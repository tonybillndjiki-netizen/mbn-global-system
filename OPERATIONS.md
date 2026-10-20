# MBN GLOBAL — exploitation de la version 0.8

Le site est publié sur Netlify. Supabase gère les utilisateurs, les autorisations, le catalogue, le CRM et les documents privés. Aucun Apps Script n’est utilisé dans le fonctionnement de cette version.

## Vérifier une livraison

Utiliser Node 24.19.0 et Python 3.12. Installer les dépendances avec `npm ci --ignore-scripts`, puis exécuter `npm run check`. Cette commande teste les fonctions et la base locale, vérifie TypeScript et fabrique le ZIP destiné à Netlify. Le constructeur exclut les sources privées et vérifie les références locales des 19 formulaires. Le fichier public `health.json` indique la version publiée et l’empreinte des scripts.

Le dépôt GitHub contient les contrôles automatisés. Le [guide d’installation et de déploiement](docs/INSTALLATION_DEPLOIEMENT.md) décrit la reconstruction d’une base neuve et le workflow de livraison, désactivé par défaut. Les anciennes migrations hébergées ont des horodatages différents de leurs fichiers locaux : le contrôle d’historique bloque cette situation jusqu’à une réconciliation revue. Le workflow ne répare pas cet historique automatiquement.

## Activer MBN Mail avec Brevo

Suivre [CONNEXION_BREVO.md](CONNEXION_BREVO.md) et [les trois groupes d’expédition](docs/BREVO_MULTI_ECOLES.md). Ajouter MBN_BREVO_API_KEY dans les secrets Supabase ; enregistrer les trois expéditeurs et le plafond quotidien commun ; renseigner le groupe et le contact admissions des 19 écoles ; vérifier chaque expéditeur ; configurer les retours communs ; confirmer la remise d’un test administrateur pour chaque expéditeur avant de l’activer.

Le webhook mbn-brevo-events utilise un jeton Bearer dédié conservé côté serveur. Chaque événement est corrélé au destinataire et à l’identifiant Brevo, puis dédupliqué. Les erreurs temporaires renvoient 429 pour conserver les nouvelles tentatives Brevo. Les rejets permanents et plaintes entraînent l’exclusion globale de l’adresse ; une désinscription arrête les campagnes.

Le job mbn-mail-due reste désactivé tant que les envois sont en pause. Une acceptation API reste distincte de la remise. Un envoi ambigu reste à vérifier, sans répétition automatique. Les réglages AWS et SNS historiques sont retirés de l’interface active.

## Parcours prospect et candidature

L’ajout ou l’import CSV crée un prospect, sans candidature prématurée. Les imports ont une limite de 500 lignes et ignorent les adresses déjà présentes dans la même école sans restaurer leur consentement. Les preuves de consentement sont obligatoires lorsqu’un consentement est déclaré.

Une campagne Meta crée exactement quatre échéances : J0, J+2, J+4, J+6. Elle exige la source Meta Lead Ads et un consentement documenté. Les contacts Messenger, dossiers déposés, clics confirmés, désinscrits et exclus restent hors séquence. Les relances après clic sont désactivées : leur calendrier n’a pas encore été validé.

Chaque prospect possède une invitation signée personnelle. Une simple visite du lien ne confirme aucun clic. Le bouton « Continuer ma candidature » confirme l’engagement et arrête la séquence A. Les 19 formulaires utilisent le catalogue actif central. Une invitation doit correspondre à l’école et à l’adresse du candidat. Les fichiers sont limités à PDF, PNG et JPEG, 5 Mo par pièce et 20 Mo au total ; leur intégrité est vérifiée. Leur dépôt est reprenable et le CRM n’est finalisé qu’après la présence des pièces. Le [bloc antivirus](docs/ANTIVIRUS.md) bloque le téléchargement et la nouvelle validation d’une pièce sans résultat propre. Son moteur ClamAV reste à installer, raccorder et tester réellement ; le traitement démarre en pause.

## CRM et équipe

L’administrateur active les personnes et leurs écoles. Les autorisations de vérification des pièces, de décision, de lettres et de campagnes sont indépendantes. Les règles d’affectation prennent en compte l’école, la formation, le campus et la rentrée lorsqu’elle est renseignée dans les données. Une absence de responsable valide produit « Affectation à vérifier ». La prise de décision exige une autorisation explicite ; les pièces obligatoires doivent être validées pour déclarer le dossier complet. L’historique conserve les changements, les notes et les affectations.

Les dossiers fictifs se consultent via **Voir les dossiers de test**, réservé à l’administrateur. Ils restent hors indicateurs réels et hors campagnes. Les formulaires ouverts sans invitation sont réservés aux validations administrateur.

## Ce qui reste à finaliser

L’expéditeur Brevo et la clé API doivent être configurés par le propriétaire du compte. Les lettres internationales sont générées en PDF et exigent une validation humaine avant l’envoi. Les sept annexes originales sont installées dans le stockage privé, après accord explicite le 19 octobre 2026 ; tailles et empreintes SHA-256 vérifiées, téléchargements publics refusés. Les sources fournies divergent sur l’AVI (facultative dans le mail et la lettre, obligatoire dans une attestation). Deux versions de CGV ont des portées différentes (CESCOM / groupe). Ces choix doivent être configurés et validés avant d’adresser des documents officiels ; aucune coordonnée de paiement issue d’un exemple n’est diffusée automatiquement.

Ne pas afficher les variables secrètes, les liens personnels de candidats ou les documents privés dans les journaux. Les formulaires du site public ne donnent aucun accès au CRM sans authentification ; les opérations métier sensibles contrôlent aussi la présence de la session et l’activation du compte au moment de l’action.

## Formulaires Messenger et lettres internationales

Les liens hébergés de MBN_LIENS_FORMULAIRES_19_ECOLES.md ouvrent une session sans compte administrateur, valable deux jours. Une ouverture ou un aperçu Messenger ne crée aucun prospect et n’accorde aucun consentement. Le dossier complet conserve la source META_MESSENGER et reste hors séquence A. Les invitations personnelles existantes conservent leur confirmation explicite et leur contrôle d’adresse e-mail.

Le service mbn-letters vérifie la session active et le droit indépendant can_send_letters sur l’école du dossier. Il bloque les lettres de test, l’absence de décision ADMIS, l’utilisation des CGV CESCOM hors CESCOM et les incohérences AVI. Le PDF est immuable, l’approbation précède la prise du verrou d’envoi et un envoi incertain ne se relance pas automatiquement. Le nom de l’école et le destinataire viennent du dossier. Les lettres des huit écoles concernées imposent le logo Campus Innovation, avec le logo de l’école en option complémentaire.

CONNEXION_BREVO.md décrit les prérequis Brevo, les champs à renseigner et les étapes de mise en service restantes.
