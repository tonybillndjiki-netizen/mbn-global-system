import {PDFDocument,rgb,type PDFPage,type PDFFont} from 'pdf-lib';
import fontkit from '@pdf-lib/fontkit';
import {letterContent,type LetterFields} from './template.ts';
import {brandFor} from '../../../assets/branding.js';
export type PDFAssets={regular:Uint8Array;bold:Uint8Array;logo:Uint8Array;schoolLogo?:Uint8Array};
export async function makeLetterPDF(fields:LetterFields,assets:PDFAssets,createdAt:string){
 const doc=await PDFDocument.create();doc.registerFontkit(fontkit);
 doc.setCreationDate(new Date(createdAt));doc.setModificationDate(new Date(createdAt));doc.setTitle('Admission - '+fields.school_name);doc.setAuthor(fields.school_name);doc.setSubject('Dossier '+fields.reference);doc.setProducer('Service des admissions');doc.setCreator('Service des admissions');
 const regular=await doc.embedFont(assets.regular,{subset:true}),bold=await doc.embedFont(assets.bold,{subset:true});
 const logo=await doc.embedPng(assets.logo),schoolLogo=assets.schoolLogo?await doc.embedPng(assets.schoolLogo):null;
 const ink=rgb(.10,.16,.24),muted=rgb(.35,.42,.47),teal=rgb(.0,.43,.48),pale=rgb(.94,.97,.97);
 let page:PDFPage,y=0;
 const normalize=(s:string)=>String(s??'').normalize('NFC').replace(/\u202f|\u00a0/g,' ').replace(/\t/g,' ');
 function lines(text:string,font:PDFFont,size:number,width:number){
  const out:string[]=[];for(const paragraph of normalize(text).split('\n')){let line='';for(const word of paragraph.split(/\s+/)){if(!word)continue;if(font.widthOfTextAtSize(word,size)>width){if(line){out.push(line);line='';}let part='';for(const char of word){if(font.widthOfTextAtSize(part+char,size)>width){out.push(part);part='';}part+=char;}line=part;continue;}if(line&&font.widthOfTextAtSize(line+' '+word,size)>width){out.push(line);line=word;}else line+=(line?' ':'')+word;}if(line)out.push(line);if(!paragraph)out.push('');}return out;
 }
 function write(text:string,{size=10.5,font=regular,color=ink,gap=10}={}){for(const line of lines(text,font,size,499)){if(y<64)newPage(true);page.drawText(line,{x:48,y,size,font,color});y-=size*1.48;}y-=gap;}
 function newPage(compact=false){
  page=doc.addPage([595.28,841.89]);
  page.drawRectangle({x:40,y:compact?756:698,width:515,height:compact?44:106,color:pale});
  if(compact){page.drawText(fields.school_name,{x:52,y:774,font:bold,size:10,color:teal});y=728;}
  else{
   const brand=brandFor(fields.school_code);
   if(brand.campus){page.drawImage(logo,{x:40,y:644,width:230,height:230});let ty=785;for(const line of lines(brand.name,bold,11,235)){page.drawText(line,{x:290,y:ty,font:bold,size:11,color:teal});ty-=16;}if(schoolLogo){const s=schoolLogo.scaleToFit(155,42);page.drawImage(schoolLogo,{x:290,y:718,width:s.width,height:s.height});}else{page.drawText(fields.school_name,{x:290,y:721,font:regular,size:10,color:ink});}}
   else{const s=logo.scaleToFit(180,65);page.drawImage(logo,{x:54,y:716,width:s.width,height:s.height});let ty=775;for(const line of lines(fields.school_name,bold,12,230)){page.drawText(line,{x:290,y:ty,font:bold,size:12,color:teal});ty-=17;}}
   y=670;
  }
 }
 const content=letterContent(fields);newPage();
 write(content.title,{size:19,font:bold,color:teal,gap:8});
 write('Année académique '+fields.academic_year,{size:11,color:muted,gap:16});
 const birth=new Date(fields.date_of_birth+'T12:00:00Z').toLocaleDateString('fr-FR',{timeZone:'UTC'});
 write(`Noms : ${fields.full_name}\nDate de naissance : ${birth}\nLieu / ville de naissance : ${fields.place_of_birth}\nCampus : ${fields.campus_name}\nN° de dossier : ${fields.reference}`,{size:9.5,gap:16});
 for(const text of content.paragraphs)write(text);
 write('Le service des admissions\n'+fields.signatory,{font:bold,gap:0});
 newPage(true);write('NOTICE D’INFORMATIONS',{size:16,font:bold,color:teal,gap:16});
 for(const [heading,text] of content.notice){if(y<112)newPage(true);if(heading)write(heading,{size:11,font:bold,color:teal,gap:3});write(text,{size:10,gap:10});}
 const count=doc.getPageCount();for(const [i,p]of doc.getPages().entries()){p.drawLine({start:{x:48,y:45},end:{x:547,y:45},color:rgb(.82,.86,.87),thickness:.5});p.drawText(fields.reference+'  |  '+(i+1)+' / '+count,{x:48,y:29,font:regular,size:7.5,color:muted});}
 return doc.save({useObjectStreams:true});
}
