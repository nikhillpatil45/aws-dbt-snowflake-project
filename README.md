# 🏔️ AWS dbt + Snowflake Airbnb Pipeline ❄️✨

A modern **data transformation pipeline** built using **dbt (data build tool)** and **Snowflake**, designed around the **Medallion Architecture** 🥉➡️🥈➡️🥇.

This project transforms raw Airbnb booking data into clean, analytics-ready marts for reporting and dashboards 📊.

---

## 🚀 Overview

This repository contains:

- 🧱 **Bronze → Silver → Gold** layered transformations
- ❄️ Snowflake for scalable compute
- 🧰 dbt for modular SQL transformations
- 🐍 Python tooling for environment + dependency management
- 🕰️ dbt Snapshots for **SCD Type 2 historical tracking**

---

## 🏗️ Technical Architecture

The pipeline follows a clean and linear flow:

> **Sources → Bronze → Silver → Gold → Snapshots / Marts**

Schemas and dbt layers are structured like this:

---

## 📥 1) Data Sources (`models/sources`)

Raw data is ingested from the Snowflake database:

- 🗄️ **Database:** `AIRBNB`
- 🧪 **Schema:** `staging`

### 📌 Source Tables
- `bookings`
- `hosts`
- `listings`

---

## 🥉 2) Bronze Layer (Staging) — `models/bronze`

This layer performs **initial ingestion + standardization**.

### ✅ Models
- `bronze_bookings`
- `bronze_hosts`
- `bronze_listings`

### ⚡ Materialization
- **Incremental tables**
- Filters new records using:

> Only records created after the **maximum existing date** are loaded  
to reduce Snowflake compute cost 💸

---

## 🥈 3) Silver Layer (Refinement) — `models/silver`

This layer applies:

- 🧼 data cleaning
- 🧠 business logic
- 🏷️ tagging and derived columns

### ✅ Models
- `silver_bookings`
- `silver_hosts`
- `silver_listings`

### 🔥 Key Transformations

#### 📌 Bookings
- Calculates `TOTAL_AMOUNT` using a reusable macro 🧮

#### 📌 Hosts
- Normalizes host names ✍️
- Derives `RESPONSE_RATE_QUALITY` based on response rate:
  - ⭐ Very Good
  - ✅ Good
  - ⚠️ Fair
  - ❌ Poor

#### 📌 Listings
- Segments pricing into categories using a macro:
  - 💸 low
  - 💰 medium
  - 💎 high

---

## 🥇 4) Gold Layer (Marts & Consumption) — `models/gold`

This layer produces final tables used directly by BI/reporting tools 📊.

### 🧾 One Big Table (OBT)
- `obt.sql`
- Joins all 3 silver models into a wide denormalized table:

✅ `silver_bookings`  
⬅️ left join `silver_listings` on `listing_id`  
⬅️ left join `silver_hosts` on `host_id`

> 📌 Grain = **bookings**

---

### 📦 Fact Table
- `fact.sql`
- Builds the main fact table by joining the OBT with dimensional logic.

---

### 🕰️ Slowly Changing Dimensions (SCD Type 2)
The project uses **dbt Snapshots** to track history over time.

#### 📌 Snapshots
- `dim_bookings`
- `dim_hosts`
- `dim_listings`

#### 🧠 Snapshot Strategy
- Uses **timestamp strategy**
- Stored in the **gold schema**
- Maintains **Type 2 history** (old versions preserved)

---

## 🧩 Logic Analysis

This project is designed with reusable, modular logic 🧠✨

### 🧱 Macro-Driven Logic
Instead of hardcoding SQL logic repeatedly, the project uses reusable macros:

- 🧮 `multiply.sql`
  - Handles revenue calculations
  - Supports precision control

- 🏷️ `tag.sql`
  - Dynamically assigns categories to numeric values  
    (example: pricing tiers)

---

### ⚡ Ephemeral Modeling
The project uses **ephemeral models**:

📁 `models/gold/ephemeral`

These models:
- act as temporary logical abstractions
- help feed snapshots
- avoid unnecessary physical tables ❌🗄️

---

### 🔗 Integration Logic
The core integration happens inside:

📌 `obt.sql`

Where:
- `bookings` is the main dataset (grain)
- joined with:
  - `listings` on `listing_id`
  - `hosts` on `host_id`

Result:
✅ a single comprehensive dataset ready for analytics 📊

---

## 🛠️ Infrastructure & Tooling

This project also uses modern Python + environment tooling 🐍⚙️

### ⚡ Dependency Management (uv)
- Uses `uv` for extremely fast Python package management 🚀
- `uv.lock` confirms dependencies such as:
  - `dbt-snowflake` (v1.11.1)
  - `sqlfmt`

---

### ☁️ AWS Integration
Presence of AWS SDK libraries indicates AWS readiness:

- `boto3`
- `botocore`

Likely used for:
- 🔐 S3 authentication
- 🧾 credential / secret handling
- cloud-based Snowflake access patterns

---

### ❄️ Snowflake Configuration
- dbt connection managed via `profiles.yml`
- Uses:
  - 👑 `accountadmin` role
  - 🏭 `COMPUTE_WH` warehouse
  - Development-focused execution setup

---

## 💼 Business Value (What You Can Answer)

This data model enables stakeholders to answer key Airbnb business questions:

### 💵 Revenue Performance
- How much revenue is generated per booking after cleaning & service fees?
- Powered by: `silver_bookings`

---

### ⭐ Host Quality Assurance
- What is the distribution of superhosts vs normal hosts?
- How does response rate quality affect booking volume?
- Powered by: `silver_hosts`

---

### 🏷️ Pricing Segmentation
- How does occupancy differ between low/medium/high priced listings?
- Enabled by: `price_per_night_tag` in `silver_listings`

---

### 🕰️ Historical Tracking
- How did listing details or host statuses change over time?
- Powered by: `dim_*` snapshots (SCD Type 2)

---

## ✅ Summary

This repository demonstrates a complete modern analytics pipeline:

- 🥉 Bronze = ingestion + standardization
- 🥈 Silver = business logic + cleaning
- 🥇 Gold = marts + consumption-ready models
- 🕰️ Snapshots = full historical tracking
- 🧠 Macros + ephemeral models = clean and reusable dbt design

---

