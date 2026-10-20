# MBN GLOBAL — Mail & CRM

Version 0.8.0. Application de pilotage pour les 19 écoles MBN GLOBAL, hébergée sur Netlify et reliée directement à Supabase. Connexion par nom d’utilisateur et code personnel à six chiffres ; les comptes, les écoles et les autorisations sont administrés dans l’application.

## Utilisation

Ouvrir https://mbn-global.netlify.app/mbn_global_admin_supabase. Les fichiers HTML locaux ont besoin de leurs dossiers `assets` et `forms` complets ; le ZIP Netlify contient uniquement les fichiers publics nécessaires.

- **MBN Mail** : carnet de prospects, import CSV depuis Excel, modèles, aperçu des e-mails, brouillons de campagnes, séquence Meta J0/J+2/J+4/J+6 et file d’envoi.
- **MBN CRM** : candidatures, liste et tableau, pièces privées, vérification, notes, affectations, règles de routage et décisions avec historique.
- **19 écoles** : logos fournis, activation des établissements et des collaborateurs, catalogue central. Évry BTS conserve son identité et ses propres identifiants de formation, avec le cursus de Marne-la-Vallée BTS.
- **Candidatures** : invitations personnelles signées, consentement marketing distinct, dépôt privé reprenable, contrôle du catalogue et déduplication. Les liens publics hébergés ouvrent une session de candidature par école, sans compte administrateur ; les formulaires ouverts sans session restent en mode test. Voir MBN_LIENS_FORMULAIRES_19_ECOLES.md.

Trois profils d’expédition Brevo sont prévus : MBN Global Éducation, Campus Innovation Marne-la-Vallée et un profil commun neutre pour les autres écoles. Le nom visible est « Service admissions - nom de l’école ». Chaque école doit être rattachée explicitement à son groupe avec son contact admissions. Les trois adresses restent à renseigner et les envois de chaque groupe restent en pause jusqu’à la remise de son propre test. Voir [le lot Brevo multi-écoles et sa reprise](docs/BREVO_MULTI_ECOLES.md). Le module de lettres internationales génère un PDF après admission, avec l’identité de l’école et une validation humaine avant l’envoi. Les sept annexes originales ont été installées dans le stockage privé, avec accord explicite le 19 octobre 2026 et contrôle des empreintes ; la clé API et l’expéditeur Brevo attendent leur configuration. Voir [CONNEXION_BREVO.md](CONNEXION_BREVO.md) et [OPERATIONS.md](OPERATIONS.md).

Le [lot équipes et affectations](docs/EQUIPES_AFFECTATIONS.md) ajoute le choix des responsables par école, campus et formation, un suivi de configuration des écoles et un aperçu avant reprise des dossiers sans responsable. La répartition réelle reste à valider et à renseigner dans l’interface.

Le [lot pièces complémentaires](docs/PIECES_COMPLEMENTAIRES.md) permet de préparer une demande, de l’envoyer avec l’expéditeur de l’école et de recevoir uniquement les pièces demandées sur un lien personnel. Les anciennes versions restent privées et les nouveaux fichiers reviennent en vérification.

Le [lot relances après clic](docs/RELANCES_APRES_CLIC.md) ajoute un calendrier et des messages réglables par école dans MBN Mail. Les relances concernent les prochains clics confirmés après activation, s’arrêtent au dépôt et expirent sans rattrapage groupé.

## Développement et livraison

Node 24.19.0, Python 3.12. Dépendances exactes et verrouillées.

```sh
npm ci --ignore-scripts
npm run check
python3 scripts/package_release.py
```

`npm run check` exécute les tests de la base locale PGlite et des services HTTP, le typage TypeScript et la construction du paquet statique Netlify. Le workflow `.github/workflows/validate.yml` lance ces vérifications à chaque push et pull request, puis conserve le ZIP public comme artefact. Le déploiement continu Netlify reste à raccorder au dépôt.

Les tests hébergés `tests/hosted-workspace-transaction.sql` utilisent des données synthétiques dans une transaction annulée. Ils n’envoient aucun e-mail et ne créent aucun document réel. Les tests de fichiers natifs et de PIN restent inclus. Le relevé de validation propre à l’environnement déployé reste dans le dossier privé du projet.

Les services `mbn-workspace`, `mbn-admissions`, `mbn-letters` et `mbn-mail-events` vérifient eux-mêmes l’authentification : session utilisateur active, invitation signée, notification SNS signée ou secret du planificateur. Les RPC métier ne sont pas exécutables par les rôles navigateur. Les clés privilégiées ne sont jamais dans le site public.

Le dépôt [mbn-global-system](https://github.com/tonybillndjiki-netizen/mbn-global-system) contient le code actif, les migrations, les tests et les 19 formulaires hébergés. Les annexes bancaires et contractuelles, les modèles originaux, les formulaires sources historiques et les relevés privés sont exclus de Git. Les logos publics, les polices avec leur licence et le manifeste d’intégrité des pièces restent disponibles pour le code. Les clés API sont configurées dans les secrets Supabase.

Les commandes `build:forms` et `audit:forms` servent à comparer ou régénérer les formulaires depuis les originaux privés fournis par les écoles. Elles nécessitent ces fichiers dans `source/forms/`. La construction courante et les tests utilisent les formulaires actifs présents dans `forms/`.

## Vérification des formulaires et identité du campus

FORMULAIRES_VERIFICATION.json compare les 20 versions sources aux 1 275 combinaisons actives des 19 écoles : aucun écart. Les huit écoles auparavant rattachées au libellé Noisiel sont présentées sous Campus Innovation Marne-la-Vallée, avec le logo fourni. Le code de routage et l’adresse postale sont conservés. Les mails sortants et les lettres utilisent l’identité de l’école ou de son campus.
