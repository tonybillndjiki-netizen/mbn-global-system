import {test} from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {PDFDocument} from 'pdf-lib';
import {letterContent,admissionMail} from '../supabase/functions/mbn-letters/template.ts';
import {makeLetterPDF} from '../supabase/functions/mbn-letters/pdf.ts';

const fields={admission_type:'NATIONAL',school_code:'MLV BTS',school_name:'Marne-la-Vallée BTS',full_name:'Candidat synthétique',reference:'TEST-NATIONAL',email:'synthetic@example.invalid',
 program_name:'Management commercial opérationnel',academic_level:'BTS 1',campus_name:'Campus Innovation Marne-la-Vallée',academic_year:'2026/2027',intake:'janvier 2027',
 deferred_intake:'',registration_fee:'0',tuition_deposit:'0',confirmation_days:'15',date_of_birth:'2000-01-02',place_of_birth:'Lieu synthétique',signatory:'Signataire synthétique',avi_mode:'NONE',logo_variant:'CAMPUS'};
test('national PDF and mail content exclude every international condition and use the configured intake',()=>{
 const content=letterContent(fields),text=JSON.stringify(content)+'\n'+admissionMail(fields);
 assert.doesNotMatch(text,/\bvisa\b|\bA\.?V\.?I\.?\b|Campus France|arriv[ée].*France|premier refus|ambassade/i);
 assert.match(text,/janvier 2027/);assert.match(text,/15 jours/);assert.match(text,/Aucun frais d’inscription ni acompte/);
 assert.doesNotMatch(text,/preuve de paiement|remboursable|fortement recommandée/);
});
test('national fees include exactly the nonzero configured amounts without claiming free tuition',()=>{
 const fee=admissionMail({...fields,registration_fee:'250.50',tuition_deposit:'0'});
 assert.match(fee,/250,5 euros de frais d’inscription/);assert.doesNotMatch(fee,/0 euros|minimum|remboursable/);
 const deposit=admissionMail({...fields,registration_fee:'0',tuition_deposit:'1500'});
 assert.match(deposit,/1 500 euros d’acompte/);assert.doesNotMatch(deposit,/\b0 euros|Aucun frais/);
});
test('international previews keep their original flow, including historical snapshots without an explicit type',()=>{
 const historical={...fields,deferred_intake:'septembre 2027',registration_fee:'800',tuition_deposit:'1000',avi_mode:'OPTIONAL'};
 delete (historical as Partial<typeof fields>).admission_type;
 const text=JSON.stringify(letterContent(historical))+'\n'+admissionMail(historical);
 assert.match(text,/visa/);assert.match(text,/A\.V\.I\./);assert.match(text,/800 euros/);assert.match(text,/septembre 2027/);
});
test('national PDF generation embeds the supplied campus assets and remains a bounded readable document',async()=>{
 const root=new URL('../',import.meta.url);
 const bytes=await makeLetterPDF(fields,{regular:readFileSync(new URL('source/fonts/regular.ttf',root)),bold:readFileSync(new URL('source/fonts/bold.ttf',root)),logo:readFileSync(new URL('assets/brands/campus-innovation-mlv.png',root))},'2026-10-19T12:00:00Z');
 const pdf=await PDFDocument.load(bytes);assert.equal(pdf.getPageCount(),2);assert.equal(pdf.getTitle(),'Admission - Marne-la-Vallée BTS');assert.ok(bytes.length>10000);assert.ok(bytes.length<5242880);
});
