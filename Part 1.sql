-- MSc in DMDS - 2023-24
-- 7CPSQL / EMLYON Business School
-- FINAL GROUP PROJECT


-- For the FINAL PROJECT you will use the 'Divvy' database. 
-- It is part of a dataset derived from a bycicle sharing service in the city of Chicago, IL (USA) 
-- The service is similar to Lyon's "Velo'v". 
-- The database has two tables: 
-- (i) Trips, containing all the trips from the year 2018
-- (ii) Stations, which contains some data on each of the stations.

-- The data has been made available by Motivate International Inc. under this license:
-- https://ride.divvybikes.com/data-license-agreement and the full dataset as originally provided can be found here:
-- https://divvy-tripdata.s3.amazonaws.com/index.html
-- To give you a feeling for the data, we plotted the stations from the Stations table here:
-- https://www.google.com/maps/d/edit?mid=1o8GHKNl2UdNlCEVGWqzjTWxOoyB-EEg&usp=sharing
-- More about Divvy here: https://divvybikes.com/system-data

-- When completing this project as a group, remember to make your SQL code clear and comment on all queries.
-- Marks are provided for attempts made, so it's better to make an attempt than to completly leave a question out.

-- Marking scheme:
-- Part1 /4 ; Part2 /5 ; Part3 /7 (4+3) ; Quality of comments and presentations /4

USE Divvy;

-- PART 1 [4 marks]
-- Explore the database and its tables, then discuss your findings. Consider all the usual aspects in database exploration:
-- (e.g., are the data types assigned to each field correct? Are there any duplicates?)

-- Modify the type of start time in table trips from time to timestamp
select from_unixtime(start_time) as start_time_ts from Divvy.Trips;

-- Modify the type of end time in table Trips from time to timestamp
select from_unixtime(end_time) as end_time_ts from Divvy.Trips;

-- Modify the types of online_date in table Station from text to date
select str_to_date(online_date "m/%d/Y") as online_date_date from Divvy.Stations;

-- Modify the type of tripduration in table Trips from time to int
select cast(tripduration As unsigned int ) As tripduration FROM Trips;

-- Modify the type of birth year in table Trips from double float to int
select CAST(birth_year As unsigned INT) AS birth_year FROM Trips;

-- Check the duplicate trip_id
select trip_id,count(*) from Divvy.Trips group by trip_id having count(*)>1 order by count(*) desc;

-- Query the missing trips.
SELECT *
FROM Trips
WHERE trip_id LIKE "" OR start_time LIKE "" OR end_time LIKE "" OR bikeid LIKE "" OR tripduration LIKE "" OR 
from_station_id LIKE "" OR to_station_id LIKE "" OR usertype LIKE "" OR gender LIKE "" OR birthyear="";
-- Count the missing trips.
SELECT COUNT(*) FROM Trips 
WHERE trip_id LIKE "" OR start_time LIKE "" OR end_time LIKE "" OR bikeid LIKE "" OR tripduration LIKE "" OR 
from_station_id LIKE "" OR to_station_id LIKE "" OR usertype LIKE "" OR gender LIKE "" OR birthyear="";


-- Answer this question: What is the common key between the two tables?
-- Remember to take into account where the data comes from. 
-- Our answer: station_id







-- PART 2 [5 marks]
-- Imagine your database administrator is a slacker, and hasn't updated the Stations table since 2013.
-- (We uploaded the 2013 stations on purpose here of course!).
-- How many unique stations are in the Trips but not in the Stations? 
-- TIPS: 
-- Include stations "from_station_id" as well as stations "to_station_id".
-- You will need to use the keyword UNION, which combines the results from two queries into one column, dropping any duplicates
-- You can do a mini-practice here to understand the keyword before applying it: https://www.w3schools.com/sql/sql_union.asp
-- Remember to also display your results as a percentage of the total number of stations and not only as a absolute number.
-- We are suggesting a four-step plan to help you. You don't have to follow it, but it would be very helpful.
-- Don't forget to make your reasoning clear and to comment each of your steps.

-- Step 1: Write a query to know which station IDs in the "from_station_id" field are not in the Stations table.
-- Then do the same for the column "to_station_id".

-- Look for from_station_id that is in the Trips table but not in the Stations table, using the DISTINCT keyword to ensure that only a unique from_station_id is returned.
select distinct from_station_id from Trips as missing_from_station
WHERE from_station_id NOT IN (SELECT id FROM Stations);
-- 311 rows of station id in the "from_station_id" field are not in the Stations table
select distinct to_station_id from Trips as missing_to_station
WHERE to_station_id NOT IN (SELECT id FROM Stations);
-- 310 rows of station id in the "to_station_id" field are not in the Stations table

-- Step 2: Now, combine your two tables in STEP 1, using the keyword UNION.
-- A UNION will drop any duplicates, so you just need to count everything in the combined table
-- This will essentially represent the number of all missing stations.


with missingstation as (
select distinct from_station_id from Trips as missing_from_station_id
WHERE from_station_id NOT IN (SELECT id FROM Stations)
union
select distinct to_station_id from Trips as missing_to_station_id
WHERE to_station_id NOT IN (SELECT id FROM Stations)
),missing_station_count as (SELECT COUNT(*) AS total_missing_stations FROM missingstation)


-- Step 3: Using the same UNION keyword, count the total number of different stations in the two columns of the Trips table
-- (i.e., from_station_id and to_station_id).
-- TIP: Remember that a UNION will drop any duplicates and 
-- Note that in this case you are using UNION to combine data in two columns of the same table

-- total number of differnt station is 1221

-- Step 4: Finally, write a query that displays the percentage of missing stations from the Stations table.

SELECT total_missing_stations, total_stations,(total_missing_stations / total_stations) * 100 AS percentage_missing
FROM missing_station_count, total_station_count;
-- total missing stations : 315 
-- total stations: 1221
-- percentage of missing stations: 25.7985%



-- PART 3 [7 marks (4+3)]
-- The marketing department wants to know the age distribution of our users, and how their usage differs (in terms of trip durations). 
-- Give them a plot of age (on the X-axis), and average tripduration on the y-axis. 

-- PART 3.1
-- To achieve this, this, write a query that returns both age and average tripduration data from the Divvy Database
-- You need to extract the age from the birthyear field in the Trips table, given that this data contains all the trips from the year 2018
-- Make sure to not include missing values, and and order results by age. 
-- Now, export your data into a CSV file, then convert into Excel, and make the plot in Excel.
-- Explain your steps and discuss your findings. Please hand in your excel file, plus a discussion of what you did 
-- and what your conclusions are (Excel or SQL script comments). 
-- There appears to be a difference between the way the plot behaves before and after an age of about 65. 
-- Discuss what you think the reason is for the shape of the plot overall, and this difference as well.

SELECT birthyear, (2018- birthyear) as age,AVG(tripduration) AS average_tripduration
FROM Trips
WHERE  birthyear>1918 and start_time >= '2018-01-01'
-- there are some Anomalous data(age>100,tripduration=222,old people hard to 
-- ride a bike more than 3 hours, so we delete them)
  AND ( trip_id not LIKE "" and start_time not LIKE "" and end_time not LIKE "" and bikeid not LIKE "" and tripduration not LIKE "" and 
from_station_id not LIKE "" and to_station_id not LIKE "" and usertype not LIKE "" and gender not LIKE "" and birthyear >"0")
-- to delete the mssing vlues
group by age,birthyear
ORDER BY age ASC;

-- PART 3.2
-- Change your query in 3.1 by using FLOOR([your data]/10)*10 AS age_bin in a query that counts the number of trips 
-- grouped per age ranges (represented by age_bin, e.g., 10,20,30,40,50 etc.) instead of absolute values of age. 
-- This is a histogram in tabular form, which can then be exported to Excel in order to plot it.
-- Make the plot, then compare it to the one from your Query in 3.1. 
-- If you had done only this query (and not Query 3.1), would you have arrived at a different conclusion? 
-- Would it have been valid? Why yes or why not?

select Trips.tripduration,
FLOOR((2018-birthyear)/10)*10 AS age_bin
from Divvy.Trips
where birthyear is not null and birthyear>1900
order by age_bin asc;
-- No correlation. Please see more details in the excel '3.2' Sheet.




