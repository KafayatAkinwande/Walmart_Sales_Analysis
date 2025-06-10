# 📊 Walmart Weekly Sales Driver Analysis

## **Problem Statement / Objective**

What drives Walmart’s weekly sales performance?

This analysis answers the above question by uncovering how external factors like inflation, unemployment, temperature, holidays, and seasonal trends
impact sales across Walmart stores over a 3-year period. 

The goal?
To identify actionable insights that can inform strategic decisions around store performance, seasonal readiness, and economic sensitivity.

## **Dataset Description**

This project analyzes Walmart weekly sales data spanning May 2, 2010 to October 26, 2012 sourced from [Kaggle](https://www.kaggle.com/datasets/mikhail1681/walmart-sales/data).

The columns in the dataset are thus: 
1. Store number
2. openingweek: Sales week end date
3. weeklysales: Sales
4. holidaystatus: Mark on the presence or absence of a holiday
5. temperaturefh: Air temperature in the region
6. fuelprice: Fuel cost in the region
7. CPI: Consumer price index
8. unemploymentrate: Unemployment rate

## **Approach / Methodology**

The analysis followed a simple and easy to follow structure:
_Question → Query → Insight_

- Question - A clear business or analytical question framed to uncover
trends, performance or hidden patterns in the data.

- Query - The actual SQL code written to answer the question.

- Insight - Presents the outcome of the query, what the data reveals
and why it matters.

🧩 I used PostgreSQL to run and optimize these queries

## **Key SQL Concepts Applied**
1. Window Functions (e.g., LAG, RANK)

2. Correlation Analysis

3. Common Table Expressions (CTEs)

4. Subqueries and Aggregations

5. Date Filtering and Case Logic

## 💡 Key Findings / Business Insights
#### 🏆 Top Stores

Stores 20, 14, and 4 consistently ranked among the top performers annually and overall. They likely benefit from strategic locations, favorable demographics, or efficient operations—making them strong benchmarks for others.

#### 📉 Underperformance

Store 33 repeatedly ranked the lowest across the three years. Its persistent underperformance calls for deeper investigation or potential repurposing, unless it serves a strategic geographic or operational role.

#### 🕒 Seasonality & Holidays Matter

Weeks leading up to Christmas (non-holiday weeks) showed the highest sales, highlighting the impact of seasonal shopping behavior. Holiday weeks also demonstrated slightly higher average sales, signaling an opportunity for targeted promotions and inventory optimization.

#### Economic Variables? Not So Much:

- Temperature: Weak negative correlation with sales (as temp ↑, sales ↓ slightly)

- Unemployment: Slight negative correlation (r = -0.10)

- Inflation (CPI): No real correlation (r = 0.038)

These signals suggest that while macro trends should be monitored, they do not significantly drive week-to-week fluctuations in sales performance.

## 📊 Dashboard Visualization
I built an interactive Tableau dashboard that used storytelling to drive informed decision-making. [Dashboad](https://public.tableau.com/app/profile/kafayat.afolake.akinwande/viz/Walmartsalesdashboard-2/WalmartSalesDashboard2)

## 🔗 Connect With Me
 LinkedIn – [Kafayat Akinwande](www.linkedin.com/in/kafayatakinwande)
 
 I am open to feedback, collaboration, or full-time data analyst opportunities!
