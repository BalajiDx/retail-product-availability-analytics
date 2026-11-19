-- 13_Brand_Mix.sql
-- Question : What share of revenue comes from own-label products in each category?
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

WITH priced AS (
    SELECT w.*, ph.Price, w.UnitsSold * ph.Price AS Revenue, w.LostUnits * ph.Price AS LostValue
    FROM WeeklyStockSales w
    JOIN PriceHistory ph ON ph.SKU = w.SKU AND w.WeekStart BETWEEN ph.EffectiveFrom AND ph.EffectiveTo
)
SELECT pr.Category,
       ROUND(100.0 * SUM(CASE WHEN pr.Brand = 'Own Label' THEN p.Revenue END) / SUM(p.Revenue), 1) AS own_label_pct,
       ROUND(100.0 * SUM(CASE WHEN pr.Brand = 'National Brand' THEN p.Revenue END) / SUM(p.Revenue), 1) AS national_pct,
       ROUND(100.0 * SUM(CASE WHEN pr.Brand = 'Regional Brand' THEN p.Revenue END) / SUM(p.Revenue), 1) AS regional_pct
FROM priced p JOIN Products pr ON pr.SKU = p.SKU
GROUP BY pr.Category ORDER BY own_label_pct DESC;
