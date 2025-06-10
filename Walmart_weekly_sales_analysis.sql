 📘 Introduction
This project takes the structure of Question → Query → Insight

Question - A clear business or analytical question framed to uncover
trends, performance or hidden patterns in the data.

Query - The actual SQL code written to answer the question.

Insight - Presents the outcome of the query, what the data reveals
and why it matters.
*/

The columns in the table are thus: 
1.Store number
2. openingweek: Sales week end date
3. weeklysales: Sales value
4. holidaystatus: Mark on the presence or absence of a holiday
5. temperaturefh: Air temperature in the region
6. fuelprice: Fuel cost in the region
7. CPI: Consumer price index
8. unemploymentrate: Unemployment rate

ANALYSIS 

/* 1a. Which store outperforms others, and why?
Why it matters: Identifies high-performing stores for benchmarking against others */

-- Based on total sales
SELECT storenumber, SUM(weeklysales) AS totalsales
FROM walmart_sales
GROUP BY storenumber
ORDER BY 2 DESC;

-- Result: Store 20  has the highest sales in the three year period.

-- Based on yearly sales
WITH storerank AS (
SELECT storenumber, 
EXTRACT(YEAR FROM openingweek) AS year,
SUM(weeklysales) AS totalsales,
RANK() OVER 
(PARTITION BY EXTRACT(YEAR FROM openingweek) 
ORDER BY SUM(weeklysales) DESC) AS sales_rank
FROM walmart_sales
GROUP BY storenumber, year
)

SELECT 
storenumber AS top_performers, 
year,
totalsales
FROM storerank
WHERE sales_rank = 1;

/* Result: Stores 14, 4, and 4 were the top performers in years 2010, 2011
and 2012 respectively */

/* Even though store 20 appears to be the highest performing store 
in the 3 year period, it did not rank highest on an annual basis. Then I dug deeper
to find out its annual rank and found it was consistently number 2. As 
seen below. 

Stores 20, 14, and 4 consistently lead in overall and annual sales performance. This 
sustained excellence strongly suggests shared underlying characteristics such as
store size, favorable locations, specific customer demographics, or operational efficiencies 
that contribute to their superior results. Further investigation into these commonalities
could reveal transferable best practices for optimizing performance across the entire chain.
*/

WITH storerank AS (
SELECT storenumber, 
EXTRACT(YEAR FROM openingweek) AS year,
SUM(weeklysales) AS totalsales,
RANK() OVER 
(PARTITION BY EXTRACT(YEAR FROM openingweek) 
ORDER BY SUM(weeklysales) DESC) AS sales_rank
FROM walmart_sales
GROUP BY storenumber, year
)

SELECT 
storenumber, 
year,
totalsales,
sales_rank
FROM storerank
WHERE sales_rank IN (1,2);

/* 1b. Which store consistently underperform and why? */

-- Based on total sales
SELECT storenumber, SUM(weeklysales) AS totalsales
FROM walmart_sales
GROUP BY storenumber
ORDER BY 2;

/* Store 33 had the lowest performance with $37K in sales.
That’s nearly $6K less than the next lowest store, which brought in $43K
*/

-- Based on yearly sales
WITH storerank AS (
SELECT storenumber, 
EXTRACT(YEAR FROM openingweek) AS year,
SUM(weeklysales) AS totalsales,
RANK() OVER 
(PARTITION BY EXTRACT(YEAR FROM openingweek) 
ORDER BY SUM(weeklysales) ) AS sales_rank
FROM walmart_sales
GROUP BY storenumber, year
)

SELECT 
storenumber AS under_performers, 
year,
totalsales
FROM storerank
WHERE sales_rank = 1;

/* Once again, Store 33 consistently underperformed in the three-year period 
compared to other stores. This recurring low performance suggests 
it may not be a strong revenue driver. However, the decision to keep it
running could be strategic, perhaps due to its location serving a niche
customer base, maintaining regional presence, or acting as a fulfillment
or convenience hub rather than a high-performing sales unit. */




/* 2. Which weeks have the highest sales in the 3 year period? 
Was it a holiday week? */

WITH weekly_rank AS (
SELECT DATE_PART('year', openingweek) AS year,
openingweek,
holidayflag,
EXTRACT(WEEK FROM openingweek) as week,
SUM(weeklysales) AS totalsales,
DENSE_RANK() OVER 
(PARTITION BY DATE_PART('year', openingweek)
ORDER BY SUM(weeklysales) DESC) AS week_rank
FROM walmart_sales
GROUP BY 1 , 2, 3
)

SELECT 
year,
week,
openingweek,
totalsales,
holidayflag,
week_rank
FROM weekly_rank 
WHERE week_rank  = 1;

/* Across the three-year period, the weeks with the highest sales didn’t
fall on public holidays. In both 2010 and 2011, the top-performing weeks were those leading
up to Christmas weeks without any public holidays.

In 2012, however, the highest weekly sales occurred during the week ending
April 6th, well ahead of the holiday season. This deviation is likely influenced by the fact that
that the latest data for 2012 only runs up to October 26th. As a result, December activity which
drove peak sales in previous years wasn't captured. Promotions, weather shifts, or regional
events may also be contributing factors.
*/


 -- 3. 🌡️ Is there a relationship between weekly temperature and sales performance?
 -- I used the correlation function to determine this relationship

SELECT
Corr(temperature_fh, weeklysales)
FROM walmart_sales

/* Insight: The correlation value is -0.064. This 
reflects a very weak relationship between weekly sales and temperature.

The negative sign means that as temperature increases, weekly sales
tend to very slightly decrease. However, the magnitude (close to 0)
means the relationship is not statistically strong, implying that temperature 
likely has little to no meaningful impact on sales in this dataset. 

- For more insight on temperature-sales relationship, I delved deeper by sectioniong the weeks
into seasons to see if there was any difference
- I also converted the FH to CELSIUS due to familiarity

*/

/*
SEASONS
Spring: March, April, May.
Summer: June, July, August.
Autumn (Fall): September, October, November.
Winter: December, January, February 
*/

WITH sales_with_season as (
SELECT 
openingweek,
weeklysales,
CASE 
WHEN EXTRACT(MONTH FROM openingweek ) IN (3, 4, 5) THEN 'Spring'
WHEN EXTRACT(MONTH FROM openingweek ) IN (6, 7, 8) THEN 'Summer'
WHEN EXTRACT(MONTH FROM openingweek ) IN (9, 10, 11) THEN 'Autumn'
WHEN EXTRACT(MONTH FROM openingweek ) IN (12, 1, 2) THEN 'Winter'
END AS season,
((temperature_fh - 32) * 5/9) AS celsius
FROM walmart_sales)

SELECT
season,
corr(celsius, weeklysales) AS seasonal_correlation
FROM sales_with_season
GROUP BY season
ORDER BY seasonal_correlation;

/* Insight: 

The results ranged from -0.0149 to -0.125, maintaining a consistently
negative correlation across all seasons. While still weak, the slightly
stronger inverse correlation in some seasons suggests that temperature
might play a marginally greater role at certain times of the year,
possibly due to seasonal buying behaviors or weather-related preferences.

However, across all seasons, the effect remains minimal, reinforcing the
idea that temperature alone isn't a key driver of sales in this dataset. */

-- 4. How do weeks with public holidays compare to regular weeks in terms of sales?

/* To assess the impact of holidays on sales, I focused on months that
contained both holiday and non-holiday weeks, allowing for a direct
comparison within the same time period. I excluded certain months that
were not consistently represented across the three years in the dataset,
in order to ensures fair comparison and reduce skew from irregular data. These months were 
February and September
*/

SELECT 
TO_CHAR(openingweek, 'Mon') AS Month,
ROUND(AVG(weeklysales) FILTER (WHERE holidayflag = 1), 0) AS avg_sales_on_holidays,
ROUND(AVG(weeklysales) FILTER (WHERE holidayflag = 0), 0) AS avg_sales_no_holidays
FROM walmart_sales
WHERE EXTRACT (MONTH FROM openingweek) BETWEEN 2 AND 10 
GROUP BY TO_CHAR( openingweek, 'Mon')
HAVING AVG(weeklysales) FILTER (WHERE holidayflag = 1) IS NOT NULL
ORDER BY MIN (EXTRACT (MONTH FROM openingweek));

/* Insight: The analysis reveals that weeks with public holidays tend to
have slightly higher average sales compared to regular weeks. While the
difference isn’t significant, it suggests that holiday weeks may subtly
boost consumer spending, possibly due to promotional events or increased
foot traffic. This pattern hints at the potential value of targeted
marketing or inventory planning around holidays.

-- 5. 📉 How does unemployment rate correlate with weekly sales over time?

/*unemploymentrate is reported on a monthly basis in the US,so I would sum
the sales and group by month and year*/


WITH monthly_unemployment_info AS (
SELECT 
    storenumber,
    EXTRACT(YEAR FROM openingweek) AS year,
    EXTRACT(MONTH FROM openingweek) AS month,
    AVG(unemploymentrate) AS avg_monthly_unemployment,
    SUM(weeklysales) AS total_monthly_sales
FROM 
    walmart_sales
GROUP BY 
    storenumber,
    EXTRACT(YEAR FROM openingweek),
    EXTRACT(MONTH FROM openingweek)
ORDER BY 
    storenumber, year, month
    
)

SELECT
     ROUND(corr(total_monthly_sales,avg_monthly_unemployment)
     :: numeric, 2) AS unemployment_sales_correlation
FROM
    monthly_unemployment_info;


/* Insight: Correlation between unemployment and sales is -0.10. 
This is another very weak negative correlation, suggesting that as 
unemployment increases, sales tend to decrease, but only slightly
and not strongly enough to imply a reliable pattern. 

Even though unemployment is not within Walmart’s control, understanding
its relationship with sales can help in:

1. Sales forecasting: During months of rising unemployment, the company
might anticipate flatter or declining sales and adjust marketing or
inventory strategies accordingly.

2. Localized strategies: If some stores are more sensitive to unemployment
changes, local pricing, promotions, or stock levels can be adjusted accordingly.

3. Economic risk assessment: Even weak signals help build broader economic
models for business continuity planning.*/

-- 6 : What is the relationship between inflation (CPI) and sales?

/* To answer this question, I first needed to calculate weekly inflation
rates using the CPI data provided. 

Additionaaly, since CPI is reported in arrears and it reflects price changes over time, 
I used the LAG window function to compare each week’s CPI with the previous week’s value. 
This allowed me to calculate the weekly inflation rate using the formula:
(Current CPI - Previous CPI) / Current CPI.

With the calculated weekly inflation rate, I then used the 
correlation function to determine whether there is a statistical
relationship between inflation and sales.

This approach helps account for short-term fluctuations and aligns the
timing of economic conditions (inflation) with consumer behavior
(sales performance). */ 

WITH inflation_data AS
(
SELECT
      storenumber,
      openingweek,
      weeklysales,
      cpi AS current_cpi,
LAG(cpi) OVER (ORDER BY storenumber, openingweek) AS previous_cpi
FROM walmart_sales
WHERE storenumber = 1
ORDER BY storenumber, openingweek)

SELECT ROUND(CAST(corr(inflation_rate, weeklysales) AS NUMERIC), 3) AS inflation_n_sales_correlation
FROM (
SELECT 
      storenumber,
      weeklysales,
      DATE_PART('month', openingweek) AS month,
      current_cpi,
      previous_cpi,
      ROUND((current_cpi - previous_cpi/ current_cpi), 3) AS inflation_rate
FROM 
     inflation_data) AS inflation_data1
    

/*Insight: The correlation between inflation rate  (measured as weekly changes in CPI)
and sales is 0.038, indicating virtually no relationship between the two
variables.

This near zero positive correlation suggests that weekly fluctuations in
inflation had minimal to no impact on consumer spending in this dataset.
In other words, changes in inflation  in the short term did not
meaningfully influence weekly sales performance. */

FINAL RECOMMENDATION
/*
Environmental and economic variables like temperature, inflation, and 
unemployment showed minimal influence on sales. Walmart should focus its
energy on what what has proven to work, optimizing what's not working, and
aligning sales strategies with seasonal behavior */

