// Create Genre nodes and Artist -> Genre relationships

LOAD CSV WITH HEADERS
FROM 'file:///spotify_artists.csv' AS row

WITH row,
     [x IN split(
         replace(
           replace(
             replace(row.genres, '[', ''),
           ']', ''),
         "'", ''),
       ',')
      | trim(x)] AS genres

UNWIND genres AS genre_name

WITH row, genre_name
WHERE genre_name <> ''

CALL (row, genre_name) {
    MATCH (a:Artist {id: row.id})

    MERGE (g:Genre {name: genre_name})

    MERGE (a)-[:HAS_GENRE]->(g)
}
IN TRANSACTIONS OF 5000 ROWS;