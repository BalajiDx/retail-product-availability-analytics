-- 03_Weekly_Availability_Trend.sql
-- Question : How did availability move week by week through 2024?
-- Dialect  : SQLite (see 00_Create_Tables_And_Load.sql)

SELECT WeekStart,
       ROUND(100.0 * AVG(InStock), 2) AS availability_pct,
       ROUND(100.0 * SUM(LostUnits) / SUM(DemandUnits), 2) AS lost_demand_pct
FROM WeeklyStockSales GROUP BY WeekStart ORDER BY WeekStart;
