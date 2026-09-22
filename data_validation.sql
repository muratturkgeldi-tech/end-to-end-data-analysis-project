-- =============================================================================
-- ONLINE RETAIL DATASET: SQL ANALYSIS & DATA VALIDATION PIPELINE
-- Database: retail_db | Table: online_retail
-- Author: Data Analytics Project
-- =============================================================================

USE retail_db;

-- -----------------------------------------------------------------------------
-- 1. EXECUTIVE DASHBOARD CORE METRICS (GROUND TRUTH VALIDATION)
-- -----------------------------------------------------------------------------

-- 1. Toplam Ciro, Sipariş, Müşteri ve Ortalama Sepet Tutarı (AOV)
SELECT 
    ROUND(SUM(TotalAmount), 2) AS Total_Revenue,
    COUNT(DISTINCT InvoiceNo) AS Total_Orders,
    COUNT(DISTINCT CustomerID) AS Total_Customers,
    ROUND(SUM(TotalAmount) / COUNT(DISTINCT InvoiceNo), 2) AS Average_Order_Value
FROM online_retail;

-- 2. Kayıtsız/Misafir Müşterilerin Toplam Cirodaki Payı
SELECT 
    CASE WHEN CustomerID = -1 THEN 'Guest Checkout' ELSE 'Registered Customer' END AS Customer_Type,
    COUNT(DISTINCT InvoiceNo) AS Order_Count,
    ROUND(SUM(TotalAmount), 2) AS Revenue
FROM online_retail
GROUP BY Customer_Type;


-- -----------------------------------------------------------------------------
-- 2. COĞRAFİ & PAZAR ANALİZLERİ (GEOGRAPHIC ANALYSIS)
-- -----------------------------------------------------------------------------

-- 3. Ülkelere Göre Ciro, Sipariş Sayısı ve Pazar Payı (%)
SELECT 
    Country,
    ROUND(SUM(TotalAmount), 2) AS Country_Revenue,
    COUNT(DISTINCT InvoiceNo) AS Order_Count,
    ROUND((SUM(TotalAmount) / (SELECT SUM(TotalAmount) FROM online_retail)) * 100, 2) AS Revenue_Share_Pct
FROM online_retail
GROUP BY Country
ORDER BY Country_Revenue DESC;

-- 4. İngiltere (UK) Dışındaki En Büyük 5 Pazar
SELECT 
    Country,
    ROUND(SUM(TotalAmount), 2) AS Country_Revenue
FROM online_retail
WHERE Country <> 'United Kingdom'
GROUP BY Country
ORDER BY Country_Revenue DESC
LIMIT 5;


-- -----------------------------------------------------------------------------
-- 3. ÜRÜN & PERFORMANS ANALİZLERİ (PRODUCT PERFORMANCE)
-- -----------------------------------------------------------------------------

-- 5. En Çok Ciro Getiren Top 10 Ürün
SELECT 
    StockCode,
    Description,
    SUM(Quantity) AS Total_Quantity_Sold,
    ROUND(SUM(TotalAmount), 2) AS Total_Revenue
FROM online_retail
GROUP BY StockCode, Description
ORDER BY Total_Revenue DESC
LIMIT 10;

-- 6. En Çok Satılan (Adet Bazlı) Top 10 Ürün
SELECT 
    StockCode,
    Description,
    SUM(Quantity) AS Total_Units_Sold
FROM online_retail
GROUP BY StockCode, Description
ORDER BY Total_Units_Sold DESC
LIMIT 10;

-- 7. Ortalama Birim Fiyatı En Yüksek Ürünler
SELECT 
    StockCode,
    Description,
    ROUND(AVG(UnitPrice), 2) AS Avg_Unit_Price
FROM online_retail
GROUP BY StockCode, Description
ORDER BY Avg_Unit_Price DESC
LIMIT 10;


-- -----------------------------------------------------------------------------
-- 4. ZAMAN SERİSİ & TREND ANALİZLERİ (TIME-SERIES TRENDS)
-- -----------------------------------------------------------------------------

-- 8. Aylık Ciro ve Sipariş Büyüme Trendi
SELECT 
    DATE_FORMAT(InvoiceDate, '%Y-%m') AS Year_Month,
    ROUND(SUM(TotalAmount), 2) AS Monthly_Revenue,
    COUNT(DISTINCT InvoiceNo) AS Monthly_Orders
FROM online_retail
GROUP BY Year_Month
ORDER BY Year_Month;

-- 9. Haftanın Günlerine Göre Satış Dağılımı
SELECT 
    DAYNAME(InvoiceDate) AS Day_Of_Week,
    COUNT(DISTINCT InvoiceNo) AS Total_Orders,
    ROUND(SUM(TotalAmount), 2) AS Total_Revenue
FROM online_retail
GROUP BY DAYNAME(InvoiceDate), DAYOFWEEK(InvoiceDate)
ORDER BY DAYOFWEEK(InvoiceDate);

-- 10. Günün Saatlerine Göre Sipariş Yoğunluğu (Peak Hours)
SELECT 
    HOUR(InvoiceDate) AS Hour_Of_Day,
    COUNT(DISTINCT InvoiceNo) AS Order_Volume,
    ROUND(SUM(TotalAmount), 2) AS Hourly_Revenue
FROM online_retail
GROUP BY HOUR(InvoiceDate)
ORDER BY Hour_Of_Day;


-- -----------------------------------------------------------------------------
-- 5. İLERİ SEVİYE ANALİTİK & MÜŞTERİ SEGMENTASYONU (ADVANCED ANALYTICS)
-- -----------------------------------------------------------------------------

-- 11. En Çok Harcama Yapan Top 10 Müşteri (VIP Customers)
SELECT 
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS Total_Orders,
    SUM(Quantity) AS Total_Items_Bought,
    ROUND(SUM(TotalAmount), 2) AS Total_Spent
FROM online_retail
WHERE CustomerID <> -1
GROUP BY CustomerID
ORDER BY Total_Spent DESC
LIMIT 10;

-- 12. Müşteri Başına Ortalama Sipariş Sıklığı (Purchase Frequency)
WITH Customer_Orders AS (
    SELECT 
        CustomerID,
        COUNT(DISTINCT InvoiceNo) AS Order_Count
    FROM online_retail
    WHERE CustomerID <> -1
    GROUP BY CustomerID
)
SELECT 
    ROUND(AVG(Order_Count), 2) AS Avg_Orders_Per_Customer,
    MAX(Order_Count) AS Max_Orders_By_Single_Customer
FROM Customer_Orders;

-- 13. Ciroya Göre Müşteri Segmentasyonu (CTE Kullanımı)
WITH Customer_Totals AS (
    SELECT 
        CustomerID,
        SUM(TotalAmount) AS Total_Spent
    FROM online_retail
    WHERE CustomerID <> -1
    GROUP BY CustomerID
)
SELECT 
    CASE 
        WHEN Total_Spent >= 5000 THEN '1. VIP (>= $5k)'
        WHEN Total_Spent BETWEEN 1000 AND 4999.99 THEN '2. High Value ($1k-$5k)'
        WHEN Total_Spent BETWEEN 250 AND 999.99 THEN '3. Medium Value ($250-$1k)'
        ELSE '4. Low Value (< $250)'
    END AS Customer_Segment,
    COUNT(CustomerID) AS Customer_Count,
    ROUND(SUM(Total_Spent), 2) AS Segment_Revenue
FROM Customer_Totals
GROUP BY Customer_Segment
ORDER BY Customer_Segment;

-- 14. Aydan Aya Satış Farkı (Window Function - LAG Kullanımı)
WITH Monthly_Sales AS (
    SELECT 
        DATE_FORMAT(InvoiceDate, '%Y-%m') AS Sales_Month,
        ROUND(SUM(TotalAmount), 2) AS Current_Month_Revenue
    FROM online_retail
    GROUP BY Sales_Month
)
SELECT 
    Sales_Month,
    Current_Month_Revenue,
    LAG(Current_Month_Revenue, 1) OVER (ORDER BY Sales_Month) AS Previous_Month_Revenue,
    ROUND(Current_Month_Revenue - LAG(Current_Month_Revenue, 1) OVER (ORDER BY Sales_Month), 2) AS MoM_Growth
FROM Monthly_Sales;

-- 15. Sepet Büyüklüğü Analizi (Sipariş Başına Düşen Ürün Kalemi)
WITH Order_Items AS (
    SELECT 
        InvoiceNo,
        COUNT(DISTINCT StockCode) AS Unique_Products_In_Order,
        SUM(Quantity) AS Total_Quantity_In_Order
    FROM online_retail
    GROUP BY InvoiceNo
)
SELECT 
    ROUND(AVG(Unique_Products_In_Order), 2) AS Avg_Unique_Items_Per_Order,
    ROUND(AVG(Total_Quantity_In_Order), 2) AS Avg_Total_Units_Per_Order
FROM Order_Items;