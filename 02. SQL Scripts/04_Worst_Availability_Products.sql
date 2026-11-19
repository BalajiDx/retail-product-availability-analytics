-- 04_Worst_Availability_Products.sql
-- Question : Which active products are most often out of stock?
-- Note     : Active products with 40+ ranged depot-weeks.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

SELECT w.SKU, p.ProductName, p.Category,
       COUNT(*) AS ranged_weeks,
       SUM(1 - w.InStock) AS out_of_stock_weeks,
       ROUND(100.0 * AVG(w.InStock), 1) AS availability_pct
FROM WeeklyStockSales w JOIN Products p ON p.SKU = w.SKU
WHERE p.Status = 'Active'
GROUP BY w.SKU HAVING COUNT(*) >= 40
ORDER BY availability_pct, out_of_stock_weeks DESC LIMIT 15;
