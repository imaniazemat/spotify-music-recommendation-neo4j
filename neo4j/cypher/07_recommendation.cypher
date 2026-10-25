// --------------------------------------------------
// Create test user and liked track
// --------------------------------------------------

MERGE (u:User {name: 'Reiaz'});

MATCH (u:User {name: 'Reiaz'})
MATCH (t:Track)-[:PERFORMED_BY]->(:Artist)-[:HAS_GENRE]->(:Genre)

WITH u, t
ORDER BY t.popularity DESC
LIMIT 1

MERGE (u)-[:LIKES]->(t);


// --------------------------------------------------
// Hybrid recommendation query
// 50% Audio similarity
// 40% Genre similarity
// 10% Popularity
// --------------------------------------------------

MATCH (u:User {name:'Reiaz'})-[:LIKES]->(liked:Track)

MATCH (liked)-[:PERFORMED_BY]->(:Artist)-[:HAS_GENRE]->(lg:Genre)

WITH u, liked, collect(DISTINCT lg.name) AS likedGenres

MATCH (candidate:Track)-[:PERFORMED_BY]->(:Artist)-[:HAS_GENRE]->(cg:Genre)

WHERE candidate <> liked
  AND NOT (u)-[:LIKES]->(candidate)

WITH u, liked, candidate, likedGenres,
     collect(DISTINCT cg.name) AS candidateGenres

WITH liked, candidate, likedGenres, candidateGenres,
     [g IN candidateGenres WHERE g IN likedGenres] AS sharedGenres

WHERE size(sharedGenres) > 0

WITH liked, candidate, sharedGenres,

     toFloat(size(sharedGenres)) /
     toFloat(size(likedGenres)) AS genre_similarity,

     (
        (1 - abs(candidate.energy - liked.energy)) +
        (1 - abs(candidate.danceability - liked.danceability)) +
        (1 - abs(candidate.valence - liked.valence)) +
        (1 - abs(candidate.acousticness - liked.acousticness)) +
        (1 - abs(candidate.speechiness - liked.speechiness)) +
        (1 - abs(candidate.tempo - liked.tempo) / 250.0)
     ) / 6.0 AS audio_similarity

WITH candidate,
     sharedGenres,
     genre_similarity,
     audio_similarity,
     candidate.popularity / 100.0 AS popularity_score,

     (
        genre_similarity * 0.40 +
        audio_similarity * 0.50 +
        (candidate.popularity / 100.0) * 0.10
     ) AS recommendation_score

RETURN
    candidate.name AS recommended_track,
    sharedGenres,
    round(genre_similarity, 3) AS genre_similarity,
    round(audio_similarity, 3) AS audio_similarity,
    candidate.popularity AS popularity,
    round(recommendation_score, 3) AS score

ORDER BY score DESC
LIMIT 3;