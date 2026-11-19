-- 08_Lost_Sales_Depot_Category.sql
-- Question : Where is lost-sales value concentrated (depot x category)?
-- Note     : Pivot with conditional aggregation.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

WITH priced AS (
    SELECT w.*, ph.Price, w.UnitsSold * ph.Price AS Revenue, w.LostUnits * ph.Price AS LostValue
    FROM WeeklyStockSales w
    JOIN PriceHistory ph ON ph.SKU = w.SKU AND w.WeekStart BETWEEN ph.EffectiveFrom AND ph.EffectiveTo
)
SELECT d.DepotName,
       ROUND(SUM(CASE WHEN pr.Category = 'Fresh Produce' THEN p.LostValue END) / 100000.0, 2) AS fresh_produce,
       ROUND(SUM(CASE WHEN pr.Category = 'Frozen'        THEN p.LostValue END) / 100000.0, 2) AS frozen,
       ROUND(SUM(CASE WHEN pr.Category = 'Dairy'         THEN p.LostValue END) / 100000.0, 2) AS dairy,
       ROUND(SUM(CASE WHEN pr.Category = 'Grocery'       THEN p.LostValue END) / 100000.0, 2) AS grocery,
       ROUND(SUM(CASE WHEN pr.Category = 'Beverages'     THEN p.LostValue END) / 100000.0, 2) AS beverages,
       ROUND(SUM(CASE WHEN pr.Category = 'Bakery'        THEN p.LostValue END) / 100000.0, 2) AS bakery,
       ROUND(SUM(CASE WHEN pr.Category = 'Household'     THEN p.LostValue END) / 100000.0, 2) AS household,
       ROUND(SUM(CASE WHEN pr.Category = 'Personal Care' THEN p.LostValue END) / 100000.0, 2) AS personal_care,
       ROUND(SUM(p.LostValue) / 100000.0, 2) AS total_lakh
FROM priced p JOIN Products pr ON pr.SKU = p.SKU JOIN Depots d ON d.DepotID = p.DepotID
GROUP BY d.DepotID ORDER BY total_lakh DESC;
