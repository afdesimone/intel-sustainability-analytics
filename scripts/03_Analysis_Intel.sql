--=====================================================
--Analysis
--=====================================================

/* 
Project: Intel Sustainability Analytics
Purpose: Analyze Intel's modeled 2024 device repurposing data to evaluate
energy savings, CO2 reductions, and opportunities to improve repurposing strategy.

Tables used:
    device_data
    impact_data
*/


--1. Create a reusable analysis view

CREATE VIEW vw_repurposed_devices_analysis AS
SELECT
    d.device_id,
    d.device_type,
    d.model_year,
    i.impact_id,
    i.usage_purpose,
    i.power_consumption,
    i.energy_savings_yr,
    i.co2_saved_kg_yr,
    i.recycling_rate,
    i.region,
    2024 - d.model_year AS device_age,
    CASE
        WHEN 2024 - d.model_year <= 3 THEN 'newer'
        WHEN 2024 - d.model_year > 3 AND 2024 - d.model_year <= 6 THEN 'mid-age'
        ELSE 'older'
    END AS device_age_bucket
FROM device_data AS d
FULL OUTER JOIN impact_data AS i
    ON d.device_id = i.device_id;

--2. Preview joined and prepared data

SELECT *
FROM vw_repurposed_devices_analysis
ORDER BY model_year ASC
LIMIT 100;

--3. Overall program impact

SELECT
    COUNT(*) AS total_devices_repurposed,
    ROUND(AVG(device_age), 2) AS average_device_age,
    ROUND(AVG(energy_savings_yr), 2) AS average_energy_savings_kwh_per_device,
    ROUND(SUM(energy_savings_yr), 2) AS total_energy_savings_kwh,
    ROUND(SUM(co2_saved_kg_yr) / 1000, 2) AS total_co2_saved_metric_tons
FROM vw_repurposed_devices_analysis;

--4. Impact by device type

SELECT
    device_type,
    COUNT(*) AS total_devices_repurposed,
    ROUND(AVG(energy_savings_yr), 2) AS average_energy_savings_kwh,
    ROUND(SUM(energy_savings_yr), 2) AS total_energy_savings_kwh,
    ROUND(AVG(co2_saved_kg_yr) / 1000, 4) AS average_co2_saved_metric_tons,
    ROUND(SUM(co2_saved_kg_yr) / 1000, 2) AS total_co2_saved_metric_tons
FROM vw_repurposed_devices_analysis
GROUP BY device_type
ORDER BY total_co2_saved_metric_tons DESC;

--5. Impact by device age bucket

SELECT
    device_age_bucket,
    COUNT(*) AS total_devices_repurposed,
    ROUND(AVG(device_age), 2) AS average_device_age,
    ROUND(AVG(energy_savings_yr), 2) AS average_energy_savings_kwh,
    ROUND(SUM(energy_savings_yr), 2) AS total_energy_savings_kwh,
    ROUND(AVG(co2_saved_kg_yr) / 1000, 4) AS average_co2_saved_metric_tons,
    ROUND(SUM(co2_saved_kg_yr) / 1000, 2) AS total_co2_saved_metric_tons
FROM vw_repurposed_devices_analysis
GROUP BY device_age_bucket
ORDER BY average_device_age;

--6. Impact by region

SELECT
    region,
    COUNT(*) AS total_devices_repurposed,
    ROUND(AVG(energy_savings_yr), 2) AS average_energy_savings_kwh,
    ROUND(SUM(energy_savings_yr), 2) AS total_energy_savings_kwh,
    ROUND(AVG(co2_saved_kg_yr) / 1000, 4) AS average_co2_saved_metric_tons,
    ROUND(SUM(co2_saved_kg_yr) / 1000, 2) AS total_co2_saved_metric_tons
FROM vw_repurposed_devices_analysis
GROUP BY region
ORDER BY total_co2_saved_metric_tons DESC;

--7. Regional contribution by device type

WITH regional_totals AS (
    SELECT
        region,
        SUM(energy_savings_yr) AS total_region_energy_savings,
        SUM(co2_saved_kg_yr) AS total_region_co2_saved
    FROM vw_repurposed_devices_analysis
    GROUP BY region
)

SELECT
    a.region,
    a.device_type,
    COUNT(*) AS total_devices_repurposed,
    ROUND(SUM(a.energy_savings_yr), 2) AS total_energy_savings_kwh,
    ROUND(SUM(a.co2_saved_kg_yr) / 1000, 2) AS total_co2_saved_metric_tons,
    ROUND(SUM(a.energy_savings_yr) / rt.total_region_energy_savings * 100, 2) AS pct_of_regional_energy_savings,
    ROUND(SUM(a.co2_saved_kg_yr) / rt.total_region_co2_saved * 100, 2) AS pct_of_regional_co2_savings
FROM vw_repurposed_devices_analysis AS a
JOIN regional_totals AS rt
    ON a.region = rt.region
GROUP BY
    a.region,
    a.device_type,
    rt.total_region_energy_savings,
    rt.total_region_co2_saved
ORDER BY
    a.region,
    pct_of_regional_co2_savings DESC;

/*
   8. High-impact priority segments
   Purpose: Identify combinations of region, device type, and age bucket
   that produce the strongest sustainability impact.
*/

SELECT
    region,
    device_type,
    device_age_bucket,
    COUNT(*) AS total_devices_repurposed,
    ROUND(AVG(energy_savings_yr), 2) AS average_energy_savings_kwh,
    ROUND(SUM(energy_savings_yr), 2) AS total_energy_savings_kwh,
    ROUND(AVG(co2_saved_kg_yr) / 1000, 4) AS average_co2_saved_metric_tons,
    ROUND(SUM(co2_saved_kg_yr) / 1000, 2) AS total_co2_saved_metric_tons
FROM vw_repurposed_devices_analysis
GROUP BY
    region,
    device_type,
    device_age_bucket
ORDER BY
    total_co2_saved_metric_tons DESC;


/*
   9. Final recommendation support query
   Purpose: Focus on older laptops by region since the project found
   older devices have stronger per-device savings and laptops drive
   most regional impact.
*/

SELECT
    region,
    COUNT(*) AS older_laptops_repurposed,
    ROUND(AVG(energy_savings_yr), 2) AS average_energy_savings_kwh,
    ROUND(SUM(energy_savings_yr), 2) AS total_energy_savings_kwh,
    ROUND(SUM(co2_saved_kg_yr) / 1000, 2) AS total_co2_saved_metric_tons
FROM vw_repurposed_devices_analysis
WHERE device_type = 'Laptop'
  AND device_age_bucket = 'older'
GROUP BY region
ORDER BY total_co2_saved_metric_tons DESC;