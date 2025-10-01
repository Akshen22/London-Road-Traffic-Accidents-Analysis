London Road Traffic Accidents Analysis 🚦


1) Overview 🌟

This repository hosts a comprehensive data analytics project analyzing road traffic accidents (RTAs) in London from the year 2014–2023. 
Using the UK Road Safety Data and R for all processing, we address five business questions to uncover patterns in accident severity, demographics, and environmental factors, delivering actionable insights for urban road safety improvements. 
Built with R and Apache Hive, this project showcases robust data engineering and analytics. 🛣️


2) Business Context 📊

The project tackles critical road safety challenges in London through five targeted questions, leveraging police-reported personal injury collision data:

Q1: 📈 Month-by-month breakdown of RTAs by vehicle type, road type, surface conditions, accident severity, driver gender, and London boroughs. Justification: Identifies seasonal patterns (e.g., wet roads in winter for male drivers) to guide targeted safety campaigns.

Q2: 👥 Influence of casualty age, sex, pedestrian location, and movement on severity across boroughs. Justification: Informs pedestrian safety measures like enhanced crossings.

Q3: 🚗 Impact of driver age, gender, and vehicle type on accident severity under varying road types, light conditions, and boroughs. Justification: Supports driver training for high-risk conditions (e.g., darkness).

Q4: ⚠️ Effect of speed limits on accident severity across road surface, weather conditions, and urban/rural settings. Justification: Recommends dynamic speed limit adjustments (e.g., in wet weather).

Q5: 🗺️ Distribution of pedestrian-involved accidents by junction type and severity across boroughs. Justification: Targets high-risk junctions (e.g., T-junctions) for signage or redesign.

Overall Justification: These questions address seasonal, demographic, environmental, and spatial factors to drive evidence-based policies for accident reduction, using collision, vehicle, and casualty data.


3) Data Source 📊

Primary: UK Road Safety Data (2014–2023) from data.gov.uk: https://www.data.gov.uk/dataset/cb7ae6f0-4be6-4935-9277-47e5ce24a11f/road-accidents-safety-data

Key features: accident severity, casualty demographics, vehicle types, road/weather conditions, speed limits, junction types, and location. 📂

For quick access: 

collisions: https://www.kaggle.com/datasets/akshendhami/collision-2014-2023

casualties: https://www.kaggle.com/datasets/akshendhami/casualty-2014-2023

vehicles: https://www.kaggle.com/datasets/akshendhami/vehicle-2014-2023


4) Architecture & Technologies 🛠️

ETL Pipeline: R scripts using readr and dplyr for data ingestion and cleansing 🧹

Data Mart: Star schema in Apache Hive & PostgreSQL for efficient queries 🗄️

Analysis: Tableau for data wrangling and visualizations 📊

Quality Assurance: R’s validate package for data integrity ✅


5) Key Findings & Recommendations 🎯

Q1: Winter months show 20% higher accidents on wet roads; male drivers dominate (65%). Recommendation: Seasonal campaigns targeting male drivers (e.g., wet-weather awareness).

Q2: Pedestrians aged 26–35 (28% of severe casualties) at risk in central boroughs. Recommendation: Enhanced crossings in Westminster (12% of incidents).

Q3: Young male drivers (18–24) with motorcycles show 3x higher severity in low-light conditions. Recommendation: Night-driving training programs.

Q4: 30mph zones on wet roads have 15% higher severity in urban areas. Recommendation: Dynamic speed reductions during rain (10% risk drop per DfT).

Q5: T-junctions account for 35% of pedestrian accidents in SE boroughs. Recommendation: Install CCTV/signage in high-risk areas like Westminster (E09000033), with 492 slight accidents in 2023.


6) Final Recommendations:

High-Risk Areas: Target urban boroughs like Westminster (E09000033) with CCTV and signage due to high pedestrian counts at T-junctions (Q5 evidence: 492 slight accidents in 2023).

Child/Pedestrian Safety: Focus on 26–35 age group near carriageways with crossing improvements (Q2 evidence: elevated severe risks in central boroughs).

Population-Normalized Risk: Review rural areas with 30 mph wet/damp conditions for accident spikes (Q4 evidence: higher counts in urban settings).

Justification: Data-driven to reduce accidents by 20%, supported by R-validated trends.


7) Setup & Usage ⚙️

i) Clone the repo: git clone https://github.com/yourusername/London-Road-Traffic-Accidents-Analysis.git & go through the .ppt first, to get an overview about the project

ii) Run the given .R file in the RStudio, will get the cleaned dataset that should be used to write the queries

iii) Open Apache hive & after going through and understanding the below files, run all the queries by copy - pasting; the files are:
"3) Hive ETL, 4) Hive Data Validation, 5) Hive Business queries, 6) Pig Export Business question csv's"

iv) Once exported the final output of each 5 questions in the csv using pig, import all the files in the tableau, refer "9) Visualization folder"; contains the tableau files for each questions 


8) Limitations & Future Work 🔮

i) Limitations

Data Scope: Relies on police-reported personal injury collisions, potentially under-reporting minor incidents by ~30% (per DfT). Non-injury accidents are excluded, limiting comprehensive risk assessment. 📊

Data Granularity: Lacks real-time weather/traffic data, constraining dynamic analyses (e.g., wet/damp 30 mph impacts in Q4). Postcode filtering may miss boundary edge cases. 🗺️

Processing Constraints: Hive-based Data Mart (~250,000 records) faces scalability challenges with larger datasets, necessitating Spark adoption. 🛠️

Geographic Specificity: High-risk area identification (e.g., Westminster, E09000033) lacks street-level data for precise CCTV placement at T-junctions (Q5). 🚦

Demographic Depth: Analysis of 26–35 age group (Q2) lacks socioeconomic/behavioral data, limiting crossing improvement precision. 👥

ii) Future Work

Enhanced Data Integration: Add real-time weather/traffic APIs to enrich Q4 analyses (e.g., wet/damp 30 mph rural spikes) and support dynamic speed limits. Expand multi-year data for longitudinal trends. 📈

Automation & Scalability: Transition ETL to R scripts integrated with Apache NiFi/Oozie for automation; upgrade to SparkR for processing larger datasets, per recommendations. 🚀

Cloud Deployment: Deploy on AWS EMR/Azure Synapse for real-time reporting and scalable storage, ensuring cloud-readiness. ☁️

Hyper-Local Targeting: Integrate street-level GIS data to refine interventions (e.g., CCTV in Westminster T-junctions, Q5). 🗺️

Predictive Modeling: Use R’s machine learning packages (e.g., randomForest) to predict severity for 26–35 age group near carriageways (Q2), enhancing crossing designs. 🤖

Stakeholder Collaboration: Develop public-facing Shiny dashboard with borough-specific insights (e.g., Q4 rural risks) for policymakers. 🤝

Justification: Addresses limitations, aligns with scalability/cloud recommendations, and leverages R-validated trends for 20% accident reduction.


9) Contributing 🤝

You are welcome to contribute to enhance this safety-focused project! Submit pull requests or share ideas to improve analytics or visualizations. 🌟

Contact: akshendhami@gmail.com, https://www.linkedin.com/in/akshen-dhami22  
