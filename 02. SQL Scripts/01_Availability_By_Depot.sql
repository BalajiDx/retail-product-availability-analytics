-- 01_Availability_By_Depot.sql
-- Question : What is on-shelf availability by depot, and how much demand was lost?
-- Note     : Availability = share of depot-product-weeks with closing stock > 0. Lost value uses the Active price of that week.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

WITH priced AS (
    SELECT w.*, ph.Price, w.UnitsSold * ph.Price AS Revenue, w.LostUnits * ph.Price AS LostValue
    FROM WeeklyStockSales w
    JOIN PriceHistory ph ON ph.SKU = w.SKU AND w.WeekStart BETWEEN ph.EffectiveFrom AND ph.EffectiveTo
)
SELECT d.DepotName, d.StoresServed,
       ROUND(100.0 * AVG(p.InStock), 2) AS availability_pct,
       ROUND(100.0 * SUM(p.LostUnits) / SUM(p.DemandUnits), 2) AS lost_demand_pct,
       ROUND(SUM(p.LostValue) / 100000.0, 2) AS lost_sales_lakh
FROM priced p JOIN Depots d ON d.DepotID = p.DepotID
GROUP BY d.DepotID ORDER BY availability_pct;
