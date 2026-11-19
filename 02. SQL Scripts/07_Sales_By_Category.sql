-- 07_Sales_By_Category.sql
-- Question : What are units, revenue and average selling price by category?
-- Note     : Revenue = units sold x Active price of that week.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

WITH priced AS (
    SELECT w.*, ph.Price, w.UnitsSold * ph.Price AS Revenue, w.LostUnits * ph.Price AS LostValue
    FROM WeeklyStockSales w
    JOIN PriceHistory ph ON ph.SKU = w.SKU AND w.WeekStart BETWEEN ph.EffectiveFrom AND ph.EffectiveTo
)
SELECT pr.Category,
       SUM(p.UnitsSold) AS units_sold,
       ROUND(SUM(p.Revenue) / 100000.0, 2) AS revenue_lakh,
       ROUND(100.0 * SUM(p.Revenue) / SUM(SUM(p.Revenue)) OVER (), 1) AS revenue_share_pct,
       ROUND(SUM(p.Revenue) / SUM(p.UnitsSold), 1) AS avg_selling_price
FROM priced p JOIN Products pr ON pr.SKU = p.SKU
GROUP BY pr.Category ORDER BY revenue_lakh DESC;
