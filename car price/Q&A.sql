"Q1.Which 5 car models have the highest price, and what are their manufacturers and engine sizes?"
select
	model,
	engine_size,
	manufacturer,
	price
from cars
where price is not null
order by 4 desc
limit 5

--Exploratory Questions--
"Q2. What are the distinct fuel types available in the dataset?"
select
	distinct(fuel_type)
from cars

"Q3. What is the average price of cars by manufacturer?"
select
	manufacturer,
	round(avg(price)::numeric, 2) as avg_price
from cars
group by 1

"Q4. How many cars are automatic vs manual transmission?"
select
	transmission,
	count(transmission) as no_of_cars
from cars
where transmission not in ('Semi-Auto', 'Other')
group by 1

"Q5. What is the average mileage for cars from the year 2020?"
select
	model,
	year,
	transmission,
	fuel_type,
	engine_size,
	manufacturer,
	round(avg(price)::numeric, 2) as avg_price
from cars
where year = 2020
group by 1, 2, 3, 4, 5, 6

"Q6.Which manufacturers have cars with an average engine size greater than 2.0?"
select
	manufacturer,
	round(avg(engine_size)::numeric, 2) as avg_engine_size
from cars
group by 1
having avg(engine_size) > 2.0

-- Comparative/Trend Questions--
"Q7. How does the average MPG compare across different fuel types?"
select
	fuel_type,
	round(avg(mpg)::numeric, 2) as avg_mpg
from cars
group by 1

"Q8. Which year has the highest average car price?"
select
	year,
	round(avg(price)::numeric, 2) as avg_price
from cars
group by 1
order by 2 desc
limit 1

"Q9. What are the top 3 most common car models for each manufacturer?"
select
	manufacturer,
	model as top_3_models
from(
	select
		manufacturer,
		model,
		count(model),
		rank() over(partition by (manufacturer) order by count(model) desc) as rank
	from cars
	group by 1, 2
	order by 1
)
where rank <= 3

"Q10. Are there any manufacturers whose cars consistently have lower tax values?"
select
	manufacturer,
	round(avg(tax)::numeric, 2) as avg_tax
from cars
group by 1
order by 2 asc

"Q11. How does price vary with mileage for diesel cars?"
select
	milage,
	avg(price) as avg_price
from cars
where fuel_type = 'Diesel'
group by 1
order by 2 desc

--Advanced Analysis Ideas--
"Q12. What is the correlation between engine size and price?"
select
	corr("engine_size", "price") as correlation
from cars

"Q13. Can you list the most expensive car by each transmission type?"
select
	transmission,
	model as expensive_car,
	expensive_car as price
from(
	select
		transmission,
		model,
		max(price) as expensive_car,
		rank() over(partition by (transmission) order by max(price) desc) as rank
	from cars
	group by 1, 2
	order by 1, 3 desc
)
where rank = 1

"Q14. What is the price distribution for hybrid cars by year?"
select
	model,
	fuel_type,
	year,
	round(avg(price)::numeric, 2) as avg_price
from cars
where fuel_type = 'Hybrid'
group by 1, 2, 3
order by 1, 3

"Q15. What is the average tax by fuel type and engine size group (e.g., <1.5L, 1.5–2.0L, >2.0L)?"
select
	fuel_type,
	case
		when engine_size < 1.5 then '<1.5L'
		when engine_size between 1.5 and 2.0 then '1.5 - 2.0L'
		else '>2.0L'
	end as engine_size_group,
	round(avg(tax)::numeric, 2) as avg_tax
from cars
where fuel_type is not null
group by 1, 2
order by 1, 2

"Q16. Which cars (model + manufacturer) have unusually high price for their mileage? "
select
	model,
	manufacturer,
	round(avg(milage)::numeric, 2) as avg_milage,
	max(price) as max_price
from cars
group by 1, 2
order by 1

--Filtering & Segmentation--
"Q17. List all electric cars with a price under £20,000 and mileage below 30,000."
select
	model,
	fuel_type,
	milage,
	price
from cars
where price < 20000 and milage < 30000 

"Q18. Which cars have an MPG higher than 60 and engine size less than 1.5L?"
select
	model,
	manufacturer,
	mpg,
	engine_size
from cars
where mpg > 60 and engine_size < 1.5

"Q19. Find all cars manufactured by BMW between 2015 and 2020."
select
	model,
	manufacturer,
	year
from cars
where manufacturer = 'BMW' and year between 2015 and 2020
group by 1, 2, 3
order by 2,1,3

"Q20. Which cars have a tax value above £200 and were manufactured after 2018?"
select *
from cars
where tax > 200 and year > 2018

"Q21. List all manual transmission cars with over 100,000 mileage."
select *
from cars
where transmission = 'Manual' and milage > 100000
	
--Grouping & Aggregates--
"Q22. What is the total number of cars available per year?"
select
	year,
	count(model) as no_of_cars
from cars
group by 1
order by 1

"Q23. Which fuel type has the highest average price per manufacturer?"
select
	manufacturer,
	fuel_type,
	avg_price as highest_avg_price
from(
	select
		manufacturer,
		fuel_type,
		round(avg(price)::numeric, 2) as avg_price,
		rank() over(partition by (manufacturer) order by avg(price) desc) as rank
	from cars
	where fuel_type is not null
	group by 2, 1
	order by 1, 3 desc
)
where rank = 1

"Q24. What is the average engine size for cars with transmission type 'Semi-Auto'?"
select
	model,
	transmission,
	round(avg(engine_size)::numeric, 2) as avg_engine_size
from cars
where transmission = 'Semi-Auto'
group by 1, 2

"Q25. How many cars have both high tax (>£150) and low MPG (<30)?"
select
	count(model) as no_of_cars_tax_more_then_150_and_mpg_less_then_30
from cars
where tax >=150 and mpg <30
	
"Q26. Which models appear in at least 10 different years?"
select *
from(
	select
		model,
		count(year) as no_of_years_appeared
	from(
		select
			model,
			year
		from cars
		group by 1, 2
		order by 1, 2
		)
	group by 1
)
where no_of_years_appeared >= 10
order by 1

--Insight & Pattern Discovery--
"Q27. What trends can you observe in car prices over the years?"
select
	model,
	year,
	round(avg(price)::numeric, 2) as avg_prices
from cars
group by 1, 2
order by 1, 2

"Q28. Are newer cars (after 2018) more fuel-efficient on average than older ones?"
with cars_after_2018 as(
	select
		model,
		year,
		round(avg(milage)::numeric, 2) as new_car_milage
	from cars
	where year >= 2018
	group by 1, 2
),
cars_before_2018 as(
	select
		model,
		year,
		round(avg(milage)::numeric, 2) as old_car_milage
	from cars
	where year < 2018
	group by 1, 2
)
select
	ca.model,
	ca.new_car_milage as milage_of_cars_mfg_after_2018,
	cb.old_car_milage as milage_of_cars_mfg_before_2018
from cars_after_2018 as ca
join cars_before_2018 as cb
on ca.model = cb.model
group by 1, 2, 3

"Q29.Is there a relationship between mileage and tax?"
select
	round(corr("milage", "tax")::numeric, 2) as milage_tax_corr
from cars

"Q30. What is the most common car configuration (combination of transmission, fuel type, and engine size)?"
select
	transmission,
	fuel_type,
	engine_size,
	count(*) as count_config
from cars
where fuel_type is not null
group by 1, 2, 3
order by 4 desc
limit 1

"Q31. Which cars offer the best MPG per price ratio?"
select
	model,
	mpg,
	price,
	round((mpg * 1.0 / price)::numeric, 2) as mpg_per_price
from cars
where price > 0 and mpg is not null
order by 4 desc
limit 10

--Detailed Feature Analysis--
"Q32.What is the most common engine size per manufacturer?"
select
	manufacturer,
	engine_size as most_common_engine_size
from(
	select
		manufacturer,
		engine_size,
		count(engine_size),
		rank() over(partition by (manufacturer) order by count(engine_size) desc) as rank
	from cars
	group by 1, 2
	order by 1, 3 desc
)
where rank = 1

"Q33. Which car models have the widest range in price (max - min)?"
select
	model,
	min(price),
	max(price),
	max(price) - min(price) as min_max_price_difference
from cars
group by 1
order by 4 desc
limit 1

"Q34. Which fuel type has the largest variance in mileage?"
select
	fuel_type,
	max(milage) - min(milage) as largest_varience
from cars
group by 1
order by 2 desc
limit 1

"Q35. Which manufacturers sell cars in all available transmission types?"
select 
	manufacturer as manufacturers_sell_cars_in_all_available_transmission_types
from(
	select
			manufacturer,
			transmission,
			row_number() over(partition by (manufacturer)) as rank
		from cars
		group by 1, 2
		order by 1, 2
)
where rank >=4

--Price & Value Insight--
"Q36. What is the average price per 1,000 miles driven for each car model?"
select
	manufacturer,
	model,
	round(avg(price / (milage / 1000.0))::numeric, 2) as avg_price_per_1000_miles_driven
from cars
where price > 0 and milage is not null
group by 1, 2
order by 1, 2

"Q37. Identify the top 10 most affordable high-MPG cars."
select
	manufacturer,
	model,
	max(mpg) as high_mpg,
	min(price) as most_affordable
from cars
group by 1, 2
order by 1, 2

"Q38. Which cars are priced significantly below the average for their manufacturer"
select
	model,
	manufacturer,
	price
from cars as c1
where price < (select avg(price) 
				from cars as c2
				where c2.manufacturer = c1.manufacturer)

































