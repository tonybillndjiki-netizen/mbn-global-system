# Brevo : trois expéditeurs et gestion des groupes par école

## Audit du 19 octobre 2026

Référence de départ : `9a8b1730fdddfdc3b40c2308bfeb467e14794a4b` sur `main`.
Le document du responsable, « elements a ajouter.pdf », donne la priorité à
Brevo, puis aux affectations et aux dossiers incomplets. Ce lot porte sur Brevo.

L'intégration existante utilisait une seule ligne de configuration d'expéditeur,
partagée par les campagnes et les lettres. Le client API Brevo, les retours
authentifiés, la déduplication et les contrôles d'accès existaient déjà.
Les logos de huit écoles utilisaient déjà Campus Innovation Marne-la-Vallée ;
ce rattachement visuel ne constituait pas une règle de choix d'expéditeur.
Le rendu des messages ne comportait pas de contact de service par école.

La vérification initiale `npm run check` a réussi : 143 tests, typage et
construction du site. Le workflow GitHub de cette référence était également
réussi. Cela ne prouve pas la livraison d'un e-mail réel.

## Comportement du nouveau lot

Trois profils sont disponibles :

| Code | Nom du groupe, modifiable | Usage prévu |
| --- | --- | --- |
| `MBN_GLOBAL` | MBN Global Éducation | Écoles rattachées à MBN, quel que soit leur campus |
| `CAMPUS_INNOVATION_MLV` | Campus Innovation Marne-la-Vallée | Les huit écoles de Noisiel |
| `ADMISSIONS_COMMUN` | Service admissions | Expéditeur commun neutre, notamment ESETH, LSB, EVRY BTS et EVRY BS |

Ces groupes sont des profils d’envoi, pas un modèle d’entités juridiques.
Une école peut être présente sur plusieurs campus : son groupe d’expédition
est commun à tous ses campus. Les affectations restent à confirmer et à
saisir dans l’interface ; la migration ne les devine pas.

Le troisième profil est ajouté par une nouvelle migration additive,
`20261019130000_mbn_mail_third_sender.sql`, après le premier lot à deux
expéditeurs. Les routes et les preuves existantes des deux premiers profils
sont conservées. Aucun expéditeur déjà configuré n’est remplacé.
Ils utilisent une clé Brevo commune, un suivi de livraison commun et un plafond
quotidien commun. L’adresse d’expédition est propre à chaque profil.
Le nom affiché au destinataire est calculé automatiquement :
**Service admissions - [nom de l’école]**. Le nom du groupe est un libellé
d’administration ; il ne remplace pas ce nom visible. Les campagnes, les tests
et les lettres appliquent la même règle depuis `assets/branding.js`.
Les réponses restent dirigées vers l'adresse automatique d'expédition.

Un administrateur renseigne, pour chaque école, le groupe et le contact du
service des admissions. Aucun domaine ni rattachement n'est déduit du campus.
Les trois profils démarrent en pause, avec des adresses vides ; les 19
rattachements et contacts sont à renseigner. Les domaines des tests utilisent
uniquement `example.invalid` et ne sont pas des valeurs de production.

Le serveur choisit l'expéditeur à partir de l'école. Une école sans groupe ou
sans contact ne peut pas prendre de bail d'envoi. Le nom et le logo de l'école
ou de son campus restent présents dans le corps du message.
Les campagnes et les lettres contiennent, en HTML et en texte :

> Ceci est un message automatique. Merci de ne pas répondre à cet e-mail.
> Pour toute information, veuillez écrire au service des admissions de votre
> établissement : [contact de l'école].

Chaque profil exige son propre test remis avant activation. Un message accepté
par l'API et un test remis pour l'autre profil ne suffisent pas. Le destinataire
du test est l'adresse confirmée du compte administrateur connecté ; aucune
adresse arbitraire n'est acceptée pour ce test.

L'identité d'expédition, la version du profil et le contact du service sont
figés sur le message au moment de sa réservation. L'autorisation est vérifiée
une nouvelle fois avant l'appel Brevo. Un changement de rattachement ou de
contact annule un envoi réservé devenu obsolète. Une nouvelle adresse ou un
nouveau nom d'expéditeur invalide son test précédent. Une rotation de la clé
commune ou une reconfiguration des retours impose de revalider les trois profils.
Un ancien retour de livraison ne valide pas une configuration remplacée.

Le plafond quotidien compte les trois groupes, les lettres, les tests et les
tentatives en cours ou incertaines. Les résultats ambigus restent à vérifier ;
aucune nouvelle tentative automatique n'est ajoutée.

## Changer le groupe depuis le front

La page **Connexion e-mail → Écoles et adresses de contact** présente les trois
profils dans chaque liste de sélection. L’administrateur choisit le nouveau
groupe, contrôle l’adresse automatique affichée et le contact du service,
puis enregistre. Le nom du troisième expéditeur est librement modifiable.

Le changement s’applique aux prochaines réservations de campagnes et de lettres.
Un message en attente prend le nouveau groupe ; une réservation en cours devenue
obsolète est annulée avant envoi, sans nouvelle émission automatique. Les messages
déjà acceptés ou remis conservent leur expéditeur enregistré. Les relations entre
écoles et campus, les permissions et les dossiers ne sont pas modifiés.
Si le profil choisi est en pause ou non validé, aucun autre expéditeur n’est utilisé.

## Fichiers à reprendre

| Fichier | Responsabilité |
| --- | --- |
| `supabase/migrations/20261019120000_mbn_mail_sender_groups.sql` | Profils, routes par école, autorisations, preuves de livraison et réservations atomiques |
| `supabase/functions/mbn-workspace/handler.ts` | Administration, choix du groupe, campagnes et pied de page des messages |
| `supabase/functions/mbn-letters/handler.ts` | Même routage pour les lettres et leurs pièces privées |
| `assets/workspace-ui.js`, `assets/workspace.css` | Trois profils, choix du groupe par école et aperçu de l’adresse automatique |
| `supabase/migrations/20261019130000_mbn_mail_third_sender.sql` | Ajout du troisième profil sans modifier les configurations existantes |
| `tests/workspace-database.test.ts`, `tests/workspace-brevo.test.ts` | Tests du routage, des contacts et de l'isolation des preuves |
| `CONNEXION_BREVO.md` | Procédure de configuration après validation du lot |

La migration est additive. Les anciens objets SQL sont conservés pour leurs
dépendances et l'historique ; les nouveaux chemins d'envoi utilisent les RPC
`mbn_mail_profile_*` et `mbn_letter_profile_action`. Les rôles navigateur ne
peuvent pas appeler directement ces RPC ni lire les tables de configuration.
La configuration de l'ancien expéditeur unique n'est plus proposée par l'API
HTTP d'enregistrement ou par l'interface.

## Reprendre la branche

```sh
git fetch origin
git switch --track origin/feature/brevo-multi-ecoles
npm ci --ignore-scripts
npm run check
```

Si la branche existe déjà localement, utiliser simplement
`git switch feature/brevo-multi-ecoles`.
La Pull Request permet d'examiner les changements et leurs contrôles avant
fusion. Aucune fusion dans `main`, mise à jour de Supabase, publication Netlify
ou émission de mail réel ne fait partie de cette livraison de code.
La migration, les deux fonctions serveur modifiées et le site doivent être
livrés ensemble dans l'environnement de validation lors de la mise en service.

## Validation et éléments encore nécessaires

Lors de la livraison initiale de ce lot : **162 tests réussis**, typage réussi et paquet statique
construit. Les contrôles couvrent les trois expéditeurs, leurs preuves de remise
séparées, le plafond commun et le changement de groupe d’une école. Ils vérifient
que les quatre écoles du profil commun gardent leur propre contact admissions,
que les messages déjà envoyés conservent leur identité et que les campus restent
inchangés. Un test suit deux écoles partageant une adresse jusqu’au JSON
Brevo et vérifie leurs deux noms affichés distincts. Les lettres vérifient
également le nom « Service admissions - école ». Les échanges Brevo sont simulés ; aucun e-mail réel n’a été envoyé.

Une vérification du front dans un DOM simulé a contrôlé les trois profils,
les 19 formulaires, le changement ESETH de MBN vers le profil commun et sa
persistance après rechargement, le renommage du groupe, le plafond et
l’aperçu bloqué d’une école sans groupe. La vérification visuelle dans un
navigateur reste à réaliser ; aucun moteur de navigateur n’est installé ici.
Les tests de base utilisent PGlite. Le [bloc installation](INSTALLATION_DEPLOIEMENT.md)
a depuis rétabli les migrations initiales et le catalogue dans le dépôt ; les tests
ne dépendent plus d’un schéma applicatif fourni uniquement comme fixture locale.

Pour mettre les envois en service, il reste à fournir et vérifier :

- Les trois adresses automatiques exactes et les noms des groupes d’expédition.
- Le rattachement confirmé des 19 écoles à ces trois groupes.
- Le contact réel du service des admissions pour chaque école.
- La clé API installée directement dans les secrets du serveur, les trois
  expéditeurs vérifiés et l'authentification de leurs domaines dans Brevo.
- L'autorisation de réaliser les tests réels, puis la réception de chaque test
  et le parcours complet « candidature → admission → lettre → remise ».

Le modèle national, les affectations, le redépôt, Meta, la réinstallation et
l’antivirus sont développés dans les blocs suivants. Voir le [guide de reprise](REPRISE_PROJET.md)
pour leur état et les essais réels restants. Les relances après clic restent sur
leur branche séparée et n’entrent pas dans la branche de finitions.
