--SLQ project: Retail Sales Analysis

-- Let's create table
DROP TABLE IF EXISTS retail_sales_tb;
CREATE TABLE retail_sales_tb
			(
				transactions_id	INT PRIMARY KEY,
				sale_date DATE,
				sale_time TIME,
				customer_id	INT,
				gender VARCHAR(15),
				age	INT,
				category VARCHAR(15),
				quantiy	INT,
				price_per_unit FLOAT,
				cogs FLOAT,
				total_sale FLOAT
			);

SELECT * FROM retail_sales_tb
LIMIT 10;

SELECT COUNT(*) FROM retail_sales_tb;

-- 1. Data Cleaning

--Finding the Null values
SELECT * FROM retail_sales_tb
WHERE transactions_id IS NULL;

SELECT * FROM retail_sales_tb
WHERE sale_date IS NULL;

SELECT * FROM retail_sales_tb
WHERE 
	transactions_id IS NULL
	OR sale_date IS NULL
	OR sale_time IS NULL
	OR customer_id IS NULL
	OR gender IS NULL
	OR age IS NULL
	OR category IS NULL
	OR quantiy IS NULL
	OR price_per_unit IS NULL
	OR cogs IS NULL
	OR total_sale IS NULL;

-- Removing NULL values
DELETE FROM retail_sales_tb
WHERE 
	transactions_id IS NULL
	OR sale_date IS NULL
	OR sale_time IS NULL
	OR customer_id IS NULL
	OR gender IS NULL
	OR age IS NULL
	OR category IS NULL
	OR quantiy IS NULL
	OR price_per_unit IS NULL
	OR cogs IS NULL
	OR total_sale IS NULL;

SELECT COUNT(*) FROM retail_sales_tb;


-- 2. Data Exploration

-- 1) How many sales and how many unique customers and categories we have?
SELECT COUNT(*) as totoal_sales 
FROM retail_sales_tb;

SELECT COUNT(DISTINCT customer_id) as total_number_of_customers
FROM retail_sales_tb;

SELECT DISTINCT category as total_number_of_categories
FROM retail_sales_tb;


-- 2) EDA: Business Key Problems and Answers(10 Questions)

--Q1) Retrieve all columns for sales made on '2024-11-05'
SELECT *
FROM retail_sales_tb
WHERE sale_date = '2024-11-05'

--Q2) Retrieve all transactions where the category is 'Clothing' and the quatity sold is more than 4 in the month of Nov 2024
SELECT *
FROM retail_sales_tb
WHERE category = 'Clothing'
	AND sale_date BETWEEN '2024-11-01' AND '2024-11-30'   --or AND TO_CHAR(sale_date, 'YYYY-MM') = '2044-11'   -
	AND quantiy >= 4;
	
--Q3) Calculate the total sales(total_sales for each category)
SELECT category, SUM(total_sale) AS total_sales, COUNT(*) AS total_orders
FROM retail_sales_tb
GROUP BY category
ORDER BY total_orders DESC;


--Q4) The average age of customer who purchased items for the 'Beauty' Category
SELECT * 
FROM retail_sales_tb;

SELECT ROUND(AVG(age), 2) AS avg_age
FROM retail_sales_tb
WHERE category = 'Beauty';

--Q5) A query to find all transactions where the total_sale is greater than 1000.
SELECT * 
FROM retail_sales_tb;

SELECT *
FROM retail_sales_tb
WHERE total_sale > 1000;

--Q6) a query to find the total number of transctions (transaction_id) made by each gender in each category
SELECT category, gender, COUNT(*) AS total_trans
FROM retail_sales_tb
GROUP BY category, gender
ORDER BY 1;

--Q7) A query to calculate the average sale for each month. Find out the best selling month in each year
SELECT * 
FROM retail_sales_tb;

--using CTE
SELECT 
	year, month, avg_sale
FROM
(
	SELECT 
		EXTRACT(YEAR FROM sale_date) as year,
		EXTRACT(MONTH FROM sale_date) as month,
		AVG(total_sale) as avg_sale,
		RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) AS rank
	FROM retail_sales_tb
	GROUP BY 1, 2
) as t1
WHERE rank = 1;

--Q8) Find the top 5 customers based on the highest total sales
SELECT * 
FROM retail_sales_tb;

SELECT
	customer_id, 
	SUM(total_sale) AS total_sales
FROM retail_sales_tb
GROUP BY customer_id
ORDER BY 2 DESC
LIMIT 5;

--Q9) Find the number of unique customers who purchased items from each category

SELECT 
	category,
	COUNT(DISTINCT customer_id) AS unique_customer
FROM retail_sales_tb
GROUP BY category;

--Q10) Create eacht shift and number of orders(Example Morning <= 12, Afternon Between 12 & 17, Evening > 17)

WITH hourly_sale
AS
(
SELECT *,
	CASE 
		WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END as Shift
FROM retail_sales_tb
)
SELECT
	shift,
	COUNT(*) as total_orders
FROM hourly_sale
GROUP BY shift;