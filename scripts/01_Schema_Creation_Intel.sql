--=====================================================
--SCHEMA CREATION 
--=====================================================

CREATE TABLE intel.device_data (
    device_id TEXT PRIMARY KEY,
    device_type TEXT NOT NULL,
    model_year INT NOT NULL
);

CREATE TABLE intel.impact_data (
    impact_id TEXT PRIMARY KEY,
    device_id TEXT NOT NULL,
    usage_purpose TEXT,
    power_consumption INT,
    energy_savings_yr NUMERIC,
    co2_saved_kg_yr NUMERIC,
    recycling_rate NUMERIC,
    region TEXT
);
