 """Questions and Answers"""

 "Q1. List all product names and their list prices."
 select 
 	product_name,
	list_price	 
 from products
 order by 2 desc

 " Q2. List all orders along with customer names and store names."
 select
 	c.first_name,
	c.last_name,
	c.city,
	p.product_name,
	p.model_year,
	oi.list_price,
	oi.discount
from customers as c
join orders as o
on c.customer_id = o.customer_id
join order_items as oi
on o.order_id = oi.order_id
join products as p
on p.product_id = oi.product_id
order by 6 desc

" Q3. Display each product with its brand and category name."
select
	p.product_name,
	b.brand_name,
	c.category_name
from products as p
join brands as b
on p.brand_id = b.brand_id
join categories as c
on c.category_id = p.category_id

" Q4 Show the total quantity of each product available in stock across all stores."	
select
	product_name,
	store_name,
	sum(quantity) as total_stock
from products as p
join stocks as s
on p.product_id = s.product_id
join stores as st
on st.store_id = s.store_id
group by 1, 2
order by 3 desc
	
" Q5 Find the number of orders placed each month."
select
	extract(month from order_date) as month_no,
	to_char(order_date, 'Month') as Month,
	count(extract(month from order_date)) as total_count
from orders
group by 2,1
order by 1

" Q 6. Calculate total sales revenue per store."
select
	store_name,
	round(sum(list_price)::numeric,2) as total_revenue
from stores as s
join orders as o
on s.store_id = o.store_id
join order_items as oi
on o.order_id = oi.order_id
group by 1
order by 2 desc

" Q6. Find the average discount offered across all order items."
select
	product_name,
	round(avg(discount):: numeric,2) as avg_discount
from products as p
join order_items as o
on o.product_id = p.product_id
group by 1
order by 2 desc

" Q7. Show the total number of products in each category."
select
	c.category_name as category,
	count(p.product_id) as total_no_of_products
from categories as c
join products as p
on c.category_id = p.category_id
group by 1
order by 2 desc

" Q8. Get the number of customers in each city."
select
	city,
	count(customer_id) as no_of_customers
from customers
group by 1
order by 2 desc

" Q 9. List the top 5 most sold products (by quantity)."
select
	product_name,
	sum(quantity) as most_sold_products
from products as p
join order_items as o
on p.product_id = p.product_id
group by 1
order by 2 desc
limit 5

" Q 10. Find customers who placed more than 3 orders."
select
	first_name,
	last_name,
	count(o.customer_id) as no_of_orders
from customers as c
join orders as o
on c.customer_id = o.customer_id
group by 1, 2
having count(o.customer_id) >= 3
order by 3 desc

" Q 11. Get the best-selling brand based on total quantity sold."
select
	brand_name,
	sum(quantity) as best_selling_brand_by_quantity
from brands as b
join products as p
on b.brand_id = p.brand_id
join order_items as o
on o.product_id = p.product_id
group by 1
order by 2 desc
limit 1

" Q 12. List customers who live in the same city as any store."
select
	c.first_name,
	c.last_name,
	c.city,
	s.store_name,
	s.city
from customers as c
join orders as o
on c.customer_id = o.customer_id
join stores as s
on s.store_id = o.store_id
where c.city = s.city

" Q 13. Which city has the highest number of customers?"
select
	city,
	count(customer_id) as highest_no_of_customers
from customers
group by 1
order by 2 desc
limit 1

" Q 14. Display the full name and total amount spent by each customer."
select
	first_name,
	last_name,
	round(sum(list_price)::numeric,2) as total_amt_spent
from customers as c
join orders as o
on o.customer_id = c.customer_id
join order_items as oi
on o.order_id = oi.order_id
group by 1, 2
order by 3 desc
	
" Q 15. Which day had the highest number of orders?"
select
	order_date,
	count(order_date)
from orders
group by 1
order by 2 desc

select
	extract(day from order_date),
	to_char(order_date, 'Day') as day_of_week,
	count(order_id) as no_of_orders
from orders
group by 1, 2

" Q 16. What is the average order value per customer?"
select
	round(avg(list_price)::numeric, 2) as avg_order_value_per_customer
from order_items


" Q 17 . Compare total sales made in each year"
select
	extract(year from order_date) as yesr,
	round(sum(list_price)::numeric, 2) as total_sales_per_year
from orders as o
join order_items as oi
on o.order_id = oi.order_id
group by 1
order by 1 asc

" Q 18. Get customers who ordered products from more than one category."
select
	c.first_name,
	c.last_name,
	count(distinct ca.category_id) as no_of_categories_ordered
from customers as c
join orders as o
on c.customer_id = o.customer_id
join order_items as oi
on o.order_id = oi.order_id
join products as p
on oi.product_id = p.product_id
join categories as ca
on p.category_id = p.category_id
group by 1, 2



	










	