import {brandFor,logoURL} from './branding.js';
import {documentLabels} from './document-requests-ui.js';
export async function startCorrectionPage({document,location,history,fetch,FormData,now=()=>Date.now()}){
 const endpoint='https://ppqeuluykiknuujfaoid.supabase.co/functions/v1/mbn-admissions';
 const status=document.getElementById('correctionStatus'),content=document.getElementById('correctionContent');
 const token=location.hash.slice(1)||history.state?.correctionToken||'';history.replaceState({correctionToken:token},'',location.pathname);
 const errors={file_too_large:'Chaque document doit peser au maximum 5 Mo.',files_too_large:'Les documents doivent peser au maximum 20 Mo au total.',invalid_document:'Ce fichier ne correspond pas à une pièce attendue.',link_unavailable:'Ce lien a expiré ou a été annulé. Contactez votre service admissions.',requested_documents_only:'Joignez uniquement toutes les pièces demandées.',reference_conflict:'Une reprise est en cours. Réessayez avec les mêmes fichiers.',documents_pending:'Le transfert doit être repris avec les mêmes fichiers.',document_request_changed:'La demande a changé. Contactez votre service admissions.',document_type_mismatch:'Utilisez des fichiers PDF, JPEG ou PNG correspondant à leur extension.'};
 const fail=e=>{status.textContent=errors[e.message]||e.message||'Le service est momentanément indisponible. Réessayez.';};
 if(!/^[a-f0-9-]{36}\.[a-f0-9]{64}$/.test(token)){status.textContent='Ouvrez le lien personnel contenu dans le message de votre école.';return;}
 try{
  const response=await fetch(endpoint,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({action:'correction_info',token})});
  const info=await response.json();if(!response.ok)throw Error(info.error);
  const brand=brandFor(info.school_code),logo=document.getElementById('correctionLogo');logo.src=logoURL(brand);logo.alt=brand.name;logo.hidden=false;
  document.getElementById('correctionSchool').textContent=info.school_name;
  if(info.completed){status.textContent='Vos documents ont été reçus. Ils seront vérifiés par les admissions.';return;}
  if(Date.parse(info.expires_at)<=now())throw Error('link_unavailable');
  status.textContent='Dossier '+info.reference+'. Déposez les pièces ci-dessous avant le '+new Date(info.expires_at).toLocaleDateString('fr-FR')+'.';
  const form=document.createElement('form'),inputs=[];
  for(const item of info.items){
   const block=document.createElement('div');block.className='document-request-item';
   const label=document.createElement('label');label.textContent=documentLabels[item.kind]||item.kind;
   const reason=document.createElement('p');reason.className='small preserve';reason.textContent=item.reason;
   const input=document.createElement('input');input.type='file';input.required=true;input.accept='.pdf,.png,.jpg,.jpeg';label.append(input);block.append(reason,label);form.append(block);inputs.push({kind:item.kind,input});
  }
  const button=document.createElement('button');button.type='submit';button.className='btn full';button.textContent='Transmettre mes documents';form.append(button);content.append(form);
  form.onsubmit=async event=>{event.preventDefault();if(!form.reportValidity())return;button.disabled=true;try{
   const body=new FormData();body.append('payload','{}');let total=0;
   for(const {kind,input} of inputs){const file=input.files[0];if(!file||file.size>5242880)throw Error('Chaque pièce doit peser au maximum 5 Mo.');total+=file.size;body.append(kind,file,file.name);}
   if(total>20971520)throw Error('Les documents doivent peser au maximum 20 Mo au total.');
   const sent=await fetch(endpoint,{method:'POST',headers:{'x-mbn-correction':token},body}),receipt=await sent.json();
   if(!sent.ok||receipt.success!==true)throw Error(receipt.error||'Le transfert a échoué. Réessayez avec les mêmes fichiers.');
   content.replaceChildren();status.textContent='Vos '+receipt.document_count+' document(s) ont été reçus. Les admissions vont les vérifier.';
  }catch(e){fail(e);button.disabled=false;}};
 }catch(e){fail(e);}
}
if(typeof document!=='undefined'&&document.getElementById('correctionStatus'))startCorrectionPage({document,location,history,fetch,FormData});
