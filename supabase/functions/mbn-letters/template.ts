export type LetterFields=Record<string,string>;
export const money=(s:string)=>Number(s).toLocaleString('fr-FR',{minimumFractionDigits:0,maximumFractionDigits:2}).replace(/\u202f/g,' ');
export function letterContent(f:LetterFields){
 if(f.admission_type==='NATIONAL')return nationalLetterContent(f);
 const fee=money(f.registration_fee),deposit=money(f.tuition_deposit);
 return {
  title:'ACCORD D’ADMISSION',
  paragraphs:[
   `Madame, Monsieur,`,
   `J’ai le plaisir de vous informer que le jury des admissions de ${f.school_name}, après étude de votre dossier, a décidé de donner un avis favorable à votre candidature pour la formation ${f.program_name} - ${f.academic_level}, pour la rentrée de ${f.intake}.`,
   `Vous disposez d’un délai de ${f.confirmation_days} jours à compter de la réception de cette lettre d’admission pour confirmer votre inscription, par le paiement des frais d’inscription qui s’élèvent à ${fee} euros et d’un acompte de vos frais de scolarité de minimum ${deposit} euros. Les coordonnées et modalités de paiement applicables sont indiquées dans les pièces jointes sélectionnées par le service admissions.`,
   `Une fois votre inscription réalisée, vous recevrez une attestation d’inscription. Votre certificat de scolarité et votre carte d’étudiant vous seront délivrés après paiement (en partie ou totale) de vos frais de scolarité dès votre arrivée en France. Nous sommes ravis de vous compter parmi nos futurs étudiants. Nous restons à votre disposition au 06 95 85 70 85 ou au 07 66 74 93 35 pour tout renseignement complémentaire.`,
   `Dans cette attente, nous vous prions de bien vouloir agréer l’expression de nos salutations distinguées.`,
  ],
  notice:[
   ['Votre rentrée',`Vous venez d’être accepté au sein de ${f.school_name} pour la rentrée ${f.academic_year}. Cette notice vous donne quelques informations supplémentaires dans le cadre de votre procédure de demande de visa.`],
   ['Frais d’inscription',`Suite à votre lettre d’admission, vous disposez d’un délai de ${f.confirmation_days} jours pour confirmer votre inscription en payant vos frais d’inscription de ${fee} euros. Les frais d’inscription ne sont pas à confondre avec les frais de scolarité. Ils vous permettent de bénéficier d’une attestation d’inscription et d’un accompagnement pour la demande de visa auprès de Campus France et de l’ambassade de France de votre pays. Ces frais ne sont pas remboursables. Toutefois, ils vous donnent automatiquement droit à deux inscriptions : la rentrée de ${f.intake} et la rentrée décalée de ${f.deferred_intake}.`],
   ['Frais de scolarité',`Vous devez faire un paiement minimum de ${deposit} euros au moment de votre inscription, remboursable à 100 % en cas de refus de visa. Le reste est payable une fois arrivé sur le territoire français, selon l’échéancier applicable. Notre école vous accompagne dans vos procédures en répondant à Campus France et aux ambassades, notamment par l’envoi de votre attestation d’inscription, des dérogations d’arrivée tardive et le report de votre rentrée à ${f.deferred_intake} si nécessaire.`],
   ['Caution bancaire et A.V.I.',`Grâce à notre partenaire MBN Global Finance, nous vous accompagnons dans vos démarches, notamment pour les questions d’A.V.I. (Attestation de Virement Irrévocable), de caution bancaire et de visa. ${f.avi_mode==='OPTIONAL'?'L’A.V.I. de notre partenaire MBN Global Finance n’est pas obligatoire, mais fortement recommandée.':'L’engagement de souscription à l’offre d’A.V.I. figure dans les pièces jointes retenues pour votre inscription.'}`],
   ['Venir étudier en France',`La France offre une opportunité d’accueil et d’accompagnement des étudiants internationaux. Grâce au dispositif de la formation en alternance, un étudiant étranger aura la possibilité, dès sa deuxième année, de bénéficier des financements publics et de voir ses études financées par les dispositifs de l’alternance. Les étudiants étrangers ne pouvant bénéficier de l’alternance la première année, vous pouvez néanmoins financer vos études par le biais d’un job étudiant. Notre école organise votre emploi du temps afin de vous permettre de trouver un job étudiant et financer vos études dès la première année, avant de passer l’année suivante au parcours alternance.`],
   ['',`Nous serons ravis de vous accueillir dès la rentrée prochaine. Le service des admissions - ${f.school_name}.`],
  ]
 };
}
export function admissionMail(f:LetterFields){
 if(f.admission_type==='NATIONAL')return nationalAdmissionMail(f);
 const fee=money(f.registration_fee),deposit=money(f.tuition_deposit);
 return `Bonjour ${f.full_name},\n\nSuite à votre candidature, nous avons le plaisir de vous annoncer votre admission au sein de ${f.school_name} ! Vous trouverez en pièce jointe votre lettre d’admission.\n\nRécapitulatif de votre cursus\nFormation : ${f.program_name}\nNiveau : ${f.academic_level}\nDomaine : ${f.domain||'—'}${f.pace?'\nRythme : '+f.pace:''}\nCampus d’affectation : ${f.campus_name}\nRentrée : ${f.intake} (${f.academic_year})${f.rncp_code?'\nCode RNCP : '+f.rncp_code:''}\n\nPour finaliser votre inscription et recevoir votre attestation, les montants prévus par cette lettre sont de ${fee} euros de frais d’inscription et un acompte minimum de ${deposit} euros sur les frais de scolarité. Les modalités de paiement et les documents applicables sont joints à ce message.\n\nDocuments à retourner : preuve de paiement des frais d’inscription et de l’acompte, lettre d’admission, conditions générales de vente signées avec la mention « Lu et approuvé »${f.avi_mode==='REQUIRED'?', ainsi que l’attestation d’engagement AVI signée.':'.'}\n\nL’acompte des frais de scolarité est remboursable à 100 % en cas de refus de visa. Les frais d’inscription ne sont pas remboursables. Après un premier refus, l’inscription reste valable pour une deuxième demande ; après un deuxième refus, de nouveaux frais d’inscription seront nécessaires pour obtenir une nouvelle attestation.\n\n${f.avi_mode==='OPTIONAL'?'L’AVI proposée avec MBN Global Finance n’est pas obligatoire, mais fortement recommandée.':'L’attestation d’engagement AVI sélectionnée pour votre inscription est jointe.'}\n\nUne fois arrivé(e) en France, vous devez suivre au moins une année de formation. Tout désistement en cours d’année entraîne le paiement de la totalité des frais de scolarité, selon les conditions applicables jointes.\n\nWhatsApp : +33 (0)7 66 74 93 35 / +33 (0)6 95 85 70 85\n\nCordialement,\nL’équipe des admissions\n${f.school_name}`;
}

function nationalPayments(f:LetterFields){
 const amounts:string[]=[];
 if(Number(f.registration_fee)>0)amounts.push(`${money(f.registration_fee)} euros de frais d’inscription`);
 if(Number(f.tuition_deposit)>0)amounts.push(`${money(f.tuition_deposit)} euros d’acompte sur les frais de scolarité`);
 return amounts.length?`Les montants à prévoir pour la confirmation sont de ${amounts.join(' et ')}. Les modalités de règlement et les conditions applicables figurent dans les documents joints sélectionnés par le service admissions.`
  :'Aucun frais d’inscription ni acompte sur les frais de scolarité n’est demandé à cette étape. Les éventuels frais de formation et leurs modalités de prise en charge restent ceux des documents applicables à votre inscription.';
}
function nationalLetterContent(f:LetterFields){
 return {title:'ACCORD D’ADMISSION',paragraphs:[
  'Madame, Monsieur,',
  `Après étude de votre dossier, le jury des admissions de ${f.school_name} a donné un avis favorable à votre candidature pour la formation ${f.program_name} - ${f.academic_level}, sur le campus ${f.campus_name}, pour la rentrée de ${f.intake}.`,
  `Nous vous invitons à confirmer votre inscription auprès du service admissions dans un délai de ${f.confirmation_days} jours à compter de la réception de cette lettre. ${nationalPayments(f)}`,
  'Cette admission constitue une étape de votre inscription. Le service admissions vous indiquera les documents à retourner et les démarches nécessaires pour finaliser votre dossier, selon le parcours et le rythme de formation retenus.',
  'Nous serons heureux de vous accueillir au sein de notre établissement. Pour toute question sur votre inscription, veuillez contacter le service admissions aux coordonnées indiquées dans le message accompagnant cette lettre.',
  'Nous vous prions d’agréer, Madame, Monsieur, l’expression de nos salutations distinguées.',
 ],notice:[
  ['Votre formation',`${f.program_name} - ${f.academic_level}${f.pace?'\nRythme : '+f.pace:''}\nCampus : ${f.campus_name}\nRentrée : ${f.intake}\nAnnée académique : ${f.academic_year}`],
  ['Confirmer votre inscription',`Contactez le service admissions dans les ${f.confirmation_days} jours suivant la réception de votre lettre. Transmettez les documents demandés et, le cas échéant, les justificatifs de règlement selon les modalités communiquées.`],
  ['Frais et modalités',nationalPayments(f)],
  ['Votre dossier',`Conservez votre référence ${f.reference} pour vos échanges avec le service admissions. La lettre et les annexes jointes sont à vérifier et à retourner uniquement selon les instructions du service.`],
 ]};
}
function nationalAdmissionMail(f:LetterFields){
 return `Bonjour ${f.full_name},\n\nNous avons le plaisir de vous annoncer votre admission au sein de ${f.school_name}. Vous trouverez votre lettre d’admission en pièce jointe.\n\nFormation : ${f.program_name}\nNiveau : ${f.academic_level}${f.pace?'\nRythme : '+f.pace:''}\nCampus : ${f.campus_name}\nRentrée : ${f.intake} (${f.academic_year})${f.rncp_code?'\nCode RNCP : '+f.rncp_code:''}\nRéférence du dossier : ${f.reference}\n\nMerci de contacter le service admissions dans les ${f.confirmation_days} jours suivant la réception de cette lettre pour confirmer votre inscription et suivre les démarches indiquées.\n\n${nationalPayments(f)}\n\nVeuillez consulter votre lettre et les annexes jointes. Le service admissions vous précisera les documents à retourner pour finaliser votre inscription.\n\nCordialement,\nService admissions - ${f.school_name}`;
}
