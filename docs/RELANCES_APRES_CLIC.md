# Relances après clic confirmé

Ce lot traite le quatrième chantier de `elements a ajouter.pdf`. Il part du
commit `3fa3d36`, après les lots Brevo, affectations et pièces complémentaires,
sur la branche `feature/relances-apres-clic`. Ces lots restent à fusionner et à
installer ensemble dans l’environnement de validation.

## Définir le calendrier dans le front

Dans **MBN Mail → Après clic**, une personne disposant de l’autorisation
d’envoyer des campagnes pour une école peut :

1. Définir de une à trois relances, chacune avec un délai, un objet et un message.
2. Choisir des délais entiers et croissants, entre 1 et 21 jours après le clic
   confirmé. Un jour représente 24 heures écoulées ; il n’y a pas de calcul en
   jours ouvrés ni d’heure locale d’envoi imposée.
3. Vérifier l’aperçu et enregistrer le calendrier **en pause**.
4. Cliquer **Activer pour les prochains clics** lorsque le calendrier est validé.

Aucun calendrier n’est prérempli ni actif à l’installation. Les textes proposés
dans le formulaire restent des brouillons modifiables ; aucun délai métier
n’est déduit de la séquence d’invitation J0/J+2/J+4/J+6.

Modifier ou désactiver un calendrier annule ses relances encore en attente.
L’enregistrement conserve les messages déjà acceptés, leurs textes et leur
expéditeur. La réactivation s’applique aux prochains clics ; elle ne reprend pas
automatiquement les anciens contacts. Une version attendue protège les
modifications concurrentes. Les personnes sans autorisation peuvent consulter
les calendriers des écoles auxquelles elles ont accès.

## Déclenchement et arrêt

La confirmation explicite du lien de candidature, déjà présente dans le
parcours candidat, déclenche la nouvelle séquence. La lecture du message, les
retours de clic de Brevo et la simple consultation du lien ne la déclenchent pas.
Le premier clic confirmé est enregistré une seule fois.

Le prospect doit provenir de **Meta Lead Ads**, avoir un consentement e-mail
actif et appartenir à une campagne d’invitation existante de la même école.
Les contacts Messenger, les liens manuels hors campagne, les tests, les
personnes exclues et les candidatures déjà déposées ne sont pas inscrits.
Les clics antérieurs à l’activation ne sont pas repris.

Le clic confirmé annule uniquement les invitations restantes. Les nouvelles
relances partent de cette confirmation, avec les textes du calendrier figés
dans la file d’envoi. Une seule séquence après clic peut exister par prospect,
y compris après une annulation ou plusieurs confirmations du même lien.

Le dépôt d’une candidature, la désinscription, le retrait du consentement,
l’exclusion et la suppression de livraison arrêtent les envois. La validité du
lien, l’adresse destinataire, l’école, les autorisations de la campagne et du
calendrier sont vérifiées à nouveau au moment de la réservation et avant envoi.
La pause de la campagne bloque aussi ses relances.

Chaque relance est valable pendant les **24 heures suivant son échéance**,
au plus tard jusqu’à l’expiration du lien personnel. Une échéance dépassée
est annulée au prochain traitement ; aucun rattrapage groupé n’est envoyé
après une longue pause ou un quota épuisé. Les échéances placées après
l’expiration du lien ne sont pas créées. Le lien n’est jamais prolongé.

L’activation d’un calendrier n’envoie rien immédiatement. Le traitement
existant de la file, déclenché par le planificateur ou par l’administrateur,
prend les messages échus selon le groupe Brevo de l’école. Les trois profils,
leurs preuves de remise et le plafond quotidien commun restent applicables.
Le nom affiché reste **Service admissions - nom de l’école**. Le contact du
service, le lien de candidature et la désinscription sont ajoutés au message.
Une transmission déjà effectuée ne peut pas être retirée. Un résultat incertain
n’entraîne pas de nouvelle tentative automatique du même message.

## Fichiers et installation

- `20261019160000_mbn_clicked_followups.sql` : calendriers privés par école,
  permissions, versions, inscription unique et contrôles d’expédition.
- `assets/followups-ui.js` : liste des écoles, création du calendrier, aperçu,
  activation, désactivation et compteurs.
- `assets/workspace-ui.js` : onglet « Après clic » et événements du prospect.
- `mbn-workspace/handler.ts` : accès authentifié aux réglages, sans envoi lors
  de leur enregistrement.

Installer la migration, la fonction `mbn-workspace` et le site reconstruit,
après les migrations des lots précédents. Le parcours public conserve le même
point de confirmation ; aucune clé ni configuration Brevo n’est créée par ce lot.
Les tables privées et les nouvelles RPC restent inaccessibles aux rôles navigateur.

## Vérification

`npm run check` couvre notamment les délais à partir du clic, les permissions,
les calendriers vides ou périmés, la non-reprise des clics anciens, les pauses,
les exclusions, les liens courts ou révoqués, le quota commun, les réservations
invalidées par une modification et la conservation des trois expéditeurs.
Les échanges HTTP et Brevo utilisent des données synthétiques. Un DOM simulé
vérifie la saisie, l’aperçu et les actions du front.

La validation visuelle dans un navigateur et la réception réelle restent à
effectuer après installation et configuration. Ce lot ne fusionne pas `main`,
ne déploie aucun service et n’envoie aucun vrai e-mail.
