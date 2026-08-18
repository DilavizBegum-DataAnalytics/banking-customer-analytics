select * from banking_transactions;

-- Top 10 Revenue per customer  
select Customer_ID, round(sum(Amount),2) as Revenue
from banking_transactions
group by Customer_ID
order by Revenue desc
limit 10;

-- Customer Segmentation by Age group
Select 
Case
when Age between 18 and 38 then '18-38'
when Age between 39 and 58 then '39-58'
when Age between 59 and 78 then '59-78'
end as Age_Group,
count(*) as Total_count
from banking_transactions
group by Age_Group
order by Total_count desc;

-- Customer Segmentation by account type
select Account_Type, count(*) as total_count
from banking_transactions
group by Account_Type
order by total_count desc;

-- Customer lifetime value pattern
-- Since we have more than 1000 customer to check, we catorgorize by account type and tranaction type
select Channel, round(avg(Amount)*count(Transaction_ID),2) as CLV
from banking_transactions
group by Channel
order by CLV desc;

-- Monthly Transaction Trend
Select  month(Transaction_Date) as Months, count(Transaction_ID) as Transaction_Trend, round(sum(Amount),2) as Transaction_Amount
from banking_transactions
group by month(Transaction_Date)
order by Transaction_Trend desc;
 
-- Profitable transaction type
select Transaction_Type, round(sum(Fees_Charged),2) as Total_fee_revenue
from banking_transactions
group by Transaction_Type
order by Total_fee_revenue desc;

-- Average Transaction Amount per customer
select  Gender, Round(avg(Amount),2) as Average_Transaction
from banking_transactions
group by Gender
order by Average_Transaction desc;

-- Peak Transaction in time pattern
select Year(Transaction_Date) as Years, Round(sum(Amount),2) as Transaction_Trend
from banking_transactions
group by Years
order by Transaction_Trend; 

-- Revenue vs Fees trend
select Year(Transaction_Date) as Years, round(sum(amount),2) as Revenue, round(sum(Fees_Charged),2) as Fees
from banking_transactions
group by Years
order by Revenue desc, Fees desc;

-- Low Profit customers
select Customer_ID, round(sum(Fees_Charged),2) as Profit
from banking_transactions
group by Customer_ID
order by Profit asc;

-- Customer segment providing high profit
select Channel,  round(sum(Fees_Charged),2) as Profit
from banking_transactions
group by Channel
order by Profit desc;

-- Declining activity of customers
WITH monthly_activity AS (
    SELECT
        Customer_ID,
        YEAR(Transaction_Date) AS yr,
        MONTH(Transaction_Date) AS mn,
        COUNT(Transaction_ID) AS total_transactions
    FROM banking_transactions
    GROUP BY customer_id, yr, mn
)

SELECT
    Customer_ID,
    yr,
    mn,
    total_transactions,
    LAG(total_transactions)
        OVER(
            PARTITION BY Customer_ID
            ORDER BY yr, mn
        ) AS prev_transactions,
        
    CASE
        WHEN total_transactions < LAG(total_transactions)
        OVER(
            PARTITION BY Customer_ID
            ORDER BY yr, mn
            )
         THEN 'Declining' ELSE 'Stable/Growing'
    END AS activity_status

FROM monthly_activity;

-- Unusual Amount transaction
With Ranking_transaction as (
select Customer_ID, Amount, Transaction_Date, row_number() over(partition by Customer_ID order by Amount desc) as rn
from banking_transactions
)
select Customer_ID, Amount, Transaction_Date,rn
from Ranking_Transaction
where rn=1;

select avg(Amount)*count(Transaction_ID)
from banking_transactions;

select Account_Type, Channel, round(sum(Amount),2) as Revenue
from banking_transactions
group by Account_Type, Channel
order by Revenue desc;