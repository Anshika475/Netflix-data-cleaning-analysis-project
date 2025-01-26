--remove duplicates
use STUDENT;
select show_id, COUNT(*)
from netflix_raw
group by show_id
having count(*)>1

select * from netflix_raw
where concat(title,type) in(
select concat(title, type)
from netflix_raw
group by title, type
having count(*)>1
)
order by title

--date type conversion for date added
--drop columns cast, country, director, listed_in
with cte as (
select * 
,ROW_NUMBER() over(partition by title, type order by show_id) as rn
from netflix_raw
)
select show_id, type, title, cast(date_added as date) as date_added, release_year, rating, case when duration IS NULL then rating else duration end as duration, description
into netflix
from cte
--where rn=1 and date_added is null

select * from netflix

--new table for director
select show_id, trim(value) as director
into netflix_directors
from netflix_raw
cross apply string_split(director,',')

select * from netflix_directors

-- new table for country
select show_id, trim(value) as country
into netflix_country
from netflix_raw
cross apply string_split(country,',')

--new table for listed_in
select show_id, trim(value) as listed_in
into netflix_listed_in
from netflix_raw
cross apply string_split(listed_in,',')

--new table for cast
select show_id, trim(value) as cast
into netflix_cast
from netflix_raw
cross apply string_split(cast,',')

select* from netflix_cast

-- populate missing values in country, duration columns
insert into netflix_country
select show_id,m.country
from netflix_raw nr
inner join (select director,country
from netflix_country nc
inner join netflix_directors nd on nc.show_id=nd.show_id
group by director,country
) m on nr.director=m.director
where nr.country is null

----------------------------------------

select * from netflix_raw where duration is null


------------------------------------------
------------------------------------------

-- netflix data analysis
/* 1 for each director count the no of movies and tv shows created by them in seperate columns for directors who have created tv shows and movies both*/
select nd.director, 
count (distinct case when n.type='movie' then n.show_id end) as no_of_movies
, count (distinct case when n.type='TV Show' then n.show_id end) as no_of_TVShow
from netflix n
inner join netflix_directors nd on n.show_id=nd.show_id
group by nd.director
having count(distinct n.type)>1

--2 which country has highest number of comedy movies
select top 1 nc.country, count (distinct nl.show_id) as no_of_movies
from netflix_listed_in nl
inner join netflix_country nc on nl.show_id=nc.show_id
inner join netflix n on nl.show_id=nc.show_id
where nl.listed_in='comedies' and n.type='movie'
group by nc.country
order by no_of_movies desc

--3 for each year (As per date added to netflix), which director has maxmium number of movies released
with cte as(
select nd.director, year(date_added) as date_year, count(n.show_id) as no_of_movies
from netflix n
inner join netflix_directors nd on n.show_id=nd.show_id
where type='movie'
group by nd.director, year(date_added)
)
, cte2 as(
select *
, ROW_NUMBER() over(partition by date_year order by no_of_movies desc, director) as rn
from cte
--order by date_year, no_of_movies desc
)
select * from cte2 where rn=1

--4 what is average duration of movies in each genre
