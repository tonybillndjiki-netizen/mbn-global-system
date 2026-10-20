# Recette de validation MBN GLOBAL

Cette grille prépare les essais réels du parcours demandé dans le document de référence. Les tests locaux passent sur des données synthétiques ; ils ne constituent pas une validation avec les comptes Brevo, Meta ou un moteur antivirus réel. Les écrans sont exercés dans un DOM simulé ; la vérification visuelle dans un vrai navigateur reste à effectuer.

## Relevé des vérifications automatisées

`npm run check` couvre la base PGlite reconstruite depuis toutes les migrations, le catalogue, les services HTTP, les permissions, les pièces et versions, l’antivirus, les paramètres de lettres, Meta, les interfaces de ces modules, les garde-fous de livraison, le typage et le paquet Netlify.

Un test métier parcourt sur un même dossier : réservation des pièces, dépôt atomique, résultats antivirus simulés, vérification, admission, lettre générée, approbation explicite, acceptation puis notification de remise corrélée. Les métadonnées Storage et les réponses des services sont simulées. Le PDF et les adaptateurs HTTP disposent aussi de leurs propres tests.

La reconstruction Docker de Supabase et le test de socket Unix sont prévus en CI. Le runtime de préparation ne fournit pas Docker et interdit les sockets Unix : ce dernier test est explicitement ignoré localement, sans ignorer les tests de protocole en mémoire.

## Compte rendu à remplir dans l’espace interne

Renseigner l’environnement, le commit exact, la date, le nom du vérificateur et le résultat de chaque ligne : **réussi**, **échoué** ou **bloqué**, avec la preuve et l’action restante. Utiliser seulement des comptes et fichiers de démonstration autorisés. Ne pas joindre de clé, jeton, lien personnel complet ou pièce d’identité au dépôt public.

| Cas | Manipulation en recette | Résultat attendu | État réel à ce stade |
| --- | --- | --- | --- |
| Installation | Reconstruire une pile Supabase locale vierge | 19 écoles, 1 275 formations inactives, aucun propriétaire ou envoi préinstallé | À exécuter avec Docker/CI |
| Mauvaise cible | Présenter au précontrôle une origine qui ne correspond pas au site choisi | Arrêt avant les migrations et la publication | Couvert localement, essai d’environnement à faire |
| Base historique | Lire et comparer l’historique hébergé avec les migrations | Écart identifié, aucune réparation automatique | Réconciliation à préparer avant livraison |
| Premier accès | Créer et confirmer le propriétaire, configurer Mon accès | Connexion personnelle ; ancien accès révoqué après changement | À tester sur la cible |
| Accès restreint | Se connecter avec un collaborateur limité à une seule école | Les autres écoles, pièces et actions restent inaccessibles | À tester en navigateur |
| Trois expéditeurs | Renseigner puis vérifier chaque adresse et son groupe | Rattachements explicites des écoles et aucun groupe activé sans sa propre preuve de remise | Adresses et groupes à valider |
| Test e-mail | Envoyer un test autorisé de chaque groupe et attendre son retour | Destinataire correct, nom Service admissions - école, bonne identité de campus et contact admissions | Brevo réel à configurer |
| Affectation | Créer une règle générale et une exception, puis prévisualiser un dossier sans responsable | Principal ou suppléant autorisé ; application uniquement des lignes choisies | Répartition réelle à fournir |
| Meta | Soumettre une fiche de démonstration depuis un formulaire autorisé | Notification signée reçue puis récupération de la bonne fiche et de la bonne école | Compte et accès Meta à configurer |
| Doublon et consentement | Répéter une notification ; essayer sans accord explicite et après désinscription | Pas de doublon, pas de consentement inventé ou restauré | À vérifier depuis Meta |
| Invitation | Ouvrir un lien, puis confirmer Continuer ma candidature | Une simple ouverture ne confirme pas le clic ; la confirmation arrête les invitations restantes | À tester en navigateur |
| Dépôt | Déposer PDF/PNG/JPEG autorisés, interrompre puis reprendre | Pas de dossier final avant toutes les pièces ; reprise sans doublon | À tester en navigateur |
| Analyse en attente | Consulter une pièce avant son résultat | Téléchargement et approbation refusés ; statut d’attente visible | Moteur à raccorder |
| Moteur réel | Contrôler un fichier inoffensif et le fichier de test officiel de détection sur l’hôte | Résultat propre puis blocage de détection ; versions des signatures connues | À faire avec ClamAV réel |
| Panne antivirus | Interrompre l’accès au moteur puis rétablir sa connexion | Erreur, reprises bornées, aucun faux résultat propre | À tester sur la cible |
| Vérification | Analyser un dossier sans menace puis vérifier chaque pièce obligatoire | Analyse et approbation humaine distinctes ; dossier complet seulement après les deux | À tester avec Admissions |
| Redépôt | Refuser une pièce, envoyer la demande puis déposer son remplacement | Seule la pièce demandée est remplacée ; ancienne version conservée ; nouvelle analyse et vérification exigées | E-mail et navigateur à tester |
| Admission | Faire passer le dossier complet en décision avec un compte autorisé | Motif enregistré ; refus des comptes sans droit de décision | À valider avec Admissions |
| Lettre nationale | Renseigner les paramètres nationaux et préparer son aperçu | École, formation, frais et signataire exacts ; aucune mention de visa ou AVI | Texte à approuver par la direction |
| Lettre internationale | Choisir la règle AVI approuvée et les annexes applicables | Identité du campus correcte ; annexes privées présentes et cohérentes | Règle et originaux à valider |
| Approbation de lettre | Modifier le formulaire ou les paramètres après aperçu | Ancien aperçu non envoyable ; nouvel aperçu et nouvelle approbation nécessaires | À tester en navigateur |
| Remise | Envoyer une lettre approuvée à une adresse de démonstration autorisée | Acceptation puis remise distinctes, corrélées au bon message et destinataire | À confirmer dans Brevo et la boîte destinataire |
| Exclusions | Retirer le consentement ou simuler une plainte dans l’environnement de test du fournisseur | Arrêt des campagnes, aucun rétablissement par un nouvel import | À contrôler avec Brevo |
| Après clic | Configurer un calendrier après clic puis confirmer un lien de démonstration | Aucune activation ni reprise d’anciens contacts sans calendrier approuvé | Intégré ; tests synthétiques réussis, réception réelle à tester |
| Navigation | Vérifier ordinateur et mobile, clavier, ouverture et fermeture des fenêtres | Libellés Brevo cohérents, erreurs lisibles, boutons indisponibles explicites et aucun débordement | Revue visuelle à faire |

Une ligne bloquée empêche la validation du parcours qu’elle protège. Le compte rendu final doit distinguer le développement terminé, le paramétrage terminé et la recette réelle réussie. La remise d’une seule lettre de démonstration ne valide pas automatiquement les paramètres des 19 écoles.
