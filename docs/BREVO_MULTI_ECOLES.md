# Brevo : deux expéditeurs pour les 19 écoles

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

Deux profils sont créés : `MBN_GLOBAL` et `CAMPUS_INNOVATION_MLV`.
Ils utilisent une clé Brevo commune, un suivi de livraison commun et un plafond
quotidien commun. Le nom et l'adresse d'expédition sont propres à chaque profil.
Les réponses restent dirigées vers l'adresse automatique d'expédition.

Un administrateur renseigne, pour chaque école, le groupe et le contact du
service des admissions. Aucun domaine ni rattachement n'est déduit du campus.
Les deux profils démarrent en pause, avec des adresses vides ; les 19
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
commune ou une reconfiguration des retours impose de revalider les deux profils.
Un ancien retour de livraison ne valide pas une configuration remplacée.

Le plafond quotidien compte les deux groupes, les lettres, les tests et les
tentatives en cours ou incertaines. Les résultats ambigus restent à vérifier ;
aucune nouvelle tentative automatique n'est ajoutée.

## Fichiers à reprendre

| Fichier | Responsabilité |
| --- | --- |
| `supabase/migrations/20261019120000_mbn_mail_sender_groups.sql` | Profils, routes par école, autorisations, preuves de livraison et réservations atomiques |
| `supabase/functions/mbn-workspace/handler.ts` | Administration, choix du groupe, campagnes et pied de page des messages |
| `supabase/functions/mbn-letters/handler.ts` | Même routage pour les lettres et leurs pièces privées |
| `assets/workspace-ui.js`, `assets/workspace.css` | Deux profils, plafond commun et formulaire des 19 écoles |
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

`npm run check` : **157 tests réussis**, typage réussi et paquet statique
construit. Les 14 tests ajoutés couvrent les contacts HTML/texte, le choix
d'expéditeur pour les campagnes et lettres, l'accès administrateur, les preuves
séparées, les changements de configuration et le plafond commun.
Une vérification locale dans un DOM simulé a aussi contrôlé les deux profils,
les 19 formulaires d'école et les trois parcours d'enregistrement (expéditeur,
rattachement/contact et plafond). La vérification visuelle dans un navigateur
reste à réaliser ; le moteur de navigateur n'était pas disponible ici.
Les tests de base utilisent PGlite et le schéma initial de référence fourni par
le dépôt. La reconstitution des migrations initiales manquantes reste un
chantier distinct identifié dans le PDF du responsable.

Pour mettre les envois en service, il reste à fournir et vérifier :

- Les deux adresses automatiques exactes et leurs noms d'expéditeur.
- Le rattachement confirmé des 19 écoles à ces deux groupes.
- Le contact réel du service des admissions pour chaque école.
- La clé API installée directement dans les secrets du serveur, les deux
  expéditeurs vérifiés et l'authentification de leurs domaines dans Brevo.
- L'autorisation de réaliser les tests réels, puis la réception de chaque test
  et le parcours complet « candidature → admission → lettre → remise ».

Le modèle national, les affectations automatiques, le redépôt des pièces,
les relances après clic, Meta, la réinstallation complète et l'antivirus
restent à traiter suivant les autres chantiers du document du responsable.
