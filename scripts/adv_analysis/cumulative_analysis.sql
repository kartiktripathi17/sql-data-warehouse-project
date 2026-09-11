-- Advances Analytics Project 
-- Cumulative Analysis
-- exp - Running Total Sales By Year
-- Moving Average of Sales By Month


-- Task :- Calculate the total sales per month and the running total sales over time

SELECT 
    order_date,
    total_sales,
    SUM(total_sales) OVER(ORDER BY order_date) AS running_total_sales
FROM
(
    SELECT  
        DATETRUNC(month,order_date) AS order_date,
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE  DATETRUNC(month,order_date) IS NOT NULL
    GROUP BY DATETRUNC(month,order_date)
) AS t;



-- Here we are Partitioning it by order_date (Year)

SELECT 
    order_date,
    total_sales,
    SUM(total_sales) OVER(PARTITION BY order_date ORDER BY order_date) AS running_total_sales
FROM
(
    SELECT  
        DATETRUNC(month,order_date) AS order_date,
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE DATETRUNC(month,order_date) IS NOT NULL
    GROUP BY DATETRUNC(month,order_date)
) AS t;



-- Here instead of Partitioning by year we are finding cumulative sales for year

SELECT 
    order_date,
    total_sales,
    SUM(total_sales) OVER(ORDER BY order_date) AS running_total_sales
FROM
(
    SELECT  
        DATETRUNC(year ,order_date) AS order_date,
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE DATETRUNC(year ,order_date) IS NOT NULL
    GROUP BY DATETRUNC(year ,order_date)
) AS t;



-- Finding moving avg along with runnign total sales

SELECT 
    order_date,
    total_sales,
    SUM(total_sales) OVER(ORDER BY order_date) AS running_total_sales,
    AVG(avg_price) OVER(ORDER BY order_date) AS running_average_sales
FROM
(
    SELECT  
        DATETRUNC(year ,order_date) AS order_date,
        SUM(sales_amount) AS total_sales,
        AVG(sls_price) AS avg_price
    FROM gold.fact_sales
    WHERE DATETRUNC(year ,order_date) IS NOT NULL
    GROUP BY DATETRUNC(year ,order_date)
) AS t;
