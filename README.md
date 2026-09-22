# 📊 Online Retail Executive Data Analytics & Dashboard

An end-to-end data analytics project featuring ETL pipeline in Python, data modeling, SQL ground-truth metric validation, and an executive-level interactive Power BI dashboard.



## 🎯 Executive Summary & Key Metrics

This project analyzes over **530k+** raw transaction records from a UK-based online retail store. Through data cleaning, feature engineering, and rigorous SQL validation, the following core business metrics were established:

* 💰 **Total Revenue (Total Sales):** `$10,666,684.54` (~$10.67M)
* 🛒 **Total Orders:** `19,960`
* 👥 **Unique Customers:** `4,339`
* 💳 **Average Order Value (Average Ticket Size):** `$534.40`

---

## 🛠️ Tech Stack & Methodology

| Stage | Tool / Technology | Purpose |
| :--- | :--- | :--- |
| **Data Extraction & Cleaning** | Python (Pandas) | UTF-8 BOM removal, handling missing Customer IDs, filtering returns/invalid transactions. |
| **ETL & Database Storage** | SQLAlchemy & MySQL | Automated pipeline streaming cleaned CSV into local MySQL database. |
| **Data Validation & Analytics** | MySQL | 15+ analytical queries (CTEs, Window Functions, Grouping) verifying metric integrity. |
| **Executive Dashboarding** | Power BI | UI/UX dashboard design using DAX measures and custom card formatting. |

---

## 🔍 SQL Data Validation (Ground Truth)

To eliminate visual/aggregation errors in Power BI, core metrics were validated against the MySQL database using the following query:

```sql
SELECT 
    ROUND(SUM(TotalAmount), 2) AS Total_Revenue,
    COUNT(DISTINCT InvoiceNo) AS Total_Orders,
    COUNT(DISTINCT CustomerID) AS Total_Customers,
    ROUND(SUM(TotalAmount) / COUNT(DISTINCT InvoiceNo), 2) AS Average_Order_Value
FROM online_retail;
