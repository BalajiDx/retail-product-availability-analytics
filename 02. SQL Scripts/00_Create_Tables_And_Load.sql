-- 00_Create_Tables_And_Load.sql
-- Purpose : Create the 4 retail tables and load the cleaned CSVs
-- Dialect : SQLite 3.32+ (run from the repo root:  sqlite3 project.db < "02. SQL Scripts/00_Create_Tables_And_Load.sql")
-- Data    : Synthetic data (generate_dataset.py, seed 31), cleaned by clean_dataset.py. PriceHistory holds Active prices only

DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Depots;
DROP TABLE IF EXISTS PriceHistory;
DROP TABLE IF EXISTS WeeklyStockSales;

CREATE TABLE Products (
    SKU TEXT PRIMARY KEY,
    ProductName TEXT,
    Category TEXT,
    Brand TEXT,
    PackSize TEXT,
    Status TEXT,
    DelistWeek INTEGER,
    BasePrice REAL
);
CREATE TABLE Depots (
    DepotID TEXT PRIMARY KEY,
    DepotName TEXT,
    Region TEXT,
    StoresServed INTEGER
);
CREATE TABLE PriceHistory (
    PriceID INTEGER PRIMARY KEY,
    SKU TEXT REFERENCES Products(SKU),
    EffectiveFrom TEXT,
    EffectiveTo TEXT,
    Price REAL
);
CREATE TABLE WeeklyStockSales (
    WeekStart TEXT,
    DepotID TEXT REFERENCES Depots(DepotID),
    SKU TEXT REFERENCES Products(SKU),
    UnitsDelivered INTEGER,
    UnitsSold INTEGER,
    DemandUnits INTEGER,
    ClosingStock INTEGER,
    InStock INTEGER,
    LostUnits INTEGER,
    PRIMARY KEY (WeekStart,
    DepotID,
    SKU)
);

.mode csv
.import --skip 1 "01. Dataset/Cleaned Dataset/Clean_Products.csv" Products
.import --skip 1 "01. Dataset/Cleaned Dataset/Clean_Depots.csv" Depots
.import --skip 1 "01. Dataset/Cleaned Dataset/Clean_PriceHistory.csv" PriceHistory
.import --skip 1 "01. Dataset/Cleaned Dataset/Clean_WeeklyStockSales.csv" WeeklyStockSales

-- SQL Server: load with BULK INSERT / the Import Flat File wizard; MySQL: LOAD DATA INFILE.
-- Date functions differ: strftime('%Y-%m', d) -> FORMAT(d,'yyyy-MM') (SQL Server) / DATE_FORMAT(d,'%Y-%m') (MySQL);
-- julianday(a) - julianday(b) -> DATEDIFF(day, b, a) / DATEDIFF(a, b).
