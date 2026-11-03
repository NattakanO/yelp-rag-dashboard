--- Questions
--- 1	Which categories have the most restaurants? 
SELECT TRIM(category) AS category,
       COUNT(*) AS num_restaurants,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM business_restaurants), 1) AS pct_of_restaurants
FROM (
    SELECT UNNEST(string_split(categories, ',')) AS category
    FROM business_restaurants
)
WHERE TRIM(category) NOT IN ('Restaurants', 'Food', 'Nightlife', 'Bars', 'Event Planning & Services')
GROUP BY category
ORDER BY num_restaurants DESC
LIMIT 20


--- 2	What are the top 5 cuisines in each city, as a share of its restaurants?

WITH categories AS (
    SELECT city, state, TRIM(category) AS category
    FROM (
        SELECT city, state, UNNEST(string_split(categories, ',')) AS category
        FROM business_restaurants
    )
    WHERE TRIM(category) NOT IN ('Restaurants', 'Food', 'Nightlife', 'Bars', 'Event Planning & Services')
),
restaurant_per_city AS (
    SELECT city, state, COUNT(*) AS city_restaurants
    FROM business_restaurants
    GROUP BY city, state
    HAVING COUNT(*) >= 500
)
SELECT c.city, c.state, c.category,
       COUNT(*) AS restaurants,
       ROUND(100.0 * COUNT(*) / MAX(t.city_restaurants), 1) AS pct_of_city
FROM categories c
JOIN restaurant_per_city t USING (city, state)
GROUP BY c.city, c.state, c.category
QUALIFY ROW_NUMBER() OVER (PARTITION BY c.city, c.state ORDER BY COUNT(*) DESC) <= 5
ORDER BY MAX(t.city_restaurants) DESC, c.city, restaurants DESC


--- 3	Which categories have the highest average stars (at least 100 restaurants)?	
WITH categories AS (
    SELECT TRIM(category) AS category, stars
    FROM (
        SELECT UNNEST(string_split(categories, ',')) AS category, stars
        FROM business_restaurants
    )
    WHERE TRIM(category) NOT IN ('Restaurants', 'Food', 'Nightlife', 'Bars', 'Event Planning & Services')
)
SELECT  category,
        COUNT(*) AS restaurants,
        ROUND(AVG(stars),2) as avg_stars
FROM categories 
GROUP BY category
HAVING COUNT(*) >= 100
ORDER BY avg_stars DESC, restaurants DESC

--- 4	Which attributes fields are well filled, and do restaurants with them (outdoor seating, delivery, good for groups) rate higher?
--- 5	Does price range relate to stars, and which cuisines are the most expensive?
--- 6	Are chains rated lower than independents?	
--- 7	Which restaurants have the most reviews?

--- 8	Do open and closed restaurants differ in average stars, and what share is closed in each star band?	
--- 9	How long do restaurants last (first to last review), open vs closed?	

--- 10	How do reviews per year change over time?	
--- 11	Do average stars change by year?
--- 12	Do heavy reviewers rate differently from occasional ones?	

--- 13	Do longer reviews have lower stars?
--- 14	Which words are most common in 1 to 2 star reviews compared with 4 to 5 star reviews? 