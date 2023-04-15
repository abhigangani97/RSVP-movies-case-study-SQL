USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/



-- Segment 1:


-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:
SELECT 
    table_name, table_rows
FROM
    information_schema.tables
WHERE
    table_schema = 'imdb'; 



-- Q2. Which columns in the movie table have null values?
-- Type your code below:


SELECT 
    SUM(CASE
        WHEN id IS NULL THEN 1
        ELSE 0
    END) AS null_ids,
    SUM(CASE
        WHEN title IS NULL THEN 1
        ELSE 0
    END) AS null_titles,
    SUM(CASE
        WHEN year IS NULL THEN 1
        ELSE 0
    END) AS null_years,
    SUM(CASE
        WHEN date_published IS NULL THEN 1
        ELSE 0
    END) AS null_dates,
    SUM(CASE
        WHEN duration IS NULL THEN 1
        ELSE 0
    END) AS null_durations,
    SUM(CASE
        WHEN country IS NULL THEN 1
        ELSE 0
    END) AS null_countries,
    SUM(CASE
        WHEN worlwide_gross_income IS NULL THEN 1
        ELSE 0
    END) AS null_incomes,
    SUM(CASE
        WHEN languages IS NULL THEN 1
        ELSE 0
    END) AS null_languages,
    SUM(CASE
        WHEN production_company IS NULL THEN 1
        ELSE 0
    END) AS null_productions
FROM
    movie;

-- duration, worlwide_gross_income, languages and production_company have null values in them

-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT 
    Year, COUNT(distinct id) AS number_of_movies
FROM
    movie
GROUP BY YEAR;

-- Count of movies shows a downward trend from 2017-2019

SELECT 
    MONTH(date_published) AS month_num,
    COUNT(distinct id) AS number_of_movies
FROM
    movie
GROUP BY MONTH(date_published)
ORDER BY month_num;


-- in March month highest number of movies were released.


/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

SELECT 
    COUNT(DISTINCT id) AS number_of_movies, year
FROM
    movie
WHERE
    (country LIKE '%INDIA%'
        OR country LIKE '%USA%')
        AND year = 2019; 
-- total 1059 movies were released in the year 2019 cumulative by India and America

/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:

SELECT DISTINCT
    genre
FROM
    genre;



/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

SELECT 
    genre, COUNT(M.id) AS number_of_movies
FROM
    movie AS M
        INNER JOIN
    genre AS G
WHERE
    G.movie_id = M.id
GROUP BY genre
ORDER BY number_of_movies DESC
LIMIT 1;

-- Drama among different genre is having highest count of movies overall.

/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:

WITH movie_with_one_genre AS(
SELECT movie_id
FROM genre
GROUP BY movie_id
HAVING count(DISTINCT genre) = 1)
SELECT count(*) FROM movie_with_one_genre;

-- There are 3289 movies which just belongs to one Genre

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)

/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
SELECT 
    GENRE, ROUND(AVG(duration), 2) AS avg_duration
FROM
    movie m
        INNER JOIN
    genre g ON m.id = g.movie_id
GROUP BY genre
ORDER BY avg_duration DESC;




/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
WITH thriller_rank AS
(
           SELECT     genre,
                      Count(m.id)                            AS movie_count,
                      Rank() OVER(ORDER BY Count(m.id) DESC) AS genre_rank
           FROM       movie                                  AS m
           INNER JOIN genre                                  AS g
           where      g.movie_id = m.id
           GROUP BY   genre)
SELECT genre,
       movie_count,
       genre_rank
FROM   thriller_rank
WHERE  genre = 'Thriller';



/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/




-- Segment 2:




-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:

SELECT Min(avg_rating)    AS MIN_AVG_RATING,
       Max(avg_rating)    AS MAX_AVG_RATING,
       Min(total_votes)   AS MIN_TOTAL_VOTES,
       Max(total_votes)   AS MAX_TOTAL_VOTES,
       Min(median_rating) AS MIN_MEDIAN_RATING,
       Max(median_rating) AS MAX_MEDIAN_RATING
FROM   ratings; 



/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too
WITH movie_rank
     AS (SELECT title,
                avg_rating,
                Rank ()
                  OVER(
                    ORDER BY avg_rating DESC) AS movie_rank
         FROM   movie m
                INNER JOIN ratings r
                        ON m.id = r.movie_id)
SELECT title,
       avg_rating,
       movie_rank
FROM   movie_rank
WHERE  movie_rank <= 10; 


/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have

SELECT 
    median_rating, COUNT(DISTINCT movie_id) AS movie_count
FROM
    ratings
GROUP BY median_rating
ORDER BY movie_count DESC;




/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:
WITH production_company_rank
     AS (SELECT production_company,
                Count(DISTINCT movie_id)                    AS movie_count,
                Rank ()
                  OVER(
                    ORDER BY Count(DISTINCT movie_id) DESC) AS prod_company_rank
         FROM   movie m
                INNER JOIN ratings r
                        ON m.id = r.movie_id
         WHERE  avg_rating >= 8
                AND production_company IS NOT NULL
         GROUP  BY production_company)
SELECT production_company,
       movie_count,
       prod_company_rank
FROM   production_company_rank
WHERE  prod_company_rank = 1; 

-- Dream Warrior Pictures and National Theatre Live are the best production houses with 3 hit movies.

-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both


-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
SELECT 
    genre, COUNT(g.movie_id) AS movie_count
FROM
    genre g
        INNER JOIN
    movie m ON g.movie_id = m.id
        INNER JOIN
    ratings r ON r.movie_id = m.id
WHERE
    MONTH(m.date_published) = 3
        AND m.year = 2017
        AND r.total_votes >= 1000
        AND country LIKE '%USA%'
GROUP BY genre
ORDER BY movie_count DESC;



-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

SELECT title,
       avg_rating,
       genre
FROM   movie AS M
       INNER JOIN genre AS G
               ON G.movie_id = M.id
       INNER JOIN ratings AS R
               ON R.movie_id = M.id
WHERE  avg_rating > 8
       AND title LIKE 'THE%'
       ORDER BY avg_rating DESC;



-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:

SELECT 
    median_rating, COUNT(*) as 'No. Of movies'
FROM
    movie m
        INNER JOIN
    ratings r ON r.movie_id = m.id
WHERE
    date_published BETWEEN '2018-04-01' AND '2019-04-01'
        AND median_rating = 8
GROUP BY median_rating;


-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:


 SELECT 
    IF((SELECT 
                SUM(total_votes) AS total_votes
            FROM
                movie m
                    INNER JOIN
                ratings r ON m.id = r.movie_id
            WHERE
                languages LIKE '%German') > (SELECT 
                SUM(total_votes) AS total_votes
            FROM
                movie m
                    INNER JOIN
                ratings r ON m.id = r.movie_id
            WHERE
                languages LIKE '%italian'),
        'Yes',
        'No');
 
 -- German movies gets more votes as compared to italian movies


-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

SELECT 
    SUM(CASE
        WHEN id IS NULL THEN 1
        ELSE 0
    END) AS null_ids,
    SUM(CASE
        WHEN name IS NULL THEN 1
        ELSE 0
    END) AS null_names,
    SUM(CASE
        WHEN height IS NULL THEN 1
        ELSE 0
    END) AS null_heights,
    SUM(CASE
        WHEN date_of_birth IS NULL THEN 1
        ELSE 0
    END) AS null_birth_dates,
    SUM(CASE
        WHEN known_for_movies IS NULL THEN 1
        ELSE 0
    END) AS null_known_for_movies
FROM
    names;


/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
with top_3_genres as (
  select 
    genre, 
    count(m.id) as movie_count,
    rank() over(order by count(m.id) desc) as Genre_rank
  from 
    movie m 
    inner join genre g on m.id = g.movie_id 
    inner join ratings r using (movie_id) 
  where 
    avg_rating > 8 
  group by 
    genre 
  limit 
    3
) ,director_rank as(
select 
  n.name as director_name, 
  count(d.movie_id) as movie_count,
  rank()over(order by count(d.movie_id) desc ) as rank_director
from 
  director_mapping d 
  inner join names n on n.id = d.name_id 
  inner join ratings r using (movie_id) 
  inner join genre g using (movie_id) 
  inner join top_3_genres t using (genre) 
where 
  avg_rating > 8 
group by 
 n.name
order by movie_count desc)
select director_name,movie_count,rank_director
from director_rank
where rank_director <= 3;

-- James Mangold is the best directors if bifurcated on basis of top 3 genres.
-- Soubin Shahir, Hoe Russo and Anthony Russo all shares 2nd place.

/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT 
    name AS actor_name, COUNT(movie_id) AS movie_count
FROM
    role_mapping rm
        INNER JOIN
    movie m ON rm.movie_id = m.id
        INNER JOIN
    ratings r USING (movie_id)
        INNER JOIN
    names ON rm.name_id = names.id
WHERE
    r.median_rating >= 8
GROUP BY actor_name
ORDER BY movie_count DESC
LIMIT 2;

-- Mammootty and Mohanlal are the best 2 actors on the basis of movie count and median rating higher than or equal to 8.

/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:


WITH ranking AS(
  SELECT 
    production_company, 
    sum(total_votes) AS vote_count, 
    RANK() OVER(
      ORDER BY 
        SUM(total_votes) DESC
    ) AS prod_comp_rank 
  FROM 
    movie AS m 
    INNER JOIN ratings AS r ON r.movie_id = m.id 
  GROUP BY 
    production_company
) 
SELECT 
  production_company, 
  vote_count, 
  prod_comp_rank 
FROM 
  ranking 
WHERE 
  prod_comp_rank <= 3;

-- Marvel Studios, Twentieth Century Fox and Warner Bros are top 3 production houses on the basis of total votes recieved 

/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
with actor_rank as (
  select 
    n.name as actor_name, 
    count(total_votes) as total_votes, 
    count(movie_id) as movie_count, 
    round(
      sum(avg_rating * total_votes)/ sum(total_votes), 
      2
    ) as actor_average_rating 
  from 
    role_mapping rm 
    inner join names n on rm.name_id = n.id 
    inner join ratings r using (movie_id) 
    inner join movie m on m.id = rm.movie_id 
  where 
    category = 'Actor' 
    and country like '%INDIA%'  
  group by 
    name 
  having 
    count(movie_id) >= 5
) 
select 
  actor_name, 
  total_votes, 
  movie_count, 
  actor_average_rating, 
  rank() over(
    order by 
      actor_average_rating desc
  ) as actor_rank 
from 
  actor_rank;




-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

with actress_rank as (
  select 
    n.name as actress_name, 
    count(total_votes) as total_votes, 
    count(r.movie_id) as movie_count, 
    round(
      sum(avg_rating * total_votes)/ sum(total_votes), 
      2
    ) as actor_average_rating 
  from 
    role_mapping rm 
    inner join names n on rm.name_id = n.id 
    inner join ratings r using (movie_id) 
    inner join movie m on m.id = rm.movie_id 
  where 
    category = 'Actress' 
    and country like '%INDIA%' and languages like '%HINDI%'
  group by 
    name 
  having 
    count(movie_id) >= 3
) 
select 
  actress_name, 
  total_votes, 
  movie_count, 
  actor_average_rating, 
  rank() over(
    order by 
      actor_average_rating desc
  ) as actor_rank 
from 
  actress_rank
order by actor_rank 
limit 5  ;




/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:
with thriller_rating as 
(
select title, avg_rating
from movie m 
inner join ratings r
on m.id = r.movie_id
inner join genre g
on m.id = g.movie_id
where genre = 'thriller')
select *,
case when avg_rating > 8 then 'Superhit movies'
when avg_rating between 7 and 8 then 'Hit movies'
when avg_rating between 5 and 7 then 'One-time-watch movies'
else 'Flop movies'
end as avg_rating_category
from thriller_rating ;



/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

select genre,
round(avg(duration),2) as avg_duration,
sum(round(avg(duration),2)) over(order by genre ROWS UNBOUNDED PRECEDING) as running_total_duration,
avg(round(avg(duration),2)) over(order by genre ROWS 10 PRECEDING ) as moving_avg_duration
FROM movie AS m 
INNER JOIN genre AS g 
ON m.id= g.movie_id
GROUP BY genre
ORDER BY genre;






-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies
with genre_rank as (
  select 
    genre, 
    count(m.id), 
    rank() over(
      order by 
        count(m.id) desc
    ) as genre_rank 
  from 
    genre g 
    inner join movie m on m.id = g.movie_id 
  group by 
    genre 
  limit 
    3
), 
movie_rank as (
  select 
    genre, 
    year, 
    title as movie_name, 
    worlwide_gross_income, 
    dense_rank() over(
      partition by year 
      order by 
        worlwide_gross_income desc
    ) as movie_rank 
  from 
    movie m 
    inner join genre g on m.id = g.movie_id 
  where 
    genre in (
      select 
        genre 
      from 
        genre_rank
    )
) 
select 
  * 
from 
  movie_rank 
where 
  movie_rank <= 5;





-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:
with prod_comp_rank as (
  select 
    production_company, 
    count(distinct movie_id) as movie_count, 
    rank() over(
      order by 
        count(distinct movie_id) desc
    ) as prod_comp_rank 
  from 
    ratings r 
    inner join movie m on m.id = r.movie_id 
  where 
    median_rating >= 8 
    and production_company is not null 
    AND Position(',' IN languages) > 0 
  group by 
    production_company 
  order by 
    count(movie_id) desc
) 
select 
  * 
from 
  prod_comp_rank 
where 
  prod_comp_rank <= 2;

-- Star cinema and Twentieth Century Fox are the top 2 production houses that have produced the highest number of hits among multilingual movies.

-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
with top_actress as (
  select 
    name as actress_name, 
    sum(total_votes), 
    count(movie_id) as movie_count, 
    Round(
      Sum(avg_rating * total_votes)/ Sum(total_votes), 
      2
    ) AS actress_avg_rating, 
    rank() over(
      order by 
        count(movie_id) desc
    ) as actress_rank 
  from 
    role_mapping rm 
    inner join names n on rm.name_id = n.id 
    inner join ratings r using (movie_id) 
    inner join genre using (movie_id) 
  where 
    avg_rating >= 8 
    and genre = 'drama' 
    and category = 'actress' 
  group by 
    actress_name
) 
select 
  * 
from 
  top_actress 
where 
  actress_rank <= 3;



/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:
with director_details as (
select name_id, name, movie_id, date_published,
lead(date_published,1)over(partition by name_id order by date_published, movie_id) as next_movie_date
from director_mapping d
inner join names n
on d.name_id = n.id
inner join movie m
on m.id = d.movie_id),
date_difference AS
(
	 SELECT *, DATEDIFF(next_movie_date, date_published) AS diff
	 FROM director_details
 ),
 avg_inter_days AS
 (
	 SELECT name_id, AVG(diff) AS avg_inter_movie_days
	 FROM date_difference
	 GROUP BY name_id
 ),
 final_result AS
 (
	 SELECT d.name_id AS director_id,
		 name AS director_name,
		 COUNT(d.movie_id) AS number_of_movies,
		 ROUND(avg_inter_movie_days) AS avg_inter_movie_days,
		 ROUND(AVG(avg_rating),2) AS avg_rating,
		 SUM(total_votes) AS total_votes,
		 MIN(avg_rating) AS min_rating,
		 MAX(avg_rating) AS max_rating,
		 SUM(duration) AS total_duration,
		 ROW_NUMBER() OVER(ORDER BY COUNT(d.movie_id) DESC) AS director_row_rank
	 FROM
		 names AS n 
         JOIN director_mapping AS d 
         ON n.id=d.name_id
		 JOIN ratings AS r 
         ON d.movie_id=r.movie_id
		 JOIN movie AS m 
         ON m.id=r.movie_id
		 JOIN avg_inter_days AS a 
         ON a.name_id=d.name_id
	 GROUP BY director_id
 )
  SELECT director_id, director_name,number_of_movies,avg_inter_movie_days,avg_rating,total_votes, min_rating, max_rating, total_duration
 FROM final_result
where director_row_rank <= 9;