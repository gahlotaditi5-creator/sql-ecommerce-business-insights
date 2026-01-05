-- ques 1
/*You can analyze all the tables by describing their contents.
Task: Describe the Tables:
Customers
Products
Orders
OrderDetails*/

-- describing customer table
desc customer;

-- describing product table
desc products;

-- describing Orders table
desc orders;

-- describing order_deatils table
desc order_details;

-- ques 2
/*Problem statement
Identify the top 3 cities with the highest number of customers to determine key markets for 
targeted marketing and logistic optimization.

Hint:
Use the “Customers” Table.
Return the result table limited to top 3 locations in descending order*/

select location , count(*) as number_of_customer 
from customer
group  by location
order by number_of_customer desc
limit 3;

-- Engagement depth analysis
/*Determine the distribution of customers by the number of orders placed. This insight will help 
in segmenting customers into one-time buyers, occasional shoppers, and regular customers for 
tailored marketing strategies.
1 = one time buyer
2- 4 occasional shopper
>4 regular customer*/

with cte as(
select customer_id , count(ï»¿order_id) as NumberOfOrders from orders
group by customer_id)
select NumberOfOrders, count(customer_id) as CustomerCount
from cte 
group by NumberOfOrders
order by NumberOfOrders;

-- 
/*Identify products where the average purchase quantity per order is 2 but with a high total 
revenue, suggesting premium product trends.*/

select product_id, avg(quantity) as AVGQuantity,
sum(quantity*price_per_unit) as total_revenue 
from order_details
group by product_id
having avg(quantity) =2
;

/*For each product category, calculate the unique number of customers purchasing from it. 
This will help understand which categories have wider appeal across the customer base.*/

select p.category, count(distinct o.customer_id) as unique_customer from products p
left join order_details od 
on p.product_id = od.product_id
join orders o 
on od.order_id = o.order_id
group by p.category;

alter table customer
rename column ï»¿customer_id to customer_id;

alter table order_details
rename column ï»¿order_id to order_id;

alter table orders
rename column ï»¿order_id to order_id;

alter table products
rename column ï»¿product_id to product_id;

/*Analyze the month-on-month percentage change in total sales to identify growth trends.
month | TotalSales | PercentageChange*/

select date_format(order_date,'%Y-%m') as 'month',
sum(total_amount) as TotalSales,
round(((sum(total_amount) - lag(sum(total_amount)) over(order by date_format(order_date,'%Y-%m')))/
lag(sum(total_amount)) over(order by date_format(order_date,'%Y-%m'))*100),2) as
PercentageChange
from orders
group by date_format(order_date,'%Y-%m');

/*Examine how the average order value changes month-on-month. Insights can guide pricing and 
promotional strategies to enhance order value.
month | AvgOrderValue | ChangeInValue */

select date_format(order_date,'%Y-%m') as 'month',
round(avg(total_amount),2) as AvgOrderValue,
round(avg(total_amount)-lag(avg(total_amount)) over(order by date_format(order_date,'%Y-%m')),2) as ChangeInValue
from orders
group by date_format(order_date,'%Y-%m')
order by changeInValue desc;

/*Based on sales data, identify products with the fastest turnover rates, suggesting high 
demand and the need for frequent restocking.*/

select product_id,count(*) as salesFrequency
from order_details
group by product_id
order by salesFrequency desc
limit 5;


/*List products purchased by less than 40% of the customer base, indicating potential 
mismatches between inventory and customer interest.*/

select p.product_id, p.name , count(distinct o.customer_id) as UniqueCustomerCount
from products p join order_details od 
on p.product_id = od.product_id
join orders o on 
od.order_id = o.order_id
group by p.product_id , p.name
having count(distinct o.customer_id) < (select count(*) from customer)*.40;


/*Evaluate the month-on-month growth rate in the customer base to understand the effectiveness 
of marketing campaigns and market expansion efforts.*/

with cte as(
select customer_id , min(date_format(order_date,'%Y-%m')) as firstPurchaseMonth 
from orders
group by customer_id)
select firstPurchaseMonth, count(customer_id) as TotalNewCustomers
from cte 
group by firstPurchaseMonth
order by firstPurchaseMonth;

/*Identify the months with the highest sales volume, aiding in planning for stock levels, 
marketing efforts, and staffing in anticipation of peak demand periods.*/

select date_format(order_date,'%Y-%m') as 'month',
sum(total_amount) as TotalSales
from Orders 
group by date_format(order_date,'%Y-%m')
order by TotalSales desc
limit 3;

/************************** ANALYSIS OF BUSINESS REQUIREMENTS ************************************/


-- KPI’S REQUIREMENTS

-- 1. Total Sales Analysis:

-- 1.1 Calculate the total sales for each respective month.

select date_format(transaction_date,'%Y-%m') as transaction_month,
round(sum(transaction_qty*unit_price),2) as total_sales
from coffee_shop_sales
group by date_format(transaction_date,'%Y-%m');

-- 1.2 Determine the month-on-month increase or decrease in sales.

select date_format(transaction_date,'%Y-%m') as transaction_month,
round(sum(transaction_qty*unit_price),2) as total_sales,
lag(sum(transaction_qty*unit_price)) over(order by date_format(transaction_date,'%Y-%m')) as last_mon,
(sum(transaction_qty*unit_price) - 
lag(sum(transaction_qty*unit_price)) over(order by date_format(transaction_date,'%Y-%m'))/
lag(sum(transaction_qty*unit_price)) over(order by date_format(transaction_date,'%Y-%m'))) 
as MoM_change
from coffee_shop_sales
group by date_format(transaction_date,'%Y-%m');

-- 1.3 Calculate the difference in sales between the selected month and the previous month.

/*2. Total Orders Analysis:

Calculate the total number of orders for each respective month.

Determine the month-on-month increase or decrease in the number of orders.

Calculate the difference in the number of orders between the selected month and the previous month.

3. Total Quantity Sold Analysis:

Calculate the total quantity sold for each respective month.

Determine the month-on-month increase or decrease in the total quantity sold.

Calculate the difference in the total quantity sold between the selected month and the previous month.
​
*/



