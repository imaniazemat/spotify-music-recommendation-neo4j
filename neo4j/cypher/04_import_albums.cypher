// Import Spotify albums

LOAD CSV WITH HEADERS
FROM 'file:///spotify_albums.csv' AS row

CALL (row) {
    MERGE (a:Album {id: row.id})
    SET
        a.name = row.name,
        a.album_type = row.album_type,
        a.release_date = row.release_date,
        a.release_date_precision = row.release_date_precision,
        a.total_tracks = toInteger(row.total_tracks)
}
IN TRANSACTIONS OF 5000 ROWS;