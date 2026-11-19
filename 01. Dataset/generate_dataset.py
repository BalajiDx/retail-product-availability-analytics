"""
Generate the SYNTHETIC raw dataset for the Retail Product & Availability Analytics project.

A grocery retailer supplies its stores from 6 depots. Weekly stock and sales are recorded per depot and product
for 2024 (52 weeks). Prices are kept as a history with a transaction status (Active / Inactive).
All data is randomly generated (seed 31) for learning. No real company data is used. Amounts in INR.

Run:  python generate_dataset.py
Output: ./Raw Dataset/{Products,Depots,PriceHistory,WeeklyStockSales}.csv
(The raw files deliberately contain data-quality problems that clean_dataset.py fixes.)
"""
import os
import numpy as np
import pandas as pd

rng = np.random.default_rng(31)
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "Raw Dataset")
os.makedirs(OUT, exist_ok=True)

# ---------------------------------------------------------------- products
cats = {"Fresh Produce": (20, 180, 9.0), "Dairy": (25, 120, 7.5), "Bakery": (30, 90, 6.0), "Frozen": (90, 450, 2.5),
        "Grocery": (40, 400, 4.0), "Beverages": (25, 220, 4.5), "Household": (60, 500, 2.0), "Personal Care": (50, 450, 1.8)}
rows, sku = [], 1
for cat, (lo, hi, vel) in cats.items():
    for _ in range(int(rng.integers(26, 40))):
        status = "Delisted" if rng.random() < 0.09 else "Active"
        rows.append({"SKU": f"P{sku:04d}", "ProductName": f"{cat} item {sku:04d}", "Category": cat,
                     "Brand": rng.choice(["Own Label", "National Brand", "Regional Brand"], p=[0.35, 0.45, 0.2]),
                     "PackSize": rng.choice(["Small", "Medium", "Large"]), "Status": status,
                     "DelistWeek": int(rng.integers(10, 45)) if status == "Delisted" else "",
                     "BaseVelocity": round(float(rng.gamma(2, vel / 2)), 2), "BasePrice": round(float(rng.uniform(lo, hi)), 0)})
        sku += 1
prod = pd.DataFrame(rows)

depots = pd.DataFrame({"DepotID": [f"D{i}" for i in range(1, 7)],
                       "DepotName": ["Chennai North", "Chennai South", "Coimbatore", "Madurai", "Trichy", "Bengaluru"],
                       "Region": ["Tamil Nadu North", "Tamil Nadu North", "Tamil Nadu West", "Tamil Nadu South", "Tamil Nadu South", "Karnataka"],
                       "StoresServed": [42, 38, 26, 22, 18, 30]})
depot_reliab = dict(zip(depots.DepotID, [0.94, 0.92, 0.89, 0.78, 0.85, 0.91]))   # hidden: Madurai is weakest
depot_scale = dict(zip(depots.DepotID, depots.StoresServed / 30))

# ------------------------------------------------------------ price history
ph, pid = [], 1
for p in prod.itertuples():
    price = p.BasePrice
    start = pd.Timestamp("2023-10-01")
    changes = sorted(rng.choice(range(1, 52), int(rng.integers(0, 4)), replace=False))
    points = [start] + [pd.Timestamp("2024-01-01") + pd.Timedelta(weeks=int(w)) for w in changes]
    for i, eff in enumerate(points):
        if i:
            price = round(price * (1 + rng.choice([-1, 1], p=[0.25, 0.75]) * rng.uniform(0.03, 0.12)), 0)
        end = points[i + 1] - pd.Timedelta(days=1) if i + 1 < len(points) else pd.Timestamp("2099-12-31")
        ph.append({"PriceID": pid, "SKU": p.SKU, "EffectiveFrom": eff.strftime("%Y-%m-%d"), "EffectiveTo": end.strftime("%Y-%m-%d"),
                   "Price": price, "TransactionStatus": "Active"})
        pid += 1
        # a cancelled / draft price entry that must be ignored
        if rng.random() < 0.12:
            ph.append({"PriceID": pid, "SKU": p.SKU, "EffectiveFrom": eff.strftime("%Y-%m-%d"), "EffectiveTo": end.strftime("%Y-%m-%d"),
                       "Price": round(price * rng.uniform(0.5, 1.6), 0), "TransactionStatus": "Inactive"})
            pid += 1
ph = pd.DataFrame(ph)
act = ph[ph.TransactionStatus == "Active"]

# ------------------------------------------------------- weekly stock & sales
weeks = pd.date_range("2024-01-01", periods=52, freq="W-MON")
season = {"Beverages": lambda w: 1 + 0.35 * np.exp(-((w - 16) / 6) ** 2), "Frozen": lambda w: 1 + 0.25 * np.exp(-((w - 18) / 6) ** 2)}
recs = []
for p in prod.itertuples():
    prices = act[act.SKU == p.SKU]
    for d in depots.DepotID:
        if rng.random() < 0.08:            # product not ranged in this depot
            continue
        rel = depot_reliab[d] - (0.06 if p.Category in ("Fresh Produce", "Frozen") else 0)
        stock = int(p.BaseVelocity * depot_scale[d] * 30 * rng.uniform(1.5, 3))
        for w, ws in enumerate(weeks, start=1):
            if p.Status == "Delisted" and w > p.DelistWeek + 3:
                break
            pr = prices[(prices.EffectiveFrom <= ws.strftime("%Y-%m-%d")) & (prices.EffectiveTo >= ws.strftime("%Y-%m-%d"))].Price.iloc[0]
            el = (p.BasePrice / pr) ** 1.6
            dem = rng.poisson(p.BaseVelocity * depot_scale[d] * 30 * el * season.get(p.Category, lambda w: 1)(w)
                              * (0.25 if p.Status == "Delisted" and w > p.DelistWeek else 1))   # delisted: stores stop ordering
            sold = min(dem, stock)
            stock -= sold
            delivered = 0
            if p.Status == "Active" or w <= p.DelistWeek:
                if rng.random() < rel:
                    target = int(p.BaseVelocity * depot_scale[d] * 30 * rng.uniform(1.0, 1.9))
                    delivered = max(0, target - stock)
                elif rng.random() < 0.5:
                    delivered = 0
            stock += delivered
            recs.append({"WeekStart": ws.strftime("%Y-%m-%d"), "DepotID": d, "SKU": p.SKU, "UnitsDelivered": delivered,
                         "UnitsSold": sold, "DemandUnits": dem, "ClosingStock": stock})
fs = pd.DataFrame(recs)

# ----------------------------------------------- deliberate data-quality issues
fs = pd.concat([fs, fs.sample(220, random_state=1)], ignore_index=True)                         # duplicate rows
i = rng.choice(len(fs), 90, replace=False)
fs.loc[i, "ClosingStock"] = -fs.loc[i, "ClosingStock"].clip(lower=1)                            # negative stock (system error)
j = rng.choice(len(fs), 150, replace=False)
fs.loc[j, "DepotID"] = fs.loc[j, "DepotID"].str.lower() + " "                                  # 'd3 '
k = rng.choice(len(prod), 8, replace=False)
prod.loc[k, "Category"] = prod.loc[k, "Category"].str.upper()                                  # inconsistent case

prod.drop(columns=["BaseVelocity"]).to_csv(os.path.join(OUT, "Products.csv"), index=False)
depots.to_csv(os.path.join(OUT, "Depots.csv"), index=False)
ph.to_csv(os.path.join(OUT, "PriceHistory.csv"), index=False)
fs.to_csv(os.path.join(OUT, "WeeklyStockSales.csv"), index=False)
print(f"products {len(prod)}  depots {len(depots)}  price rows {len(ph)}  weekly rows {len(fs):,}")
