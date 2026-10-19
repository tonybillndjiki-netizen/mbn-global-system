(() => {
 'use strict';
 const endpoint='https://ppqeuluykiknuujfaoid.supabase.co/functions/v1/mbn-auth';
 const key='sb_publishable_NGnS0aBO4WUBbL6EbgMr0A_ad6EfOzS';
 const messages={invalid_credentials:'Nom d’utilisateur ou code incorrect.',six_digits_required:'Le mot de passe doit contenir exactement six chiffres.',invalid_username:'Choisissez un nom de 3 à 60 caractères : lettres, chiffres, espaces, points, tirets.',too_many_attempts:'Trop de tentatives. Patientez avant de réessayer.',authentication_required:'Connectez-vous pour configurer cet accès.',access_denied:'Ce compte ne permet pas cette opération.',session_revoked:'Votre code a été modifié. Reconnectez-vous.',reauthentication_required:'Reconnectez-vous avec votre accès existant pour configurer votre premier code.',username_taken:'Ce nom d’utilisateur est déjà utilisé.',access_changed:'L’accès a été modifié. Reconnectez-vous avant de recommencer.',service_unavailable:'Connexion temporairement indisponible. Réessayez plus tard.'};
 async function request(client,data,authenticated){
  const headers={apikey:key,'Content-Type':'application/json'};
  if(authenticated){const {data:{session}}=await client.auth.getSession();if(!session)throw Error(messages.authentication_required);headers.Authorization='Bearer '+session.access_token;}
  let response;try{response=await fetch(endpoint,{method:'POST',headers,body:JSON.stringify(data)});}catch{throw Error(messages.service_unavailable);}
  let result;try{result=await response.json();}catch{throw Error(messages.service_unavailable);}
  if(!result||typeof result!=='object')throw Error(messages.service_unavailable);
  if(!response.ok)throw Error(messages[result.error]||'Vérifiez les informations saisies.');return result;
 }
 async function login(client,username,pin){
  const result=await request(client,{action:'login',username,pin},false);
  if(!result.session?.access_token||!result.session?.refresh_token)throw Error(messages.service_unavailable);
  const {error}=await client.auth.setSession({access_token:result.session.access_token,refresh_token:result.session.refresh_token});
  if(error)throw Error(messages.service_unavailable);
 }
 async function configure(client,{targetId,name=''}={}){
  const dialog=document.createElement('dialog');dialog.style.cssText='width:min(480px,94vw);padding:28px;border:1px solid #d5deeb;border-radius:18px;color:#17243e;font:14px/1.5 Arial,sans-serif';
  dialog.innerHTML='<h2 style="font-size:22px;margin:0 0 12px">Configurer l’accès</h2><p data-note></p><div data-content></div><p data-error role="alert" style="color:#a32438;margin-top:14px"></p><button type="button" data-close style="margin-top:16px">Fermer</button>';
  document.body.append(dialog);dialog.showModal();
  const area=dialog.querySelector('[data-content]'),note=dialog.querySelector('[data-note]'),error=dialog.querySelector('[data-error]');
  const finish=new Promise(resolve=>{dialog.querySelector('[data-close]').onclick=()=>{dialog.close();dialog.remove();resolve();};dialog.addEventListener('cancel',()=>{dialog.remove();resolve();});});
  async function legacy(){
   note.textContent='Première configuration : confirmez votre accès existant. Ensuite, le nom d’utilisateur et le code à six chiffres suffiront.';
   area.innerHTML='<form><label>E-mail du compte existant<input name="email" type="email" autocomplete="username" required style="display:block;width:100%"></label><label>Mot de passe existant<input name="password" type="password" autocomplete="current-password" required style="display:block;width:100%"></label><button type="submit" style="margin-top:18px">Confirmer mon identité</button></form>';
   area.querySelector('form').onsubmit=async event=>{event.preventDefault();error.textContent='';const form=event.currentTarget,button=form.querySelector('button');button.disabled=true;
    try{const {error:failure}=await client.auth.signInWithPassword({email:form.elements.email.value.trim(),password:form.elements.password.value});form.elements.password.value='';if(failure)throw Error('Connexion refusée. Vérifiez votre accès existant.');await load();}catch(err){error.textContent=err.message;}finally{button.disabled=false;}};
  }
  async function load(){
   const {data:{session}}=await client.auth.getSession();if(!session)return legacy();
   const actorId=session.user.id,target=targetId||actorId;
   const status=await request(client,{action:'status',target_id:target},true);
   if(!status.actor_configured&&!status.initial_setup_allowed)return legacy();
   note.textContent=target===actorId?'Choisissez votre nom d’utilisateur et votre code personnel.':'Définissez l’accès de cette personne. Son activation reste gérée dans Collaborateurs.';
   area.innerHTML='<form><label>Nom d’utilisateur<input name="username" type="text" minlength="3" maxlength="60" autocomplete="off" required style="display:block;width:100%"></label><label>Nouveau mot de passe — six chiffres<input name="newpin" type="password" inputmode="numeric" pattern="[0-9 ]{6,8}" maxlength="8" autocomplete="new-password" required style="display:block;width:100%"></label><label>Confirmer les six chiffres<input name="confirm" type="password" inputmode="numeric" maxlength="8" autocomplete="new-password" required style="display:block;width:100%"></label><label data-current>Votre code actuel<input name="current" type="password" inputmode="numeric" maxlength="8" autocomplete="current-password" style="display:block;width:100%"></label><button type="submit" style="margin-top:18px">Enregistrer l’accès</button></form>';
   const form=area.querySelector('form');form.elements.username.value=status.username||name;
   form.querySelector('[data-current]').hidden=!status.actor_configured;form.querySelector('[data-current]').style.display=status.actor_configured?'block':'none';form.elements.current.required=status.actor_configured;
   form.onsubmit=async event=>{event.preventDefault();error.textContent='';const button=form.querySelector('button');button.disabled=true;
    try{if(form.elements.newpin.value.replace(/\s/g,'')!==form.elements.confirm.value.replace(/\s/g,''))throw Error('Les deux codes ne correspondent pas.');
     const result=await request(client,{action:'configure',target_id:target,username:form.elements.username.value,new_pin:form.elements.newpin.value,...(status.actor_configured?{current_pin:form.elements.current.value}:{})},true);
     form.elements.newpin.value='';form.elements.confirm.value='';form.elements.current.value='';if(result.success!==true)throw Error(messages.service_unavailable);
     if(target===actorId){await client.auth.signOut({scope:'local'});note.textContent='Accès enregistré pour « '+result.username+' ». Reconnectez-vous avec ce nom et vos six chiffres.';area.replaceChildren();}
     else{note.textContent='Accès enregistré. Activez le compte dans Collaborateurs lorsque vous souhaitez lui donner accès.';area.replaceChildren();}
    }catch(err){error.textContent=err.message;}finally{button.disabled=false;}
   };
  }
  load().catch(err=>{error.textContent=err.message;});return finish;
 }
 window.MBNAuth={login,configure,status:client=>request(client,{action:'status'},true)};
})();
