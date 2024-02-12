create database project1;
use project1;

# Project name :Zomato data analysis using SQL
-- Discription:
-- In this Zomato data analysis project, we aim to explore and 
-- derive insights from a dataset comprising restaurant information, 
-- including details such as location, cuisine, pricing, 
-- and customer reviews. We will examine factors influencing 
-- restaurant popularity, assess the relationship between 
-- price and customer ratings, and investigate the prevalence 
-- of services like online delivery and table booking. 
--  The project seeks to provide valuable insights into the restaurant 
--  industry and enhance decision-making for both customers and 
--  restaurateurs

-- Description of the dataset:

-- RestaurantID: A unique identifier for each restaurant in the dataset.

-- RestaurantName: The name of the restaurant.

-- CountryCode: A code indicating the country where the restaurant 
-- is located.

-- City: The city in which the restaurant is situated.

-- Address: The specific address of the restaurant.

-- Locality: The locality (neighborhood or district) where the restaurant 
-- is located.

-- LocalityVerbose: A more detailed description or name of the locality.

-- Longitude: The geographical longitude coordinate of the restaurant's 
-- location.

-- Latitude: The geographical latitude coordinate of the restaurant's 
-- location.

-- Cuisines: The types of cuisines or food offerings available at the 
-- restaurant. This may include multiple cuisines separated by commas.

-- Currency: The currency used for pricing in the restaurant.

-- Has_Table_booking: A binary indicator (0 or 1) that shows whether 
-- the restaurant offers table booking.

-- Has_Online_delivery: A binary indicator (0 or 1) that shows 
-- whether the restaurant provides online delivery services.

-- Is_delivering_now: A binary indicator (0 or 1) that indicates 
-- whether the restaurant is currently delivering food.

-- Switch_to_order_menu: A field that might suggest whether customers 
-- can switch to an online menu to place orders.

-- Price_range: A rating or category that indicates the price 
-- range of the restaurant's offerings (e.g., low, medium, high).

-- Votes: The number of votes or reviews that the restaurant has received.

-- Average_Cost_for_two: The average cost for two people to dine 
-- at the restaurant, often used as a measure of affordability.

-- Rating: The rating of the restaurant, possibly on a scale 
-- from 0 to 5 or a similar rating system.

-- Datekey_Opening: The date or key representing the restaurant's 
-- opening date.

-- This dataset seems to be valuable for analyzing and understanding 
-- restaurant-related information, including location, cuisine, 
-- pricing, and customer reviews. You can use it to perform 
-- various analyses, such as finding the most popular cuisines, 
-- exploring the relationship between price and rating, 
-- or identifying trends in restaurant services like 
-- online delivery and table booking.

-- ----------------------------------------------------
-- mysql can import only json or csv files
#step-1: data import/data collection
-- create database project1;
-- use project1;
select * from rest_data;
select * from country_data;

#step-2: Data cleaning
-- 1) datekey_opening.... replace _ by / and covert datatype
set sql_safe_updates=0;
update rest_data set datekey_opening=replace(datekey_opening,'_','/');
select datekey_opening from rest_data;
alter table rest_data modify column datekey_opening date;

-- 2) check unique values from categorical columns
select distinct countrycode from rest_data;
-- data is available for 6 countries

select distinct Has_Table_booking from rest_data;
select distinct Has_Online_delivery from rest_data;
select distinct Is_delivering_now from rest_data;
select distinct Switch_to_order_menu from rest_data;
select distinct Price_range  from rest_data;
select distinct Rating from rest_data;

-- 3) rename column countryname
alter table country_data 
change column `country name` country_name text;

-- 4) countries name

select * from country_data where countryid in (select distinct countrycode from rest_data);
-- India
-- Canada
-- New Zealand
-- Singapore
-- United Kingdom
-- United States of America

-- 5) how many resturants are registerd
select count(*) from rest_data;

-- 6) count of resturants from each country
select c2.country_name, count(*) from rest_data c1 inner join country_data c2
on c1.countrycode=c2.countryid
group by c2.country_name;
-- most of the resturunts are from india country

-- 7) count of * in % format 
select c2.country_name, (count(*)/804)*100 as total from rest_data c1 inner join country_data c2
on c1.countrycode=c2.countryid
group by c2.country_name;
-- 94% resturants are from india

-- 8)% of resturants based on Has_Online_delivery
select Has_Online_delivery,(count(*)/804)*100 from rest_data group by Has_Online_delivery;

-- 9)% of resturants based on Has_Table_booking
select Has_Table_booking,(count(*)/804)*100 from rest_data group by Has_Table_booking;
-- just 3% resturants has table booking

-- 10) date key column ... year, month, quater
select year(datekey_opening),count(*) from rest_data group by year(datekey_opening) order by 1;
select monthname(datekey_opening),count(*) from rest_data group by monthname(datekey_opening) ;
select quarter(datekey_opening),count(*) from rest_data group by quarter(datekey_opening) ;

-- by using extract fun
select extract(quarter from datekey_opening) as myyear,count(*) from rest_data
group by myyear order by myyear;


# 7 feb
-- 11) find most common cuisines in dataset
select Cuisines,count(*) from rest_data group by Cuisines;
-- nort indian is most common cuision

-- 12)top 5 rest who has more votes
select RestaurantName,votes from rest_data order by votes desc limit 5;
-- with countryname
select c2.country_name,c1.RestaurantName,c1.votes from rest_data c1 inner join country_data c2
on c1.countrycode=c2.countryid
order by c1.votes desc
limit 5;

-- 13)find the city with highest avg cost for two people
select city,avg(Average_Cost_for_two) from rest_data group by city order by 2 desc;

-- 14)india city wise count of rest
select c2.country_name,city,count(*) from rest_data c1 inner join country_data c2
on c1.countrycode=c2.countryid
where c2.country_name='india'
group by city;
-- data is avilable for new delhi

-- 15) rest name that are currently delevering
select RestaurantName,city,Is_delivering_now from rest_data where Is_delivering_now='yes';

-- 16) count of rest based on avg ratings
select distinct rating from rest_data;
select count(*),rating from rest_data group by rating;
-- most of the rest has one star rating

select 
case when rating <=2 then '0-2'
	when rating <=3 then '2-3'
    when rating <=4 then '3-4'
    when rating <=5 then '4-5'
    end rating_range,count(*) from rest_data
group by rating_range order by rating_range;

-- 17)price range 
select distinct Price_range from rest_data;

select price_range,min(Average_Cost_for_two),max( Average_Cost_for_two)
 from rest_data group by price_range;
/*  price range 3 .....expensive
    price range 2 .....medium
    price range 1 .....below medium
    price range 4......lowest/cheap
*/

select
case when price_range=3 then 'A'
	when price_range=2 then 'B'
    when price_range=1 then 'C'
    when price_range=4 then 'D'
end status,count(*)
from rest_data group by status order by status;

-- 18) find the top rated rest in each city
select distinct(city) from rest_data;
select city,max(votes)  from rest_data group by city;

with cte1 as (select RestaurantName,city,rank() over(partition by city order by votes desc) as 'rank1'
from rest_data)
select RestaurantName,city,rank1 from cte1 where rank1=1;
