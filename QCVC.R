library(dplyr)
library(lubridate)
library(readr)
library(validate)
library(stringr)

# Define variable code mappings as named vectors for labeling
accident_severity_codes <- c("1" = "Fatal", "2" = "Serious", "3" = "Slight")
casualty_severity_codes <- accident_severity_codes
vehicle_type_codes <- c("1" = "Pedal cycle", "2" = "Motorcycle 50cc and under", 
                        "3" = "Motorcycle over 50cc and up to 125cc", "4" = "Motorcycle over 125cc and up to 500cc",
                        "5" = "Motorcycle over 500cc", "8" = "Taxi/Private hire car", "9" = "Car",
                        "10" = "Minibus (8-16 passenger seats)", "11" = "Bus or coach (17 or more passenger seats)",
                        "16" = "Ridden horse", "17" = "Agricultural vehicle", "18" = "Tram/Light rail",
                        "19" = "Van/Goods vehicle 3.5 tonnes mgw and under", 
                        "20" = "Goods vehicle over 3.5 tonnes and under 7.5 tonnes mgw",
                        "21" = "Goods vehicle 7.5 tonnes mgw and over", "22" = "Mobility scooter",
                        "23" = "Electric motorcycle", "33" = "Personal Powered Transporter",
                        "90" = "Other vehicle", "97" = "Motorcycle - cc unknown", 
                        "98" = "Goods vehicle - unknown weight")
road_type_codes <- c("1" = "Roundabout", "2" = "One way street", "3" = "Dual carriageway",
                     "6" = "Single carriageway", "7" = "Slip road", "9" = "Unknown")
road_surface_conditions_codes <- c("1" = "Dry", "2" = "Wet/Damp", "3" = "Snow",
                                   "4" = "Frost/Ice", "5" = "Flood", "9" = "Unknown")
weather_conditions_codes <- c("1" = "Fine without high winds", "2" = "Raining without high winds",
                              "3" = "Snowing without high winds", "4" = "Fine with high winds",
                              "5" = "Raining with high winds", "6" = "Snowing with high winds",
                              "7" = "Fog or mist - if hazard", "8" = "Other", "9" = "Unknown")
light_conditions_codes <- c("1" = "Daylight", "4" = "Darkness: street lights present and lit",
                            "5" = "Darkness: street lights present but unlit", 
                            "6" = "Darkness: no street lighting", "7" = "Darkness: street lighting unknown")
junction_detail_codes <- c("0" = "Not at junction", "1" = "Roundabout", "2" = "Mini-roundabout",
                           "3" = "T or staggered junction", "5" = "Slip road", "6" = "Crossroads",
                           "7" = "More than 4 arms (not roundabout)", "8" = "Private drive or entrance",
                           "9" = "Other junction")
pedestrian_location_codes <- c("1" = "Crossing on pedestrian crossing", 
                               "2" = "Crossing in zig-zag approach", "3" = "Crossing in zig-zag exit",
                               "4" = "Crossing within 50m of crossing", "5" = "Crossing elsewhere",
                               "6" = "On footway or verge", "7" = "On refuge/central island",
                               "8" = "In centre of carriageway", "9" = "In carriageway, not crossing",
                               "10" = "Unknown or other")
pedestrian_movement_codes <- c("1" = "Crossing from nearside", 
                               "2" = "Crossing from nearside - masked", 
                               "3" = "Crossing from offside", "4" = "Crossing from offside - masked",
                               "5" = "Stationary in carriageway", 
                               "6" = "Stationary in carriageway - masked",
                               "7" = "Walking facing traffic", "8" = "Walking back to traffic",
                               "9" = "Unknown or other")
casualty_type_codes <- c("0" = "Pedestrian", "1" = "Cyclist", 
                         "2" = "Motorcycle 50cc and under rider/passenger",
                         "3" = "Motorcycle over 50cc to 125cc rider/passenger",
                         "4" = "Motorcycle over 125cc to 500cc rider/passenger",
                         "5" = "Motorcycle over 500cc rider/passenger", 
                         "8" = "Taxi/Private hire car occupant", "9" = "Car occupant",
                         "10" = "Minibus occupant", "11" = "Bus or coach occupant",
                         "16" = "Horse rider", "17" = "Agricultural vehicle occupant",
                         "18" = "Tram occupant", "19" = "Van/Goods vehicle occupant",
                         "20" = "Goods vehicle 3.5-7.5 tonnes occupant",
                         "21" = "Goods vehicle over 7.5 tonnes occupant",
                         "22" = "Mobility scooter rider", "23" = "Electric motorcycle rider/passenger",
                         "90" = "Other vehicle occupant", "97" = "Motorcycle - unknown cc",
                         "98" = "Goods vehicle - unknown weight")
sex_codes <- c("1" = "Male", "2" = "Female", "3" = "Not known")
age_band_codes <- c("1" = "0-5", "2" = "6-10", "3" = "11-15", "4" = "16-20",
                    "5" = "21-25", "6" = "26-35", "7" = "36-45", "8" = "46-55",
                    "9" = "56-65", "10" = "66-75", "11" = "Over 75")
urban_rural_codes <- c("1" = "Urban", "2" = "Rural", "3" = "Unallocated")
speed_limit_codes <- c("20" = "20 mph", "30" = "30 mph", "40" = "40 mph",
                       "50" = "50 mph", "60" = "60 mph", "70" = "70 mph")
day_of_week_codes <- c("1" = "Sunday", "2" = "Monday", "3" = "Tuesday", "4" = "Wednesday",
                       "5" = "Thursday", "6" = "Friday", "7" = "Saturday")
ped_crossing_human_codes <- c("0" = "None within 50m", "1" = "School crossing patrol",
                              "2" = "Other authorised person")
ped_crossing_facilities_codes <- c("0" = "No facilities within 50m", "1" = "Zebra",
                                   "4" = "Pelican/puffin/toucan crossing",
                                   "5" = "Pedestrian phase at signal",
                                   "7" = "Footbridge or subway", "8" = "Central refuge")
carriageway_hazards_codes <- c("0" = "None", "1" = "Vehicle load", "2" = "Other object",
                               "3" = "Previous accident", "6" = "Roadworks", 
                               "7" = "Parked vehicle", "8" = "Bridge (roof)",
                               "9" = "Bridge (side)")
special_conditions_codes <- c("0" = "None", "1" = "Auto signal out", 
                              "2" = "Auto signal defective", 
                              "3" = "Sign/marking defective", "4" = "Roadworks",
                              "5" = "Road slippery", "6" = "Mud", "7" = "Oil or diesel",
                              "9" = "Unknown")
junction_control_codes <- c("-1" = "Data missing", "0" = "Not at junction",
                            "1" = "Authorised person", "2" = "Auto traffic signal",
                            "3" = "Stop sign", "4" = "Give way or uncontrolled",
                            "9" = "Unknown")
road_class_codes <- c("1" = "Motorway", "2" = "A(M)", "3" = "A", "4" = "B", 
                      "5" = "C", "6" = "Unclassified")
second_road_class_codes <- c("-1" = "Not at junction", "3" = "A", "4" = "B",
                             "5" = "C", "6" = "Unclassified")
casualty_class_codes <- c("1" = "Driver or rider", "2" = "Passenger", "3" = "Pedestrian")
car_passenger_codes <- c("0" = "Not car passenger", "1" = "Front seat", 
                         "2" = "Rear seat", "9" = "Unknown")
bus_passenger_codes <- c("0" = "Not bus passenger", "1" = "Boarding", 
                         "2" = "Alighting", "3" = "Standing", 
                         "4" = "Seated", "9" = "Unknown")
ped_road_worker_codes <- c("0" = "No/Not applicable", "1" = "Yes", "2" = "Not known")
vehicle_manoeuvre_codes <- c("1" = "Reversing", "2" = "Parked", "3" = "Waiting to go",
                             "4" = "Slowing/stopping", "5" = "Moving off", 
                             "6" = "U-turn", "7" = "Turning left",
                             "8" = "Waiting to turn left", "9" = "Turning right",
                             "10" = "Waiting to turn right", "11" = "Changing lane left",
                             "12" = "Changing lane right", "13" = "Overtaking offside",
                             "14" = "Overtaking stationary offside", 
                             "15" = "Overtaking nearside", "16" = "Going ahead left bend",
                             "17" = "Going ahead right bend", "18" = "Going ahead other",
                             "19" = "Unknown")
towing_codes <- c("0" = "No towing", "1" = "Articulated vehicle", 
                  "2" = "Double/multiple trailer", "3" = "Caravan", 
                  "4" = "Single trailer", "5" = "Other tow", "9" = "Unknown")
skidding_codes <- c("0" = "No skidding/overturning", "1" = "Jackknifed",
                    "2" = "Jackknifed and overturned", "3" = "Skidded",
                    "4" = "Skidded and overturned", "5" = "Overturned",
                    "9" = "Unknown")
hit_object_in_codes <- c("0" = "None", "1" = "Previous accident", "2" = "Road work",
                         "4" = "Parked vehicle", "5" = "Bridge (roof)",
                         "6" = "Bridge (side)", "7" = "Bollard or refuge",
                         "8" = "Open door", "9" = "Central island",
                         "10" = "Kerb", "11" = "Other object", 
                         "12" = "Animal (except horse)")
hit_object_off_codes <- c("0" = "None", "1" = "Road sign/traffic signal",
                          "2" = "Lamp post", "3" = "Telegraph/electricity pole",
                          "4" = "Tree", "5" = "Bus stop/shelter", 
                          "6" = "Central crash barrier", "7" = "Near/Offside crash barrier",
                          "8" = "Submerged in water", "9" = "Entered ditch",
                          "10" = "Other permanent object", "11" = "Wall or fence")
impact_point_codes <- c("0" = "Did not impact", "1" = "Front", "2" = "Back",
                        "3" = "Offside", "4" = "Nearside", "9" = "Unknown")
journey_purpose_codes <- c("1" = "Work", "2" = "Commuting", 
                           "3" = "Taking pupil to school", "4" = "Pupil to school",
                           "5" = "Other", "6" = "Unknown")
propulsion_codes <- c("1" = "Petrol", "2" = "Heavy oil", "3" = "Electric",
                      "4" = "Steam", "5" = "Gas", "6" = "Petrol/Gas (LPG)",
                      "7" = "Gas/Bi-fuel", "8" = "Gas diesel",
                      "9" = "Hybrid electric", "12" = "Electricity diesel")
home_area_codes <- c("1" = "Urban area", "2" = "Small town", "3" = "Rural")

# Load data (replace with actual paths to concatenated 2014-2023 CSVs)
collisions <- read_csv("collision.csv")
casualties <- read_csv("casualty.csv")
vehicles <- read_csv("vehicle.csv")

# Convert categorical variables to strings (factors) with labels
collisions <- collisions %>%
  mutate(
    accident_severity = factor(accident_severity, levels = names(accident_severity_codes), labels = accident_severity_codes),
    road_type = factor(road_type, levels = names(road_type_codes), labels = road_type_codes),
    road_surface_conditions = factor(road_surface_conditions, levels = names(road_surface_conditions_codes), labels = road_surface_conditions_codes),
    weather_conditions = factor(weather_conditions, levels = names(weather_conditions_codes), labels = weather_conditions_codes),
    light_conditions = factor(light_conditions, levels = names(light_conditions_codes), labels = light_conditions_codes),
    junction_detail = factor(junction_detail, levels = names(junction_detail_codes), labels = junction_detail_codes),
    urban_or_rural_area = factor(urban_or_rural_area, levels = names(urban_rural_codes), labels = urban_rural_codes),
    day_of_week = factor(day_of_week, levels = names(day_of_week_codes), labels = day_of_week_codes),
    ped_crossing_human = factor(pedestrian_crossing_human_control, levels = names(ped_crossing_human_codes), labels = ped_crossing_human_codes),
    ped_crossing_facilities = factor(pedestrian_crossing_physical_facilities, levels = names(ped_crossing_facilities_codes), labels = ped_crossing_facilities_codes),
    carriageway_hazards = factor(carriageway_hazards, levels = names(carriageway_hazards_codes), labels = carriageway_hazards_codes),
    special_conditions_at_site = factor(special_conditions_at_site, levels = names(special_conditions_codes), labels = special_conditions_codes),
    junction_control = factor(junction_control, levels = names(junction_control_codes), labels = junction_control_codes),
    first_road_class = factor(first_road_class, levels = names(road_class_codes), labels = road_class_codes),
    second_road_class = factor(second_road_class, levels = names(second_road_class_codes), labels = second_road_class_codes)
  )

vehicles <- vehicles %>%
  mutate(
    vehicle_type = factor(vehicle_type, levels = names(vehicle_type_codes), labels = vehicle_type_codes),
    sex_of_driver = factor(sex_of_driver, levels = names(sex_codes), labels = sex_codes),
    age_band_of_driver = factor(age_band_of_driver, levels = c(names(age_band_codes), "-1"), labels = c(age_band_codes, "Unknown")),
    vehicle_manoeuvre = factor(vehicle_manoeuvre, levels = names(vehicle_manoeuvre_codes), labels = vehicle_manoeuvre_codes),
    towing_and_articulation = factor(towing_and_articulation, levels = names(towing_codes), labels = towing_codes),
    skidding_and_overturning = factor(skidding_and_overturning, levels = names(skidding_codes), labels = skidding_codes),
    hit_object_in_carriageway = factor(hit_object_in_carriageway, levels = names(hit_object_in_codes), labels = hit_object_in_codes),
    hit_object_off_carriageway = factor(hit_object_off_carriageway, levels = names(hit_object_off_codes), labels = hit_object_off_codes),
    first_point_of_impact = factor(first_point_of_impact, levels = names(impact_point_codes), labels = impact_point_codes),
    journey_purpose_of_driver = factor(journey_purpose_of_driver, levels = names(journey_purpose_codes), labels = journey_purpose_codes),
    propulsion_code = factor(propulsion_code, levels = names(propulsion_codes), labels = propulsion_codes),
    driver_home_area_type = factor(driver_home_area_type, levels = names(home_area_codes), labels = home_area_codes)
  )

casualties <- casualties %>%
  mutate(
    casualty_severity = factor(casualty_severity, levels = names(casualty_severity_codes), labels = casualty_severity_codes),
    casualty_type = factor(casualty_type, levels = names(casualty_type_codes), labels = casualty_type_codes),
    sex_of_casualty = factor(sex_of_casualty, levels = names(sex_codes), labels = sex_codes),
    age_band_of_casualty = factor(age_band_of_casualty, levels = c(names(age_band_codes), "-1"), labels = c(age_band_codes, "Unknown")),
    pedestrian_location = factor(pedestrian_location, levels = names(pedestrian_location_codes), labels = pedestrian_location_codes),
    pedestrian_movement = factor(pedestrian_movement, levels = names(pedestrian_movement_codes), labels = pedestrian_movement_codes),
    casualty_class = factor(casualty_class, levels = names(casualty_class_codes), labels = casualty_class_codes),
    car_passenger = factor(car_passenger, levels = names(car_passenger_codes), labels = car_passenger_codes),
    bus_or_coach_passenger = factor(bus_or_coach_passenger, levels = names(bus_passenger_codes), labels = bus_passenger_codes),
    pedestrian_road_maintenance_worker = factor(pedestrian_road_maintenance_worker, levels = names(ped_road_worker_codes), labels = ped_road_worker_codes),
    casualty_home_area_type = factor(casualty_home_area_type, levels = names(home_area_codes), labels = home_area_codes)
  )

# Data Quality Checks using validate package
rules_collisions <- validator(
  accident_severity %in% accident_severity_codes,
  road_type %in% road_type_codes,
  road_surface_conditions %in% road_surface_conditions_codes,
  weather_conditions %in% weather_conditions_codes,
  light_conditions %in% light_conditions_codes,
  junction_detail %in% junction_detail_codes,
  urban_or_rural_area %in% urban_rural_codes,
  day_of_week %in% day_of_week_codes,
  ped_crossing_human %in% ped_crossing_human_codes,
  ped_crossing_facilities %in% ped_crossing_facilities_codes,
  carriageway_hazards %in% carriageway_hazards_codes,
  special_conditions_at_site %in% special_conditions_codes,
  junction_control %in% junction_control_codes,
  first_road_class %in% road_class_codes,
  second_road_class %in% second_road_class_codes,
  speed_limit %in% c(20, 30, 40, 50, 60, 70) | is.na(speed_limit),
  accident_year %in% 2014:2023,
  str_starts(local_authority_ons_district, "E09") & !is.na(local_authority_ons_district),
  !is.na(longitude) & !is.na(latitude),  # Location data required
  number_of_vehicles >= 1,
  number_of_casualties >= 1
)

rules_vehicles <- validator(
  vehicle_type %in% vehicle_type_codes,
  sex_of_driver %in% sex_codes,
  age_band_of_driver %in% c(age_band_codes, "Unknown"),
  vehicle_manoeuvre %in% vehicle_manoeuvre_codes,
  towing_and_articulation %in% towing_codes,
  skidding_and_overturning %in% skidding_codes,
  hit_object_in_carriageway %in% hit_object_in_codes,
  hit_object_off_carriageway %in% hit_object_off_codes,
  first_point_of_impact %in% impact_point_codes,
  journey_purpose_of_driver %in% journey_purpose_codes,
  propulsion_code %in% propulsion_codes,
  driver_home_area_type %in% home_area_codes,
  accident_year %in% 2014:2023
)

rules_casualties <- validator(
  casualty_severity %in% casualty_severity_codes,
  casualty_type %in% casualty_type_codes,
  sex_of_casualty %in% sex_codes,
  age_band_of_casualty %in% c(age_band_codes, "Unknown"),
  pedestrian_location %in% pedestrian_location_codes,
  pedestrian_movement %in% pedestrian_movement_codes,
  casualty_class %in% casualty_class_codes,
  car_passenger %in% car_passenger_codes,
  bus_or_coach_passenger %in% bus_passenger_codes,
  pedestrian_road_maintenance_worker %in% ped_road_worker_codes,
  casualty_home_area_type %in% home_area_codes,
  accident_year %in% 2014:2023
)

# Apply validation
collision_validation <- confront(collisions, rules_collisions)
vehicle_validation <- confront(vehicles, rules_vehicles)
casualty_validation <- confront(casualties, rules_casualties)

# Summarize validation results
print(summary(collision_validation))
print(summary(vehicle_validation))
print(summary(casualty_validation))

# Data Cleaning
collisions_clean <- collisions %>%
  filter(
    accident_year %in% 2014:2023,
    str_starts(local_authority_ons_district, "E09") & !is.na(local_authority_ons_district),  # Fixed London filter
    accident_severity %in% accident_severity_codes,
    road_type %in% road_type_codes,
    road_surface_conditions %in% road_surface_conditions_codes,
    weather_conditions %in% weather_conditions_codes,
    light_conditions %in% light_conditions_codes,
    junction_detail %in% junction_detail_codes,
    !is.na(longitude) & !is.na(latitude),  # Remove missing locations
    number_of_vehicles >= 1,
    number_of_casualties >= 1
  ) %>%
  mutate(
    speed_limit = ifelse(is.na(speed_limit), 30, speed_limit),  # Impute common speed limit
    date = dmy(date, quiet = TRUE),  # Parse date
    month = month(date, label = TRUE, abbr = FALSE)  # Extract month as string
  )

vehicles_clean <- vehicles %>%
  semi_join(collisions_clean, by = "accident_index") %>%  # Only vehicles in London accidents
  filter(
    vehicle_type %in% vehicle_type_codes,
    sex_of_driver %in% sex_codes,
    age_band_of_driver %in% c(age_band_codes, "Unknown"),
    vehicle_manoeuvre %in% vehicle_manoeuvre_codes,
    towing_and_articulation %in% towing_codes,
    skidding_and_overturning %in% skidding_codes,
    hit_object_in_carriageway %in% hit_object_in_codes,
    hit_object_off_carriageway %in% hit_object_off_codes,
    first_point_of_impact %in% impact_point_codes,
    journey_purpose_of_driver %in% journey_purpose_codes,
    propulsion_code %in% propulsion_codes,
    driver_home_area_type %in% home_area_codes
  ) %>%
  mutate(
    age_of_driver = ifelse(age_of_driver < 17 | age_of_driver > 110, NA, age_of_driver)  # Cap age
  )

casualties_clean <- casualties %>%
  semi_join(collisions_clean, by = "accident_index") %>%  # Only casualties in London accidents
  filter(
    casualty_severity %in% casualty_severity_codes,
    casualty_type %in% casualty_type_codes,
    sex_of_casualty %in% sex_codes,
    age_band_of_casualty %in% c(age_band_codes, "Unknown"),
    pedestrian_location %in% pedestrian_location_codes,
    pedestrian_movement %in% pedestrian_movement_codes,
    casualty_class %in% casualty_class_codes,
    car_passenger %in% car_passenger_codes,
    bus_or_coach_passenger %in% bus_passenger_codes,
    pedestrian_road_maintenance_worker %in% ped_road_worker_codes,
    casualty_home_area_type %in% home_area_codes
  ) %>%
  mutate(
    age_of_casualty = ifelse(age_of_casualty < 0 | age_of_casualty > 110, NA, age_of_casualty)  # Cap age
  )

# Consistency Check: Ensure number_of_vehicles/casualties align
vehicle_counts <- vehicles_clean %>%
  group_by(accident_index) %>%
  summarise(vehicle_count = n())
casualty_counts <- casualties_clean %>%
  group_by(accident_index) %>%
  summarise(casualty_count = n())

collisions_clean <- collisions_clean %>%
  left_join(vehicle_counts, by = "accident_index") %>%
  left_join(casualty_counts, by = "accident_index") %>%
  filter(
    number_of_vehicles == vehicle_count | is.na(vehicle_count),  # Allow if no vehicles (rare)
    number_of_casualties == casualty_count | is.na(casualty_count)  # Allow if no casualties
  ) %>%
  select(-vehicle_count, -casualty_count)

# Save cleaned data for PostgreSQL/Hive loading
write_csv(collisions_clean, "clean_london_collisions.csv")
write_csv(vehicles_clean, "clean_london_vehicles.csv")
write_csv(casualties_clean, "clean_london_casualties.csv")

print("Data quality checks and cleaning complete. Cleaned CSVs saved.")

# Read and filter collisions CSV
collisions <- read.csv("clean_london_collisions.csv")
collisions_filtered <- collisions %>%
  select(accident_index, accident_year, month, local_authority_ons_district, 
         accident_severity, road_type, road_surface_conditions, weather_conditions, 
         light_conditions, junction_detail, urban_or_rural_area, speed_limit, time)
write.csv(collisions_filtered, "clean_london_collisions_filtered.csv", row.names = FALSE)

# Read and filter vehicles CSV
vehicles <- read.csv("clean_london_vehicles.csv")
vehicles_filtered <- vehicles %>%
  select(accident_index, vehicle_reference, vehicle_type, sex_of_driver, age_band_of_driver)
write.csv(vehicles_filtered, "clean_london_vehicles_filtered.csv", row.names = FALSE)

# Read and filter casualties CSV
casualties <- read.csv("clean_london_casualties.csv")
casualties_filtered <- casualties %>%
  select(accident_index, casualty_reference, casualty_type, sex_of_casualty, 
         age_band_of_casualty, casualty_severity, pedestrian_location, pedestrian_movement)
write.csv(casualties_filtered, "clean_london_casualties_filtered.csv", row.names = FALSE)

print("Filtered CSVs saved: clean_london_collisions_filtered.csv, clean_london_vehicles_filtered.csv, clean_london_casualties_filtered.csv")
