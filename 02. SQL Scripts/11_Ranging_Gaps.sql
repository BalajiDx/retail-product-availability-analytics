-- 11_Ranging_Gaps.sql
-- Question : Which active products are not stocked in every depot?
-- Note     : A product is ranged in a depot if it has any weekly row there.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

WITH r AS (SELECT DISTINCT SKU, DepotID FROM WeeklyStockSales)
SELECT p.Category,
       COUNT(DISTINCT p.SKU) AS active_products,
       SUM(CASE WHEN n.depots < (SELECT COUNT(*) FROM Depots) THEN 1 ELSE 0 END) AS products_with_gaps,
       SUM((SELECT COUNT(*) FROM Depots) - n.depots) AS missing_depot_listings
FROM Products p
JOIN (SELECT SKU, COUNT(*) AS depots FROM r GROUP BY SKU) n ON n.SKU = p.SKU
WHERE p.Status = 'Active'
GROUP BY p.Category ORDER BY missing_depot_listings DESC;
