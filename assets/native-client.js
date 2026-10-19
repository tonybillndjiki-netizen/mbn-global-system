(() => {
  'use strict';
  const url='https://ppqeuluykiknuujfaoid.supabase.co';
  const publicKey='sb_publishable_NGnS0aBO4WUBbL6EbgMr0A_ad6EfOzS';
  const school=document.querySelector('meta[name="mbn-school"]').content;
  const $=id=>document.getElementById(id);
  const value=id=>String($(id)?.value||'').trim();
  const key='mbn-native-test-reference:'+school;
  let candidateToken='';
  const fragment=typeof location==='undefined'?'':location.hash.slice(1);
  if(/^[a-f0-9-]{36}\.[a-f0-9]{64}$/.test(fragment)){
    candidateToken=fragment;
    try{sessionStorage.setItem('mbn-candidate:'+school,candidateToken);}catch{}
    if(typeof history!=='undefined')history.replaceState(null,'',location.pathname);
  }else{try{candidateToken=sessionStorage.getItem('mbn-candidate:'+school)||'';}catch{}}
  const candidate=!!candidateToken;
  let candidateInfo;
  let reference;
  try{reference=sessionStorage.getItem(key);}catch{}
  if(!/^MBNTEST-[a-f0-9-]{36}$/.test(reference||''))reference='MBNTEST-'+crypto.randomUUID();
  if(candidate)reference='MBNAPP-'+candidateToken.slice(0,36);
  try{sessionStorage.setItem(key,reference);}catch{}
  let client,programs=[],catalogueReady=false,authorized=false,busy=false;
  const status=text=>{$('mbn-native-status').textContent=text;};
  $('mbn-native-reference').textContent='Référence de cet essai : '+reference;
  const messages={
    reference_conflict:'Cette référence correspond à un autre contenu. Reprenez les mêmes données et documents pour réessayer, ou choisissez « Nouvel essai ».',
    admin_required:'Connectez-vous avec votre compte administrateur actif.',
    authentication_required:'Votre session a expiré. Reconnectez-vous pour reprendre cet essai.',
    catalogue_selection_invalid:'L’école, le campus ou la formation n’est plus disponible. Actualisez le catalogue.',
    school_inactive_or_unknown:'Cette école est désactivée.',
    program_not_found:'Cette formation n’est plus proposée. Actualisez le catalogue.',
    documents_pending:'Le dépôt des documents doit être repris avec les mêmes fichiers.',
    document_type_mismatch:'Un document ne correspond pas à son format annoncé. Utilisez un PDF, JPEG ou PNG valide.',
    file_too_large:'Chaque fichier doit peser au maximum 5 Mo.',files_too_large:'Les documents doivent peser au maximum 20 Mo au total.',
    temporarily_unavailable:'Le service est temporairement indisponible. Réessayez avec les mêmes données et documents : votre référence est conservée.',
    test_quota_reached:'La limite des essais de cette heure est atteinte.',
    invitation_mismatch:'Utilisez l’adresse e-mail du prospect auquel ce lien a été attribué.',
    required_documents_missing:'Joignez votre CV, votre diplôme, votre pièce d’identité et, pour une admission nationale, votre carte Vitale.',
    link_unavailable:'Cette invitation a expiré ou l’école n’est plus disponible. Contactez l’équipe admissions.',
    intake_busy:'Le service reçoit beaucoup de dossiers. Réessayez plus tard avec les mêmes fichiers.',
  };
  function ready(){if($('btn-submit'))$('btn-submit').disabled=busy||!catalogueReady||!authorized;}
  function options(element,entries,placeholder='— Sélectionnez —'){
    if(!element)return;
    const previous=element.value;
    element.replaceChildren(new Option(placeholder,''));
    for(const [value,label] of entries)element.add(new Option(label,value));
    element.disabled=entries.length===0;
    if(entries.some(entry=>entry[0]===previous))element.value=previous;
    else if(entries.length===1)element.value=entries[0][0];
  }
  const unique=(rows,key)=>[...new Set(rows.map(p=>p[key]||''))].sort((a,b)=>a.localeCompare(b,'fr')).map(v=>[v||'__UNSPECIFIED__',v||'Non renseigné dans le catalogue']);
  function cascade(){
    if(!catalogueReady)return;
    let rows=programs;
    const stages=[['cycle','cycle'],['niveau_academique','academic_level'],[$('domaine')?'domaine':'niveau','domain']];
    for(const [id,field] of stages){
      const el=$(id);if(!el)continue;
      options(el,unique(rows,field));
      rows=el.value ? rows.filter(p=>(p[field]||'')===(el.value==='__UNSPECIFIED__'?'':el.value)) : [];
    }
    options($('formation'),rows.map(p=>[p.id,[p.name,!$('niveau_academique')?p.academic_level:''].filter(Boolean).join(' — ')]),'— Sélectionnez votre formation —');
    const selected=programs.find(p=>p.id===value('formation'));
    if(selected?.pace)options($('rythme'),[[selected.pace,selected.pace]]);
  }
  async function catalogue(){
    const [p,c,s]=await Promise.all([
      client.from('school_programs').select('id,name,cycle,academic_level,domain,pace').eq('school_code',school).eq('is_active',true).order('name').range(0,4999),
      client.from('school_campuses').select('campus_code').eq('school_code',school),
      client.from('schools').select('code,is_active').eq('code',school).eq('is_active',true).maybeSingle(),
    ]);
    if(p.error||c.error||s.error||!s.data||!p.data?.length||!c.data?.length)throw Error('Le catalogue de cette école est indisponible.');
    programs=p.data;catalogueReady=true;
    options($('campus'),c.data.map(row=>[row.campus_code,row.campus_code==='NOISIEL'?'Campus Innovation Marne-la-Vallée':row.campus_code==='EVRY'?'Évry':row.campus_code]));
    for(const name of ['updateCycles','updateNiveaux','updateDomaines','updateFormationsCascade','updateFormations'])window[name]=cascade;
    for(const id of ['campus','cycle','niveau_academique','domaine','niveau','formation']){
      const el=$(id);if(!el)continue;
      el.removeAttribute('onchange');el.addEventListener('change',cascade);
    }
    cascade();ready();
  }
  async function access(){
    if(candidate){authorized=true;$('mbn-native-login').hidden=true;$('mbn-native-logout').hidden=true;status('Votre candidature sera transmise directement à l’équipe admissions de '+school+'.');ready();return;}
    const {data,error}=await client.auth.getUser();
    authorized=false;
    if(!error&&data.user){const result=await client.rpc('mbn_native_admin_access');authorized=!result.error&&result.data===true;}
    $('mbn-native-login').hidden=authorized;$('mbn-native-logout').hidden=!data.user;
    status(authorized?'Compte administrateur connecté. Les dossiers de test sont enregistrés directement dans MBN GLOBAL.':'Connectez-vous pour transmettre un dossier de test.');ready();
  }
  function payload(){
    const program=programs.find(p=>p.id===value('formation'));
    if(!program)throw Error('Sélectionnez une formation du catalogue actif.');
    const phone=(indicatif,id)=>[value(indicatif),value(id)].filter(Boolean).join(' ');
    return {
      reference_dossier:reference,full_name:[value('nom'),value('prenom')].filter(Boolean).join(' '),
      email:value('email'),phone:phone('indicatif_tel','telephone'),country_of_residence:value('pays_residence'),
      school_code:school,campus_code:value('campus'),program_id:program.id,program_name:program.name,
      cycle:program.cycle||'',academic_level:program.academic_level||'',domain:program.domain||'',pace:program.pace||value('rythme'),
      consent_email:$('mbn-consent-email')?.checked===true,
      details:{nom:value('nom'),prenom:value('prenom'),date_naissance:value('ddn'),lieu_naissance:value('ldn'),
        ville:value('ville'),adresse:value('adresse'),telephone_proche:phone('indicatif_proche','telephone_proche'),
        financement:/^(FRANCE|FR|FRA)$/i.test(value('pays_residence'))?value('financement_fr'):value('financement_hors_fr'),handicap:document.querySelector('input[name="handicap"]:checked')?.value||''},
    };
  }
  window.mbnSubmitNative=async()=>{
    if(busy)return;
    const error=$('error-message');
    const fail=message=>{error.textContent=message;error.classList.remove('hidden');status(message);};
    if(!authorized||!catalogueReady)return fail('Connectez-vous avec votre compte administrateur et attendez le chargement du catalogue.');
    const form=$('admission-form');
    const invalid=[...form.querySelectorAll('input[required],select[required],textarea[required]')].find(el=>!el.disabled&&!el.checkValidity());
    if(invalid){invalid.reportValidity();return fail('Complétez les champs obligatoires avant la transmission.');}
    busy=true;ready();error.classList.add('hidden');
    try{
      const body=new FormData();body.append('payload',JSON.stringify(payload()));
      const fields={file_cv:'CV',file_diplome:'DIPLOME',file_identite:'PIECE_IDENTITE',file_vitale:'CARTE_VITALE',file_rqth:'JUSTIFICATIF_HANDICAP',file_paiement:'JUSTIFICATIF_PAIEMENT'};
      let size=0;
      for(const [id,kind] of Object.entries(fields)){
        const file=$(id)?.files?.[0];if(!file)continue;
        if(file.size>5*1024*1024)throw Error('Chaque document doit peser au maximum 5 Mo.');
        size+=file.size;body.append(kind,file,file.name);
      }
      if(size>20*1024*1024)throw Error('Les documents doivent peser au maximum 20 Mo au total.');
      const {data:{session}}=await client.auth.getSession();
      if(!candidate&&!session)throw Error('Reconnectez-vous pour reprendre cet essai.');
      status('Transmission du dossier et des documents…');
      const response=await fetch(url+'/functions/v1/'+(candidate?'mbn-admissions':'mbn-form-ingest'),{
        method:'POST',headers:candidate?{'x-mbn-admission':candidateToken,apikey:publicKey}:{Authorization:'Bearer '+session.access_token,apikey:publicKey},body,
      });
      let result;try{result=await response.json();}catch{throw Error(messages.temporarily_unavailable);}
      if(!response.ok||result.success!==true||(!candidate&&result.test!==true)||result.reference!==reference)throw Error(messages[result.error]||`Transmission refusée (${response.status}). Vérifiez les champs du dossier.`);
      for(const step of document.querySelectorAll('.step-container'))step.style.display='none';
      $('form-navigation').style.display='none';
      const screen=$('success-screen');screen.replaceChildren();
      const title=document.createElement('h2');title.textContent=candidate?'Votre candidature est reçue':'Dossier de test reçu';title.style.cssText='font-size:25px;font-weight:700;margin-bottom:15px';
      const ref=document.createElement('p');ref.textContent=reference;
      const detail=document.createElement('p');detail.textContent=candidate?`${result.document_count||0} pièce(s) jointe(s). Votre dossier est en cours de prise en charge par l’équipe admissions.`:`${result.document_count||0} document(s) enregistré(s) en accès privé. Aucun e-mail envoyé.`;
      screen.append(title,ref,detail);screen.classList.remove('hidden');
      status(candidate?'Candidature enregistrée. Conservez votre référence de dossier.':'Essai enregistré. Retrouvez ce dossier dans la console administrateur, rubrique Formulaires.');
    }catch(err){fail(err.message||messages.temporarily_unavailable);}finally{busy=false;ready();}
  };
  async function boot(){
    ready();
    const {createClient}=await import('https://esm.sh/@supabase/supabase-js@2.57.2');
    client=createClient(url,publicKey,{auth:{persistSession:true,autoRefreshToken:true,detectSessionInUrl:false}});
    if(candidate){
      const response=await fetch(url+'/functions/v1/mbn-admissions',{method:'POST',headers:{'Content-Type':'application/json',apikey:publicKey},body:JSON.stringify({action:'info',token:candidateToken})});
      candidateInfo=await response.json();if(!response.ok||candidateInfo.school_code!==school)throw Error('invitation_unavailable');
      const header=$('mbn-native-test');header.setAttribute('aria-label','Votre candidature');
      const heading=header.querySelector('p');heading.replaceChildren();
      const title=document.createElement('strong');title.textContent=school+' · Candidature';heading.append(title);
      const notice=header.querySelectorAll('p')[1];notice.textContent='Complétez ce formulaire et joignez vos documents. Les champs obligatoires sont indiqués dans chaque étape.';
      for(const id of ['mbn-native-access','mbn-native-new','mbn-native-login','mbn-native-logout'])$(id).hidden=true;
      $('mbn-native-reference').textContent='Référence de candidature : '+reference;
      for(const a of header.querySelectorAll('a'))a.hidden=true;
      if(candidateInfo.submitted){status('Une candidature a déjà été reçue avec cette invitation. Conservez votre référence et contactez l’équipe admissions pour la suite.');catalogueReady=false;ready();return;}
    }
    $('mbn-native-login').addEventListener('submit',async event=>{
      event.preventDefault();const button=event.currentTarget.querySelector('button');button.disabled=true;
      try{await window.MBNAuth.login(client,value('mbn-native-username'),$('mbn-native-password').value);$('mbn-native-password').value='';await access();}
      catch(err){status(err.message||'Connexion refusée. Vérifiez votre nom d’utilisateur et vos six chiffres.');}finally{button.disabled=false;}
    });
    $('mbn-native-access').onclick=()=>window.MBNAuth.configure(client).then(()=>access()).catch(err=>status(err.message));
    $('mbn-native-logout').onclick=async()=>{await client.auth.signOut();await access();};
    $('mbn-native-new').onclick=()=>{if(confirm('Démarrer un nouvel essai avec une nouvelle référence ? Pour reprendre un envoi interrompu, conservez la référence actuelle.')){try{sessionStorage.removeItem(key);}catch{}location.reload();}};
    const consent=document.createElement('label');consent.style.cssText='display:block;padding:14px;font-size:13px';
    const checkbox=document.createElement('input');checkbox.id='mbn-consent-email';checkbox.type='checkbox';
    consent.append(checkbox,document.createTextNode(' Je souhaite recevoir les communications de l’école par e-mail (facultatif).'));
    $('form-navigation').before(consent);
    await catalogue();await access();
    client.auth.onAuthStateChange(event=>{if(event==='SIGNED_OUT'){authorized=false;ready();status('Session déconnectée.');}});
  }
  boot().catch(()=>{catalogueReady=false;authorized=false;ready();status('Le service est indisponible. Rechargez la page pour charger le catalogue.');});
})();
