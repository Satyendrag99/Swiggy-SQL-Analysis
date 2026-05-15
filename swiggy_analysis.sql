use swiggy_rest;
select * from swiggy_rest;

-- Which resturant of abohar is visited by least number of people?
SELECT *
FROM swiggy_rest
WHERE city = 'abohar'
AND rating_count = (
    SELECT MIN(rating_count)
    FROM swiggy_rest
    WHERE city = 'abohar'
);
SELECT *
FROM swiggy_rest
WHERE city = 'abohar'
ORDER BY rating_count ASC
LIMIT 20;

-- which resturant has Generated Maximum Revenue all Over India?

select * ,(cost*rating_count) as Revenue
from swiggy_rest
where (cost*rating_count) = (select MAX(cost*rating_count) 
from swiggy_rest);

-- How many resturants are having rating more than the Average rating?
select count(*) 
from swiggy_rest
where rating > (select AVG(rating)
from swiggy_rest);

-- which resturant of Delhi has Generated Most Revenue?
select *,(cost*rating_count) as Revenue
from swiggy_rest
where city = 'delhi'
and cost *rating_count = (select MAX(cost*rating_count) 
from swiggy_rest where city = 'delhi');

-- Which Resturant Chain has maximum No. of Resturants?

select name, count(name) as 'Total_Chain'
from swiggy_rest
group by name
order by Total_Chain 
desc Limit 1;

-- Which Resturant Chain has Generated Maximum Revenue?

select name, sum(cost*rating_count)
as 'Revenue'
from swiggy_rest
group by name 
order by Revenue 
desc limit 10;

-- Which City has Maximum number of Restaurants?

select city, count(*) as Total_Number
from swiggy_rest
group by city
order by 'Total_Numner'
desc limit 5;

-- Which City has Generated maximum revenue all over the india?

select city,sum(cost*rating_count) as Revenue
from swiggy_rest
group by city
order by Revenue
desc limit 10;


-- list 10 Least expensive Cuisines?

select cuisine, AVG(cost) as Least_Expensive
from swiggy_rest
group by cuisine
order by Least_Expensive 
limit 10;

-- List 10 Most Expensive Cuisine?

select cuisine, MAX(cost) as Most_Expensive
from swiggy_rest
group by cuisine
order by Most_Expensive desc
limit 10;

-- Which city is having Biryani as the most Popular Cuisine?

select city,Cuisine, AVG(rating_count) as Total_Popularity
from swiggy_rest
where cuisine ='Biryani'
group by city
order by Total_Popularity desc
limit 1;

-- List Top 10 Unique Resturants with unique name only through out the data sheet 
-- as per Generate Maximum revenue ( Single Resturant with that name)

SELECT name, SUM(cost * rating_count) AS Revenue
FROM swiggy_rest
GROUP BY name
HAVING COUNT(name) = 1
ORDER BY Revenue DESC
LIMIT 10;


-- WINDOWS FUNCTION--

-- Create New Column Containing Average rating of Restaurants Through the Dataset?

select *,
Avg(rating) Over() as Avg_rating
from swiggy_rest; 


 -- Create New Column Containing Average rating_count of Restaurants Through out the dataset
 
 select *,
 Avg(rating_count) over() as Avg_Rating
 from swiggy_rest;

-- Create New Column Containing Average, Min, Max of cost, rating,rating_count of Restaurants Through the dataset

Select name,city,cuisine,rating_count,cost,
-- Rating
	round(min(rating) over(),2) as 'min_rating',
    round(Avg(rating) over(),2) as 'Avg_rating',
    round(max(rating) over(),2) as 'max_rating',
-- cost
	round(min(cost) over(),2) as 'min_cost',
    round(Avg(cost) over(),2) as 'Avg_cost',
    round(Max(cost) over(),2) as 'Max_cost',
-- Rating_count
	round(min(rating_count) over(),2) as 'min_rating_count',
    round(Avg(rating_count) over(),2) as 'Avg_rating_count',
    round(Max(rating_count) over(),2) as 'Max_rating_count'
    from swiggy_rest;

-- Create column containing Avg cost of city which that specific resturants is Serving?

select name , city,cost, 
	round(Avg(cost) over (partition by city),2) 
    as 'Avg_cost'
    from swiggy_rest;
    
-- Create column containing Avg cost of cuisine which that specific resturants is Serving?
select name ,city, cuisine,cost,
	round(avg(cost) over(partition by cuisine),2)
    as 'Avg_cost_Cuisine'
    from swiggy_rest;


-- List  the restaurant whose cost is more than the avg cost of restaurants?
    
SELECT name, cost,
    ROUND(AVG(cost) OVER (),2) AS Avg_cost
FROM swiggy_rest 
WHERE cost > (SELECT AVG(cost) FROM swiggy_rest);

-- List the Restaurant whose cuisine is more than the Average cost?

SELECT *
FROM (
    SELECT *, 
           ROUND(AVG(cost) OVER (PARTITION BY cuisine), 2) AS avg_cost
    FROM swiggy_rest
) AS t
WHERE t.cost > t.avg_cost;
    
    
-- Rank Every Restaurant  from most Expensive  to Least Expensive?

SELECT  *,
	rank() Over (order By Cost DESC)
    as 'Rank' From Swiggy_rest;

-- Rank Every Restaurant from  most Visited to Least Visited?

Select *,
	Rank() over(Order By Rating_count Desc) as 
    'rank' from swiggy_rest;   
    
-- Rank Every Restaurant from most expensive to Least Expensive as per their city?

select *,
	rank() over(partition by City Order by Cost desc)
    as 'Rank' from swiggy_rest;
    
-- Dense Rank--
-- Rank Every Restaurant from most Expensive to Least Expensive as per their City?

Select *,
	Dense_rank() Over (Partition by city Order by Cost Desc)
		as 'Rank' from swiggy_rest;
    
-- Row_Number--
-- Every Restaurants from Most Expensive to Least Expensive as per their City?

Select *,
	Row_number() Over (Partition By City Order By Cost Desc)
    as 'Rank' from swiggy_rest;
    
-- Rank Every Restaurant from Most Expensive  to Least Expensive  as per their City along With its City [Adilabad-1, Adilabad -2]
    
Select * ,
	concat(City,'-',Row_number() over (Partition By City Order By Cost Desc))
    as 'Rank' from swiggy_rest;
    
    
-- Find Top Restaurants Of Every City as per Revenue?

select * from
(select * , cost*rating_count as Revenue,
	Row_number() Over (Partition By City Order By cost*rating_count Desc) 
    as 'Rank' from swiggy_rest) as t
    where t.Rank<6;
    
-- Find Top Restaurants Of Every Cuisine as per Revenue?

Select * from
(Select *, cost*rating_count as Revenue,
	Row_number() Over (Partition By Cuisine Order By cost*rating_count Desc)
    as 'Rank'from Swiggy_rest) as t
    where t.Rank<6;
    
    
 
     -- Advance Window function
     
-- 1. List the top 5 cuisines as per the revenue generated by top 5 Restaurant of every cuisine?

select*,
		Dense_rank() over (order by Rev Desc)
        as Cuisine_Rank from

(select Cuisine,sum(cost*rating_count) as 'Rev' from
    (select *,
		cost*rating_count as 'Revenue',
        row_number() over (Partition by Cuisine
        order by cost*rating_count DESC) as 'Rank' from swiggy_rest)as t
	where t.rank<6
    group by cuisine) aS x;
    
    























 





