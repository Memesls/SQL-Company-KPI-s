-- 1. Creating the table and adding data with the import wizard tool

create database coffe_shop_sales_db;

-- 2. Updating data types in the table

SELECT 
    *
FROM
    coffe_shop_sales;

describe coffe_shop_sales;

-- change column to date and format it
UPDATE coffe_shop_sales 
SET 
    transaction_date = STR_TO_DATE(transaction_date, '%m/%d/%Y');

alter table coffe_shop_sales
modify column transaction_date date;

-- change column to time and format it
UPDATE coffe_shop_sales 
SET 
    transaction_time = STR_TO_DATE(transaction_time, '%H:%i:%s');

alter table coffe_shop_sales
modify column transaction_time time;

-- correct the id column name
alter table coffe_shop_sales
change column ï»¿transaction_id transaction_id int;

-- 3. Calculating new values

-- 3.1 Total sales by month
select 
month(transaction_date) as month,
round(sum(unit_price * transaction_qty),1) as Total_sales
from coffe_shop_sales
group by month(transaction_date);

-- MoM sales percentage change
-- create cte for easier readibility
with Sales_by_month as (
select 
month(transaction_date) as month,
round(sum(unit_price * transaction_qty),1) as Total_sales
from coffe_shop_sales
group by month(transaction_date)
)
select 
month, 
Total_Sales,
round((Total_Sales - lag(Total_Sales,1) over (order by month)),1) as mom_sales_change,
round(((Total_Sales - lag(Total_Sales,1) over (order by month)) / lag(Total_sales,1) over (order by month)) * 100,1) as mom_percentage_change
from Sales_by_month
group by month;


-- 3.2 Total # of orders by month
SELECT 
    MONTH(transaction_date) AS month, COUNT(*) AS Total_orders
FROM
    coffe_shop_sales
GROUP BY month;

-- MoM # of orders percentage change
-- create cte for easier readibility
with Orders_by_month as (
select 
month(transaction_date) as month, count(*) as Total_orders
from coffe_shop_sales
group by month
)
select 
month, 
Total_orders,
round((Total_orders - lag(Total_orders,1) over (order by month)),1) as mom_orders_change,
round(((Total_orders - lag(Total_orders,1) over (order by month)) / lag(Total_orders,1) over (order by month)) * 100,1) as mom_percentage_change
from Orders_by_month
group by month;


-- 3.3 Total quantity by month
SELECT 
    MONTH(transaction_date) AS month,
    SUM(transaction_qty) AS Total_quantity
FROM
    coffe_shop_sales
GROUP BY month;

-- MoM # of orders percentage change
-- create cte for easier readibility
with Quantity_by_month as (
select month(transaction_date) as month, sum(transaction_qty) as Total_quantity
from coffe_shop_sales
group by month
)
select 
month, 
Total_quantity,
round((Total_quantity - lag(Total_quantity,1) over (order by month)),1) as mom_orders_change,
round(((Total_quantity - lag(Total_quantity,1) over (order by month)) / lag(Total_quantity,1) over (order by month)) * 100,1) as mom_percentage_change
from Quantity_by_month
group by month;


-- 3.4 General values calculation for specific days
SELECT 
    ROUND(SUM(unit_price * transaction_qty), 1) AS Total_sales,
    SUM(transaction_qty) AS Total_quantity,
    COUNT(*) AS Total_orders
FROM
    coffe_shop_sales
WHERE
    transaction_date = '2023-05-18';


-- 3.5 Revenue by weekday and weekend per month
SELECT 
    MONTH(transaction_date) AS month,
    CASE
        WHEN DAYOFWEEK(transaction_date) IN (1 , 7) THEN 'Weekends'
        ELSE 'Weekdays'
    END AS day_type,
    ROUND(SUM(unit_price * transaction_qty), 1) AS Total_sales
FROM
    coffe_shop_sales
GROUP BY month , day_type;


-- 3.6 Sales by store location
SELECT 
    store_location,
    ROUND(SUM(unit_price * transaction_qty), 1) AS Total_sales
FROM
    coffe_shop_sales
GROUP BY store_location;

-- 3.7 Monthly Sales average
select 
month,
round(avg(Total_sales),1)
from (
select 
month(transaction_date) as month,
sum(unit_price * transaction_qty) as Total_sales
from coffe_shop_sales
-- where month(transaction_date) = 5
group by transaction_date
) as subquery
group by month;


-- 3.8 Daily Sales per month
SELECT 
    MONTH(transaction_date) AS month,
    DAY(transaction_date) AS day_of_month,
    ROUND(SUM(unit_price * transaction_qty), 1) AS Total_sales
FROM
    coffe_shop_sales
GROUP BY month , day_of_month;


-- 3.9 Determine which sales day was above or below the respective monthly average
select 
month,
day_of_month,
case 
	when Total_sales > Avg_sales then "Above Average"
	when Total_sales < Avg_sales then "Below Average"
    else "Equal to Average"
end as Sales_status,
Total_sales
from (
	select
    month(transaction_date) as month,
    day(transaction_date) as day_of_month,
    round(sum(unit_price * transaction_qty),1) as Total_sales,
    avg(sum(unit_price * transaction_qty)) over (partition by month(transaction_date)) as Avg_sales
from coffe_shop_sales
-- where month(transaction_date) = 5
group by month, day(transaction_date)
) as Sales_data;
		

-- 3.10 Sales by product category
SELECT 
    MONTH(transaction_date) AS month,
    product_category,
    ROUND(SUM(unit_price * transaction_qty), 1) Total_sales
FROM
    coffe_shop_sales
GROUP BY month , product_category
ORDER BY month , Total_sales DESC;


-- 3.11 Top 10 products by sales
SELECT 
    product_type,
    ROUND(SUM(unit_price * transaction_qty), 1) Total_sales
FROM
    coffe_shop_sales
WHERE
    MONTH(transaction_date) = 5
GROUP BY product_type
ORDER BY Total_sales DESC
LIMIT 10;


-- 3.12 Sales, quantity and orders for specific days and hours of the month
SELECT 
    DAYOFWEEK(transaction_date) AS day,
    HOUR(transaction_time) AS hour,
    ROUND(SUM(unit_price * transaction_qty), 1) Total_sales,
    SUM(transaction_qty) AS Total_quantity,
    COUNT(*) AS Total_orders
FROM
    coffe_shop_sales
WHERE
    MONTH(transaction_date) = 5
GROUP BY day , hour
ORDER BY day , hour;


-- 3.13 Total sales by hour
SELECT 
    HOUR(transaction_time) AS hour,
    ROUND(SUM(unit_price * transaction_qty), 1) Total_sales
FROM
    coffe_shop_sales
WHERE
    MONTH(transaction_date) = 5
GROUP BY HOUR(transaction_time)
ORDER BY HOUR(transaction_time);
    
    
-- 3.13 Total sales by day
SELECT 
    DAYNAME(transaction_date) AS day,
    ROUND(SUM(unit_price * transaction_qty), 1) Total_sales
FROM
    coffe_shop_sales
WHERE
    MONTH(transaction_date) = 5
GROUP BY day
ORDER BY 
	CASE day
    WHEN 'Monday' THEN 1
    WHEN 'Tuesday' THEN 2
    WHEN 'Wednesday' THEN 3
    WHEN 'Thursday' THEN 4
    WHEN 'Friday' THEN 5
    WHEN 'Saturday' THEN 6
    WHEN 'Sunday' THEN 7
END;
