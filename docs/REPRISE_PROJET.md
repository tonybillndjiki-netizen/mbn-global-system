# Reprendre MBN GLOBAL Mail et CRM

Cette version réunit les huit chantiers du dépôt Supabase/Brevo. Les branches
historiques restent consultables ; le code courant contient les expéditeurs,
les affectations, les compléments, les relances après clic, les lettres,
Meta, l’installation et l’antivirus. Pour identifier une copie, utiliser
`git rev-parse HEAD` puis comparer ce commit à la livraison et à sa CI.

## Reprendre le développement

Node 24.19.0 et Python 3.12 sont requis :

```sh
npm ci --ignore-scripts
npm run check
```

Le contrôle reconstruit la base locale de tests depuis toutes les migrations,
vérifie les services et les interfaces, TypeScript, puis construit le ZIP
public Netlify. Le job GitHub Actions `fresh-installation` reconstruit aussi
une pile Supabase jetable avec Docker. Aucun de ces contrôles ne valide un
compte réel Brevo, Meta ou ClamAV.

## État des huit chantiers

| Chantier | Code intégré | Paramétrage ou recette restante |
| --- | --- | --- |
| Expéditeurs | Trois groupes, contacts par école, plafond commun et traitement alterné | Adresses vérifiées, retours et tests de remise pour chaque groupe |
| Affectations | Principal, suppléant, exceptions et reprise après aperçu | Répartition réelle et droits des collaborateurs |
| Pièces complémentaires | Demande, e-mail, lien personnel et historique des versions | Essai réel de demande et de redépôt |
| Après clic | Calendrier par école et arrêt au dépôt, retrait ou expiration | Délais et messages approuvés ; activation explicite |
| Lettres | Modèles national/international, paramètres par école, aperçu et approbation | Texte national, frais, signataires, rentrées, AVI et annexes validés |
| Meta | Notification signée, récupération, rattachement et déduplication | Application, pages, formulaires, accès et consentement |
| Installation | Base initiale, catalogue, environnements et contrôleur de livraison | Cibles, secrets et réconciliation de l’historique existant |
| Antivirus | File d’analyse, adaptateur ClamAV et blocages métier | Hébergement du moteur, signatures et essai de détection |

La validation d’un expéditeur est indépendante des deux autres. Le traitement
des campagnes prend un message de chaque groupe prêt par tour. Les résultats
incertains restent à vérifier avant toute répétition.

## Installer et valider

1. Consulter [INSTALLATION_DEPLOIEMENT.md](INSTALLATION_DEPLOIEMENT.md). La base
   historique a des identifiants de migrations différents : comparer le schéma
   et l’historique avant une livraison, sans réparation automatique ni remise
   à zéro de la base distante.
2. Installer la version complète dans une cible de recette séparée. Restaurer
   les originaux privés via leur manifeste et configurer les services.
3. Renseigner les paramètres métiers avec Tony et les responsables concernés.
   Aucun tarif, signataire, expéditeur ou responsable n’est déduit d’un exemple.
4. Exécuter [RECETTE.md](RECETTE.md) en navigateur et avec les services réels,
   puis conserver les résultats et les preuves dans l’espace interne.
5. Activer uniquement les groupes et les parcours validés. Une publication de
   code sur GitHub ne prouve pas sa livraison ni la réception d’un e-mail.

L’antivirus démarre en pause mais sa migration bloque les nouvelles opérations
sur les pièces non analysées. Raccorder et tester le moteur dans la recette
avant de livrer cette migration en production. Les trois groupes Brevo,
les paramètres de lettres et les calendriers ne sont pas activés implicitement.
