CREATE DATABASE SALES

CREATE TABLE retail_sales(
transactions_id	INT PRIMARY KEY,
sale_date	DATE, 
sale_time   TIME,
customer_id	 INT,
gender	VARCHAR(15),
age	INT,
category VARCHAR(15),
quantiy	INT, 
price_per_unit FLOAT,
cogs	FLOAT,
total_sale  FLOAT

);

SELECT * FROM retail_sales
LIMIT 10
-- DATA CLEANING
SELECT * FROM retail_sales
WHERE
     transactions_id IS NULL
	 OR
	 sale_date IS NULL
	 OR
	 sale_time IS NULL
	 OR
	 gender IS NULL
	 OR
	 age IS NULL
	 OR
	 category IS NULL
	 OR
	 quantiy IS NULL
	 OR
	 cogs IS NULL
	 OR
	 total_sale IS NULL

	 DELETE FROM retail_sales
	 WHERE
	      transactions_id IS NULL
	 OR
	 sale_date IS NULL
	 OR
	 sale_time IS NULL
	 OR
	 gender IS NULL
	 OR
	 category IS NULL
	 OR
	 quantiy IS NULL
	 OR
	 cogs IS NULL
	 OR
	 total_sale IS NULL

-- DATA EXPLORATION

-- How many sales we have?
SELECT COUNT(*) as total_sale FROM retail_sales


-- How many unique customers do we have?
SELECT COUNT(DISTINCT(customer_id)) as unique_customer FROM retail_sales

-- How many unique category do we have?
SELECT COUNT(DISTINCT(category)) as unique_customer FROM retail_sales


 --What are the unique category do we have?
SELECT DISTINCT(category) FROM retail_sales

-- Q1. Write a sql query to retrive all columns for salesmade on '2022-11-05'
SELECT * FROM retail_sales
WHERE sale_date = '2022-11-05'

-- Q2. Write a sql query to retrive all transactions where the category is 'clothing' and the quantity sold is more than 4 in the month of november
SELECT * FROM retail_sales
WHERE 
    category='Clothing' 
    AND 
	quantiy>= 4 
	AND 
	TO_CHAR(sale_date,'YYYY-MM')='2022-11'

--Q3. Write a sql querry to calculate the total sales(total_sale) for each category
SELECT 
     category,
	 SUM(total_sale) as TOTAL_SALES,
	 COUNT(*) as TOTAL_OREDRS 
FROM retail_sales
GROUP BY category

--Q4. Write a sql querry to find the average age of customers who purchased items from the 'beauty' category
  SELECT ROUND(AVG(age),2) AS AVG_AGE
  FROM retail_sales
      WHERE category='Beauty'

--Q5. Write a sql querry to find all transactions where the total_sales is greater than 1000

	 SELECT * FROM retail_sales
	 WHERE total_sale >1000

--Q6. Write	 a sql query to find the total numberof transaction_id madeby eachgender in each category
SELECT category,gender,COUNT(transactions_id) AS TOTAL_NUMBER
FROM retail_sales
GROUP BY gender, category
ORDER BY category

--Q7.Write a sql query to calculate the average sale for each month.Find out best selling month in each year
SELECT * FROM
	 (SELECT
	       EXTRACT(YEAR FROM sale_date) as year,
		   EXTRACT(MONTH FROM sale_date) as month,
		   ROUND(AVG(total_sale):: NUMERIC,2) as avg_sale,-- note: we cannot use round function on avg bcz it returns a float value so to use round function first we nned to do explicit typecasting to convert into numeric value
		   RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) as rank --note: we cannot use where clause(bcz the useer have created the column in window function)  that's why we need to store it in a sub query or cte to use a where clause and alias(as) at window function
	FROM retail_sales
	GROUP BY  year, month) AS T1
	WHERE rank=1
	--ORDER BY year ASC, avg_sale  DESC

--Q8. Write	 a sql query to find the top 5 customers based on the highest totalsales
SELECT * FROM
(SELECT customer_id, SUM(total_sale) as totalsales,
RANK() OVER(ORDER BY SUM(total_sale) DESC) AS RANK
FROM retail_sales 
GROUP BY customer_id)
LIMIT 5

--Q9. Write a sql query to find the number of unique characters who purchased items from each category

 SELECT
      category,
	  COUNT(DISTINCT customer_id) AS unique_customer
FROM retail_sales
GROUP BY category

--Q10. Write a sql query to create each shift and number of orders(Example morning<=12, afternoon between 12 &17, evening>17)
WITH hourly_sales
AS
   (SELECT *,
       CASE
	       WHEN EXTRACT(HOUR FROM sale_time)<12 THEN 'morning'
		   WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'afternoon'
		   ELSE 'evening'
	   END AS shift	   
      
   FROM retail_sales) 
SELECT 
shift,
COUNT(*) as total_orders
FROM hourly_sales
GROUP BY shift