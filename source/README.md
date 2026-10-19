# Références du projet

Ce dossier contient les logos publics, les polices et leur licence, ainsi que le manifeste d’intégrité des documents utilisés par le serveur.

Les formulaires HTML sources des écoles, les modèles de courrier et les annexes bancaires ou contractuelles sont des références privées. Ils sont exclus du dépôt public par `.gitignore`. Les sept annexes nécessaires aux lettres sont installées dans le stockage privé Supabase ; leur accès passe par le serveur et les autorisations de l’école.

Les 19 formulaires actifs se trouvent dans `forms/`. Leurs tests et la construction du site fonctionnent sans les originaux privés. Pour régénérer ou réauditer ces formulaires, restaurer les originaux autorisés dans `source/forms/` ; ils restent ignorés par Git.
