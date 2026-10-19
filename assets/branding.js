export const CAMPUS_INNOVATION = 'Campus Innovation Marne-la-Vallée';
export const CAMPUS_SCHOOLS = Object.freeze(['CESCOM','ESART','ESEA','ESJM','ESMAS','ESMOSS','MLV BTS','MLV BS']);
const names = {'MLV BTS':'Marne-la-Vallée BTS','MLV BS':'Marne-la-Vallée Business School','EVRY BTS':'Évry BTS','EVRY BS':'Évry Business School'};
/** @param {string} school */
export function brandFor(school) {
  const slug=school.toLowerCase().replaceAll(' ','-');
  const campus=CAMPUS_SCHOOLS.includes(school);
  const schoolName=names[school]||school;
  return {schoolName,slug,campus,name:campus?CAMPUS_INNOVATION:schoolName,
    logo:campus?'campus-innovation-mlv':slug,schoolLogo:slug};
}

/** @param {string} school */
export function admissionsSenderName(school){return 'Service admissions — '+brandFor(school).schoolName;}
/** @param {string} code */
export function campusName(code) {
  return code==='NOISIEL'?CAMPUS_INNOVATION:({'EVRY':'Évry','LYON':'Lyon','TORCY':'Torcy'}[code]||code);
}
/** @param {string} slug */
export function hostedFormURL(slug) {
  if(!/^[a-z0-9-]{2,50}$/.test(slug))throw Error('École indisponible');
  return 'https://ppqeuluykiknuujfaoid.supabase.co/functions/v1/mbn-admissions?ecole='+encodeURIComponent(slug);
}

/** @param {{logo:string}} brand */
export function logoURL(brand){return brand.logo==='campus-innovation-mlv'?'https://ppqeuluykiknuujfaoid.supabase.co/storage/v1/object/public/mbn-school-branding/campus-innovation-mlv.png':'https://mbn-global.netlify.app/assets/brands/'+brand.logo+'.png';}
