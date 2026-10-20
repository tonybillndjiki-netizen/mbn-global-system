import {brandFor} from './branding.js';

export const letterErrors={
 letter_settings_changed:'Les paramètres ou le dossier ont changé. Rouvrez la lettre et générez un nouvel aperçu.',
 letter_settings_missing:'Un administrateur doit renseigner et activer les paramètres de cette école pour ce type d’admission.',
 invalid_letter_settings:'Vérifiez les frais, le signataire, les rentrées et le type d’admission.',
 national_attachment_conflict:'Cette annexe internationale ne peut pas accompagner une admission nationale.',
 admission_required:'Une décision d’admission et une formation sont nécessaires pour préparer la lettre.',
};

const typeLabel=type=>type==='NATIONAL'?'Nationale':'Internationale';
const settingKeys=['academic_year','intake','deferred_intake','registration_fee','tuition_deposit','confirmation_days','signatory','avi_mode'];
const settingsSummary=(f,h)=>`<dl class="letter-settings-summary"><div><dt>Année / rentrée</dt><dd>${h(f.academic_year)} / ${h(f.intake)}</dd></div><div><dt>Frais d’inscription</dt><dd>${h(f.registration_fee)} €</dd></div><div><dt>Acompte scolarité</dt><dd>${h(f.tuition_deposit)} €</dd></div><div><dt>Confirmation</dt><dd>${h(f.confirmation_days)} jours</dd></div><div><dt>Signataire</dt><dd>${h(f.signatory)}</dd></div>${f.deferred_intake?`<div><dt>Rentrée décalée</dt><dd>${h(f.deferred_intake)}</dd></div>`:''}</dl>`;

export async function openLetterSettings(deps,schoolCode='',admissionType='NATIONAL'){
 const {request,dialog,escapeHTML:h,toast}=deps,data=await request('letter_config_get');
 const node=dialog('Paramètres des lettres d’admission',`
  <p class="small">Enregistrez les frais, le signataire et la rentrée de chaque école. Les admissions nationales et internationales disposent de paramètres distincts. Les valeurs initiales sont vides.</p>
  <form id="letterSettingsForm"><div class="form-grid">
   <label>École<select name="school_code" required><option value="">Choisir une école</option>${data.schools.map(s=>`<option value="${h(s.code)}" ${s.is_active?'':'disabled'}>${h(s.name)}${s.is_active?'':' (désactivée)'}</option>`).join('')}</select></label>
   <label>Admission<select name="admission_type"><option value="NATIONAL">Nationale</option><option value="INTERNATIONAL">Internationale</option></select></label>
  </div><div id="letterSettingStatus" class="notice" role="status"></div>
  <fieldset id="letterSettingFields" class="letter-settings-fields"><legend>Paramètres de cette école</legend><div class="form-grid">
   <label>Année académique<input name="academic_year" required pattern="20[0-9]{2}/20[0-9]{2}" placeholder="AAAA/AAAA"></label>
   <label>Rentrée<input name="intake" required maxlength="80" placeholder="Mois et année"></label>
   <label data-international>Rentrée décalée<input name="deferred_intake" maxlength="80"></label>
   <label>Délai de confirmation (jours)<input name="confirmation_days" type="number" required min="1" max="90"></label>
   <label>Frais d’inscription (€)<input name="registration_fee" type="number" required min="0" step="0.01" max="99999.99"></label>
   <label>Acompte scolarité (€)<input name="tuition_deposit" type="number" required min="0" step="0.01" max="99999.99"></label>
   <label>Signataire<input name="signatory" required maxlength="120"></label>
   <label data-international>Règle AVI<select name="avi_mode"><option value="">Choisir la règle applicable</option><option value="OPTIONAL">Facultative, recommandée</option><option value="REQUIRED">Engagement de souscription retenu</option></select></label>
  </div><p class="small">Saisissez 0 si aucun montant n’est demandé à cette étape. Les frais de formation et leur financement restent définis dans les documents d’inscription applicables.</p>
  <p class="small" id="letterTemplateHint"></p>
  <label class="check-label"><input type="checkbox" name="enabled"> J’ai vérifié les paramètres et le texte du modèle applicable ; autoriser la génération de nouvelles lettres pour cette école et ce type d’admission.</label></fieldset>
  <div class="error form-error" role="alert" hidden></div><div class="dialog-actions"><button class="btn" type="submit">Enregistrer les paramètres</button></div></form>
  <details class="more"><summary>État des ${data.schools.length} écoles</summary><div class="table-wrap"><table class="data-table"><thead><tr><th>École</th><th>National</th><th>International</th></tr></thead><tbody>${data.schools.map(s=>`<tr><td>${h(s.name)}</td>${['NATIONAL','INTERNATIONAL'].map(t=>`<td>${data.settings.find(x=>x.school_code===s.code&&x.admission_type===t)?.enabled?'Prêt':'À configurer ou en pause'}</td>`).join('')}</tr>`).join('')}</tbody></table></div></details>`,{wide:true});
 const form=node.querySelector('#letterSettingsForm'),fields=form.elements,button=form.querySelector('[type=submit]'),error=form.querySelector('.form-error');
 fields.school_code.value=schoolCode;fields.admission_type.value=admissionType;
 let current;
 function populate(){
  current=data.settings.find(s=>s.school_code===fields.school_code.value&&s.admission_type===fields.admission_type.value);
  const national=fields.admission_type.value==='NATIONAL';
  for(const key of settingKeys)fields[key].value=current?.fields[key]||'';
  fields.enabled.checked=Boolean(current?.enabled);
  node.querySelector('#letterSettingFields').disabled=!current;
  node.querySelectorAll('[data-international]').forEach(label=>{label.hidden=national;label.querySelector('input,select').disabled=national;label.querySelector('input,select').required=!national;});
  node.querySelector('#letterSettingStatus').textContent=!current?'Choisissez une école.':current.enabled?'Paramètres prêts pour les nouvelles lettres.':'Génération en pause : renseignez et vérifiez les paramètres avant activation.';
  node.querySelector('#letterTemplateHint').textContent=national?'Le modèle national est un texte de base à valider par la direction. Il ne contient aucune mention de visa ni d’AVI. Consultez ensuite un aperçu PDF avant tout envoi.':'Le modèle international conserve les mentions du document fourni. Vérifiez notamment la rentrée décalée, les frais et la règle AVI.';
  button.disabled=!current;error.hidden=true;
 }
 fields.school_code.onchange=populate;fields.admission_type.onchange=populate;populate();
 form.onsubmit=async event=>{
  event.preventDefault();if(!current)return;button.disabled=true;error.hidden=true;
  const selected=current,school=fields.school_code.value,type=fields.admission_type.value;
  const values=Object.fromEntries(settingKeys.map(key=>[key,String(fields[key].value).trim()]));
  if(type==='NATIONAL'){values.avi_mode='NONE';values.deferred_intake='';}
  fields.school_code.disabled=true;fields.admission_type.disabled=true;
  try{
   const row=await request('letter_config_save',{school_code:school,admission_type:type,expected_revision:selected.revision,fields:values,enabled:fields.enabled.checked});
   data.settings=data.settings.map(s=>s.school_code===school&&s.admission_type===type?row:s);
   toast('Paramètres des lettres enregistrés.');node.close();await openLetterSettings(deps,school,type);
  }catch(e){error.textContent=e.message;error.hidden=false;}
  finally{fields.school_code.disabled=false;fields.admission_type.disabled=false;if(button.isConnected)button.disabled=false;}
 };
 return node;
}

export async function openLetterEditor(deps,applicationId){
 const {request,dialog,escapeHTML:h,toast,refreshCRM}=deps,data=await request('letter_context',{application_id:applicationId});
 const a=data.application,d=data.details||{},brand=brandFor(a.school_code),national=a.admission_type==='NATIONAL',setting=data.letter_settings;
 const ready=Boolean(setting?.enabled),canGenerate=ready&&a.status==='ADMITTED';
 const assets=data.assets.filter(x=>!national||!['avi_attestation','visa_refusal','rib_cameroun'].includes(x.key));
 const node=dialog('Lettre d’admission - '+data.school.name,`
  <div class="notice"><strong>${h(brand.name)} / Admission ${typeLabel(a.admission_type).toLowerCase()}</strong><br>${national?'Modèle national : vérifiez le texte et les conditions applicables à ce candidat.':'Modèle international fourni : vérifiez le texte, la rentrée et les annexes applicables.'}</div>
  <section><div class="row between wrap"><h3>Paramètres de l’école</h3>${data.can_configure?'<button type="button" class="btn ghost sm" id="configureLetter">Configurer les lettres</button>':''}</div>
  ${ready?settingsSummary(setting.fields,h):'<p class="warning">Les paramètres de ce type d’admission doivent être renseignés et activés par un administrateur avant de générer une lettre.</p>'}</section>
  <form id="letterForm"><div class="compose-grid"><div><div class="form-grid">
   <label>École<input readonly value="${h(data.school.name)}"></label>
   <label>Identité visuelle<select name="logo_variant">${brand.campus?'<option value="CAMPUS">Campus Innovation</option><option value="CAMPUS_AND_SCHOOL">Campus Innovation + école</option>':'<option value="SCHOOL">Logo de l’école</option>'}</select></label>
   <label>Date de naissance<input name="date_of_birth" type="date" required value="${h(d.date_naissance||'')}"></label>
   <label>Lieu de naissance<input name="place_of_birth" required maxlength="180" value="${h(d.lieu_naissance||'')}"></label>
  </div><h3 class="more">Pièces jointes</h3>
  <label>Conditions générales<select name="cgv" required><option value="">Choisir les CGV applicables</option>${assets.filter(x=>x.key.startsWith('cgv_')).map(x=>`<option value="${h(x.key)}">${h(x.label)}</option>`).join('')}</select></label>
  <div class="document-list">${assets.map(x=>`<div class="row between wrap"><label class="check-label">${x.key.startsWith('cgv_')?'':`<input type="checkbox" name="attachment" value="${h(x.key)}" ${x.key==='avi_attestation'?`disabled ${setting?.fields.avi_mode==='REQUIRED'?'checked':''}`:''}>`}${h(x.label)}</label><button type="button" class="btn ghost sm" data-letter-asset="${h(x.key)}">Consulter</button></div>`).join('')}</div>
  <p class="small">Consultez les annexes et choisissez celles qui correspondent à cette école et ce candidat. Aucun RIB n’est ajouté automatiquement.${!national&&setting?.fields.avi_mode==='REQUIRED'?' L’engagement AVI est obligatoire avec la règle enregistrée.':''}</p>
  <div class="error form-error" role="alert" hidden></div><div class="dialog-actions"><button class="btn" type="submit" ${canGenerate?'':'disabled'}>Générer l’aperçu PDF</button></div></div>
  <div class="preview-column"><span class="eyebrow">LETTRE ET NOTICE</span><div id="letterPreview" class="notice" role="status">L’aperçu PDF apparaîtra ici après génération.</div><p id="letterPreviewStatus" class="small" role="status"></p>
  <label class="check-label"><input type="checkbox" id="approveLetter" disabled> J’ai vérifié le candidat, le logo, la formation, la rentrée, les frais, le texte et chaque pièce jointe.</label>
  <button class="btn full" type="button" id="sendLetter" disabled>Envoyer la lettre et ses pièces avec Brevo</button><p class="small">La génération ne déclenche aucun envoi. Une acceptation par Brevo et la remise au serveur destinataire sont suivies séparément.</p></div></div></form>
  ${data.letters.length?`<h3 class="more">Lettres générées</h3><div class="document-list">${data.letters.map(l=>`<div class="row between wrap"><span>${h(new Date(l.created_at).toLocaleString('fr-FR'))} / ${h(l.status||'Aperçu généré')}</span>${l.generated_at?`<button class="btn ghost sm" type="button" data-letter-download="${h(l.id)}">Télécharger le PDF</button>`:''}</div>`).join('')}</div>`:''}`,{wide:true});
 const form=node.querySelector('#letterForm'),generate=form.querySelector('[type=submit]'),send=node.querySelector('#sendLetter'),approval=node.querySelector('#approveLetter'),preview=node.querySelector('#letterPreview'),status=node.querySelector('#letterPreviewStatus'),error=form.querySelector('.form-error');
 let generatedId,previewURL,editVersion=0;
 const clear=()=>{generatedId=undefined;approval.checked=false;approval.disabled=true;send.disabled=true;};
 form.addEventListener('input',event=>{if(event.target===approval){send.disabled=!approval.checked||!generatedId;return;}editVersion++;clear();status.textContent=previewURL?'Le formulaire a changé. Générez un nouvel aperçu.':'';});
 node.addEventListener('close',()=>{if(previewURL)URL.revokeObjectURL(previewURL);},{once:true});
 const saveBlob=(blob,name)=>{const url=URL.createObjectURL(blob),link=document.createElement('a');link.href=url;link.download=name;link.click();setTimeout(()=>URL.revokeObjectURL(url),1000);};
 const bind=(selector,fn)=>node.querySelectorAll(selector).forEach(button=>button.onclick=async()=>{button.disabled=true;try{await fn(button);}catch(e){toast(e.message);}finally{if(button.isConnected)button.disabled=false;}});
 bind('#configureLetter',async()=>{node.close();await openLetterSettings(deps,a.school_code,a.admission_type);await refreshCRM();});
 bind('[data-letter-asset]',async button=>{const asset=assets.find(x=>x.key===button.dataset.letterAsset);saveBlob(await request('letter_asset',{application_id:applicationId,key:asset.key},true),asset.filename);});
 bind('[data-letter-download]',async button=>saveBlob(await request('letter_download',{id:button.dataset.letterDownload},true),'admission-'+a.application_reference+'.pdf'));
 form.onsubmit=async event=>{
  event.preventDefault();if(!canGenerate)return;generate.disabled=true;error.hidden=true;clear();
  const version=editVersion,values=new FormData(form),attachments=values.getAll('attachment');
  if(values.get('cgv'))attachments.push(values.get('cgv'));
  if(!national&&setting.fields.avi_mode==='REQUIRED')attachments.push('avi_attestation');
  try{
   const fields=Object.fromEntries(['date_of_birth','place_of_birth','logo_variant'].map(key=>[key,values.get(key)]));
   const result=await request('letter_generate',{application_id:applicationId,request_id:crypto.randomUUID(),expected_config_revision:setting.revision,fields,attachments});
   const blob=await request('letter_download',{id:result.id},true);
   if(!node.isConnected||version!==editVersion){status.textContent='Le formulaire a changé pendant la génération. Générez un nouvel aperçu.';return;}
   if(previewURL)URL.revokeObjectURL(previewURL);previewURL=URL.createObjectURL(blob);
   const frame=document.createElement('iframe');frame.title='Lettre d’admission à vérifier';frame.src=previewURL;frame.className='letter-pdf';preview.replaceChildren(frame);
   generatedId=result.id;approval.disabled=false;status.textContent='PDF généré. Consultez-le puis vérifiez le contenu et les annexes.';
  }catch(e){error.textContent=e.message;error.hidden=false;}
  finally{if(generate.isConnected)generate.disabled=!canGenerate;}
 };
 send.onclick=async()=>{
  if(!generatedId||!approval.checked)return;send.disabled=true;approval.disabled=true;generate.disabled=true;
  try{const result=await request('letter_send',{id:generatedId,confirmed:true});clear();status.textContent=result.status==='ACCEPTED'?'Lettre acceptée par Brevo. Consultez ensuite son retour de livraison.':result.status==='UNCERTAIN'?'Résultat d’envoi à vérifier. Aucun nouvel envoi automatique ne sera effectué.':'Envoi refusé. Consultez la file d’envoi.';await refreshCRM();}
  catch(e){status.textContent=e.message;approval.disabled=false;send.disabled=false;}
  finally{if(generate.isConnected)generate.disabled=!canGenerate;}
 };
 return node;
}
