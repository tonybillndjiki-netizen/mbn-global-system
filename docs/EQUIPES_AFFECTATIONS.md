# Équipes et affectations des admissions

Ce lot complète le deuxième chantier de « elements a ajouter.pdf ». Le moteur
d’affectation existait ; la répartition réelle des équipes reste à faire valider.
Aucun nom de responsable, compte, règle réelle ou affectation de production
n’est créé par la migration.

## Utilisation

Depuis **MBN CRM > Règles d’affectation**, un administrateur dispose de :

- Un suivi des 19 écoles, des règles actives et des dossiers ouverts sans responsable.
- Des listes de campus et de formations limitées à l’école choisie.
- Des collaborateurs dont le compte est confirmé, actif et autorisé pour cette école
  avec un rôle Admissions ou Direction ; le principal et son suppléant sont distincts.
- La création, la modification, la mise en pause et la réactivation des règles.
- Un aperçu des affectations proposées pour les dossiers encore sans responsable.

Une règle générale laisse campus, formation et rentrée vides. Des règles plus
précises peuvent compléter cette règle. La rentrée reste un texte à faire
correspondre au libellé de la candidature ; sa centralisation relève du chantier
des paramètres par école. La priorité est comprise entre 0 et 1000.

Le moteur conserve l’ordre existant : nombre de critères renseignés, puis priorité
décroissante, puis ancienneté et identifiant. Le titulaire est retenu s’il est
encore autorisé, sinon son suppléant. Si les deux sont indisponibles, le dossier
reste à vérifier. Il ne passe pas automatiquement à une équipe d’une règle moins
précise. Une règle générale prête n’atteste pas que toutes les exceptions sont prêtes.

Les groupes d’expédition Brevo restent indépendants de ces règles d’affectation.
Deux écoles situées sur un même campus gardent leurs responsables et leurs droits.

## Dossiers déjà reçus

Enregistrer une règle ne réattribue pas les anciens dossiers. Cliquer
**Vérifier les dossiers sans responsable**, examiner la liste, conserver les
propositions souhaitées puis cliquer **Appliquer les affectations**.

Le serveur limite chaque aperçu à 200 dossiers, en donnant la priorité aux
propositions applicables. Seuls les dossiers réels, dans une école active, ouverts
et encore sans responsable sont concernés. Les dossiers de test, clôturés, refusés,
inscrits ou déjà attribués sont exclus.

Chaque proposition est recalculée avant application. Un changement de règle, de
responsable autorisé, de dossier ou une affectation manuelle invalide l’ancienne
proposition. Le traitement ignore alors cette ligne et conserve son état actuel.
Une action répétée ne réattribue pas le même dossier. Les affectations appliquées
enregistrent l’acteur et la règle dans l’historique du dossier. Aucun e-mail n’est
envoyé par ces opérations.

## Répartition à obtenir

Pour chaque école et éventuelle exception, faire valider par la direction ou le
responsable admissions :

| Information | Utilisation |
| --- | --- |
| École | Périmètre de la règle |
| Campus, si différent selon le site | Exception à la règle générale |
| Formation ou rentrée, si nécessaire | Critères supplémentaires |
| Responsable principal et son compte professionnel | Attribution normale |
| Suppléant éventuel et son compte professionnel | Relais si le principal perd son accès actif |

Les comptes et leurs accès se configurent dans **Équipes**. Les données réelles
sont ensuite choisies dans l’application ; elles ne sont pas insérées dans GitHub.

## Livraison et validation

La branche `feature/equipes-affectations` part de `18ac797`, dernière version du lot
Brevo sur `feature/brevo-multi-ecoles`. Elle inclut ce lot non fusionné. Pour examiner
uniquement les affectations, comparer ces deux branches. `main` reste inchangé.

Livrer ensemble la migration additive
`20261019140000_mbn_admission_routing_admin.sql`, la fonction `mbn-workspace` et
les fichiers publics construits. Les nouveaux RPC restent limités au rôle serveur,
avec vérification de la session administrateur et des droits par école.

**176 tests passent**, ainsi que le typage et la construction. `npm run check` contrôle les migrations dans PGlite, les services HTTP, le typage
et la construction. Les cas d’affectation couvrent la priorité des critères,
le suppléant, les droits, les règles modifiées, les aperçus périmés, les affectations
manuelles, les dossiers exclus et l’absence d’appel au fournisseur d’e-mails.
Les tests utilisent uniquement des données synthétiques.
Un contrôle du front dans un DOM simulé vérifie les 19 écoles, les listes limitées
à l’école choisie, le principal et le suppléant distincts, la création, la modification,
la pause et l’application d’une seule proposition sélectionnée. Un ancien choix de
formation devenu indisponible reste visible et doit être corrigé explicitement.

La vérification en navigateur et la validation de la répartition réelle restent
nécessaires après installation dans l’environnement de validation. Aucune fusion,
installation distante, publication Netlify ou modification de données réelles
n’est effectuée dans cette livraison de code.
