-- Generated from the 19 committed active forms by scripts/export_catalog.mjs.
-- Programs start inactive; existing rows and activation decisions are preserved.
with source as (select * from jsonb_to_recordset($mbn_catalog$[
  {
    "id": "0011218e-6f20-52c9-a057-e83a11ec6fba",
    "school_code": "EMSP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastères Managements de Projets et de l'Innovation",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "0033a771-e9d2-5d43-8af9-dfdd1812ef56",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Start-up and Business Development",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "004e5ed1-8ad7-5721-a535-0f14a14e7bd0",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Intercultural Risk Management",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "0069b6db-3da3-5880-9324-7089d91539a7",
    "school_code": "ISMOD",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Mode-Innovation",
    "name": "Bachelor Mode et Entrepreneuriat",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "00704850-9d73-5d03-b667-ffc074f657a9",
    "school_code": "LSB",
    "cycle": "Masteres",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère Management de projrts et de l'innovation (MPI)",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "008a5784-e75c-5dbd-b1fb-8d9a5eb45513",
    "school_code": "ESUV",
    "cycle": "Mastères",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Management et Digitalisation des Processus Achat et Logistique(MD-AL)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "00a057f8-0a00-5a2d-a969-b34c37468644",
    "school_code": "ESMEP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "MANAGEMENT ET GESTION",
    "name": "MASTÈRE EN MANAGEMENT DEVELOPPEMENT DURABLE ET RSE",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "010d18d6-5550-5709-a9ba-d2db2d69e8ff",
    "school_code": "ILMIS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Finance de Marché et Management des Risques",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "012edf8e-feac-53c6-ad71-eaa1c71815bc",
    "school_code": "LSB",
    "cycle": "Masteres",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère entrepreneuriat & business development",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "013e1e68-5926-58cb-a82d-3f617fcbdeb4",
    "school_code": "ESMAS",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "Master's Degree in Project and Innovation Management",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "01a7a589-10b8-5fe5-b5c8-5010127f4a3c",
    "school_code": "ISMOD",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Communication-Vente",
    "name": "Bachelor Négociation-Vente",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "01f2e324-9318-513f-8ea5-61ecc7f0f385",
    "school_code": "ESMEP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "MASTER'S DEGREE IN HUMAN RESOURCES AND DIGITALISATION OF OPERATIONS",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "01f58f96-fffc-51dd-8a9e-b5e765f8a5be",
    "school_code": "ESEA",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "MANAGEMENT ET GESTION",
    "name": "MASTÈRE MANAGEMENT ET GESTION DES ENTREPRISES",
    "source_file": "forms/esea.html"
  },
  {
    "id": "0218d2a2-cb07-557c-ac17-3a8de8084ad8",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Start-up and Business Development",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "0238cd51-c99c-52a3-85a2-cdeb74344916",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Management et Gestion",
    "name": "Bachelor Achats et Logistique",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "024acc12-fc1d-533b-8e12-a550b8eba6f6",
    "school_code": "CESCOM",
    "cycle": "BTS (BAC+2)",
    "academic_level": null,
    "domain": "COMMERCE-VENTE",
    "name": "BTS Négociation et Digitalisation de la Relation Client (NDRC)",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "0261ee13-d0ec-5db1-82dd-1be3082778fd",
    "school_code": "ISMOD",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "Bachelor in Fashion and Luxury",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "02e27bbe-ebc7-5dd3-8bbf-9230e7c6b295",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "Bachelor's Degree in Brand Management and Branding",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "02fef2d0-770a-5d40-8ef8-6f403d7d4348",
    "school_code": "ISMOD",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Communication-Vente",
    "name": "Mastère Fashion Business",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "031bc4be-1d9f-5df4-b25b-d0e9b9e21247",
    "school_code": "ESMOSS",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "MANAGEMENT-GESTION",
    "name": "Bachelor Gestion de la Santé et de la Transformation Numerique (GST)",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "033ee900-0557-5611-b622-4101e9a64609",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN IN ORGANISATIONAL MANAGEMENT",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "03ccabd1-ee7c-533f-b692-780ab4d17a19",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Start-up and Business Development",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "03ee375d-11ae-51df-8d59-6dd5957497ef",
    "school_code": "EVRY BS",
    "cycle": "NIVEAU BAC",
    "academic_level": null,
    "domain": "niveau bac",
    "name": "TP assistant manager d'unité marchande (AMUM)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "040e64f3-1c88-59b8-8fdd-d0190ba88747",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Management et Gestion",
    "name": "Bachelor Ressources Humaines",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "04442a41-87b0-5d2f-8a77-eb3991c22e23",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "MANAGEMENT ET GESTION",
    "name": "BACHELOR EN GESTION DE L'INNOVATION",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "044c5750-ce24-5b62-8162-ab69ead56343",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master's Degree in E-Banking and Fintech",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "044c8139-8941-5ec7-b9b9-445ea7df7c61",
    "school_code": "ILMIS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère E-Banking et Fintech",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "04f088a5-f5c0-5191-995e-630e0a690714",
    "school_code": "MLV BS",
    "cycle": "MBA",
    "academic_level": null,
    "domain": "MBA",
    "name": "MASTER OF BUSINESS ADMINISTRATION (MBA)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "054b4866-a46c-580c-9c43-4587eb5f7c87",
    "school_code": "ESUV",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Bachelor Gestionde Marque et Branding(GM)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "059e0062-f49d-5680-bbdb-a5c4e01748f0",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master's Degree in Strategic Management and Economic Intelligence",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "060fc4d3-7b6b-5f50-9d4d-b8c6b5500a01",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Finance",
    "name": "Bachelor Gestion des Opérations de Marchés Financiers",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "0626e0e1-99f3-5e7b-a822-7675aed820a4",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Commerce - Vente",
    "name": "Bachelor Chef de Produit",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "0628b912-5c88-5a1d-8985-be7afd3c13a1",
    "school_code": "ILMIS",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Spécialisé en Banque Finance et Assurance",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "063250e0-81b7-5e2b-bd44-16cab0c31f0b",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "STRATÉGIE ET MANAGEMENT INTERNATIONAL",
    "name": "BACHELOR EN GESTION DES ORGANISATIONS",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "0642d5c0-f6a2-5cc4-9e46-3012edb166f9",
    "school_code": "ESMEP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "MASTER'S DEGREE IN ENTREPRENEURSHIP AND BUSINESS DEVELOPMENT",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "06523f65-67de-5dd3-ace5-36f2bdc08a71",
    "school_code": "ESJM",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "MASTERE DROIT DU SPORT ET DES COMPETITIONS",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "0684e883-f1b6-5748-94c1-b717716a354c",
    "school_code": "MLV BS",
    "cycle": "Nos Mastère Spécialisé",
    "academic_level": null,
    "domain": "Commerce et Vente",
    "name": "MASTÈRE SPECIALISE ENTREPRENEURIAT & BUSINESS DEVELOPMENT (EBD)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "06aa152b-1d66-5019-8a5c-092958e0a118",
    "school_code": "ESUV",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Master's Degree",
    "name": "master's in digital marketing and communication (MCD)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "06b14238-b46b-5380-aa6d-9e483505ab60",
    "school_code": "EMSP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Management des Produits Digitaux",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "06c23145-5c87-50dc-9bd9-2670a9d80f21",
    "school_code": "EVRY BS",
    "cycle": "NIVEAU BAC",
    "academic_level": null,
    "domain": "niveau bac",
    "name": "TP negociateur technico-commercial",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "06deb65d-902f-5ac2-bbe9-87332fabea8e",
    "school_code": "ESJM",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "MASTÈRE SPÉCIALISÉ EN DROIT DES AFFAIRES ET MANAGEMENT",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "06fb235e-7b1d-5c00-b655-32eac529834d",
    "school_code": "EMSP",
    "cycle": "Mastère spécialisé",
    "academic_level": "Mastère spécialisé",
    "domain": "Commerce - Vente",
    "name": "Mastère Spécialisé en Affaires Internationales et Enjeux Digitaux",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "070f3c09-2aca-55da-b2f5-dc13efdf676e",
    "school_code": "EVRY BS",
    "cycle": "Mastères Spécialisés",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "mastere spécialisé ux design (UX)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "0734ca70-a127-54ee-ab87-0031fdfcb4ac",
    "school_code": "MLV BTS",
    "cycle": "BTS (Brevet de Technicien Supérieur)",
    "academic_level": null,
    "domain": "MANAGEMENT ET GESTION",
    "name": "BTS SAM",
    "source_file": "forms/mlv-bts.html"
  },
  {
    "id": "073bcf71-8494-56b7-9506-9605914322db",
    "school_code": "MLV BTS",
    "cycle": "BTS (Brevet de Technicien Supérieur)",
    "academic_level": null,
    "domain": "COMMERCE - VENTE",
    "name": "BTS MCO (MANAGEMENT COMMERCIAL ET OPÉRATIONNEL)",
    "source_file": "forms/mlv-bts.html"
  },
  {
    "id": "073d9a65-c808-53ae-bdc9-b6b9335d8c62",
    "school_code": "EMSP",
    "cycle": "Mastère spécialisé",
    "academic_level": "Mastère spécialisé",
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Spécialisé UX Designer",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "0813c3e3-c09d-5e32-9270-c3de0a168e12",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "Bachelor's Degree in Business Management and Commercial Development",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "085cfb28-da48-5e2b-9499-e61f762bffe9",
    "school_code": "EMSP",
    "cycle": "Mastère spécialisé",
    "academic_level": "Mastère spécialisé",
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Spécialisé en Management de Projets et de l’Innovation",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "0870531d-bd8f-52f0-875e-ecd20844284d",
    "school_code": "EVRY BTS",
    "cycle": "BTS (Brevet de Technicien Supérieur)",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "BTS CYBERSÉCURITÉ",
    "source_file": "forms/evry-bts.html"
  },
  {
    "id": "087e790e-e682-5b79-867e-ef4225efee0f",
    "school_code": "MLV BS",
    "cycle": "Nos Mastère Spécialisé",
    "academic_level": null,
    "domain": "Commerce et Vente",
    "name": "MASTÈRE SPECIALISE INGÉNIEUR D'AFFAIRES (IA)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "09301a44-91a2-5f7d-8782-f9c78e6b4aeb",
    "school_code": "MLV BS",
    "cycle": "Nos Bachelors",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "BACHELOR ACHATS ET LOGISTIQUE (AL)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "093a752b-4ad7-56fd-93a6-187b4d9a5475",
    "school_code": "EVRY BS",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Bachelor's Degree",
    "name": "Bachelor's Degree in E-COMMERCE",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "099fe2ef-2aa5-5d18-899c-e2e2d2f600dc",
    "school_code": "ESUV",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Bachelor's Degree",
    "name": "Bachelor degree in retail management",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "09aaf8ff-4228-5754-9df2-36c8c3284707",
    "school_code": "EMSP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère E-Santé et Transformation Digitale",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "09cb2fde-f39e-5680-9e6e-f5a6b12997f2",
    "school_code": "ESMAS",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "Bachelor's Degree in Negotiation and Sales",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "09cc4612-f989-54e8-8a66-9c2821470af3",
    "school_code": "EVRY BS",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Bachelor's Degree",
    "name": "Bachelor's Degree in brand management and branding",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "09d48df6-1176-59b9-82b6-f27217463cb9",
    "school_code": "ILMIS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Stratégie et Management International",
    "name": "Mastère en Management Stratégique et Intelligence Économique",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "0a025874-ded8-53f3-955f-7d5321416a41",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Commerce - Vente",
    "name": "Bachelor Gestion des Risques Interculturels",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "0a43e716-3dd9-5655-bd60-9674d156372a",
    "school_code": "ILMIS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in Digital Product Management",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "0a5489f4-3287-5cae-8c7c-8ade1c0ab533",
    "school_code": "ESUV",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Bachelor's Degree",
    "name": "Bachelor's Degree in business management",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "0a5ea277-6201-559d-bd51-dbc267de4520",
    "school_code": "EMSP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in Digital Marketing and Communication",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "0ac97b4a-46ae-53f6-90d9-228bb861116c",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "Bachelor's Degree in Healthcare Management and Transformation",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "0af768b1-f5ff-53d3-87ad-b3ed44ee2c49",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Management et Gestion",
    "name": "Bachelor Gestion des Organisations",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "0b5a5c78-cf0c-5c0f-9330-4ae89f879858",
    "school_code": "EVRY BS",
    "cycle": "NIVEAU BAC",
    "academic_level": null,
    "domain": "niveau bac",
    "name": "TP manager d'equipe relation client a distance",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "0bb0860d-86ca-5d8b-aedc-b9c6edcf310d",
    "school_code": "EMSP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in Business Development Management",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "0bd2dada-6234-5c3c-995a-76fd8fed217b",
    "school_code": "CESCOM",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "Master in Global Management",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "0bd512a9-718d-5889-b353-d06058fc6b9a",
    "school_code": "ESMEP",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "MASTÈRE SPÉCIALISÉ MANAGEMENT DES PRODUITS DIGITAUX",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "0c17a09d-7278-5674-b9cc-91a02636abae",
    "school_code": "ESMAS",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "STRATÉGIE ET MANAGEMENT INTERNATIONAL",
    "name": "Mastère Spécialisé Management International du Sport (MIS)",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "0c24e26b-f403-54a3-a1fb-babcd8bfda10",
    "school_code": "CESCOM",
    "cycle": "MASTÈRE (BAC+5)",
    "academic_level": null,
    "domain": "MARKETING-MANAGEMENT",
    "name": "Mastère Management de Projet",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "0c4e0dee-dbd0-5806-ab65-0b94924ac706",
    "school_code": "ESEA",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "MASTER'S DEGREE IN CSR CONSULTING AND SUSTAINABLE DEVELOPMENT (C-RSE)",
    "source_file": "forms/esea.html"
  },
  {
    "id": "0c8481ab-721b-5255-bce3-aef08ed0eb4e",
    "school_code": "ESMAS",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "FINANCE",
    "name": "Mastère Management Commercial et Sponsoring Sportif 4.0(MCS)",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "0c8f237b-ba5b-5580-b7ee-02dbadaf70c0",
    "school_code": "ESMEP",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "MASTÈRE SPÉCIALISÉ MANAGER ENTREPRENEURIAL PROJET NUMERIQUE ET STRATEGIE DIGITALE(PN-SD)",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "0db2b1dd-fe1c-59f7-b647-4e5ea5efb353",
    "school_code": "ESART",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "BACHELOR'S DEGREE IN PROJECT MANAAGEMENT",
    "source_file": "forms/esart.html"
  },
  {
    "id": "0dc0f340-0978-5ae3-a86d-f1f1cbed9c4c",
    "school_code": "ESETH",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "MASTER'S DEGREE IN ENTREPRENEURSHIP AND BUSINESS DEVELOPMENT",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "0dcf9a52-f71d-5fa2-97a9-4a212dd1a2a9",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Technologie et Data Innovation",
    "name": "Bachelor Informatique et Réseaux",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "0dd04db5-afb3-5b3f-bf5e-f69dacc5d7f3",
    "school_code": "ESUV",
    "cycle": "Mastères",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Management des Produits Digitaux(MPD)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "0de398ba-42c8-5059-8b51-a319b01ced0a",
    "school_code": "ESJM",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "MASTÈRE SPÉCIALISÉ DROIT DU SPORT ET DES COMPETITIONS",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "0e3597a8-3c9f-59ad-92d0-6761acffacf4",
    "school_code": "ESEA",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "COMMERCE VENTE",
    "name": "BACHELOR LOGISTIQUE DURABLE ET PILOTAGE DIGITAL DES FLUX (TLD)",
    "source_file": "forms/esea.html"
  },
  {
    "id": "0e3b2f5e-d18a-5fe4-bfd0-473cbfd25ccd",
    "school_code": "ESART",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "MASTER'S DEGREE IN PROJECT AND INNOVATION MANAGEMENT",
    "source_file": "forms/esart.html"
  },
  {
    "id": "0e575206-2cfb-50a7-9c5e-444f4174514d",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Management et Gestion",
    "name": "Bachelor Droit des Entreprises",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "0e861d99-6a67-5f7b-92ac-ea6b852d92b0",
    "school_code": "LSB",
    "cycle": "Masteres Specialises",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastere specialise management et numerisation des processes NP-QHSE",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "0e8fa182-c816-55fa-a4e7-ff7129daf1ea",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Commerce - Vente",
    "name": "Bachelor Marketing et Communication",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "0f0dccc6-b548-5619-8582-645058534c68",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Procurement and Logistics",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "0f0f72e2-798d-5877-98bc-7ffa5495e212",
    "school_code": "ESUV",
    "cycle": "Mastères Spécialisés",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "technologie et data innovation",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "0f32e32b-ae90-5125-af85-052caf1f871b",
    "school_code": "EVRY BS",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Bachelor's Degree",
    "name": "Bachelor's Degree in digital and event communication with ai impact",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "0f716ad0-b792-5141-b32f-a01bf2ab9c2f",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Management et Gestion",
    "name": "Bachelor Gestion des Organisations",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "0fb79a66-ba14-5293-8800-49dae7da3c93",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN BRAND MANAGEMENT AND BRANDING",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "0fbc5202-61cf-5657-9e0c-c87ba99a1c2b",
    "school_code": "EVRY BTS",
    "cycle": "BTS (Brevet de Technicien Supérieur)",
    "academic_level": null,
    "domain": "MODE ET LUXE",
    "name": "BTS - MÉTIERS DE LA MODE : VÊTEMENTS",
    "source_file": "forms/evry-bts.html"
  },
  {
    "id": "0fcdb3ed-4420-5a6b-9b91-a2be5f594033",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "MANAGEMENT ET GESTION",
    "name": "BACHELOR DES RESSOURCES DES RESSOURCES HUMAINES",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "0fcfa7ac-388a-5ac5-9a95-f76bd865b4cb",
    "school_code": "ESIIA",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Bachelor's Degree",
    "name": "Bachelor's Degree in IT Project Management",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "0fd3a515-6098-5b5e-ab99-82a306351ef2",
    "school_code": "ILMIS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in Quality, Health, Safety, and Environment Management",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "0fdad91b-713e-5a03-9ee2-2ae8a20c942e",
    "school_code": "EMSP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Commerce International et Digitalisation",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "0fe11c26-dafb-5bba-a1dd-abb5a8b4063d",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master's Degree in Sustainable Development and CSR Management",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "10417f0c-8e61-5434-879f-584b21757748",
    "school_code": "MLV BS",
    "cycle": "Nos Bachelors",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "BACHELOR EN GESTION DE MARQUE (GM)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "10873f9e-8e1a-5d9e-a17e-5b60838bbf4f",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Technologie et Data Innovation",
    "name": "Bachelor Marketing Digital et Data",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "10b0484e-8649-5ac8-9255-77053e73bf3f",
    "school_code": "ISMOD",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Gestion-Luxe",
    "name": "Bachelor Gestion de Marque et Branding",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "10e40225-2152-5f8d-89f6-dd3d7f202ef0",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Finance",
    "name": "Diplôme de Comptabilité et de Gestion",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "114b39e7-43ed-5345-ab29-2f53fe9369c1",
    "school_code": "ESMEP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "MASTÈRE MANAGER ENTREPRENEURIAL PROJET NUMERIQUE ET STRATEGIE DIGITALE (PN-SD)",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "1157c153-7870-5619-9586-66bc68c88a41",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Project Management",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "115bfbcb-a92a-5c11-919b-829a47fb9fde",
    "school_code": "ISMOD",
    "cycle": "MBA",
    "academic_level": "MBA",
    "domain": "MBA",
    "name": "Master of Business Administration (MBA)",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "11711ab7-87df-562f-b1e4-c897a7341a81",
    "school_code": "ILMIS",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "Stratégie et Management International",
    "name": "Mastère Spécialisé en Management et Stratégie",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "117a3260-c99c-5e32-af88-6aa1cdf8e836",
    "school_code": "MLV BS",
    "cycle": "Nos Mastères",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Intelligence Artificelle et Management (IAM)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "11a7eaba-8638-592f-9cc6-40b290427d12",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère en Droit des Affaires et Management",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "11aa2064-e28f-5c84-b317-cfe3e5a479a3",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Commerce - Vente",
    "name": "Bachelor Marketing et Communication",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "11ac4c8e-3570-5359-9871-3e7a36cd51a7",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Stratégie et Management International",
    "name": "Responsable Etablissement Marchand",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "11e747d7-c028-556f-813f-74264712002c",
    "school_code": "MLV BS",
    "cycle": "Nos Bachelors",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "BACHELOR EN RESSOURCES HUMAINES (RH)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "12107151-d010-5b05-9092-dd396ac3fd1a",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Management et Gestion",
    "name": "Bachelor Responsabilité Sociétale des Entreprises",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "1223f260-9fc8-5f6a-a034-37a460bef226",
    "school_code": "MLV BS",
    "cycle": "Nos Mastère Spécialisé",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Spécialisé e-Banking et FINTECH",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "1257e8ac-7ec9-5d00-98aa-5f5da0ea37be",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Marketing and Communication",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "1273be87-2f5c-5e60-bc68-029bed9feb0b",
    "school_code": "ILMIS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastères Managements de Projets et de l'Innovation",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "12b58a74-d46d-5e60-a202-ec310f61ae23",
    "school_code": "ESEA",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "MANAGEMENT ET GESTION",
    "name": "MASTÈRE QUALITE, SECURITE ET TRANSITION (QST)",
    "source_file": "forms/esea.html"
  },
  {
    "id": "1332bf2f-504d-5be1-8634-203c3e43ae1b",
    "school_code": "EVRY BS",
    "cycle": "Mastères Spécialisés",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "mastere spécialisé responsable communication digitale evenementielle et ia impact (CDE)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "134d9f92-2292-532a-a99c-621677e92c8e",
    "school_code": "ESMOSS",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "MÉDICO-SOCIAL",
    "name": "Bachelor Gestion et Numerisation QHSE",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "13559154-ef33-5c0c-a845-4ceb46245f34",
    "school_code": "ESMAS",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "Master's Degree in Commercial Management and Sports Sponsorship",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "13631796-11f2-5989-ab48-2358921ecdbb",
    "school_code": "ILMIS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Comptabilité Audit et Contrôle de Gestion (CAC)",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "138f4cec-8d76-5d19-b76e-4f3447d58d0d",
    "school_code": "EMSP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère en Management de la Qualité Hygiène Sécurité Environnement",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "14cf5c95-b2af-591d-a26e-4bda5e0131be",
    "school_code": "LSB",
    "cycle": "Masteres",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère management et digitalisation de ressources humaines",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "14da09df-6b10-5b61-87c8-07a067c1e1ed",
    "school_code": "LSB",
    "cycle": "Masteres",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère Management et digitalisation des processus achats et logistique",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "1547f800-30f9-5ecf-968a-eabc5e0666e0",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "COMMERCE - VENTE",
    "name": "BACHELOR EN MARKETING ET COMMUNICATION",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "155a1bb8-6dcd-50a5-804c-56c3ee0bfe3c",
    "school_code": "ESEA",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "STRATÉGIE ET MANAGEMENT INTERNATIONAL",
    "name": "MASTÈRE TRANSITION ENERGETIQUE ET ENERGIES VERTES (TEEV)",
    "source_file": "forms/esea.html"
  },
  {
    "id": "15854d77-a4ab-5f8a-81af-32c0e98db2e9",
    "school_code": "ESMEP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "MASTÈRE MANAGER ENTREPRENEURIAL PROJET NUMERIQUE ET STRATEGIE DIGITALE (PN-SD)",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "1585e82a-22f4-5b7f-b1e4-042d7bfe7d86",
    "school_code": "MLV BS",
    "cycle": "Nos Mastère Spécialisé",
    "academic_level": null,
    "domain": "Stratégie et Management International",
    "name": "Mastère Spécialisé Stratégique et Intelligence Economique (SIE)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "15a6b507-7f96-560c-93df-74054203f882",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "MANAGEMENT ET GESTION",
    "name": "BACHELOR EN GESTION DE MARQUE ET BRANDING",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "15d2bc8f-ec5c-514e-9dbd-47f4c96e9a60",
    "school_code": "EMSP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in Entrepreneurial Management of Digital Projects and Digital Strategy",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "15d5e7c2-cb77-5d95-ba0e-35fffc085605",
    "school_code": "EMSP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Affaires Internationales et Enjeux Digitaux",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "16c79d47-ae84-5082-bc0a-65615ad3b89d",
    "school_code": "CESCOM",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "Master in International Finance",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "16cde98c-4ffd-56d6-acf2-a577ef69465d",
    "school_code": "ESUV",
    "cycle": "Mastères",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère Management et Stratégie et Intelligence Economique(SIE)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "16ceca05-aad7-580e-a3ca-18d40f6ef903",
    "school_code": "ESMAS",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "Bachelor's Degree in Sports Management",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "16d24f65-3ee1-563f-9398-4a618ccf289e",
    "school_code": "ESUV",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Bachelor Nego Vente",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "16de8a2b-5f00-5d67-9ac9-18705dca82b5",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master's Degree in Entrepreneurship and Innovation",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "16f1e7bf-d40a-5057-8af5-dcf1b96f77cf",
    "school_code": "ISMOD",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Communication-Vente",
    "name": "Bachelor Négociation-Vente",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "1721f0fc-ff4c-5018-b01c-c1d07ddbc13a",
    "school_code": "ESART",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "COMMUNICATION - MANAGEMENT",
    "name": "MASTÈRE SPÉCIALISÉ MANAGEMENT DE PROJET ET DE L'INNOVATION (MPI)",
    "source_file": "forms/esart.html"
  },
  {
    "id": "17860f53-e1bf-59cf-94cf-21ce251ff42a",
    "school_code": "EVRY BS",
    "cycle": "Mastères",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère UX Design (UX)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "17c13bce-bb7f-53da-ac18-0fe8a76acd85",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Management et Gestion",
    "name": "Bachelor Droit des Entreprises",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "18525f59-8d80-5ecf-8c62-7befe4538fc1",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Commerce - Vente",
    "name": "Bachelor Commerce International",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "18fb1f95-613c-599d-86d6-2cac9de9fa1f",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "Bachelor's Degree in Organisational Management",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "1936fc08-f1ac-5f3b-9e8b-ea84a767bfe5",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Stratégie et Management International",
    "name": "Bachelor Stratégie et Management International",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "19689c96-2f77-5c15-9010-407b36637f84",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Product Management",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "19bc926a-180e-5ece-afce-4b60164167e8",
    "school_code": "LSB",
    "cycle": "Masteres Specialises",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Spécialisé architecture des systemes informatiques(ASI)",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "19bd256e-8448-5a71-b8f6-469ba56c06eb",
    "school_code": "MLV BS",
    "cycle": "Nos Bachelors",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "BACHELOR EN DROIT DES ENTREPRISES (DE)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "19e4f5bc-cad0-58d7-b397-04ef2ec31df0",
    "school_code": "ISMOD",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Gestion-Luxe",
    "name": "Bachelor Gestion de Marque et Branding",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "19fbe7d4-68bb-5e2c-956c-0a1b04feee3d",
    "school_code": "ILMIS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Cybersécurité et Management des Données Personnelles",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "1a63641a-6d64-5a0a-a287-4adbd7645001",
    "school_code": "ESMEP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "MASTER'S DEGREE IN MANAGEMENT AND STATEGY",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "1a7c85ec-cbe0-55da-9a0b-848fe7c9f028",
    "school_code": "LSB",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Bachelor developpement web et mobile (WN)",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "1ab1798c-4ba7-5b3c-8240-0ff7f18fb362",
    "school_code": "ESUV",
    "cycle": "NIVEAU BAC",
    "academic_level": null,
    "domain": "niveau bac",
    "name": "TP assistant manager d'unité marchande (AMUM)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "1af8672a-413c-51e0-ab32-d2c01c0fbf65",
    "school_code": "ESIIA",
    "cycle": "Mastères Spécialisés",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Spécialisé Lead Developer",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "1b613568-72a3-5b94-b9aa-3627da189c34",
    "school_code": "ESJM",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "MASTÈRE SPÉCIALISÉ DROIT FISCAL ET MANAGEMENT DE LA PERFORMANCE",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "1b82f84d-ad92-5b34-ba88-4b444ab86b1a",
    "school_code": "ESMEP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "FINANCE",
    "name": "MASTERE EN FINANCE DE MARCHE ET MANAGEMENT DES RISQUES",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "1c530fb3-5a9e-5e98-8ec7-f693d75818eb",
    "school_code": "EMSP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Manager Entrepreneuriel de Projet Numérique et Stratégie Digitale",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "1c5792fb-0763-5e6b-b996-60fe3e3df646",
    "school_code": "ILMIS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in Quality, Health, Safety, and Environment Management",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "1c92f55c-5202-563a-a271-c6868a5d6c30",
    "school_code": "ESMOSS",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "Master's Degree in QHSE Process Management and Digitalisation",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "1cb5704a-d26c-5c18-8200-3cb90a1e27aa",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "Bachelor's Degree in Human Resources Management",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "1cca1f02-a496-5ff0-87e9-1497748a758e",
    "school_code": "ESART",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "AUDIOVISUEL - CINÉMA - PRODUCTION",
    "name": "BACHELOR SCENARIO",
    "source_file": "forms/esart.html"
  },
  {
    "id": "1cd5ff71-9af8-5409-8830-81466d25706d",
    "school_code": "ESMAS",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "Master's Degree in Entrepreneurship and Business Development",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "1d009cca-fafd-5e10-b6eb-46d01c7989dc",
    "school_code": "ESIIA",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Bachelor Chef de Projet Informatique",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "1d4eff94-24ec-51ff-a35c-a8608cce7e19",
    "school_code": "EMSP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in Human Resources and Digitisation of Operations",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "1d81f28a-5ea9-5e9a-8d2f-1a4c8e1418e0",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "FINANCE",
    "name": "BACHELOR GESTION DES OPERATIONS DE MARCHES FINANCIERS (GMF)",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "1d8cacff-4294-5001-a03d-4f8416143eaf",
    "school_code": "ESEA",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "COMMERCE VENTE",
    "name": "BACHELOR MARKETING ET COMMUNICATION",
    "source_file": "forms/esea.html"
  },
  {
    "id": "1dcc352a-b86c-589f-bccc-c91f1a92b9d9",
    "school_code": "EMSP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in Digital Product Management",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "1df0d121-9ee0-5beb-aa3d-65a90226fc3a",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "MANAGEMENT ET GESTION",
    "name": "BACHELOR EN RESPONSABILITE SOCIETALE DES ENTREPRISES",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "1e717eba-ee64-546a-be26-24231dbb3635",
    "school_code": "MLV BS",
    "cycle": "Nos Mastère Spécialisé",
    "academic_level": null,
    "domain": "Stratégie et Management International",
    "name": "Mastère Spécialisé Management et Stategie (MS)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "1e96b3dd-4074-542e-b881-85bf949c4d15",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "COMMERCE - VENTE",
    "name": "BACHELOR E-COMMERCE",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "1e9ce468-0b85-57b3-a301-191044bbf2db",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Intercultural Risk Management",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "1ed0df05-eb4e-5ac6-ac20-116da9bdec95",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "Bachelor's Degree in Innovation Management",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "1ee0778d-5948-581d-9833-af28dbb3dc49",
    "school_code": "ESEA",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "COMMERCE VENTE",
    "name": "MASTÈRE ENTREPRENEURIAT RESPONSABLE ET BUSINESS DEVELOPMENT DIGITAL",
    "source_file": "forms/esea.html"
  },
  {
    "id": "1ee8254d-fb11-5d45-95e6-608da4f983c4",
    "school_code": "ESUV",
    "cycle": "NIVEAU BAC",
    "academic_level": null,
    "domain": "niveau bac",
    "name": "TP negociateur technico-commercial",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "1ef84c22-c195-5aab-8f7c-f80da2880652",
    "school_code": "EMSP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Banque Finance et Assurance",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "1f044d26-d9ad-5658-a55d-a445f4fead37",
    "school_code": "ESEA",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "MASTER'S DEGREE IN ENERGY TRANSITION AND GREEN ENERGY (TEEV)",
    "source_file": "forms/esea.html"
  },
  {
    "id": "1f2bf608-ef09-5a7d-be04-45fae7129182",
    "school_code": "LSB",
    "cycle": "Masteres Specialises",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Spécialisé en Banque Finance et Assurance",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "1f56b8b9-9794-5d04-a5dc-d415408c7e2d",
    "school_code": "ESJM",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "MASTÈRE EN DROIT ET GESTION DU PATRIMOINE",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "1fef8ce3-cfd4-5619-b699-b645dae2fcd2",
    "school_code": "EMSP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère E-Banking et Fintech",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "1ff8c800-a805-5be6-ac90-697cc078233a",
    "school_code": "EVRY BS",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Bachelor's Degree",
    "name": "Bachelor's Degree in business management",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "203f1eaa-c2c8-549a-a64e-101fb56067e6",
    "school_code": "EVRY BS",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Bachelor Nego Vente",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "208bee5f-f84f-505f-ab22-92fed950a3e0",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "Diploma in Accounting and Management",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "20a70bcf-7f8f-5e55-8601-0452744f9fe5",
    "school_code": "ESMEP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "COMMERCE - VENTE",
    "name": "MASTER EN MARKETING ET COMMUNICATION DIGITALE",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "20a83e1e-e1e6-570c-b308-7ca99bd789b7",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "Bachelor’s Degree in International Business",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "20bd0abf-e917-58ee-b3d7-81fb56b9349d",
    "school_code": "EVRY BS",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Bachelor Gestion Commerciale(GC)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "20ffe557-01f9-5af4-aba1-9e7a0d85e0c1",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "Bachelor's Degree in Organisational Management",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "219f9c20-cc1e-54a3-a16d-fd5e055a5283",
    "school_code": "ESEA",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "MANAGEMENT ET GESTION",
    "name": "BACHELOR RESPONSABILITE SOCIETALE DE L'ENTREPRISE ET IMPACT NUMÉRIQUE (RSEI)",
    "source_file": "forms/esea.html"
  },
  {
    "id": "21b7f787-0008-566e-b6ba-9b70d9a45db4",
    "school_code": "ISMOD",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Communication-Vente",
    "name": "Bachelor Chargé de Communication Digitale, Événementielle et à Impact",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "21cbc907-3d15-5c67-8a2c-331d1c1a023d",
    "school_code": "ESART",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "DESIGN-CRÉATION",
    "name": "BACHELOR DESIGN ET CRÉATION",
    "source_file": "forms/esart.html"
  },
  {
    "id": "21cdd05b-76c0-535f-af70-3e94c7aaf1c5",
    "school_code": "ESIIA",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Bachelor Développeur Web et Mobile",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "21fa3fae-fed1-5e05-9f5e-bca220a1b050",
    "school_code": "ESART",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "COMMERCE-GESTION-BUSINESS DEVELOPMENT",
    "name": "BACHELOR ACHATS ET LOGISTIQUES",
    "source_file": "forms/esart.html"
  },
  {
    "id": "2240aa61-f088-5b7b-ae7b-f47e21c789db",
    "school_code": "ESETH",
    "cycle": "MASTÈRE SPÉCIALISÉ",
    "academic_level": null,
    "domain": "COMMERCE-DIGITAL",
    "name": "MASTÈRE SPÉCIALISÉ INGÉNIEUR D'AFFAIRES ET DE TRANSITION (IA)",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "22bae345-c60d-5208-98d0-a0470ffab095",
    "school_code": "ESMOSS",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "SANTÉ-DIGITALE",
    "name": "Mastère Management de la Durabilité et Numerique Responsable(RSE)",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "22ca499a-7a1a-5444-b603-9f322da2f43c",
    "school_code": "EVRY BS",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Bachelor's Degree",
    "name": "Bachelor degree in retail management",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "231b5506-9cfb-5a2e-9088-4a54a5e45606",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère Management de Projet et de l'Innovation",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "23550211-29e8-5e05-ab25-75226578aafb",
    "school_code": "ESMEP",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "MANAGEMENT ET GESTION",
    "name": "MASTÈRE SPÉCIALISÉ EN MANAGEMENT DE LA QUALITE HYGIENE SECURITE ENVIRONNEMENT(QHSE)",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "236636e2-0b89-56f7-abae-b7ef93edfe29",
    "school_code": "ESMEP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "MASTER'S DEGREE IN BANKING, FINANCE AND INSURANCE",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "23723ec2-5eda-5e7a-91f5-b124e6e3a1c8",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "Bachelor's Degree in Brand Management and Branding",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "239dc4e6-90bd-56f7-874f-9479b5084cc0",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Management et Gestion",
    "name": "Bachelor Gestion de Projets",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "23dd948e-a560-5b68-b6b2-a657c09dcc3e",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master's Degree in Sustainable Development and CSR Management",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "247f7ae5-27e6-5ed0-8656-35f6c72c3af5",
    "school_code": "ESIIA",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Master's Degree",
    "name": "Master's Degree in Computer Systems Architecture",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "24805f1f-8c7e-5352-9c69-17fd13f433c7",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN QUALITY, HYGIENE, SAFETY AND ENVIRONMENT (QHSE)",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "24814548-3a04-53bb-9eb8-d138a05e9e5f",
    "school_code": "LSB",
    "cycle": "MBA",
    "academic_level": null,
    "domain": "MBA",
    "name": "Master of Business Administration (MBA)",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "24879e3d-71ae-5f2a-b7f4-b0a0912cf852",
    "school_code": "EVRY BS",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Master's Degree",
    "name": "master's degree in UX design (UX)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "24a4258a-fd18-5771-a9df-ab0ea9cbc554",
    "school_code": "CESCOM",
    "cycle": "NIVEAU BAC",
    "academic_level": null,
    "domain": "TITRES PROFESSIONNELS",
    "name": "TP CONSEILLER RELATION CLIENT A DISTANCE",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "24c1e295-8b3c-56a9-8e30-fcd7c4b6e274",
    "school_code": "EVRY BS",
    "cycle": "Mastères",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère Management et Stratégie et Intelligence Economique(SIE)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "24c742ab-68f8-5efa-9341-4153c33ac32a",
    "school_code": "EVRY BS",
    "cycle": "Mastères",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Management des Produits Digitaux(MPD)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "24cd1081-713e-5c5a-af25-e5fa40a24f9f",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Commerce - Vente",
    "name": "Bachelor Chef de Produit",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "24e720f1-0147-571e-a09a-9d2483157184",
    "school_code": "ESEA",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "MANAGEMENT ET GESTION",
    "name": "BACHELOR RESSOURCES HUMAINES ET TRANSITION",
    "source_file": "forms/esea.html"
  },
  {
    "id": "25000d06-45e5-5214-af02-0089624957e7",
    "school_code": "EMSP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Affaires Internationales et Enjeux Digitaux",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "2532e4e8-18dc-5f0a-a8d3-7de4eeba4741",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Commerce - Vente",
    "name": "Bachelor Négociation et Vente",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "25368d60-94a1-5a68-8c78-e6ca08622d7d",
    "school_code": "ILMIS",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Spécialisé en Ingénieur(e) d’Affaires",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "2556b734-005e-5963-b083-08e2ec51b03c",
    "school_code": "ESEA",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "MANAGEMENT ET GESTION",
    "name": "MASTÈRE MANAGEMENT ET STRATÉGIE",
    "source_file": "forms/esea.html"
  },
  {
    "id": "25a01fc5-3920-5403-a6d2-25d2651599da",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "Bachelor's Degree in Project Management",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "25af74fe-9b82-591d-8452-88d1c46c364b",
    "school_code": "ESMOSS",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "MANAGEMENT-GESTION",
    "name": "Mastère SpécialiséIngénieur(e) d'Affaires et de la Transition (IA)",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "26822cd3-9c2b-52bc-b758-27d8d06c2384",
    "school_code": "ISMOD",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Communication-Vente",
    "name": "Bachelor Négociation-Vente",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "2688372c-704b-5efd-b32d-edf2d999eaad",
    "school_code": "EMSP",
    "cycle": "Mastère spécialisé",
    "academic_level": "Mastère spécialisé",
    "domain": "Finance",
    "name": "Mastère Spécialisé en Finance de Marché et Management des Risques",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "26cbba70-1d89-5623-8aa4-22b4bd8fc8d8",
    "school_code": "EMSP",
    "cycle": "Mastère spécialisé",
    "academic_level": "Mastère spécialisé",
    "domain": "Stratégie et Management International",
    "name": "Mastère Spécialisé en Management International des Projets et Digitalisation des Process",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "26dfd4bc-3498-5327-88f7-32ab3676450e",
    "school_code": "CESCOM",
    "cycle": "MASTÈRES SPÉCIALISÉS (BAC+6)",
    "academic_level": null,
    "domain": "MARKETING-MANAGEMENT",
    "name": "MS Management de l'Innovation",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "26e1c256-3bde-5553-8b5d-a71e7a7c699e",
    "school_code": "ESEA",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "BACHELOR'S DEGREE IN INTERNATIONAL BUSINESS",
    "source_file": "forms/esea.html"
  },
  {
    "id": "26ff37ec-caba-59e1-9f02-050f1e4ac555",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "MANAGEMENT ET GESTION",
    "name": "BACHELOR EN GESTION DE L'INNOVATION",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "2764d08d-d6cd-5e25-8808-9ae22991b4f5",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Commerce - Vente",
    "name": "Bachelor Gestion et Affaires Internationales",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "278fa9f5-0f77-5032-9a14-c6bd3f83af7c",
    "school_code": "ESMEP",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "COMMERCE - VENTE",
    "name": "MASTÈRE SPECIALISE EN DROIT DES AFFAIRES",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "284929b4-a7ea-5a53-9abb-b091607e39bb",
    "school_code": "ILMIS",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Specialisé en Affaires Internationales et Enjeux Digitaux",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "287c047b-5f56-576d-95fb-022c3ac6b30b",
    "school_code": "ESJM",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "MASTÈRE SPÉCIALISÉ E-SANTÉ ET PROTECTION DES DONNÉES PERSONNELLES",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "28a2356c-42d1-58cb-9f94-2a07e70dbde8",
    "school_code": "ESMEP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "MANAGEMENT ET GESTION",
    "name": "MASTÈRE MANAGEMENT ET DIGITALISATION DES RESSOURCES HUMAINES",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "290ba81e-c8ad-5129-820e-acce6330103d",
    "school_code": "ESEA",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "STRATÉGIE ET MANAGEMENT INTERNATIONAL",
    "name": "MASTÈRE MANAGEMENT ET DIGITLISATION DES PROCESS QHSE",
    "source_file": "forms/esea.html"
  },
  {
    "id": "2969c8a4-41f4-52a7-9cd4-0fb93df68357",
    "school_code": "EVRY BS",
    "cycle": "Mastères Spécialisés",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère Spécialisé ingenieur (e) d'affaires (IA)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "297a17aa-895c-5f00-8d98-5183e5cc710b",
    "school_code": "ESART",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "BACHELOR'S DEGREE IN PRODUCTION MANAGEMENT",
    "source_file": "forms/esart.html"
  },
  {
    "id": "29844029-c278-584f-af0e-ce8944bc11cb",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "COMMERCE - VENTE",
    "name": "BACHELOR START-UP ET BUSINESS DEVELOPMENT",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "29ab641f-cae6-5899-90f1-5dfb90037280",
    "school_code": "EVRY BS",
    "cycle": "NIVEAU BAC",
    "academic_level": null,
    "domain": "niveau bac",
    "name": "TP conseiller commercial",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "2a06a1c7-6cc4-5755-adbc-1889c13738e7",
    "school_code": "ESMAS",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "MANAGEMENT-GESTION",
    "name": "MASTÈRE ENTREPRENEURIAT ET BUSINESS DEVELOPMENT DIGITAL (EBD)",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "2a461645-14e5-5dd9-a888-d602ddfdc48a",
    "school_code": "EMSP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Marketing et Communication Digitales",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "2a8b1aa1-2ebb-5ed1-ade3-fb76576c9709",
    "school_code": "ESART",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "COMMERCE-GESTION-BUSINESS DEVELOPMENT",
    "name": "BACHELOR START-UP ET BUSINESS DEVELOPMENT",
    "source_file": "forms/esart.html"
  },
  {
    "id": "2ad9e4a3-490c-5d7f-ab05-336799c43227",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Commerce - Vente",
    "name": "Bachelor Chef de Produit",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "2af17bb4-9cfc-5100-aa6b-87b9468cc119",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Commerce - Vente",
    "name": "Bachelor Négociation et Vente",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "2b3706c9-1bc1-51a3-a5d8-cd1cfe69058a",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Stratégie et Management International",
    "name": "Bachelor Commerce International et Logistique",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "2b51cfb8-ce57-5e9f-9bb0-e30254e70c00",
    "school_code": "EVRY BS",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Bachelor Marketing et communication(MC)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "2b633d96-50ac-5b65-b0e6-891975c9160d",
    "school_code": "ESMAS",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "SPORT-BUSINESS",
    "name": "BACHELOR CHARGÉ ÉVÈNEMENTIEL SPORTIF & SOLUTIONS DIGITALES (CES)",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "2b889832-756c-5e74-a8b5-ef36cba8fbe7",
    "school_code": "EVRY BTS",
    "cycle": "BTS (Brevet de Technicien Supérieur)",
    "academic_level": null,
    "domain": "MANAGEMENT ET GESTION",
    "name": "BTS CGPME",
    "source_file": "forms/evry-bts.html"
  },
  {
    "id": "2bc7c3ef-b7fa-54dc-9761-19d5a30e84be",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère en Management des Ressources Humaines",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "2c232999-db13-5466-a9c9-9e96c6b361fc",
    "school_code": "ESMAS",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "Mastère Spécialisé Management de Projet et de L'innovation (MPI)",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "2c53865b-9ca6-543f-8c36-73da20213ccd",
    "school_code": "ESMEP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "MANAGEMENT ET GESTION",
    "name": "MASTÈRE EN MANAGEMENT DE LA QUALITE HYGIENE SECURITE ENVIRONNEMENT(QHSE)",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "2cab38d4-a950-5060-8e0c-ed1cda74ac0a",
    "school_code": "EVRY BS",
    "cycle": "NIVEAU BAC",
    "academic_level": null,
    "domain": "niveau bac",
    "name": "TP conseiller relation client a distance",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "2cbab291-9fd7-526b-9dba-acf5042eb16c",
    "school_code": "EVRY BS",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Master's Degree",
    "name": "master's degree in business engineering",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "2cf0a5af-5ce8-576e-bf2d-c7b94e837d4d",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "MANAGEMENT ET GESTION",
    "name": "BACHELOR GESTION DE PROJETS",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "2d7c002b-3ede-5583-99f1-abec029cf667",
    "school_code": "EVRY BS",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Bachelor Responsable des Etablissements Marchands(REM)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "2dd2fd77-8880-59fb-ab02-338ba021b378",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Stratégie et Management International",
    "name": "Bachelor Gestion des Risques Intercurels",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "2e10d755-cdfc-51b9-b913-b1438678af82",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Commerce - Vente",
    "name": "Bachelor Gestion et Affaires Internationales",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "2e47d95a-8294-540c-9279-541d5624dfbb",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Commerce - Vente",
    "name": "Bachelor Gestion et Affaires Internationales",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "2e6ade4a-d676-557d-9e31-a6ef42fefabc",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "Bachelor’s Degree in International Business",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "2e722ed0-c9f3-51d6-9e76-fdefd4ad1cab",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Commerce - Vente",
    "name": "Bachelor Gestion et Affaires Internationales",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "2ec35a47-bdfa-50bd-bd7c-9405f693fe55",
    "school_code": "LSB",
    "cycle": "Masteres Specialises",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "mastere specialisé Entrepreneuriat et management numerique",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "2ef813bb-992e-58b5-ab8a-9fee979dcb23",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Intercultural Risk Management",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "2f6217f4-90bb-5dc9-97a3-f2790204f140",
    "school_code": "ESMEP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "MASTER'S DEGREE IN SUSTAINABLE DEVELOPMENT AND CORPORATE SOCIAL REESPONSIBILITY(RSE) MANAGEMENT",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "2fc7b475-bcac-5570-a2bf-7d51e3568922",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Commerce - Vente",
    "name": "Bachelor Gestion et Affaires Internationales",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "2fd97ccf-ee6b-5c17-b82b-79e1870ac1c1",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Commercial Establishments Management",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "3015ae03-ebec-59f5-a8a4-2edce4ea6b89",
    "school_code": "ESMAS",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "MANAGEMENT-GESTION",
    "name": "Mastère Spécialisé Start-Up et Développement de L'industrie Sportive Connectée (SIS)",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "30696704-3cc2-558a-96d0-0fe08974732b",
    "school_code": "ESETH",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "BACHELOR'S DEGREE IN HOTEL AND TOURISM MARKETING",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "307320f0-31ad-5631-b9da-974c85692318",
    "school_code": "ESUV",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Master's Degree",
    "name": "master's degree in purchasing and supply chain process management and digitalisation (MD-AL)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "30cd44b5-b914-5920-93f9-c5b2d348feb8",
    "school_code": "ISMOD",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Gestion-Luxe",
    "name": "Mastère Gestion de Marque et Branding",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "30d76a85-9d04-5191-aeda-c1ac28353d66",
    "school_code": "ESMEP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "MASTER'S DEGREE IN DIGITAL PRODUCT MANAGEMENT",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "3115cdc7-8194-53a7-8458-60cc4926fa45",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master's Degree in Project and Innovation Management",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "312efeec-9232-5b55-8c75-cee72b52b53d",
    "school_code": "ESJM",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "MASTERE DROIT FISCAL ET MANAGEMENT DE LA PERFORMANCE",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "315a2b89-6bfb-5fe4-8cb0-7fb49a0ac8d1",
    "school_code": "ESJM",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "MASTERE E-SANTE ET PROTECTION DES PROTECTION DES DONNEES PERSONELLES",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "316b05fd-a6c3-5faa-b4a2-85d2d170ec83",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Finance",
    "name": "Bachelor Comptabilité, Audit et Contrôle de Gestion",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "3197ed5e-ef92-5ca8-b87d-2fb9139434fb",
    "school_code": "ESUV",
    "cycle": "NIVEAU BAC",
    "academic_level": null,
    "domain": "niveau bac",
    "name": "TP prospection clientele et valorisation de l'offre commerciale",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "31e55803-01e5-502a-b29e-488646605c00",
    "school_code": "ILMIS",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Spécialisé Management International et Transformation Digitale",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "32350288-772a-53ca-a7ff-80a6fe06993b",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "Bachelor's Degree in Project Management",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "328db29a-42f3-5ca9-8298-a5fefaf2240f",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Commerce - Vente",
    "name": "Bachelor Responsabilité Sociétale des Entreprises",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "32938c98-2650-5b4d-a85d-ac8f5c958c8a",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Human Resources",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "329f5193-db0b-590d-985f-31bedbf375e1",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Technologie et Data Innovation",
    "name": "Bachelor Développement Web et Application",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "32b8219c-fd46-582e-b784-8a7f83bc6907",
    "school_code": "CESCOM",
    "cycle": "BACHELOR (BAC+3)",
    "academic_level": null,
    "domain": "MANAGEMENT ET GESTION",
    "name": "Bachelor Management d'Entreprise",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "32d62400-f2ec-5312-92db-42ccce6d76d8",
    "school_code": "ESETH",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "GESTION-RESTAURATION",
    "name": "BACHELOR CHARGÉ DE DÉVELOPPEMENT TOURISTIQUE ET PERFORMANCE DIGITALE (CDT)",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "33152d83-7ec9-5463-b583-60f1e6f6e989",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Human Resources",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "33587ebb-e1f2-51a5-85a5-ea053c7641ba",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN IN ORGANISATIONAL MANAGEMENT",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "336061a2-79fd-5717-b04c-1947bdd0d61e",
    "school_code": "ESEA",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "BACHELOR START-UP A IMPACT ET BUSINESS DEVELOPMENT",
    "source_file": "forms/esea.html"
  },
  {
    "id": "3394cd96-2763-578c-99e1-ccaeb2688023",
    "school_code": "ESIIA",
    "cycle": "Mastère",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Architecture des Systèmes Informatiques",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "33d009dc-7e65-5833-9419-5f5cf226fd2b",
    "school_code": "MLV BS",
    "cycle": "Nos Mastère Spécialisé",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "MASTÈRE SPECIALISE MANAGEMENT ET DIGITALISATION DES PROCESSUS ACHATS ET LOGISTIQUE",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "33de098f-5b40-5ad0-9706-6869c9a267a1",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "Bachelor’s Degree in International Management and Business",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "341f9269-0df8-5f96-9089-4c4edeecb1c0",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN IN ORGANISATIONAL MANAGEMENT",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "3454637d-a00a-5073-9a59-9bdb34cd675d",
    "school_code": "ESJM",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "MASTÈRE DROIT DES AFFAIRES ET DU NUMÉRIQUE",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "34a6685d-6661-5dcb-9d12-5edc1071951e",
    "school_code": "ESART",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "MASTER'S DEGREE IN BUSINESS ENGINEERING",
    "source_file": "forms/esart.html"
  },
  {
    "id": "34e026fe-c500-5129-b6f1-a8a53482b8d4",
    "school_code": "ESMEP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "FINANCE",
    "name": "MASTERE COMPTABILITE AUDIT ET CONTROLE DE GESTION (CAC)",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "35393caf-0f3c-58af-94fa-57551310dcf5",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Stratégie et Management International",
    "name": "Bachelor Responsabilité Societale des Entreprises",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "35478a5f-c254-59c2-8911-1e8d8d656393",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Intercultural Risk Management",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "355337fe-97b5-5fd1-8953-e4db094df49f",
    "school_code": "EVRY BS",
    "cycle": "BTS",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "BTS Commerce International",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "35858700-6b6a-5609-a84b-f865bffd5b0e",
    "school_code": "ESMAS",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "Master's Degree in Business Engineering",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "3590c0c8-74be-5d9a-926c-60b247e3945a",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Technologie et Data Innovation",
    "name": "Bachelor Informatique et Réseaux",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "35cca63d-431d-516e-9dc3-c28c8142668d",
    "school_code": "EVRY BS",
    "cycle": "Mastères Spécialisés",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "magement et gestion",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "35e970ec-36f8-5d29-93c0-61b6194dbf8f",
    "school_code": "LSB",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Marketing et communication",
    "name": "Bachelor E-commerce",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "3603a632-dbac-52cf-908c-89070f1b009e",
    "school_code": "ESMAS",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "Bachelor's Degree in Sports Management and Representation",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "3608d39e-03d4-5785-abe0-c8736bb74c20",
    "school_code": "ILMIS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in Entrepreneurial Management of Digital Projects and Digital Strategy",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "361a9fee-b30c-5cd7-988a-f8f39d9ef0a0",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN INNOVATION COMMERCIAL MANAGEMENT",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "361c6071-4c5b-5a29-b50b-b4df6c037101",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN PROCURMENT AND LPOGISITCS",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "363368ab-58a2-5d62-bd0a-6cd7af93f229",
    "school_code": "ESEA",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "MASTER'S DEGREE IN MANAGEMENT AND DIGITALISATION OF QHSE PROCESSES",
    "source_file": "forms/esea.html"
  },
  {
    "id": "363e9d74-9d62-5120-9415-96bff39e67f4",
    "school_code": "ESMAS",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "MANAGEMENT-GESTION",
    "name": "Mastère Spécialisé Entrepreneuriat et Business Development Digital (EBD)",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "36bb4ca3-1a12-5452-a7a4-292ca509a312",
    "school_code": "CESCOM",
    "cycle": "MASTÈRE (BAC+5)",
    "academic_level": null,
    "domain": "DESIGN-CRÉATION",
    "name": "Mastère Direction Artistique",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "375bdc45-552a-53ce-aabc-f709b73ac41e",
    "school_code": "LSB",
    "cycle": "Masteres Specialises",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Spécialisé lead developer et management (LD)",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "376c961e-f54d-5cd4-ae06-25217c458abb",
    "school_code": "CESCOM",
    "cycle": "MASTÈRES SPÉCIALISÉS (BAC+6)",
    "academic_level": null,
    "domain": "DROIT-LOGISTIQUE-BUSINESS",
    "name": "MS Droit International",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "37b3712f-2c15-5271-9a96-a77fdba8bb39",
    "school_code": "LSB",
    "cycle": "Masteres Specialises",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Spécialisé en E-Banking et Fintech",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "37c96e67-b94b-5390-83e3-ac8a15c00542",
    "school_code": "MLV BS",
    "cycle": "Nos Bachelors",
    "academic_level": null,
    "domain": "Finance",
    "name": "BACHELOR DIPLÔME DE COMPTABILITÉ ET DE GESTION (DCG)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "381e855d-4fc8-5dfa-8bf5-6aa146a6622a",
    "school_code": "LSB",
    "cycle": "Masteres Specialises",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Spécialisé ingenieur d'affaires (IA)",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "38697736-3ac4-53c1-bd8c-e06829c0b84b",
    "school_code": "ISMOD",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Mode-Innovation",
    "name": "Bachelor Innovation Textile",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "3898a9a9-4d74-55b3-ad21-4b835b6bbcba",
    "school_code": "EVRY BS",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Bachelor Chargé de Communication Digitale, Evenementielle et IA impavct (CDE)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "389f77da-5787-5aa2-918d-51efab370fd5",
    "school_code": "EMSP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in Quality, Health, Safety, and Environment Management",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "38a11c9a-cec4-5517-a3c7-21899d98dce0",
    "school_code": "ESIIA",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Bachelor's Degree",
    "name": "Bachelor's Degree in UX/UI Design",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "38f7c9eb-f340-5a67-a8d6-fa51ba6e5086",
    "school_code": "ESETH",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "MASTER'S DEGREE IN MANAGEMENT AND DIGITALISATION OF QHSE PROCESSES (MD-QHSE)",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "38ff2208-0b32-5c26-9a39-29724f0f929c",
    "school_code": "EMSP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in Human Resources and Digitisation of Operations",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "393bcf1f-ea1e-5e34-a5a1-61f8d291540a",
    "school_code": "ESJM",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "MASTÈRE MANAGEMENT DES CRISES ET CONDUITE DE LA TRANSFORMATION (MC2)",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "3991da15-102f-5e6d-aa99-c03fbe9a0b50",
    "school_code": "ESMEP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "MASTER'S DEGREE IN E-HEALTH AND DIGITAL TRANSFORMATION",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "39937598-db34-51d2-a5c6-eb89496fe120",
    "school_code": "LSB",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Management et gestion",
    "name": "bachelor en ressources humaines (Rh)",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "39cb5fd5-fc55-5107-a5b9-ee4e4b9c49fe",
    "school_code": "ESETH",
    "cycle": "MASTÈRE SPÉCIALISÉ",
    "academic_level": null,
    "domain": "TOURISME-EVÈNEMENTIEL",
    "name": "MASTÈRE SPÉCIALISÉ TOURISME DURABLE ET SMART DESTINATION",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "3a1a26a5-9e38-584a-bffd-04f48eccbdcd",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Management et Gestion",
    "name": "Bachelor Ressources Humaines",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "3a2ac020-09d4-5341-a7d0-4d72bc63a628",
    "school_code": "ISMOD",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Mode-Innovation",
    "name": "Mastère Innovation Textile et Management (ITM)",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "3a3c5b87-0588-5c2a-a49d-4bde58a2a1bd",
    "school_code": "EMSP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in Digital Marketing and Communication",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "3a8f504a-a916-5067-a329-93784c1ef464",
    "school_code": "ISMOD",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Gestion-Luxe",
    "name": "Mastère Gestion de Marque et Branding",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "3b2ec122-3157-5975-8c1d-23ced33a829b",
    "school_code": "CESCOM",
    "cycle": "NIVEAU BAC",
    "academic_level": null,
    "domain": "TITRES PROFESSIONNELS",
    "name": "TP CONSEILLER COMMERCIAL",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "3b730b97-2399-588c-8301-3a367399ad89",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Procurement and Logistics",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "3c47b591-752e-50bc-89f6-05df30645f7d",
    "school_code": "ESIIA",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Master's Degree",
    "name": "Master's Degree in E-Banking and Fintech",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "3c4bb6a4-2ece-57a6-9164-705ce9c7e1a8",
    "school_code": "ESMEP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "MASTER'S DEGREE IN DIGITAL MARKETING AND COMMUNICATION",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "3c96f663-4f88-5d75-b796-b4f51bd8ddda",
    "school_code": "EMSP",
    "cycle": "Mastère spécialisé",
    "academic_level": "Mastère spécialisé",
    "domain": "Management et Gestion",
    "name": "Mastère Spécialisé en Management et Numérisation des Processus QHSE",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "3ca96cb8-e06c-5d81-ad16-214a9f200fa4",
    "school_code": "ESMAS",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "FINANCE-GESTION",
    "name": "BACHELOR SMART SELLING & NÉGOCIATION (NÉGO-VENTE)",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "3ce74f3f-71db-5c6c-a9bd-d922ce1c7fb5",
    "school_code": "ESMAS",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "Bachelor's Degree in Sports Facility Management",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "3d05cafb-8f08-5f33-9827-4652db836733",
    "school_code": "EVRY BS",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Bachelor Gestion de L'Innovation(GIN)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "3d078472-4c6c-5344-b9f4-52b4e04daef2",
    "school_code": "EMSP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in Business Development Management",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "3d08b66a-59f9-5a17-ae49-46ada11a61b0",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Commerce - Vente",
    "name": "Bachelor Commerce International",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "3d10078a-a44c-552c-b2d2-4028e879cde5",
    "school_code": "EMSP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in Digital Product Management",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "3d37a897-5854-58f5-be50-a44817d6f012",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Commerce - Vente",
    "name": "Bachelor Chef de Produit",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "3d945a9a-56e2-5e87-9c90-a7d4d6dac70e",
    "school_code": "EVRY BS",
    "cycle": "BTS",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "BTS Négociation et Digitalisation de la Relation Client (NDRC)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "3dea0757-f51f-58fd-beff-fb6577d01e8d",
    "school_code": "EVRY BTS",
    "cycle": "BTS (Brevet de Technicien Supérieur)",
    "academic_level": null,
    "domain": "FINANCE",
    "name": "BTS COMPTABILITÉ ET GESTION (CG)",
    "source_file": "forms/evry-bts.html"
  },
  {
    "id": "3e0433ec-2105-5b7b-b391-0399b8d87fe6",
    "school_code": "ESMEP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "MASTER'S DEGREE IN ENTREPRENEURIAL MANAGEMENT, DIGITAL STRATEGY( PN-SD)",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "3e318b4c-d5b7-570a-a8ee-e09952df79cd",
    "school_code": "MLV BS",
    "cycle": "Nos Mastère Spécialisé",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Spécialisé Administration Systèmes, Réseaux et Cybersécurité (SRC)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "3e54011e-069a-5b99-9d50-6e3ac19a9a62",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Management et Gestion",
    "name": "Bachelor Responsabilité Sociétale des Entreprises",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "3e7c8044-3e98-5e03-8882-fb7e04018ac0",
    "school_code": "EVRY BS",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Master's Degree",
    "name": "master's degree in strategic management and business intelligence (SIE)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "3e912a02-0d43-5ec5-9d78-2fff103ef1da",
    "school_code": "ILMIS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in Human Resources and Digitisation of Operations",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "3f293fb4-74b0-56a8-bd5c-64c56d34a26a",
    "school_code": "ESIIA",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Bachelor Intelligence Artificielle et Gestion",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "3f3524cc-0a7a-5a51-b44c-24eb180843b1",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Technologie et Data Innovation",
    "name": "Bachelor Marketing Digital et Data",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "3f39e6e2-1095-5afc-8f2d-0d7394b0340b",
    "school_code": "ESETH",
    "cycle": "MASTÈRE SPÉCIALISÉ",
    "academic_level": null,
    "domain": "MARKETING-HÔTELLERIE",
    "name": "MANAGER DES ETABLISSEMENTS HÔTELIERS ET SMART HOSPITALITY (MH)",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "3f48cba5-35ec-5186-9471-641701911710",
    "school_code": "MLV BS",
    "cycle": "Nos Bachelors",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "BACHELOR UX/UI DESIGN (UX)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "3f7b97e1-89a7-56fb-9e82-997f1cfef568",
    "school_code": "ESART",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "COMMUNICATION - MANAGEMENT",
    "name": "MASTÈRE MANAGEMENT DE LA MUSIQUE",
    "source_file": "forms/esart.html"
  },
  {
    "id": "3fa57cb4-3752-5907-8d3f-f1590c90070e",
    "school_code": "EMSP",
    "cycle": "MBA",
    "academic_level": "MBA",
    "domain": "MBA",
    "name": "Master of Business Administration (MBA)",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "400ec8c2-d24b-5be3-8397-9a0b06374aba",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "MANAGEMENT ET GESTION",
    "name": "BACHELOR EN GESTION DE L'INNOVATION",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "403cc577-caa6-5e87-bc76-22d2ff514743",
    "school_code": "ESART",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "COMMUNICATION - MANAGEMENT",
    "name": "MASTÈRE SPÉCIALISÉ MANAGEMENT DE LA MUSIQUE",
    "source_file": "forms/esart.html"
  },
  {
    "id": "403fa161-a483-597e-a17a-c7a3a38ac74f",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Commerce - Vente",
    "name": "Bachelor Négociation et Vente",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "40473829-f178-54b6-802e-a74670330b78",
    "school_code": "ILMIS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère E-Banking et Fintech",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "406982ca-2b2a-5d93-b1ae-f2786245bdb5",
    "school_code": "ESUV",
    "cycle": "Mastères",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère Creation de Marque et Identité Produit(MIP)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "407419e8-6fb2-5e28-9592-2dae6dcbc14a",
    "school_code": "ESJM",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "BACHELOR DROIT DES ENTREPRISES",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "409d2009-a6bb-5063-924c-30e40869be57",
    "school_code": "LSB",
    "cycle": "Masteres",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère E-Banking et Fintech",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "415b674d-2e59-5ccb-82de-59adc3480bfb",
    "school_code": "ESMOSS",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "SANTÉ-DIGITALE",
    "name": "Mastère Spécialisé e-Santé et Transformation Gigitale(e-Santé)",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "41742980-cc6b-577d-9a18-c0c36dc93eb7",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "Bachelor's Degree in Business Law",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "41841865-0d16-5865-a872-d31937d80060",
    "school_code": "EMSP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Comptabilité Audit et Contrôle de Gestion (CAC)",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "4194ca87-59e5-5041-94e5-cd6d539c87d0",
    "school_code": "ESART",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "AUDIOVISUEL - CINÉMA - PRODUCTION",
    "name": "MASTÈRE SPÉCIALISÉ PRODUCTION AUDIOVISUELLE (PA)",
    "source_file": "forms/esart.html"
  },
  {
    "id": "41e3db95-3f51-5b44-918d-ba3f493b5a0e",
    "school_code": "LSB",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Marketing et communication",
    "name": "Bachelor commerciale",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "42859d3f-95e4-5525-bdbb-0f33d99050ae",
    "school_code": "ESUV",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Bachelor Marketing et communication(MC)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "428b622c-72ff-5ed0-bbde-62f8d29e07df",
    "school_code": "ESIIA",
    "cycle": "Mastères Spécialisés",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Spécialisé Architecture des Systèmes Informatiques",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "428df660-dca3-5340-8166-3597b1ac31ad",
    "school_code": "EMSP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère Management et Numérisation des Processus QHSE",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "42f6ba18-9c91-5dad-8c3d-b352dbd9af62",
    "school_code": "ESJM",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "MASTÈRE SPÉCIALISÉ MANAGEMENT DES CRISES ET CONDUITE DE LA TRANSFORMATION (MC2)",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "43169610-57fd-5555-9657-6223c9e8c83c",
    "school_code": "ILMIS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in Management and Strategy",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "437e4fd4-b147-5ff8-a9e0-58e443f0fbe7",
    "school_code": "ESMEP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "FINANCE",
    "name": "MASTÈRE EN E-BANKING ET FINTECH",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "4424562f-c283-5e02-8fca-cb3ea68f2343",
    "school_code": "LSB",
    "cycle": "Masteres",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Commerce International et Digitalisation (CID)",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "44473191-617b-5147-ab59-e1b541f5362d",
    "school_code": "ESMEP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "MASTER'S DEGREE IN ENTREPRENEURSHIP AND BUSINESS DEVELOPMENT",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "44532b83-5b51-5dae-b40b-46190938b18f",
    "school_code": "ILMIS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in Management and Digitisation of QHSE Processes",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "44a14da3-7425-50c3-9968-8e4f1da30c52",
    "school_code": "ESEA",
    "cycle": "MBA",
    "academic_level": null,
    "domain": "MBA",
    "name": "MASTER OF BUSINESS ADMINISTRATION",
    "source_file": "forms/esea.html"
  },
  {
    "id": "44a2db1e-4e36-57eb-8a65-96c461191ce9",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "Bachelor’s Degree in International Business",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "44e30099-fbc8-5a80-8d9b-0a61aa54ebcd",
    "school_code": "ESMOSS",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "BUSINESS-LOGISTIQUE",
    "name": "Bachelor Gestion et Numerisation des Achats Logistique (AL)",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "450d3f98-44b4-5ee4-8c0c-3cfdcb55743d",
    "school_code": "ESART",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "BACHELOR'S DEGREE IN SCREENWRITING",
    "source_file": "forms/esart.html"
  },
  {
    "id": "450f5a44-752c-590a-aad9-637f33b3dd61",
    "school_code": "ESJM",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "MASTÈRE SPÉCIALISÉ DROIT DES AFFAIRES ET DU NUMÉRIQUE",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "454e20f1-f4be-5ada-b6e7-42915107e5b9",
    "school_code": "MLV BTS",
    "cycle": "BTS (Brevet de Technicien Supérieur)",
    "academic_level": null,
    "domain": "MODE ET LUXE",
    "name": "BTS MCO (MANAGEMENT COMMERCIAL ET OPÉRATIONNEL) OPTION LUXE",
    "source_file": "forms/mlv-bts.html"
  },
  {
    "id": "4558394d-4110-59b5-9129-d277a63555ea",
    "school_code": "ISMOD",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Communication-Vente",
    "name": "Bachelor Achats et Logistiques (AL)",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "4575892b-84bf-5c0f-883a-8e326fe96306",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "COMMERCE - VENTE",
    "name": "BACHELOR E-COMMERCE",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "45844539-612e-5766-a6df-9098e9a6715c",
    "school_code": "EMSP",
    "cycle": "Mastère spécialisé",
    "academic_level": "Mastère spécialisé",
    "domain": "Finance",
    "name": "Mastère Spécialisé en Banque Finance et Assurance",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "46871f61-187c-50e7-af78-ffcc8bed6ad3",
    "school_code": "EMSP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère UX-Designer",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "46d4ca44-e201-592c-a27b-c6d901829e28",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN MARKETING AND COMMUNICATION ( INNOVATION MANAGEMENT)",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "46eb239a-4787-5ff0-be07-0be043a7c5ef",
    "school_code": "ESMEP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "MASTER'S DEGREE IN MANAGEMENT AND DIGITALISATION OF PROCURMENT AND LOGISTICS PROCESSES",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "46ee3cda-3e75-5b21-be87-8faac0828acd",
    "school_code": "EMSP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastères Managements de Projets et de l'Innovation",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "47008de2-141d-5579-8d0b-2ff6365346aa",
    "school_code": "ILMIS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in E-Health and Digital Transformation",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "47154538-293f-58d2-be1d-9a41786f5bb5",
    "school_code": "MLV BS",
    "cycle": "Nos Bachelors",
    "academic_level": null,
    "domain": "Marketing et Communication",
    "name": "BACHELOR START-UP ET BUSINESS DEVELOPMENT (SBD)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "47182f22-f124-5e18-9427-6cbc708773f9",
    "school_code": "MLV BS",
    "cycle": "Nos Mastères",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "MASTÈRE MANAGEMENT ET DIGITAALISATION DES PROCESSUS ACHATS ET LOGISTIQUE",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "47333a35-5c83-504b-92be-36fff0184987",
    "school_code": "ESETH",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "TOURISME-EVÈNEMENTIEL",
    "name": "MASTÈRE TOURISME DURABLE ET SMART DESTINATION (TD)",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "473b08a8-fa1f-53f8-ad9d-40685846ef51",
    "school_code": "MLV BS",
    "cycle": "Nos Mastères",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Lead Developer et Management (LD)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "47619fdc-abbf-51f3-862f-ef4077182805",
    "school_code": "CESCOM",
    "cycle": "MASTÈRE (BAC+5)",
    "academic_level": null,
    "domain": "MARKETING-MANAGEMENT",
    "name": "Mastère Marketing Stratégique",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "47bccbfe-4684-5f47-9975-ff5ad5122ebb",
    "school_code": "ISMOD",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Communication-Vente",
    "name": "Bachelor Chargé de Communication Digitale, Événementielle et à Impact",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "47bfad85-73e2-5922-8ac6-7b7639a4ed01",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Management et Gestion",
    "name": "Bachelor Achats et Logistique",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "4807300d-a9f5-58a0-b60c-8204ed17b5a3",
    "school_code": "ESMEP",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "COMMERCE - VENTE",
    "name": "MASTÈRE SPECIALISE EN MARKETING COMMUNICATION-DIGITALES",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "480b1bf9-a2f5-54c2-8f24-6713d951d9eb",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Start-up and Business Development",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "48a81576-4886-57ea-ac26-fa8db5a59c34",
    "school_code": "ESMOSS",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "SANTÉ-DIGITALE",
    "name": "Mastère Spécialisé Management des Produits Digitaux (MPD)",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "48d539ea-a986-5342-bfff-d5cc2d7c50cd",
    "school_code": "ESART",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "MASTER'S DEGREE IN PERFORMING ARTS AND LIVE ENTERTAINMENT",
    "source_file": "forms/esart.html"
  },
  {
    "id": "48df55ee-1ae1-5170-ace9-b04dc66e7fd6",
    "school_code": "ESMAS",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "SPORT-BUSINESS",
    "name": "BACHELOR GESTION DU SPORT ET DIGITALISATION (GS)",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "48f9bc5f-9c83-5596-84f2-926da29c3332",
    "school_code": "ESEA",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "MASTER'S DEGREE IN SUSTAINABLE AGRIBUSINESS AND IMPACT (SAI)",
    "source_file": "forms/esea.html"
  },
  {
    "id": "49141eed-4b90-5f71-ab02-34781fd32d1e",
    "school_code": "ISMOD",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Mode-Innovation",
    "name": "Bachelor Mode et Entrepreneuriat",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "4927b236-689f-534e-bdd4-bb487c65ab3e",
    "school_code": "ESART",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "COMMERCE-GESTION-BUSINESS DEVELOPMENT",
    "name": "BACHELOR E-COMMERCE",
    "source_file": "forms/esart.html"
  },
  {
    "id": "4962011a-43c4-5528-a266-92ceecf72bd8",
    "school_code": "ESEA",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "MANAGEMENT ET GESTION",
    "name": "MASTÈRE CONSULTANT RSE ET CONDUITE DU CHANGEMENT",
    "source_file": "forms/esea.html"
  },
  {
    "id": "499a7e18-a086-557c-8d7c-6afbb0c3efb3",
    "school_code": "ESMEP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "MANAGEMENT ET GESTION",
    "name": "MASTÈRE EN DROIT DES AFFAIRES ET MANAGEMENT",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "49ac8f6b-110b-5aad-8250-d002b774ea72",
    "school_code": "LSB",
    "cycle": "Masteres",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Finance de Marché et Management des Risques",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "49f3d2c3-38a8-5505-ab96-6bd12a1158cd",
    "school_code": "EVRY BTS",
    "cycle": "BTS (Brevet de Technicien Supérieur)",
    "academic_level": null,
    "domain": "FINANCE",
    "name": "BTS BANQUE",
    "source_file": "forms/evry-bts.html"
  },
  {
    "id": "4a4dafb5-2bb8-5495-a4e9-33f54ff6fdf4",
    "school_code": "ESIIA",
    "cycle": "Mastère",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Administration Systèmes, Réseaux et Cybersécurité",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "4a6f066c-3ac4-5920-a49f-d4e584356401",
    "school_code": "ILMIS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastères Managements de Projets et de l'Innovation",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "4a70a34f-d611-5756-aad9-e8f329588179",
    "school_code": "CESCOM",
    "cycle": "BTS (BAC+2)",
    "academic_level": null,
    "domain": "COMMERCE-VENTE",
    "name": "BTS Commerce International (CI)",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "4aaad412-8c24-517e-9508-1b14cb45f6df",
    "school_code": "EVRY BS",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Bachelor's Degree",
    "name": "Bachelor's Degree in sale and negotiation",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "4ad27ce3-975f-5e02-937b-ef29e8daedce",
    "school_code": "ILMIS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in Project and Innovation Management",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "4aee5f5c-5768-5c5d-8f61-c1dc3303c4a6",
    "school_code": "MLV BTS",
    "cycle": "BTS (Brevet de Technicien Supérieur)",
    "academic_level": null,
    "domain": "COMMERCE - VENTE",
    "name": "BTS NDRC (NÉGOCIATION ET DIGITALISATION DE LA RELATION CLIENT)",
    "source_file": "forms/mlv-bts.html"
  },
  {
    "id": "4b5faffd-1e07-5e58-aac4-3fc0f22b011d",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Spécialisé en E-Banking et Fintech",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "4b77ebfa-d580-5135-bc12-d39ef5d524ef",
    "school_code": "ESJM",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "MASTÈRE SPÉCIALISÉ CYBERSÉCURITÉ ET MANAGEMENT DES DONNÉES PERSONNELLES (CDP)",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "4c0e47f6-6cec-5f65-9a71-69c7c92a51d2",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "Higher Diploma in Accounting and Management (DSCG)",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "4c453e38-1b82-509a-9458-d0a035b1e84c",
    "school_code": "ESUV",
    "cycle": "Mastères Spécialisés",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "mastere spécialise creation de marque et identité-produit (MIP)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "4c716f46-f4f5-56aa-b49a-da26169322ff",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN HEALTH MANAGEMENT AND TRANSFORMATION",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "4ca673e7-8ce8-582c-b247-b396d85aa0fc",
    "school_code": "ESMOSS",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "SANTÉ-DIGITALE",
    "name": "Mastère Spécialisé Transformation Digitale en Santé",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "4d35cf09-aaa6-5d09-9c69-e8ef68292f79",
    "school_code": "EVRY BS",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Master's Degree",
    "name": "Master degree in entrepreneurship and business development (EBD)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "4d361eea-bb10-589b-88ce-161b3d7ee76f",
    "school_code": "MLV BS",
    "cycle": "Nos Bachelors",
    "academic_level": null,
    "domain": "Finance",
    "name": "BACHELOR GESTION DES OPÉRATIONS DE MARCHÉS FINANCIERS (GMF)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "4d7d5631-f793-5443-b32f-17e0be6673a6",
    "school_code": "ESUV",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Bachelor Responsable des Etablissements Marchands(REM)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "4d87e712-d6e3-595b-80ba-cca42183ac78",
    "school_code": "CESCOM",
    "cycle": "NIVEAU BAC",
    "academic_level": null,
    "domain": "TITRES PROFESSIONNELS",
    "name": "TP CONSEILLER EN VENTE",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "4dbdd4e4-3781-5127-a05a-f4476e9f65bf",
    "school_code": "LSB",
    "cycle": "Masteres",
    "academic_level": null,
    "domain": "Stratégie et Management International",
    "name": "Mastère Management et Stratégie (MS)",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "4dc5d0d1-b2af-53ad-9f5c-55c6d1166739",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Commerce - Vente",
    "name": "Bachelor Gestion des Risques Interculturels",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "4dc749dd-07d6-52d9-bbb4-9e3e2cb3b873",
    "school_code": "ESMEP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "MASTER'S DEGREE IN ENTREPRENEURIAL MANAGEMENT, DIGITAL STRATEGY( PN-SD)",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "4e3e7592-7dd7-5b93-a4c6-299bc8104377",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Technologie et Data Innovation",
    "name": "Bachelor Marketing Digital et Data",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "4ea12950-990e-50dc-b09e-32ef10d554d1",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "COMMERCE - VENTE",
    "name": "BACHELOR START-UP ET BUSINESS DEVELOPMENT",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "4ebd8c61-6370-5bd9-a232-afef7e9cc17a",
    "school_code": "ESUV",
    "cycle": "BTS",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "BTS Technico Commercial",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "4ed907b8-57f2-5586-b477-6b57018f647d",
    "school_code": "ESUV",
    "cycle": "BTS",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "BTS Support à l'Action Managériale (SAM)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "4eeb1bae-72dd-5dea-a040-737cb460a3b0",
    "school_code": "LSB",
    "cycle": "Masteres",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Banque Finance et Assurance",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "4f06ebe8-345b-5738-91df-d996356ae242",
    "school_code": "CESCOM",
    "cycle": "BACHELOR (BAC+3)",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "Bachelor Marketing Digital",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "4fad4490-d97b-5e36-ae9c-4b33a44fc495",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Commerce - Vente",
    "name": "Bachelor Commerce International",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "5014a745-ab69-5b24-a21e-73ac1fb6d960",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Stratégie et Management International",
    "name": "Bachelor Gestion des Risques Intercurels",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "501794d4-c6fd-5ad5-b3e6-52f8a846ad6e",
    "school_code": "ILMIS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Affaires Internationales et Enjeux Digitaux",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "502aac08-33bb-50a8-a38e-82134035c4df",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère en Comptabilité, Audit et Contrôle de Gestion",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "503a09e3-e249-51c6-a0ca-05fe12167e1b",
    "school_code": "ILMIS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Management des Produits Digitaux",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "506478f0-781a-57b0-95f5-4e6a02a9b18c",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "MANAGEMENT ET GESTION",
    "name": "BACHELOR EN DROTI DES ENTREPRISES",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "50bb73d9-b0a3-58c5-a52a-a12f475466d7",
    "school_code": "ESART",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "DESIGN-CRÉATION",
    "name": "MASTÈRE UX DESIGN (UX)",
    "source_file": "forms/esart.html"
  },
  {
    "id": "50bd0dac-3ca6-5c31-934a-c4d5fbb5472c",
    "school_code": "ILMIS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère en Ingénieur(e) d'Affaires",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "50cd1163-9228-569b-9dce-f4aecd656fe5",
    "school_code": "ESMAS",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "Mastère Management des Produits Digitaux (MPD)",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "512d6743-0279-5f96-99bd-f665fb0bbe24",
    "school_code": "ESMEP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "MASTER'S DEGREE IN QUALITY, HEALTH, SAFETY AND ENVIRONNMENT (QHSE) ENVIRONMENT",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "514617b8-f44e-5b9e-8570-4fb4608ac063",
    "school_code": "EMSP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Finance de Marché et Management des Risques",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "5173b467-206c-5b53-8345-32dffa640b73",
    "school_code": "ESUV",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Bachelor's Degree",
    "name": "Bachelor's Degree in sale and negotiation",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "51842061-61e7-58be-8fbc-a5e2fb79053c",
    "school_code": "ESIIA",
    "cycle": "Mastère",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Stratégie Publicitaire et Identité-Produit",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "51ac231c-bdba-5eb0-9333-4d4e6e410711",
    "school_code": "ESMEP",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "MASTÈRE SPÉCIALISÉ E-SANTE ET TRANSFORMATION DIGITALE",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "523c23f0-0e1f-5406-8d13-d6e98cb16f7f",
    "school_code": "ESIIA",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Bachelor's Degree",
    "name": "Bachelor's Degree in Artificial Intelligence and Management",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "529781d1-4821-57dd-b72d-cbc21cb1759a",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Human Resources",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "529db2f6-78de-5c78-a500-3c6efb2c9eab",
    "school_code": "ESUV",
    "cycle": "Mastères",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Responsable CommunicationDigitale(MCD)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "52c21e5c-50c1-565e-83d2-81b129bc5432",
    "school_code": "ESMAS",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "MANAGEMENT-GESTION",
    "name": "MASTÈRE START-UP ET DÉVELOPPEMENT DE L'INDUSTRIE SPORTIVE CONNECTÉE (SIS)",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "53154555-c192-54a0-96b6-55e9cb3d2d4f",
    "school_code": "ESMEP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "FINANCE",
    "name": "MASTERE BANQUE FINANCE ET ASSURANCE",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "5379f37b-0e9e-547b-810a-3f8e08828ca0",
    "school_code": "EMSP",
    "cycle": "Mastère spécialisé",
    "academic_level": "Mastère spécialisé",
    "domain": "Finance",
    "name": "Mastère Spécialisé en E-Banking et Fintech",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "53cf40c9-780d-553b-acd8-6032b6d0545c",
    "school_code": "ESUV",
    "cycle": "NIVEAU BAC",
    "academic_level": null,
    "domain": "niveau bac",
    "name": "TP conseiller relation client a distance",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "53dfb0c1-2e98-5987-8cd0-86183c488e03",
    "school_code": "ESMOSS",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "Bachelor's Degree in Health and Social Care with Support for Vulnerable Individuals",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "53fd8bba-0c28-52f8-8104-8a81c6170ae8",
    "school_code": "EMSP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère Ressources Humaines",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "54293c47-0583-5826-88f9-8d7ead215c75",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "COMMERCE - VENTE",
    "name": "BACHELOR EN GESTION COMMERCIALE",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "5437b0c4-2f21-5c30-a396-01b12f02711a",
    "school_code": "LSB",
    "cycle": "Masteres Specialises",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Spécialisé en Marketing et communication digitales",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "54877836-d252-5ff8-b584-61839fdb932c",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Stratégie et Management International",
    "name": "Bachelor Commerce International et Logistique",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "549ad717-0c99-56aa-9ce4-d7d009f8012a",
    "school_code": "ISMOD",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Communication-Vente",
    "name": "Mastère Responsable Communication Digitale, Événementielle et à Impact (CDEI)",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "54dba609-e1f7-5ef0-8296-e15a99021145",
    "school_code": "MLV BS",
    "cycle": "Nos Bachelors",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "BACHELOR EN GESTION DE LA QUALITÉ, HYGIÈNE, SÉCURITÉ ET ENVIRONNEMENT (QHSE)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "550e14e9-6f8f-57fa-ba76-e9dd55725f22",
    "school_code": "ESART",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "COMMUNICATION - MANAGEMENT",
    "name": "MASTÈRE RESPONSABLE COMMUNICATION DIGITALE, ÉVÈNEMENTIELLE (CDE)",
    "source_file": "forms/esart.html"
  },
  {
    "id": "55528cd1-2b6f-5386-a91a-fc831d3f9d9a",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN HUMAN RESOURCES",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "55a3b4be-ce65-5282-8e1e-7f71d98fb240",
    "school_code": "ESMAS",
    "cycle": "MBA",
    "academic_level": null,
    "domain": "MBA",
    "name": "MASTER OF BUSINESS ADMINISTRATION (MBA)",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "55a3fe87-b1e6-5cba-ad54-4d83aca361ad",
    "school_code": "ESIIA",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Bachelor Administration Systèmes, Réseaux et Cybersécurité",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "55ef2880-6239-5121-9bbe-7cc648a17c26",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Marketing and Communication",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "5653e5a8-b313-5241-811c-27eafe0f163b",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Finance de Marché et Management des Risques",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "56974e9c-179e-5f37-9919-844dd07af857",
    "school_code": "ILMIS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Finance de Marché et Management des Risques",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "56a0f0aa-b730-5277-b49c-c691489eb8c3",
    "school_code": "EVRY BS",
    "cycle": "NIVEAU BAC",
    "academic_level": null,
    "domain": "niveau bac",
    "name": "TP animation et gestion de l'espace commercial",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "56fbc1bf-b2d2-5f6e-a4dd-7b5e94828310",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "Bachelor’s Degree in International Management and Business",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "56fbc932-b239-5cc9-8820-7e87f8ee17fb",
    "school_code": "EVRY BS",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Bachelor en Commerce International(CI)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "56ffbb5c-6a2b-5b29-a1bd-43394b7c52a1",
    "school_code": "ESIIA",
    "cycle": "Mastère",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère E-Business et Stratégie Digitale",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "574e4068-7e82-5f9a-8420-736eeb377b26",
    "school_code": "ILMIS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère Ressources Humaines",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "57eaa0a3-15d3-5186-b1be-d59132a3a44f",
    "school_code": "ESMOSS",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "SANTÉ-DIGITALE",
    "name": "Mastère Management et Digitalisation des Process QHSE (MD-QHSE)",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "588e908d-565b-5e0b-abe7-fdb6ced8ce4d",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN PROCURMENT AND LPOGISITCS",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "58aa1563-9bd2-5213-9755-606704f582f8",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Commerce - Vente",
    "name": "Bachelor Start-up et Business Development",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "58b85eff-8bea-50e3-8ead-9a354d25d4f0",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Management et Gestion",
    "name": "Bachelor Gestion des Organisations",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "590b4fe5-b3ec-585c-b24a-b07dff318df7",
    "school_code": "ESMEP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "MASTER'S DEGREE IN QUALITY, HEALTH, SAFETY AND ENVIRONNMENT (QHSE) ENVIRONMENT",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "5a0299df-552c-5d57-b2dd-88fd7bc669e1",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN HEALTH MANAGEMENT AND TRANSFORMATION",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "5a7f3a2f-9b37-5c88-b15d-2b8c8d75a335",
    "school_code": "ESJM",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "BACHELOR'S DEGREE",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "5b22862f-caf4-54b3-9685-4357a817c5a3",
    "school_code": "ESIIA",
    "cycle": "Mastère",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Big Data et Marketing Digital",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "5b613c67-96cc-559f-b5c2-0c60fd174035",
    "school_code": "ILMIS",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Spécialisé en Manager Entrepreneuriel de Projet Numérique et Stratégie Digitale",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "5bfa97ac-2b0f-5cf2-a093-fb187200d553",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "STRATÉGIE ET MANAGEMENT INTERNATIONAL",
    "name": "BACHELOR EN GESTION DE LA SANTE ET DE LA TRANSFORMATION NUMERIQUE",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "5c8e5005-b29b-51c6-b7fa-4fda37af32ce",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère Spécialisé en Management de la Qualité, Hygiène, Sécurité et Environnement",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "5cb03e40-daa6-5f45-85fd-d1d16cc80634",
    "school_code": "ESART",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "COMMUNICATION - MANAGEMENT",
    "name": "MASTÈRE SPÉCIALISÉ RESPONSABLE COMMUNICATION DIGITALE, ÉVÈNEMENTIELLE ET IA IMPACT",
    "source_file": "forms/esart.html"
  },
  {
    "id": "5dbadbed-2f25-5fa4-bb17-ae1db4ced892",
    "school_code": "ESUV",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Bachelor Achat et Logistique(AL)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "5df08329-bbf3-55bb-b01e-c8757a7d772c",
    "school_code": "ISMOD",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Communication-Vente",
    "name": "Bachelor Achats et Logistiques (AL)",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "5df5cbfc-22ec-554d-b193-979563863299",
    "school_code": "CESCOM",
    "cycle": "BACHELOR (BAC+3)",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "Bachelor Développement Web",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "5e07e5a0-8a1b-5899-b33a-11baa8810e32",
    "school_code": "LSB",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "bachelor UX-UI DESIGN (UX)",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "5e0b726e-63ac-5dc5-84f2-b29053b57a40",
    "school_code": "ESMOSS",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "MANAGEMENT-GESTION",
    "name": "Mastère Ingenieur(e) d'Affaires et Transition",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "5e1961db-232a-5fa1-9470-0d4467e9a1b1",
    "school_code": "ESUV",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Bachelor's Degree",
    "name": "Bachelor's Degree in digital and event communication with ai impact",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "5e5619ec-69f1-5472-941d-0295dcac9b54",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère Management de Projet et de l'Innovation",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "5e7b4b1a-0234-55d0-8db2-79a25dad7363",
    "school_code": "EMSP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère E-Banking et Fintech",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "5ec6dda3-4cc0-520c-80e1-a6c6d5e144e1",
    "school_code": "ESETH",
    "cycle": "MASTÈRE SPÉCIALISÉ",
    "academic_level": null,
    "domain": "MANAGEMENT-ENTREPRENARIAT",
    "name": "MASTÈRE SPÉCIALISÉ MANAGEMENT DE LA DURABILITE ET NUMERIQUE RESPONSABLE",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "5f069985-08d2-51d4-abd6-62fd2ca83b8c",
    "school_code": "ISMOD",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Mode-Innovation",
    "name": "Mastère Management de la Mode et des Industries Créatives (MIC)",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "5f75fea3-8ba7-5427-b225-a459f1f01263",
    "school_code": "EVRY BTS",
    "cycle": "BTS (Brevet de Technicien Supérieur)",
    "academic_level": null,
    "domain": "MANAGEMENT ET GESTION",
    "name": "BTS SAM",
    "source_file": "forms/evry-bts.html"
  },
  {
    "id": "5f87e300-70e5-5ec5-be97-e9773f31ded0",
    "school_code": "LSB",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "bachelor chef de projet informatique (CPI)",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "5fd43a2f-0949-56c8-b6a8-f33753345f45",
    "school_code": "ILMIS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Stratégie et Management International",
    "name": "Mastère Management et Stratégie",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "5fdaedfd-1280-5a18-b8c0-e2bc05aae03d",
    "school_code": "ILMIS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère UX-Designer",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "5ffb9219-8cea-50ce-9972-e68f088acadb",
    "school_code": "EMSP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère en Management de la Qualité Hygiène Sécurité Environnement",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "603d403a-c3a1-599c-bcff-82dffc8316e0",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "COMMERCE - VENTE",
    "name": "BACHELOR START-UP ET BUSINESS DEVELOPMENT",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "604c23ae-4113-5064-b962-93e1b5110acb",
    "school_code": "CESCOM",
    "cycle": "NIVEAU BAC",
    "academic_level": null,
    "domain": "TITRES PROFESSIONNELS",
    "name": "TP ANIMATION ET GESTION DE L'ESPACE COMMERCIAL",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "60c8a90f-8411-561a-b615-e7d068ffb23d",
    "school_code": "ESEA",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "MASTER'S DEGREE IN PROJECT AND INNOVATION MANAGEMENT",
    "source_file": "forms/esea.html"
  },
  {
    "id": "60fe6b26-59d5-526b-a1a9-eb7767ba7443",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Finance",
    "name": "Bachelor Gestion de Patrimoine",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "6117507e-a761-5718-abfc-72b0eedc0f65",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "MANAGEMENT ET GESTION",
    "name": "BACHELOR EN GESTION DE MARQUE ET BRANDING",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "61363371-0631-50ca-aa99-067b6e40df2e",
    "school_code": "ESUV",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Bachelor's Degree",
    "name": "Bachelor's Degree in E-COMMERCE",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "61a033f5-34b6-58d3-90c0-beacae1c8783",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master's Degree in Business Law and Management",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "61addea3-a077-5c0d-87d2-f23df4fd0787",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "Bachelor’s Degree in International Management and Business",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "61c8b52a-0f07-55dd-af2b-356a6b15f2db",
    "school_code": "ESART",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "COMMERCE-GESTION-BUSINESS DEVELOPMENT",
    "name": "BACHELOR GESTION COMMERCIALE",
    "source_file": "forms/esart.html"
  },
  {
    "id": "625992a4-1741-5c78-8323-0e8493d42197",
    "school_code": "ESEA",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "STRATÉGIE ET MANAGEMENT INTERNATIONAL",
    "name": "BACHELOR GESTION ET NUMÉRISATION QHSE",
    "source_file": "forms/esea.html"
  },
  {
    "id": "625c6871-911a-524e-b1a7-78d0b1a73a16",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Product Management",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "6273343f-ecb5-5bd2-8443-639c7290c870",
    "school_code": "ESJM",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "MASTÈRE MANAGEMENT DE LA CONCURRENCE ET DU NUMÉRIQUE (MCN)",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "629175c8-17c3-53be-91a3-85865c8e8f12",
    "school_code": "ESMOSS",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "SANTÉ-DIGITALE",
    "name": "Mastère Spécialisé Spécialité Management de la Durabilité et Numerique Responsable(RSE)",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "62d02d72-5dec-599f-abff-bd1b321a3746",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "MANAGEMENT ET GESTION",
    "name": "BACHELOR EN GESTION DE MARQUE ET BRANDING",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "633f860c-77e7-54ce-a23a-196ddb2d1b11",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "Bachelor’s Degree in International Management and Business",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "637eb956-dae7-5381-97bd-f55e6dae4aa2",
    "school_code": "ILMIS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in Human Resources and Digitisation of Operations",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "63a69b5a-9626-5ba6-ab14-865698faf2d9",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Commerce - Vente",
    "name": "Bachelor Négociation et Vente",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "64140894-8244-5036-ac08-09cfe01fec59",
    "school_code": "MLV BS",
    "cycle": "Nos Mastères",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère Management et Digitalisation des Processus Achats et Logiques",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "6439752d-da0e-5476-b516-85dffe4e353d",
    "school_code": "ISMOD",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Commerce-Marketing",
    "name": "Mastère Commerce et Marketing",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "64580f7a-00a5-5815-be3a-e84d8b59aedb",
    "school_code": "ISMOD",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "Communication-Vente",
    "name": "Mastère Spécialisé Communication-Vente",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "6463367a-fe6d-5037-af5a-0980d04052b3",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master's Degree in Accounting, Audit and Management Control",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "64e16529-5a2e-55cb-9735-b2a634c5b1ff",
    "school_code": "ISMOD",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master in Fashion and Luxury Management",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "64ef5a78-0c53-5b07-b9b5-e36ee7d11d02",
    "school_code": "CESCOM",
    "cycle": "BACHELOR (BAC+3)",
    "academic_level": null,
    "domain": "MANAGEMENT ET GESTION",
    "name": "Bachelor Gestion de Projet",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "64fd298c-20f1-5ab6-97f8-5c5ec5c3210a",
    "school_code": "ESMAS",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "Mastère Management et Digitalisation des Processus Achats et Logistique (MD-AL)",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "6527fe95-6445-5def-ac5b-e312ceee0e3f",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère Spécialisé en Management Stratégique et Intelligence Économique",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "655a399d-7a9c-5a95-afd6-c22512916bae",
    "school_code": "ESUV",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Bachelor Gestion de L'Innovation(GIN)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "6561607a-b11a-5eda-914e-a2a98f4bd9d7",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Management et Gestion",
    "name": "Bachelor Gestion de Projets",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "656b4476-6692-59ae-9eb2-edfd3ab610a1",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master's Degree in E-Banking and Fintech",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "657ae9df-59dd-5b0f-bffc-87fe4bcf3808",
    "school_code": "CESCOM",
    "cycle": "BACHELOR (BAC+3)",
    "academic_level": null,
    "domain": "COMMERCE-VENTE",
    "name": "Bachelor Développement Commercial",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "6597d125-7768-543d-9866-29912a72fdf8",
    "school_code": "ESIIA",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Bachelor's Degree",
    "name": "Bachelor's Degree Web and Mobile Development",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "6614bc22-be4e-5c53-aa14-7bd9ca030968",
    "school_code": "ESMAS",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "STRATÉGIE ET MANAGEMENT INTERNATIONAL",
    "name": "Mastère Spécialisé Management du Sport (MS)",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "661a1f51-2b82-5530-a6b6-f22ae3eb3a5c",
    "school_code": "LSB",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Management et gestion",
    "name": "bachelor gestion de marque et branding",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "66295f19-3138-5ef2-855a-7debf0e04a92",
    "school_code": "ILMIS",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Spécialisé en E-Santé et Transformation Digitale",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "663d5b4e-68fc-53bc-9919-d7acee2f2bd3",
    "school_code": "ESUV",
    "cycle": "NIVEAU BAC",
    "academic_level": null,
    "domain": "niveau bac",
    "name": "TP animation et gestion de l'espace commercial",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "66504a94-6f9b-5074-ba51-20dcd63ea741",
    "school_code": "ESMEP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "FINANCE",
    "name": "MASTERE BANQUE FINANCE ET ASSURANCE",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "665cde24-ddce-5fbb-adcb-e9f62ba08cf7",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "Stratégie et Management International",
    "name": "Mastère Spécialisé en Management et Stratégie",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "6683b7f0-dfff-522a-91ab-2674f14f5635",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Product Management",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "66f23c00-3447-5cd9-ab57-598045161c6b",
    "school_code": "ESUV",
    "cycle": "Mastères Spécialisés",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Spécialisé entrepreneuriat & business development (EBD)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "66f7bb92-580c-5792-af7f-49da598202d7",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Commerce - Vente",
    "name": "Bachelor Start-up et Business Development",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "670eae87-8732-5c5a-89db-e1f6a7f2074c",
    "school_code": "MLV BS",
    "cycle": "Nos Mastères",
    "academic_level": null,
    "domain": "Finance",
    "name": "MASTÈRE BANQUE FINANCE ET ASSURANCE",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "6719556a-6beb-57d1-aee1-8942248f4f17",
    "school_code": "CESCOM",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "Bachelor in Digital Marketing",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "675aabf5-de12-5fd4-a07e-081daf9ca2a7",
    "school_code": "ESJM",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "MASTER'S DEGREE",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "67603258-b9e0-56df-acb4-0abfc07da78b",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "Bachelor's Degree in Brand Management and Branding",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "6779b4ff-e43b-55ae-b49c-8ff01b006b50",
    "school_code": "ISMOD",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Mode-Innovation",
    "name": "Mastère Innovation Textile et Management (ITM)",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "678bcb3f-3c4a-5816-8c52-425e964189d7",
    "school_code": "LSB",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Management et gestion",
    "name": "bachelor achats et logistique (AL)",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "67922750-67e7-58ed-9518-c2ab669f7721",
    "school_code": "ESMEP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "MASTER'S DEGREE IN BUSINESS LAW AND MANAGEMENT",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "6798b9f7-3aa3-5df0-b980-201ab1768b88",
    "school_code": "ILMIS",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Spécialisé en Management de Projets et de l’Innovation",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "67c6edf6-22d2-5b1e-857f-2e0ad7c37d6f",
    "school_code": "ESMOSS",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "MANAGEMENT-GESTION",
    "name": "Mastère Management des Organuisations de la Santé et Solutions Digitales de Prevention (MOS)",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "683f37c6-3e8f-58de-8eb5-4603d7dd90e0",
    "school_code": "ESETH",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "MASTER'S DEGREE IN HOTEL ESTABLISHMENT MANAGEMENT",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "689c98e9-5b69-57ce-a7eb-10a904b237f6",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master's Degree in Entrepreneurship and Innovation",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "68d8b423-707b-52ef-8afd-5e2bf0cb6134",
    "school_code": "EMSP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Management des Produits Digitaux",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "69e623a9-2084-579c-adaa-9b121d69abb9",
    "school_code": "ESEA",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "MASTERE SPECIALISE MANAGEMENT DE PROJET ET DE L'INNOVBATION",
    "source_file": "forms/esea.html"
  },
  {
    "id": "6a25ab61-2e2a-5aa7-a18e-a2aa4fa2bb8c",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Commerce - Vente",
    "name": "Responsable Établissement Marchand",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "6a3a10a5-8f03-54c9-ae32-6b29c855ca02",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN HEALTH MANAGEMENT AND TRANSFORMATION",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "6a986b8d-af27-5e87-8ca2-4572d75ea152",
    "school_code": "ESMAS",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "Master's Degree in Sports Management",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "6ad2c2de-b3fb-5412-a943-dacd225351cc",
    "school_code": "ILMIS",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Spécialisé en Comptabilité Audit et Contrôle de Gestion (CAC)",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "6af7ae0d-2e81-5d77-9e2b-056d97b57727",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Banque Finance et Assurance",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "6b10ca35-d711-5b0a-aefd-1acea4e96483",
    "school_code": "EVRY BS",
    "cycle": "Mastères Spécialisés",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "technologie et data innovation",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "6b3374e0-2d0b-507e-a615-2167dd5d15b2",
    "school_code": "ILMIS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Marketing et Communication Digitales",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "6b64f581-dc1d-54c9-b9dd-05695e5c1e54",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN INNOVATION COMMERCIAL MANAGEMENT",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "6b7107ec-0829-5b71-b71f-709644e4d1ea",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Marketing and Communication",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "6b8a61c9-14ec-5f5d-9be9-a385e2873313",
    "school_code": "LSB",
    "cycle": "Masteres Specialises",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère Spécialisé en Management du developpement durable et RSE",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "6c66df62-b7cd-50a5-9e36-fbe16130dc85",
    "school_code": "CESCOM",
    "cycle": "MASTÈRES SPÉCIALISÉS (BAC+6)",
    "academic_level": null,
    "domain": "MARKETING-MANAGEMENT",
    "name": "MS Stratégie Marketing",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "6ca767cc-5c09-5821-8929-bb123182883f",
    "school_code": "EMSP",
    "cycle": "Mastère spécialisé",
    "academic_level": "Mastère spécialisé",
    "domain": "Commerce - Vente",
    "name": "Mastère Spécialisé en Commerce International et Digitalisation",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "6ca86cb9-3649-5c2c-babd-e6630ef53d06",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Management et Gestion",
    "name": "Bachelor Gestion de Projets",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "6cbe6dcd-7038-5b90-8c81-0f5a5b39b68c",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Project Management",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "6ccfd9eb-eb5a-581e-8532-97046f45bc41",
    "school_code": "ILMIS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in Project and Innovation Management",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "6cde9e8a-2f34-5332-aeb7-3d072f7ba29a",
    "school_code": "ESEA",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "MASTER'S DEGREE IN MANAGEMENT AND STRATEGY",
    "source_file": "forms/esea.html"
  },
  {
    "id": "6d073732-e378-5e4c-b08a-a1ad294acd66",
    "school_code": "ESMEP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "MASTERE MANAGEMENT DE PROJET ET DE L'INNOVATION",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "6d146a81-73ac-5a04-bb0f-b9a3080a49d7",
    "school_code": "ISMOD",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Gestion-Luxe",
    "name": "Bachelor Gestion de Marque et Branding",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "6d72631a-c768-5240-8ad0-39889a0822cd",
    "school_code": "ILMIS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Commerce International et Digitalisation",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "6db9c44c-c50d-5fb9-8994-a1b5e22a87c2",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Commerce - Vente",
    "name": "Responsable Établissement Marchand",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "6dbe6034-5266-5962-98ae-2518302dde2e",
    "school_code": "ESMEP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "MASTER'S DEGREE IN SUSTAINABLE DEVELOPMENT AND CORPORATE SOCIAL REESPONSIBILITY(RSE) MANAGEMENT",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "6dc68387-3fe7-5ed1-a81b-e5ad8d9900bd",
    "school_code": "ESART",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "MASTER'S DEGREE IN DIGITAL COMMUNICATION, EVENT MANAGEMENT AND AI STRATEGY",
    "source_file": "forms/esart.html"
  },
  {
    "id": "6dcc7c1b-aec5-5f02-8707-f8fd91fcb331",
    "school_code": "ESMEP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "MASTER'S DEGREE IN DIGITAL PRODUCT MANAGEMENT",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "6dd38411-43e3-54ec-b542-416d754b7d97",
    "school_code": "ESJM",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "MASTÈRE INNOVATION ET COMPLIANCE",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "6dfefe9f-8b01-521e-a4f8-d1c6ee3365ee",
    "school_code": "ISMOD",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Commerce-Marketing",
    "name": "Mastère Commerce et Marketing",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "6e4befc7-a278-575d-a77e-43d5635f10cf",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "FINANCE",
    "name": "BACHELOR GESTION DES OPERATIONS DE MARCHES FINANCIERS (GMF)",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "6e5aca6f-fa21-5903-97ab-4d7ac6d9ff23",
    "school_code": "EMSP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère Management et Numérisation des Processus QHSE",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "6e6be63c-07ca-5330-8e52-3a1d9347f494",
    "school_code": "ESMAS",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "STRATÉGIE ET MANAGEMENT INTERNATIONAL",
    "name": "Mastère Spécialisé Management des Structures de Sport (MS2)",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "6e9644d8-3065-5a45-813f-755a6f976759",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN PROJECT MANAGEMENT",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "6ea69230-a5c1-550a-b281-a034aa1e68b8",
    "school_code": "EVRY BS",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Bachelor e-commerce",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "6f0f3cc3-71df-5bd7-867d-f31a44ca6812",
    "school_code": "EMSP",
    "cycle": "Mastère spécialisé",
    "academic_level": "Mastère spécialisé",
    "domain": "Stratégie et Management International",
    "name": "Mastère Spécialisé Management International des RH et Numérisation des Opérations",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "6f51adac-5dba-5768-a727-a3fa94a06adb",
    "school_code": "ILMIS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in UX Design",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "6f61ae34-de56-5ddf-aa5c-fab2fad2337d",
    "school_code": "ESMEP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "MANAGEMENT ET GESTION",
    "name": "MASTÈRE MANAGEMENT ET STRATEGIE",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "701012cb-2fa1-5969-b79f-0e059b5a7572",
    "school_code": "EVRY BS",
    "cycle": "Mastères Spécialisés",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "mastere spécialise creation de marque et identité-produit (MIP)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "705e8831-8c7c-56ce-a9bd-8d923c3bfe9a",
    "school_code": "ILMIS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Stratégie et Management International",
    "name": "Mastère en Management Stratégique et Intelligence Économique",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "708473c7-7084-5135-a3b8-25613f351276",
    "school_code": "ESETH",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "MANAGEMENT-ENTREPRENARIAT",
    "name": "MASTÈRE PROJETS EVÈNEMENTIELS ET DATA MANAGEMENT (MPE)",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "70aeba2b-cc93-528f-acb2-6da4d4d8a117",
    "school_code": "ESETH",
    "cycle": "MASTÈRE SPÉCIALISÉ",
    "academic_level": null,
    "domain": "MARKETING-HÔTELLERIE",
    "name": "MASTÈRE SPÉCIALISÉ MARKETING INTERNATIONAL",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "70d0ae56-5ca4-5671-9d63-a86eba5a6bd2",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Finance de Marché et Management des Risques",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "7164f180-5d15-5a0b-967b-9ae31ef68868",
    "school_code": "ESART",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "MASTER'S DEGREE IN ENTREPRENEURSHIP AND BUSINESS DEVELOPMENT",
    "source_file": "forms/esart.html"
  },
  {
    "id": "7167e6b9-413e-5c8f-9eef-12e18df64fe6",
    "school_code": "LSB",
    "cycle": "Masteres",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Manager intelligence artificielle et management (IAM)",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "7182639d-d5b3-5454-bdec-f277917c2f6f",
    "school_code": "EVRY BS",
    "cycle": "NIVEAU BAC",
    "academic_level": null,
    "domain": "niveau bac",
    "name": "TP prospection clientele et valorisation de l'offre commerciale",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "71fcf7de-b417-592f-9276-d331e07269b8",
    "school_code": "ESUV",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Master's Degree",
    "name": "Master's degree in digital event and ai-driven communication (CDE)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "720ac486-3be7-538b-b638-33dd0e84fad2",
    "school_code": "ILMIS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Cybersécurité et Management des Données Personnelles",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "7224a728-b0e5-50a3-8c25-6efa7c89361b",
    "school_code": "ESMEP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "COMMERCE - VENTE",
    "name": "MASTERE EDNTREPRENEURIAT ET BUSINESS DEVELOPMENT",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "72846a58-4c83-55e5-8bbf-67c0215d5d78",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Commerce - Vente",
    "name": "Bachelor Gestion et Affaires Internationales",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "72930496-41da-5d12-b14e-f17e46bd122b",
    "school_code": "LSB",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Marketing et communication",
    "name": "bachelor start-up et business development(SBD)",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "7295b0c6-4121-5431-a92d-f39434bd85ab",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Management et Gestion",
    "name": "Bachelor Ressources Humaines",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "732378c0-4e27-5dad-baa3-2191b52003f3",
    "school_code": "MLV BS",
    "cycle": "Nos Bachelors",
    "academic_level": null,
    "domain": "Marketing et Communication",
    "name": "BACHELOR GESTION COMMERCIALE (GC)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "7329624d-0834-5898-8dfc-9fb734e21245",
    "school_code": "CESCOM",
    "cycle": "BTS (BAC+2)",
    "academic_level": null,
    "domain": "FINANCE-GESTION",
    "name": "BTS Gestion de la PME (GPME)",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "73591279-608e-5c97-bb90-a80777809ea7",
    "school_code": "EVRY BTS",
    "cycle": "BTS (Brevet de Technicien Supérieur)",
    "academic_level": null,
    "domain": "FINANCE",
    "name": "BTS ASSURANCE",
    "source_file": "forms/evry-bts.html"
  },
  {
    "id": "7364902b-f18c-514c-b4ba-1768b7e8cfc9",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Stratégie et Management International",
    "name": "Bachelor Gestion des Risques Intercurels",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "736eac62-513a-5bd8-b040-8abe6aa9e590",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master's Degree in Accounting, Audit and Management Control",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "73b8bfdc-38f1-5a29-929f-7a259f517703",
    "school_code": "LSB",
    "cycle": "Masteres",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère en managment du developpement durable et RSE",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "73f09587-b46e-592a-ba51-729b6ecdc4ef",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "Bachelor's Degree in Healthcare Management and Transformation",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "73f47327-631f-5e95-8743-e0f82df18682",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "Bachelor’s Degree in International Business",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "7415f63d-4ffb-5a57-a498-6205dc9b3ad4",
    "school_code": "LSB",
    "cycle": "Masteres",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère administration systemes, reseaux et Cybersécurité",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "741c2509-788c-5689-88a3-869142444147",
    "school_code": "ESMEP",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "FINANCE",
    "name": "MASTÈRE SPÉCIALISÉ E-BANKING ET FINTECH",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "7433a888-3f4a-501f-832c-af87f3d7e9b1",
    "school_code": "CESCOM",
    "cycle": "MASTÈRE (BAC+5)",
    "academic_level": null,
    "domain": "DROIT-LOGISTIQUE-BUSINESS",
    "name": "Mastère Supply Chain",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "747b90e6-811d-56cc-8e27-f87e2ab08144",
    "school_code": "CESCOM",
    "cycle": "NIVEAU BAC",
    "academic_level": null,
    "domain": "TITRES PROFESSIONNELS",
    "name": "TP NÉGOCIATEUR TECHNICO-COMMERCIAL",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "74cb7c8a-950e-5636-9d1d-c5b8a96b0f35",
    "school_code": "ESJM",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "BACHELOR CHARGE DE PROTECTION DE DONNÉES PERSONNELLES",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "74cf5f4b-056e-5258-b8c1-5023cae623c1",
    "school_code": "ESETH",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "MARKETING-HÔTELLERIE",
    "name": "MASTÈRE MARKETING INTERNATIONAL (MI)",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "74ec992e-6538-5772-ab94-3b70e9f1a49b",
    "school_code": "MLV BS",
    "cycle": "Nos Mastère Spécialisé",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Spécialisé Banque Finance Et Assurance",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "7505c7ce-8061-5771-9556-bcfb53c88f06",
    "school_code": "ESMAS",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "FINANCE",
    "name": "MASTÈRE INGÉNIEUR D'AFFAIRES ET DE TRANSITION (IA)",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "750f3f6e-2e96-55bf-9f27-38fc894e61d4",
    "school_code": "ESMAS",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "Bachelor's Degree in Sports Marketing and Communication",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "752a3f81-49ad-5db8-8b5c-fb6a19e7d9b8",
    "school_code": "ILMIS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in Business Development Management",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "75f94569-df8c-5ebd-a2f9-69bc20706d68",
    "school_code": "ILMIS",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "Stratégie et Management International",
    "name": "Mastère Spécialisé Management International des RH et Numérisation des Opérations",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "761d5ce2-80c3-52f9-8f91-119e2aab720d",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "COMMERCE - VENTE",
    "name": "BACHELOR MARKETING ET COMMUNICATION",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "76cdb206-4d75-56d5-925e-3d03dddf6598",
    "school_code": "LSB",
    "cycle": "Masteres Specialises",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère Spécialisé en Management et digitalisation des processus achats et logistique",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "7701e256-14ed-5efc-8cc7-b6091762e213",
    "school_code": "CESCOM",
    "cycle": "BTS (BAC+2)",
    "academic_level": null,
    "domain": "COMMERCE-VENTE",
    "name": "BTS Management Commercial Opérationnel (MCO)",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "7805f5f2-6ac1-5712-bc39-87249d71292a",
    "school_code": "ESJM",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "BACHELOR RESSOURCES HUMAINES",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "781801ce-c4ae-531e-831c-f4140b50a16b",
    "school_code": "ESMEP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "MASTERE MANAGEMENT ET DIGITALISATION DES PROCESSUS D'ACHATS ET LOGISTIQUE",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "782bd0c4-c19e-5380-ac59-b419e07e44a9",
    "school_code": "ESIIA",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Bachelor's Degree",
    "name": "Bachelor's Degree in Data Marketing and Digital Product Development",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "78880a67-d166-5997-bb04-a2867f0fd21d",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Marketing and Communication",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "78a1a2bb-4690-5c55-95ff-07595d77f8ef",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Commerce - Vente",
    "name": "Bachelor Négociation et Vente",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "78b2df61-9364-51f0-b5ef-960266253fd6",
    "school_code": "MLV BS",
    "cycle": "Nos Mastères",
    "academic_level": null,
    "domain": "Finance",
    "name": "MASTÈRE COMPTABILITÉ AUDIT ET CONTRÔLE DE GESTION (CAC)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "78b76037-f27a-5095-bc39-bbd50b4bcba1",
    "school_code": "ESMAS",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "Mastère Spécialisé Management et Digitalisation des Processus Achats et Logistique (MD-AL)",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "78d23409-c729-50f5-969a-f11ce759e7ec",
    "school_code": "ILMIS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in E-Health and Digital Transformation",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "78d5a036-5a59-595e-b87f-c87d45e99313",
    "school_code": "ESMOSS",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "SANTÉ-DIGITALE",
    "name": "Mastère Spécialisé mAnagement et Digitalisation des Process Qualité, Hygiène, Sécurité et Environnnement (MD-QHSE)",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "78ebe942-f5bc-5f2c-8764-3c270a5d9c97",
    "school_code": "EVRY BTS",
    "cycle": "BTS (Brevet de Technicien Supérieur)",
    "academic_level": null,
    "domain": "TOURISME ET HÔTELLERIE",
    "name": "BTS MANAGEMENT D'UNITÉ D'HÉBERGEMENT",
    "source_file": "forms/evry-bts.html"
  },
  {
    "id": "793b6e39-6790-551b-86ed-da1d6c7f1be2",
    "school_code": "ESIIA",
    "cycle": "Mastère",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Finance de Marché et Management des Risques (FM)",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "79cf107f-c6d3-5391-98e2-8e6445cc2d20",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "Bachelor's Degree in Human Resources Management",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "7a0fe382-665c-5839-912b-28e8a441949c",
    "school_code": "ESART",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "AUDIOVISUEL - CINÉMA - PRODUCTION",
    "name": "MASTÈRE PRODUCTION AUDIOVISUELLE (PA)",
    "source_file": "forms/esart.html"
  },
  {
    "id": "7a4e8342-8a60-545d-9a53-5bc754bc6f0e",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN E-COMMERCE",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "7aa0fa21-1f1c-5bb8-922c-8770bd64bb36",
    "school_code": "ESUV",
    "cycle": "Mastères Spécialisés",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "mastere spécialisé management strategique et intelligence économique (SIE)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "7ad10568-3cd2-5520-b32a-1cc64f4b339a",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Corporate Social Responsibility",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "7b126cc8-3d33-5367-bce9-94e1ec75f79a",
    "school_code": "ESMAS",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "STRATÉGIE ET MANAGEMENT INTERNATIONAL",
    "name": "Mastère Management du Sport & Transformation Digitale (MS)",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "7b65b921-9556-5e93-b737-92442af86699",
    "school_code": "ESART",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "MASTER'S DEGREE IN MUSIC MANAGEMENT",
    "source_file": "forms/esart.html"
  },
  {
    "id": "7c8866f5-5e8d-5a20-8f32-64f097ed48a4",
    "school_code": "ILMIS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère E-Santé et Transformation Digitale",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "7cb840c3-5925-5ecc-b2a0-e0e9033500ef",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Sales and Negotiation",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "7cd21f60-de53-50f3-b8cf-11ce5ef107ca",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Project Management",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "7cd23004-f5c6-586f-9856-cf4ed8ebc7dc",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "COMMERCE - VENTE",
    "name": "BACHELOR MARKETING ET COMMUNICATION",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "7cdbd055-3371-5759-85bf-8fa26e14e0cc",
    "school_code": "ESIIA",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Master's Degree",
    "name": "Master's Degree in UX Design and Content Strategy",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "7cef9bc7-9479-5feb-a769-5f481aec8746",
    "school_code": "CESCOM",
    "cycle": "MASTÈRES SPÉCIALISÉS (BAC+6)",
    "academic_level": null,
    "domain": "DESIGN-CRÉATION",
    "name": "MS Design Global",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "7d06ca85-fc95-58b6-ac79-278fab7151a8",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Sales and Negotiation",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "7d075c25-0d17-5ba1-9e07-900baebb4540",
    "school_code": "ESMOSS",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "SANTÉ-DIGITALE",
    "name": "Mastère Entrepreneuriat et Management Numerique (EML)",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "7d13417c-e02f-55f6-a898-25c0bcc3b623",
    "school_code": "ESEA",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "BACHELOR GESTION DE L'INNOVATION",
    "source_file": "forms/esea.html"
  },
  {
    "id": "7d1c0b39-9a48-5b8d-9131-9176a31e458b",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Product Management",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "7d5c1435-974d-5bf1-a76b-a401e26a3225",
    "school_code": "ISMOD",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Mode-Innovation",
    "name": "Mastère Création de Marque et Identité-Produit (MIP)",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "7d71c092-bc75-515d-94a9-a8274c4c60d8",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Finance",
    "name": "Bachelor Gestion de Patrimoine",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "7db62cde-0cdf-5077-bf3c-99ce9a89b03c",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Procurement and Logistics",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "7db7263c-6499-50a7-a724-beaca774c6c6",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Commerce - Vente",
    "name": "Bachelor Responsabilité Sociétale des Entreprises",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "7dde0801-3875-5612-a71e-94762350f222",
    "school_code": "ESMOSS",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "MANAGEMENT-GESTION",
    "name": "Bachelor Gestion de l'Innovation(GIN)",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "7de8555f-6a5c-555d-9a97-1d85eedb26b6",
    "school_code": "EVRY BS",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Bachelor's Degree",
    "name": "Bachelor's Degree in marketing and communication",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "7e145f8d-d78f-51b3-954e-ae43a0bae2e8",
    "school_code": "ESART",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "COMMERCE-GESTION-BUSINESS DEVELOPMENT",
    "name": "BACHELOR GESTION DE PROJETS",
    "source_file": "forms/esart.html"
  },
  {
    "id": "7ee0bb55-e976-5db6-b492-05353de3b97c",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "Bachelor's Degree in Innovation Management",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "7eef0dc6-9ef2-5da9-853f-602ba1ade43d",
    "school_code": "ESART",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "COMMERCE-GESTION-BUSINESS DEVELOPMENT",
    "name": "MASTÈRE SPÉCIALISÉ EN ENTREPRENEURIAT ET BUSINESS DEVELOPMENT (EBD)",
    "source_file": "forms/esart.html"
  },
  {
    "id": "7fad2859-e41d-5abf-95e6-1e260f3346ed",
    "school_code": "ESJM",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "MASTÈRE DROIT IMMOBILIER ET CONTRAINTES REGLEMENTAIRES",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "7ff585f6-37c4-5efc-8832-528f3e852436",
    "school_code": "ESMAS",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "Mastère Management de Projet et de L'innovation (MPI)",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "803e45c8-f2e6-5d2b-9d27-e5d6aaaca5b7",
    "school_code": "ESMOSS",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "MANAGEMENT-GESTION",
    "name": "Bachelor Actions Sociales et Accompagnement Connecté(AS)",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "8078529f-7bcc-55ae-bbf9-34d4d81f1176",
    "school_code": "ESART",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "BACHELOR'S DEGREE IN BRAND MANAGEMENT AND BRANDING",
    "source_file": "forms/esart.html"
  },
  {
    "id": "80a8d0d9-3305-579f-9ca6-7ea9b4091533",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN E-COMMERCE",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "80df02d8-4d2f-5b8d-bb6d-1c0790f1e24e",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master's Degree in Project and Innovation Management",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "80e822de-ccba-5dea-b2c9-2f4ae5312b78",
    "school_code": "EMSP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Commerce International et Digitalisation",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "80f5596a-bcad-54ab-9883-ca7b1edce115",
    "school_code": "ILMIS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in Entrepreneurial Management of Digital Projects and Digital Strategy",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "81454faf-9145-5814-94f1-33358500827d",
    "school_code": "ISMOD",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Gestion-Luxe",
    "name": "Mastère Gestion de Luxe et de la Qualité",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "814d200e-cba7-5dea-88a6-db22b31cc4e7",
    "school_code": "ESIIA",
    "cycle": "Mastère",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Comptabilité Audit et Contrôle de Gestion (CAC)",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "817c75da-242d-531b-ba69-91853487834b",
    "school_code": "ILMIS",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Spécialisé Marketing,Communicaion Internationale et Digitale",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "81820aa9-bff6-56bd-ab8a-102ace1ef2c5",
    "school_code": "ESETH",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "MARKETING-COMMUNICATION",
    "name": "BACHELOR MARKETING ET COMMUNICATION (MC)",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "81a0fa97-a7ac-5b70-b8e9-bca40ed0d19e",
    "school_code": "ESEA",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "MANAGEMENT ET GESTION",
    "name": "MASTÈRE RESSOURCES HUMAINES ET NUMERISATION DES OPERATIONS",
    "source_file": "forms/esea.html"
  },
  {
    "id": "820c2b32-5c43-5d82-83b9-05c0322aa5bd",
    "school_code": "CESCOM",
    "cycle": "NIVEAU BAC",
    "academic_level": null,
    "domain": "TITRES PROFESSIONNELS",
    "name": "TP ASSISTANT MANAGER D'UNITÉ MARCHANDE (AMUM)",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "82414e68-90b4-5b72-8546-b8ae367573cb",
    "school_code": "MLV BTS",
    "cycle": "BTS (Brevet de Technicien Supérieur)",
    "academic_level": null,
    "domain": "FINANCE",
    "name": "BTS BANQUE",
    "source_file": "forms/mlv-bts.html"
  },
  {
    "id": "824ff427-cc1b-533a-ba55-2bd370108e0c",
    "school_code": "MLV BS",
    "cycle": "Nos Mastères",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Administration Systèmes, Reseaux et Cybersécurité (SRC)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "8250e1c0-524e-5abc-ac58-bf847edffdf8",
    "school_code": "EMSP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Stratégie et Management International",
    "name": "Mastère en Management Stratégique et Intelligence Économique",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "826ce132-6739-5cd4-931c-305e7ddce1bf",
    "school_code": "MLV BS",
    "cycle": "Nos Mastères",
    "academic_level": null,
    "domain": "Commerce et Vente",
    "name": "Mastére Commerce International et Digitalisation (CID)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "82c87309-7318-5fc2-9e88-0a25be0d9337",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère en Droit des Affaires et Management",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "834a8b65-3e63-5610-a06a-779ba04e20ab",
    "school_code": "MLV BS",
    "cycle": "Nos Bachelors",
    "academic_level": null,
    "domain": "Marketing et Communication",
    "name": "TP RESPONSABLE D'ÉTABLISSEMENT MARCHAND (REM)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "837871b4-c4e1-57cf-9666-0bd19939020d",
    "school_code": "ESMOSS",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "Bachelor's Degree in Health Managemnt and Transformation",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "83b5f399-c86a-5041-b1f8-8e158c0b6961",
    "school_code": "ISMOD",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Communication-Vente",
    "name": "Mastère Fashion Business",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "83cce302-6f4b-5638-a8e6-d9eafbe32425",
    "school_code": "CESCOM",
    "cycle": "MASTÈRE (BAC+5)",
    "academic_level": null,
    "domain": "DESIGN-CRÉATION",
    "name": "Mastère Design UX/UI",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "83d3b031-93aa-58a0-98d6-02949da1bd05",
    "school_code": "EVRY BS",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Master's Degree",
    "name": "Master's Degree in brand creation and product identity",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "83e7c3a3-4f08-5105-9c85-388f3fc589f2",
    "school_code": "LSB",
    "cycle": "Masteres",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Marketing et Communication Digitales",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "840d419a-5461-5e0d-86c5-bf0a0ebe50d4",
    "school_code": "MLV BS",
    "cycle": "Nos Mastères",
    "academic_level": null,
    "domain": "Finance",
    "name": "MASTÈRE E-BANKING ET FINTECH",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "847ddb9d-1adf-5d61-96ba-f2d28fbbad95",
    "school_code": "LSB",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Marketing et communication",
    "name": "Tp responsable d'etablissement marchand",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "849f7f26-170f-54f4-a6a8-fd0aa323f745",
    "school_code": "ESETH",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "GESTION-RESTAURATION",
    "name": "BACHELOR SMART GESTION DU TOURISME ET DES LOISIRS (GTL)",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "84a4f898-a58b-5214-9497-213b0b16d47d",
    "school_code": "ESETH",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "COMMERCE-DIGITAL",
    "name": "MASTÈRE MANAGEMENT ET DIGITALISATION DES PROCESS QHSE (MD-QHSE)",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "84d6fdbf-d7cd-5d77-be74-be3312293074",
    "school_code": "ESMOSS",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "SANTÉ-DIGITALE",
    "name": "Mastère E- Santé et Transformation Digitale(e-Santé)",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "8523f9f7-91ed-552d-99db-b97a11f55b96",
    "school_code": "LSB",
    "cycle": "Masteres Specialises",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "mastere spécialisé managements de projets et de l'innovation (MPI)",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "85bab660-7530-5700-afb2-2783b74f4b2b",
    "school_code": "EVRY BS",
    "cycle": "BTS",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "BTS Technico Commercial",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "860a1aa8-6f2e-5f2f-bc56-1078e72944d2",
    "school_code": "ESMEP",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "FINANCE",
    "name": "MASTÈRE SPÉCIALISÉ FINANCE DE MARCHE ET MANAGEMENT DES RISQUES",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "8728ee5c-0975-5dee-a378-0947f76a7967",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Sales and Negotiation",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "8737d322-2e98-59c6-9203-5cd051a6d0ae",
    "school_code": "EVRY BS",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Bachelor's Degree",
    "name": "Bachelor's Degree in purchasing and logistics",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "8761864a-bfc5-5674-a0a8-6513eb1eacbe",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère en Comptabilité, Audit et Contrôle de Gestion",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "87994227-ca51-53b7-94db-6849b8365e04",
    "school_code": "ILMIS",
    "cycle": "MBA",
    "academic_level": "MBA",
    "domain": "MBA",
    "name": "Master of Business Administration (MBA)",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "87c1eb68-00ff-5af2-bb14-d7c62e47c791",
    "school_code": "EVRY BS",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Master's Degree",
    "name": "master's degree in purchasing and supply chain process management and digitalisation (MD-AL)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "87c2769e-8bd1-5a58-b433-6f39bc46b281",
    "school_code": "EVRY BS",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Bachelor Gestionde Marque et Branding(GM)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "87fe3364-7af8-538a-9a06-bd85f37c7cfa",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Human Resources",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "880dde69-fe69-5f65-96a2-db67fd994514",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "STRATÉGIE ET MANAGEMENT INTERNATIONAL",
    "name": "BACHELOR EN GESTION DE LA SANTE DE LA QUALITE HYGIENE SECURITE ENVIRONNEMENT(QHSE)",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "88324d98-135e-5543-b0a2-3982b7d48365",
    "school_code": "ESMEP",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "MASTÈRE SPÉCIALISÉ MANAGEMENT ET DIGITALISATION DES PROCESSUS D'ACHATS ET LOGISTIQUE",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "884189d0-947b-594d-bab3-aad2e22f475c",
    "school_code": "ILMIS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in UX Design",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "88539420-d34d-51aa-880c-1fad084ad39c",
    "school_code": "LSB",
    "cycle": "Masteres Specialises",
    "academic_level": null,
    "domain": "Stratégie et Management International",
    "name": "Mastère Spécialisé en Management et Stratégie (MS)",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "8863a875-16a1-5cab-8efd-8dc0dd5c8fba",
    "school_code": "ESETH",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "MASTER'S DEGREE IN INTERNATIONAL MARKETING",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "8886fd69-7620-53a5-8e13-ee68fe15fbff",
    "school_code": "ESMEP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "FINANCE",
    "name": "MASTERE COMPTABILITE AUDIT ET CONTROLE DE GESTION (CAC)",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "88e9c210-c79a-5102-bce0-768d7f13423f",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "COMMERCE - VENTE",
    "name": "BACHELOR MARKETING ET COMMUNICATION",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "88fd040c-fe1e-5f7c-b9dd-149118e03de7",
    "school_code": "EMSP",
    "cycle": "Mastère spécialisé",
    "academic_level": "Mastère spécialisé",
    "domain": "Stratégie et Management International",
    "name": "Mastère Spécialisé en Management et Stratégie",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "891ba692-8e09-593c-940e-1b2c8d17aa49",
    "school_code": "ILMIS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Manager Entrepreneuriel de Projet Numérique et Stratégie Digitale",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "89517003-4e1e-5fbf-8c86-733a7b6708b6",
    "school_code": "ILMIS",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Spécialisé UX Designer",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "897218cb-835f-506c-bd51-945af80e17fa",
    "school_code": "MLV BS",
    "cycle": "Nos Bachelors",
    "academic_level": null,
    "domain": "Marketing et Communication",
    "name": "BACHELOR EN COMMERCE INTERNATIONAL (CI)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "89835574-2b50-5d9c-b8d6-a9d86e47e255",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "STRATÉGIE ET MANAGEMENT INTERNATIONAL",
    "name": "BACHELOR EN GESTION DE LA SANTE ET DE LA TRANSFORMATION NUMERIQUE",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "8a42ff23-a97f-535c-afa6-055bc735e4b0",
    "school_code": "ESMEP",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "FINANCE",
    "name": "MASTÈRE SPÉCIALISÉ COMPTABILITE AUDIT ET CONTROLE DE GESTION (CAC)",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "8a5de43a-6e26-5c59-b488-89c264173770",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Commerce - Vente",
    "name": "Bachelor Chef de Produit",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "8a7476b2-b212-5348-86b2-0f78e2a88794",
    "school_code": "ESART",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "AUDIOVISUEL - CINÉMA - PRODUCTION",
    "name": "BACHELOR CINEMA ET AUDIOVISUEL",
    "source_file": "forms/esart.html"
  },
  {
    "id": "8a94bc24-3c0d-5898-a185-a456cba0a764",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "Bachelor's Degree in Innovation Management",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "8aa3dd18-4de9-522f-95ef-bef865240c86",
    "school_code": "ESMOSS",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "Master's Degree in Health Organisations Management and Risk Prevention",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "8ad59e74-b029-5cd3-b510-c1396fec9fae",
    "school_code": "ESMEP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "COMMERCE - VENTE",
    "name": "MASTERE EDNTREPRENEURIAT ET BUSINESS DEVELOPMENT",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "8af90050-fa35-5b08-81ab-62fb98c377ce",
    "school_code": "ESEA",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "MASTER'S DEGREE IN QUALITY, SAFETY AND TRANSITION (QST)",
    "source_file": "forms/esea.html"
  },
  {
    "id": "8b68272d-d866-53b5-a231-4ced47f1b806",
    "school_code": "EVRY BS",
    "cycle": "Mastères",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "mastere ingenieur(e) d'affaires (IA)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "8b7e001d-17c4-508f-bac4-489ef856d791",
    "school_code": "ESIIA",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Master's Degree",
    "name": "Master's Degree in Social Media and Community Management",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "8b971173-8c8b-5709-8a2f-309963d83797",
    "school_code": "ESMOSS",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "SANTÉ-DIGITALE",
    "name": "Mastère Management de Projet et de l'Innovation(MPI)",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "8bc74b3a-3906-53f9-8d2a-d560073efc4e",
    "school_code": "ILMIS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in Management and Digitisation of QHSE Processes",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "8bd3d6ce-e808-5c80-ae27-3e13284df7f5",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Sales and Negotiation",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "8c261e96-1b13-5a29-86f3-d0d184dd46c4",
    "school_code": "ILMIS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in Digital Marketing and Communication",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "8c92c22a-3f83-5e96-a7e4-ba935cee8f0b",
    "school_code": "ESEA",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "MASTER'S DEGREE IN SUSTAINABLE SUPPLY CHAIN AND DIGITALISATION",
    "source_file": "forms/esea.html"
  },
  {
    "id": "8c932430-8305-5f25-a8e1-33e5c9787876",
    "school_code": "ESUV",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Master's Degree",
    "name": "master's degree in UX design (UX)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "8c9f4482-73d0-5267-bce8-e54483bbdd2d",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Management et Gestion",
    "name": "Bachelor Achats et Logistique",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "8caa3602-904a-54c5-9b10-6de0338c9929",
    "school_code": "EMSP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in UX Design",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "8d25d596-fcfa-58f2-8829-1b62f5d310d0",
    "school_code": "ESART",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "BACHELOR'S DEGREE IN PURCHASING AND LOGISTICS",
    "source_file": "forms/esart.html"
  },
  {
    "id": "8d26e96e-ec62-56ca-86f2-8aa629d05a2a",
    "school_code": "ESETH",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "VENTE-COMMERCE",
    "name": "BACHELOR GESTION COMMERCIALE ET STRATÉGIE DIGITALE (GC)",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "8d94f77f-f9ff-507f-8a7b-6dab4692d5c7",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Sales and Negotiation",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "8d9f8442-d463-53ef-9330-8ef72d76dc49",
    "school_code": "ESMOSS",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "Master's Degree in Health Technology Management",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "8db0a857-8bab-53bc-a737-c072f101dd42",
    "school_code": "ESART",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "COMMUNICATION - MANAGEMENT",
    "name": "MASTÈRE MANAGEMENT DES PRODUITS DIGITAUX (MPD)",
    "source_file": "forms/esart.html"
  },
  {
    "id": "8dd31dfe-784d-5f8a-8ab5-4fab956bccf1",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Commerce - Vente",
    "name": "Bachelor Négociation et Vente",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "8e172119-8639-5bee-8276-5e8e949aea80",
    "school_code": "MLV BTS",
    "cycle": "BTS (Brevet de Technicien Supérieur)",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "BTS CYBERSÉCURITÉ",
    "source_file": "forms/mlv-bts.html"
  },
  {
    "id": "8e27601d-132e-5d03-843d-32cecf0988f4",
    "school_code": "ILMIS",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère Spécialisé en Management et Numérisation des Processus QHSE",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "8e423a8d-9ba4-5d25-ae8b-3b48fb9c1677",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "MANAGEMENT ET GESTION",
    "name": "BACHELOR GESTION DE PROJETS",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "8e73049f-e67a-5632-9acc-11373d77bcad",
    "school_code": "LSB",
    "cycle": "Masteres Specialises",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Spécialisé entrepreneuriat & business development",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "8eb730a8-8fbd-5c54-a7a0-609bb2bc952e",
    "school_code": "ESMEP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "MASTER'S DEGREE IN MANAGEMENT AND STATEGY",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "8ec92b72-cd95-5749-b592-526cdf409486",
    "school_code": "ESART",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "MASTER'S DEGREE IN DIGITAL PRODUCT MANAGEMENT",
    "source_file": "forms/esart.html"
  },
  {
    "id": "8edcb3a6-630d-5133-9dd2-851d40b9a589",
    "school_code": "ESMOSS",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "MANAGEMENT-GESTION",
    "name": "Mastère Spécialisé Management des Technologies de la Santé (MTS)",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "8f131c3d-3c03-57b1-9b9c-81825fd51d5f",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN IN CORPORATE SOCIAL RESPONSIBILITY (CSR)",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "8f59c6c5-fa78-5d96-8086-3196e7ea2f5a",
    "school_code": "ESART",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "COMMUNICATION - MARKETING - DIGITAL",
    "name": "BACHELOR MARKETING ET COMMUNICATION",
    "source_file": "forms/esart.html"
  },
  {
    "id": "8f60ae68-64bd-50a7-8c31-7bd0b8de2cb3",
    "school_code": "ISMOD",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Communication-Vente",
    "name": "Bachelor Chargé de Communication Digitale, Événementielle et à Impact",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "8f8b9163-589b-541d-be19-563c457cd676",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "Bachelor's Degree in Corporate Social Responsibility (CSR)",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "902db6ae-ab92-5a6a-a8ed-9361ec2dfbda",
    "school_code": "EMSP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in Management and Strategy",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "903e31c6-f00f-57a9-bbd3-d87c641142ce",
    "school_code": "ESMEP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "MASTER'S DEGREE IN HUMAN RESOURCES AND DIGITALISATION OF OPERATIONS",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "904321a8-9171-529c-91e5-add974c33669",
    "school_code": "EVRY BS",
    "cycle": "Mastères",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère management de project et de l'innovation (MPI)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "907ee081-82b9-59a1-9ae5-60ce3174d2d5",
    "school_code": "EVRY BS",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Bachelor Achat et Logistique(AL)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "90844d21-f76d-53ce-80f1-2bb0a41bb773",
    "school_code": "ESIIA",
    "cycle": "Mastère",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Lead Developer",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "909315ad-45df-5e98-ba1d-6e9168736605",
    "school_code": "ESART",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "AUDIOVISUEL - CINÉMA - PRODUCTION",
    "name": "BACHELOR RÉALISATEUR-MONTEUR",
    "source_file": "forms/esart.html"
  },
  {
    "id": "90de3c0e-080f-52dd-9e82-a39b1f171c22",
    "school_code": "EVRY BS",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Bachelor's Degree",
    "name": "Bachelor's Degree in start-up and business development",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "90e33b85-b366-57a5-a9b5-d43a14afa256",
    "school_code": "ESMEP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "MASTERE E-SANTE ET TRANSFORMATION DIGITALE",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "90e9c739-864c-57f1-a37e-882951e1a7b0",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Finance",
    "name": "Bachelor Finance et Comptabilité",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "90fdaf68-9c52-5f49-a10d-85046c207b1c",
    "school_code": "LSB",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Marketing et communication",
    "name": "bachelor negociation et vente",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "91112293-1d2b-5f74-b97f-2e3b77d60054",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Management et Gestion",
    "name": "Bachelor Gestion de Projets",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "912eeb32-b091-5e8c-90ab-bf0e6f2ae15f",
    "school_code": "ESIIA",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Bachelor Data Analysis et Gestion Stratégique",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "918057a8-aa06-59c3-aba5-9b31bb5851a3",
    "school_code": "MLV BS",
    "cycle": "Nos Mastère Spécialisé",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "MASTÈRE SPECIALISE MANAGEMENT ET DIGITALISATION DES PROCESS QHSE",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "926f427a-d486-5807-9bfc-374e1fd3461b",
    "school_code": "EMSP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in Project and Innovation Management",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "9291a884-dbb0-5604-a213-82aed03ac50f",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN SALES AND NEGOCIATION",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "92af07f1-aed7-5e73-bdfd-802474d5ef9f",
    "school_code": "ESIIA",
    "cycle": "Mastère",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère UX-Design et Stratégie de Contenus",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "92bb9b55-4908-5f71-a6d2-fd411f06ce45",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Management et Gestion",
    "name": "Bachelor Achats et Logistique",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "9357893e-ef63-53d9-8a82-56be0032cbfa",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Commercial Establishments Management",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "93862df6-59c7-5253-b322-4079d416754f",
    "school_code": "ESMOSS",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "MANAGEMENT-GESTION",
    "name": "Mastère en Management et Stratégie(MS)",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "93c3063a-ce9d-5b56-8eec-ec9ddd10affd",
    "school_code": "EVRY BTS",
    "cycle": "BTS (Brevet de Technicien Supérieur)",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "BTS SERVICES INFORMATIQUES AUX ORGANISATIONS",
    "source_file": "forms/evry-bts.html"
  },
  {
    "id": "93f96a4d-5b12-5759-8f03-80ac294ed1ff",
    "school_code": "ESART",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "BACHELOR'S DEGREE UN START-UP AND BUSINEESS DEVELOPMENT",
    "source_file": "forms/esart.html"
  },
  {
    "id": "94162df6-df81-5199-920f-3e8f25a46242",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Sales and Negotiation",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "94f04bb0-a3a4-53b5-af35-629c0e1ae19d",
    "school_code": "EMSP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in Management and Digitisation of QHSE Processes",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "950c9d12-dc22-5664-872a-34e7e188342d",
    "school_code": "ESMAS",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "STRATÉGIE ET MANAGEMENT INTERNATIONAL",
    "name": "Mastère Management International du Sport & Business Digital (MIS)",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "95253ecb-bb09-54b1-9e14-3efc2ff16907",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Commerce - Vente",
    "name": "Bachelor Marketing et Communication",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "9548dcec-5dcc-543d-8b4f-33c25bd5c6a3",
    "school_code": "ESETH",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "TOURISME-EVÈNEMENTIEL",
    "name": "MASTÈRE INGÉNIERIE DU TOURISME NUMÉRIQUE ET DÉVELOPPEMENT INTERNATIONAL (TDI)",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "95846ba4-ef85-5bb3-977f-6960a927038c",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Procurement and Logistics",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "95b6bb63-ec23-54a7-b0af-a2b673b916ae",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "Bachelor's Degree in Business Management and Commercial Development",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "9601de3c-bef7-500d-ae87-bc2ce1133da9",
    "school_code": "ISMOD",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Communication-Vente",
    "name": "Mastère Responsable Communication Digitale, Événementielle et à Impact (CDEI)",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "960aea87-ae94-54b3-9f3f-10e2ae6ba4eb",
    "school_code": "EVRY BS",
    "cycle": "BTS",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "BTS Support à l'Action Managériale (SAM)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "962e558d-7ae8-5431-8193-694edf695635",
    "school_code": "EVRY BTS",
    "cycle": "BTS (Brevet de Technicien Supérieur)",
    "academic_level": null,
    "domain": "MODE ET LUXE",
    "name": "BTS MCO (MANAGEMENT COMMERCIAL ET OPÉRATIONNEL) OPTION LUXE",
    "source_file": "forms/evry-bts.html"
  },
  {
    "id": "96345bf8-72e6-57e8-a658-0e8d66e6165e",
    "school_code": "EMSP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in Management and Strategy",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "963b0e3f-ffcb-567b-b6bd-b777c7e606e1",
    "school_code": "EMSP",
    "cycle": "Mastère spécialisé",
    "academic_level": "Mastère spécialisé",
    "domain": "Commerce - Vente",
    "name": "Mastère Spécialisé en Marketing et Communication Digitale",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "9642ee85-c3cf-5a18-9681-c3fdd93b92ed",
    "school_code": "LSB",
    "cycle": "Masteres",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère entrepreneuriat et management numérique",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "965cac6d-0623-5a3f-8b6d-fc10c19e04e1",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Finance",
    "name": "Diplôme de Comptabilité et de Gestion",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "96894206-8caf-5dd2-bd33-83ae350039ad",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère E-Banking et Fintech",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "97970798-43a0-505e-9cf9-d638f5d874b3",
    "school_code": "ESIIA",
    "cycle": "Mastère",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Intelligence Artificielle et Management",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "982e9d97-cd9b-50b0-9a4f-e5ba6912cc8a",
    "school_code": "MLV BS",
    "cycle": "Nos Mastères",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "MASTÈRE MANAGEMENT ET DIGITALISATION DES PROCESS QHSE",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "98672f36-5b21-5a49-8692-5e2621608fde",
    "school_code": "EMSP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Stratégie et Management International",
    "name": "Mastère en Management Stratégique et Intelligence Économique",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "99357dca-064d-56e3-9ce5-9fb12aa928f8",
    "school_code": "MLV BTS",
    "cycle": "BTS (Brevet de Technicien Supérieur)",
    "academic_level": null,
    "domain": "TOURISME ET HÔTELLERIE",
    "name": "BTS TOURISME",
    "source_file": "forms/mlv-bts.html"
  },
  {
    "id": "99b22003-8d79-5cb8-9d46-acb207874836",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Management et Gestion",
    "name": "Bachelor Ressources Humaines",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "99d45ea3-4c69-5031-8fbc-03428aa94696",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Product Management",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "99f61afb-0c3c-5c4b-9c5d-d70dc2564964",
    "school_code": "EVRY BTS",
    "cycle": "BTS (Brevet de Technicien Supérieur)",
    "academic_level": null,
    "domain": "COMMERCE - VENTE",
    "name": "BTS MCO (MANAGEMENT COMMERCIAL ET OPÉRATIONNEL)",
    "source_file": "forms/evry-bts.html"
  },
  {
    "id": "9a0f0b5d-b8c9-5df0-a426-844d993a36f1",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "MANAGEMENT ET GESTION",
    "name": "BACHELOR ACHATS ET LOGISTIQUE",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "9a44a230-298c-5a08-92d3-99fbbff2c750",
    "school_code": "ESMEP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "FINANCE",
    "name": "MASTERE EN FINANCE DE MARCHE ET MANAGEMENT DES RISQUES",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "9a64997c-8983-5424-b51a-39bfeae91d77",
    "school_code": "MLV BS",
    "cycle": "Nos Mastère Spécialisé",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Spécialisé Architecture des Systèmes Informatiques (ASI)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "9a731e10-e178-5312-9736-bde6daeb50b9",
    "school_code": "ILMIS",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère Spécialisé en Management Stratégique et Intelligence Économique",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "9a9bd98b-a052-55c0-a119-d858fd085eee",
    "school_code": "ESMOSS",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "Master's Degree in Manageemnt and Strategy",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "9ae422c7-2ad0-52d0-a58d-2fdd56f80e51",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Management et Gestion",
    "name": "Bachelor Ressources Humaines",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "9b8137e4-d152-520c-b24c-b7706ec9af2a",
    "school_code": "ISMOD",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Gestion-Luxe",
    "name": "Mastère Gestion de Luxe et de la Qualité",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "9ba08e8a-4a54-5a71-8972-1ca179e79d9a",
    "school_code": "EMSP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère en Ingénieur(e) d'Affaires",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "9bbc9b72-07fe-5690-8f2a-6b4c66c5c703",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "COMMERCE - VENTE",
    "name": "BACHELOR EN MARKETING ET COMMUNICATION",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "9be7db31-8dcf-557f-83c6-aac054c43e61",
    "school_code": "ESUV",
    "cycle": "Mastères",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère management de project et de l'innovation (MPI)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "9c706343-68e0-5490-bbe0-c70b3e5719f6",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "FINANCE",
    "name": "BACHELOR COMPTABILITE, AUDIT ET CONTROLE DE GESTION (CAG)",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "9c862722-a02f-5619-bf7c-23f1f469c08e",
    "school_code": "ISMOD",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Mode-Innovation",
    "name": "Mastère Management de la Mode et des Industries Créatives (MIC)",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "9c95d2f2-bf67-5a55-9f79-dad5f3d4aa8c",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "MANAGEMENT ET GESTION",
    "name": "BACHELOR GESTION DE PROJETS",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "9ca8df30-417c-5484-b09f-2ffa5a6052db",
    "school_code": "EVRY BTS",
    "cycle": "BTS (Brevet de Technicien Supérieur)",
    "academic_level": null,
    "domain": "TOURISME ET HÔTELLERIE",
    "name": "BTS MANAGEMENT D'UNITÉ DE PRODUCTION CULINAIRE",
    "source_file": "forms/evry-bts.html"
  },
  {
    "id": "9ce0ad2b-5400-5eae-9a63-68c467052353",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Finance",
    "name": "Bachelor Finance et Comptabilité",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "9ce8ef41-d317-52ad-bf9d-d293b71d9367",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "COMMERCE - VENTE",
    "name": "BACHELOR EN GESTION COMMERCIALE",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "9cf604ee-228c-5757-9d03-897315a14009",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Technologie et Data Innovation",
    "name": "Bachelor Développement Web et Application",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "9d0cf4a9-3fbe-53d2-b59c-6e118675f375",
    "school_code": "MLV BS",
    "cycle": "Nos Mastères",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Marketing et Communication Digitales",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "9d1c4a23-94c1-5f7d-9e14-7a1fd8c3e4e7",
    "school_code": "ISMOD",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Communication-Vente",
    "name": "Bachelor Achats et Logistiques (AL)",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "9d46f62a-1ef3-5604-9bd9-fe108fb342c9",
    "school_code": "ESJM",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "MASTÈRE SPÉCIALISÉ EN DROIT ET GESTION DU PATRIMOINE",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "9d49f664-1fe7-574b-be7a-41519a3410e5",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN IN CORPORATE SOCIAL RESPONSIBILITY (CSR)",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "9d680471-9b04-5d09-8d24-6e639d6d0e04",
    "school_code": "ESIIA",
    "cycle": "Mastère",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Social Media et Community Management",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "9dcf3c3d-f44a-5f69-9280-366083d2bd60",
    "school_code": "EVRY BS",
    "cycle": "Mastères",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Entrepreneuriat et Business Development(EBD)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "9de4f80a-c8af-5d67-adff-daef41d6df81",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Management et Gestion",
    "name": "Bachelor Ressources Humaines",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "9e01c466-a8a2-5120-8155-ed9f059ef634",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN IN CORPORATE SOCIAL RESPONSIBILITY (CSR)",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "9e0aaaf6-9c68-5473-9763-e3a98227c183",
    "school_code": "ESEA",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "COMMERCE VENTE",
    "name": "MASTERE SPECIALISE ENTRPREUNEURIAT & BUSINESS DEVELOPMENT",
    "source_file": "forms/esea.html"
  },
  {
    "id": "9e1ce7a9-0230-54a6-9848-4fa9268c7523",
    "school_code": "EVRY BTS",
    "cycle": "BTS (Brevet de Technicien Supérieur)",
    "academic_level": null,
    "domain": "COMMERCE - VENTE",
    "name": "BTS COMMERCE INTERNATIONAL",
    "source_file": "forms/evry-bts.html"
  },
  {
    "id": "9e2d8ba9-9c66-5ecf-8a21-da516eccabcc",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère en Management des Ressources Humaines",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "9e915cb6-9260-58d0-abb6-0da7153d4fd9",
    "school_code": "ESMEP",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "MANAGEMENT ET GESTION",
    "name": "MASTÈRE SPÉCIALISÉ MANAGEMENT ET STRATEGIE",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "9eab2eba-dbdf-56c5-8744-d850dec0017e",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "MANAGEMENT ET GESTION",
    "name": "BACHELOR ACHATS ET LOGISTIQUE",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "9ecc7e52-d79e-54ca-9fcc-fe8f02cb2bbe",
    "school_code": "ESMOSS",
    "cycle": "MBA",
    "academic_level": null,
    "domain": "MBA",
    "name": "MASTER OF BUSINESS ADMINISTRATION (MBA)",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "9f1449e7-18b8-54a5-b614-696a730e2513",
    "school_code": "EVRY BTS",
    "cycle": "BTS (Brevet de Technicien Supérieur)",
    "academic_level": null,
    "domain": "TOURISME ET HÔTELLERIE",
    "name": "BTS TOURISME",
    "source_file": "forms/evry-bts.html"
  },
  {
    "id": "9f1df8d6-2211-52aa-8981-3f260b38097d",
    "school_code": "ESMEP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "MASTER'S DEGREE IN MANAGEMENT AND DIGITALISATION OF PROCURMENT AND LOGISTICS PROCESSES",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "9f42e2f5-8dfb-5d07-925c-0731ba27c821",
    "school_code": "ESUV",
    "cycle": "BTS",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "BTS Négociation et Digitalisation de la Relation Client (NDRC)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "9fe23d9d-fc29-5eb1-8b07-464cb25546e6",
    "school_code": "ESETH",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "BACHELOR'S DEGREE IN TOURISM BUSINESS DEVELOPMENT",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "9ff0e00c-585b-5bb7-a8f7-d2bccde25e5d",
    "school_code": "ESUV",
    "cycle": "BTS",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "BTS Commerce International",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "a06354b4-7702-5165-97bb-0f218c594bc4",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "Bachelor's Degree in Corporate Social Responsibility (CSR)",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "a06d4b5f-e797-5274-94ce-4ac0ea187aef",
    "school_code": "ESMOSS",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "MANAGEMENT-GESTION",
    "name": "Mastère Spécialisé Management des Organisaitons de la Santé et Solutions Digitaales de Prevention(MOS)",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "a082e043-b8db-5dfe-af8c-a1774a7e9049",
    "school_code": "ILMIS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère Management et Numérisation des Processus QHSE",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "a0d0e239-3444-57a6-98c4-391f25224cb3",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Banque Finance et Assurance",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "a10cc058-f4f3-5bf8-9499-7800b9c0794b",
    "school_code": "LSB",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Finance",
    "name": "Bachelor Gestion des operations de marchés financiers (GMF)",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "a1470aa8-bf06-59d2-9664-e53dd5e9fcc0",
    "school_code": "EMSP",
    "cycle": "Mastère spécialisé",
    "academic_level": "Mastère spécialisé",
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Spécialisé Management International et Transformation Digitale",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "a154f306-6ef4-5229-a2a0-21030cb5d698",
    "school_code": "ESART",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "AUDIOVISUEL - CINÉMA - PRODUCTION",
    "name": "MASTÈRE ARTS ET SPECTACLE VIVANT (ASV)",
    "source_file": "forms/esart.html"
  },
  {
    "id": "a168fdfc-eee2-51ae-81d3-b515f317e8a2",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Stratégie et Management International",
    "name": "Bachelor Stratégie et Management International",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "a16f7e72-9225-568d-8565-9e8f8ba34466",
    "school_code": "LSB",
    "cycle": "Masteres",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "mastere management et numerisation des processes NP-QHSE",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "a19d6fc8-3f03-5daf-b323-991fddab5795",
    "school_code": "ESUV",
    "cycle": "Mastères Spécialisés",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "mastere spécialisé responsable communication digitale evenementielle et ia impact (CDE)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "a1ac51fb-48fa-572d-92a5-ea119d27df8d",
    "school_code": "EMSP",
    "cycle": "Mastère spécialisé",
    "academic_level": "Mastère spécialisé",
    "domain": "Commerce - Vente",
    "name": "Mastère Spécialisé en Ingénieur(e) d’Affaires",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "a1ad938e-2ff5-5913-ad77-f8c7e69817ad",
    "school_code": "MLV BS",
    "cycle": "Nos Mastères",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "MASTÈRE MANAGEMENT DE PROJET ET DE L'INNOVATION(MPI)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "a206935c-4714-507f-a49a-a0f2a9ee55f9",
    "school_code": "MLV BS",
    "cycle": "Nos Mastères",
    "academic_level": null,
    "domain": "Commerce et Vente",
    "name": "Mastère Ingenieurs d'Affaires (IA)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "a22d0a52-67bf-53e6-878b-797bdb7730c2",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "Bachelor’s Degree in International Management and Business",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "a23849e8-98c1-5ca1-a8d2-58a8d299095d",
    "school_code": "ESUV",
    "cycle": "NIVEAU BAC",
    "academic_level": null,
    "domain": "niveau bac",
    "name": "TP manager d'equipe relation client a distance",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "a281bc81-5660-52ff-93e2-910d27c71433",
    "school_code": "ESIIA",
    "cycle": "Mastères Spécialisés",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Spécialisé Intelligence Artificielle et Management",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "a298f26f-c9ab-5bf7-8716-e2efe81fa626",
    "school_code": "EMSP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère E-Santé et Transformation Digitale",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "a2c54c5e-e791-5737-9a4c-2c1d85163cdb",
    "school_code": "ISMOD",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Gestion-Luxe",
    "name": "Bachelor Gestion de Luxe et de la Qualité",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "a2c89bea-cc13-5b45-9b69-a23f89598391",
    "school_code": "ESETH",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "BACHELOR'S DEGREE IN PROCUREMENT AND LOGISTICS",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "a31e03b4-5941-50d4-9f41-c15d813340ad",
    "school_code": "LSB",
    "cycle": "Masteres Specialises",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Spécialisé en Comptabilité Audit et Contrôle de Gestion (CAC)",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "a3c0efdb-f417-519c-8f41-c960c7e4ec55",
    "school_code": "LSB",
    "cycle": "Masteres Specialises",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère Spécialisé en Management digitalisation des ressources humaines",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "a3e82cde-ef76-50e2-aa91-fd31273ae6dd",
    "school_code": "EMSP",
    "cycle": "Mastère spécialisé",
    "academic_level": "Mastère spécialisé",
    "domain": "Management et Gestion",
    "name": "Mastère Spécialisé en Management de la Qualité, Hygiène, Sécurité et Environnement",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "a42d153a-8757-5de0-ba72-d3ef7a72b76b",
    "school_code": "EMSP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in Management and Digitisation of QHSE Processes",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "a4f55fc4-d855-58c3-8358-30b8b8be42d7",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "FINANCE",
    "name": "BACHELOR COMPTABILITE, AUDIT ET CONTROLE DE GESTION (CAG)",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "a5021630-c0a0-59cf-85db-87775b10d51d",
    "school_code": "ESJM",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "MASTÈRE SPÉCIALISÉ INTELLIGENCE JURIDIQUE ET MANAGEMENT DIGITAL",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "a50ba38c-f3ab-54c0-8f7a-6a264c898def",
    "school_code": "ESEA",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "MASTER'S DEGREE IN HUMAN RESOURCES AND DIGITALISATION OF OPERATIONS",
    "source_file": "forms/esea.html"
  },
  {
    "id": "a53edc1e-4567-50f1-9e78-1ef30d82af6c",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master's Degree in Management and Strategy",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "a58ea8d8-ddb8-5141-8839-cdd9abf10c83",
    "school_code": "LSB",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "bachelor administartion systemes, reseaux et cybersecurité (ARC)",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "a5f6abd4-6211-5399-b7f1-b7fd4f16a2d9",
    "school_code": "MLV BS",
    "cycle": "Nos Bachelors",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "BACHELOR GESTION DE PROJETS (GP)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "a6251cab-7494-5480-abc8-a8a8e750bc6b",
    "school_code": "EVRY BS",
    "cycle": "BTS",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "BTS Management Commercial Opérationnel (MCO)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "a63c7100-10d9-50b8-80de-156c991a284b",
    "school_code": "EMSP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Marketing et Communication Digitales",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "a6a07e52-c1a0-5b60-87ed-019acc9ff483",
    "school_code": "MLV BS",
    "cycle": "Nos Mastères",
    "academic_level": null,
    "domain": "Commerce et Vente",
    "name": "Mastère Entrepreneuriat et Business Development (EBD)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "a6a5a0ab-d2c8-5bb1-88af-0c8f35b134c9",
    "school_code": "EMSP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Finance de Marché et Management des Risques",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "a6bd0d27-871c-5b52-8319-8a2601ea0fa4",
    "school_code": "ESMAS",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "FINANCE",
    "name": "Mastère Ingenieur d'Affaires et de Transitions(IA)",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "a6d4699a-6314-5d30-b810-b6eb88d7a8a2",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Commerce - Vente",
    "name": "Bachelor Commerce International",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "a74ed456-4529-5fbe-8bbd-487151e2266e",
    "school_code": "ISMOD",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Gestion-Luxe",
    "name": "Bachelor Gestion de Luxe et de la Qualité",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "a7833cf2-26fa-5a40-ae55-c4ae8e989287",
    "school_code": "ESMAS",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "MANAGEMENT-MARKETING",
    "name": "BACHELOR AGENT SPORTIF 2.0 (AS)",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "a78e01f8-9403-5fd7-bfee-c367fd9a2289",
    "school_code": "EMSP",
    "cycle": "Mastère spécialisé",
    "academic_level": "Mastère spécialisé",
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Spécialisé Cybersécurité et Management des Données Personnelles",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "a797edc1-0555-5af0-94f0-12fdea96c35b",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Stratégie et Management International",
    "name": "Responsable Etablissement Marchand",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "a79b2ad1-c990-564a-8aa4-d1236e72c9a4",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Spécialisé en Banque Finance et Assurance",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "a7ceda66-79fa-505a-8d10-53214a82e385",
    "school_code": "MLV BS",
    "cycle": "Nos Bachelors",
    "academic_level": null,
    "domain": "Marketing et Communication",
    "name": "BACHELOR E-COMMERCE",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "a7db116d-bd85-564a-88dc-a2fae07f37a4",
    "school_code": "ESUV",
    "cycle": "Mastères Spécialisés",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Master spécialisé marketing communication digitales (MCD)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "a7f6fe13-af70-52a3-b0a5-87e0cd6e4df5",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN E-COMMERCE",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "a7f96947-4981-54bd-b6a9-19e1d1604d65",
    "school_code": "ESMEP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "MASTER'S DEGREE IN BUSINESS LAW AND MANAGEMENT",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "a80de9ea-961b-5190-b36d-8391e87192bc",
    "school_code": "ESMEP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "COMMERCE - VENTE",
    "name": "MASTÈRE EN INGENIEUR(E) D'AFFAIRES",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "a820db0e-d904-50e4-a6f7-33592a64f41b",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN MARKETING AND COMMUNICATION ( INNOVATION MANAGEMENT)",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "a8809578-9b25-5c4a-8dcc-e557fc2fdc4d",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "COMMERCE - VENTE",
    "name": "BACHELOR E-COMMERCE",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "a894388a-e4bb-5110-be0b-cceadf6e5fdb",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Commerce - Vente",
    "name": "Bachelor Marketing et Communication",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "a8a6c330-0aca-5115-87eb-f9e976a8266d",
    "school_code": "ESJM",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "MASTÈRE EN DROIT DES AFFAIRES ET MANAGEMENT",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "a929dded-9eb5-5cbc-9004-d231e6cb9d23",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN HUMAN RESOURCES",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "a99edd86-e346-59a1-bb09-d0dfd8dcaaac",
    "school_code": "ESUV",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Bachelor Chargé de Communication Digitale, Evenementielle et IA impavct (CDE)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "a9beb464-343f-5cf7-a97b-8cd372b1a4bc",
    "school_code": "ESMEP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "MASTERE MANAGEMENT DES PRODUITS DIGITAUX",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "a9c54c28-561e-565a-987d-5acfb136c170",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "FINANCE",
    "name": "DIPLOME DE COMPTABILITE ET DE GESTIO (CDG)",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "a9d3d60a-536d-5fbf-aacb-fa1df7633599",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Commerce - Vente",
    "name": "Bachelor Start-up et Business Development",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "aa7c73d1-8438-558b-acd1-42e19f980496",
    "school_code": "ESUV",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Bachelor en Commerce International(CI)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "aaf56e85-2ad0-5380-a143-224438657029",
    "school_code": "ESETH",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "BACHELOR'S DEGREE IN BUSINESS MANAGEMENT",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "ab16eb6e-78d1-59c5-8ab7-d34ad310bcb5",
    "school_code": "ESUV",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Bachelor's Degree",
    "name": "Bachelor's Degree in marketing and communication",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "ab1ca704-42e6-56fe-9151-6ce99754fae3",
    "school_code": "MLV BTS",
    "cycle": "BTS (Brevet de Technicien Supérieur)",
    "academic_level": null,
    "domain": "COMMERCE - VENTE",
    "name": "BTS COMMERCE INTERNATIONAL",
    "source_file": "forms/mlv-bts.html"
  },
  {
    "id": "ab83dee3-45ef-5c78-83bb-778626ee688a",
    "school_code": "ESJM",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "MASTERE DROIT DE L'ENVIRONNEMENT ET DES CONTRAINTES DE TRANSITION (DEC)",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "ab90f2b6-9d7f-5b43-81ae-4e1ce3ccf5f7",
    "school_code": "EMSP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in E-Health and Digital Transformation",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "abc1bc5a-bd1f-5054-8658-5ce0c0afc949",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "Bachelor's Degree in Project Management",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "abd0239b-7d04-5831-bf24-f35aa40df934",
    "school_code": "EVRY BS",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Master's Degree",
    "name": "Master degree in gital project and innovation management (MPI)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "abd09d72-3f61-5ffa-bb73-0e20ba3248f0",
    "school_code": "ESIIA",
    "cycle": "Mastère",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère E-Banking et Fintech",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "abe4a41c-049d-56b2-aefe-835c916a2005",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Stratégie et Management International",
    "name": "Bachelor Stratégie et Management International",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "ac0e5b01-30f2-5701-9b42-3ac3c90facac",
    "school_code": "ESJM",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "BACHELOR GESTION DE LA PERFORMANCE ET GOUVERNANCE NUMÉRIQUE",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "ac1224d2-1ae2-586a-9dda-314193cde2fe",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Start-up and Business Development",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "ac1700de-9891-5727-aecf-8733c8aeda88",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Start-up and Business Development",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "ac7f0e8f-5e58-5ed2-bf16-a1e003de3ac4",
    "school_code": "DCG FORMATIONS",
    "cycle": "MBA",
    "academic_level": "MBA",
    "domain": "MBA",
    "name": "Master of Business Administration (MBA)",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "acb52b6e-ab4b-50ae-9bd0-e5da5510d8f9",
    "school_code": "EMSP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Cybersécurité et Management des Données Personnelles",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "acc2e4fa-949c-53f6-952d-25b86ddb3f13",
    "school_code": "ESART",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "BACHELOR'S DEGREE IN E-COMMERCE",
    "source_file": "forms/esart.html"
  },
  {
    "id": "ad572425-76db-53ce-8984-f486e82355bb",
    "school_code": "ESUV",
    "cycle": "Mastères Spécialisés",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "magement et gestion",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "ad758ebc-17e9-5565-9bfc-7682a46adc36",
    "school_code": "ESUV",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Bachelor start-up & business development",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "ad924947-315d-5e52-8978-4a35b8deaabf",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "Bachelor's Degree in Business Law",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "ad93632e-2b92-5a7f-9902-df72d717cd2e",
    "school_code": "ESART",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "BACHELOR'S DEGREE IN CINEMA AND AUDIOVISUAL STUDIES",
    "source_file": "forms/esart.html"
  },
  {
    "id": "adb4e7cb-0766-5bd3-a0fe-1935e0bd6361",
    "school_code": "ESEA",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "MANAGEMENT ET GESTION",
    "name": "BACHELOR GESTION AUTOMATISÉE DE PROJETS",
    "source_file": "forms/esea.html"
  },
  {
    "id": "adca2689-bc3d-5d39-81fd-532fbad960f1",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Spécialisé en Comptabilité Audit et Contrôle de Gestion (CAC)",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "addb27fa-db44-5e90-8acf-412db0c114b3",
    "school_code": "LSB",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Management et gestion",
    "name": "bachelor en droit des entreprises (DE)",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "aeba108d-f2bc-526a-a3eb-735b9c447b57",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Marketing and Communication",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "aed08b51-f34c-532e-a655-402919186519",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "MANAGEMENT ET GESTION",
    "name": "BACHELOR EN DROTI DES ENTREPRISES",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "af26f361-f3d5-569c-b2ab-214451427534",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Management et Gestion",
    "name": "Bachelor Gestion de Projets",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "af3b9141-c9a8-5fb7-abb7-215a555a3f54",
    "school_code": "ESART",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "COMMUNICATION - MARKETING - DIGITAL",
    "name": "BACHELOR GESTION DE MARQUE ET BRANDING",
    "source_file": "forms/esart.html"
  },
  {
    "id": "afb26827-453e-5288-b1fe-2935eba2db27",
    "school_code": "ESIIA",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Bachelor's Degree",
    "name": "Bachelor's Degree in Systems Administration, Networks and Cybersecurity",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "afcd4423-a663-50a5-a6d6-b5acad8bd81e",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Commerce - Vente",
    "name": "Bachelor Gestion des Risques Interculturels",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "b0485162-dff1-55a0-bada-03f984552085",
    "school_code": "LSB",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Bachelor getsion de l'innovation",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "b0734982-dbe7-557e-a870-cd23df2c0cef",
    "school_code": "ESART",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "COMMUNICATION - MANAGEMENT",
    "name": "MASTÈRE SPÉCIALISÉ MANAGEMENT DES PRODUITS DIGITAUX (MPD)",
    "source_file": "forms/esart.html"
  },
  {
    "id": "b0796983-faea-5ca4-973a-e7ec0064b284",
    "school_code": "MLV BS",
    "cycle": "Nos Bachelors",
    "academic_level": null,
    "domain": "Finance",
    "name": "BACHELOR COMPTABILITÉ, AUDIT ET CONTRÔLE DE GESTION (CAG)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "b0d59af5-93cf-5347-87f1-fd5e57d989c0",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN START-UP AND BUSINESS DEVELOPMENT",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "b104dff6-8c22-5708-a329-7ff253861398",
    "school_code": "MLV BTS",
    "cycle": "BTS (Brevet de Technicien Supérieur)",
    "academic_level": null,
    "domain": "MANAGEMENT ET GESTION",
    "name": "BTS CGPME",
    "source_file": "forms/mlv-bts.html"
  },
  {
    "id": "b17c5cc9-0daa-5922-9a23-b45b4cc3132f",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Commerce - Vente",
    "name": "Bachelor Start-up et Business Development",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "b20af9c3-0f08-5bb2-b2af-f83b737a1801",
    "school_code": "EVRY BS",
    "cycle": "NIVEAU BAC",
    "academic_level": null,
    "domain": "niveau bac",
    "name": "TP manager d'unité marchande",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "b2163697-19ee-5c58-be02-af23458c7290",
    "school_code": "ESMEP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "MASTER'S DEGREE IN DIGITAL MARKETING AND COMMUNICATION",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "b2440eff-e72d-5e3f-94c8-f039eddff78b",
    "school_code": "ESUV",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Master's Degree",
    "name": "master's degree in strategic management and business intelligence (SIE)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "b25b24e9-611a-5807-941c-8976b68570a5",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Technologie et Data Innovation",
    "name": "Bachelor Informatique et Réseaux",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "b2fb699d-aea4-5a42-b48a-85acc13f43f2",
    "school_code": "ISMOD",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Mode-Innovation",
    "name": "Mastère Création de Marque et Identité-Produit (MIP)",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "b318bf89-3095-5863-b4ac-9273de56eed0",
    "school_code": "ILMIS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère Management et Numérisation des Processus QHSE",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "b3289e06-ea59-5469-993d-837b621cdda3",
    "school_code": "LSB",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Bachelor gestion de la sante de la transformation numerique",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "b3682a02-4a3a-566f-b0c7-74a03b2e5cd2",
    "school_code": "ESUV",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Bachelor's Degree",
    "name": "Bachelor's Degree in start-up and business development",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "b36f6440-8e46-544c-89ca-aab8fa115163",
    "school_code": "EMSP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in Project and Innovation Management",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "b3ab32c0-f339-5f61-80d1-3d6a9840f2c2",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Corporate Social Responsibility",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "b3b1703d-3272-5f3d-b800-d79a9196ae22",
    "school_code": "LSB",
    "cycle": "Masteres Specialises",
    "academic_level": null,
    "domain": "Stratégie et Management International",
    "name": "Mastère Spécialisé Management strategique et intelligence economique",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "b3de9bb7-d62f-5ff0-ad5f-59712b9c42da",
    "school_code": "ILMIS",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Spécialisé en Finance de Marché et Management des Risques",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "b404d261-fc70-53dc-ae6c-af1d3bb398df",
    "school_code": "ESMOSS",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "SANTÉ-DIGITALE",
    "name": "Mastère Spécialisé Entrepreneuriat et Management Numérique(EMN)",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "b40d4b27-6796-5b9f-a9ba-7b34f4fdb9a0",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "STRATÉGIE ET MANAGEMENT INTERNATIONAL",
    "name": "BACHELOR EN GESTION DES ORGANISATIONS",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "b4a3bfe5-c33a-5e48-9f77-39405bd40869",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Management et Gestion",
    "name": "Bachelor Gestion de Projets",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "b4aec452-1f4f-5822-bd4f-2b92d8790e70",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master's Degree in Strategic Management and Economic Intelligence",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "b4b07ab2-294e-5e5f-87c3-718546b81856",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN START-UP AND BUSINESS DEVELOPMENT",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "b4bebe1b-20f2-5673-b4f8-1df3cc11e1bd",
    "school_code": "ESJM",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "MASTÈRE SPÉCIALISÉ PROPRIÉTÉ INTELLECTUELLE ET GESTION AUTOMATISÉE DES DROITS (PID)",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "b4ecb884-89e9-522b-9309-1b611d6c7392",
    "school_code": "ILMIS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Affaires Internationales et Enjeux Digitaux",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "b564320b-fe3b-52cd-8e69-8181a25e6b81",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Commerce - Vente",
    "name": "Responsable Établissement Marchand",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "b5b7c492-b490-5b76-8128-306556bda834",
    "school_code": "ESMEP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "COMMERCE - VENTE",
    "name": "MASTÈRE EN INGENIEUR(E) D'AFFAIRES",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "b5bb4160-c057-591a-8d3d-0685d10eaf77",
    "school_code": "ESMAS",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "SPORT-BUSINESS",
    "name": "BACHELOR SPORT BUSINESS & DIGITAL TRANSFORMATION (SBS)",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "b64d23be-f303-5ead-9e70-544eeab667ee",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "Bachelor's Degree in Corporate Social Responsibility (CSR)",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "b666a558-2d2e-5c2c-8faf-cec91b6138cd",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Management et Gestion",
    "name": "Bachelor Ressources Humaines",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "b673f413-73bd-52c2-8316-faceb5adc901",
    "school_code": "ILMIS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère Ressources Humaines",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "b70a838c-a2ad-501e-89e3-71fc5e47b007",
    "school_code": "ISMOD",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Mode-Innovation",
    "name": "Bachelor Innovation Textile",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "b7308680-fd2e-54b3-945e-b9924bfea0f8",
    "school_code": "ESUV",
    "cycle": "Mastères Spécialisés",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "mastere spécialisé ux design (UX)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "b73a4a61-33d8-5e7c-91a3-8ede54c6f3e7",
    "school_code": "ESMOSS",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "MÉDICO-SOCIAL",
    "name": "Mastère Ingénierie et Management des Structures Sociales",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "b78dbb3e-b838-509b-bffc-566c357c2fe6",
    "school_code": "EVRY BS",
    "cycle": "Mastères",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Responsable CommunicationDigitale(MCD)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "b7c75f45-1b4e-50e7-a041-7a713e381de6",
    "school_code": "ESJM",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "MASTÈRE CYBERSÉCURITÉ ET MANAGEMENT DES DONNÉES PERSONNELLES (CDP)",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "b805685d-b80f-5587-a7bc-ef0a00dadb02",
    "school_code": "ESJM",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "MASTÈRE SPÉCIALISÉ DROIT IMMOBILIER ET CONTRAINTES REGLEMENTAIRES",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "b8095f61-cc82-51b4-840b-738ec5d97a7c",
    "school_code": "ESMEP",
    "cycle": "MBA",
    "academic_level": "MBA",
    "domain": "MBA",
    "name": "Master of Business Administration (MBA)",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "b8cff480-78bd-5887-8c62-aaede13f3630",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN BRAND MANAGEMENT AND BRANDING",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "b8ed03f3-d538-5295-bdb8-fb08a2c2908b",
    "school_code": "ESMEP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "MASTER'S DEGREE IN BANKING, FINANCE AND INSURANCE",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "b919807e-7a8c-58e6-83c3-9feb292b723a",
    "school_code": "ESMOSS",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "MANAGEMENT-GESTION",
    "name": "Mastère Spécialisé Management de Projet de l'Innovation (MPI)",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "b950ea84-dfbc-5e05-a74c-a2d6b3fdddae",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Finance",
    "name": "Bachelor Gestion des Opérations de Marchés Financiers",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "b966b09e-c3a3-5a7e-a1bc-1f314139573c",
    "school_code": "ESEA",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "STRATÉGIE ET MANAGEMENT INTERNATIONAL",
    "name": "MASTÈRE MANAGEMENT DE PROJET ET DE L'INNOVATION",
    "source_file": "forms/esea.html"
  },
  {
    "id": "b97247e5-c3ec-5ff3-a53d-218e2fca5320",
    "school_code": "ILMIS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Banque Finance et Assurance",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "b98d1aa6-4bcf-50ce-ad6d-84966764a010",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "COMMERCE - VENTE",
    "name": "BACHELOR EN GESTION COMMERCIALE",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "b9a07827-b063-5602-935a-9b596ec512f9",
    "school_code": "ISMOD",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "Bachelor in Fashion and Luxury",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "b9a14b37-c084-522e-83b6-c50f70aafa33",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN PROJECT MANAGEMENT",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "b9c686ad-5c6c-587e-ad88-80da79cd0d89",
    "school_code": "EVRY BTS",
    "cycle": "BTS (Brevet de Technicien Supérieur)",
    "academic_level": null,
    "domain": "TOURISME ET HÔTELLERIE",
    "name": "BTS MANAGEMENT D'UNITÉ DE RESTAURATION",
    "source_file": "forms/evry-bts.html"
  },
  {
    "id": "b9cf8164-8395-5b30-a5d9-5b44bf33e2e5",
    "school_code": "ESETH",
    "cycle": "MASTÈRE SPÉCIALISÉ",
    "academic_level": null,
    "domain": "TOURISME-EVÈNEMENTIEL",
    "name": "MASTÈRE SPÉCIALISÉ INGÉNIERIE DU TOURISME NUMÉRIQUE ET DÉVELOPPEMENT INTERNATIONAL (TDI)",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "b9e61f9e-0ad7-578e-acbb-fe4473c75df3",
    "school_code": "ESMEP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "MASTERE E-SANTE ET TRANSFORMATION DIGITALE",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "ba7c6efe-cae2-5bc0-8602-982937dfcdb3",
    "school_code": "ESIIA",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Master's Degree",
    "name": "Master's Degree in Artificial Intelligence and Management",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "baa2a2d1-81ce-519b-811e-dce381c9838e",
    "school_code": "ESETH",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "VENTE-COMMERCE",
    "name": "BACHELOR COMMERCIALISATION DES PRODUITS TOURISTIQUES ET GESTION DATA (CP)",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "bb00b33c-54dc-5685-a941-a0ea2266290a",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Finance",
    "name": "Bachelor Comptabilité, Audit et Contrôle de Gestion",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "bb41d97a-f485-564b-9963-6e3827b26d60",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Commercial Establishments Management",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "bbbeddce-d957-56fc-9bfb-87d2187d83ad",
    "school_code": "ESMAS",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "MANAGEMENT-MARKETING",
    "name": "BACHELOR MARKETING ET COMMUNICATION DU SPORT (MCS)",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "bbeb2040-40b8-52be-b3d8-fd1e5be8cbf0",
    "school_code": "EVRY BS",
    "cycle": "Mastères Spécialisés",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Master spécialisé marketing communication digitales (MCD)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "bbec83dc-52e5-54d2-8e58-da24faf6e2be",
    "school_code": "ILMIS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Commerce International et Digitalisation",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "bbfd6af3-1223-5385-a5cc-e53b1bcfebce",
    "school_code": "ESUV",
    "cycle": "Mastères",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Entrepreneuriat et Business Development(EBD)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "bc03638b-74bf-562a-b5f9-f757ba321c1b",
    "school_code": "ILMIS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in Digital Marketing and Communication",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "bc2206b6-3eb0-55c0-bbd2-edb916cd83de",
    "school_code": "LSB",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Management et gestion",
    "name": "Bachelor gestion de projets",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "bc6897e2-ebe7-5097-a050-cffaf635d151",
    "school_code": "ESEA",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "Mastère Spécialisé, Transition Energetique, Numerique et Durable(TEEV)",
    "source_file": "forms/esea.html"
  },
  {
    "id": "bc6ac5ce-db2a-55f0-81d1-be8bc39d6ed3",
    "school_code": "ESART",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "BACHELOR'S DEGREE IN MARKETING AND COMMUNICATION",
    "source_file": "forms/esart.html"
  },
  {
    "id": "bc866e3f-21ea-5e39-bd31-0c4584bf992b",
    "school_code": "ESUV",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Bachelor Gestion Commerciale(GC)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "bcf191fa-a9a8-540a-a41b-f52956e748d0",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Finance",
    "name": "Diplôme de Comptabilité et de Gestion",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "bcf89a2b-1f91-5896-9ef2-b4665a6e4163",
    "school_code": "ESETH",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "MARKETING-HÔTELLERIE",
    "name": "MASTÈRE MANAGER DES ETABLISSEMENTS HÔTELIERS ET SMART HOSPITALITY (MH)",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "bcfa4779-4f99-54a7-98bd-317442314f68",
    "school_code": "ESETH",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "MANAGEMENT-ENTREPRENARIAT",
    "name": "MASTÈRE MANAGEMENT DE LA DURABILITÉ ET NUMÉRIQUE RESPONSABLE (RSE)",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "bd1e9c13-cf43-5f2b-9eb6-99c26ac09aae",
    "school_code": "ESIIA",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Master's Degree",
    "name": "Master's Degree in Advertising Strategy and Product Identity",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "bd2278d4-3ff0-56fb-9493-7286d6024146",
    "school_code": "ESMEP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "MANAGEMENT ET GESTION",
    "name": "MASTÈRE EN DROIT DES AFFAIRES ET MANAGEMENT",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "bd26b472-db53-56c2-83fb-923bc2929c94",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "STRATÉGIE ET MANAGEMENT INTERNATIONAL",
    "name": "BACHELOR EN GESTION DES ORGANISATIONS",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "bd501df0-2b15-5d65-9250-0074ff9cd800",
    "school_code": "ILMIS",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "Stratégie et Management International",
    "name": "Mastère Spécialisé en Management International des Projets et Digitalisation des Process",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "bd5c6122-8e78-5ee0-ac3d-18cb133eb574",
    "school_code": "ESMAS",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "Master's Degree in International Sports Management",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "bda493aa-ed75-5dc2-9129-18883c32ce2a",
    "school_code": "ESUV",
    "cycle": "Mastères",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Responsable Communication Digitale Evenementielle et IA Impact(CDE)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "be164d8f-4103-5e6f-ab2c-d01e4fd2f6ce",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Finance",
    "name": "Bachelor Comptabilité, Audit et Contrôle de Gestion",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "be6323f3-a6dc-50a9-8521-47ce88f4379a",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Stratégie et Management International",
    "name": "Bachelor Responsabilité Societale des Entreprises",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "bee1a41f-1f25-56de-a195-085aebc73a3f",
    "school_code": "EMSP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in Entrepreneurial Management of Digital Projects and Digital Strategy",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "bf07677a-d09e-517b-b704-c759b5e61ef1",
    "school_code": "EMSP",
    "cycle": "Mastère spécialisé",
    "academic_level": "Mastère spécialisé",
    "domain": "Management et Gestion",
    "name": "Mastère Spécialisé en Management Stratégique et Intelligence Économique",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "bf1411f3-6c79-5843-9202-4cc6a3bca336",
    "school_code": "ESEA",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "MASTER'S DEGREE IN ENTREPRENEURSHIP & BUSINESS DEVELOPMENT",
    "source_file": "forms/esea.html"
  },
  {
    "id": "bf314c91-3958-50f0-a996-de4350eb2723",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Finance",
    "name": "Bachelor Gestion de Patrimoine",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "bf448abf-0617-5520-b587-f337cd3e5dce",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Stratégie et Management International",
    "name": "Bachelor Commerce International et Logistique",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "bf7870ad-59aa-54ea-87da-42d11e582119",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Commerce - Vente",
    "name": "Bachelor Responsabilité Sociétale des Entreprises",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "bff804c5-d53e-5cb1-9010-ab39f38577fa",
    "school_code": "ESEA",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "MASTÈRE MARKETING ET COMMUNICATION DIGITALES",
    "source_file": "forms/esea.html"
  },
  {
    "id": "bffecf40-6f9d-5d19-a51f-a364fa928a20",
    "school_code": "ILMIS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère UX-Designer",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "c001ecbc-754e-51e4-8f44-612109984860",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "Bachelor's Degree in Business Management and Commercial Development",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "c01b39bc-1a33-54c1-9b5b-a4ef9e35e0d4",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Management et Gestion",
    "name": "Bachelor Achats et Logistique",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "c0dfbb00-cdec-523a-a9ee-094dd36fb127",
    "school_code": "LSB",
    "cycle": "Masteres",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Comptabilité Audit et Contrôle de Gestion (CAC)",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "c0fefd88-bac3-5c45-b8ad-6d17fd484b3d",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN START-UP AND BUSINESS DEVELOPMENT",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "c13c3a99-59f1-5a52-9ec2-417a9573afc1",
    "school_code": "EMSP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Comptabilité Audit et Contrôle de Gestion (CAC)",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "c13e692f-8710-504b-8657-d6e0621d08c3",
    "school_code": "ESUV",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Bachelor's Degree",
    "name": "Bachelor's Degree in purchasing and logistics",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "c14b5867-bc8b-59e5-b1a3-4c6c9d64bcc3",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "Higher Diploma in Accounting and Management (DSCG)",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "c171dad4-d345-5f20-a93b-7507dc67452d",
    "school_code": "ESEA",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "MASTERE SPECIALISE MANAGEMENT ET DIGITALISATION DES PROCESSUS ACHATS ET LOGISTIQUE",
    "source_file": "forms/esea.html"
  },
  {
    "id": "c1a3ae57-eb05-512a-b02c-8adae0e62052",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Commerce - Vente",
    "name": "Bachelor Commerce International",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "c1d041fd-99f7-5fb4-b4ff-f75ebfb99611",
    "school_code": "EMSP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Cybersécurité et Management des Données Personnelles",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "c1e3f67f-a88b-558a-b071-a6f3120b0cef",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "MANAGEMENT ET GESTION",
    "name": "BACHELOR DES RESSOURCES DES RESSOURCES HUMAINES",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "c20e9514-0535-54ee-a41a-1a7e8158ac3d",
    "school_code": "ESART",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "COMMERCE-GESTION-BUSINESS DEVELOPMENT",
    "name": "MASTÈRE EN ENTREPRENEURIAT ET BUSINESS DEVELOPMENT (EBD)",
    "source_file": "forms/esart.html"
  },
  {
    "id": "c267567a-f485-5a00-bf07-889b22932b7b",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "Bachelor’s Degree in International Business",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "c297125f-ded3-50ca-999b-b8e29e1c8418",
    "school_code": "ILMIS",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Spécialisé Cybersécurité et Management des Données Personnelles",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "c2be90db-0d3f-5fed-a906-f37edec290ce",
    "school_code": "ESIIA",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Master's Degree",
    "name": "Master's Degree in E-Business and Digital Strategy",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "c2ec88c8-ca3d-5884-8cb3-10fb32550c01",
    "school_code": "ESMEP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "MASTERE MANAGEMENT ET DIGITALISATION DES PROCESSUS D'ACHATS ET LOGISTIQUE",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "c333f183-228d-56b8-b6f3-3748a061291f",
    "school_code": "ESJM",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "MASTÈRE INTELLIGENCE JURIDIQUE ET MANAGEMENT DIGITAL",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "c389e37d-c1ac-5fd3-b085-3af3b0883369",
    "school_code": "ESUV",
    "cycle": "NIVEAU BAC",
    "academic_level": null,
    "domain": "niveau bac",
    "name": "TP conseiller en vente",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "c40e6713-f0bb-5427-8acf-12a36080a6ca",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "FINANCE",
    "name": "BACHELOR COMPTABILITE, AUDIT ET CONTROLE DE GESTION (CAG)",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "c41f664c-8a55-58d4-a574-611f3398bb17",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "MANAGEMENT ET GESTION",
    "name": "BACHELOR DES RESSOURCES DES RESSOURCES HUMAINES",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "c4790211-9664-51f1-9be9-6e7b32915fd5",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "STRATÉGIE ET MANAGEMENT INTERNATIONAL",
    "name": "BACHELOR EN GESTION DE LA SANTE DE LA QUALITE HYGIENE SECURITE ENVIRONNEMENT(QHSE)",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "c48bc216-3e48-5d67-b678-d885ced438de",
    "school_code": "LSB",
    "cycle": "Masteres Specialises",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Spécialisé en Finance de Marché et Management des Risques",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "c4df7a40-6ab0-5329-922b-e62077775c47",
    "school_code": "ILMIS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère en Ingénieur(e) d'Affaires",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "c517c7ae-082b-517c-8b64-31354dc05675",
    "school_code": "ESMOSS",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "MÉDICO-SOCIAL",
    "name": "Mastère Specialisé Actions Sociales, Handicap et Solutions Technologiques(ASH)",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "c551a46f-8035-5998-a687-b05cfcfadab8",
    "school_code": "CESCOM",
    "cycle": "BACHELOR (BAC+3)",
    "academic_level": null,
    "domain": "COMMERCE-VENTE",
    "name": "Bachelor Commerce et Marketing",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "c61e0e67-4f80-595c-ad58-89d4bfa1dd56",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Technologie et Data Innovation",
    "name": "Bachelor Développement Web et Application",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "c6308b9d-6b4a-5dff-9806-9ed86135c4cc",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "COMMERCE - VENTE",
    "name": "BACHELOR EN MARKETING ET COMMUNICATION",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "c6337b10-ea63-52c4-bd16-67f8825b73a0",
    "school_code": "ESMEP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "FINANCE",
    "name": "MASTÈRE EN E-BANKING ET FINTECH",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "c686e438-8fa8-51f4-a035-39f3312351b1",
    "school_code": "MLV BS",
    "cycle": "Nos Mastère Spécialisé",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "MASTÈRE SPECIALISE MANAGEMENT DE PROJET ET DE L'INNOVATION (MPI)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "c69cdcb6-0bdf-5ed4-ba87-790219d143f2",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN PROCURMENT AND LPOGISITCS",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "c6cf66e6-bca4-5d89-83d0-713eb32bdc3c",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Commerce - Vente",
    "name": "Bachelor Marketing et Communication",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "c6e14cd9-67d1-5560-93d9-1cfba7295f30",
    "school_code": "ILMIS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Management des Produits Digitaux",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "c700528e-75dd-55e0-960d-354289875a1a",
    "school_code": "ESART",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "AUDIOVISUEL - CINÉMA - PRODUCTION",
    "name": "MASTÈRE SPÉCIALISÉ ARTS ET SPECTACLE VIVANT (ASV)",
    "source_file": "forms/esart.html"
  },
  {
    "id": "c7014385-1fd0-5001-8822-224095b142a5",
    "school_code": "ESEA",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "COMMERCE VENTE",
    "name": "MASTÈRE SUSTAINABLE SUPPLY CHAIN AND DIGITALISATION",
    "source_file": "forms/esea.html"
  },
  {
    "id": "c701476a-c6b5-51bb-83b3-f8651e2fe29c",
    "school_code": "ESIIA",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Master's Degree",
    "name": "Master's Degree in Management and Digitalisation of Procurement and Logistics Processes",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "c8553dcd-31f5-5153-997e-17e3dbb42f91",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "Bachelor’s Degree in International Business",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "c86e7b63-e4bd-5494-9329-815dc4d97e4f",
    "school_code": "EVRY BS",
    "cycle": "Mastères Spécialisés",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Spécialisé management et des produits digitaux (MPD)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "c8930666-87cc-5c37-84d3-aad75aabdeb0",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Procurement and Logistics",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "c8abd849-fd04-5ef3-ae54-69f008e965f2",
    "school_code": "ESART",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "MASTER'S DEGREE IN UX DESIGN",
    "source_file": "forms/esart.html"
  },
  {
    "id": "c8b67d6d-ba55-58e0-b2e0-1517dd706017",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Commercial Establishments Management",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "c8bb8c87-0497-598e-8794-6be4bfb57c20",
    "school_code": "ESETH",
    "cycle": "MASTÈRE SPÉCIALISÉ",
    "academic_level": null,
    "domain": "MANAGEMENT-ENTREPRENARIAT",
    "name": "MASTÈRE SPÉCIALISÉ ENTREPRENEURIAT ET BUSINESS DEVELOPMENT DIGITAL (EBD)",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "c8df4466-23f9-50c8-959f-690ba44e226e",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "Bachelor’s Degree in International Management and Business",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "c8ff6daf-12bf-58dc-a8da-5240684f7f98",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "Bachelor's Degree in Human Resources Management",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "c91713f8-e964-557b-867c-50fabf6f78c3",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Stratégie et Management International",
    "name": "Mastère Management et Stratégie",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "c96aa6f0-9899-5fd2-8905-ab26e891f0f8",
    "school_code": "ESUV",
    "cycle": "Mastères",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "mastere ingenieur(e) d'affaires (IA)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "c9c2b506-8c8d-59fe-bef6-9929d7f600ea",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "Bachelor's Degree in Business Law",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "ca79abfd-7a6d-50ff-85ce-0a89027be9d8",
    "school_code": "ILMIS",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Spécialisé en E-Banking et Fintech",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "caa2624f-a670-503e-bd39-e126bb0cfdc4",
    "school_code": "ESEA",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "MASTERE SPECIALISE MANAGEMENT ET DIGITALISATION DES PROCESS QHSE",
    "source_file": "forms/esea.html"
  },
  {
    "id": "cacd1206-112b-51b8-836b-9963680e93a2",
    "school_code": "ESETH",
    "cycle": "MBA",
    "academic_level": null,
    "domain": "MBA",
    "name": "MASTER OF BUSINESS ADMINISTRATION (MBA)",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "cace1300-6bd2-5d81-b6f9-d64c1020b7b5",
    "school_code": "MLV BS",
    "cycle": "Nos Mastère Spécialisé",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Spécialisé Comptabilité Audit et Controle de Gestion(CAC)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "cad3fb74-8957-5fc1-ad26-8330bfe52500",
    "school_code": "ESETH",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "VENTE-COMMERCE",
    "name": "BACHELOR GESTION ET NUMÉRISATION DES PROCESSUS D'ACHATS ET LOGISTIQUE (AL)",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "cafe0f3a-c470-5532-b4f1-9cb2969882a7",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Commerce - Vente",
    "name": "Bachelor Marketing et Communication",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "cb69f9c5-9590-5f6d-8616-5aca5590f0b4",
    "school_code": "ESART",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "MASTER'S DEGREE IN AUDIOVISUAL PRODUCTION",
    "source_file": "forms/esart.html"
  },
  {
    "id": "cb9dd3df-3d67-504a-9ef3-024df7b7a71d",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "FINANCE",
    "name": "DIPLOME DE COMPTABILITE ET DE GESTIO (CDG)",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "cbd49955-b930-5be6-b8ca-a97ae7035c6a",
    "school_code": "CESCOM",
    "cycle": "MASTÈRES SPÉCIALISÉS (BAC+6)",
    "academic_level": null,
    "domain": "DROIT-LOGISTIQUE-BUSINESS",
    "name": "MS Logistique Globale",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "cc3a9197-897c-5977-8fd5-afb64de8caf0",
    "school_code": "ESMEP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "MASTERE MANAGEMENT DES PRODUITS DIGITAUX",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "cc3b7d79-1b29-5e26-b773-f653052c82ce",
    "school_code": "ESMAS",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "Master's Degree in Sports Organisation Management",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "cc8885fb-b193-5d7d-899a-3b927d3253f4",
    "school_code": "ESETH",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "MASTER'S DEGREE IN SUSTAINABLE TOURISM",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "ccd7d180-11fb-528c-ba6e-27152626b4b4",
    "school_code": "EVRY BS",
    "cycle": "Mastères Spécialisés",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Spécialisé entrepreneuriat & business development (EBD)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "cd0e16ae-e780-5015-b252-7ed2fdd11cea",
    "school_code": "EVRY BS",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Master's Degree",
    "name": "Master's degree in digital event and ai-driven communication (CDE)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "cd494f65-5983-5102-ad0b-699cfe719317",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Management et Gestion",
    "name": "Bachelor Responsabilité Sociétale des Entreprises",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "cd55dfda-2bbd-57b1-8242-81c177918d97",
    "school_code": "EMSP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Stratégie et Management International",
    "name": "Mastère Management et Stratégie",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "cd560871-fa9f-5038-86f1-aff9337308f8",
    "school_code": "ESETH",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "COMMERCE-DIGITAL",
    "name": "MASTÈRE INGÉNIEUR D'AFFAIRES ET DE TRANSITION (IA)",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "cdfc2fb2-e220-5821-b10e-97a1eaf0013d",
    "school_code": "ESMEP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "MASTERE MANAGEMENT DE PROJET ET DE L'INNOVATION",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "cdfdbf8e-8bab-5f08-a393-bf4ea613d646",
    "school_code": "ESMEP",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "COMMERCE - VENTE",
    "name": "MASTÈRE SPÉCIALISÉ ENTREPRENEURIAT ET BUSINESS DEVELOPMENT",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "ce22eba0-fc2e-59d9-a5b0-fbe66df30c77",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN QUALITY, HYGIENE, SAFETY AND ENVIRONMENT (QHSE)",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "ce65cc83-0fac-5c22-b931-2f92903c96ab",
    "school_code": "ESMAS",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "Bachelor's Degree in Sports Event Management",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "ce96c94c-b6f9-5fff-89a7-81a282f2f951",
    "school_code": "LSB",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Finance",
    "name": "bachelor comptabilité audit et controle de gestion (CAG)",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "cec46d7b-d882-5377-9101-a6d91c50a0c5",
    "school_code": "ESART",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "BACHELOR'S DEGREE IN DIGITAL AND EVENT COMMUNICATION WITH AI IMPACT",
    "source_file": "forms/esart.html"
  },
  {
    "id": "cecd15d5-3f80-5d48-9f5b-e821348980a1",
    "school_code": "ESMAS",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "Mastère Spécialisé Management et Digitalisation des Process QHSE (MD-QHSE)",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "cf21feb2-f66c-52a0-a7e7-49f87e128c49",
    "school_code": "MLV BTS",
    "cycle": "BTS (Brevet de Technicien Supérieur)",
    "academic_level": null,
    "domain": "TOURISME ET HÔTELLERIE",
    "name": "BTS MANAGEMENT D'UNITÉ D'HÉBERGEMENT",
    "source_file": "forms/mlv-bts.html"
  },
  {
    "id": "cf73f9c9-b5d6-5071-867b-4d698147911b",
    "school_code": "ESEA",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "MASTER'S DEGREE IN MANAGEMENT AND DIGITALISATION OF PURCHASING AND LOGISTICS PROCESSES",
    "source_file": "forms/esea.html"
  },
  {
    "id": "cfe5a315-f402-5902-992f-250ff3e37415",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Management et Gestion",
    "name": "Bachelor Gestion de Projets",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "d03869e5-4923-52ee-833e-02a81467de08",
    "school_code": "ESMAS",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "Bachelor's Degree in Sports Start-Ups and Business",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "d046fee2-018d-53e9-ac7d-d2e02c9fa261",
    "school_code": "EMSP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in Quality, Health, Safety, and Environment Management",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "d0490b00-b535-5b74-85e0-5824a368fd64",
    "school_code": "ESUV",
    "cycle": "Mastères Spécialisés",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Spécialisé management et des produits digitaux (MPD)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "d058a66a-c4a7-5967-b173-5a38cb126d75",
    "school_code": "ESIIA",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Bachelor UX/UI Design",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "d08da213-1350-5a19-9f54-35f752c6ed49",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master's Degree in Management and Strategy",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "d0b0e75a-e9a6-5fc4-89e9-abbd637bcd4f",
    "school_code": "ESUV",
    "cycle": "Mastères Spécialisés",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère Spécialisé ingenieur (e) d'affaires (IA)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "d1209289-11df-58d2-b6f8-8fb8fbadebc9",
    "school_code": "ESMAS",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "Master's Degree in Management and Digitalisation of Procurement and Logistics Processes",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "d1299c53-3d93-573b-8da3-eb2811af49e9",
    "school_code": "ESMOSS",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "MÉDICO-SOCIAL",
    "name": "Bachelor Medico-Social et Innovation Technologique d'Accompagnement(MSA)",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "d174cbf7-f474-5335-b6bc-69b6334555ef",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère E-Banking et Fintech",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "d17badef-4a65-54de-98f7-36d3dab189ae",
    "school_code": "ESUV",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Master's Degree",
    "name": "master's degree in business engineering",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "d1da38e9-b928-5679-9936-8a8de9c520e8",
    "school_code": "EMSP",
    "cycle": "Mastère spécialisé",
    "academic_level": "Mastère spécialisé",
    "domain": "Commerce - Vente",
    "name": "Mastère Spécialisé Marketing, Communication Internationale et Digitale",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "d1ee6099-d800-5dad-8d9b-92b141647808",
    "school_code": "ESEA",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "STRATÉGIE ET MANAGEMENT INTERNATIONAL",
    "name": "MASTÈRE EN MANAGEMENT ET STRATÉGIE (MS)",
    "source_file": "forms/esea.html"
  },
  {
    "id": "d230b42e-3181-5e26-9439-0a51ef72772a",
    "school_code": "MLV BS",
    "cycle": "Nos Bachelors",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "BACHELOR GESTION DE LA SANTÉ ET DE LA TRANSFORMATION NUMÉRIQUE (GST)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "d24b344f-43ad-513e-a12f-528494273ef2",
    "school_code": "EVRY BS",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Bachelor start-up & business development",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "d25971d0-2e0d-57b5-823c-266441bd2f05",
    "school_code": "LSB",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Management et gestion",
    "name": "bachelor qualite hygiene securite et environnement (QHSE)",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "d2670ba7-f01e-54b8-a549-282c7f730a61",
    "school_code": "ISMOD",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "Bachelor in Fashion and Luxury",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "d2ef7ee4-f4c1-5095-803b-edb94b9cf230",
    "school_code": "ESJM",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "BACHELOR CHARGE D'AFFAIRES",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "d31e3d90-5286-54ae-8d78-33ea1d4aead1",
    "school_code": "ESJM",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "MASTÈRE SPÉCIALISÉ MANAGEMENT DE LA CONCURRENCE ET DU NUMÉRIQUE (MCN)",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "d33bf94f-c5cc-5074-b5f2-b9b60d03301e",
    "school_code": "MLV BTS",
    "cycle": "BTS (Brevet de Technicien Supérieur)",
    "academic_level": null,
    "domain": "TOURISME ET HÔTELLERIE",
    "name": "BTS MANAGEMENT D'UNITÉ DE RESTAURATION",
    "source_file": "forms/mlv-bts.html"
  },
  {
    "id": "d3941388-1143-5f88-b4b5-1fce22746b21",
    "school_code": "MLV BTS",
    "cycle": "BTS (Brevet de Technicien Supérieur)",
    "academic_level": null,
    "domain": "FINANCE",
    "name": "BTS ASSURANCE",
    "source_file": "forms/mlv-bts.html"
  },
  {
    "id": "d3b7bb08-b2eb-55e6-98f9-0edf2cdf0dfb",
    "school_code": "ESMAS",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "Master's Degree in Digital Product Management",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "d3ccbbed-24c7-529c-a4d1-a25c76058f1f",
    "school_code": "ESMAS",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "Mastère Spécialisé Management des Produits Digitaux (MPD)",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "d3f4c2ea-fa8b-5b39-b597-402c78b45a22",
    "school_code": "ESETH",
    "cycle": "MASTÈRE SPÉCIALISÉ",
    "academic_level": null,
    "domain": "COMMERCE-DIGITAL",
    "name": "MASTÈRE SPÉCIALISÉ MANAGEMENT ET DIGITALISATION DES PROCESS QHSE (MD-QHSE)",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "d3f68105-7c46-57db-bdb6-4ed6c40635b6",
    "school_code": "LSB",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Marketing et communication",
    "name": "Bachelor commerce international",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "d3f9bb03-b0a5-55d3-a915-f761ecf7f83c",
    "school_code": "LSB",
    "cycle": "Masteres",
    "academic_level": null,
    "domain": "Stratégie et Management International",
    "name": "Mastère en Management Stratégique et Intelligence Économique (SIE)",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "d442986d-8917-5673-9498-c5079f70c386",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Product Management",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "d46ac1a6-a136-59ea-bea6-9bc24d1d151c",
    "school_code": "ESETH",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "GESTION-RESTAURATION",
    "name": "BACHELOR GESTION DE MARQUE ET BRANDING (GM)",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "d474c283-53c5-5157-bfa6-6b4b2f6f018b",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Management et Gestion",
    "name": "Bachelor Achats et Logistique",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "d53a76b2-0c5d-543b-a338-98486e968816",
    "school_code": "EVRY BS",
    "cycle": "NIVEAU BAC",
    "academic_level": null,
    "domain": "niveau bac",
    "name": "TP conseiller en vente",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "d5d051ce-0d88-5f3e-a153-98f8001e8052",
    "school_code": "ESMAS",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "FINANCE",
    "name": "MASTÈRE MANAGEMENT COMMERCIAL ET SPONSORING SPORTIF 4.0 (MCS)",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "d6088c2f-35e0-5ac3-b4f2-114ab8d32446",
    "school_code": "EVRY BTS",
    "cycle": "BTS (Brevet de Technicien Supérieur)",
    "academic_level": null,
    "domain": "COMMERCE - VENTE",
    "name": "BTS NDRC (NÉGOCIATION ET DIGITALISATION DE LA RELATION CLIENT)",
    "source_file": "forms/evry-bts.html"
  },
  {
    "id": "d6139d26-3f46-5274-87ec-7fa10f743cf9",
    "school_code": "ILMIS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in Digital Product Management",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "d6282dae-23fa-5c40-a770-ab22aa43dc17",
    "school_code": "ESUV",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Master's Degree",
    "name": "Master's Degree in brand creation and product identity",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "d630e822-3037-5be6-b123-691efa92d6b8",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "MANAGEMENT ET GESTION",
    "name": "BACHELOR EN RESPONSABILITE SOCIETALE DES ENTREPRISES",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "d696191a-8bc1-5e58-a536-4cd34b38d7d3",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "Diploma in Accounting and Management",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "d69c144f-3e08-579f-be25-dd2e30ef63ed",
    "school_code": "ILMIS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in Business Development Management",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "d6c5826f-8cf2-56e7-b3fa-1b407477d63f",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Project Management",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "d6fdd682-70ed-5b0b-b56c-78d7530a0712",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Human Resources",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "d702fda3-abf7-5e52-b480-92a001ece40b",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Commerce - Vente",
    "name": "Bachelor Commerce International",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "d77fdef4-ab77-50f1-912a-fc13e617ecb2",
    "school_code": "ESIIA",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Master's Degree",
    "name": "Master's Degree in Systems, Networks and Cybersecurity Administration",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "d79c875b-0102-54b3-98b2-9f42d0d8a144",
    "school_code": "ESMOSS",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "Bachelor's Degree in Social Action",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "d7bce027-3d3f-566b-9c7b-6b0c8789113b",
    "school_code": "ESMOSS",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "MANAGEMENT-GESTION",
    "name": "Mastère Specialisé en Maanagement de la Stratégie (MS)",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "d7c7b989-4fd1-531d-a240-6829b4a93b9c",
    "school_code": "ESJM",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "MASTÈRE SPÉCIALISÉ MANAGEMENT DES CONFORMITÉS ET PROTECTIONS DES PERSONNES (MCP)",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "d8051245-c701-56e4-870d-0a215d39e5e1",
    "school_code": "ESETH",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "MASTER'S DEGREE IN BUSINESS ENGINEERING (IA)",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "d8255fd4-377c-53d8-b77c-2ce64fc674fc",
    "school_code": "MLV BS",
    "cycle": "Nos Mastère Spécialisé",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Spécialisé Lead Developer et Management (LD)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "d8299ebb-9505-5164-a3d8-f1d3ec9f9fff",
    "school_code": "CESCOM",
    "cycle": "BACHELOR (BAC+3)",
    "academic_level": null,
    "domain": "MANAGEMENT ET GESTION",
    "name": "Bachelor Ressources Humaines",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "d83fabf6-0c29-5d50-863c-b7a52443ff44",
    "school_code": "ESUV",
    "cycle": "Mastères Spécialisés",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "mastere spécialisé management et digitalisation des processus achats et logistique (MD-AL)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "d8717bf3-4374-52f6-bcdb-1522ff8963ff",
    "school_code": "ESMEP",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "MASTÈRE SPÉCIALISÉ MANAGEMENT DE PROJET ET DE L'INNOVATION",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "d99f1853-86c0-5cc4-8a63-b84c04d4335e",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "FINANCE",
    "name": "DIPLOME DE COMPTABILITE ET DE GESTIO (CDG)",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "d9dac9fd-f2d2-58a4-bd32-0d53863d7949",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Management et Gestion",
    "name": "Bachelor Ressources Humaines",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "da0e255f-dcdb-529a-8b49-f099380ad6da",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Intercultural Risk Management",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "da6010f4-056a-5b6b-a0d1-b6907c3395a0",
    "school_code": "EMSP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère Ressources Humaines",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "da81a91e-716d-5837-b6af-5fc62d5ab3fc",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Spécialisé en Finance de Marché et Management des Risques",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "da8d0727-3daa-5560-bdeb-8f065c105ea6",
    "school_code": "MLV BTS",
    "cycle": "BTS (Brevet de Technicien Supérieur)",
    "academic_level": null,
    "domain": "TOURISME ET HÔTELLERIE",
    "name": "BTS MANAGEMENT D'UNITÉ DE PRODUCTION CULINAIRE",
    "source_file": "forms/mlv-bts.html"
  },
  {
    "id": "dab69ef2-799f-5937-bdd2-118350a1af95",
    "school_code": "ESMEP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "MASTER'S DEGREE IN E-HEALTH AND DIGITAL TRANSFORMATION",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "dad326fc-c728-53bd-a966-549bf9ec79ec",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Project Management",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "db137d08-9f65-5681-aee5-72241748cd23",
    "school_code": "ESJM",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "BACHELOR CONSEILLER DATA GOVERNANCE ET COMPLIANCE",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "db175338-a374-58ae-894e-c87034edefd5",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Human Resources",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "db1c13a5-4ab1-5924-915d-b7fd757d2417",
    "school_code": "ILMIS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Stratégie et Management International",
    "name": "Mastère Management et Stratégie",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "db600ca4-c31f-5313-99bf-6a6736c9412c",
    "school_code": "ESEA",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "STRATÉGIE ET MANAGEMENT INTERNATIONAL",
    "name": "MASTÈRE MANAGEMENT ET DIGITALISATION DES PROCESSUS ACHATS ET LOGISTIQUE",
    "source_file": "forms/esea.html"
  },
  {
    "id": "db793c45-b968-5719-bcd9-39bf4f84e910",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Commercial Establishments Management",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "dbae4ee9-756e-5747-8705-a3aba9118df4",
    "school_code": "MLV BTS",
    "cycle": "BTS (Brevet de Technicien Supérieur)",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "BTS SERVICES INFORMATIQUES AUX ORGANISATIONS",
    "source_file": "forms/mlv-bts.html"
  },
  {
    "id": "dbd41313-d9a6-5127-8262-b0d0f9b1bd3b",
    "school_code": "LSB",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Finance",
    "name": "Bachelor diplome de Comptabilité et gestion (DCG)",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "dc31803a-b927-5e41-8609-57137ddc65de",
    "school_code": "ESUV",
    "cycle": "Mastères",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère UX Design (UX)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "dc72a67f-7613-5401-a814-332e02f5e66f",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Finance",
    "name": "Bachelor Finance et Comptabilité",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "dc8ad970-2375-5fd0-8472-522e62ded17c",
    "school_code": "ESETH",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "BACHELOR'S DEGREE IN HOTEL AND RESTAURANT MANAGEMENT",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "dcda60ca-228f-57b6-bfa4-0875b47d5ae9",
    "school_code": "ESUV",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Bachelor's Degree",
    "name": "Bachelor's Degree in international trade",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "dd10f1bf-e369-5e86-8163-46e395073d29",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Commerce - Vente",
    "name": "Bachelor Start-up et Business Development",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "dd5c4e8e-e28f-5a38-a270-26e1cadf3049",
    "school_code": "ESIIA",
    "cycle": "MBA",
    "academic_level": "MBA",
    "domain": "MBA",
    "name": "Master of Business Administration (MBA)",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "ddbc83cd-0d2b-5c34-8607-c235a69af64e",
    "school_code": "EMSP",
    "cycle": "Mastère spécialisé",
    "academic_level": "Mastère spécialisé",
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Spécialisé en Manager Entrepreneuriel de Projet Numérique et Stratégie Digitale",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "ddc2fa30-72de-520b-a4fe-b979d02b542d",
    "school_code": "ESMOSS",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "Bachelor's Degree in Health Management",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "ddd66c8c-0375-5bab-a500-38647cdbc497",
    "school_code": "ISMOD",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "Gestion-Luxe",
    "name": "Mastère Spécialisé Gestion-Luxe",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "dddb1286-0724-5da3-a62e-a39b68266d99",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Stratégie et Management International",
    "name": "Bachelor Responsabilité Societale des Entreprises",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "ddf929a9-bdea-5efa-95eb-a1f98208bf68",
    "school_code": "ILMIS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Comptabilité Audit et Contrôle de Gestion (CAC)",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "de0c111d-1bca-5e7a-ac27-fb29bbf19cb0",
    "school_code": "ILMIS",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Spécialisé en Commerce International et Digitalisation",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "de34a7a3-01ad-5678-94d5-4472c71af381",
    "school_code": "CESCOM",
    "cycle": "NIVEAU BAC",
    "academic_level": null,
    "domain": "TITRES PROFESSIONNELS",
    "name": "TP MANAGER D'UNITÉ MARCHANDE",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "de37aa2b-40ac-5a93-91c8-08641af000a1",
    "school_code": "ESMEP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "MANAGEMENT ET GESTION",
    "name": "MASTÈRE EN MANAGEMENT DE LA QUALITE HYGIENE SECURITE ENVIRONNEMENT(QHSE)",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "de806725-9e38-5348-ba23-af0b63980720",
    "school_code": "ILMIS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère en Management de la Qualité Hygiène Sécurité Environnement",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "df117abe-fa43-514f-a9ab-db2219a1f66f",
    "school_code": "MLV BS",
    "cycle": "Nos Mastère Spécialisé",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Spécialisé Intellignece Artificielle et Management (IAM)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "df1eb865-f332-56bf-8ea9-9a600ba9fa96",
    "school_code": "MLV BS",
    "cycle": "Nos Mastère Spécialisé",
    "academic_level": null,
    "domain": "Commerce et Vente",
    "name": "MASTÈRE SPECIALISE COMMERCE INTERNATIONAL ET DIGITALISATION (CID)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "df4cae3d-693f-567d-acfa-0f90b3770fb3",
    "school_code": "ESUV",
    "cycle": "BTS",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "BTS Management Commercial Opérationnel (MCO)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "df4d2c5a-f0ed-538f-b7bc-e6e707361f86",
    "school_code": "ILMIS",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère Spécialisé en Management de la Qualité, Hygiène, Sécurité et Environnement",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "df682e8d-b9c8-5d91-8f99-3ef1e8f4a0dd",
    "school_code": "ESMEP",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "FINANCE",
    "name": "MASTÈRE SPÉCIALISÉ EN BANQUE FINANCE ET ASSURANCE",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "df70a77c-1e18-5aaa-852c-badbf300cbeb",
    "school_code": "ESMEP",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "MANAGEMENT ET GESTION",
    "name": "MASTÈRE SPÉCIALISÉ EN INGENIEUR(E) D'AFFAIRES",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "df85cb9d-2897-5974-a350-817e2fea4831",
    "school_code": "CESCOM",
    "cycle": "MASTÈRES SPÉCIALISÉS (BAC+6)",
    "academic_level": null,
    "domain": "DESIGN-CRÉATION",
    "name": "MS Création Numérique",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "df894b93-0876-5c56-a6e2-1518dff08ca6",
    "school_code": "ESART",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "COMMUNICATION - MANAGEMENT",
    "name": "MASTÈRE MANAGEMENT DE PROJET ET DE L'INNOVATION (MPI)",
    "source_file": "forms/esart.html"
  },
  {
    "id": "dfa9215d-d918-5513-86d6-4e634a33faf6",
    "school_code": "EMSP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère en Ingénieur(e) d'Affaires",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "dfac8dbc-0d3b-5d48-a4a8-b8c9c9dd858a",
    "school_code": "ESJM",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "MASTÈRE MANAGEMENT DES CONFORMITÉS ET PROTECTIONS DES PERSONNES (MCP)",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "dfc1909f-a438-5857-9a38-2d5b9ac738ed",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "FINANCE",
    "name": "BACHELOR GESTION DES OPERATIONS DE MARCHES FINANCIERS (GMF)",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "dfd05cb8-9c09-5b50-bc83-e1ba12192639",
    "school_code": "EVRY BS",
    "cycle": "Mastères Spécialisés",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "mastere spécialisé management et digitalisation des processus achats et logistique (MD-AL)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "dfe28d8b-c356-523f-bf63-d1eb7bad3dba",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Corporate Social Responsibility",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "e01150ed-5e8e-5ce7-a8ae-eb189f5a4071",
    "school_code": "ESETH",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "MASTER'S DEGREE IN EVENT PROJECT MANAGEMENT",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "e013b8a2-42e0-59b0-91bd-3ddab5c8c89c",
    "school_code": "EMSP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Manager Entrepreneuriel de Projet Numérique et Stratégie Digitale",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "e135cfa2-aef3-5fd1-9787-b8414dc805df",
    "school_code": "ESIIA",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Bachelor's Degree",
    "name": "Bachelor's Degree in Data Analysis and Strategic Management",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "e263c9cd-ea25-54ee-b390-124a97b17f1b",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Procurement and Logistics",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "e275c1bd-7fa1-5066-8936-bdd9b37b0165",
    "school_code": "CESCOM",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "Bachelor in International Business",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "e29898f9-4265-50f1-aed8-188450e5ee21",
    "school_code": "ESIIA",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Master's Degree",
    "name": "Master's Degree in Big Data and Digital Marketing",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "e2bec2c4-d9cd-5399-bc7d-c19c9a88e03b",
    "school_code": "EVRY BS",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Bachelor's Degree",
    "name": "Bachelor's Degree in international trade",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "e2c6868e-c914-536f-a1ac-e50dce66422a",
    "school_code": "EMSP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère UX-Designer",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "e2f729d4-b092-58ec-927a-ddfd7b8b0a24",
    "school_code": "ESMOSS",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "MANAGEMENT-GESTION",
    "name": "Mastère Management des Technologies de la Santé(MTS)",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "e3563991-9fa7-5d92-b4aa-e397eda3e349",
    "school_code": "EMSP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Banque Finance et Assurance",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "e37b3dd5-f55e-5de7-a270-cdbc55282ecd",
    "school_code": "ESETH",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "BACHELOR'S DEGREE IN MARKETING AND COMMUNICATION",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "e387e161-11fc-5820-a792-0b9b1cf39c3f",
    "school_code": "ESIIA",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Master's Degree",
    "name": "Master's Degree in Lead Software Development",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "e3d63820-5206-5fce-b3fa-de28a33aed6e",
    "school_code": "CESCOM",
    "cycle": "BTS (BAC+2)",
    "academic_level": null,
    "domain": "FINANCE-GESTION",
    "name": "BTS Comptabilité et Gestion (CG)",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "e45d634a-d477-5372-a8ed-2854cfeb1084",
    "school_code": "ESART",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "COMMUNICATION - MARKETING - DIGITAL",
    "name": "BACHELOR CHARGE DE COMMUNICATION DIGITALE, ÉVÉNEMENTIELLE ET IA IMPACT",
    "source_file": "forms/esart.html"
  },
  {
    "id": "e4eecdb9-4366-5010-b2e6-cdff7cc11a0e",
    "school_code": "ILMIS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère E-Santé et Transformation Digitale",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "e539aba4-40f9-59cd-8be7-bdb5b6339e70",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Intercultural Risk Management",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "e55c025e-23b4-5c49-b203-2ed9d4eefc2a",
    "school_code": "ESMOSS",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "Master's Degree in Social Action and Disability Management",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "e5675f58-facb-5b27-b875-4a6ee1d3f554",
    "school_code": "MLV BTS",
    "cycle": "BTS (Brevet de Technicien Supérieur)",
    "academic_level": null,
    "domain": "MODE ET LUXE",
    "name": "BTS - MÉTIERS DE LA MODE : VÊTEMENTS",
    "source_file": "forms/mlv-bts.html"
  },
  {
    "id": "e5686060-042f-5288-91e3-2e06983d99e1",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "MANAGEMENT ET GESTION",
    "name": "BACHELOR EN RESPONSABILITE SOCIETALE DES ENTREPRISES",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "e57aceeb-d112-51e7-aaa7-ef0097f123ad",
    "school_code": "ESETH",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "BACHELOR'S DEGREE IN BRAND MANAGEMENT AND BRANDING",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "e5a97044-cc7b-5265-8db6-dd477c6a8322",
    "school_code": "LSB",
    "cycle": "Masteres",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère lead developer et management (LD)",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "e5b6639c-1a8d-546f-a253-147f2dad6bfa",
    "school_code": "ESEA",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "BACHELOR TRANSITION ÉNERGÉTIQUE, NUMÉRIQUE ET DURABLE (TEND)",
    "source_file": "forms/esea.html"
  },
  {
    "id": "e5c71de6-c6ce-55fd-8f1e-93987de1d897",
    "school_code": "ILMIS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in Management and Strategy",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "e67357d4-174c-5121-8a04-0dd11080fb96",
    "school_code": "ESMOSS",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "MÉDICO-SOCIAL",
    "name": "Mastère Specialisé Santé Publique et Ecosystèmes Connectés(SP)",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "e68220ff-3eaa-57ea-9ba1-a8a488444416",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN MARKETING AND COMMUNICATION ( INNOVATION MANAGEMENT)",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "e6c36df9-0e68-52a6-85d0-75b3a7de137b",
    "school_code": "CESCOM",
    "cycle": "MASTÈRE (BAC+5)",
    "academic_level": null,
    "domain": "DROIT-LOGISTIQUE-BUSINESS",
    "name": "Mastère Droit des Affaires",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "e6c3a6c1-bfab-591c-8c03-a4c2299ea07d",
    "school_code": "ESETH",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "BACHELOR'S DEGREE IN TOURISM AND LEISURE MANAGEMENT",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "e7302a7b-32b9-5a45-81f6-287af5f7e67a",
    "school_code": "ESJM",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "MASTÈRE SPÉCIALISÉ DROIT DE L'ENVIRONNEMENT ET CONTRAINTES DE TRANSITION (DEC)",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "e74646be-6525-554b-b282-875be1e77cc5",
    "school_code": "ESUV",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Master's Degree",
    "name": "Master degree in gital project and innovation management (MPI)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "e799e766-2024-5f47-99f4-69cfe14c19cf",
    "school_code": "ESART",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "BACHELOR'S DEGREE IN BUSINESS MANAGEMENT",
    "source_file": "forms/esart.html"
  },
  {
    "id": "e838a4e8-ba07-5812-8d62-30b747dd1b4d",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Corporate Social Responsibility",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "e86f74e2-add8-594f-9f6b-8649c362ea5d",
    "school_code": "ESMAS",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "MANAGEMENT-MARKETING",
    "name": "BACHELOR GESTION DES ÉTABLISSEMENTS SPORTIFS ET TRANSFORMATION DIGITALE (RES)",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "e8a45ed6-d4fc-57f0-bc54-5de5c1761845",
    "school_code": "MLV BS",
    "cycle": "Nos Mastère Spécialisé",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "MASTÈRE SPECIALISE MANAGEMENT ET DIGITALISATION DES RESSOURCES HUMAINES",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "e8bc2d1e-cb09-5cf7-a63f-60310712c8bf",
    "school_code": "ESUV",
    "cycle": "NIVEAU BAC",
    "academic_level": null,
    "domain": "niveau bac",
    "name": "TP manager d'unité marchande",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "e917fb5b-30f4-57b4-a410-8708a2d86bb0",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Project Management",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "e98298c5-cc9c-529e-88e8-8ccec0fcad1c",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Corporate Social Responsibility",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "ea2c1e7e-7d3d-5295-b41f-106700cc5551",
    "school_code": "MLV BS",
    "cycle": "Nos Bachelors",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "BACHELOR ADMINISTRATION SYSTÈMES, RÉSEAUX ET CYBERSÉCURITÉ (ARC)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "eb073998-d77c-5bf7-a487-b48c1c567fda",
    "school_code": "EMSP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in UX Design",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "eb2cbff0-d4fe-5f99-b1ac-1b08ec0ac0bb",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN BRAND MANAGEMENT AND BRANDING",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "eb340a80-660e-56b0-a5be-a0ca10cae380",
    "school_code": "MLV BS",
    "cycle": "Nos Mastères",
    "academic_level": null,
    "domain": "Finance",
    "name": "MASTÈRE FINANCE DE MARCHÉ ET MANAGEMENT DES RISQUES",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "eb350731-7197-5766-8579-400acc1a1ec7",
    "school_code": "EVRY BS",
    "cycle": "Mastères Spécialisés",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "mastere spécialisé management strategique et intelligence économique (SIE)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "eb497be6-ac48-5f4f-abd8-684ac2f64b0f",
    "school_code": "ESART",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "DESIGN-CRÉATION",
    "name": "MASTÈRE UX DESIGN (UX)",
    "source_file": "forms/esart.html"
  },
  {
    "id": "ebc887db-fff3-5fed-9c73-1d38297a4277",
    "school_code": "ISMOD",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Mode-Innovation",
    "name": "Bachelor Innovation Textile",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "ebe52699-edfa-5e64-a6ff-3343247df517",
    "school_code": "ISMOD",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Mode-Innovation",
    "name": "Bachelor Mode et Entrepreneuriat",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "ec10ee1f-6484-569b-b09e-061bc3b25857",
    "school_code": "ESMOSS",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "Bachelor's Degree in Procurement and Logistics",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "ec1c1c89-a80f-5596-a038-54c3a24fcadd",
    "school_code": "ESMOSS",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "Master's Degree in e-Health and Digital Transformation",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "ec1fa8ef-39eb-530d-8e78-f5ad907a0b71",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Management et Gestion",
    "name": "Bachelor Gestion de Projets",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "ec811842-4310-5da5-8da1-4f1298b5a818",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Marketing and Communication",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "ec981240-5fb3-59a6-bbc4-a1fc89ae6bed",
    "school_code": "ESJM",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "MASTÈRE PROPRIÉTÉ INTELLECTUELLE ET GESTION AUTOMATISÉE DES DROITS (PID)",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "ec9fd550-05bf-537e-8cd2-9490181e0015",
    "school_code": "ISMOD",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Gestion-Luxe",
    "name": "Bachelor Gestion de Luxe et de la Qualité",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "ecc5af6e-95a3-5930-876a-b88a6fd4107d",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master's Degree in Business Law and Management",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "ee2a7b27-6443-5ecb-aff3-2c999ae684d0",
    "school_code": "ESUV",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Master's Degree",
    "name": "Master degree in entrepreneurship and business development (EBD)",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "ee68238a-1f7a-5584-832d-7b242275c09c",
    "school_code": "ESART",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "COMMERCE-GESTION-BUSINESS DEVELOPMENT",
    "name": "MASTÈRE INGÉNIEUR D'AFFAIRES (IA)",
    "source_file": "forms/esart.html"
  },
  {
    "id": "ee7dd776-c509-508d-a180-3110c8d8eef5",
    "school_code": "ESMAS",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "TECHNOLOGIE ET DATA INNOVATION",
    "name": "Mastère Management et Digitalisation des Process QHSE (MD-QHSE)",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "ee85e284-073f-5050-b38b-0d8ebf38402c",
    "school_code": "EMSP",
    "cycle": "Mastère spécialisé",
    "academic_level": "Mastère spécialisé",
    "domain": "Commerce - Vente",
    "name": "Mastère Spécialisé en Management des Produits Digitaux",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "eeb3364b-8b47-55a3-b186-aff940d89a96",
    "school_code": "ESEA",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "STRATÉGIE ET MANAGEMENT INTERNATIONAL",
    "name": "BACHELOR AGROBUSINESS RESPONSABLE ET TRANSITION NUMÉRIQUE",
    "source_file": "forms/esea.html"
  },
  {
    "id": "eef4a119-694d-544b-81b1-8710e9e31498",
    "school_code": "ESETH",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "MASTER'S DEGREE IN TOURISM MANAGEMENT AND INTERNATIONAL DEVELOPMENT",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "ef367c31-a94b-57d4-91da-36dd52661133",
    "school_code": "EVRY BS",
    "cycle": "Mastères",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère Creation de Marque et Identité Produit(MIP)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "ef766518-7a50-5eef-adfd-aa30f6e29d53",
    "school_code": "ESIIA",
    "cycle": "Mastère",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Banque Finance et Assurance",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "ef832a22-0d0c-5950-9b6c-00058bf337b1",
    "school_code": "ESART",
    "cycle": "MBA",
    "academic_level": null,
    "domain": "MBA",
    "name": "MASTER OF BUSINESS ADMINISTRATION (MBA)",
    "source_file": "forms/esart.html"
  },
  {
    "id": "ef837679-9987-5c5e-b0b7-94acd465a176",
    "school_code": "CESCOM",
    "cycle": "NIVEAU BAC",
    "academic_level": null,
    "domain": "TITRES PROFESSIONNELS",
    "name": "TP PROSPECTION CLIENTÈLE ET VALORISATION DE L'OFFRE COMMERCIALE",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "f00422a8-8e9a-5a3f-83bf-de927bd442e5",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "STRATÉGIE ET MANAGEMENT INTERNATIONAL",
    "name": "BACHELOR EN GESTION DE LA SANTE DE LA QUALITE HYGIENE SECURITE ENVIRONNEMENT(QHSE)",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "f0b7df77-0ea4-51cf-a41b-a68a3b7420ce",
    "school_code": "EVRY BS",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Master's Degree",
    "name": "master's in digital marketing and communication (MCD)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "f14e2427-94b8-5006-a0d8-d2446b9bdefa",
    "school_code": "LSB",
    "cycle": "Masteres Specialises",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Spécialisé Administration systemes, reseaux e cybersécurité (SRC)",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "f14ef253-270a-55bd-8a23-e683fc60f96f",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Commerce - Vente",
    "name": "Bachelor Start-up et Business Development",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "f152e0f3-35aa-5e78-a3ce-0cdc310f9c42",
    "school_code": "LSB",
    "cycle": "Masteres",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère ingenieur d'affaires (IA)",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "f15f036d-79ef-50f6-99ad-354b1ffdbeb5",
    "school_code": "ILMIS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Marketing et Communication Digitales",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "f1872757-fd2d-55c8-8ce7-f708a1b46a79",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "STRATÉGIE ET MANAGEMENT INTERNATIONAL",
    "name": "BACHELOR EN GESTION DE LA SANTE ET DE LA TRANSFORMATION NUMERIQUE",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "f1a4f39d-c832-5844-a274-d60d5730ca7d",
    "school_code": "ESMEP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "MANAGEMENT ET GESTION",
    "name": "MASTÈRE MANAGEMENT ET DIGITALISATION DES RESSOURCES HUMAINES",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "f1ad1892-b0c3-586c-9464-a1d8e7e0b3ac",
    "school_code": "ESART",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "BACHELOR'S DEGREE IN DIRECTING AND EDITING",
    "source_file": "forms/esart.html"
  },
  {
    "id": "f1c67b41-f48e-53bf-82c3-6728195007f4",
    "school_code": "ESMAS",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "Master's Degree in Management and Digitalisation of QHSE Processes",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "f1f1246c-5070-54aa-a66b-d8687a5eb99c",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "Stratégie et Management International",
    "name": "Responsable Etablissement Marchand",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "f207501c-526f-516f-8ced-aef95e0c9874",
    "school_code": "ESART",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "COMMERCE-GESTION-BUSINESS DEVELOPMENT",
    "name": "MASTÈRE SPÉCIALISÉ INGÉNIEUR D'AFFAIRES (IA)",
    "source_file": "forms/esart.html"
  },
  {
    "id": "f2471f9b-344a-5082-a7aa-18a88c0e4f0a",
    "school_code": "EMSP",
    "cycle": "Mastère spécialisé",
    "academic_level": "Mastère spécialisé",
    "domain": "Finance",
    "name": "Mastère Spécialisé en Comptabilité Audit et Contrôle de Gestion (CAC)",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "f287f479-9655-5940-b43a-dac26cc7c6ea",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN SALES AND NEGOCIATION",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "f2980235-9819-5ee0-91ba-4f38c00cfe91",
    "school_code": "ESMEP",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "MANAGEMENT ET GESTION",
    "name": "MASTÈRE SPÉCIALISÉ MANGEMENT ET DIGITALISZTION DES RESSOURCES HUMAINES",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "f2bda137-25e4-5562-b484-878d6b5e3bf2",
    "school_code": "ESEA",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "COMMERCE VENTE",
    "name": "MASTERE SPECIALISE SUSTAINABLE SUPPLY CHAIN AND DIGITALISATION",
    "source_file": "forms/esea.html"
  },
  {
    "id": "f2cc27a8-5d92-5224-bf39-e0a34024ff16",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Management et Gestion",
    "name": "Bachelor Droit des Entreprises",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "f301a193-ca91-5987-856e-5ad9a2e8de5f",
    "school_code": "MLV BS",
    "cycle": "Nos Mastères",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastére Architecture des Systémes Informatiques",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "f3558e6a-a1d7-514b-994d-9b2d17f18109",
    "school_code": "ESIIA",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Bachelor Data Marketing et Développement de Produits Digitaux",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "f391fb5e-7d4a-5342-94f0-61ee36c8234b",
    "school_code": "MLV BS",
    "cycle": "Nos Mastères",
    "academic_level": null,
    "domain": "Stratégie et Management International",
    "name": "MASTÈRE MANAGEMENT STRATÉGIQUE ET INTELLIGENCE ÉCONOMIQUE (SIE)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "f3dc821c-40c0-504f-a5cb-25ad22ea2aa5",
    "school_code": "ESMEP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "MANAGEMENT ET GESTION",
    "name": "MASTÈRE EN MANAGEMENT DEVELOPPEMENT DURABLE ET RSE",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "f4648ba9-0b04-5d70-be20-68517542958c",
    "school_code": "ILMIS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Manager Entrepreneuriel de Projet Numérique et Stratégie Digitale",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "f469fdb5-c4c6-5156-bf53-230eaa70e274",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère Spécialisé en Management et Numérisation des Processus QHSE",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "f49e8c06-b350-588b-81b0-07ac3918a540",
    "school_code": "MLV BTS",
    "cycle": "BTS (Brevet de Technicien Supérieur)",
    "academic_level": null,
    "domain": "FINANCE",
    "name": "BTS COMPTABILITÉ ET GESTION (CG)",
    "source_file": "forms/mlv-bts.html"
  },
  {
    "id": "f5255860-aaef-54a7-bc7d-69fd9d8b5231",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN SALES AND NEGOCIATION",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "f54456c3-aa52-56f6-b5dc-3faf34d56a0c",
    "school_code": "ESART",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "AUDIOVISUEL - CINÉMA - PRODUCTION",
    "name": "BACHELOR CHARGE DE PRODUCTION",
    "source_file": "forms/esart.html"
  },
  {
    "id": "f548255d-8bc7-598c-8f03-2dda7f0378ea",
    "school_code": "ILMIS",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Spécialisé en Management des Produits Digitaux",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "f5555742-0274-518c-a96f-d8099c4a34f1",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Commercial Establishments Management",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "f558d4b3-afc8-55ec-b056-6166cdd562a7",
    "school_code": "MLV BS",
    "cycle": "Nos Mastères",
    "academic_level": null,
    "domain": "Stratégie et Management International",
    "name": "MASTÈRE EN MANAGEMENT ET STRATÉGIE (MS)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "f56a8665-c0d4-506a-a0a8-a74681c954fe",
    "school_code": "MLV BS",
    "cycle": "Nos Bachelors",
    "academic_level": null,
    "domain": "Marketing et Communication",
    "name": "BACHELOR NÉGOCIATION ET VENTE",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "f570c5cd-725d-5802-9275-ad980b94c89f",
    "school_code": "ESETH",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "MASTER'S DEGREE IN SUSTAINABLE DEVELOPMENT AND CSR MANAGEMENT (CSR)",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "f5897d00-bd81-5fd2-8171-fa89a3b485dc",
    "school_code": "ESIIA",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Master's Degree",
    "name": "Master's Degree in Entrepreneurship and Digital Management",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "f5fe9152-baac-5f0d-b6e9-96bb90461233",
    "school_code": "ESETH",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "BACHELOR'S DEGREE IN TOURISM PRODUCT MARKETING",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "f616fa19-fd26-544e-a6d8-0a36cfe347f5",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN HUMAN RESOURCES",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "f62296d7-17ad-593d-bbb4-ff7d3206b562",
    "school_code": "ESETH",
    "cycle": "MASTÈRE SPÉCIALISÉ",
    "academic_level": null,
    "domain": "MANAGEMENT-ENTREPRENARIAT",
    "name": "MASTÈRE SPÉCIALISÉ PROJETS EVENEMENTIELS ET DATA MANAGEMENT (MPE)",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "f6237cc2-88ea-53cf-93df-7fa26b524230",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Stratégie et Management International",
    "name": "Mastère Management et Stratégie",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "f6cba400-7bc7-524f-866c-e5b985504812",
    "school_code": "ILMIS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Finance",
    "name": "Mastère Banque Finance et Assurance",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "f71f4f91-e26d-54f3-a0aa-041c9174d0bb",
    "school_code": "ESMOSS",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "SANTÉ-DIGITALE",
    "name": "Mastère Management des Produits Digitaux (MPD)",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "f75c7037-3179-52f6-9529-5bf0ef67c29e",
    "school_code": "EMSP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master’s Degree in E-Health and Digital Transformation",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "f76a56e1-b4d8-5aee-8d8e-3e8eab3908fe",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "MANAGEMENT ET GESTION",
    "name": "BACHELOR ACHATS ET LOGISTIQUE",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "f793bd91-5a1e-520b-a056-3d7afc475ba6",
    "school_code": "ILMIS",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "Management et Gestion",
    "name": "Mastère en Management de la Qualité Hygiène Sécurité Environnement",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "f7988314-42f9-52d2-ba8c-2c79a1009587",
    "school_code": "ISMOD",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "English Track",
    "name": "Master in Fashion and Luxury Management",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "f7bc5ee9-39ad-52b5-bf56-84e268ebd1ab",
    "school_code": "MLV BS",
    "cycle": "Nos Bachelors",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "BACHELOR DÉVELOPPEMENT WEB ET MOBILE (WM)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "f7da1be7-7444-5383-85a0-d7cf4db9c134",
    "school_code": "EMSP",
    "cycle": "Mastère spécialisé",
    "academic_level": "Mastère spécialisé",
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Spécialisé en E-Santé et Transformation Digitale",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "f7e7b759-0b40-5c45-ba4a-ba512ccee706",
    "school_code": "ESUV",
    "cycle": "NIVEAU BAC",
    "academic_level": null,
    "domain": "niveau bac",
    "name": "TP conseiller commercial",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "f88aad04-c28e-5f6f-8fdc-a105e3507200",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Commerce - Vente",
    "name": "Bachelor Chef de Produit",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "f8f088d5-fd63-5933-b0cd-11130207d0c5",
    "school_code": "LSB",
    "cycle": "Masteres Specialises",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Spécialisé en Commerce International et Digitalisation (CID)",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "f90e6fe4-6786-5b43-81f0-336646a21033",
    "school_code": "ESMOSS",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "Master's Degree in Public Health",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "f942247e-1cd8-5551-bb6d-ab8c1bda4799",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "MANAGEMENT ET GESTION",
    "name": "BACHELOR EN DROTI DES ENTREPRISES",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "f963361c-e71d-58ae-be9c-bcceaa72f70b",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Management et Gestion",
    "name": "Bachelor Ressources Humaines",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "f9b2b1f0-7be9-515d-abdb-9f69eb0d65d2",
    "school_code": "EVRY BS",
    "cycle": "Mastères",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Management et Digitalisation des Processus Achat et Logistique(MD-AL)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "f9be6918-5239-5c52-8cc6-3520cc41f324",
    "school_code": "ESMAS",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "MASTER'S DEGREE",
    "name": "Master's Degree in Sports Industry Start-Ups and Development",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "f9d6e8ed-d1d8-5376-9a7d-97fca1c42e65",
    "school_code": "ESUV",
    "cycle": "English Track",
    "academic_level": null,
    "domain": "Bachelor's Degree",
    "name": "Bachelor's Degree in brand management and branding",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "f9df7691-1290-5ee8-9669-185a2e5bed82",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN PROJECT MANAGEMENT",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "fa4704bb-b61d-57d6-bc9a-5082c84a3230",
    "school_code": "MLV BS",
    "cycle": "Nos Mastère Spécialisé",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Spécialisé Marketing et Communication Digitale",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "fa653db8-5836-56a6-b167-6929adc28279",
    "school_code": "ESETH",
    "cycle": "BACHELOR",
    "academic_level": null,
    "domain": "GESTION-RESTAURATION",
    "name": "BACHELOR GESTION ET TRANSFORMATION DIGITALE DE L'HÔTELLERIE-RESTAURATION (HR)",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "fa836c08-0537-5239-84d8-fd66c620066d",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 3",
    "domain": "Finance",
    "name": "Bachelor Gestion des Opérations de Marchés Financiers",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "fab1af60-351a-505a-8e6c-d195bbb4e4d0",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "Bachelor's Degree in Organisational Management",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "fb37cb72-e410-57a6-8227-d9a78bc95722",
    "school_code": "LSB",
    "cycle": "Masteres Specialises",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Spécialisé intelligence artificielle et management (IAM)",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "fbaa89df-c706-5925-8a83-4720601040df",
    "school_code": "MLV BS",
    "cycle": "Nos Bachelors",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "BACHELOR CHEF DE PROJET INFORMATIQUE (CPI)",
    "source_file": "forms/mlv-bs.html"
  },
  {
    "id": "fbf815ce-bfe7-542e-a164-8c798d5daffc",
    "school_code": "ESMAS",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "STRATÉGIE ET MANAGEMENT INTERNATIONAL",
    "name": "Mastère Management des Structures de Sport et Stratégie Numérique (MS2)",
    "source_file": "forms/esmas.html"
  },
  {
    "id": "fc11d0a0-eff1-5c8c-b076-c930ba2befd9",
    "school_code": "ESUV",
    "cycle": "Bachelor",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Bachelor e-commerce",
    "source_file": "forms/esuv.html"
  },
  {
    "id": "fc1a2f56-7263-524b-95d5-7e21bf81052f",
    "school_code": "ISMOD",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "Mode-Innovation",
    "name": "Mastère Spécialisé Mode-Innovation",
    "source_file": "forms/ismod.html"
  },
  {
    "id": "fc2b34eb-8ef0-51cb-a400-7768627dbd34",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN INNOVATION COMMERCIAL MANAGEMENT",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "fc88020e-5677-5719-9c82-e4b2e2834374",
    "school_code": "ESIIA",
    "cycle": "Mastères Spécialisés",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Spécialisé Administration Systèmes, Réseaux et Cybersécurité",
    "source_file": "forms/esiia.html"
  },
  {
    "id": "fcade86d-6927-516d-bb71-6b7fbd2a1506",
    "school_code": "ESMEP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "COMMERCE - VENTE",
    "name": "MASTER EN MARKETING ET COMMUNICATION DIGITALE",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "fcc37bb6-0718-58f7-a3b6-6cb02cc7c3fb",
    "school_code": "ESMEP",
    "cycle": "Mastère 1",
    "academic_level": null,
    "domain": "MANAGEMENT ET GESTION",
    "name": "MASTÈRE MANAGEMENT ET STRATEGIE",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "fcdd4510-13fd-52f7-9b44-0056125b887e",
    "school_code": "LSB",
    "cycle": "Masteres",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastères architecture des systemes informatiques (ASI)",
    "source_file": "forms/lsb.html"
  },
  {
    "id": "fce652b3-6420-51c3-8d47-29ebc0df2604",
    "school_code": "CESCOM",
    "cycle": "NIVEAU BAC",
    "academic_level": null,
    "domain": "TITRES PROFESSIONNELS",
    "name": "TP MANAGER D'ÉQUIPE RELATION CLIENT A DISTANCE",
    "source_file": "forms/cescom.html"
  },
  {
    "id": "fd791e4c-d9b4-5c9d-9ed5-82411211683d",
    "school_code": "DCG FORMATIONS",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "Technologie et Data Innovation",
    "name": "Mastère Spécialisé en Ressources Humaines et Numérisation des Opérations",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "fdaadb18-325d-54d2-90d8-5eb20d9a7a7c",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "Bachelor's Degree in Healthcare Management and Transformation",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "fdd29eb0-5e70-5dcd-a038-00586a547420",
    "school_code": "ESMOSS",
    "cycle": "ENGLISH TRACK",
    "academic_level": null,
    "domain": "BACHELOR'S DEGREE",
    "name": "Bachelor's Degree in Quality, Health, Safety and Environment",
    "source_file": "forms/esmoss.html"
  },
  {
    "id": "fdddc3f2-8755-5eca-914b-18a2d54d480f",
    "school_code": "ILMIS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "Bachelor’s Degree in Corporate Social Responsibility",
    "source_file": "forms/ilmis.html"
  },
  {
    "id": "fde879f0-265c-5aec-b88b-9eac0d3286e5",
    "school_code": "ESJM",
    "cycle": "MBA",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "MASTER OF BUSINESS ADMINISTRATION (MBA)",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "fe2bb07c-a82c-5006-835b-4458b3d5c2c3",
    "school_code": "ESJM",
    "cycle": "MASTÈRES SPÉCIALISÉS",
    "academic_level": null,
    "domain": "Sciences Juridiques et Management",
    "name": "MASTÈRE SPÉCIALISÉ INNOVATION ET COMPLIANCE",
    "source_file": "forms/esjm.html"
  },
  {
    "id": "fe56d65e-73b1-5eca-8e03-7db02b62faab",
    "school_code": "DCG FORMATIONS",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "English Track",
    "name": "Diploma in Accounting and Management",
    "source_file": "forms/dcg-formations.html"
  },
  {
    "id": "fe8451c6-2506-53b8-a35f-4c83727cc4c5",
    "school_code": "EMSP",
    "cycle": "Mastère 2",
    "academic_level": null,
    "domain": "Stratégie et Management International",
    "name": "Mastère Management et Stratégie",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "ff33f795-4a2c-5675-9673-bd78182fafe5",
    "school_code": "ESETH",
    "cycle": "MASTÈRE",
    "academic_level": null,
    "domain": "MANAGEMENT-ENTREPRENARIAT",
    "name": "MASTÈRE ENTREPRENEURIAT ET BUSINESS DEVELOPMENT DIGITAL (EBD)",
    "source_file": "forms/eseth.html"
  },
  {
    "id": "ff68c487-1fe2-5372-a5c9-5982ffa84995",
    "school_code": "EVRY BS",
    "cycle": "Mastères",
    "academic_level": null,
    "domain": "Commerce - Vente",
    "name": "Mastère Responsable Communication Digitale Evenementielle et IA Impact(CDE)",
    "source_file": "forms/evry-bs.html"
  },
  {
    "id": "ff912a55-a06f-5598-bc9e-d33781564275",
    "school_code": "EMSP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 2",
    "domain": "Management et Gestion",
    "name": "Bachelor Gestion de Projets",
    "source_file": "forms/emsp.html"
  },
  {
    "id": "ffeb625a-cde0-5107-93c8-f422f3af3a38",
    "school_code": "ESMEP",
    "cycle": "Bachelor",
    "academic_level": "Bachelor 1",
    "domain": "English Track",
    "name": "BACHELOR'S DEGREE IN QUALITY, HYGIENE, SAFETY AND ENVIRONMENT (QHSE)",
    "source_file": "forms/esmep.html"
  },
  {
    "id": "fffe0506-5725-5124-88a8-1562cde919ce",
    "school_code": "ESMEP",
    "cycle": "Mastère spécialisé",
    "academic_level": null,
    "domain": "MANAGEMENT ET GESTION",
    "name": "MASTÈRE SPÉCIALISÉ EN MANAGEMENT ET DEVELOPPEMENT DURABLE RSE",
    "source_file": "forms/esmep.html"
  }
]$mbn_catalog$::jsonb) as p(id uuid,school_code text,cycle text,academic_level text,domain text,name text,source_file text))
insert into public.school_programs(id,school_code,name,cycle,academic_level,domain,is_active,review_status,source_file,source_version)
select s.id,s.school_code,s.name,s.cycle,s.academic_level,s.domain,false,'PENDING',s.source_file,'3bcb70adb298102a7aaac0ffd2a931db3b30be87f7d2399a75f13f6a401c2bbf' from source s
where not exists(select 1 from public.school_programs p where p.school_code=s.school_code and p.name=s.name and p.cycle is not distinct from s.cycle and p.academic_level is not distinct from s.academic_level and p.domain is not distinct from s.domain)
on conflict(id) do nothing;
