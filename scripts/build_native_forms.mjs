import {readFileSync,writeFileSync,mkdirSync,readdirSync,copyFileSync} from 'node:fs';
import {fileURLToPath} from 'node:url';
import path from 'node:path';
import vm from 'node:vm';
import {brandFor,CAMPUS_INNOVATION} from '../assets/branding.js';
const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
const source=path.join(root,'source/forms'),out=path.join(root,'forms');
mkdirSync(out,{recursive:true});mkdirSync(path.join(root,'assets/brands'),{recursive:true});
const endpoint='https://ppqeuluykiknuujfaoid.supabase.co/functions/v1/mbn-form-ingest';
const schools=['LSB','ESUV','ESEA','MLV BS','MLV BTS','ESMOSS','ESMAS','ESART','CESCOM','ESJM','EVRY BS','EVRY BTS','ESETH','ISMOD','ILMIS','DCG FORMATIONS','ESIIA','ESMEP','EMSP'];
function functionRange(script,name){
  const match=new RegExp('(?:async\\s+)?function\\s+'+name+'\\s*\\([^)]*\\)\\s*\\{').exec(script);
  if(!match)return null;
  const opening=match.index+match[0].length-1;let depth=0,quote='',comment='';
  for(let i=opening;i<script.length;i++){
    const char=script[i],next=script[i+1];
    if(comment==='line'){if(char==='\n')comment='';continue;}
    if(comment==='block'){if(char==='*'&&next==='/'){comment='';i++;}continue;}
    if(quote){if(char==='\\'){i++;continue;}if(char===quote)quote='';continue;}
    if(char==='/'&&next==='/'){comment='line';i++;continue;}
    if(char==='/'&&next==='*'){comment='block';i++;continue;}
    if(['"',"'",'`'].includes(char)){quote=char;continue;}
    if(char==='{')depth++;if(char==='}'&&--depth===0)return [match.index,i+1];
  }
  throw Error('Unclosed source function: '+name);
}
const nativeHeader=`<style>
#mbn-native-test{font:14px/1.5 Arial,sans-serif;background:#112747;color:#fff;padding:18px 24px;position:relative;z-index:100}
#mbn-native-test p{margin:5px 0}#mbn-native-test a{color:#a6e4dd;text-decoration:underline}
#mbn-native-test form{display:flex;gap:10px;align-items:end;flex-wrap:wrap;margin-top:12px}
#mbn-native-test label{display:grid;gap:4px}#mbn-native-test input{padding:8px 10px;border-radius:5px;color:#152742;background:#fff;border:1px solid #bdd0e6}
#mbn-native-test button{background:#fff;color:#112747;padding:8px 12px;border:1px solid #bdd0e6;border-radius:5px;font-weight:700;cursor:pointer}
#mbn-native-test button:disabled{opacity:.5}#mbn-native-test [hidden]{display:none!important}
#mbn-native-status{min-height:22px}#mbn-native-test .mbn-ref{font-size:11px;overflow-wrap:anywhere;color:#c8d5e8}
</style><section id="mbn-native-test" aria-label="Validation administrateur">
<p><strong>MBN GLOBAL · Validation des formulaires</strong> — <a href="../MBN_GLOBAL_Admin_Supabase.html">Console administrateur</a></p>
<p>Mode test : utilisez des données et des documents fictifs. Aucun e-mail n’est envoyé.</p>
<p id="mbn-native-status" role="status">Chargement du catalogue…</p><p class="mbn-ref" id="mbn-native-reference"></p>
<form id="mbn-native-login"><label>Nom d’utilisateur<input id="mbn-native-username" type="text" autocomplete="username" value="Tony Bill" required></label>
<label>Mot de passe — six chiffres<input id="mbn-native-password" type="password" inputmode="numeric" maxlength="8" pattern="[0-9 ]{6,8}" autocomplete="current-password" required></label>
<button type="submit">Se connecter</button></form>
<div style="margin-top:10px"><button type="button" id="mbn-native-logout" hidden>Déconnexion</button> <button type="button" id="mbn-native-access">Mon accès</button> <button type="button" id="mbn-native-new">Nouvel essai</button></div></section>`;
const result=[];
for(const school of schools){
  const slug=school.toLowerCase().replaceAll(' ','-'),brand=brandFor(school);
  const sourceSchool=school==='EVRY BTS'?'MLV BTS':school;
  const prefix=sourceSchool.replaceAll(' ','_')+'_';
  const filename=readdirSync(source).filter(n=>n.startsWith(prefix)&&n.endsWith('.html')).sort((a,b)=>a.length-b.length)[0];
  if(!filename)throw Error(`Missing source form: ${school}`);
  let html=readFileSync(path.join(source,filename),'utf8');
  if(school==='EVRY BTS'){
    html=html.replaceAll('MLV BTS','EVRY BTS').replaceAll('Marne La Vallée BTS','Évry BTS').replaceAll('Marne-la-Vallée BTS','Évry BTS')
      .replaceAll('Marne La Vallée','Évry').replaceAll('Marne-la-Vallée','Évry')
      .replaceAll('NOISIEL','EVRY').replaceAll('Noisiel','Évry').replaceAll('#469d9e','#c23c55').replaceAll('#3b8687','#a12f46').replaceAll('#265758','#751e30')
      .replaceAll('rgba(70, 157, 158,','rgba(194, 60, 85,');
    html=html.replace(/contact@marnelavallee-bts\.fr\s*\/\s*admission@marnelavallee-bts\.fr/g,'Admissions Évry BTS');
  }
  let replacements=0;
  html=html.replace(/<script([^>]*)>([\s\S]*?)<\/script>/gi,(whole,attributes,script)=>{
    if(/\bsrc\s*=/.test(attributes))return whole;
    const edits=[];
    for(const name of ['submitForm','soumettreMonoCampus']){
      const submit=functionRange(script,name);
      if(submit){edits.push([...submit,`async function ${name}() { return window.mbnSubmitNative(); }`]);replacements++;}
    }
    const convert=functionRange(script,'convertirFichierEnBase64');
    if(convert)edits.push([...convert,'']);
    for(const [start,end,replacement] of edits.sort((a,b)=>b[0]-a[0]))script=script.slice(0,start)+replacement+script.slice(end);
    return `<script${attributes}>${script}</script>`;
  });
  if(replacements!==1)throw Error(`Expected one submission handler: ${school}`);
  html=html.replace(/<input\b[^>]*id="campus_mono_fixe"[^>]*>/i,'<select id="campus" name="campus" required hidden aria-label="Campus"></select>');
  if(!/id=["']campus["']/.test(html))html=html.replace(/(<form\b[^>]*id="admission-form"[^>]*>)/i,'$1<select id="campus" name="campus" required hidden aria-label="Campus"></select>');
  html=html.replace(/https:\/\/script\.google\.com\/[^"'\s<>]+/g,endpoint)
    .replace(/8 \* 1024 \* 1024/g,'5 * 1024 * 1024').replace(/25 \* 1024 \* 1024/g,'20 * 1024 * 1024')
    .replaceAll('8 Mo','5 Mo').replaceAll('25 Mo','20 Mo')
    .replace(/[^\n]*COLlez VOTRE LIEN APPSCRIPT ICI[^\n]*/g,`            apiUrl: "${endpoint}",`)
    .replace('</head>',`<meta name="mbn-school" content="${school}"><meta name="referrer" content="no-referrer"></head>`)
    .replace(/<body([^>]*)>/i,`<body$1>${nativeHeader.replace('<p><strong>',`<p><img src="../assets/brands/${slug}.png" alt="${school}" style="display:inline-block;height:30px;max-width:130px;object-fit:contain;background:#fff;padding:3px;margin-right:10px"> <strong>`)}`)
    .replace('</body>','<script src="../assets/auth-client.js" defer></script><script src="../assets/native-client.js" defer></script></body>');
  if(brand.campus){
    html=html.replaceAll('assets/brands/'+slug+'.png','assets/brands/'+brand.logo+'.png');
    html=html.replace(/Campus\s+(?:de\s+)?Noisi(?:el|y)/gi,CAMPUS_INNOVATION).replace(/NOISIEL/g,'NOISIEL');
    html=html.replace(/>Noisiel</g,'>'+CAMPUS_INNOVATION+'<');
  }
  // The supplied school logo is retained locally, including the separate Evry identity.
  const brandFile=path.join(root,'source/brands',slug+'.png');
  copyFileSync(brandFile,path.join(root,'assets/brands',slug+'.png'));
  // First logo image, as identified by the source form's Google Drive logo URL.
  html=html.replace(/(src=")[^"]*(?:drive\.google\.com\/thumbnail|lh3\.googleusercontent\.com\/d\/)[^"]*(")/i,`$1../assets/brands/${brand.logo}.png$2`);
  for(const match of html.matchAll(/<script([^>]*)>([\s\S]*?)<\/script>/gi)){
    if(!/\bsrc\s*=/.test(match[1]))new vm.Script(match[2],{filename:slug+'.inline.js'});
  }
  writeFileSync(path.join(out,slug+'.html'),html);
  result.push({school,slug,source:filename,campus_brand:brand.campus?CAMPUS_INNOVATION:null});
}
writeFileSync(path.join(out,'manifest.json'),JSON.stringify(result,null,2)+'\n');
console.log(JSON.stringify({forms:result.length,output:out}));
