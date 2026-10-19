# Connecter MBN Mail à Brevo

Version 0.8.0 · lot deux expéditeurs du 19 octobre 2026. Le serveur et les lettres utilisent l’API Brevo. Les envois de chaque groupe restent désactivés tant que sa configuration et son propre test de remise ne sont pas validés. Voir aussi [l’audit et le guide de reprise](docs/BREVO_MULTI_ECOLES.md).

## Ce que Tony doit préparer

1. Un compte Brevo avec l’envoi transactionnel actif et des crédits e-mail disponibles.
2. Deux adresses automatiques distinctes, par exemple de type `no-reply`, ajoutées et validées dans ce compte : une pour MBN Global Éducation et une pour Campus Innovation Marne-la-Vallée. Les adresses exactes restent à fournir. Installer pour chaque domaine les réglages d’authentification DNS exacts fournis par Brevo.
3. Une clé API Brevo autorisée à lire le compte et les expéditeurs, envoyer des e-mails et gérer les webhooks. Saisir la clé directement dans les secrets du serveur.
4. La correspondance confirmée entre les 19 écoles et ces deux groupes, ainsi que l’adresse du service des admissions à afficher pour chaque école. Le campus seul ne détermine pas ce rattachement.

## Mise en service

1. Ouvrir [les secrets des fonctions Supabase](https://supabase.com/dashboard/project/ppqeuluykiknuujfaoid/functions/secrets). Ajouter **MBN_BREVO_API_KEY**, coller la clé Brevo comme valeur, puis enregistrer. Garder cette valeur hors des fichiers du site et des conversations.
2. Après validation et livraison de ce lot, ouvrir **Connexion e-mail** dans [MBN GLOBAL](https://mbn-global.netlify.app/mbn_global_admin_supabase). Enregistrer le nom et l’adresse de chacun des deux expéditeurs en laissant leurs envois en pause. Régler le plafond quotidien total.
3. Dans **Écoles et adresses de contact**, renseigner puis enregistrer le groupe et le contact admissions de chaque école. Une école sans groupe ou sans contact ne sera pas envoyée. Au moins une école active et configurée est nécessaire pour tester chaque groupe.
4. Cliquer **Vérifier cet expéditeur** pour chaque profil. L’application contrôle l’adresse dans les expéditeurs actifs, l’activation de l’envoi transactionnel et les crédits e-mail retournés par le compte.
5. Cliquer une fois **Configurer les retours Brevo** dans la partie commune. L’application crée ou met à jour uniquement son propre webhook, avec un secret d’authentification généré côté serveur. Elle ne modifie pas les webhooks des autres applications. Refaire cette configuration invalide les tests des deux profils.
6. Avec l’autorisation d’effectuer des envois réels, cliquer **M’envoyer son test** pour chaque expéditeur. Le destinataire est limité à l’adresse confirmée du compte administrateur connecté. Vérifier le message et son contact admissions, puis cliquer **Actualiser les statuts** jusqu’à la remise confirmée pour chacun des deux profils.
7. Cocher **Activer les envois de ce groupe**, puis enregistrer pour chaque groupe prêt. Le serveur refuse l’activation avant la remise du test correspondant à son identité actuelle et à la clé commune. La réussite du test de l’autre groupe ne suffit pas.

## Écoles, lettres et annexes

Chaque message reprend le nom et le logo de son école ou de son campus. Les huit écoles concernées utilisent Campus Innovation Marne-la-Vallée. L’adresse d’expédition est celle du groupe attribué à l’école et vérifiée dans Brevo. Les réponses restent dirigées vers l’adresse automatique d’expédition. Le corps de chaque e-mail contient la mention « Merci de ne pas répondre à cet e-mail » et invite le destinataire à écrire au contact admissions enregistré pour son école.

Les lettres internationales sont générées après admission, consultées puis approuvées par une personne autorisée pour l’école. Le PDF et les annexes sélectionnées sont transmis comme pièces jointes en base64 ; aucun lien public vers les documents privés n’est créé. Les sept originaux sont déjà installés avec leurs empreintes et leurs tailles contrôlées. Les CGV CESCOM restent limitées à CESCOM ; aucun RIB n’est sélectionné automatiquement. Le modèle national reste à fournir.

La séquence Meta reste J0, J+2, J+4 et J+6. Le consentement, les exclusions, l’engagement confirmé sur le lien de candidature et la candidature déposée gardent leurs contrôles. Les ouvertures ou clics déclarés par Brevo ne déclenchent aucune progression du dossier. Le lien de désinscription reste présent dans chaque message de campagne.

## Exploitation

- **Accepté par Brevo** signifie que l’API a accepté le message. **Remis** dépend d’un retour de livraison authentifié et corrélé au message et à son destinataire.
- Les notifications sont dédupliquées. Rejets permanents et plaintes excluent l’adresse des envois suivants ; les désinscriptions arrêtent les campagnes de cette adresse dans les écoles concernées.
- Les coupures après transmission ou réponses ambiguës restent **Envoi à vérifier**, sans nouvel envoi automatique.
- Un retour arrivé avant la fin de l’envoi reçoit une réponse 429 pour permettre la nouvelle tentative Brevo. Les retours peuvent donc être différés. Une réponse 5xx arrêterait les nouvelles tentatives selon la documentation Brevo.
- Un changement de nom ou d’adresse invalide le test de cet expéditeur. Une nouvelle clé API impose de reconfigurer les retours et de refaire les tests des deux expéditeurs. Une modification du groupe ou du contact d’une école révoque les messages déjà réservés qui utilisent l’ancienne configuration.
- Le plafond quotidien MBN est commun aux deux groupes, tests et lettres compris. Les limites du compte Brevo s’appliquent aussi. Les crédits SMS ne sont pas comptés comme crédits e-mail. Aucun volume d’envoi n’est garanti par le code.

Endpoint des retours : `https://ppqeuluykiknuujfaoid.supabase.co/functions/v1/mbn-brevo-events`.

## Sources officielles vérifiées

- [Envoi et pièces jointes](https://developers.brevo.com/reference/send-transac-email)
- [Compte et crédits](https://developers.brevo.com/reference/get-account)
- [Expéditeurs](https://developers.brevo.com/reference/get-senders)
- [Configuration des retours](https://developers.brevo.com/reference/create-webhook)
- [Authentification des retours](https://developers.brevo.com/docs/secured-webhooks)
- [Nouvelles tentatives](https://developers.brevo.com/docs/retry-mechanism)
