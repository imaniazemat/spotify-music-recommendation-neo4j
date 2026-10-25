// Import Spotify tracks

LOAD CSV WITH HEADERS
FROM 'file:///spotify_tracks_neo4j.csv' AS row

CALL (row) {
    MERGE (t:Track {id: row.id})
    SET
        t.name = row.name,
        t.album_id = row.album_id,
        t.popularity = toInteger(toFloat(row.popularity)),
        t.acousticness = toFloat(row.acousticness),
        t.danceability = toFloat(row.danceability),
        t.duration_ms = toInteger(toFloat(row.duration_ms)),
        t.energy = toFloat(row.energy),
        t.instrumentalness = toFloat(row.instrumentalness),
        t.key = toInteger(toFloat(row.key)),
        t.liveness = toFloat(row.liveness),
        t.loudness = toFloat(row.loudness),
        t.mode = toInteger(toFloat(row.mode)),
        t.speechiness = toFloat(row.speechiness),
        t.tempo = toFloat(row.tempo),
        t.time_signature = toInteger(toFloat(row.time_signature)),
        t.valence = toFloat(row.valence),
        t.playlist = row.playlist
}
IN TRANSACTIONS OF 5000 ROWS;