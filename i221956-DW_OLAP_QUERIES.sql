
use my_dw;

-- Q1.SELECT *
SELECT *
FROM (
    SELECT 
        YEAR(dd.full_date) AS year,
        MONTH(dd.full_date) AS month,
        CASE 
            WHEN DAYOFWEEK(dd.full_date) IN (1, 7) THEN 'Weekend'
            ELSE 'Weekday'
        END AS day_type,
        pd.product_id,
        pd.product_category,
        SUM(fs.purchase_amount) AS total_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY 
                YEAR(dd.full_date),
                MONTH(dd.full_date),
                CASE 
                    WHEN DAYOFWEEK(dd.full_date) IN (1, 7) THEN 'Weekend'
                    ELSE 'Weekday'
                END
            ORDER BY SUM(fs.purchase_amount) DESC
        ) AS rn
    FROM fact_sales fs
    JOIN date_dim dd ON fs.date_id = dd.date_id
    JOIN product_dim pd ON fs.product_id = pd.product_id
    GROUP BY 
        YEAR(dd.full_date),
        MONTH(dd.full_date),
        day_type,
        pd.product_id,
        pd.product_category
) ranked_products
WHERE rn <= 5
ORDER BY year, month, day_type, total_revenue DESC;

-- 2.
SELECT
    c.gender,
    c.age,
    c.city_category,
    SUM(f.purchase_amount) AS total_purchase_amount
FROM fact_sales f
JOIN customer_dim c 
    ON f.customer_id = c.customer_id
GROUP BY 
    c.gender,
    c.age,
    c.city_category
ORDER BY 
    c.city_category,
    c.gender,
    c.age;

-- Q3.
SELECT
    p.product_category,
    c.occupation,
    SUM(f.purchase_amount) AS total_sales
FROM fact_sales f
JOIN customer_dim c 
    ON f.customer_id = c.customer_id
JOIN product_dim p
    ON f.product_id = p.product_id
GROUP BY
    p.product_category,
    c.occupation
ORDER BY
    p.product_category,
    total_sales DESC;

 -- Q4.
 SELECT
    c.gender,
    CASE
        WHEN c.age < 18 THEN '0-17'
        WHEN c.age BETWEEN 18 AND 25 THEN '18-25'
        WHEN c.age BETWEEN 26 AND 35 THEN '26-35'
        WHEN c.age BETWEEN 36 AND 45 THEN '36-45'
        WHEN c.age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '55+'
    END AS age_group,
    d.quarter,
    SUM(f.purchase_amount) AS total_purchase_amount
FROM fact_sales f
JOIN customer_dim c
    ON f.customer_id = c.customer_id
JOIN date_dim d
    ON f.date_id = d.date_id
WHERE d.year = 2015   
GROUP BY
    c.gender,
    age_group,
    d.quarter
ORDER BY
    c.gender,
    age_group,
    d.quarter;


-- Q5:
SELECT
    product_category,
    occupation,
    total_sales
FROM (
    SELECT
        p.product_category,
        c.occupation,
        SUM(f.purchase_amount) AS total_sales,
        ROW_NUMBER() OVER (PARTITION BY p.product_category ORDER BY SUM(f.purchase_amount) DESC) AS rn
    FROM fact_sales f
    JOIN customer_dim c
        ON f.customer_id = c.customer_id
    JOIN product_dim p
        ON f.product_id = p.product_id
    GROUP BY
        p.product_category,
        c.occupation
) AS ranked
WHERE rn <= 5
ORDER BY
    product_category,
    total_sales DESC;

-- Q6 :
SELECT
    c.city_category,
    c.marital_status,
    d.year,
    d.month,
    SUM(f.purchase_amount) AS total_purchase_amount
FROM fact_sales AS f
JOIN customer_dim AS c
    ON f.customer_id = c.customer_id
JOIN date_dim AS d
    ON f.date_id = d.date_id
WHERE d.full_date >= DATE_SUB((SELECT MAX(full_date) FROM date_dim), INTERVAL 6 MONTH)
GROUP BY
    c.city_category,
    c.marital_status,
    d.year,
    d.month
ORDER BY
    d.year,
    d.month,
    c.city_category,
    c.marital_status;
    
    -- Q7 
    SELECT
    c.stay_in_current_city_years,
    c.gender,
    AVG(f.purchase_amount) AS avg_purchase_amount
FROM fact_sales AS f
JOIN customer_dim AS c
    ON f.customer_id = c.customer_id
GROUP BY
    c.stay_in_current_city_years,
    c.gender
ORDER BY
    c.stay_in_current_city_years,
    c.gender;

-- Q8:
SELECT *
FROM (
    SELECT
        c.city_category,
        p.product_category,
        SUM(f.purchase_amount) AS total_revenue,
        ROW_NUMBER() OVER (PARTITION BY p.product_category ORDER BY SUM(f.purchase_amount) DESC) AS rn
    FROM fact_sales AS f
    JOIN customer_dim AS c
        ON f.customer_id = c.customer_id
    JOIN product_dim AS p
        ON f.product_id = p.product_id
    GROUP BY
        c.city_category,
        p.product_category
) AS ranked
WHERE rn <= 5
ORDER BY
    product_category,
    total_revenue DESC;
    
    -- Q9
    
    SELECT
    product_category,
    year,
    month,
    total_sales,
    ROUND(
        (total_sales - prev_month_sales) / prev_month_sales * 100,
        2
    ) AS mom_growth_percentage
FROM (
    SELECT
        p.product_category,
        d.year,
        d.month,
        SUM(f.purchase_amount) AS total_sales,
        LAG(SUM(f.purchase_amount)) OVER (
            PARTITION BY p.product_category ORDER BY d.year, d.month
        ) AS prev_month_sales
    FROM fact_sales AS f
    JOIN product_dim AS p
        ON f.product_id = p.product_id
    JOIN date_dim AS d
        ON f.date_id = d.date_id
    WHERE d.year = 2020   -- change to a year that exists in your data
    GROUP BY
        p.product_category,
        d.year,
        d.month
) AS monthly_sales
ORDER BY
    product_category,
    year,
    month;

-- Q10:

SELECT
    CASE
        WHEN c.age < 18 THEN '0-17'
        WHEN c.age BETWEEN 18 AND 25 THEN '18-25'
        WHEN c.age BETWEEN 26 AND 35 THEN '26-35'
        WHEN c.age BETWEEN 36 AND 45 THEN '36-45'
        WHEN c.age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '55+'
    END AS age_group,
    CASE
        WHEN d.weekday IN ('Saturday', 'Sunday') THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    SUM(f.purchase_amount) AS total_purchase_amount
FROM fact_sales f
JOIN customer_dim c
    ON f.customer_id = c.customer_id
JOIN date_dim d
    ON f.date_id = d.date_id
WHERE d.year = 2020  -- change to the current year in your dataset
GROUP BY age_group, day_type
ORDER BY age_group, day_type;


-- Q11:

WITH product_monthly_revenue AS (
    SELECT
        p.product_id,
        p.product_category,
        p.store_name,
        p.supplier_name,
        d.year,
        d.month,
        CASE
            WHEN d.weekday IN ('Saturday', 'Sunday') THEN 'Weekend'
            ELSE 'Weekday'
        END AS day_type,
        SUM(f.purchase_amount) AS total_revenue
    FROM fact_sales f
    JOIN product_dim p
        ON f.product_id = p.product_id
    JOIN date_dim d
        ON f.date_id = d.date_id
    WHERE d.year = 2020  -- replace with the year you want
    GROUP BY
        p.product_id,
        p.product_category,
        p.store_name,
        p.supplier_name,
        d.year,
        d.month,
        day_type
),
ranked_products AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY month, day_type ORDER BY total_revenue DESC) AS rn
    FROM product_monthly_revenue
)
SELECT
    product_id,
    product_category,
    store_name,
    supplier_name,
    year,
    month,
    day_type,
    total_revenue
FROM ranked_products
WHERE rn <= 5
ORDER BY month, day_type, total_revenue DESC;


-- Q12:

SELECT
    current.store_id,
    current.store_name,
    current.year,
    current.quarter,
    current.total_revenue,
    CASE
        WHEN prev.total_revenue IS NULL THEN NULL
        ELSE ROUND((current.total_revenue - prev.total_revenue) / prev.total_revenue * 100, 2)
    END AS growth_percentage
FROM
    (
        -- Current quarter revenue
        SELECT
            s.store_id,
            s.store_name,
            d.year,
            d.quarter,
            SUM(f.purchase_amount) AS total_revenue
        FROM fact_sales f
        JOIN store_dim s ON f.store_id = s.store_id
        JOIN date_dim d ON f.date_id = d.date_id
        WHERE d.year = 2017
        GROUP BY s.store_id, s.store_name, d.year, d.quarter
    ) AS current
LEFT JOIN
    (
        -- Previous quarter revenue
        SELECT
            s.store_id,
            d.year,
            d.quarter,
            SUM(f.purchase_amount) AS total_revenue
        FROM fact_sales f
        JOIN store_dim s ON f.store_id = s.store_id
        JOIN date_dim d ON f.date_id = d.date_id
        WHERE d.year = 2017
        GROUP BY s.store_id, d.year, d.quarter
    ) AS prev
ON current.store_id = prev.store_id
   AND current.quarter = prev.quarter + 1
ORDER BY current.store_id, current.quarter;


-- Q 13:


SELECT
    s.store_id,
    s.store_name,
    sup.supplier_id,
    sup.supplier_name,
    p.product_id,
    p.product_category AS product_name,
    SUM(f.purchase_amount) AS total_sales
FROM fact_sales f
JOIN store_dim s ON f.store_id = s.store_id
JOIN supplier_dim sup ON f.supplier_id = sup.supplier_id
JOIN product_dim p ON f.product_id = p.product_id
GROUP BY
    s.store_id,
    s.store_name,
    sup.supplier_id,
    sup.supplier_name,
    p.product_id,
    p.product_category
ORDER BY
    s.store_name,
    sup.supplier_name,
    p.product_category;


-- Q14:

SELECT
    p.product_id,
    p.product_category AS product_name,
    CASE
        WHEN d.month IN (3,4,5) THEN 'Spring'
        WHEN d.month IN (6,7,8) THEN 'Summer'
        WHEN d.month IN (9,10,11) THEN 'Fall'
        ELSE 'Winter'
    END AS season,
    SUM(f.purchase_amount) AS total_sales,
    CASE
        WHEN d.month IN (3,4,5) THEN 1
        WHEN d.month IN (6,7,8) THEN 2
        WHEN d.month IN (9,10,11) THEN 3
        ELSE 4
    END AS season_order
FROM fact_sales f
JOIN product_dim p ON f.product_id = p.product_id
JOIN date_dim d ON f.date_id = d.date_id
GROUP BY
    p.product_id,
    p.product_category,
    season,
    season_order
ORDER BY
    p.product_category,
    season_order;


-- Q15: 


SELECT
    curr.store_id,
    s.store_name,
    curr.supplier_id,
    sp.supplier_name,
    curr.year,
    curr.month,
    curr.total_revenue,
    ROUND(
        (curr.total_revenue - IFNULL(prev.total_revenue, curr.total_revenue))
        / IFNULL(prev.total_revenue, curr.total_revenue) * 100, 2
    ) AS revenue_volatility_percentage
FROM
    (
        SELECT 
            f.store_id,
            f.supplier_id,
            d.year,
            d.month,
            SUM(f.purchase_amount) AS total_revenue
        FROM fact_sales f
        JOIN date_dim d ON f.date_id = d.date_id
        GROUP BY f.store_id, f.supplier_id, d.year, d.month
    ) AS curr
LEFT JOIN
    (
        SELECT 
            f.store_id,
            f.supplier_id,
            d.year,
            d.month,
            SUM(f.purchase_amount) AS total_revenue
        FROM fact_sales f
        JOIN date_dim d ON f.date_id = d.date_id
        GROUP BY f.store_id, f.supplier_id, d.year, d.month
    ) AS prev
    ON curr.store_id = prev.store_id
    AND curr.supplier_id = prev.supplier_id
    AND (
        (curr.year = prev.year AND curr.month = prev.month + 1)
        OR (curr.year = prev.year + 1 AND curr.month = 1 AND prev.month = 12)
    )
JOIN store_dim s ON curr.store_id = s.store_id
JOIN supplier_dim sp ON curr.supplier_id = sp.supplier_id
ORDER BY
    curr.store_id,
    curr.supplier_id,
    curr.year,
    curr.month;
    
    
    
    
    
-- Q17: Yearly Revenue Trends by Store, Supplier, and Product with ROLLUP
SELECT
    d.year,
    COALESCE(s.store_name, 'All Stores') AS store_name,
    COALESCE(sup.supplier_name, 'All Suppliers') AS supplier_name,
    COALESCE(p.product_category, 'All Products') AS product_name,
    SUM(f.purchase_amount) AS total_revenue
FROM fact_sales f
JOIN store_dim s ON f.store_id = s.store_id
JOIN supplier_dim sup ON f.supplier_id = sup.supplier_id
JOIN product_dim p ON f.product_id = p.product_id
JOIN date_dim d ON f.date_id = d.date_id
GROUP BY d.year, s.store_name, sup.supplier_name, p.product_category WITH ROLLUP
ORDER BY
    d.year,
    store_name,
    supplier_name,
    product_name;


-- Q18:
-- Q18: Revenue and Volume-Based Sales Analysis for Each Product for H1 and H2

SELECT
    p.product_id,
    p.product_category AS product_name,
    SUM(CASE WHEN d.month BETWEEN 1 AND 6 THEN f.purchase_amount ELSE 0 END) AS H1_revenue,
    SUM(CASE WHEN d.month BETWEEN 7 AND 12 THEN f.purchase_amount ELSE 0 END) AS H2_revenue,
    SUM(f.purchase_amount) AS yearly_revenue,
    SUM(CASE WHEN d.month BETWEEN 1 AND 6 THEN f.quantity ELSE 0 END) AS H1_quantity,
    SUM(CASE WHEN d.month BETWEEN 7 AND 12 THEN f.quantity ELSE 0 END) AS H2_quantity,
    SUM(f.quantity) AS yearly_quantity
FROM fact_sales f
JOIN product_dim p ON f.product_id = p.product_id
JOIN date_dim d ON f.date_id = d.date_id
GROUP BY p.product_id, p.product_category
ORDER BY yearly_revenue DESC;



-- Q19: Identify High Revenue Spikes in Product Sales
SELECT
    p.product_id,
    p.product_category AS product_name,
    d.full_date,
    SUM(f.purchase_amount) AS daily_sales,
    ROUND(avg_sales.avg_daily_sales, 2) AS daily_average,
    CASE 
        WHEN SUM(f.purchase_amount) > 2 * avg_sales.avg_daily_sales THEN 'Spike'
        ELSE 'Normal'
    END AS status
FROM fact_sales f
JOIN product_dim p ON f.product_id = p.product_id
JOIN date_dim d ON f.date_id = d.date_id
-- Subquery to calculate average daily sales per product
JOIN (
    SELECT
        product_id,
        AVG(daily_total) AS avg_daily_sales
    FROM (
        SELECT
            product_id,
            date_id,
            SUM(purchase_amount) AS daily_total
        FROM fact_sales
        GROUP BY product_id, date_id
    ) AS daily_totals
    GROUP BY product_id
) AS avg_sales
ON f.product_id = avg_sales.product_id
GROUP BY p.product_id, p.product_category, d.full_date, avg_sales.avg_daily_sales
HAVING status = 'Spike'
ORDER BY daily_sales DESC;



-- Q20: Create a view for quarterly sales by store
CREATE OR REPLACE VIEW STORE_QUARTERLY_SALES AS
SELECT
    s.store_id,
    s.store_name,
    d.year,
    d.quarter,
    SUM(f.purchase_amount) AS total_quarterly_sales
FROM fact_sales f
JOIN store_dim s ON f.store_id = s.store_id
JOIN date_dim d ON f.date_id = d.date_id
GROUP BY
    s.store_id,
    s.store_name,
    d.year,
    d.quarter;
    
    
    -- Q20 Example :
    SELECT *
FROM STORE_QUARTERLY_SALES
ORDER BY store_name, year, quarter;

-- Q16:
-- Q16: Top 5 Products Purchased Together Across Multiple Orders
WITH order_products AS (
    -- Step 1: Get distinct products per order to avoid duplicates
    SELECT DISTINCT order_id, product_id
    FROM fact_sales
)

SELECT
    op1.product_id AS product_1,
    op2.product_id AS product_2,
    COUNT(*) AS times_bought_together
FROM order_products op1
JOIN order_products op2
    ON op1.order_id = op2.order_id
    AND op1.product_id < op2.product_id  -- avoids self-pairing & duplicate pairs
GROUP BY op1.product_id, op2.product_id
ORDER BY times_bought_together DESC
LIMIT 5;

