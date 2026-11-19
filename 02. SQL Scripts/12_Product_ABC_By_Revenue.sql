-- 12_Product_ABC_By_Revenue.sql
-- Question : How is revenue spread across products (ABC classes)?
-- Note     : A = top 80% of revenue, B = next 15%, C = last 5%.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

WITH priced AS (
    SELECT w.*, ph.Price, w.UnitsSold * ph.Price AS Revenue, w.LostUnits * ph.Price AS LostValue
    FROM WeeklyStockSales w
    JOIN PriceHistory ph ON ph.SKU = w.SKU AND w.WeekStart BETWEEN ph.EffectiveFrom AND ph.EffectiveTo
), s AS (
    SELECT SKU, SUM(Revenue) AS rev FROM priced GROUP BY SKU
), c AS (
    SELECT SKU, rev, 100.0 * SUM(rev) OVER (ORDER BY rev DESC ROWS UNBOUNDED PRECEDING) / SUM(rev) OVER () AS cum_pct
    FROM s
), k AS (
    SELECT *, CASE WHEN cum_pct - 100.0 * rev / (SELECT SUM(rev) FROM s) < 80 THEN 'A'
                   WHEN cum_pct - 100.0 * rev / (SELECT SUM(rev) FROM s) < 95 THEN 'B' ELSE 'C' END AS abc
    FROM c
)
SELECT abc AS abc_class, COUNT(*) AS products,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM k), 1) AS share_of_products_pct,
       ROUND(SUM(rev) / 100000.0, 2) AS revenue_lakh,
       ROUND(100.0 * SUM(rev) / (SELECT SUM(rev) FROM s), 1) AS share_of_revenue_pct
FROM k GROUP BY abc ORDER BY abc;
