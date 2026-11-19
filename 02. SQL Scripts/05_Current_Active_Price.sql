-- 05_Current_Active_Price.sql
-- Question : What is the current selling price of each product, and how often did it change in 2024?
-- Note     : Uses Active price rows only (Inactive rows were removed in cleaning). Current = the row open on 31 Dec 2024.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

SELECT p.SKU, p.ProductName, p.Category, p.Status,
       cur.Price AS current_price,
       (SELECT COUNT(*) - 1 FROM PriceHistory x WHERE x.SKU = p.SKU) AS price_changes_2024,
       ROUND(100.0 * (cur.Price / first.Price - 1), 1) AS change_since_jan_pct
FROM Products p
JOIN PriceHistory cur   ON cur.SKU = p.SKU AND '2024-12-31' BETWEEN cur.EffectiveFrom AND cur.EffectiveTo
JOIN PriceHistory first ON first.SKU = p.SKU AND '2024-01-01' BETWEEN first.EffectiveFrom AND first.EffectiveTo
ORDER BY price_changes_2024 DESC, change_since_jan_pct DESC;
