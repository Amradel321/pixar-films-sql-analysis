select * from pixar_films;
select * from box_office;
-- Task 1: Financial Performance 
select f.film,year(release_date)as release_year
 ,round(budget/ 1000000, 1) AS budget_milions
 ,round(box_office_worldwide/1000000,1)as Worldwide_gross_millions 
 ,round(((box_office_worldwide-budget)/budget)*100,1) as ROI_Percentage
from pixar_films f join box_office o
on f.film = o.film
where budget is not null and budget >0
order by ROI_Percentage desc;


-- Task 2: Award Analysis 
with awards as(
select film , SUM(CASE 
        WHEN status LIKE 'won%' THEN 1 
        ELSE 0 
      END) AS awards_won,
      count(*) as Total_nominations
from academy
where status like "won%" or status like "nominated%" 
group by film
)
select film, awards_won, total_nominations,round((awards_won/Total_nominations)*100,1) as win_percentage
from awards
having awards_won > 0
order by win_percentage desc;

 -- Task 3: Genre Profitability
 select value as subgenre ,round(avg(box_office_worldwide)/1000000,1) as Avg_worldwide_gross_millions,
 count(distinct g.film) as num_of_films
 from genres g join box_office o
 on g.film = o.film
 group by subgenre
 having num_of_films>2
 order by Avg_worldwide_gross_millions desc
 limit 5;
 
 
 -- Task 4: Director Impact Study
 select name, round(avg(rotten_tomatoes_score),1)as avg_rotten_tomatoes_score,
 round(avg(box_office_worldwide)/1000000,1) as Avg_worldwide_gross_millions,
 round(avg(imdb_score),1) as avg_imdb_score,count(distinct p.film) as num_of_films
 from pixar_people p join public_response r 
 on p.film = r.film  join box_office o 
 on p.film = o.film
 where role_type = "director"
 group by name
 having num_of_films>1
 order by Avg_worldwide_gross_millions desc;
 
 
 
 
 
 --  Task 5: Franchise Comparison
 select* from pixar_films;
 select 
 case
 when f.film like "toy story%" then "Toy Story"
 when f.film like "Cars%" then "Cars"
 when f.film like "Finding%" then "Finding Nemo/Dory"
 end as franchise,
 count(f.film) as num_of_films, round(sum(box_office_worldwide)/1000000,1) as worldwide_gross_millions
 , round(avg(f.run_time),1)as avg_run_time
 from pixar_films f join box_office o
 on f.film = o.film  
 where
  f.film like "toy story%"or
  f.film like "Cars%" or
  f.film like "Finding%"
 group by franchise
 order by worldwide_gross_millions desc;
 
 -- Task 6: Budget Category Analysis
 
 select 
 case
 when budget<100000000 then"Low budget"
 when budget Between 100000000 and 150000000 then"Medium budget"
 when budget>150000000 then"High budget"
 end as Budget_category,
 round(avg(metacritic_score),1)Avg_metacritic_score, round(avg(box_office_worldwide)/1000000,1) as Avg_worldwide_gross_millions,
 count(o.film) as number_of_films
 from box_office o join public_response r 
 on o.film = r.film
 group by Budget_category;
 
 