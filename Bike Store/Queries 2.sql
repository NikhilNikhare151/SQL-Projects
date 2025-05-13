"1. Who are the top 5 customers by total order value?"
select
	oi.order_id,
	first_name,
	last_name,
	round(sum(quantity * list_price)::numeric, 2) as total_order_value
from customers as c
join orders as o
on c.customer_id = o.customer_id
join order_items as oi
on o.order_id = oi.order_id
group by 1, 2, 3
order by 4 desc
limit 5

"2. Which products are currently out of stock at each store?"
select
	p.product_id,
	p.product_name,
	quantity
from products as p
join stocks as s
on p.product_id = s.product_id
where quantity = 0
order by 1 

"3. Which staff member made the most sales?"
select
	first_name,
	last_name,
	round(sum(quantity * list_price)::numeric, 2) as total_sales
from staff as s
join orders as o
on s.staff_id = o.staff_id
join order_items as oi
on o.order_id = oi.order_id
group by 1, 2
order by 3 desc

"4. What is the most sold product category by quantity?"
select
	c.category_id,
	c.category_name,
	sum(quantity) as total_quantity_sold
from categories as c
join products as p
on c.category_id = p.category_id
join order_items as oi
on p.product_id = oi.product_id
group by 1, 2
order by 3 desc

"5. What are the total sales (revenue) for each store?"
select
	store_name,
	round(sum(quantity * list_price * (1 - discount))::numeric, 2) as total_revenue
from stores as s
join orders as o
on o.store_id = s.store_id
join order_items as oi
on o.order_id = oi.order_id 
group by 1
order by 2 desc

"6. List all products that have never been ordered."
select
	oi.order_id,
	p.product_id,
	p.product_name
from products as p
left join order_items as oi
on p.product_id = oi.product_id
where p.product_id = null

"7. What is the average delivery time for each store?"
select
	store_name,
	round(avg(shipped_date - order_date)::numeric, 2) as delivery_time_in_days
from stores as s
join orders as o
on s.store_id = o.store_id
group by 1
order by 2 desc

"8. Which brand has the highest number of distinct products?"
select
	brand_name,
	count(distinct(product_id)) as no_of_products
from brands as b
join products as p
on b.brand_id = p.brand_id 
group by 1
order by 2 desc

"9. Find customers who have placed more than 2 orders."
select
	first_name,
	last_name,
	count(order_id) as total_order_placed
from customers as c
join orders as o
on c.customer_id = o.customer_id
group by 1, 2
having count(order_id) > 2

"10. Which product had the highest discount given (as a percentage)?"
select
	p. product_id,
	p. product_name,
	avg(oi.discount) as avg_discount
from products as p
join order_items as oi
on p.product_id = oi.product_id
group by 1, 2
order by 3 desc

"11. What are the top 3 most ordered products (by quantity)?"
select
	p. product_id,
	p. product_name,
	count(quantity) as total_quantity
from products as p
join order_items as oi
on p.product_id = oi.product_id
group by 1, 2
order by 3 desc
limit 3

"12. Show the total stock quantity of each product across all stores."
select
	p. product_id,
	p. product_name,
	sum(quantity) as total_stock_quantity
from products as p
join stocks as s
on p.product_id = s.product_id
group by 1, 2
order by 3 desc

"13. Which cities have customers but no store?"
select
	c.city,
	count(c.customer_id) as customer_count,
	s.store_name,
	s.city
from customers as c
join orders as o
on c.customer_id = o.customer_id 	
join stores as s
on o.store_id = s.store_id
group by 1, 3, 4
having c.city != s.city

"14. Which customer bought the most different product types (categories)?"
select
	c.first_name,
	c.last_name,
	count(distinct ca.category_id) as category_count
from customers as c
join orders as o
on o.customer_id = c.customer_id
join order_items as oi
on o.order_id = oi.order_id
join products as p
on p.product_id = oi.product_id
join categories as ca
on ca.category_id = p.category_id
group by 1, 2
order by 3 desc
limit 1

"15. Which month had the highest total sales value?"
select
	to_char(order_date, 'month') as month,
	round(sum(quantity * list_price)::numeric, 2) as total_sales
from orders as o
join order_items as oi
on o.order_id = oi.order_id
group by 1
order by 2 desc


"16. show a list of customers who have not placed any orders."
select
	first_name,
	last_name,
	order_id
from customers as c
left join orders as o
on c.customer_id = o.customer_id
where order_id is null

"17. Which customers always order from the same store?"
select
	c.customer_id,
	c.first_name,
	c.last_name,
	count(distinct s.store_id)
from customers as c
join orders as o
on c.customer_id = o.customer_id
join stores as s
on s.store_id = o.store_id
group by 1, 2, 3

"18. Find the orders where the total value is above the average order value."
select
	order_id,
	product_id,
	sum(quantity * list_price) as total_value
from order_items
group by 1, 2
having sum(quantity * list_price) > (
	select avg(order_total)
	from (
			select order_id, sum(quantity * list_price) as order_total
			from order_items
			group by order_id
	) as order_totals
)

"19. Which products are priced above the average for their category?"
with product_price
as
(select
	p.product_id,
	p.product_name,
	c.category_id,
	c.category_name,
	p.list_price
from products as p
join categories as c
on p.category_id = c.category_id 
),
category_price
as
(select
	c.category_id,
	c.category_name,
	round(avg(p.list_price)::numeric, 2) as avg_price_of_category
from products as p
join categories as c
on p.category_id = c.category_id
group by 1, 2
)
select
	pp.product_id,
	pp.product_name,
	cp.category_name,
	pp.list_price,
	cp.avg_price_of_category
from product_price as pp
join category_price as cp
on pp.category_id = cp.category_id
where list_price > avg_price_of_category	

"20. What is the average time between order date and required date?"
select
	round(avg(required_date - order_date)::numeric, 2) as average_time_between_order_date_and_required_date
from orders

"21. Rank products within each category by total quantity sold."
select
	product_name,
	category_name,
	sum(quantity) as total_qty_sold,
	row_number() over(partition by (category_name) order by sum(quantity) desc) as rank
from categories as c
join products as p
on c.category_id = p.category_id
join order_items as oi
on p.product_id = oi.product_id
group by 1, 2


"22. Which customers have ordered products from the most number of different brands?"
select
	c.first_name,
	c.last_name,
	count(b.brand_id) as ordered_products_from_the_most_number_of_different_brands
from customers as c
join orders as o
on c.customer_id = o.customer_id
join order_items as oi
on o.order_id = oi.order_id
join products as p
on p.product_id = oi.product_id
join brands as b
on b.brand_id = p.brand_id
group by 1, 2
order by 3 desc

"23. Generate a customer loyalty report:"
with total_orders
as(
select
	c.customer_id,
	c.first_name,
	c.last_name,
	count(o.order_id) as orders
from customers as c
join orders as o
on c.customer_id = o.customer_id
group by 1, 2, 3
),
total_amt_spent
as(
select
	c.customer_id,
	c.first_name,
	c.last_name,
	round(sum(quantity * list_price)::numeric, 2) as total_sum
from customers as c
join orders as o
on c.customer_id = o.customer_id
join order_items as oi
on o.order_id = oi.order_id
group by 1, 2, 3
),
fev_product_cat
as(
select
	c.customer_id,
	c.first_name,
	c.last_name,
	ca.category_name,
	count(ca.category_id) as count_category,
	row_number() over(partition by (first_name) order by count(ca.category_id) desc) as rank
from customers as c
join orders as o
on c.customer_id = o.customer_id
join order_items as oi
on o.order_id = oi.order_id
join products as p
on p.product_id = oi.product_id
join categories as ca
on ca.category_id = p.category_id 
group by 1, 2, 3, 4
),
last_order
as(
select
	c.customer_id,
	c.first_name,
	c.last_name,
	max(order_date) as order_date
from customers as c
join orders as o
on c.customer_id = o.customer_id
group by 1, 2, 3
)
select
	t.first_name,
	t.last_name,
	t.orders as total_orders,
	tms.total_sum as total_amt_spent,
	fpc.category_name as fev_product_cat,
	lo.order_date as last_order_date
from total_orders as t
join total_amt_spent as tms
on t.customer_id = tms.customer_id
join fev_product_cat as fpc
on tms.customer_id = fpc.customer_id
join last_order as lo
on lo.customer_id = fpc.customer_id
where fpc.rank = 1
group by 1, 2, 3, 4, 5, 6
order by 4 desc

"24. Which products have never been stocked in any store?"
select
	p.product_id,
	p.product_name,
	s.quantity,
	s.store_id
from products as p
left join stocks as s
on p.product_id = s.product_id	
where store_id is null

"25. Find the time of year (month or quarter) when the most orders are placed."
select
	extract (year from order_date) as year,
	to_char(order_date, 'month') as month,
	count(order_id) as no_of_orders_placed
from orders
group by 1, 2
order by 3 desc
---------------------------------------------
with quarters
as
(select *,
	case
		when extract(month from order_date) between 1 and 3 then '1st Quarter'
		when extract(month from order_date) between 4 and 6 then '2nd Quarter'
		when extract(month from order_date) between 7 and 9 then '3rd Quarter'
		when extract(month from order_date) between 10 and 12 then '4th Quarter'
		else 'unknown'
	end as quarter
from orders
)
select
	quarter,
	count(order_id) as orders_count
from quarters
group by 1
order by 2 desc

"26.  What is the reorder frequency (in days) for each product?"
select
	product_name,
	round(avg(days_since_last_order)::numeric, 2) as reorder_frequency_in_days
from
	(select
		p.product_id,
		p.product_name,
		o.order_date,
		o.order_date - lag(o.order_date) over(partition by product_name
		order by order_date) as days_since_last_order
	from orders as o
	join order_items as oi
	on o.order_id = oi.order_id
	join products as p
	on p.product_id = oi.product_id
	order by 1, 3 asc
)
group by 1
having avg(days_since_last_order) is not null
order by 2 desc

"27. Find the customer who spent the most money per order on average."
select
	o.order_id,
	c.first_name,
	c.last_name,
	round(avg(oi.quantity *  oi.list_price)::numeric, 2) as avg_money_spent_per_order
from customers as c
join orders as o
on o.customer_id = c.customer_id
join order_items as oi
on o.order_id = oi.order_id
group by 1, 2, 3
order by 4 desc

"28. Identify orders that include only one item."
select * 
from order_items
where quantity = 1

"29. Which brands are only sold in one store?"
select
	p.product_name,
	c.category_name,
	b.brand_name,
	count(distinct st.store_id)
from products as p
join categories as c
on p.category_id = c.category_id
join brands as b
on p.brand_id = b.brand_id
join stocks as s
on s.product_id = p.product_id
join stores as st
on s.store_id = st.store_id
group by 1, 2, 3

"30.  For each category, what is the average list price of products and total quantity sold?"
select
	c.category_name,
	round(avg(oi.list_price)::numeric, 2) as avg_price,
	sum(oi.quantity) as total_quantiy
from categories as c
join products as p
on c.category_id = p.category_id
join order_items as oi
on p.product_id = oi.product_id
group by 1
order by 2 desc, 3 desc

"31. Which staff has processed the largest number of high-value orders (>= 1000 $)"
select
	first_name,
	last_name,
	count(order_id) as orders_count
from
	(select
		s.first_name,
		s.last_name,
		oi.order_id,
		quantity * list_price * (1 - discount) as order_value
	from staff as s
	join orders as o
	on s.staff_id = o.staff_id
	join order_items as oi
	on o.order_id = oi.order_id
)
where order_value >= 1000
group by 1, 2
order by 3 desc

"32. Detect any missing shipped dates where the required date has already passed."
select
	order_date,
	required_date,
	shipped_date
from orders
where shipped_date is null

"33. Find the best-selling product per brand."
select
	brand_name,
	product_name as best_selling_product_per_brand,
	total_quantity_sold
from
	(select
		brand_name,
		product_name,
		sum(quantity) as total_quantity_sold,
		row_number() over(partition by (brand_name) order by sum(quantity) desc) as rank
	from brands as b
	join products as p
	on b.brand_id = p.brand_id
	join order_items as oi
	on oi.product_id = p.product_id
	group by 1, 2
)
where rank = 1

"34. Which customers placed orders in multiple cities (unusual behavior)?"
select
	c.customer_id,
	c.first_name,
	c.last_name,
	count(s.city)
from customers as c
join orders as o
on c.customer_id = o.customer_id
join stores as s
on o.store_id = s.store_id
group by 1, 2, 3
having count(s.city)> 1
order by 4 desc

"35. What’s the longest gap between orders for a customer?"
with last_order
as
(select
	c.customer_id,
	c.first_name,
	c.last_name,
	o.order_date,
	o.order_date - lag(o.order_date) over(partition by c.customer_id order by order_date desc) as days_since_last_order
from customers as c
join orders as o
on c.customer_id = o.customer_id
join order_items as oi
on o.order_id = oi.order_id
)
select
	customer_id,
	first_name,
	last_name,
	days_since_last_order,
	row_number() over(partition by customer_id order by days_since_last_order desc) as rank
from last_order
where days_since_last_order is not null
group by 1, 2, 3

"36. Identify orders with inconsistencies: shipped before order date."
select *
from orders
where shipped_date < order_date
	
"37. Which customers always buy products from the same brand?"
select
	c.customer_id,
	c.first_name,
	c.last_name,
	count(distinct b.brand_id)
from customers as c
join orders as o
on c.customer_id = o.customer_id
join order_items as oi
on o.order_id = oi.order_id 
join products as p
on p.product_id = oi.product_id
join brands as b
on b.brand_id = p.brand_id
group by 1, 2, 3
having count(distinct b.brand_id) = 1

"38. Show the product with the highest price per category."
select
	category_name,
	product_name,
	list_price as highest_price_in_category
from
	(select
		category_name,
		product_name,
		list_price,
		row_number() over(partition by category_name order by list_price desc) as rank
	from categories as c
	join products as p
	on p.category_id = c.category_id
)
where rank = 1

"39. Which products sell better in certain cities?"
select
	p.product_id,
	p.product_name,
	c.city,
	count(o.order_id) as total_count
from customers as c
join orders as o
on c.customer_id = o.customer_id 
join order_items as oi
on o.order_id = oi.order_id 
join products as p
on oi.product_id = p.product_id
group by 1, 2, 3
order by 4 desc

"40. What is the fastest shipped order per store?"
select *
from
	(select 
		s.store_name,
		o.order_id,
		c.customer_id,
		c.first_name,
		c.last_name,
		shipped_date - order_date as shipping_time,
		row_number() over(
			partition by store_name 
			order by shipped_date - order_date desc
		) as rn
	from customers as c
	join orders as o
	on c.customer_id = o.customer_id
	join order_items as oi
	on o.order_id = oi.order_id
	join stores as s
	on s.store_id = o.store_id
	order by 6 desc
)
where rn = 1







































