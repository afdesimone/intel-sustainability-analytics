--=====================================================
--Validation and Clean Up
--=====================================================

/*
Project: Intel Sustainability Analytics
Purpose: Check that the loaded data is clean and ready for analysis.

Tables used:
    device_data
    impact_data

Note:
    The data was already very clean, so this script mainly checks
    row counts, missing values, joins, categories, and numeric ranges.
*/


--1. Checking row counts after load
--Expected output: impact_data should have 601,740 rows and device_data should have 539,579 rows.

SELECT
    'impact_data' AS table_name,
    COUNT(*) AS row_count
FROM impact_data

UNION ALL

SELECT
    'device_data' AS table_name,
    COUNT(*) AS row_count
FROM device_data;


--2. Checking for duplicate IDs
--Expected output: duplicate_ids should be 0 for both tables.

SELECT
    'device_data' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT device_id) AS unique_device_ids,
    COUNT(*) - COUNT(DISTINCT device_id) AS duplicate_ids
FROM device_data;

SELECT
    'impact_data' AS table_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT impact_id) AS unique_impact_ids,
    COUNT(*) - COUNT(DISTINCT impact_id) AS duplicate_ids
FROM impact_data;


--3. Checking for missing values in device_data
--Expected output: all missing value counts should be 0.

SELECT
    SUM(CASE WHEN device_id IS NULL THEN 1 ELSE 0 END) AS missing_device_id,
    SUM(CASE WHEN device_type IS NULL THEN 1 ELSE 0 END) AS missing_device_type,
    SUM(CASE WHEN model_year IS NULL THEN 1 ELSE 0 END) AS missing_model_year
FROM device_data;


--4. Checking for missing values in impact_data
--Expected output: all missing value counts should be 0.

SELECT
    SUM(CASE WHEN impact_id IS NULL THEN 1 ELSE 0 END) AS missing_impact_id,
    SUM(CASE WHEN device_id IS NULL THEN 1 ELSE 0 END) AS missing_device_id,
    SUM(CASE WHEN usage_purpose IS NULL THEN 1 ELSE 0 END) AS missing_usage_purpose,
    SUM(CASE WHEN power_consumption IS NULL THEN 1 ELSE 0 END) AS missing_power_consumption,
    SUM(CASE WHEN energy_savings_yr IS NULL THEN 1 ELSE 0 END) AS missing_energy_savings,
    SUM(CASE WHEN co2_saved_kg_yr IS NULL THEN 1 ELSE 0 END) AS missing_co2_savings,
    SUM(CASE WHEN recycling_rate IS NULL THEN 1 ELSE 0 END) AS missing_recycling_rate,
    SUM(CASE WHEN region IS NULL THEN 1 ELSE 0 END) AS missing_region
FROM impact_data;


--5. Join check
--This checks whether every impact record has a matching device record.
--Expected output: unmatched_impact_records should be 0.

SELECT
    COUNT(*) AS unmatched_impact_records
FROM impact_data AS i
LEFT JOIN device_data AS d
    ON i.device_id = d.device_id
WHERE d.device_id IS NULL;


--6. Reverse join check
--This checks whether any device records do not appear in the impact table.
--Expected output: devices_without_impact_records should be 0 or very low.

SELECT
    COUNT(*) AS devices_without_impact_records
FROM device_data AS d
LEFT JOIN impact_data AS i
    ON d.device_id = i.device_id
WHERE i.device_id IS NULL;


--7. Checking the final joined row count used for analysis
--Expected output: joined_row_count should match the analysis dataset size, 601,740 rows.

SELECT
    COUNT(*) AS joined_row_count
FROM device_data AS d
FULL OUTER JOIN impact_data AS i
    ON d.device_id = i.device_id;


--8. Checking numeric ranges for obvious outliers
--Expected output: values should be positive and within reasonable ranges.

SELECT
    MIN(power_consumption) AS min_power_consumption,
    MAX(power_consumption) AS max_power_consumption,
    AVG(power_consumption) AS avg_power_consumption,

    MIN(energy_savings_yr) AS min_energy_savings_yr,
    MAX(energy_savings_yr) AS max_energy_savings_yr,
    AVG(energy_savings_yr) AS avg_energy_savings_yr,

    MIN(co2_saved_kg_yr) AS min_co2_saved_kg_yr,
    MAX(co2_saved_kg_yr) AS max_co2_saved_kg_yr,
    AVG(co2_saved_kg_yr) AS avg_co2_saved_kg_yr,

    MIN(recycling_rate) AS min_recycling_rate,
    MAX(recycling_rate) AS max_recycling_rate,
    AVG(recycling_rate) AS avg_recycling_rate
FROM impact_data;


--9. Checking model year range
--Expected output: model years should be realistic and should not be greater than 2024.

SELECT
    MIN(model_year) AS oldest_model_year,
    MAX(model_year) AS newest_model_year,
    AVG(2024 - model_year) AS avg_device_age
FROM device_data;


--10. Checking for invalid numeric values
--Expected output: all invalid value counts should be 0.

SELECT
    SUM(CASE WHEN power_consumption <= 0 THEN 1 ELSE 0 END) AS invalid_power_consumption,
    SUM(CASE WHEN energy_savings_yr < 0 THEN 1 ELSE 0 END) AS invalid_energy_savings,
    SUM(CASE WHEN co2_saved_kg_yr < 0 THEN 1 ELSE 0 END) AS invalid_co2_savings,
    SUM(CASE WHEN recycling_rate < 0 OR recycling_rate > 100 THEN 1 ELSE 0 END) AS invalid_recycling_rate
FROM impact_data;


--11. Checking device type categories
--Expected output: device_type should only include Laptop and Desktop.

SELECT
    device_type,
    COUNT(*) AS row_count
FROM device_data
GROUP BY device_type
ORDER BY device_type;


--12. Checking region categories
--Expected output: region should only include Asia, Europe, and North America.

SELECT
    region,
    COUNT(*) AS row_count
FROM impact_data
GROUP BY region
ORDER BY region;


--13. Checking usage purpose categories
--Expected output: usage_purpose should show the expected repurposing categories with no unexpected blanks or labels.

SELECT
    usage_purpose,
    COUNT(*) AS row_count
FROM impact_data
GROUP BY usage_purpose
ORDER BY usage_purpose;


--14. Checking device age bucket logic
--Expected output: newer should have ages 0-3, mid-age should have ages 4-6, and older should have ages above 6.

SELECT
    CASE
        WHEN 2024 - model_year <= 3 THEN 'newer'
        WHEN 2024 - model_year > 3 AND 2024 - model_year <= 6 THEN 'mid-age'
        ELSE 'older'
    END AS device_age_bucket,
    COUNT(*) AS row_count,
    MIN(2024 - model_year) AS min_device_age,
    MAX(2024 - model_year) AS max_device_age,
    AVG(2024 - model_year) AS avg_device_age
FROM device_data
GROUP BY
    CASE
        WHEN 2024 - model_year <= 3 THEN 'newer'
        WHEN 2024 - model_year > 3 AND 2024 - model_year <= 6 THEN 'mid-age'
        ELSE 'older'
    END
ORDER BY avg_device_age;


--15. Final validation summary
--Expected output: totals should match the main analysis results used in the project.

SELECT
    COUNT(*) AS total_joined_records,
    AVG(energy_savings_yr) AS avg_energy_savings_kwh,
    SUM(energy_savings_yr) AS total_energy_savings_kwh,
    SUM(co2_saved_kg_yr) / 1000 AS total_co2_saved_metric_tons
FROM device_data AS d
FULL OUTER JOIN impact_data AS i
    ON d.device_id = i.device_id;