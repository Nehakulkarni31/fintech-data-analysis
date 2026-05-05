SELECT * FROM transactions_final;

-- 1.count transactions by status
SELECT 
status, 
COUNT(*) AS transaction_count
FROM transactions_final
GROUP BY status;

-- 2. calculate total captured GMV by merchant
SELECT 
merchant_name, 
SUM(amount_usd) AS captured_GMV
FROM transactions_final
WHERE status = 'captured'
GROUP BY merchant_name
ORDER BY captured_GMV DESC;

-- 3.Show top 10 merchants by captured GMV
SELECT merchant_name,
       SUM(amount_usd) AS captured_GMV
FROM transactions_final
WHERE status = 'captured'
GROUP BY merchant_name
ORDER BY captured_GMV DESC
FETCH FIRST 10 ROWS ONLY;

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

-- 4. show daily gmv and successful transaction count

SELECT transaction_date,
SUM(amount_usd) AS daily_gmv,
COUNT(transaction_id) AS successful_transaction_count
FROM transactions_final
WHERE status = 'captured'
GROUP BY transaction_date
ORDER BY transaction_date;

-- 5. Find merchants with chargeback ratio above 1%

SELECT merchant_name,
COUNT(CASE WHEN status='chargeback' THEN 1 END) AS chargebacks,
COUNT(*) AS total_transactions,
ROUND((COUNT(CASE WHEN status='chargeback' THEN 1 END)*100.0/COUNT(*)),2) AS chargeback_ratio
FROM transactions_final
GROUP BY merchant_name
HAVING (COUNT(CASE WHEN status='chargeback' THEN 1 END)*100.0/COUNT(*))>1
ORDER BY chargeback_ratio DESC;

-- 6. Find regions with average risk score above 50 and more than 20 transactions

SELECT gateway_region,
AVG(risk_score) AS avg_risk_score,
COUNT(transaction_id) AS transaction_count
FROM transactions_final
GROUP BY gateway_region
HAVING AVG(risk_score)>50 AND COUNT(transaction_id)>5;

-- 7. Find users with 3 or more failed or chargeback transactions on the same day
SELECT user_id,
       transaction_date,
       COUNT(*) AS risky_transactions
FROM transactions_final
WHERE status IN ('failed', 'chargeback')
GROUP BY user_id, transaction_date
HAVING COUNT(*) >= 3
ORDER BY risky_transactions DESC;

-- 8. Show chargeback count, unique affected users, and chargeback amount by merchant
SELECT merchant_name,
COUNT(CASE WHEN status='chargeback' THEN 1 END) AS chargeback_count,
COUNT(DISTINCT CASE WHEN status='chargeback' THEN user_id END) AS unique_users_affected,
SUM(CASE WHEN status='chargeback' THEN amount_usd ELSE 0 END) AS total_chargeback_amount
FROM transactions_final
GROUP BY merchant_name;

