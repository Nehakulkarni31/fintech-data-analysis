## Excel-Based Data Cleaning and Analysis Pipeline

---

## 1. Data Cleaning Steps

* Cleaned merchant names using `TRIM`, `CLEAN`, and `PROPER` to remove inconsistencies
* Standardized transaction status into: **captured, failed, chargeback**
* Cleaned `risk_score` by extracting numeric values from text (e.g., "score:62", "risk-83")
* Standardized `gateway_region` using `UPPER` and handled missing values as **"UNKNOWN"**
* Cleaned `currency` column using `TRIM` and `UPPER`

---

## 2. Standardization Rules

* **Merchant Names:** Proper case (e.g., *Alpha Mart*)
* **Status:** Only `captured`, `failed`, `chargeback`
* **Region:** APAC / EU / US / UNKNOWN
* **Risk Score:** Numeric values only

---

## 3. Lookup & Enrichment Logic

* Created a composite **lookup_key** using `transaction_date + currency`
* Used **INDEX + MATCH** to map exchange rates from `exchange_rates.csv`
* Converted all transaction amounts into USD using the mapped exchange rate

---

## 4. Key Metrics

* **Total Raw Rows:** 30
* **Total Cleaned Rows:** 30
* **Missing/Invalid Values Handled:** Yes (standardized or flagged as UNKNOWN)

---

## 5. Merchant Risk Summary (Pivot Table)

### Pivot Configuration:

* **Rows:** `merchant_name`
* **Values:**

  * Count of `transaction_id` → **total_transactions**
  * Sum of `high_risk_flag` → **total_high_risk_transactions**

### Pivot Results:

| Merchant Name | Total Transactions | High Risk Transactions |
| ------------- | ------------------ | ---------------------- |
| Alpha Mart    | 11                 | 2                      |
| Beta Stores   | 11                 | 5                      |
| City Pharma   | 2                  | 0                      |
| Delta Travels | 4                  | 1                      |
| Eco Home      | 2                  | 1                      |

---

## 6. Key Insights

* **Top Merchant by Transactions:** Alpha Mart & Beta Stores (11 each)
* **Highest Risk Merchant:** Beta Stores (5 high-risk transactions)
* **Lowest Risk Merchant:** City Pharma (0 high-risk transactions)
* **Top Region by GMV:** APAC
* **High Value Transactions:** 6 (based on region-specific thresholds)
* **High Risk Transactions:** 9 (risk_score ≥ 70 OR chargeback)

---

## 7. Business Interpretation

* **Beta Stores** shows both high transaction volume and high risk, indicating potential fraud exposure
* **Alpha Mart** demonstrates stable performance with moderate risk
* **City Pharma** represents low-risk transactions, indicating safer operations
* Other merchants fall into moderate performance categories

This analysis helps:

* Identify high-value merchants
* Detect risk-prone transactions
* Support fraud monitoring and decision-making

---

## 8. Formula Samples

* **Currency Conversion:**

  ```
  =raw_amount * exchange_rate
  ```

  (Exchange rate obtained using INDEX-MATCH on lookup_key)

* **High Value Flag:**

  ```
  =IF(AND(region="APAC",amount_usd>5000),1,
     IF(AND(region="EU",amount_usd>6000),1,
     IF(AND(region="US",amount_usd>7000),1,0)))
  ```

* **High Risk Flag:**

  ```
  =IF(OR(risk_score>=70, status="chargeback"),1,0)
  ```

---

## 9. Reproducibility

All transformations were performed using Excel formulas without manual edits, ensuring a fully reproducible and auditable data pipeline.
