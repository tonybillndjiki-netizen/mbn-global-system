export const metaErrors={
 invalid_meta_route:'Vérifiez le formulaire, la page, l’école et les champs de correspondance.',
 meta_form_already_mapped:'Ce formulaire est déjà rattaché. Modifiez sa configuration existante.',
 meta_route_changed:'Le rattachement a changé. Actualisez avant de recommencer.',
 meta_route_missing:'Configurez et activez le rattachement de ce formulaire avant de le reprendre.',
 meta_event_changed:'Cette notification a changé ou a déjà été traitée. Actualisez la liste.',
 meta_configuration_missing:'La connexion Meta doit être configurée côté serveur par votre responsable technique.',
 meta_page_token_missing:'L’accès à cette page Meta doit être installé côté serveur.',
 meta_token_rejected:'Meta refuse le jeton de cette page. Faites vérifier son accès.',
 meta_permission_denied:'L’accès aux prospects de cette page doit être autorisé dans Meta.',
 meta_required_fields_missing:'Les données reçues ne contiennent pas un nom et une adresse e-mail valides. Vérifiez les champs du formulaire.',
 meta_identity_mismatch:'La fiche reçue ne correspond pas à la notification attendue.',
 meta_source_conflict:'Cet identifiant Meta existe déjà pour une autre école ou un dossier de test. Vérifiez son rattachement.',
 meta_connection_unavailable:'Meta est momentanément inaccessible. Une reprise est prévue.',
 meta_temporarily_unavailable:'Meta limite momentanément les demandes. Une reprise est prévue.',
 meta_lead_unavailable:'Cette fiche n’est pas accessible avec les droits Meta actuels.',
 meta_invalid_response:'La réponse Meta ne permet pas de traiter cette fiche.',
 meta_processing_interrupted:'La récupération a été interrompue. Une reprise peut être effectuée.',
 meta_processing_failed:'La récupération doit être vérifiée avant une nouvelle tentative.',
};
const statusText={UNMAPPED:'Formulaire à rattacher',PENDING:'En attente',PROCESSING:'Récupération en cours',RETRY:'Reprise prévue',FAILED:'À vérifier',IMPORTED:'Prospect créé',DUPLICATE:'Déjà présent'};
export async function renderMeta(deps){
 const {root,request,dialog,escapeHTML:h,toast,openLead}=deps,data=await request('meta_context');
 const serverReady=data.credentials.app_secret_configured&&data.credentials.graph_version_configured&&data.credentials.verify_token_configured;
 const active=data.routes.filter(r=>r.ready&&r.page_token_configured&&serverReady).length;
 const waiting=['UNMAPPED','PENDING','PROCESSING','RETRY'].reduce((n,s)=>n+Number(data.counts[s]||0),0);
 root.innerHTML=`<section class="panel no-top"><div class="panel-head"><div><h2>Prospects Meta</h2><p class="small">Les nouvelles réponses aux formulaires Meta arrivent dans le carnet de prospects de leur école.</p></div><div class="row wrap"><button class="btn ghost" id="refreshMeta">Actualiser</button><button class="btn" id="newMetaRoute">Rattacher un formulaire</button></div></div>
  <div class="meta-summary"><div><strong>${active}</strong><span>Formulaires prêts</span></div><div><strong>${waiting}</strong><span>Notifications à traiter</span></div><div><strong>${Number(data.counts.FAILED||0)}</strong><span>Récupérations à vérifier</span></div></div>
  ${serverReady?'':'<p class="notice">La connexion Meta doit être installée côté serveur par votre responsable technique. Vous pouvez préparer les rattachements ci-dessous. Aucun jeton d’accès n’est saisi dans cet écran.</p>'}
  <p class="small">Chaque formulaire choisit son école. Le consentement e-mail est absent tant qu’une réponse explicite et son libellé n’ont pas été configurés et retrouvés dans les données reçues. Cette connexion ne lance aucune campagne automatiquement.</p>
  <h3 class="more">Formulaires rattachés</h3>${data.routes.length?`<div class="table-wrap"><table class="data-table"><thead><tr><th>Formulaire / page</th><th>École</th><th>État</th><th></th></tr></thead><tbody>${data.routes.map(r=>`<tr><td><strong>${h(r.label)}</strong><div class="small">Formulaire ${h(r.form_id)}<br>Page ${h(r.page_id)}</div></td><td>${h(data.schools.find(s=>s.code===r.school_code)?.name||r.school_code)}</td><td><span class="status ${r.ready&&r.page_token_configured&&serverReady?'ok':''}">${!r.enabled?'En pause':r.ready&&r.page_token_configured&&serverReady?'Prêt':'Configuration à terminer'}</span><div class="small">${r.page_token_configured?'Accès à la page installé':'Accès à la page à installer'}</div></td><td><button class="btn ghost sm" data-meta-edit="${h(r.id)}">Modifier</button></td></tr>`).join('')}</tbody></table></div>`:'<p class="notice">Aucun formulaire n’est rattaché. Choisissez son école et ses champs avant de l’activer.</p>'}
  <div class="row between wrap more"><h3>Dernières notifications</h3><button class="btn ghost" id="processMeta" ${active?'':'disabled'}>Traiter les notifications en attente</button></div>
  ${data.events.length?`<div class="table-wrap"><table class="data-table"><thead><tr><th>Réception / identifiant</th><th>Formulaire</th><th>Résultat</th><th></th></tr></thead><tbody>${data.events.map(e=>`<tr><td>${h(new Date(e.received_at).toLocaleString('fr-FR'))}<div class="small">${h(e.leadgen_id)}</div></td><td>${h(data.routes.find(r=>r.id===e.route_id)?.label||e.form_id)}</td><td><strong>${h(statusText[e.status]||e.status)}</strong><div class="small">${e.attempts} tentative(s)${e.error_code?'<br>'+h(metaErrors[e.error_code]||'Vérification nécessaire'):''}</div></td><td>${['UNMAPPED','RETRY','FAILED'].includes(e.status)?`<button class="btn ghost sm" data-meta-retry="${h(e.id)}">Reprendre</button>`:''}${e.lead_id?`<button class="btn ghost sm" data-meta-lead="${h(e.lead_id)}">Voir le prospect</button>`:''}</td></tr>`).join('')}</tbody></table></div><p class="small more">Les 50 dernières notifications sont affichées. Les reprises automatiques sont limitées à cinq tentatives. Un formulaire en pause ne lance aucune nouvelle récupération.</p>`:'<p class="notice">Aucune notification Meta reçue. La connexion doit être installée puis testée avec un formulaire autorisé.</p>'}
 </section>`;
 const reload=()=>renderMeta(deps);
 const bind=(selector,fn)=>root.querySelectorAll(selector).forEach(button=>button.onclick=async()=>{button.disabled=true;try{await fn(button);}catch(e){toast(e.message);}finally{if(button.isConnected)button.disabled=false;}});
 bind('#refreshMeta',reload);bind('#newMetaRoute',()=>editRoute());
 bind('[data-meta-edit]',button=>editRoute(data.routes.find(r=>r.id===button.dataset.metaEdit)));
 bind('[data-meta-lead]',button=>openLead(button.dataset.metaLead));
 bind('#processMeta',async()=>{const result=await request('meta_process');toast(`${result.processed} notification(s) traitée(s).`);await reload();});
 bind('[data-meta-retry]',async button=>{const e=data.events.find(x=>x.id===button.dataset.metaRetry);await request('meta_retry',{id:e.id,expected_revision:e.revision});toast('Notification remise en attente.');await reload();});
 function editRoute(route){
  const r=route||{},mapping=r.field_map||{name:'full_name',email:'email',phone:'phone_number',country:'country'};
  const node=dialog(route?'Modifier le rattachement Meta':'Rattacher un formulaire Meta',`
   <form id="metaRouteForm"><div class="form-grid">
    <label>Nom du formulaire<input name="label" required maxlength="120" value="${h(r.label||'')}"></label>
    <label>École<select name="school_code" required><option value="">Choisir une école</option>${data.schools.map(s=>`<option value="${h(s.code)}" ${s.is_active?'':'disabled'}>${h(s.name)}</option>`).join('')}</select></label>
    <label>Identifiant de la page Meta<input name="page_id" required inputmode="numeric" pattern="[0-9]{5,30}" value="${h(r.page_id||'')}"></label>
    <label>Identifiant du formulaire Meta<input name="form_id" required inputmode="numeric" pattern="[0-9]{5,30}" value="${h(r.form_id||'')}"></label>
    <label>Campus (facultatif)<select name="campus_code"></select></label><label>Formation (facultative)<select name="program_id"></select></label>
   </div><details class="more"><summary>Correspondance des champs Meta</summary><p class="small">Utilisez les noms de champs transmis par votre formulaire. Si « full_name » est absent, les champs « first_name » et « last_name » sont utilisés.</p><div class="form-grid">
    ${[['name','Nom complet'],['email','Adresse e-mail'],['phone','Téléphone (facultatif)'],['country','Pays (facultatif)']].map(([key,label])=>`<label>${label}<input name="field_${key}" ${['name','email'].includes(key)?'required':''} maxlength="100" value="${h(mapping[key]||'')}"></label>`).join('')}
   </div></details><details class="more" ${r.consent_field?'open':''}><summary>Consentement aux e-mails (facultatif)</summary><p class="small">Renseignez ensemble le champ de réponse, la valeur acceptée et le texte réellement présenté au candidat. Sans cette preuve, le prospect reste enregistré sans consentement e-mail.</p>
    <div class="form-grid"><label>Champ du consentement<input name="consent_field" maxlength="100" value="${h(r.consent_field||'')}"></label><label>Valeur exacte correspondant à l’accord<input name="consent_value" maxlength="160" value="${h(r.consent_value||'')}"></label></div>
    <label>Texte de l’accord présenté dans Meta<textarea name="consent_statement" maxlength="300" rows="3">${h(r.consent_statement||'')}</textarea></label>
   </details><label class="check-label more"><input type="checkbox" name="enabled" ${r.enabled?'checked':''}> Autoriser la récupération automatique pour ce formulaire</label>
   <p class="small">Les nouvelles récupérations utiliseront ce rattachement. Les prospects déjà créés conserveront leur école et leur historique.</p>
   <div class="error form-error" role="alert" hidden></div><div class="dialog-actions"><button class="btn" type="submit">Enregistrer le rattachement</button></div></form>`,{wide:true});
  const form=node.querySelector('#metaRouteForm'),f=form.elements,button=form.querySelector('[type=submit]'),error=form.querySelector('.form-error');
  const option=(value,label)=>`<option value="${h(value)}">${h(label)}</option>`;
  f.school_code.value=r.school_code||'';
  function populate(){
   f.campus_code.innerHTML=option('','Non précisé')+data.campuses.filter(c=>c.school_code===f.school_code.value).map(c=>option(c.code,c.name)).join('');
   f.program_id.innerHTML=option('','Non précisée')+data.programs.filter(p=>p.school_code===f.school_code.value).map(p=>option(p.id,p.name)).join('');
   f.campus_code.disabled=!f.school_code.value;f.program_id.disabled=!f.school_code.value;
  }
  f.school_code.onchange=populate;populate();f.campus_code.value=r.campus_code||'';f.program_id.value=r.program_id||'';
  form.onsubmit=async event=>{
   event.preventDefault();button.disabled=true;error.hidden=true;
   const values=Object.fromEntries(new FormData(form));
   const payload=Object.fromEntries(['label','page_id','form_id','school_code','campus_code','program_id','consent_field','consent_value','consent_statement'].map(key=>[key,String(values[key]||'').trim()]));
   payload.field_map=Object.fromEntries(['name','email','phone','country'].map(key=>[key,String(values['field_'+key]||'').trim()]));payload.enabled=f.enabled.checked;
   if(route){payload.id=r.id;payload.expected_revision=r.revision;}
   try{await request('meta_route_save',payload);node.close();toast('Rattachement Meta enregistré.');await reload();}
   catch(e){error.textContent=e.message;error.hidden=false;}finally{if(button.isConnected)button.disabled=false;}
  };
 }
}
