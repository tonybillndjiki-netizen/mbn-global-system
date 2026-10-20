# Installation et livraison MBN GLOBAL

Ce bloc prépare une installation reproductible et un workflow de livraison. Il ne configure aucun compte distant et ne déploie rien lors de sa préparation. Les fonctionnalités des blocs précédents doivent être présentes dans le commit retenu pour la livraison. Les notifications Brevo, connexions Meta et lettres officielles conservent leurs validations propres.

## Reconstruire un environnement neuf

Prévoir Node 24.19.0, Python 3.12, Docker et Supabase CLI **2.121.0**. Les trois migrations initiales, auparavant conservées dans une fixture de test, sont rétablies dans `supabase/migrations`. Tous les objets applicatifs proviennent désormais de ces migrations.

```sh
npm ci --ignore-scripts
npm run check
supabase start
supabase db reset --local
docker exec -i supabase_db_mbn-global-system psql -U postgres -d postgres -v ON_ERROR_STOP=1 < tests/fresh-installation.sql
supabase stop --no-backup
```

Les commandes de réinitialisation ci-dessus concernent exclusivement la pile Docker locale. La reconstruction complète avec Supabase est également prévue dans le job `fresh-installation`. Les tests PGlite simulent seulement les services de la plateforme, notamment Auth, Storage et Vault ; ils appliquent toutes les migrations de production et le catalogue réel du dépôt.

L’installation crée **19 écoles et 1 275 combinaisons de formation**, issues des formulaires actifs. Les formations et les écoles démarrent inactives, les groupes Brevo sont en pause et les paramètres de lettres sont vides. Aucune adresse d’administrateur, candidature ou campagne n’est préinstallée. Le seed ajoute les formations manquantes sans modifier une formation existante ni sa décision d’activation.

`node scripts/export_catalog.mjs` régénère `supabase/seed.sql` depuis les constantes littérales des 19 formulaires. Les identifiants sont déterministes. Le test d’installation refuse un seed qui ne correspond plus aux formulaires.

## Préparer recette et production

Créer **un projet Supabase et un site Netlify distincts pour chaque environnement**. Dans Supabase Auth, désactiver les inscriptions publiques et les comptes anonymes, définir l’URL du site et les redirections nécessaires. Ne pas relier le site Netlify à une publication Git parallèle : le workflow fourni publie directement le ZIP validé. Le domaine principal Netlify doit être servi en HTTPS.

Créer les environnements GitHub `staging` et `production`, limités à `main`. Configurer les personnes autorisées à approuver la production dans les règles de protection de cet environnement. Le code ne crée pas ces protections à distance. Protéger également `main` avec les jobs de validation requis.

| Variable par environnement | Valeur |
| --- | --- |
| `MBN_SUPABASE_PROJECT_REF` | Identifiant exact de 20 caractères du projet Supabase |
| `MBN_SUPABASE_PUBLISHABLE_KEY` | Clé publique publishable de ce projet, ou ancien JWT `anon` portant sa référence |
| `MBN_PUBLIC_ORIGIN` | Origine HTTPS principale du site Netlify, sans chemin ni barre finale |
| `NETLIFY_SITE_ID` | UUID exact du site Netlify |
| `MBN_INITIALIZE_CATALOG` | `false` normalement ; voir la reprise d’une première installation ci-dessous |

| Secret GitHub par environnement | Utilisation |
| --- | --- |
| `SUPABASE_ACCESS_TOKEN` | Accès au projet par le CLI et l’API de gestion |
| `SUPABASE_DB_PASSWORD` | Liaison et migrations de la base cible |
| `NETLIFY_AUTH_TOKEN` | Lecture et publication du site cible |

La variable **du dépôt** `MBN_DEPLOY_ENABLED` doit rester absente ou `false` tant que la recette n’est pas acceptée. Avec `true`, un push sur `main` livre automatiquement la recette. Une livraison de production se lance depuis **Actions → Deploy MBN GLOBAL → Run workflow**, branche `main`, environnement `production`, puis suit ses règles de protection. Une branche de fonctionnalité ne peut pas déployer. Les livraisons d’un même environnement sont sérialisées et une livraison en cours n’est pas annulée par le push suivant.

Les clés Brevo et Meta restent dans les secrets des fonctions Supabase, selon [Brevo](../CONNEXION_BREVO.md) et [Meta](CONNEXION_META.md). Le workflow de livraison n’active ni expéditeur, ni route Meta, ni école, ni campagne. Les trois secrets internes de signature et de planification sont générés dans Vault à l’installation ; leur présence est contrôlée sans afficher leur valeur.

## Construire et contrôler une cible

Définir les trois variables publiques `MBN_SUPABASE_PROJECT_REF`, `MBN_SUPABASE_PUBLISHABLE_KEY` et `MBN_PUBLIC_ORIGIN` dans le processus, en s’aidant de `.env.example`. Les scripts ne chargent pas automatiquement un fichier `.env`.

```sh
# Construction locale seulement ; aucun appel distant.
python3 scripts/release.py

# Lecture de la cible uniquement, avec ses secrets de gestion dans l’environnement.
python3 scripts/release.py --preflight
```

La construction produit `.release/site.zip`, les fonctions préparées et `.release/manifest.json`. Elle remplace les URL, la référence du projet et la clé publique dans les copies générées. Les imports de marque des fonctions sont regroupés dans leur dossier `_shared` ; le paquet de fonctions ne dépend donc pas de fichiers extérieurs. Les migrations historiques restent inchangées. Les clés privilégiées sont refusées dans la configuration publique. Le ZIP contient seulement les fichiers du navigateur ; les originaux privés et les polices côté serveur n’y entrent pas.

Le manifeste conserve le commit, la cible, la liste des fonctions, les versions et empreintes des migrations et l’empreinte du ZIP. `health.json` identifie le commit et la cible publiés. Ni les secrets de gestion ni les tickets de transfert ne sont écrits dans ces fichiers ou affichés par le contrôleur.

## Base existante : contrôler l’historique avant toute mise à jour

L’historique distant doit être exactement le début de la liste locale triée. Une version inconnue, un trou ou une base applicative sans historique arrête la livraison avant les migrations, les fonctions et la publication Netlify. Une base déjà attachée à une autre origine arrête également la livraison.

L’installation hébergée historique comporte des horodatages de migrations différents. **Le simple rétablissement des fichiers initiaux ne réconcilie pas cette base.** Faire d’abord une sauvegarde vérifiée, comparer son schéma et ses migrations aux fichiers du dépôt, puis préparer une réconciliation explicite et revue. Le contrôleur ne lance aucune commande `migration repair`, aucune suppression et aucune réinitialisation distante. Il compare les numéros de version ; cette comparaison ne prouve pas à elle seule l’égalité du contenu d’anciennes migrations. Les empreintes du manifeste servent aux livraisons suivantes et à la revue.

## Ordre d’une livraison activée

Après validation complète, dont la reconstruction Supabase locale, le contrôleur vérifie le site Netlify, la clé publique, les inscriptions Auth, l’historique et l’origine déjà installée. Il utilise ensuite le CLI épinglé pour lier la copie préparée, effectuer `db push --dry-run`, puis appliquer les migrations. Il initialise le catalogue seulement pour une base neuve ou lorsque `MBN_INITIALIZE_CATALOG=true` est explicitement demandé. Les activations existantes sont préservées.

Il contrôle Vault, configure les URL du planificateur, publie les huit fonctions, installe les vingt logos et les deux polices dont les empreintes sont fixées en base, puis vérifie la santé du backend. Le site est publié en dernier. Le contrôleur attend l’état Netlify `ready` et contrôle le commit et la cible dans `health.json`.

L’exécution locale d’une livraison exige un checkout propre, `MBN_DEPLOY_ENABLED=true`, les secrets attendus et la référence exacte de la cible :

```sh
python3 scripts/release.py --apply --confirm-project "$MBN_SUPABASE_PROJECT_REF"
```

Cette commande écrit réellement dans Supabase et Netlify. Sans `--apply`, aucune écriture distante n’est réalisée. Les appels HTTP refusent les redirections ; une écriture dont la réponse est incertaine n’est pas répétée automatiquement.

Si une première installation s’interrompt après les migrations et avant le catalogue, vérifier son état puis utiliser temporairement `MBN_INITIALIZE_CATALOG=true` pour reprendre. Le seed est idempotent ; remettre cette variable à `false` après la reprise. Les migrations déjà enregistrées sont reconnues par le contrôle d’historique. Une erreur de backend empêche la publication du nouveau site, mais peut laisser des migrations ou fonctions déjà appliquées. Il n’y a pas de retour automatique de la base en arrière : diagnostiquer et corriger avant de relancer. Si Netlify a accepté la publication mais que le contrôle final échoue, vérifier d’abord son état et `health.json` dans le tableau de bord.

## Premier propriétaire et originaux privés

Créer dans Supabase Auth le compte du propriétaire, avec une adresse confirmée et un mot de passe initial. Depuis le SQL Editor du **projet cible**, exécuter avec son adresse réelle normalisée :

```sql
select public.mbn_installation_bootstrap_owner('proprietaire@votre-domaine.fr');
```

La fonction n’accepte qu’un compte confirmé, non anonyme, non supprimé et non banni. Elle active son profil et ne permet pas d’ajouter un deuxième propriétaire après l’initialisation. Dans l’application cible, ouvrir **Mon accès**, confirmer cet accès existant et choisir son nom d’utilisateur et son code personnel. Ajouter ensuite les collaborateurs et leurs droits depuis l’interface habituelle, puis contrôler et activer le catalogue voulu.

Les sept annexes bancaires et contractuelles ne sont pas dans Git et ne sont pas transférées par le workflow. Une nouvelle installation exige leur restauration privée depuis les originaux validés, en contrôlant les empreintes du manifeste conservé dans `source/mail-assets/manifest.json`. Les documents de l’installation historique ne sont pas copiés implicitement. La génération et l’envoi d’une lettre utilisant une annexe absente restent bloqués. Les frais, signataires, rentrées, expéditeurs et validations humaines restent à renseigner dans la cible.

## Références techniques

- [Migrations Supabase](https://supabase.com/docs/guides/deployment/database-migrations)
- [Environnements Supabase](https://supabase.com/docs/guides/deployment/managing-environments)
- [Déploiement des fonctions](https://supabase.com/docs/guides/functions/deploy)
- [API SQL Supabase](https://supabase.com/docs/reference/api/v1-run-a-query), endpoint expérimental : toute réponse inattendue arrête la livraison.
- [API Netlify, méthode ZIP](https://docs.netlify.com/api-and-cli-guides/api-guides/get-started-with-api/)
- [Protections des environnements GitHub](https://docs.github.com/en/actions/how-tos/deploy/configure-and-manage-deployments/manage-environments)
