

CREATE TABLE netflix(
show_id varchar(6),
type varchar (10),
title varchar(150),
director varchar(208),
casts varchar(1000),
country varchar(150),
date_added varchar(50),
release_year int,
rating varchar(10),
duration varchar(15),
listed_in varchar(250),
description varchar(250)
);

SELECT * FROM netflix;

-- Business Problems
-- 1. Count the number of Movies vs TV Shows

SELECT Type, COUNT(type) AS Count
FROM netflix
GROUP BY type;

-- 2. Find the most common rating for movies and TV shows

WITH rating AS
(SELECT type, rating, COUNT(rating) AS Count,
RANK() OVER(PARTITION BY type ORDER BY Count(rating) DESC) AS rnk
FROM  netflix
GROUP BY type, rating)
SELECT Type, Rating, Count FROM rating
WHERE rnk = 1;

-- 3. List all movies released in a specific year (e.g., 2020)

SELECT Title
FROM netflix
WHERE type = "Movie"
	AND
	release_year = 2020;


-- 4. Find the top 5 countries with the most content on Netflix

SELECT Country, COUNT(show_id) AS Total_Content
FROM netflix
WHERE country != '0'
GROUP BY country
ORDER BY Total_Content DESC
LIMIT 5;

-- SELECT UNNEST(STRING_TO_ARRAY(country, ',')) AS new_country, COUNT(show_id) AS Total_Content
-- FROM netflix
-- GROUP BY 1
-- ORDER BY Total_Content DESC
-- LIMIT 5;

-- 5. Identify the longest movie

SELECT title, duration
FROM netflix
WHERE type = 'Movie'
 -- AND duration REGEXP '^[0-9]+ min$'
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC
LIMIT 5;


-- 6. Find content added in the last 5 years

SELECT title, RIGHT(date_added,4) AS year_added
FROM netflix
WHERE RIGHT(date_added,4) > year(current_date()) - 5;

SELECT title, STR_TO_DATE(date_added, '%M %d,%Y') AS formatted_date
FROM netflix
WHERE STR_TO_DATE(date_added, '%M %d,%Y') >= curdate() - INTERVAL 5 YEAR;


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT type, director, title
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';


-- 8. List all TV shows with more than 5 seasons

SELECT DISTINCT(title), 
  SUBSTRING_INDEX(SUBSTRING_INDEX(duration, ' ', 1), ' ', -1) AS seasonz
FROM netflix
WHERE type = "TV Show"
AND SUBSTRING_INDEX(SUBSTRING_INDEX(duration, ' ', 1), ' ', 1) > 5;


-- 9. Count the number of content items in each genre

SELECT listed_in, COUNT(show_id) AS Number
FROM netflix
GROUP BY 1
ORDER BY 2 DESC;


-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !

SELECT release_year, COUNT(show_id) AS Total
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 2 DESC;

SELECT
YEAR(STR_TO_DATE(date_added, '%M %d, %Y')) AS Year,
COUNT(show_id) AS Total,
ROUND(100 * COUNT(show_id) / (select COUNT(*) FROM netflix WHERE country = 'India'),2) AS Average
FROM netflix
WHERE country = 'India'
GROUP BY 1
ORDER BY 3 DESC;


-- 11. List all movies that are documentaries

SELECT title
FROM netflix
WHERE type = 'Movie'
AND listed_in LIKE '%Documentaries%';


-- 12. Find all content without a director

SELECT title, director
FROM netflix
WHERE director IS NULL;


-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

ALTER TABLE netflix
MODIFY COLUMN release_year date;

SELECT title, release_year
FROM netflix
WHERE casts LIKE "%Salman Khan%"
AND release_year > year(current_date()) - 10;


-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT casts, title
FROM netflix
WHERE country = 'India';


/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/

WITH Category AS
(SELECT title,
CASE WHEN description LIKE "%kill%" OR description LIKE "%Violence%" THEN "Bad"
ELSE "Good"
END AS Content
FROM netflix)
SELECT Content, COUNT(content) AS Count
FROM Category
GROUP BY Content;




-- End of reports

