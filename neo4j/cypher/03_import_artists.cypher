// Import Spotify artists

LOAD CSV WITH HEADERS
FROM 'file:///spotify_artists.csv' AS row

CALL (row) {
    MERGE (a:Artist {id: row.id})
    SET
        a.name = row.name,
        a.popularity = toInteger(row.artist_popularity),
        a.followers = toInteger(row.followers)
}
IN TRANSACTIONS OF 5000 ROWS;