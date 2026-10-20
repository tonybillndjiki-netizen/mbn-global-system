# Connexion directe des prospects Meta

## Ce que fait ce bloc

Les nouvelles réponses aux formulaires Lead Ads de Meta peuvent arriver dans le carnet de prospects sans import CSV. Une notification signée ne contient ici que les identifiants utiles : la page, le formulaire et la fiche. Le service enregistre ces identifiants, puis un traitement séparé récupère la fiche auprès de Meta.

Chaque formulaire possède un rattachement explicite à une école, éventuellement à un campus et une formation. Aucune école n’est déduite du nom, de l’adresse e-mail du prospect ou d’un champ arbitraire du formulaire.

L’import crée un prospect, sans créer de dossier de candidature ni lancer de campagne e-mail. Le mécanisme existant de lancement des campagnes reste distinct. Les trois profils Brevo, leurs rattachements par école et le nom « Service admissions - nom de l’école » restent utilisés lors des envois ultérieurs.

Ce bloc traite les réponses aux formulaires Lead Ads. Il ne récupère pas les conversations Messenger et ne relit pas automatiquement les anciennes fiches avant l’installation. L’import CSV existant reste disponible.

## Paramétrage dans l’interface

Un administrateur ouvre **MBN Mail > Connexion Meta**, puis « Rattacher un formulaire » :

1. Nommer le formulaire et renseigner ses identifiants de page et de formulaire Meta.
2. Choisir l’école ; choisir un campus et une formation si ces informations sont connues pour ce formulaire.
3. Vérifier les noms des champs transmis par Meta : nom, e-mail, téléphone et pays. Les deux derniers sont facultatifs. Avec le champ `full_name`, un nom absent peut être reconstitué à partir de `first_name` et `last_name`.
4. Si le formulaire collecte un accord aux e-mails, renseigner le nom du champ, la valeur exacte qui signifie l’accord et le texte effectivement présenté au candidat. Sinon, laisser les trois champs vides.
5. Enregistrer d’abord en pause, puis activer après vérification du formulaire et des accès Meta.

Plusieurs formulaires d’une même page peuvent viser des écoles différentes. Un formulaire ne peut avoir qu’un rattachement. Les jetons d’accès ne sont jamais saisis ni renvoyés dans cet écran ; l’interface indique seulement si l’accès à la page est installé côté serveur.

Un formulaire inconnu conserve ses notifications « à rattacher ». Enregistrer son rattachement les remet en attente, sans attribuer arbitrairement une école. Les modifications de rattachement s’appliquent aux prochaines récupérations des notifications encore en attente ; les prospects déjà créés ne sont pas déplacés. Une modification pendant une récupération invalide son résultat et impose une reprise.

## Consentement et doublons

La soumission d’un formulaire ne donne pas automatiquement un consentement aux campagnes e-mail. L’accord doit correspondre à un champ configuré, à une seule valeur explicite et au texte de preuve enregistré. La réponse, le formulaire, le texte et la date Meta sont conservés dans une preuve privée. Une réponse absente ou ambiguë laisse le consentement à faux.

Une notification répétée ne crée pas de nouveau traitement. Une fiche Meta déjà utilisée ou une adresse e-mail déjà présente dans la même école ne remplace pas un prospect existant. Son identité, son consentement et son historique sont conservés. Si plusieurs prospects partagent déjà cette adresse, le traitement signale un doublon sans fusionner leurs identités.

Un identifiant Meta déjà utilisé pour une autre école ou un prospect de test est bloqué pour vérification. Une désinscription ou une suppression d’envoi connue pour la même adresse reste respectée lors de la création d’un prospect dans une autre école. Une fiche sans nom ou e-mail utilisable reste en erreur ; aucune adresse fictive n’est créée.

## Installation technique à effectuer

Le code est préparé ; aucun compte, application, page ou formulaire Meta n’a été connecté pendant ce développement.

La personne qui administre Meta doit confirmer l’application à utiliser, les pages, les formulaires et les autorisations nécessaires pour la récupération des prospects. Suivre les instructions officielles propres à l’application et à son mode d’accès :

- [Récupérer les prospects Lead Ads](https://developers.facebook.com/documentation/ads-commerce/marketing-api/guides/lead-ads/retrieving)
- [Notifications de formulaires Leadgen](https://developers.facebook.com/docs/graph-api/webhooks/getting-started/webhooks-for-leadgen/)
- [Vérification et signature des notifications Meta](https://developers.facebook.com/docs/graph-api/webhooks/getting-started/)

Les secrets suivants sont à installer directement dans Supabase, sans les copier dans la conversation, le navigateur ou Git :

| Secret | Contenu |
| --- | --- |
| `MBN_META_APP_SECRET` | Secret de l’application Meta autorisée |
| `MBN_META_VERIFY_TOKEN` | Jeton de vérification choisi pour le callback, entre 16 et 256 caractères |
| `MBN_META_GRAPH_VERSION` | Version Graph prise en charge par l’application, au format `vNN.0` ; aucune version n’est choisie automatiquement |
| `MBN_META_PAGE_TOKENS` | Objet JSON associant chaque identifiant de page à son jeton autorisé : `{"ID_PAGE":"JETON_PAGE"}` |

Installer ensuite la migration `20261020080000_mbn_meta_leads.sql`, la fonction `mbn-meta` et le front construit. La fonction doit accepter les appels Meta sans JWT Supabase : elle contrôle elle-même la signature des notifications, les sessions administrateur et le secret du traitement planifié. Par exemple, dans l’environnement de validation choisi :

```sh
supabase functions deploy mbn-meta --no-verify-jwt
npm run build
```

Après installation seulement, déclarer comme callback Meta :

```text
https://ppqeuluykiknuujfaoid.supabase.co/functions/v1/mbn-meta
```

Associer le jeton de vérification correspondant, puis activer l’abonnement aux notifications `leadgen` des pages/formulaires autorisés selon la procédure Meta. Ce bloc ne modifie pas les abonnements de vos pages à distance.

## Traitement, reprises et diagnostic

La signature HMAC SHA-256 porte sur les octets reçus, avant lecture du JSON. Les identifiants de la fiche et du formulaire renvoyés par Graph doivent correspondre à la notification. Les requêtes Graph utilisent un hôte fixe, sans redirection, un jeton en en-tête et une preuve calculée avec le secret de l’application. Le contenu brut des erreurs du fournisseur et les jetons ne sont pas affichés ni inscrits dans les diagnostics.

La file ne récupère des fiches que pour des rattachements actifs dont l’école et le catalogue restent valides. Les erreurs temporaires sont reprises avec délai, jusqu’à cinq tentatives. Une récupération interrompue peut être reprise après expiration de son bail ; un ancien résultat ne peut alors plus créer de prospect. Les erreurs d’accès demandent une correction puis une reprise explicite dans l’interface.

Un traitement planifié par minute est enregistré si `pg_cron` et `pg_net` sont déjà installés. Il ne sollicite la fonction que lorsque des notifications actives sont dues. Vérifier ce planificateur dans l’environnement de validation ; en son absence, l’administrateur peut utiliser « Traiter les notifications en attente ». Cette action lit les fiches Meta mais n’envoie pas d’e-mail.

L’écran présente les compteurs réels et les 50 dernières notifications : en attente, formulaire à rattacher, reprise prévue, erreur, prospect créé ou doublon. Il ne reçoit pas les données personnelles brutes des fiches Meta. Un administrateur peut ensuite ouvrir le prospect via le contrôle d’accès CRM existant.

## Validation effectuée et validation réelle restante

Les tests locaux couvrent la signature et sa falsification, la validation du callback, l’absence de configuration, les permissions, le routage école/campus/formation, les champs personnalisés, le consentement absent ou ambigu, les doublons, les désinscriptions, les changements de configuration en cours de traitement, les reprises, les erreurs Graph et l’intégrité des identifiants. Leurs appels Meta sont simulés. Les formulaires ont été exercés dans un DOM simulé, sans appel externe.

Il reste à installer le bloc dans l’environnement choisi, tester l’interface dans un navigateur réel et soumettre une fiche de démonstration depuis Meta. Vérifier son école, ses coordonnées, son consentement, son historique et le traitement d’une notification répétée. La réception d’une notification et la récupération d’une fiche doivent être confirmées séparément. Aucun test réel Meta ni déploiement n’est réalisé par le développement de ce lot.

La branche `feature/meta-leads` reprend le contenu du bloc 5. Le bloc 4 « relances après clic » reste séparé et n’est pas inclus dans cette branche.
