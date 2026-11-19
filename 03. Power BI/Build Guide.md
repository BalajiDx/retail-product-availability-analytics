# Power BI Build Guide

Steps to rebuild the report in Power BI Desktop from this repo. The `.pbix` itself is not included; save yours as
`03. Power BI/File/Retail_Product_Availability.pbix` once built. The images in `Dashboard Images/` show the target layout.

## 1. Load the data
1. **Home > Get data > Text/CSV**, and load these files from `01. Dataset/Cleaned Dataset/`:
   - `Clean_Products.csv` -> rename the query to `Products`
   - `Clean_Depots.csv` -> rename the query to `Depots`
   - `Clean_PriceHistory.csv` -> rename the query to `PriceHistory`
   - `Clean_WeeklyStockSales.csv` -> rename the query to `WeeklyStockSales`
2. In Power Query set types: dates to **Date**, money and rates to **Decimal number**, counts to **Whole number**, IDs to **Text**.
3. **Pricing rule:** only Active price rows are used. The cleaned PriceHistory already excludes Inactive rows; if you load the raw file, filter `TransactionStatus = "Active"` in Power Query before anything else.
4. Optional: add **row-level security** on `Depots[DepotName]` so each depot manager sees only their depot.

## 2. Model
Create these relationships (single direction, filter flows from the "1" side):

| From (1) | To (*) |
|---|---|
| Products[SKU] | WeeklyStockSales[SKU] |
| Products[SKU] | PriceHistory[SKU] |
| Depots[DepotID] | WeeklyStockSales[DepotID] |
| Calendar[Date] | WeeklyStockSales[WeekStart] |

Mark `Calendar` as the date table.

## 3. Add DAX
From `DAX/Measures.dax`, in order: the `Calendar` table, calculated columns (set **Sort by column** on band columns),
then measures in a dedicated `_Measures` table with display folders (Availability, Sales, Stock).

## 4. Pages
| Page | Image | Visuals |
|---|---|---|
| 1. Availability Overview | `1.Availability_Overview.png` | KPI cards, availability and demand-lost bars by depot, weekly line, category column |
| 2. Sales & Pricing | `2.Sales_Pricing.png` | Price KPIs, revenue by category, brand-mix table, worst-availability product table |
| 3. Stock Health | `3.Stock_Health.png` | Matrix with colour scale (lost value depot x category), weeks-of-cover bands, ranging gaps |
| Model | `4.Data_Model.png` | Relationships to build in Model view |

## 5. Check your numbers
With no slicers applied the report should show:
- Availability % ≈ 97.2%; Demand Lost % ≈ 7.4%
- Total Revenue ≈ ₹135.8 Cr; Lost Sales Value ≈ ₹11.1 Cr
- Madurai has the lowest Availability % (93.5%)

The full set of reference results is in `02. SQL Scripts/Query Results/`. Anything different means a relationship or a data type is wrong.

## 6. Optional: Power BI Service
Publish to a workspace, set **scheduled refresh** (a gateway is needed for on-premises sources), add **row-level security**
under Modeling > Manage roles, and use a **deployment pipeline** to move the report from Development to Test to Production.
