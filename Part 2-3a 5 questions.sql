 -- Part 02 - 3a
 
 -- Question 01：Pricing strategy, step pricing: how long it takes for the bike to start breaking down？
 -- How to query？ Tripduration ratio of damage to total bike per half hour.
 -- Code below:
-- Convert tripduration to half hour intervals. Use floor to do round off.
 select floor(tripduration / (30 * 60)) as half_hour_interval,
-- Calculate the proportion of damage within each interval. Use cast to change bolean to decimals. Use AVG to calculate the average damage.
avg(Cast(end_bike_condition AS DECIMAL)) as damage_percentage from Trips
-- Damage statistics every half hour
group by half_hour_interval
order by half_hour_interval;
  
  
  
 -- Question 02：What is the damage cycle of each bike?
 -- 	How to query？ The ratio of the total tripduration each bike has been on the road to the number of times it has been damaged.
 -- 	Code below:
 -- Find the last damage time of every bike. If end_bike_condition is true, select the largest time， and create a temporary table(subquery?), Lastdamagetime, to make sure we only focus on the tripduraton before last damage time.
with ：Lastdamageinfo as (select bike_id, max(trip_start_time) as last_breakdown_time FROM trips WHERE end_bike_condition = TRUE GROUP BY bike_id)
-- Count the damage times(end_bike_condition = true), the total duration, calculate the average trip duration.
select bike_id, count(case when end_bike_condition = True Then 1 end) as damage_times, 
sum(tripduration) as total_duration, avg(tripduration) over () as average_damage_duration
-- Join the data before last damage time(lastdamageinfo) join trips. Make sure we focus on this time period only when we calculate the average.
from (select trips.bike_id, trips.tripduration,Lastdamageinfo.last_breakdown_time from trips join Lastdamageinfo on trips.bike_id = Lastdamageinfo.bike_id 
WHERE trips.trip_start_time <= Lastdamageinfo.last_breakdown_time) AS Lastdamagedata
-- group by bike_id and order by bike_id, then we can see that every bike's damage cycle.
group by bike_id order by bike_id;


-- Question 03: Service/product optimization: Query user satisfaction and the reasons for dissatisfaction
-- How to query？ Count 3 points out of 5 and below the reasons for dissatisfaction. No need to filter 1-3 points. Because only rated 3 and below users can answer this question.
-- Code below:
select user_complaints, count(*) AS user_complaints_count from Trips
where user_complaints is not null group by user_complaints;
  
  
-- Question 04: Market forecast: user's cycling frequency.
-- How to query？ Every user's cycle frequency per year.
-- Code below: 
select user_id,
extract(year from start_time) as trip_year,
count(*) as trips_count
from Trips Group by user_id, trip_year;
  
  
-- Question 05: Station planning: How should we balance the altitude of the new stations?
-- How to query？If the user change the station to return the bike, we can check the differences between the altitude of two stations.
-- Code below:
-- Put altitude information in trips table separately.
select trips.*, location.altitude AS from_station_altitude
From trips right join location on trips.from_station_id = location.station_id;
select trips.*, location.altitude as to_station_altitude
From trips right join location on trips.to_station_id = location.station_id;
-- Select if return station is different from start station, and count the conditions if the return station's altitude is higher or not.
select
count(case when to_station_altitude > from_station_altitude then 1 end) as return_altitude_higher,
count(case when to_station_altitude <= from_station_altitude then 1 end) as return_altitude_not_higher
from trips where to_station_id <> from_station_id;
