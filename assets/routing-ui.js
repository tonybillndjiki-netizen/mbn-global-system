export async function openRoutingRules(deps,selectedSchool=''){
 const {request,dialog,escapeHTML:h,toast,refreshCRM}=deps,data=await request('routing_context');
 const activeSchools=data.schools.filter(s=>s.is_active),unassigned=activeSchools.reduce((n,s)=>n+Number(s.unassigned),0);
 const option=(value,label)=>`<option value="${h(value)}">${h(label)}</option>`;
 const schoolOptions=blank=>option('',blank)+data.schools.map(s=>`<option value="${h(s.code)}" ${s.is_active?'':'disabled'}>${h(s.name)}${s.is_active?'':' (désactivée)'}</option>`).join('');
 const node=dialog('Équipes et affectations',`
  <p class="small">Chaque école choisit ses responsables, avec des règles possibles par campus, formation et rentrée. Les comptes proposés disposent déjà d’un accès Admissions ou Direction à l’école.</p>
  <div class="routing-summary"><div><strong>${activeSchools.filter(s=>s.general_ready).length} / ${activeSchools.length}</strong><span>Écoles actives avec une règle générale prête</span></div><div><strong>${unassigned}</strong><span>Dossiers ouverts sans responsable</span></div></div>
  <label>Afficher une école<select id="routingSchoolScope">${option('','Toutes les écoles')+data.schools.map(s=>option(s.code,s.name)).join('')}</select></label>
  <details class="routing-coverage"><summary>Vérifier la couverture des ${data.schools.length} écoles</summary><div class="table-wrap"><table class="data-table"><thead><tr><th>École</th><th>Configuration</th><th>Sans responsable</th></tr></thead><tbody>${data.schools.map(s=>`<tr data-coverage-school="${h(s.code)}"><td><strong>${h(s.name)}</strong></td><td><span class="status ${!s.is_active?'':s.general_ready?'ok':'warn'}">${!s.is_active?'École désactivée':s.general_ready?'Règle générale prête':s.active_rules?'Règles ciblées uniquement':'À configurer'}</span><div class="small">${Number(s.active_rules)} règle(s) active(s)</div></td><td>${Number(s.unassigned)}</td></tr>`).join('')}</tbody></table></div></details>
  <section class="routing-section"><div class="row between wrap"><h3>Règles enregistrées</h3><button class="btn ghost sm" id="previewRouting" ${unassigned?'':'disabled'}>Vérifier les dossiers sans responsable</button></div><div id="routingRuleList"></div></section>
  <section class="routing-section"><h3 id="routingEditorTitle">Ajouter une règle</h3><form id="routingRuleForm"><input type="hidden" name="id"><input type="hidden" name="expected_revision"><div class="form-grid">
   <label>École<select name="school_code" required>${schoolOptions('Choisir une école')}</select></label>
   <label>Campus<select name="campus_code" disabled>${option('','Tous les campus de l’école')}</select></label>
   <label>Formation<select name="program_id" disabled>${option('','Toutes les formations de l’école')}</select></label>
   <label>Rentrée (facultative)<input name="intake" maxlength="80" placeholder="Même libellé que sur la candidature"></label>
   <label>Responsable principal<select name="primary_user" required disabled>${option('','Choisir un responsable')}</select></label>
   <label>Suppléant (facultatif)<select name="backup_user" disabled>${option('','Aucun')}</select></label>
  </div><p class="small" id="routingPeopleHint">Choisissez une école pour afficher ses collaborateurs autorisés.</p>
  <details class="more"><summary>Ordre des règles</summary><p class="small">La règle avec le plus de critères renseignés est prioritaire. À précision égale, la priorité la plus élevée gagne ; à égalité, la règle la plus ancienne est retenue. Si le principal et son suppléant sont indisponibles, le dossier reste à vérifier.</p><label>Priorité à précision égale<input name="priority" type="number" min="0" max="1000" value="0" required></label></details>
  <p class="error form-error" role="alert" hidden></p><div class="dialog-actions"><button type="button" class="btn ghost" id="resetRoutingRule">Nouvelle règle</button><button type="submit" class="btn">Enregistrer la règle</button></div></form></section>`,{wide:true});
 const scope=node.querySelector('#routingSchoolScope'),form=node.querySelector('#routingRuleForm'),fields=form.elements;
 scope.value=selectedSchool;
 const showError=error=>{const box=form.querySelector('.form-error');box.textContent=error.message;box.hidden=false;};
 const busy=async(button,fn)=>{button.disabled=true;try{await fn();}catch(error){showError(error);}finally{if(button.isConnected)button.disabled=false;}};
 const reopen=async()=>{const school=scope.value;node.close();await openRoutingRules(deps,school);};
 function populateSchool(values={}){
  const school=fields.school_code.value,people=data.people.filter(p=>p.school_code===school);
  fields.campus_code.innerHTML=option('','Tous les campus de l’école')+data.campuses.filter(c=>c.school_code===school).map(c=>option(c.code,c.name)).join('');
  fields.program_id.innerHTML=option('','Toutes les formations de l’école')+data.programs.filter(p=>p.school_code===school).map(p=>option(p.id,p.name+(p.cycle?' ('+p.cycle+')':''))).join('');
  fields.primary_user.innerHTML=option('','Choisir un responsable')+people.map(p=>option(p.id,p.name+(p.name!==p.email?' ('+p.email+')':''))).join('');
  for(const key of ['campus_code','program_id','primary_user']){
   const value=values[key]||'';
   if(value&&![...fields[key].options].some(o=>o.value===value))fields[key].insertAdjacentHTML('beforeend',option(value,(values[{campus_code:'campus_name',program_id:'program_name',primary_user:'primary_name'}[key]]||'Choix enregistré')+' (indisponible)'));
   fields[key].disabled=!school;fields[key].value=value;
  }
  if(fields.primary_user.selectedIndex<0)fields.primary_user.value='';
  populateBackup(values.backup_user||'');
  node.querySelector('#routingPeopleHint').textContent=!school?'Choisissez une école pour afficher ses collaborateurs autorisés.':people.length?'Le suppléant prend le relais si le principal n’a plus d’accès actif.':'Aucun collaborateur autorisé pour cette école. Configurez ses accès dans Équipes avant d’ajouter la règle.';
 }
 function populateBackup(selected=''){
  const people=data.people.filter(p=>p.school_code===fields.school_code.value&&p.id!==fields.primary_user.value);
  fields.backup_user.innerHTML=option('','Aucun')+people.map(p=>option(p.id,p.name+(p.name!==p.email?' ('+p.email+')':''))).join('');
  if(selected&&selected!==fields.primary_user.value&&!people.some(p=>p.id===selected))fields.backup_user.insertAdjacentHTML('beforeend',option(selected,'Suppléant enregistré (indisponible)'));
  fields.backup_user.disabled=!fields.school_code.value;fields.backup_user.value=selected;
  if(fields.backup_user.selectedIndex<0)fields.backup_user.value='';
 }
 function edit(rule){
  form.reset();form.querySelector('.form-error').hidden=true;
  fields.id.value=rule?.id||'';fields.expected_revision.value=rule?.revision||'';
  fields.school_code.value=rule?.school_code||scope.value;fields.intake.value=rule?.intake||'';fields.priority.value=rule?.priority??0;
  populateSchool(rule||{});node.querySelector('#routingEditorTitle').textContent=rule?'Modifier la règle':'Ajouter une règle';
  if(rule)node.querySelector('#routingEditorTitle').scrollIntoView?.({block:'nearest'});
 }
 function renderRules(){
  const rules=data.rules.filter(r=>!scope.value||r.school_code===scope.value),list=node.querySelector('#routingRuleList');
  list.innerHTML=rules.length?rules.map(r=>`<div class="routing-rule"><div><strong>${h(r.school_name)}</strong><p>${h(r.primary_name)}${r.primary_available?'':' (indisponible)'}${r.backup_name?' · Suppléant : '+h(r.backup_name)+(r.backup_available?'':' (indisponible)'):''}</p><p class="small">${h(r.campus_name||'Tous campus')} · ${h(r.program_name||'Toutes formations')} · ${h(r.intake||'Toutes rentrées')} · Priorité ${r.priority}</p></div><div class="row wrap"><span class="status ${r.is_active?(r.primary_available||r.backup_available?'ok':'warn'):''}">${r.is_active?'Active':'En pause'}</span><button type="button" class="btn ghost sm" data-edit-rule="${r.id}">Modifier</button><button type="button" class="btn ghost sm" data-toggle-rule="${r.id}">${r.is_active?'Désactiver':'Activer'}</button></div></div>`).join(''):'<p class="notice soft">Aucune règle pour cette sélection. Ajoutez une règle générale pour choisir le responsable de l’école.</p>';
  list.querySelectorAll('[data-edit-rule]').forEach(b=>b.onclick=()=>edit(data.rules.find(r=>r.id===b.dataset.editRule)));
  list.querySelectorAll('[data-toggle-rule]').forEach(b=>b.onclick=()=>busy(b,async()=>{const rule=data.rules.find(r=>r.id===b.dataset.toggleRule);await request('routing_toggle',{id:rule.id,expected_revision:rule.revision});await reopen();}));
  node.querySelectorAll('[data-coverage-school]').forEach(row=>{row.hidden=!!scope.value&&row.dataset.coverageSchool!==scope.value;});
 }
 scope.onchange=()=>{renderRules();edit();};fields.school_code.onchange=()=>populateSchool();
 fields.primary_user.onchange=()=>populateBackup(fields.backup_user.value);
 node.querySelector('#resetRoutingRule').onclick=()=>edit();
 form.onsubmit=event=>{event.preventDefault();return busy(event.submitter||form.querySelector('[type=submit]'),async()=>{
  form.querySelector('.form-error').hidden=true;const values=Object.fromEntries(new FormData(form));
  await request('routing_save',{...values,priority:Number(values.priority)});toast('Règle enregistrée. Les nouveaux dossiers utiliseront cette configuration.');await reopen();
 });};
 node.querySelector('#previewRouting').onclick=event=>busy(event.currentTarget,async()=>{
  const preview=await request('routing_reassign_preview',{school_code:scope.value}),ready=preview.rows.filter(r=>r.user_id);
  const review=dialog('Vérifier les affectations proposées',`<p class="small">Cette opération concerne uniquement les dossiers réels ouverts sans responsable. Les dossiers déjà attribués sont conservés. Aucun e-mail n’est envoyé.</p><p class="notice">${ready.length} proposition(s) sur ${preview.rows.length} dossier(s) examinés. ${preview.rows.length-ready.length} restent sans responsable disponible.${preview.has_more?' Le contrôle est limité à 200 dossiers ; relancez-le après ce lot.':''}</p><div class="table-wrap"><table class="data-table"><thead><tr><th>Choisir</th><th>Dossier</th><th>École / campus</th><th>Responsable proposé</th></tr></thead><tbody>${preview.rows.map((r,i)=>`<tr><td>${r.user_id?`<input type="checkbox" data-routing-index="${i}" checked aria-label="Affecter le dossier ${h(r.application_reference)}">`:''}</td><td>${h(r.application_reference)}</td><td>${h(r.school_code)}<div class="small">${h(r.campus_code)}</div></td><td>${h(r.assignee_name||'À vérifier : aucune affectation disponible')}</td></tr>`).join('')||'<tr><td colspan="4">Aucun dossier à reprendre.</td></tr>'}</tbody></table></div><p class="error" id="routingApplyError" role="alert" hidden></p><div class="dialog-actions"><button type="button" class="btn" id="applyRoutingPreview"></button></div>`,{wide:true});
  const apply=review.querySelector('#applyRoutingPreview'),checked=()=>[...review.querySelectorAll('[data-routing-index]:checked')].map(c=>preview.rows[Number(c.dataset.routingIndex)]);
  const update=()=>{const n=checked().length;apply.disabled=!n;apply.textContent='Appliquer '+n+' affectation(s)';};
  review.querySelectorAll('[data-routing-index]').forEach(c=>c.onchange=update);update();
  apply.onclick=async()=>{apply.disabled=true;const error=review.querySelector('#routingApplyError');error.hidden=true;try{
   const rows=checked().map(({id,expected_updated_at,rule_id,rule_revision,user_id})=>({id,expected_updated_at,rule_id,rule_revision,user_id}));
   const result=await request('routing_reassign_apply',{rows});review.close();toast(result.assigned+' dossier(s) affecté(s), '+result.skipped+' ignoré(s) car leur situation a changé.');
   await refreshCRM();await reopen();
  }catch(e){error.textContent=e.message;error.hidden=false;update();}};
 });
 renderRules();edit();return node;
}
