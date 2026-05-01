# Intel Sustainability Analytics

A SQL portfolio project analyzing a modeled Intel device repurposing dataset. The project evaluates how device type, device age, and region affect estimated energy savings and CO₂ reductions from Intel's 2024 device repurposing program.

> Completed through The Global Career Accelerator. The dataset is modeled to reflect the structure of Intel-related sustainability data, but it is synthetic. Results should be interpreted as illustrative rather than official Intel findings.

---

## Project Summary

This project uses PostgreSQL in DBeaver to validate, join, and analyze two device repurposing datasets.

The analysis focuses on three main questions:

1. How much energy and CO₂ did the repurposing program save overall?
2. Which device types, age groups, and regions contributed the most impact?
3. Where should repurposing efforts be prioritized to improve future environmental impact?

The raw CSV files and local PostgreSQL database are not included in this repository because of file size limitations. Instead, this repository includes the SQL workflow and exported aggregate analysis outputs.

---

## Key Findings

- The dataset includes **601,740 repurposed devices** from Intel's modeled 2024 repurposing program.
- The program saved an estimated **15,490,046.8 kWh** of energy and **6,768.42 metric tons of CO₂** in one year.
- Each repurposed device saved an average of **25.74 kWh** of energy per year.
- **Laptops produced about 68% of total energy and CO₂ savings** across each region, mainly because they made up most of the repurposed devices.
- **Older devices had much higher per-device savings** than newer devices. Older devices averaged **48.02 kWh** saved per device, compared to **19.07 kWh** for newer devices.
- **North America produced the highest total CO₂ savings** because it had the largest number of repurposed devices.
- **Asia had the highest average CO₂ savings per device**, which suggests that repurposing has stronger per-device carbon benefits in more carbon-intensive regions.

---

## Recommendation

Intel should maintain its high-volume laptop repurposing pipeline while increasing efforts to source more older laptops, especially in regions with higher per-device CO₂ savings such as Asia.

The current program's total impact is mostly driven by volume, especially mid-age and newer laptops. However, older devices produce stronger per-device energy and CO₂ savings. A better strategy would preserve the scale of the current program while gradually shifting more sourcing toward older, high-impact devices.

---

## Repository Structure

```text
intel-sustainability-analytics/
├── README.md
├── scripts/
│   ├── 01_Schema_Creation_Intel.sql
│   ├── 02_Validation_&_Cleanup_Intel.sql
│   └── 03_Analysis_Intel.sql
├── outputs/
│   ├── 03_overall_program_impact.csv
│   ├── 04_impact_by_device_type.csv
│   ├── 05_impact_by_age_bucket.csv
│   ├── 06_impact_by_region.csv
│   ├── 07_regional_device_type_contribution.csv
│   ├── 08_priority_segments.csv
│   └── 09_older_laptops_by_region.csv
└── visuals/
    └── dashboard_screenshots_or_charts.png
```

The `outputs/` folder contains exported aggregate result tables from DBeaver. These are small summary outputs, not the raw source data.

---

## Data Availability Note

The raw source CSV files and local PostgreSQL database are not included in this repository. They were used locally in DBeaver to run the analysis, but they are too large and not appropriate to share publicly as part of this portfolio repository.

Because of this, the project is not intended to be fully reproducible from raw data by cloning the repository alone. Instead, the repository is designed to show:

- The SQL schema structure
- The validation checks performed before analysis
- The analysis logic used to create the findings
- The exported aggregate outputs used to support the recommendation

---

## Data Model

The project uses two tables joined on `device_id`.

### `device_data`

| Column | Description |
|---|---|
| `device_id` | Unique identifier for each repurposed device |
| `device_type` | Device category, either `Laptop` or `Desktop` |
| `model_year` | Year the device was manufactured |

### `impact_data`

| Column | Description |
|---|---|
| `impact_id` | Unique identifier for each impact record |
| `device_id` | Device identifier used to join to `device_data` |
| `usage_purpose` | Repurposing use case |
| `power_consumption` | Device power consumption in watts |
| `energy_savings_yr` | Estimated annual energy savings in kWh |
| `co2_saved_kg_yr` | Estimated annual CO₂ savings in kilograms |
| `recycling_rate` | Percentage of the device that is recyclable |
| `region` | Region where the device was repurposed |

---

## SQL Workflow

### 1. Schema Creation

`scripts/01_Schema_Creation_Intel.sql` creates the two project tables:

- `device_data`
- `impact_data`

The script defines the main columns used in the analysis and assigns primary keys to the device and impact records.

### 2. Validation and Cleanup

`scripts/02_Validation_&_Cleanup_Intel.sql` checks that the loaded data is ready for analysis. Since the dataset is already clean, the script focuses on validation rather than major cleaning.

Validation checks include:

- Row counts after load
- Duplicate ID checks
- Missing value checks
- Join integrity checks
- Numeric range checks
- Invalid value checks
- Category checks for device type, region, and usage purpose
- Device age bucket validation

### 3. Analysis

`scripts/03_Analysis_Intel.sql` creates a reusable analysis view called:

```sql
vw_repurposed_devices_analysis
```

The view joins `device_data` and `impact_data`, then adds two derived fields:

```sql
2024 - model_year AS device_age
```

and

```sql
CASE
    WHEN 2024 - model_year <= 3 THEN 'newer'
    WHEN 2024 - model_year > 3 AND 2024 - model_year <= 6 THEN 'mid-age'
    ELSE 'older'
END AS device_age_bucket
```

The analysis then summarizes the data by:

- Overall program impact
- Device type
- Device age bucket
- Region
- Region and device type
- Region, device type, and age bucket
- Older laptops by region

---

## Analysis Outputs

| File | Description |
|---|---|
| `03_overall_program_impact.csv` | Overall device count, average device age, average energy savings, total energy savings, and total CO₂ saved |
| `04_impact_by_device_type.csv` | Compares laptops and desktops by volume, energy savings, and CO₂ savings |
| `05_impact_by_age_bucket.csv` | Compares newer, mid-age, and older devices |
| `06_impact_by_region.csv` | Compares sustainability impact across North America, Asia, and Europe |
| `07_regional_device_type_contribution.csv` | Shows each device type's share of regional energy and CO₂ savings |
| `08_priority_segments.csv` | Ranks region, device type, and age bucket combinations by total CO₂ savings |
| `09_older_laptops_by_region.csv` | Focuses on older laptops by region to support the final recommendation |

---

## Main Results

### Overall Program Impact

| Metric | Value |
|---|---:|
| Total devices repurposed | 601,740 |
| Average device age | 3.52 years |
| Average energy savings per device | 25.74 kWh |
| Total energy savings | 15,490,046.8 kWh |
| Total CO₂ saved | 6,768.42 metric tons |

### Impact by Device Type

| Device Type | Devices | Total Energy Savings | Total CO₂ Saved |
|---|---:|---:|---:|
| Laptop | 408,064 | 10,528,785.6 kWh | 4,601.10 metric tons |
| Desktop | 193,676 | 4,961,261.2 kWh | 2,167.32 metric tons |

Laptops contributed most of the total impact because they had much higher volume in the dataset.

### Impact by Age Bucket

| Age Bucket | Devices | Average Energy Savings | Total CO₂ Saved |
|---|---:|---:|---:|
| Newer | 317,191 | 19.07 kWh | 2,642.09 metric tons |
| Mid-age | 264,310 | 32.04 kWh | 3,701.19 metric tons |
| Older | 20,239 | 48.02 kWh | 425.14 metric tons |

Older devices had the highest average savings per device, but they contributed less total impact because there were far fewer of them.

### Impact by Region

| Region | Devices | Average CO₂ Saved per Device | Total CO₂ Saved |
|---|---:|---:|---:|
| North America | 299,478 | 0.0103 metric tons | 3,079.83 metric tons |
| Asia | 192,881 | 0.0155 metric tons | 2,984.48 metric tons |
| Europe | 109,381 | 0.0064 metric tons | 704.10 metric tons |

North America had the highest total CO₂ savings because it had the most devices. Asia had the highest average CO₂ savings per device.

---

## Important Interpretation

The highest current total-impact segments are not always the best future priority segments.

For example, `08_priority_segments.csv` shows that high-volume mid-age laptop groups rank highest by total CO₂ savings. This reflects the current distribution of the program. However, `05_impact_by_age_bucket.csv` shows that older devices save more energy and CO₂ per device.

This means the recommendation is not that older laptops currently produce the most total savings. Instead, the recommendation is that increasing the share of older laptops could improve future per-device impact while keeping the program focused on high-volume laptop repurposing.

---

## Tools Used

- **DBeaver** for database management, CSV import, query execution, and CSV export
- **PostgreSQL** for schema creation, validation, joins, views, CTEs, `CASE WHEN` logic, and aggregations
- **GitHub** for project documentation and version control

---

## Skills Demonstrated

- Relational schema creation
- Data validation before analysis
- Primary key and join checks
- Multi-table joins
- Reusable SQL views
- Derived columns
- `CASE WHEN` bucketing
- Grouped aggregations
- Regional percentage calculations using CTEs
- Exporting SQL outputs for documentation
- Translating SQL findings into business recommendations

---

## How to Review This Project

This repository is meant to document the SQL workflow and final analysis outputs, not to provide a fully reproducible raw-data pipeline.

To review the project:

1. Read `scripts/01_Schema_Creation_Intel.sql` to see the table structure.
2. Read `scripts/02_Validation_&_Cleanup_Intel.sql` to see the validation checks used before analysis.
3. Read `scripts/03_Analysis_Intel.sql` to see how the final metrics and segments were calculated.
4. Review the exported CSV files in the `outputs/` folder to see the final result tables.
5. Use the README findings to understand how the SQL outputs were translated into a business recommendation.

With access to the original source CSV files, the project could be reproduced locally by creating the tables, importing the data into DBeaver/PostgreSQL, running the validation script, and then running the analysis script.

---

## Next Steps

Possible future improvements include:

- Build a Power BI dashboard using `vw_repurposed_devices_analysis`
- Add dashboard screenshots to the `visuals/` folder
- Add a cost-effectiveness layer, such as CO₂ saved per dollar spent
- Compare high-volume segments against high-per-device-impact segments
- Create a short project write-up explaining the business recommendation in non-technical language
