-- 06_Price_Change_Impact.sql
-- Question : What happens to unit sales in the 4 weeks after a price change?
-- Note     : Compares average weekly units sold (all depots) 4 weeks before vs 4 weeks after each 2024 price change.
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

WITH ch AS (
    SELECT cur.SKU, cur.EffectiveFrom AS change_date,
           CASE WHEN cur.Price > prev.Price THEN 'Price increase' ELSE 'Price decrease' END AS direction,
           100.0 * (cur.Price / prev.Price - 1) AS price_change_pct
    FROM PriceHistory cur
    JOIN PriceHistory prev ON prev.SKU = cur.SKU AND date(prev.EffectiveTo, '+1 day') = cur.EffectiveFrom
    WHERE cur.EffectiveFrom BETWEEN '2024-02-01' AND '2024-11-30'
), wk AS (
    SELECT SKU, WeekStart, SUM(UnitsSold) AS units FROM WeeklyStockSales GROUP BY SKU, WeekStart
), ba AS (
    SELECT ch.direction, ch.price_change_pct,
           AVG(CASE WHEN wk.WeekStart <  ch.change_date THEN wk.units END) AS before_units,
           AVG(CASE WHEN wk.WeekStart >= ch.change_date THEN wk.units END) AS after_units
    FROM ch JOIN wk ON wk.SKU = ch.SKU
     AND wk.WeekStart BETWEEN date(ch.change_date, '-28 days') AND date(ch.change_date, '+27 days')
    GROUP BY ch.SKU, ch.change_date
)
SELECT direction, COUNT(*) AS price_changes,
       ROUND(AVG(price_change_pct), 1) AS avg_price_change_pct,
       ROUND(AVG(100.0 * (after_units / before_units - 1)), 1) AS avg_units_change_pct
FROM ba WHERE before_units > 0 GROUP BY direction;
