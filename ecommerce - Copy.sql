drop table Ecommerce;

create table Ecommerce(
customer_id	varchar(50),
customer_first_name varchar(50),
customer_last_name varchar(50),
category_name varchar(50),
product_name text,
customer_segment varchar(50),
customer_city varchar(50),
customer_state varchar(50),
customer_country varchar(50),
customer_region varchar(50),
delivery_status varchar(50),
order_date date,
order_id varchar(50),
ship_date date,
shipping_type varchar(50),
days_for_shipment_scheduled int,
days_for_shipment_real int ,
order_item_discount double precision,
sales_per_order double precision,
order_quantity int,
profit_per_order double precision
);

select * from Ecommerce;


-- YTD Sales, PYTD Sales, YoY Sales growth
WITH 

max_2022 AS (
    SELECT MAX(order_date) AS max_date_2022
    FROM ecommerce
    WHERE EXTRACT(YEAR FROM order_date) = 2022
),

ytd_2022 AS (
    SELECT SUM(sales_per_order) AS ytd_sales_2022
    FROM ecommerce e, max_2022 m
    WHERE e.order_date >= date_trunc('year',m.max_date_2022)
      AND e.order_date <= m.max_date_2022
),

pytd_2021 AS (
    SELECT SUM(sales_per_order) AS pytd_sales_2021
    FROM ecommerce e, max_2022 m
    WHERE e.order_date >= date_trunc('year',m.max_date_2022)-INTERVAL '1 year'
      AND e.order_date <= (m.max_date_2022 - INTERVAL '1 year')
)

SELECT 
    y.ytd_sales_2022,
    p.pytd_sales_2021,round((((y.ytd_sales_2022-p.pytd_sales_2021)/p.pytd_sales_2021)*100)::numeric,2) || '%' as Growth_sales
FROM ytd_2022 y
JOIN pytd_2021 p ON true;



-- YTD Quantity, PYTD Quantity, YoY Quantity growth
WITH 
max_2022 AS (
    SELECT MAX(order_date) AS max_date_2022
    FROM ecommerce
    WHERE EXTRACT(YEAR FROM order_date) = 2022
),

ytd_2022 AS (
    SELECT SUM(order_quantity) AS ytd_quantity_2022
    FROM ecommerce e, max_2022 m
    WHERE e.order_date >= DATE '2022-01-01'
      AND e.order_date <= m.max_date_2022
),

pytd_2021 AS (
    SELECT SUM(order_quantity) AS pytd_quantity_2021
    FROM ecommerce e, max_2022 m
    WHERE e.order_date >= DATE '2021-01-01'
      AND e.order_date <= (m.max_date_2022 - INTERVAL '1 year')
)

SELECT 
    y.ytd_quantity_2022,
    p.pytd_quantity_2021,round(((y.ytd_quantity_2022-p.pytd_quantity_2021)*100.0/p.pytd_quantity_2021)::numeric,2) || '%' as Growth_sales
FROM ytd_2022 y
JOIN pytd_2021 p ON true;



--YTD Profit, PYTD Profit, YoY Profit growth
WITH 

max_2022 AS (
    SELECT MAX(order_date) AS max_date_2022
    FROM ecommerce
    WHERE EXTRACT(YEAR FROM order_date) = 2022
),

ytd_2022 AS (
    SELECT SUM(profit_per_order) AS ytd_profit_per_order_2022
    FROM ecommerce e, max_2022 m
    WHERE e.order_date >= DATE '2022-01-01'
      AND e.order_date <= m.max_date_2022
),

pytd_2021 AS (
    SELECT SUM(profit_per_order) AS pytd_profit_per_order_2021
    FROM ecommerce e, max_2022 m
    WHERE e.order_date >= DATE '2021-01-01'
      AND e.order_date <= (m.max_date_2022 - INTERVAL '1 year')
)

SELECT 
    y.ytd_profit_per_order_2022,
    p.pytd_profit_per_order_2021,
    ROUND(
        ((y.ytd_profit_per_order_2022 - p.pytd_profit_per_order_2021) * 100.0 / p.pytd_profit_per_order_2021)::numeric, 2
    ) || '%' AS growth_sales_pct
FROM ytd_2022 y
JOIN pytd_2021 p ON true;







---YTD Profit Margin, PYTD Profit Margin, YoY Profit Margin growth

WITH 

max_2022 AS (
    SELECT MAX(order_date) AS max_date_2022
    FROM ecommerce
    WHERE EXTRACT(YEAR FROM order_date) = 2022
),

ytd_2022 AS (
    SELECT round(((SUM(profit_per_order)/sum(sales_per_order))*100.0)::numeric,2) AS ytd_profit_Margin_2022
    FROM ecommerce e, max_2022 m
    WHERE e.order_date >= DATE '2022-01-01'
      AND e.order_date <= m.max_date_2022
),

pytd_2021 AS (
    SELECT round(((SUM(profit_per_order)/sum(sales_per_order))*100.0)::numeric,2) AS pytd_profit_Margin_2021
    FROM ecommerce e, max_2022 m
    WHERE e.order_date >= DATE '2021-01-01'
      AND e.order_date <= (m.max_date_2022 - INTERVAL '1 year')
)

SELECT 
    y.ytd_profit_Margin_2022,
    p.pytd_profit_Margin_2021, 
    ROUND(
        ((y.ytd_profit_Margin_2022 - p.pytd_profit_Margin_2021) * 100.0 / p.pytd_profit_Margin_2021)::numeric, 2
    ) || '%' AS growth_sales_pct
FROM ytd_2022 y
JOIN pytd_2021 p ON true;




--Sales By Category
WITH 

max_2022 AS (
    SELECT MAX(order_date) AS max_date_2022
    FROM ecommerce
    WHERE EXTRACT(YEAR FROM order_date) = 2022
),

ytd_2022 AS (
    SELECT 
        category_name,
        SUM(sales_per_order) AS ytd_sales_per_order_2022
    FROM ecommerce e, max_2022 m
    WHERE e.order_date >= DATE '2022-01-01'
      AND e.order_date <= m.max_date_2022
    GROUP BY category_name
),

pytd_2021 AS (
    SELECT 
        category_name,
        SUM(sales_per_order) AS pytd_sales_per_order_2021
    FROM ecommerce e, max_2022 m
    WHERE e.order_date >= DATE '2021-01-01'
      AND e.order_date <= (m.max_date_2022 - INTERVAL '1 year')
    GROUP BY category_name
)

SELECT 
    y.category_name,
    y.ytd_sales_per_order_2022,
    p.pytd_sales_per_order_2021,
    ROUND(
        ((y.ytd_sales_per_order_2022 - p.pytd_sales_per_order_2021) * 100.0 / p.pytd_sales_per_order_2021)::numeric, 2
    ) || '%' AS growth_sales_pct
FROM ytd_2022 y
JOIN pytd_2021 p 
    ON y.category_name = p.category_name
ORDER BY growth_sales_pct DESC;



--Sales By Region

WITH 
max_2022 AS (
    SELECT MAX(order_date) AS max_date_2022
    FROM ecommerce
    WHERE EXTRACT(YEAR FROM order_date) = 2022
),

ytd_2022 AS (
    SELECT customer_region, SUM(sales_per_order) AS ytd_sales_2022
    FROM ecommerce e, max_2022 m
    WHERE e.order_date >= date_trunc('year', m.max_date_2022)
      AND e.order_date <= m.max_date_2022
    GROUP BY customer_region
),

pytd_2021 AS (
    SELECT customer_region, SUM(sales_per_order) AS pytd_sales_2021
    FROM ecommerce e, max_2022 m
    WHERE e.order_date >= date_trunc('year', m.max_date_2022) - INTERVAL '1 year'
      AND e.order_date <= (m.max_date_2022 - INTERVAL '1 year')
    GROUP BY customer_region
)

SELECT 
    y.customer_region,
    y.ytd_sales_2022,
    p.pytd_sales_2021,
    ROUND(((y.ytd_sales_2022 - p.pytd_sales_2021) * 100.0 / p.pytd_sales_2021)::numeric, 2) || '%' AS growth_sales
FROM ytd_2022 y
JOIN pytd_2021 p 
    ON y.customer_region = p.customer_region
ORDER BY growth_sales DESC;


--Sales By Shipping_type
WITH 
max_2022 AS (
    SELECT MAX(order_date) AS max_date_2022
    FROM ecommerce
    WHERE EXTRACT(YEAR FROM order_date) = 2022
),

ytd_2022 AS (
    SELECT shipping_type, SUM(sales_per_order) AS ytd_sales_2022
    FROM ecommerce e, max_2022 m
    WHERE e.order_date >= date_trunc('year', m.max_date_2022)
      AND e.order_date <= m.max_date_2022
    GROUP BY shipping_type
),

pytd_2021 AS (
    SELECT shipping_type, SUM(sales_per_order) AS pytd_sales_2021
    FROM ecommerce e, max_2022 m
    WHERE e.order_date >= date_trunc('year', m.max_date_2022) - INTERVAL '1 year'
      AND e.order_date <= (m.max_date_2022 - INTERVAL '1 year')
    GROUP BY shipping_type
)

SELECT 
    y.shipping_type,
    y.ytd_sales_2022,
    p.pytd_sales_2021,
    ROUND(((y.ytd_sales_2022 - p.pytd_sales_2021) * 100.0 / p.pytd_sales_2021)::numeric, 2) || '%' AS growth_sales
FROM ytd_2022 y
JOIN pytd_2021 p 
    ON y.shipping_type = p.shipping_type
ORDER BY growth_sales DESC;



--Sales By Customer Segment
WITH 
max_2022 AS (
    SELECT MAX(order_date) AS max_date_2022
    FROM ecommerce
    WHERE EXTRACT(YEAR FROM order_date) = 2022
),

ytd_2022 AS (
    SELECT customer_segment, SUM(sales_per_order) AS ytd_sales_2022
    FROM ecommerce e, max_2022 m
    WHERE e.order_date >= date_trunc('year', m.max_date_2022)
      AND e.order_date <= m.max_date_2022
    GROUP BY customer_segment
),

pytd_2021 AS (
    SELECT customer_segment, SUM(sales_per_order) AS pytd_sales_2021
    FROM ecommerce e, max_2022 m
    WHERE e.order_date >= date_trunc('year', m.max_date_2022) - INTERVAL '1 year'
      AND e.order_date <= (m.max_date_2022 - INTERVAL '1 year')
    GROUP BY customer_segment
)

SELECT 
    y.customer_segment,
    y.ytd_sales_2022,
    p.pytd_sales_2021,
    ROUND(((y.ytd_sales_2022 - p.pytd_sales_2021) * 100.0 / p.pytd_sales_2021)::numeric, 2) || '%' AS growth_sales
FROM ytd_2022 y
JOIN pytd_2021 p 
    ON y.customer_segment = p.customer_segment
ORDER BY growth_sales DESC;












