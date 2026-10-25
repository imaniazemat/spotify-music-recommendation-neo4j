# Spotify Music Recommendation with Neo4j

## Présentation du projet

Ce projet a été réalisé dans le cadre du **Projet de session** du cours de traitement distribué des données.

L’objectif est d’analyser un ensemble de données Spotify, de modéliser les données dans une base orientée graphe avec **Neo4j**, de construire un système de recommandation musicale et de produire plusieurs visualisations permettant de mieux comprendre les caractéristiques des pistes, artistes, albums et genres.

Le jeu de données provient de Spotify via la bibliothèque Python **Spotipy** et a été obtenu à partir de Kaggle.

---

## Technologies utilisées

- Python
- PySpark
- Databricks
- Neo4j Community Edition 5.26
- Docker
- Cypher
- Pandas
- Matplotlib
- Git
- GitHub

---

## Sources de données

Le projet utilise trois fichiers CSV principaux :

### spotify_tracks.csv

Contient les pistes Spotify et leurs caractéristiques audio.

- 101 939 pistes
- 32 colonnes

Principales variables utilisées :

- id
- name
- album_id
- artists_id
- popularity
- acousticness
- danceability
- duration_ms
- energy
- instrumentalness
- liveness
- loudness
- speechiness
- tempo
- valence
- playlist

### spotify_artists.csv

Contient les informations relatives aux artistes.

- 56 129 enregistrements
- 9 colonnes

Principales variables :

- id
- name
- artist_popularity
- followers
- genres
- track_id

### spotify_albums.csv

Contient les informations relatives aux albums.

- 75 511 enregistrements
- 16 colonnes

Principales variables :

- id
- name
- album_type
- release_date
- total_tracks

---

## 1. Analyse et qualité des données

L’analyse initiale a été réalisée dans **Databricks avec PySpark**.

Le notebook principal est :

```text
notebooks/01_data_profiling.ipynb
```

Les vérifications effectuées comprennent :

- nombre de lignes et de colonnes ;
- structure et types des colonnes ;
- valeurs NULL ;
- chaînes vides ;
- identifiants dupliqués ;
- lignes dupliquées ;
- analyse des caractéristiques audio ;
- détection de valeurs atypiques.

### Résultats principaux

Pour `spotify_tracks.csv` :

- 101 939 pistes ;
- aucune valeur NULL détectée ;
- aucun identifiant de piste dupliqué ;
- aucune ligne entièrement dupliquée ;
- 367 pistes ont un tempo égal à 0 ;
- 391 pistes ont une durée inférieure à 30 secondes ;
- 672 pistes ont une durée supérieure à 20 minutes.

Certaines pistes très longues correspondent à des livres audio, conférences ou sons d’ambiance.

Pour `spotify_artists.csv` :

- 56 129 enregistrements ;
- aucune valeur NULL ;
- aucun identifiant dupliqué ;
- 23 450 artistes n’ont aucun genre défini (`genres = []`).

Pour `spotify_albums.csv` :

- 75 511 enregistrements ;
- aucune valeur NULL ;
- aucun identifiant dupliqué.

Répartition des types d’albums :

- single : 39 555
- album : 32 636
- compilation : 3 320

---

## 2. Modélisation Neo4j

La base orientée graphe contient les types de nœuds suivants :

```text
Track
Artist
Album
Genre
User
```

Les principales relations sont :

```text
(User)-[:LIKES]->(Track)

(Track)-[:PERFORMED_BY]->(Artist)

(Track)-[:IN_ALBUM]->(Album)

(Artist)-[:HAS_GENRE]->(Genre)
```

Cette modélisation permet de représenter directement les relations entre les différentes entités musicales.

---

## Contraintes Neo4j

Des contraintes d’unicité ont été créées pour éviter les doublons :

```text
Track.id
Artist.id
Album.id
Genre.name
User.name
```

Le fichier correspondant est :

```text
neo4j/cypher/01_constraints.cypher
```

---

## Import des données dans Neo4j

Les requêtes Cypher sont disponibles dans :

```text
neo4j/cypher/
```

Organisation :

```text
01_constraints.cypher
02_import_tracks.cypher
03_import_artists.cypher
04_import_albums.cypher
05_relationships.cypher
06_genres.cypher
07_recommendation.cypher
```

### Gestion du fichier des pistes

Le fichier original `spotify_tracks.csv` contient une colonne `lyrics` avec du texte multiligne.

Cette structure provoquait une erreur avec `LOAD CSV` dans Neo4j.

Une version technique destinée à l’import Neo4j a donc été générée :

```text
spotify_tracks_neo4j.csv
```

Cette version conserve uniquement les colonnes nécessaires au modèle de recommandation et exclut notamment la