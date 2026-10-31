DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
show_id     VARCHAR (5),
type	    VARCHAR(10),
title	    VARCHAR(250),
director    VARCHAR(550),
casts       VARCHAR(1050),
country	    VARCHAR(550),
date_added	VARCHAR(55),
release_year INT,
rating		VARCHAR(15),
durationN 	VARCHAR (15),
listed_in	VARCHAR (250),
description VARCHAR (550)
);
ALTER TABLE netflix
RENAME COLUMN durationN to duration;

select * from netflix

-- 15 Business Problems & Solutions

1.--Count the number of Movies vs TV Shows
 SELECT 
 type,
 COUNT(*) as total_content
 FROM netflix
 GROUP BY type
2.--Find the most common rating for movies and TV shows
WITH rating_counts AS (
    SELECT
        type,
        rating,
        COUNT(*) AS total,
        RANK() OVER (PARTITION BY type ORDER BY COUNT(*) DESC) AS rnk
    FROM netflix
    WHERE rating IS NOT NULL
    GROUP BY type, rating
)
SELECT type, rating, total
FROM rating_counts
WHERE rnk = 1;

3.--List all movies released in a specific year (e.g., 2020)
SELECT title, director, country, rating
FROM netflix
WHERE type = 'Movie'
AND release_year = 2020
ORDER BY title;

 
4.--Find the top 5 countries with the most content on Netflix

SELECT country, 
COUNT(*) AS total_content
FROM netflix
WHERE country IS NOT NULL
GROUP BY country
ORDER BY total_content DESC
LIMIT 5;

5.--Identify the longest movie
SELECT title, type, duration
FROM netflix
WHERE type = 'Movie'
AND duration IS NOT NULL
ORDER BY CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) DESC
LIMIT 1;

6.--Find content added in the last 5 years

SELECT title, type, date_added
FROM netflix
WHERE date_added IS NOT NULL
  AND TO_DATE(TRIM(date_added), 'Month DD, YYYY') >=
      (SELECT MAX(TO_DATE(TRIM(date_added), 'Month DD, YYYY')) - INTERVAL '5 years'
       FROM netflix
       WHERE date_added IS NOT NULL)
ORDER BY TO_DATE(TRIM(date_added), 'Month DD, YYYY') DESC;

--OR

SELECT title, type, date_added
FROM netflix
WHERE date_added LIKE '%2017'
   OR date_added LIKE '%2018'
   OR date_added LIKE '%2019'
   OR date_added LIKE '%2020'
   OR date_added LIKE '%2021';


7.--Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT title, type, release_year, director
FROM netflix
WHERE director = 'Rajiv Chilaka'
ORDER BY release_year;


8.--List all TV shows with more than 5 seasons

SELECT type, duration
FROM netflix
WHERE type = 'TV Show'
AND CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) > 5
ORDER BY CAST(SPLIT_PART(duration, ' ', 1) AS INTEGER) DESC;



9.--Count the number of content items in each genre
SELECT listed_in,
COUNT(*) AS genre
FROM netflix
GROUP BY listed_in
ORDER BY genre DESC;

/*
10.Find each year and the average numbers of content release in India on netflix. 
Return top 5 year with highest avg content release.
*/
SELECT RIGHT(date_added, 4) AS year,
       COUNT(*) AS total_content
FROM netflix
WHERE country LIKE '%India%'
  AND date_added IS NOT NULL
GROUP BY RIGHT(date_added, 4)
ORDER BY total_content DESC
LIMIT 5;

11. List all movies that are documentaries

SELECT type, title, listed_in
FROM netflix
WHERE listed_in LIKE '%Documentaries%'
AND type = 'Movie'

12.--Find all content without a director

SELECT type, title, director
FROM netflix
WHERE director IS NULL

13.--Find how many movies actor 'Salman Khan' appeared in last 10 years

SELECT COUNT(*) AS salman_khan_movies
FROM netflix
WHERE type = 'Movie'
AND casts LIKE '%Salman Khan%'
AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;


14.--Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT TRIM(actor) AS actor, COUNT(*) AS total_movies
FROM (
    SELECT UNNEST(STRING_TO_ARRAY("casts", ',')) AS actor
    FROM netflix
    WHERE type = 'Movie'
      AND country LIKE '%India%'
) AS actor_list
GROUP BY TRIM(actor)
ORDER BY total_movies DESC
LIMIT 10;

/*
15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/

SELECT category, COUNT(*) AS total_items
FROM (
    SELECT
        CASE
            WHEN description ILIKE '%kill%'
              OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS labelled
GROUP BY category;


-------