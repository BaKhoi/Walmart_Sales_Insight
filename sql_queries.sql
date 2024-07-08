CREATE DATABASE IF NOT EXISTS salesDataWalmart;

CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6,4) NOT NULL,
    total DECIMAL(12,4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_percentage FLOAT(11,9),
    gross_income DECIMAL(12,4) NOT NULL,
    rating FLOAT(2,1) 
);





-- ---------------------------Feature Engineering--------------------------- --

-- time_of_day 

SELECT 
	time,
    (CASE 
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END) AS time_of_day
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day = 
(CASE 
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END);
    

-- day_name	

SELECT 
	date,
    DAYNAME(date) AS day_name
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DAYNAME(date);


-- month_name

SELECT 
	date,
    MONTHNAME(date) as month_name
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = MONTHNAME(date);

-- --------------------------------------------------------------------------- --
-- ---------------------------GENERIC QUESTIONS------------------------------- --
-- How many unique cities does the data have?

SELECT 
	DISTINCT city
FROM sales;

-- Yangon, Naypyitaw, Mandalay --



SELECT DISTINCT
    city, branch
FROM
    sales;

-- Yangon A, Naypyitaw B, Mandalay C --

-- --------------------------------------------------------------------------- --
-- --------------------------- PRODUCT QUESTIONS------------------------------- --

-- How many unique product lines does the data have? 6
SELECT 
	COUNT(DISTINCT product_line)
FROM sales;

	
-- What is the most common payment method? cash
SELECT 
	payment_method,
    COUNT(payment_method) AS customer_count
FROM sales
GROUP BY payment_method
ORDER BY customer_count DESC;

 
 
-- What is the most selling product line? Fashion accessories
SELECT 
	product_line,
    COUNT(product_line) AS customer_count
FROM sales
GROUP BY product_line
ORDER BY customer_count DESC;

-- What is the total revenue by month? Feb: 95727, March: 108867, January: 116291
SELECT 
	SUM(total) AS total_revenue,
    month_name
FROM sales
GROUP BY month_name
ORDER BY total_revenue;

-- What month had the largest COGS? January
SELECT 
	SUM(unit_price * quantity) AS COGS ,
    month_name
FROM sales
GROUP BY month_name
ORDER BY COGS;

-- What product line had the largest revenue? F&B
SELECT 
	SUM(total) AS total_revenue,
    product_line
FROM sales
GROUP BY product_line
ORDER BY total_revenue;

-- What is the city with the largest revenue? Naypyitaw
SELECT 
	SUM(total) AS total_revenue,
    city
FROM sales
GROUP BY city
ORDER BY total_revenue;

-- What product line had the largest VAT? Food and beverages
SELECT 
	SUM(VAT) AS total_VAT,
    product_line
FROM sales
GROUP BY product_line
ORDER BY total_VAT;

-- Fetch each product line and add a column to those product line showing "Good" "Bad". Good if its greater than average sales
SELECT 
	AVG(quantity) AS avg_qnty
FROM sales;

SELECT
	product_line,
	CASE
		WHEN AVG(quantity) > (SELECT AVG(quantity) AS avg_qnty FROM sales) THEN "Good"
        ELSE "Bad"
    END AS status
FROM sales
GROUP BY product_line;


-- Which branch sold more products than average product sold? Brnach A
SELECT
	branch,
    SUM(quantity) as total_quantity
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

-- What is the most common product line by gender? Female: Fashion accessories

SELECT 	
	gender,
    product_line,
    COUNT(gender) as total_cnt
FROM sales
GROUP BY gender, product_line
ORDER BY total_cnt DESC;

-- What is the average rating of each product line?
SELECT
	ROUND(AVG(rating), 2) as avg_rating,
    product_line
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;
	
    
    
-- -------------------------- SALES -------------------------------
-- -----------------------------------------------------------------
-- Number of sales made in each time of the day per weekday
SELECT 
	time_of_day,
    COUNT(*) AS total_sales
FROM sales
WHERE day_name NOT IN ("Sunday" , "Saturday")
GROUP BY time_of_day
ORDER BY total_sales DESC;


-- Which of the customer types brings the most revenue?
SELECT
	customer_type,
    SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue DESC;
    
-- Which city has the largest tax percent/ VAT (Value Added Tax)? Naypyitaw
SELECT
	city,
    ROUND(AVG(VAT), 2) AS avg_tax_pct
FROM sales
GROUP BY city 
ORDER BY avg_tax_pct DESC;

-- Which customer type pays the most in VAT? Member
SELECT
	customer_type,
    AVG(VAT) AS avg_VAT
FROM sales
GROUP BY customer_type
ORDER BY avg_VAT DESC;


-- -------------------------- CUSTOMERS ---------------------------- --
-- ----------------------------------------------------------------- --
-- How many unique customer types does the data have? 2
SELECT 
	DISTINCT customer_type
FROM sales;

-- How many unique payment methods does the data have? 3
SELECT 
	DISTINCT payment_method
FROM sales;

-- What is the most common customer type? 2
SELECT 
	DISTINCT customer_type,
    COUNT(*) AS count
FROM sales
GROUP BY customer_type
ORDER BY count DESC;

-- Which customer type buys the most? Member

-- What is the gender of most of the customers? Male 
SELECT 
	DISTINCT gender,
    COUNT(*) AS count
FROM sales
GROUP BY gender
ORDER BY count DESC;

-- What is the gender distribution per branch?
SELECT 
	branch,
    gender,
    COUNT(gender) AS gender_count
FROM sales
GROUP BY branch, gender
ORDER BY branch;

-- Which time of the day do customers give most ratings?
SELECT 
	time_of_day,
    AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Which time of the day do customers give most ratings per branch?

SELECT
	branch,
	time_of_day,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day, branch
ORDER BY avg_rating DESC;

-- Which day of the week has the best avg ratings?
SELECT
	day_name,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name 
ORDER BY avg_rating DESC;

-- Which day of the week has the best average ratings per branch?
SELECT
	branch,
	day_name,
	AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name, branch
ORDER BY avg_rating DESC;