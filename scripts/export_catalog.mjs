import {readFileSync,writeFileSync} from 'node:fs';
import {createHash} from 'node:crypto';
import {parse} from '@babel/parser';
const root=new URL('../',import.meta.url);
const norm=value=>String(value??'').normalize('NFKC').trim().replace(/\s+/g,' ');
function literal(n){
 if(['StringLiteral','NumericLiteral','BooleanLiteral'].includes(n.type))return n.value;
 if(n.type==='NullLiteral')return null;
 if(n.type==='ArrayExpression')return n.elements.map(literal);
 if(n.type==='ObjectExpression')return Object.fromEntries(n.properties.map(p=>{if(p.type!=='ObjectProperty'||p.computed)throw Error('Non-literal catalog');return [p.key.name??p.key.value,literal(p.value)];}));
 if(n.type==='CallExpression'&&n.callee.object?.name==='Object'&&n.callee.property?.name==='freeze')return literal(n.arguments[0]);
 throw Error('Non-literal catalog expression '+n.type);
}
function walk(n,fn){if(!n||typeof n!=='object')return;if(Array.isArray(n)){n.forEach(v=>walk(v,fn));return;}fn(n);for(const [key,v]of Object.entries(n))if(!['loc','start','end','comments','tokens'].includes(key))walk(v,fn);}
export function catalogFromForms(){
 const rows=[];
 for(const school of JSON.parse(readFileSync(new URL('forms/manifest.json',root),'utf8'))){
  let catalog,levels;
  const html=readFileSync(new URL('forms/'+school.slug+'.html',root),'utf8');
  for(const match of html.matchAll(/<script\b([^>]*)>([\s\S]*?)<\/script\s*>/gi)){
   if(/\bsrc\s*=/.test(match[1]))continue;
   walk(parse(match[2],{sourceType:'unambiguous'}),node=>{if(node.type==='VariableDeclarator'&&node.id.type==='Identifier'){
    if(['cursusData','cursusCascadeData'].includes(node.id.name))catalog=literal(node.init);
    if(node.id.name==='NIVEAUX_PAR_CYCLE')levels=literal(node.init);
   }});
  }
  if(!catalog)throw Error('Missing catalog '+school.school);
  const seen=new Set();
  for(const [label,item]of Object.entries(catalog)){
   let cycle=label,academic_level=null;
   if(!item.formations&&levels)for(const [family,values]of Object.entries(levels)){const found=values.find(v=>v.value===label);if(found){cycle=family;academic_level=found.label;break;}}
   for(const [domain,names]of Object.entries(item.formations??item))for(const name of names){
    const tuple=[school.school,cycle,academic_level,domain,name].map(v=>v===null?null:norm(v)),key=JSON.stringify(tuple);if(seen.has(key))continue;seen.add(key);
    const hash=createHash('sha1').update(Buffer.from('3fcaaf5ed45e4e5da8fb942ff061009a','hex')).update(key).digest();hash[6]=(hash[6]&15)|80;hash[8]=(hash[8]&63)|128;
    const h=hash.subarray(0,16).toString('hex'),id=h.slice(0,8)+'-'+h.slice(8,12)+'-'+h.slice(12,16)+'-'+h.slice(16,20)+'-'+h.slice(20);
    rows.push({id,school_code:tuple[0],cycle:tuple[1],academic_level:tuple[2],domain:tuple[3],name:tuple[4],source_file:'forms/'+school.slug+'.html'});
   }
  }
 }
 return rows.sort((a,b)=>a.id.localeCompare(b.id));
}
export function catalogSeed(rows){
 const digest=createHash('sha256').update(JSON.stringify(rows)).digest('hex');
 return `-- Generated from the 19 committed active forms by scripts/export_catalog.mjs.\n-- Programs start inactive; existing rows and activation decisions are preserved.\nwith source as (select * from jsonb_to_recordset($mbn_catalog$${JSON.stringify(rows,null,2)}$mbn_catalog$::jsonb) as p(id uuid,school_code text,cycle text,academic_level text,domain text,name text,source_file text))\ninsert into public.school_programs(id,school_code,name,cycle,academic_level,domain,is_active,review_status,source_file,source_version)\nselect s.id,s.school_code,s.name,s.cycle,s.academic_level,s.domain,false,'PENDING',s.source_file,'${digest}' from source s\nwhere not exists(select 1 from public.school_programs p where p.school_code=s.school_code and p.name=s.name and p.cycle is not distinct from s.cycle and p.academic_level is not distinct from s.academic_level and p.domain is not distinct from s.domain)\non conflict(id) do nothing;\n`;
}
if(process.argv[1]&&new URL('file://'+process.argv[1]).href===import.meta.url){
 const rows=catalogFromForms();if(rows.length!==1275||new Set(rows.map(r=>r.school_code)).size!==19)throw Error('Unexpected catalog coverage');
 writeFileSync(new URL('supabase/seed.sql',root),catalogSeed(rows));console.log(JSON.stringify({schools:19,programs:rows.length}));
}
