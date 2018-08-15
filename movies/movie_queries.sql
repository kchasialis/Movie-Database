/*Q1 - Find the titles of the movies that an actor with surname "Allen" is playing and movie's genre is "Comedy" */

select distinct m.title
from movie m,actor a,genre g,movie_has_genre mg,role r
where m.movie_id = mg.movie_id and r.actor_id = a.actor_id and r.movie_id = m.movie_id and r.movie_id = mg.movie_id and mg.genre_id = g.genre_id
  and a.last_name = "Allen" and g.genre_name = "Comedy";

/*Q2 - Find the surnames of the directors and the titles of the movies that they directed,that an actor with surname "Allen"
is playing on condition that this director has directed at least 2 different genres  */

SELECT d.last_name,m.title
FROM director d,genre g,actor a,movie m,movie_has_director md,role r,movie_has_genre mg
WHERE md.director_id = d.director_id and m.movie_id = md.movie_id and r.movie_id = m.movie_id and r.actor_id = a.actor_id and a.last_name = "Allen"
and g.genre_id = mg.genre_id and mg.movie_id = m.movie_id and d.director_id in
(SELECT d.director_id
FROM genre g,movie_has_genre mg,movie m,director d,movie_has_director md
WHERE mg.genre_id = g.genre_id and m.movie_id = mg.movie_id and m.movie_id = md.movie_id and d.director_id = md.director_id
GROUP BY d.director_id
HAVING COUNT(g.genre_id) >= 2)
GROUP BY d.last_name,m.title;

/*Q3 - Find the surnames of the actors,that,firstly,they play in at least one movie which has been directed from a director
with the same surname and secondly,they have played in at least one movie with a director with a different surname
and the movie genre is the same with some other movie that they don't play but has been direted by the director with the same surname. */

SELECT a.last_name
FROM actor a,director d,movie m,movie_has_director md,role r
WHERE m.movie_id = md.movie_id and md.director_id = d.director_id and r.movie_id = m.movie_id and a.actor_id = r.actor_id
and a.actor_id IN
(SELECT a.actor_id
FROM actor a,director d
WHERE a.last_name = d.last_name and m.movie_id = md.movie_id and md.director_id = d.director_id and r.movie_id = m.movie_id and a.actor_id = r.actor_id
GROUP BY a.actor_id
HAVING COUNT(*) >= 1)
and EXISTS
(SELECT *
FROM director d1,genre g,movie_has_director md1,movie m1,role r1,movie_has_genre mg
WHERE d1.last_name != d.last_name and md1.director_id = d1.director_id and md1.movie_id = m1.movie_id and r1.actor_id = a.actor_id and
r1.movie_id = m1.movie_id
HAVING g.genre_id = ANY
(SELECT g.genre_id
FROM movie_has_director md2,movie m2,role r2,director d2,genre g1,actor a1
WHERE d2.director_id = d.director_id and md2.director_id = d2.director_id and m2.movie_id = md2.movie_id
GROUP BY g.genre_id))
GROUP BY a.actor_id;

/*Q4 - Check if there is a movie with genre "Drama" that has been filmed in 1995.
This query should return one tuple with "yes" or "no" as an answer.Flow control Operators are not allowed*/

SELECT distinct 'yes' as answer
FROM movie m
WHERE EXISTS
(SELECT *
FROM genre g,movie_has_genre mg
WHERE m.movie_id = mg.movie_id and mg.genre_id = g.genre_id and g.genre_name = "Drama" and m.year = 1995)
UNION ALL
SELECT distinct 'no' as answer
FROM movie m1
WHERE m1.movie_id = ALL
(SELECT m2.movie_id
FROM movie m2
WHERE NOT EXISTS
(SELECT *
FROM genre g1,movie_has_genre mg1
WHERE m2.movie_id = mg1.movie_id and mg1.genre_id = g1.genre_id and g1.genre_name != "Drama" and m1.year = 1995)
);

/*Q5 - Find the surnames of a pair of directors that have directed the same movie between 2000 and 2006
on condition that these 2 directors have directed at least 6 different genres. Each pair must be printed once
and a director is not pair with himself*/

SELECT DISTINCT d1.last_name as a,d2.last_name as b
FROM movie m,director d1,director d2,movie_has_director md1,movie_has_director md2
WHERE d1.director_id != d2.director_id and md1.movie_id = m.movie_id and md2.movie_id = m.movie_id
and md1.director_id = d1.director_id and md2.director_id = d2.director_id and d1.last_name < d2.last_name
and m.year BETWEEN 2000 and 2006
and EXISTS
(
 SELECT d1.director_id
 FROM genre g,movie_has_genre mg,movie m,director d,movie_has_director md
 WHERE mg.genre_id = g.genre_id and m.movie_id = mg.movie_id and m.movie_id = md.movie_id and d1.director_id = md.director_id
 GROUP BY d1.director_id
 HAVING COUNT(g.genre_id) >= 6
)
and EXISTS
(
 SELECT d2.director_id
 FROM genre g,movie_has_genre mg,movie m,movie_has_director md
 WHERE mg.genre_id = g.genre_id and m.movie_id = mg.movie_id and m.movie_id = md.movie_id and d2.director_id = md.director_id
 GROUP BY d2.director_id
 HAVING COUNT(g.genre_id) >= 6
)
GROUP BY d1.last_name,d2.last_name;

/*Q6 - For each actor that have played in exactly 3 movies,find his name and his surname as well as
the number of different directors that have directed the movies he has played to*/

select actor.first_name,actor.last_name,count(distinct director.director_id) as px
from actor
join role on role.actor_id=actor.actor_id
join movie on movie.movie_id=role.movie_id
join movie_has_director on movie_has_director.movie_id=movie.movie_id
join director on director.director_id=movie_has_director.director_id
group by actor.actor_id
having count(distinct movie.movie_id)=3;

/*Q7 - For each movie that has exactly one genre,find this genre as well as the number of
directors that have directed this genre*/

SELECT genre.genre_id,COUNT(DISTINCT director.director_id) AS px
FROM genre
JOIN movie_has_genre on genre.genre_id=movie_has_genre.genre_id
JOIN movie_has_director on movie_has_genre.movie_id=movie_has_director.movie_id
JOIN director ON movie_has_director.director_id=director.director_id
GROUP BY genre.genre_id
HAVING genre.genre_id in (SELECT DISTINCT g.genre_id
	FROM movie m, movie_has_genre mhg,genre g
	WHERE mhg.genre_id=g.genre_id and mhg.movie_id IN (
		SELECT m.movie_id
		FROM movie m, movie_has_genre mhg,genre g
		WHERE m.movie_id=mhg.movie_id and mhg.genre_id=g.genre_id
		GROUP BY m.movie_id
		HAVING COUNT(g.genre_id)=1
	));

/*Q8 - Find the ids of the actors that have played in all genres*/

select a.actor_id
from genre g,actor a,role r,movie m,movie_has_genre mhg
where a.actor_id=r.actor_id and r.movie_id=m.movie_id and mhg.movie_id=m.movie_id and mhg.genre_id=g.genre_id
group by a.actor_id
having (select count(genre_id) from genre)=count(distinct(g.genre_id));

/*Q9 - For each pair of genre_ids find the number of directors that have directed movies for both genres*/

select g1.genre_id as np, g2.genre_id as nq,count(distinct director.director_id) as px
from genre g1,genre g2,director,movie_has_director mhd1,movie_has_director mhd2 ,movie_has_genre mhg1,movie_has_genre mhg2
where g1.genre_id<g2.genre_id and director.director_id=mhd1.director_id and mhd1.movie_id=mhg1.movie_id and mhg1.genre_id=g1.genre_id and
director.director_id=mhd2.director_id and mhd2.movie_id=mhg2.movie_id and mhg2.genre_id=g2.genre_id
group by g1.genre_id,g2.genre_id;

/*Q10 - For each genre and actor,find the number of movies of this genre that the actor has played,
on condition that all of these movies do not have a director that has directed some other genre besides this one*/

SELECT DISTINCT g.genre_id,a.actor_id,COUNT(m.movie_id) as movies
FROM genre g,actor a,movie m,role r,movie_has_director md,movie_has_genre mg,director d
WHERE a.actor_id = r.actor_id and r.movie_id = m.movie_id and mg.genre_id = g.genre_id and mg.movie_id = m.movie_id
and d.director_id = md.director_id and md.movie_id = m.movie_id and md.director_id NOT IN
(
  SELECT d1.director_id
  FROM director d1,genre g1,movie_has_director md1,movie m1,movie_has_genre mg1
  WHERE d1.director_id = md1.director_id and md1.movie_id = mg1.movie_id and mg1.genre_id = g1.genre_id
  and g1.genre_id != g.genre_id
  GROUP BY d1.director_id
) and m.movie_id IN
(
 SELECT m1.movie_id
 FROM movie m1,movie_has_genre mg1,movie_has_director md1
 WHERE m1.movie_id = md1.movie_id and m1.movie_id = mg1.movie_id
 GROUP BY m1.movie_id
 HAVING COUNT(mg1.genre_id) = 1
)
GROUP BY g.genre_id,a.actor_id;
