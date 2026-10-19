import {readFileSync,readdirSync,writeFileSync} from 'node:fs';
import {createHash} from 'node:crypto';
import {parse} from '@babel/parser';
const root=new URL('../',import.meta.url),source=new URL('source/forms/',root);
const live=JSON.parse(readFileSync(process.argv[2],'utf8'));
const norm=v=>String(v??'').normalize('NFKC').trim().replace(/\s+/g,' ');
const tuple=p=>[p.cycle,p.academic_level??p.study_level,p.domain,p.name].map(norm).join('|');
const unique=rows=>new Set(rows.map(tuple));
function literal(n){
 if(['StringLiteral','NumericLiteral','BooleanLiteral'].includes(n.type))return n.value;
 if(n.type==='NullLiteral')return null;
 if(n.type==='ArrayExpression')return n.elements.map(literal);
 if(n.type==='ObjectExpression')return Object.fromEntries(n.properties.map(p=>{if(p.type!=='ObjectProperty'||p.computed)throw Error('non-literal');return [p.key.name??p.key.value,literal(p.value)];}));
 if(n.type==='CallExpression'&&n.callee.object?.name==='Object'&&n.callee.property?.name==='freeze')return literal(n.arguments[0]);
 throw Error('Non-literal catalog expression '+n.type);
}
function walk(n,fn){if(!n||typeof n!=='object')return;if(Array.isArray(n)){n.forEach(v=>walk(v,fn));return;}fn(n);for(const [k,v]of Object.entries(n))if(!['loc','start','end','comments','tokens'].includes(k))walk(v,fn);}
const checks=[],fields=['nom','prenom','ddn','ldn','pays_residence','email','telephone','file_cv','file_diplome','file_identite'];
const schools=JSON.parse(readFileSync(new URL('forms/manifest.json',root),'utf8'));
for(const school of schools){
 const origin=school.school==='EVRY BTS'?'MLV BTS':school.school;
 const files=readdirSync(source).filter(f=>f.startsWith(origin.replaceAll(' ','_')+'_')&&f.endsWith('.html'));
 for(const file of files){
  const html=readFileSync(new URL(file,source),'utf8');let catalog,levels;
  for(const m of html.matchAll(/<script\b([^>]*)>([\s\S]*?)<\/script\s*>/gi)){if(/\bsrc\s*=/.test(m[1]))continue;walk(parse(m[2],{sourceType:'unambiguous'}),n=>{if(n.type==='VariableDeclarator'&&n.id.type==='Identifier'){if(['cursusData','cursusCascadeData'].includes(n.id.name))catalog=literal(n.init);if(n.id.name==='NIVEAUX_PAR_CYCLE')levels=literal(n.init);}});}
  if(!catalog)throw Error('No source catalog '+file);
  const rows=[];
  for(const [label,item]of Object.entries(catalog)){
   let cycle=label,academic_level=null;
   if(!item.formations&&levels)for(const [family,ls]of Object.entries(levels)){const found=ls.find(v=>v.value===label);if(found){cycle=family;academic_level=found.label;break;}}
   for(const [domain,names]of Object.entries(item.formations??item))for(const name of names)rows.push({cycle,academic_level,domain,name});
  }
  const expected=unique(rows),actual=unique(live.filter(p=>p.school_code===school.school));
  const absent=[...expected].filter(k=>!actual.has(k)),extra=[...actual].filter(k=>!expected.has(k));
  const built=readFileSync(new URL('forms/'+school.slug+'.html',root),'utf8');
  const missingFields=fields.filter(id=>html.includes('id="'+id+'"')&&!built.includes('id="'+id+'"'));
  const requiredMissing=[...html.matchAll(/<(?:input|select|textarea)\b[^>]*>/gi)].filter(m=>/\brequired\b/.test(m[0])).map(m=>/\bid="([^"]+)"/.exec(m[0])?.[1]).filter(id=>id&&!new RegExp('id="'+id+'"[^>]*required|\\brequired\\b[^>]*id="'+id+'"').test(built));
  checks.push({school:school.school,source:file,source_sha256:createHash('sha256').update(html).digest('hex'),source_combinations:expected.size,active_combinations:actual.size,absent,extra,missing_fields:missingFields,required_fields_lost:requiredMissing,inherited:school.school==='EVRY BTS'});
 }
}
const report={checked_at:new Date().toISOString(),school_count:schools.length,source_versions:checks.length,active_combinations:live.length,checks,ok:checks.every(c=>!c.absent.length&&!c.extra.length&&!c.missing_fields.length&&!c.required_fields_lost.length),notes:['Évry BTS reprend exactement le catalogue MLV BTS sur instruction explicite.','Les deux versions ESMAS sont comparées séparément.','Les limites des documents sont de 5 Mo par fichier, 20 Mo au total.','Les codes RNCP et rythmes absents des sources ne sont pas inventés.','Le campus NOISIEL est présenté comme Campus Innovation Marne-la-Vallée ; adresse postale conservée.']};
writeFileSync(new URL('FORMULAIRES_VERIFICATION.json',root),JSON.stringify(report,null,2)+'\n');
console.log(JSON.stringify({ok:report.ok,schools:report.school_count,versions:report.source_versions,combinations:live.length,issues:checks.filter(c=>c.absent.length||c.extra.length||c.missing_fields.length||c.required_fields_lost.length)}));
if(!report.ok)process.exitCode=1;
