-- Create time_dim table
CREATE TABLE time_dim (
    time_id VARCHAR(50) PRIMARY KEY,
    accident_year INT,
    month_of_accident VARCHAR(20),
    time_of_day VARCHAR(20)
);

-- Create location_dim table
CREATE TABLE location_dim (
    location_id VARCHAR(20) PRIMARY KEY,
    local_authority_ons_district VARCHAR(20),
    urban_or_rural_area VARCHAR(20)
);

-- Create vehicle_dim table
CREATE TABLE vehicle_dim (
    vehicle_id VARCHAR(50) PRIMARY KEY,
    vehicle_reference INT,
    vehicle_type VARCHAR(50),
    sex_of_driver VARCHAR(20),
    age_band_of_driver VARCHAR(20)
);

-- Create casualty_dim table
CREATE TABLE casualty_dim (
    casualty_id VARCHAR(50) PRIMARY KEY,
    casualty_reference INT,
    casualty_type VARCHAR(50),
    sex_of_casualty VARCHAR(20),
    age_band_of_casualty VARCHAR(20),
    pedestrian_location VARCHAR(50),
    pedestrian_movement VARCHAR(50)
);

-- Create accidents_fact table
CREATE TABLE accidents_fact (
    accident_id VARCHAR(50) PRIMARY KEY,
    time_id VARCHAR(50),
    location_id VARCHAR(20),
    vehicle_id VARCHAR(50),
    casualty_id VARCHAR(50),
    accident_severity VARCHAR(20),
    casualty_severity VARCHAR(20),
    road_type VARCHAR(50),
    road_surface_conditions VARCHAR(50),
    weather_conditions VARCHAR(50),
    light_conditions VARCHAR(50),
    junction_detail VARCHAR(50),
    speed_limit INT,
    FOREIGN KEY (time_id) REFERENCES time_dim(time_id),
    FOREIGN KEY (location_id) REFERENCES location_dim(location_id),
    FOREIGN KEY (vehicle_id) REFERENCES vehicle_dim(vehicle_id),
    FOREIGN KEY (casualty_id) REFERENCES casualty_dim(casualty_id)
);

-- Add comments for documentation
COMMENT ON TABLE accidents_fact IS 'Fact table storing accident details with foreign keys to dimension tables';
COMMENT ON TABLE time_dim IS 'Dimension table for time-related attributes';
COMMENT ON TABLE location_dim IS 'Dimension table for location-related attributes';
COMMENT ON TABLE vehicle_dim IS 'Dimension table for vehicle-related attributes';
COMMENT ON TABLE casualty_dim IS 'Dimension table for casualty-related attributes';

-- Verify schema
SELECT table_schema, table_name, column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'london_accidents'
ORDER BY table_name, ordinal_position;