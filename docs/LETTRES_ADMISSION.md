# Lettres d’admission nationales et paramètres par école

## Comportement

Le type NATIONAL ou INTERNATIONAL du dossier détermine le modèle. Il n’est pas choisi à partir de la nationalité du candidat ni modifiable depuis l’éditeur de lettre.

Le modèle national possède son propre texte, sa notice et son e-mail. Il exclut les mentions de visa, Campus France, arrivée en France et AVI. Les annexes `visa_refusal`, `avi_attestation` et `rib_cameroun` sont refusées pour ce flux. Le texte national est une base proposée, à faire valider par la direction avant utilisation ; aucun modèle national officiel n’a été fourni dans le lot de référence consulté. Aucune signature électronique du candidat n’est intégrée par ce bloc.

Le modèle international conserve le texte du modèle existant, avec les paramètres désormais lus côté serveur.

## Configuration depuis le front

Dans **MBN CRM > Paramètres des lettres**, un administrateur choisit l’école et le type d’admission, puis renseigne :

- l’année académique et la rentrée ;
- la rentrée décalée pour l’international ;
- les frais d’inscription et l’acompte scolarité ;
- le délai de confirmation et le signataire ;
- la règle AVI pour l’international.

Les 19 écoles disposent de deux configurations distinctes, soit 38 configurations initialement vides et en pause. Aucun montant, signataire ou calendrier historique n’est adopté automatiquement. Les frais peuvent être nuls ; cela n’annonce pas la gratuité de la formation. Les valeurs s’appliquent aux nouvelles lettres de cette école et de ce type, pour l’ensemble de ses campus. Il s’agit d’un paramétrage de la rentrée courante, sans grille tarifaire par formation.

Après vérification des valeurs et du texte applicable, l’administrateur coche l’autorisation de génération et enregistre. Une modification concurrente est refusée et impose de recharger le formulaire. Chaque changement de configuration est historisé avec son auteur, les valeurs et sa révision.

## Préparer et envoyer

1. Ouvrir un dossier admis avec une formation et l’autorisation « envoyer les lettres ».
2. Consulter les paramètres de l’école ; renseigner ou corriger la date et le lieu de naissance, puis choisir l’identité visuelle autorisée.
3. Consulter et sélectionner les annexes applicables, avec un document de conditions générales. Aucun RIB n’est ajouté automatiquement. L’AVI obligatoire est ajoutée explicitement par la règle internationale enregistrée.
4. Générer et consulter l’aperçu PDF. Cette étape n’envoie pas de message.
5. Vérifier le texte, le candidat, la formation, la rentrée, les frais et toutes les annexes, puis cocher l’approbation et utiliser le bouton d’envoi.

Le serveur détermine les frais, le signataire, les rentrées, l’école, le campus et la formation. Le navigateur ne peut pas remplacer ces valeurs dans une requête de génération. Une modification du formulaire invalide l’approbation, y compris si elle intervient pendant la génération du PDF.

Les PDF et champs historiques sont conservés. Une modification de la configuration, de son activation ou du type d’admission après génération bloque l’envoi de l’ancien aperçu : générer et vérifier une nouvelle lettre. Les anciens aperçus créés avant cette migration restent téléchargeables mais doivent être régénérés avant un nouvel envoi. Une lettre déjà envoyée conserve ses valeurs et son historique ; aucun renvoi automatique n’est créé.

Le routage utilise les trois profils Brevo existants et le nom « Service admissions - nom de l’école ». L’approbation humaine, les autorisations, les contrôles d’intégrité des fichiers, le quota partagé, la prévention des doublons et la distinction ACCEPTED / DELIVERED restent applicables.

## Installation du lot

La branche `feature/lettres-nationales` est fondée sur `feature/pieces-complementaires`. Elle contient les blocs 1 à 3 et le présent bloc 5. Le bloc 4 « relances après clic » reste séparé et n’est pas publié par cette branche.

Après validation et dans l’environnement choisi pour les essais :

1. Appliquer les migrations précédentes, puis `20261019170000_mbn_national_letters_settings.sql`.
2. Installer la nouvelle version de `mbn-letters` et les assets du front issus de `npm run build`.
3. Vérifier la présence des polices, logos et annexes privées installés par le module existant.
4. Configurer et valider les paramètres de chaque école concernée.
5. Tester les deux types avec des dossiers de démonstration, puis la réception réelle uniquement lorsque Brevo est configuré et les envois autorisés.

Ce travail ne réalise aucune migration, installation ni modification de données sur l’environnement en ligne.

## Vérification effectuée

Les tests couvrent les deux modèles, les configurations vides ou désactivées, les frais nuls, les paramètres séparés par école et par type, les droits et sessions, les modifications concurrentes, les valeurs imposées côté serveur, les annexes nationales et l’invalidation d’un aperçu devenu obsolète. Un parcours national en base locale vérifie l’approbation, l’acceptation puis la remise simulée. Les appels d’envoi et notifications des tests sont simulés.

Les formulaires ont été exercés dans un DOM simulé : enregistrement, génération, changement de formulaire pendant la génération, approbation et envoi explicite. Les rendus PDF ont été inspectés avec les identités Campus Innovation et ESIIA, un nom long, des frais nuls et des frais positifs. La génération du modèle international a également été contrôlée. Le test d’usage dans un navigateur réel et la réception de vrais e-mails restent à réaliser après installation.
