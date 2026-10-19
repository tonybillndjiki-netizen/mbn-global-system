# Connecter MBN Mail à Brevo

Version 0.8.0 · 19 octobre 2026. Le serveur et les lettres utilisent l’API Brevo. Les envois réels restent désactivés tant que la clé, l’expéditeur et le test de remise ne sont pas validés.

## Ce que Tony doit préparer

1. Un compte Brevo avec l’envoi transactionnel actif et des crédits e-mail disponibles.
2. Une adresse d’expédition ajoutée et validée dans ce compte. Pour un domaine professionnel, installer les réglages d’authentification DNS fournis par Brevo chez l’hébergeur du domaine, par exemple LWS. Utiliser les valeurs exactes affichées par Brevo.
3. Une clé API Brevo autorisée à lire le compte et les expéditeurs, envoyer des e-mails et gérer les webhooks. Saisir la clé directement dans les secrets du serveur.

## Mise en service

1. Ouvrir [les secrets des fonctions Supabase](https://supabase.com/dashboard/project/ppqeuluykiknuujfaoid/functions/secrets). Ajouter **MBN_BREVO_API_KEY**, coller la clé Brevo comme valeur, puis enregistrer. Garder cette valeur hors des fichiers du site et des conversations.
2. Dans [MBN GLOBAL](https://mbn-global.netlify.app/mbn_global_admin_supabase), ouvrir **Connexion e-mail**. Enregistrer l’adresse d’expédition, l’adresse de réponse et le plafond quotidien MBN, en laissant les envois en pause.
3. Cliquer **Vérifier Brevo**. L’application contrôle l’adresse dans les expéditeurs actifs, l’activation de l’envoi transactionnel et les crédits e-mail retournés par le compte.
4. Cliquer **Configurer les retours Brevo**. L’application crée ou met à jour uniquement son propre webhook, avec un secret d’authentification généré côté serveur. Elle ne modifie pas les webhooks des autres applications.
5. Cliquer **M’envoyer un test**. Le destinataire est limité à l’adresse du compte administrateur connecté. Vérifier le message, puis actualiser la connexion jusqu’à l’affichage de la remise confirmée.
6. Cocher **Activer les envois planifiés**, puis enregistrer. Le serveur refuse l’activation avant la confirmation de remise du test pour la clé et l’adresse actuellement configurées.

## Écoles, lettres et annexes

Chaque message reprend le nom et le logo de son école ou de son campus. Les huit écoles concernées utilisent Campus Innovation Marne-la-Vallée. L’adresse d’expédition est celle enregistrée et vérifiée dans Brevo.

Les lettres internationales sont générées après admission, consultées puis approuvées par une personne autorisée pour l’école. Le PDF et les annexes sélectionnées sont transmis comme pièces jointes en base64 ; aucun lien public vers les documents privés n’est créé. Les sept originaux sont déjà installés avec leurs empreintes et leurs tailles contrôlées. Les CGV CESCOM restent limitées à CESCOM ; aucun RIB n’est sélectionné automatiquement. Le modèle national reste à fournir.

La séquence Meta reste J0, J+2, J+4 et J+6. Le consentement, les exclusions, l’engagement confirmé sur le lien de candidature et la candidature déposée gardent leurs contrôles. Les ouvertures ou clics déclarés par Brevo ne déclenchent aucune progression du dossier. Le lien de désinscription reste présent dans chaque message de campagne.

## Exploitation

- **Accepté par Brevo** signifie que l’API a accepté le message. **Remis** dépend d’un retour de livraison authentifié et corrélé au message et à son destinataire.
- Les notifications sont dédupliquées. Rejets permanents et plaintes excluent l’adresse des envois suivants ; les désinscriptions arrêtent les campagnes de cette adresse dans les écoles concernées.
- Les coupures après transmission ou réponses ambiguës restent **Envoi à vérifier**, sans nouvel envoi automatique.
- Un retour arrivé avant la fin de l’envoi reçoit une réponse 429 pour permettre la nouvelle tentative Brevo. Les retours peuvent donc être différés. Une réponse 5xx arrêterait les nouvelles tentatives selon la documentation Brevo.
- Un changement d’adresse invalide les preuves précédentes. Une nouvelle clé API impose de reconfigurer les retours et de refaire le test.
- Le plafond quotidien MBN et les limites du compte Brevo s’appliquent. Les crédits SMS ne sont pas comptés comme crédits e-mail. Aucun volume d’envoi n’est garanti par le code.

Endpoint des retours : `https://ppqeuluykiknuujfaoid.supabase.co/functions/v1/mbn-brevo-events`.

## Sources officielles vérifiées

- [Envoi et pièces jointes](https://developers.brevo.com/reference/send-transac-email)
- [Compte et crédits](https://developers.brevo.com/reference/get-account)
- [Expéditeurs](https://developers.brevo.com/reference/get-senders)
- [Configuration des retours](https://developers.brevo.com/reference/create-webhook)
- [Authentification des retours](https://developers.brevo.com/docs/secured-webhooks)
- [Nouvelles tentatives](https://developers.brevo.com/docs/retry-mechanism)
