# Reprendre MBN GLOBAL Mail et CRM

Ce guide accompagne le bloc 8 « finitions » du document `elements a ajouter.pdf`. Le dépôt contient le code et les tests ; les paramètres métiers, secrets et essais dans les services réels restent distincts. La branche de finitions reprend les blocs 1, 2, 3, 5, 6 et 7. **Le bloc 4 reste sur une branche séparée.**

## Où se trouve le travail

État des branches distantes vérifié le **20 octobre 2026** :

| Bloc | Branche | Commit du code préparé | Publication GitHub constatée |
| --- | --- | --- | --- |
| Version de référence | `main` | `9a8b173` | `9a8b173`, inchangé par ces blocs |
| 1. Trois expéditeurs Brevo | `feature/brevo-multi-ecoles` | `18ac797` | `18ac797` |
| 2. Équipes et affectations | `feature/equipes-affectations` | `265293c` | `265293c` |
| 3. Pièces complémentaires | `feature/pieces-complementaires` | `3fa3d36` | `3fa3d36` |
| 4. Relances après clic | `feature/relances-apres-clic` | `1691ea3`, local | La branche distante pointe encore sur `3fa3d36` ; le code du bloc 4 n’y est pas publié |
| 5. Lettres nationales et paramètres | `feature/lettres-nationales` | `96c9ef1`, local | `34e322d`, contenu identique au commit local |
| 6. Meta Lead Ads | `feature/meta-leads` | `2a38839`, local | Branche absente du dépôt distant lors de la vérification |
| 7. Installation et livraison | `feature/installation-deploiement` | `b5b9c9b`, local | Branche absente du dépôt distant lors de la vérification |
| 8. Antivirus et recette | `feature/finitions-recette` | Commit de cette branche, voir `git log -1` | Préparé localement, sans publication |

Les commits local et distant des lettres portent des identifiants différents mais le même arbre de fichiers. Avant une publication ultérieure, vérifier les différences et la filiation de la branche distante ; ne pas forcer son remplacement. Aucun bloc n’a été fusionné dans `main` dans le cadre de cette préparation. La publication de code ne prouve ni son déploiement ni la configuration des services.

Une archive Git `MBN_Reprise_Complete.bundle` peut conserver les branches locales, y compris le bloc 4 séparé, sans dépendre de leur publication. Pour reprendre le bundle livré :

```sh
git clone -b feature/finitions-recette MBN_Reprise_Complete.bundle mbn-global-system
cd mbn-global-system
git remote set-url origin https://github.com/tonybillndjiki-netizen/mbn-global-system.git
git log -1 --oneline
npm ci --ignore-scripts
npm run check
```

La dernière commande utilise Node 24.19.0 et Python 3.12. Les différentes branches du bundle sont récupérées comme branches distantes du clone ; les sélectionner explicitement si nécessaire. Le clone du dépôt GitHub seul ne récupère pas les blocs qui n’y ont pas encore été publiés.

## Ce que chaque composant fait

| Composant | Rôle | Référence |
| --- | --- | --- |
| Site statique Netlify | Interface admissions, Mail, CRM et 19 formulaires | `assets/`, `forms/`, constructeur `scripts/build_netlify.py` |
| Supabase Auth et `mbn-auth` | Comptes confirmés, accès personnel, sessions révocables | Migrations d’accès et tests PIN |
| `mbn-workspace` | Prospects, campagnes, droits, pièces et décisions | [Exploitation](../OPERATIONS.md) |
| `mbn-admissions`, `mbn-form-ingest` | Invitations et dépôt privé reprenable | [Pièces complémentaires](PIECES_COMPLEMENTAIRES.md) |
| `mbn-letters` | PDF national/international, aperçu puis approbation | [Lettres](LETTRES_ADMISSION.md) |
| `mbn-brevo-events` | Remises, erreurs, plaintes et désinscriptions Brevo | [Brevo](BREVO_MULTI_ECOLES.md) |
| `mbn-meta` | Notifications signées et récupération des fiches Lead Ads | [Meta](CONNEXION_META.md) |
| `mbn-antivirus` et `scanner/server.py` | File d’analyse et adaptateur local ClamAV | [Antivirus](ANTIVIRUS.md) |
| `mbn-mail-events` | Compatibilité historique des notifications SNS, hors parcours Brevo actif | [Ancienne connexion SES](../CONNEXION_AMAZON_SES.md) |
| Contrôleur de livraison | Cible explicite, contrôle d’historique, migrations, fonctions et ZIP | [Installation](INSTALLATION_DEPLOIEMENT.md) |

Les fonctions disposent de leurs propres contrôles d’authentification et de droits. Les secrets de service ne vont jamais dans les fichiers du navigateur. Le ZIP Netlify contient seulement les fichiers publics. Les annexes originales privées se restaurent séparément depuis leurs sources validées.

## Configuration à obtenir avant la recette réelle

| Sujet | Informations à faire valider | Où les renseigner |
| --- | --- | --- |
| Expédition | Trois adresses automatiques vérifiées, groupes des 19 écoles, contact admissions par école, plafond commun | Connexion Brevo ; clé dans les secrets Supabase |
| Responsables | Principal et suppléant, comptes confirmés, droits par école et exceptions campus/formation/rentrée | Équipes puis Règles d’affectation |
| Lettres | Texte national, frais, acomptes, signataires, rentrées, délai et règle AVI | Paramètres des lettres, par école et type |
| Annexes | Originaux validés et empreintes attendues | Stockage privé via le parcours d’installation des originaux |
| Meta | Application, pages, formulaires, version Graph supportée, champs et preuve du consentement | Secrets Supabase puis Connexion Meta |
| Antivirus | Hôte ClamAV maintenu, mises à jour des signatures, adaptateur HTTPS et test de détection | Configuration technique puis Analyse antivirus |
| Déploiement | Projets séparés recette/production, secrets, protections GitHub et historique réconcilié | Environnements GitHub et tableaux de bord des services |
| Après clic | Calendrier et textes approuvés, intégration du bloc 4 séparé à revoir | Branche `feature/relances-apres-clic`, jamais activée implicitement |

Aucune répartition d’équipe, adresse automatique, tarif, signataire ou date métier ne doit être déduit d’un exemple. Les trois groupes d’expédition démarrent en pause, les 38 paramètres de lettres sont vides et Meta n’a aucun rattachement initial. L’antivirus reste en pause jusqu’à son raccordement. Sa migration bloque les nouvelles opérations sur les pièces non analysées : prévoir la recette du moteur avant une installation en production.

## Revue et mise en service

1. Partir du commit exact retenu et lancer les contrôles locaux puis GitHub Actions. Vérifier la reconstruction Supabase avec Docker ; elle n’a pas été exécutée dans le runtime de préparation.
2. Revoir le code et les migrations. Pour la base hébergée historique, comparer le schéma et les versions avant toute tentative de livraison. Le contrôleur refuse l’historique divergent et ne le répare pas automatiquement.
3. Installer les blocs retenus dans l’environnement de recette, restaurer les originaux et configurer les comptes, équipes, services et écoles de démonstration.
4. Exécuter [la recette fonctionnelle](RECETTE.md), y compris moteur antivirus, vrai navigateur et réceptions e-mail. Conserver le compte rendu et les preuves dans un espace interne, sans secrets ou liens candidats dans Git.
5. Faire valider les résultats et le texte officiel des lettres par les responsables concernés. Une fusion et une mise en production demandent une décision distincte de la préparation du code.

En cas de reprise après échec, vérifier d’abord l’état de la base, des fonctions et de la publication Netlify. Une erreur peut survenir après une migration déjà appliquée. Ne pas réinitialiser une base distante pour la faire correspondre au dépôt. Les envois incertains restent à vérifier dans Brevo avant toute nouvelle tentative.
