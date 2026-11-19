-- 09_Weeks_Of_Cover_Year_End.sql
-- Question : At year end, how many active product-depot lines are understocked or overstocked?
-- Note     : Weeks of cover = closing stock in the last week / average weekly sales over the last 8 weeks.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

WITH last8 AS (
    SELECT DepotID, SKU, AVG(UnitsSold) AS avg_weekly_sales
    FROM WeeklyStockSales WHERE WeekStart >= '2024-11-04' GROUP BY DepotID, SKU
), cover AS (
    SELECT w.DepotID, w.SKU, w.ClosingStock, l.avg_weekly_sales,
           CASE WHEN l.avg_weekly_sales = 0 THEN NULL ELSE w.ClosingStock / l.avg_weekly_sales END AS weeks_cover
    FROM WeeklyStockSales w
    JOIN last8 l ON l.DepotID = w.DepotID AND l.SKU = w.SKU
    JOIN Products p ON p.SKU = w.SKU
    WHERE w.WeekStart = (SELECT MAX(WeekStart) FROM WeeklyStockSales) AND p.Status = 'Active'
)
SELECT CASE WHEN weeks_cover IS NULL THEN '5. No sales'
            WHEN weeks_cover < 0.5 THEN '1. Under 0.5 weeks'
            WHEN weeks_cover < 1   THEN '2. 0.5-1 week'
            WHEN weeks_cover <= 3  THEN '3. 1-3 weeks (target)'
            ELSE '4. Over 3 weeks' END AS cover_band,
       COUNT(*) AS product_depot_lines,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS share_pct
FROM cover GROUP BY cover_band ORDER BY cover_band;
