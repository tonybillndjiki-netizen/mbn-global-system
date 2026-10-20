# Analyse antivirus des pièces candidates

Ce bloc ajoute une file d’analyse et un raccordement à **ClamAV**, via un adaptateur HTTPS hébergé par l’organisation. Aucun compte antivirus, serveur ou transfert de pièce réelle n’est créé par le développement. Le traitement démarre en pause ; les secrets et le moteur restent à installer et tester.

## Comportement

Toutes les pièces candidates déposées ou redéposées conservent leur stockage privé et leur empreinte. Elles passent de `NOT_SCANNED` à `SCANNING`, puis à `CLEAN`, `INFECTED` ou `ERROR`. Le verdict porte sur les octets exacts, leur taille et leur SHA-256. Une pièce remplacée ne transmet jamais son résultat à la nouvelle version.

Le téléchargement et une nouvelle approbation exigent `CLEAN`, affiché **Aucune menace détectée**. Une nouvelle transition vers dossier complet, prêt pour décision ou admis est bloquée si une pièce courante n’est pas analysée sans menace détectée. Les décisions et approbations historiques restent enregistrées, mais elles ne dispensent pas de l’analyse pour une nouvelle opération protégée. La mise en pause du traitement ne lève aucun blocage.

Les pièces bloquées restent dans le stockage privé, sans déplacement ni suppression automatique. Les admissions peuvent les refuser et demander un nouveau fichier par le parcours des pièces complémentaires. Un résultat propre permet la vérification humaine du contenu ; il ne valide pas automatiquement la pièce. Les détections heuristiques, fichiers chiffrés et dépassements de limites peuvent également entraîner un blocage. Aucun moteur ne garantit l’absence de toutes les menaces.

Les erreurs bénéficient de cinq tentatives au maximum, avec délais de 1, 2, 4 puis 8 minutes. Une récupération interrompue perd son bail après 90 secondes ; les résultats périmés sont ignorés. Après correction de la connexion, un administrateur peut reprendre une erreur avec sa révision actuelle. Une détection ne peut pas être transformée en résultat propre depuis l’interface.

## Installer le moteur et son adaptateur

Sur un hôte dédié administré par l’organisation :

1. Installer une version maintenue de ClamAV/`clamd` et son actualisation `freshclam`. Conserver les bases de signatures sur disque et vérifier leur actualisation. Le service et l’adaptateur doivent utiliser UTC.
2. Adapter la configuration au système à partir de `scanner/clamd.conf.example`, en conservant les options d’alerte sur fichiers chiffrés et limites dépassées. Configurer le socket Unix local `/run/clamav/clamd.sock` et donner à l’utilisateur de l’adaptateur l’accès nécessaire à ce socket. Le socket ClamAV reste local.
3. Définir `MBN_SCANNER_TOKEN`, secret aléatoire de 80 à 200 caractères base64url. Par exemple, générer une valeur avec `python3 -c 'import secrets; print(secrets.token_urlsafe(72))'`, puis la conserver dans le gestionnaire de secrets de l’hôte. Ne pas l’insérer dans un fichier suivi par Git.
4. Lancer `TZ=UTC python3 scanner/server.py` sous supervision de services. Il écoute uniquement sur `127.0.0.1:8080`. `CLAMD_SOCKET` permet de choisir le chemin du socket.
5. Placer un reverse proxy HTTPS devant `/v1/scan`, en limitant le corps à 5 Mio et les délais à environ 20 secondes. Ne pas journaliser le corps ni les en-têtes d’authentification ; limiter l’accès au service d’analyse. Garder les sauvegardes et journaux du serveur exempts de pièces candidates.

L’adaptateur ne reçoit aucun nom de candidat ni nom de fichier. Il transmet les octets en mémoire à `clamd` avec `INSTREAM` et renvoie uniquement le verdict, la version du moteur et l’empreinte. Il refuse une base de signatures âgée de plus de 48 heures, une réponse inconnue ou une erreur de moteur. Deux analyses simultanées au maximum sont admises. Les octets ne sont pas écrits dans un fichier temporaire par l’adaptateur.

Contrat HTTP : `POST /v1/scan`, `Authorization: Bearer <secret>`, corps binaire avec `Content-Length`. Une réponse réussie est de la forme suivante :

```json
{"status":"CLEAN","engine":"ClamAV <version>/<revision>","sha256":"<empreinte du corps>"}
```

Le second verdict possible est `INFECTED`. Un code d’erreur, une interruption, une réponse trop grande ou une empreinte différente produit une erreur de traitement, jamais un résultat propre.

## Raccorder Supabase

Installer la migration `20261020100000_mbn_document_antivirus.sql`, la fonction `mbn-antivirus` et le front correspondant. Le contrôleur de livraison inclut désormais cette neuvième fonction. Renseigner dans les secrets des fonctions :

| Secret | Valeur |
| --- | --- |
| `MBN_SCANNER_URL` | URL HTTPS exacte, par exemple `https://antivirus.votre-domaine.fr/v1/scan`, sans query string ni identifiant intégré |
| `MBN_SCANNER_TOKEN` | Même secret que celui de l’adaptateur |

Depuis **MBN CRM → Analyse antivirus**, contrôler l’état de connexion, les compteurs et les erreurs. La présence des secrets signifie seulement que la connexion est renseignée. Tester le moteur sur l’hôte avec un fichier inoffensif puis le fichier de test officiel EICAR, dans l’environnement de recette. Contrôler qu’une pièce non analysée ne se télécharge pas, que le résultat propre autorise la vérification et que la détection reste bloquée. Tester ensuite le redépôt d’une nouvelle version.

Activer le traitement automatique après cette recette. Le job `mbn-antivirus-due` appelle chaque minute la fonction avec le secret serveur existant, et traite au plus deux pièces par appel. Les anciens fichiers encore non analysés entrent aussi dans la file, à l’exception des versions remplacées. Le bouton **Traiter maintenant** utilise exactement le même parcours ; aucun bouton n’autorise à contourner le résultat.

## Vérifications et limites

Les tests locaux vérifient la liaison entre empreinte et verdict, le protocole de transmission, les permissions, les baux, les reprises, les versions remplacées et les blocages de téléchargement, validation et décision. Les services HTTP et le moteur sont simulés. Un test supplémentaire de socket Unix est exécuté en CI et explicitement ignoré si le runtime local interdit les sockets.

La connexion à un vrai moteur, le test EICAR, la mise à jour de ses signatures et la vérification de l’hébergement restent nécessaires. La reconstruction Docker complète de Supabase reste elle aussi à exécuter. Les annexes officielles installées par manifeste et les PDF générés ne sont pas des pièces candidates et ne passent pas dans cette file.

Références : [protocole officiel ClamAV](https://docs.clamav.net/manual/Usage/ClamdProtocol.html), [gestion des signatures](https://docs.clamav.net/manual/Usage/SignatureManagement.html), [fichier de test EICAR](https://www.eicar.org/download-anti-malware-testfile/).
