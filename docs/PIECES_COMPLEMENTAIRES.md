# Demandes de pièces complémentaires et redépôt

Ce lot traite le troisième chantier de « elements a ajouter.pdf » : demander par
e-mail les pièces absentes ou à remplacer, puis permettre leur nouveau dépôt.
Il part du commit `265293c`, sur la branche `feature/pieces-complementaires`,
et inclut les lots Brevo et affectations non encore fusionnés dans `main`.

## Parcours des admissions

1. Ouvrir le dossier dans **MBN CRM** et vérifier les pièces reçues.
2. Cliquer **Demandes de pièces complémentaires**. Sélectionner les pièces et
   écrire pour chacune un motif destiné au candidat. Les pièces validées sont
   conservées ; une pièce validée doit être réexaminée avant une demande de remplacement.
3. Cliquer **Préparer la demande**. Le dossier passe à **Pièces manquantes**.
   Cette opération enregistre la demande sans envoyer d’e-mail.
4. Vérifier les motifs affichés, puis cliquer **Envoyer par e-mail**.
5. Suivre l’acceptation et la livraison dans la file d’envoi et dans la demande.

Un compte doit disposer du droit de vérification des pièces pour préparer,
envoyer ou annuler une demande, dans le périmètre de son école. Les dossiers
de test, les candidats exclus et les dossiers ayant quitté la phase de vérification
ne permettent pas cette demande. Aucune répartition de personnel n’est présumée.

## Expéditeur et livraison

Le nom visible reste **Service admissions - nom de l’école**. L’adresse et le
contact proviennent du groupe d’expédition et de la configuration de l’école.
Le message contient les motifs, un bouton de dépôt et la date d’expiration du
lien personnel. Le contact admissions et la mention de message automatique
restent présents.

Cette notification concerne le dossier en cours ; elle ne requiert pas le
consentement aux campagnes marketing. Une exclusion de livraison, un rejet
permanent ou une plainte enregistrée bloque toutefois l’envoi. La clé Brevo,
le test remis propre à l’expéditeur, son activation et le plafond quotidien
commun continuent de s’appliquer.

L’envoi est explicite, sans programmation de relance automatique. Une seule
tentative est réservée par demande ; un résultat incertain ne déclenche jamais
un renvoi automatique. Vérifier le résultat avant d’annuler le lien et de préparer
éventuellement une autre demande. Une annulation révoque le lien ; elle ne retire
pas un e-mail déjà transmis. Les retours Brevo existants suivent la remise.

## Parcours du candidat

Le bouton ouvre `documents.html` avec une capacité signée dédiée. Le lien expire
au bout de 14 jours, ne fonctionne que pour la demande concernée et devient
inutilisable après annulation. Il est distinct des liens de candidature et de
désinscription. La page n’affiche que l’école, la référence et les motifs à traiter,
sans accès aux anciens fichiers ni aux notes internes de vérification.

Le candidat joint toutes les pièces demandées, sans modifier son identité,
son école, sa formation ou ses pièces déjà validées. PDF, JPEG et PNG sont acceptés,
dans la limite de 5 Mo par fichier et 20 Mo au total. Le serveur vérifie le contenu,
le format et l’empreinte. Après interruption, reprendre avec les mêmes fichiers.
Un accusé de réception à l’écran confirme l’enregistrement ; aucune confirmation
par e-mail supplémentaire n’est générée.

Les nouvelles pièces restent **À vérifier** et le dossier passe à
**Pièces à vérifier**. Les anciennes versions sont conservées dans le stockage
privé et dans un historique réservé aux personnes autorisées. Une ancienne
version ne peut plus être validée. Le dossier ne passe pas automatiquement à
complet ou admis après le dépôt.

## Protections et reprise

- Une seule demande ouverte par dossier ; cinq créations au maximum par jour.
- Demande et dossier sont vérifiés à nouveau avant envoi et avant validation du dépôt.
- Les pièces non demandées, les liens expirés, les substitutions de dossier et
  les contenus différents sous une même réservation sont refusés.
- Le dépôt atomique conserve la précédente version jusqu’à la présence de tous
  les nouveaux fichiers. Une reprise reconnue ne crée pas de doublon.
- Les nouvelles tables et RPC sont réservées au serveur ; les rôles navigateur
  n’obtiennent aucun accès direct au stockage privé.
- Les documents restent marqués `NOT_SCANNED` : l’analyse antivirus demeure
  un chantier distinct du document du responsable.

## Livraison et vérification

Installer ensemble la migration additive `20261019150000_mbn_document_corrections.sql`,
les fonctions `mbn-workspace` et `mbn-admissions` avec leur parseur partagé, et le
site construit comprenant `documents.html` et les nouveaux modules JavaScript.
Les migrations des lots précédents sont nécessaires.

`npm run check` vérifie le parcours dans PGlite, les services HTTP, le typage et
le paquet statique. Les tests utilisent des comptes, fichiers et échanges Brevo
synthétiques. Le front est contrôlé dans un DOM simulé, côté admissions et côté
candidat. La vérification visuelle en navigateur, l’installation en environnement
de validation et la réception réelle des e-mails restent à effectuer.

Ce lot de code n’installe aucune clé API, ne modifie aucune donnée distante,
ne fusionne pas `main`, ne déploie pas le site et n’envoie aucun e-mail réel.
