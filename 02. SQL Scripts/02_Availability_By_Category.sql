-- 02_Availability_By_Category.sql
-- Question : Which categories have the lowest availability?
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

WITH priced AS (
    SELECT w.*, ph.Price, w.UnitsSold * ph.Price AS Revenue, w.LostUnits * ph.Price AS LostValue
    FROM WeeklyStockSales w
    JOIN PriceHistory ph ON ph.SKU = w.SKU AND w.WeekStart BETWEEN ph.EffectiveFrom AND ph.EffectiveTo
)
SELECT pr.Category,
       ROUND(100.0 * AVG(p.InStock), 2) AS availability_pct,
       ROUND(100.0 * SUM(p.LostUnits) / SUM(p.DemandUnits), 2) AS lost_demand_pct,
       ROUND(SUM(p.LostValue) / 100000.0, 2) AS lost_sales_lakh
FROM priced p JOIN Products pr ON pr.SKU = p.SKU
GROUP BY pr.Category ORDER BY availability_pct;
