-- 10_Delisted_Products_Holding_Stock.sql
-- Question : Which delisted products were still sitting in depots in their last recorded week?
-- Note     : Stock that must be cleared or returned to the supplier.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

WITH last AS (
    SELECT w.DepotID, w.SKU, w.ClosingStock, w.WeekStart,
           ROW_NUMBER() OVER (PARTITION BY w.DepotID, w.SKU ORDER BY w.WeekStart DESC) AS rn
    FROM WeeklyStockSales w JOIN Products p ON p.SKU = w.SKU
    WHERE p.Status = 'Delisted'
)
SELECT p.SKU, p.ProductName, p.Category, p.DelistWeek,
       COUNT(*) AS depots_with_stock, SUM(l.ClosingStock) AS units_left, MAX(l.WeekStart) AS last_week
FROM last l JOIN Products p ON p.SKU = l.SKU
WHERE l.rn = 1 AND l.ClosingStock > 0
GROUP BY p.SKU ORDER BY units_left DESC;
