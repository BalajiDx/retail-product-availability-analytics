# Data Dictionary

Synthetic data, seed 31. Amounts in INR. Weekly data for 2024 (weeks start on Monday).

## Products
| Column | Type | Description |
|---|---|---|
| SKU | Text (PK) | Product code |
| ProductName | Text | Generic name |
| Category | Text | 8 grocery categories |
| Brand | Text | Own Label / National Brand / Regional Brand |
| PackSize | Text | Small / Medium / Large |
| Status | Text | Active or Delisted |
| DelistWeek | Integer | Week of 2024 the product was delisted (blank if active) |
| BasePrice | Decimal | Reference price at the start of the period |

## Depots
| Column | Type | Description |
|---|---|---|
| DepotID | Text (PK) | D1 - D6 |
| DepotName | Text | City |
| Region | Text |  |
| StoresServed | Integer | Stores supplied by the depot |

## PriceHistory
| Column | Type | Description |
|---|---|---|
| PriceID | Integer (PK) |  |
| SKU | Text (FK) |  |
| EffectiveFrom / EffectiveTo | Date | Validity window; 2099-12-31 = still current |
| Price | Decimal | Shelf price per unit |
| TransactionStatus | Text | Raw file only. Active or Inactive (cancelled / draft). Cleaning keeps Active rows only |

## WeeklyStockSales
| Column | Type | Description |
|---|---|---|
| WeekStart | Date | Monday of the week |
| DepotID | Text (FK) |  |
| SKU | Text (FK) |  |
| UnitsDelivered | Integer | Units received from suppliers that week |
| UnitsSold | Integer | Units shipped to stores and sold |
| DemandUnits | Integer | Units the stores ordered |
| ClosingStock | Integer | Units on hand at the end of the week |
| InStock | Integer | Added in cleaning: 1 if ClosingStock > 0 |
| LostUnits | Integer | Added in cleaning: DemandUnits - UnitsSold |

The grain is one row per week, depot and product. A product with no rows in a depot is not ranged there.
