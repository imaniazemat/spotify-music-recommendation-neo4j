// Create relationships between Tracks, Artists and Albums

// --------------------------------------------------
// Track -> Artist
// --------------------------------------------------

LOAD CSV WITH HEADERS
FROM 'file:///spotify_tracks_neo4j.csv' AS row

WITH row,
     [x IN split(
         replace(
           replace(
             replace(row.artists_id, '[', ''),
           ']', ''),
         "'", ''),
       ',')
      | trim(x)] AS artist_ids

UNWIND artist_ids AS artist_id

WITH row, artist_id
WHERE artist_id <> ''

CALL (row, artist_id) {
    MATCH (t:Track {id: row.id})
    MATCH (a:Artist {id: artist_id})
    MERGE (t)-[:PERFORMED_BY]->(a)
}
IN TRANSACTIONS OF 5000 ROWS;


// --------------------------------------------------
// Track -> Album
// --------------------------------------------------

LOAD CSV WITH HEADERS
FROM 'file:///spotify_tracks_neo4j.csv' AS row

CALL (row) {
    MATCH (t:Track {id: row.id})
    MATCH (a:Album {id: row.album_id})
    MERGE (t)-[:IN_ALBUM]->(a)
}
IN TRANSACTIONS OF 5000 ROWS;