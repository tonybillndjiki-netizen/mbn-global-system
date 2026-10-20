# Envois MBN CRM avec Google Apps Script

Le CRM, ses accès, les 19 formulaires et les pièces privées restent dans l’application actuelle. Apps Script remplace le service d’expédition pour les invitations, les relances, les demandes de pièces et les lettres déjà approuvées. Le code conserve le fournisseur des messages historiques.

## Compte d’envoi

Commencer avec un compte Google choisi par Tony et un seul groupe d’expédition. Ce groupe peut desservir plusieurs écoles ; le logo et le nom affichés restent ceux de l’école du candidat. Les autres groupes peuvent rester en pause. Pour plusieurs adresses d’expédition, utiliser un projet Apps Script déployé par chacun des comptes concernés. MailApp utilise le compte qui exécute le projet ; renseigner une autre adresse dans le CRM ne change pas l’expéditeur réel. Les alias Gmail ne sont pas pris en charge par cette version.

## Préparer le projet Google

1. Ouvrir [Apps Script](https://script.google.com/) avec le compte qui doit envoyer et créer un projet dédié « MBN Mail ». Ne pas remplacer un projet existant de formulaires ou de Google Sheets.
2. Copier `appscript/Code.gs` dans `Code.gs`. Dans les paramètres du projet, afficher le manifeste `appsscript.json`, puis copier `appscript/appsscript.json`.
3. Exécuter `initialiserMBNMail` et autoriser les services Google demandés. Cette initialisation n’envoie aucun e-mail. Elle crée un journal technique dans un Google Sheet et génère un secret dans les propriétés du script. Le journal conserve uniquement l’identifiant interne du message, son empreinte, son état et sa date ; il ne doit pas être partagé.
4. Dans les propriétés du script, conserver `MBN_MAIL_SECRET` et `MBN_MAIL_LEDGER_ID`. Copier le secret directement vers les secrets du serveur, jamais dans le dépôt, le site public ou le chat.
5. Déployer une **Application Web**, exécution **en tant que vous**, accès permettant l’appel du serveur sans connexion interactive Google. Le connecteur authentifie chaque requête par une signature et refuse tout envoi non signé. Si la politique Workspace interdit ce type de déploiement, arrêter ce raccordement et faire valider l’accès par l’administrateur du domaine.
6. Conserver l’URL publiée se terminant par `/exec`. Le lien de l’éditeur et le lien de test `/dev` ne sont pas des points d’envoi.

Les autorisations sont l’envoi d’e-mails, l’identification du compte exécutant et la gestion du journal Google Sheets. Aucun accès en lecture à Gmail ni mot de passe de messagerie n’est demandé.

## Raccorder le serveur et le CRM

Installer la migration `mbn_apps_script_mail_provider`, puis les fonctions `mbn-workspace` et `mbn-letters` et le site correspondant depuis le même commit validé. Le serveur conserve le fournisseur existant jusqu’au choix explicite **Utiliser Google Apps Script** dans **Connexion e-mail** ; ce choix met les groupes en pause et invalide leurs anciennes preuves de test.

Dans les secrets des fonctions Supabase, créer `MBN_APPS_SCRIPT_ENDPOINTS`, dont la valeur est un objet JSON. Chaque groupe raccordé contient son URL et son secret :

```json
{
  "MBN_GLOBAL": {
    "url": "https://script.google.com/macros/s/IDENTIFIANT_DU_DEPLOIEMENT/exec",
    "secret": "SECRET_GENERE_DANS_LES_PROPRIETES_DU_PROJET"
  }
}
```

Les groupes supplémentaires disponibles sont `CAMPUS_INNOVATION_MLV` et `ADMISSIONS_COMMUN`. Ne pas inventer leurs comptes ou leurs rattachements. Chaque secret doit contenir 80 à 200 caractères alphanumériques, tirets ou soulignés ; l’initialiseur produit 96 caractères. Ne pas installer cet objet dans les variables publiques Netlify.

Dans **Connexion e-mail** :

1. Choisir **Utiliser Google Apps Script**.
2. Enregistrer l’adresse Google exacte et le nom du groupe.
3. Choisir le groupe et le contact admissions pour chaque école concernée.
4. Vérifier la connexion : le compte réel et le quota sont contrôlés par le projet signé.
5. Demander le test, limité à l’adresse confirmée du compte administrateur connecté.
6. Après réception réelle, confirmer manuellement le test, puis activer ce groupe. La confirmation porte sur le test accepté, son destinataire, son groupe et sa configuration courante. Une modification de l’adresse ou des identifiants impose un nouveau test.

## Fonctionnement et limites

- Le journal est écrit avant l’envoi ; une reprise du même message et du même contenu ne renvoie pas le mail. Une interruption, un contenu modifié sous le même identifiant ou un résultat non vérifiable demande une vérification humaine ; aucune relance automatique d’un envoi incertain n’est effectuée.
- Les échanges sont signés dans les deux sens, limités dans le temps et réservés aux points Google HTTPS autorisés. Une redirection ne reçoit jamais le corps du mail.
- Le plafond total MBN reste actif. Le quota Google est relu avant chaque envoi et prévaut s’il est plus bas. Les quotas documentés sont actuellement de 100 destinataires par jour pour un compte grand public et 1 500 pour Workspace, avec des règles particulières pour les comptes d’essai ; ils ne constituent pas une garantie pour un compte donné.
- Le nom et le logo de l’école, les liens personnels, les exclusions et le consentement existants restent appliqués. Les campagnes ne sont pas activées par ce changement.
- Les lettres exigent toujours la décision d’admission, les paramètres de l’école, les pièces requises et l’approbation humaine. Apps Script ne contourne ni les droits ni les contrôles antivirus.
- MailApp ne fournit pas de notification automatique de remise ou de rebond à ce connecteur. **Transmis au service d’envoi** signifie que l’appel Google a abouti ; le CRM ne le transforme pas en **Remis**. La confirmation manuelle du test est affichée séparément.
- Le compte rendu de tests automatisés utilise uniquement des messages, services et pièces synthétiques. L’autorisation du projet Google, un test réel reçu et la vérification des annexes sur le compte choisi restent indispensables avant utilisation réelle.

Références : [MailApp](https://developers.google.com/apps-script/reference/mail/mail-app), [quotas Apps Script](https://developers.google.com/apps-script/guides/services/quotas), [applications Web et identité d’exécution](https://developers.google.com/apps-script/guides/web).
