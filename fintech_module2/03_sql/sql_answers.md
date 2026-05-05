1. Count Transactions by Status

-- count transactions by status
SELECT 
status, 
COUNT(*) AS transaction_count
FROM transactions_final
GROUP BY status;

Captured: 19  
Failed: 7  
Chargeback: 4  

Insight:
Most transactions are successfully completed. However, there are failed and chargeback transactions, indicating potential payment failures and fraud/dispute cases.

2. Total Captured GMV by Merchant

-- calculate total captured GMV by merchant
SELECT 
merchant_name, 
SUM(amount_usd) AS captured_GMV
FROM transactions_final
WHERE status = 'captured'
GROUP BY merchant_name
ORDER BY captured_GMV DESC;

Beta Stores: 33431  
Alpha Mart: 29984.5  
Delta Travels: 10300  
City Pharma: 8640  

Insight:
Beta Stores generates the highest revenue from successful transactions, followed by Alpha Mart. This helps identify top-performing merchants and revenue concentration.

3. Top 10 Merchants by Captured GMV

Query used to identify top revenue-generating merchants based on successful transactions.
SELECT *
FROM (
    SELECT merchant_name,
           SUM(amount_usd) AS captured_GMV
    FROM transactions_final
    WHERE status = 'captured'
    GROUP BY merchant_name
    ORDER BY captured_GMV DESC
)
WHERE ROWNUM <= 10;

Beta Stores    33431
Alpha Mart     29984.5
Delta Travels  10300
City Pharma    8640

Insight:
This helps identify key merchants contributing most to total revenue, enabling better business focus and partnership strategies.

4. Daily GMV and Successful Transactions

Calculated daily total GMV and number of successful transactions.

SELECT transaction_date,
SUM(amount_usd) AS daily_gmv,
COUNT(transaction_id) AS successful_transaction_count
FROM transactions_final
WHERE status = 'captured'
GROUP BY transaction_date
ORDER BY transaction_date;

Insight:
GMV varies across days, with the highest on 01-03-26 and lowest on 05-03-26. This indicates fluctuating transaction volumes and potential business trends.

5. Merchants with Chargeback Ratio > 1%

Query identifies merchants with high chargeback rates.

SELECT merchant_name,
COUNT(CASE WHEN status='chargeback' THEN 1 END) AS chargebacks,
COUNT(*) AS total_transactions,
ROUND((COUNT(CASE WHEN status='chargeback' THEN 1 END)*100.0/COUNT(*)),2) AS chargeback_ratio
FROM transactions_final
GROUP BY merchant_name
HAVING (COUNT(CASE WHEN status='chargeback' THEN 1 END)*100.0/COUNT(*))>1
ORDER BY chargeback_ratio DESC;

Insight:
Merchants with chargeback ratio above 1% may indicate higher fraud risk or customer disputes. These merchants require closer monitoring and potential intervention.

6. Find regions with average risk score above 50 and more than 20 transactions

## Regions with High Risk (Avg Risk > 50 & Transactions > 5)
(Since more than 20 gives no records)

SELECT gateway_region,
AVG(risk_score) AS avg_risk_score,
COUNT(transaction_id) AS transaction_count
FROM transactions_final
GROUP BY gateway_region
HAVING AVG(risk_score)>50 AND COUNT(transaction_id)>5;

APAC:
- Avg Risk Score: ~67.5
- Transactions: 13

UNKNOWN:
- Avg Risk Score: ~55.2
- Transactions: 9

Insight:
APAC shows the highest risk with significant transaction volume, indicating potential fraud exposure. UNKNOWN region also shows elevated risk, highlighting possible data quality or classification issues.

7. Find users with 3 or more failed or chargeback transactions on the same day

SELECT user_id,
       transaction_date,
       COUNT(*) AS risky_transactions
FROM transactions_final
WHERE status IN ('failed', 'chargeback')
GROUP BY user_id, transaction_date
HAVING COUNT(*) >= 3
ORDER BY risky_transactions DESC;

Query identifies users with multiple risky transactions in a single day.

Insight:
Users with 3 or more failed or chargeback transactions in a day may indicate fraudulent behavior such as card testing or repeated payment failures.

8. Show chargeback count, unique affected users, and chargeback amount by merchant

SELECT merchant_name,
COUNT(CASE WHEN status='chargeback' THEN 1 END) AS chargeback_count,
COUNT(DISTINCT CASE WHEN status='chargeback' THEN user_id END) AS unique_users_affected,
SUM(CASE WHEN status='chargeback' THEN amount_usd ELSE 0 END) AS total_chargeback_amount
FROM transactions_final
GROUP BY merchant_name;

- Each merchant except City Pharma has 1 chargeback
- Eco Home has the highest chargeback amount (6649 USD)
- City Pharma shows no chargebacks, indicating lower risk

Insight:
This analysis helps identify merchants with financial loss due to disputes and potential fraud exposure.