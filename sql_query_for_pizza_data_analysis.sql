
--  CREATE TABLE ORDERS 

CREATE TABLE orders(
order_id INT NOT NULL,
order_date date not null,
order_time time not null,
primary key (order_id));

-- CREATE TABLE ORDERS_DETAILS 

CREATE TABLE order_details (
order_details_id INT NOT NULL,
order_id INT NOT NULL,
pizza_id text not null,
quntity int not null,
primary key (order_details_id));


-- Retrieve the total number of orders placed.
SELECT  COUNT(order_id)  from orders;


-- Calculate the total revenue generated from pizza sales
SELECT round(sum(order_details.quntity * pizzas.price),2) as total_revenue
FROM order_details join pizzas
on order_details.pizza_id=pizzas.pizza_id; 


-- Identify the highest-priced pizza.
SELECT pizza_types.name ,pizzas.price 
FROM pizza_types join pizzas
on pizza_types.pizza_type_id=pizzas.pizza_type_id ;
order by pizzas.price desc LIMIT 1;


-- Identify the most common pizza size ordered.
SELECT quntity ,count(order_details_id)
from order_details group by quntity;

SELECT pizzas.size , count(order_details.order_details_id) as total_size
from pizzas join order_details
on pizzas.pizza_id=order_details.pizza_id
group by pizzas.size order by total_size desc LIMIT 10;


-- List the top 5 most ordered pizza types along with their quantities.
SELECT pizza_types.name , SUM(order_details.quntity) as totalqunt 
from pizza_types join pizzas 
on pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on order_details.pizza_id=pizzas.pizza_id
group by  pizza_types.name order by totalqunt desc limit 5;


-- join the necessary tables to find the total quantity of each pizza category ordered.
SELECT pizza_types.category, sum(order_details.quntity) as quantity
from pizza_types join pizzas on
pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details on
order_details.pizza_id= pizzas.pizza_id
group by pizza_types.category order by quantity desc;


-- Determine the distribution of orders by hour of the day.
SELECT hour(order_time) as hour, count(order_id) as order_count from orders
group by hour(order_time) order by order_count desc ;


-- Join relevant tables to find the category-wise distribution of pizzas. 
select category , count(name) as name
from pizza_types group by category;


-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT avg(quntity) as avg_pizza from
(SELECT orders.order_date , sum(order_details.quntity) as quntity
FROM orders join order_details
on orders.order_id = order_details.order_id
group by orders.order_date) as order_quntity;


-- Determine the top 3 most ordered pizza types based on revenue.
select pizza_types.name, round(sum(order_details.quntity * pizzas.price),0) as revenue
from pizza_types join pizzas on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details on  order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name order by revenue desc;


-- Calculate the percentage contribution of each pizza type to total revenue
select pizza_types.category, round((round(sum(order_details.quntity * pizzas.price),0) / (SELECT round(sum(order_details.quntity * pizzas.price),2) as total_revenue
FROM order_details join pizzas
on order_details.pizza_id=pizzas.pizza_id))*100 ,2) as revenue
from pizza_types join pizzas on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details on  order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category order by revenue desc ;


-- Analyze the cumulative revenue generated over time.
select order_date, sum(revenue) over(order by order_date) as cum_revenue
from
(select orders.order_date, round(sum(order_details.quntity * pizzas.price),0) as revenue
from order_details join pizzas 
on order_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id - order_details.order_id
group by orders.order_date) as sales;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category , name, revenue
from
(select category , name, revenue,
rank() over ( partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.name,
sum((order_details.quntity) * pizzas.price) as revenue
from pizza_types join pizzas on
pizza_types.pizza_type_id=pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.category,pizza_types.name) as a) as b
where rn <= 3;
