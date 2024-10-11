select *
from prescriber
select *
from prescription
select *
from drug
select *
from zip_fips
select *
from cbsa
select *
from population
select *
from fips_county
select *
from overdose_deaths

-- 1a) Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

-- SELECT npi, SUM(total_claim_count) AS sum_claim
-- FROM prescription
-- GROUP by npi
-- ORDER BY sum_claim DESC

-- A: 1881634483 is the provider with 99,707 claims.

-- 1b) Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims.

-- SELECT prescriber.nppes_provider_first_name AS first_name, prescriber.nppes_provider_last_org_name AS last_name, prescriber.specialty_description, SUM(prescription.total_claim_count) AS sum_claim
-- FROM prescriber 
-- JOIN prescription 
-- USING(npi)
-- GROUP BY first_name, last_name, prescriber.specialty_description
-- ORDER BY sum_claim DESC

-- SELECT CONCAT(prescriber.nppes_provider_first_name, ' ', prescriber.nppes_provider_last_org_name) AS provider_name, prescriber.specialty_description, SUM(prescription.total_claim_count) AS sum_claim
-- FROM prescriber 
-- JOIN prescription 
-- USING(npi)
-- GROUP BY provider_name, prescriber.specialty_description
-- ORDER BY sum_claim DESC

-- A: Bruce Pendley, Family Practice, is 1881634483.

-- 2a) Which specialty had the most total number of claims (totaled over all drugs)?

-- SELECT prescriber.specialty_description, SUM(prescription.total_claim_count) AS sum_claim
-- FROM prescriber
-- JOIN prescription
-- USING(npi)
-- GROUP BY prescriber.specialty_description
-- ORDER BY sum_claim DESC

-- A: Family Practice at 9,752,347 claims.

-- 2b) Which specialty had the most total number of claims for opioids?

-- SELECT prescriber.specialty_description, SUM(prescription.total_claim_count) AS sum_claim
-- FROM prescriber
-- JOIN prescription
-- USING (npi)
-- JOIN 
-- 	(SELECT * 
-- 	FROM prescription
-- 	JOIN drug
-- 	USING(drug_name)
-- 	WHERE opioid_drug_flag = 'Y' AND long_acting_opioid_drug_flag = 'Y')
-- USING(npi)
-- GROUP BY prescriber.specialty_description
-- ORDER BY sum_claim DESC;

-- A: Family practice had the highest number of opioid claims at 12,152,032.

-- 3a) Which drug (generic_name) had the highest total drug cost?

-- SELECT drug.generic_name, ROUND(prescription.total_drug_cost,-1)
-- FROM prescription
-- JOIN drug
-- USING(drug_name)
-- GROUP BY drug.generic_name, prescription.total_drug_cost
-- ORDER BY prescription.total_drug_cost DESC;

-- SELECT drug.generic_name, TO_CHAR(ROUND(prescription.total_drug_cost,-1), 'L999G999G999') AS total_cost
-- FROM prescription
-- JOIN drug
-- USING(drug_name)
-- ORDER BY total_cost DESC;

-- A: Pirfenidone at $2.8M.

-- 3b) Which drug (generic_name) has the hightest total cost per day? Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.

Need to divide total drug cost by total day supply for each drug

-- SELECT DISTINCT drug.generic_name, TO_CHAR(ROUND(CAST(prescription.total_drug_cost AS DECIMAL)/prescription.total_day_supply,2),'L9G999G999.00') AS total_cost_per_day
-- FROM drug
-- JOIN prescription
-- USING(drug_name)
-- ORDER BY total_cost_per_day DESC;

-- SELECT DISTINCT drug.generic_name, ROUND(CAST(prescription.total_drug_cost AS NUMERIC)/prescription.total_day_supply,2) AS total_cost_per_day
-- FROM drug
-- JOIN prescription
-- USING(drug_name)
-- ORDER BY total_cost_per_day DESC;

-- SELECT DISTINCT drug.generic_name, ROUND(prescription.total_drug_cost/prescription.total_day_supply,2) AS total_cost_per_day
-- FROM drug
-- JOIN prescription
-- USING(drug_name)
-- ORDER BY total_cost_per_day DESC;

-- A: IMMUN GLOB G(IGG) had the highest cost per day at $7,141.11.

-- 4a) For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. Hint: You may want to use a CASE expression for this.

drug name and then drug type: opioid OR antibiotic OR neither, which is going to be 1 opioids (combining regular and long acting), 1 antibiotic, and 1 neither

-- SELECT drug_name, opioid_drug_flag, long_acting_opioid_drug_flag, antibiotic_drug_flag,
-- CASE 
-- 	WHEN opioid_drug_flag = 'Y' AND long_acting_opioid_drug_flag = 'Y' AND antibiotic_drug_flag = 'N' THEN 'Opioid'
-- 	WHEN long_acting_opioid_drug_flag = 'Y' AND opioid_drug_flag = 'N' AND antibiotic_drug_flag = 'N' THEN 'Opioid'
-- 	WHEN long_acting_opioid_drug_flag = 'N' AND opioid_drug_flag = 'Y' AND antibiotic_drug_flag = 'N' THEN 'Opioid'
-- 	WHEN antibiotic_drug_flag = 'Y' AND opioid_drug_flag = 'N' AND long_acting_opioid_drug_flag = 'N' THEN 'Antibiotic'
-- 	ELSE 'Neither nor' END AS drug_type
-- FROM drug

-- SELECT drug_name, opioid_drug_flag, antibiotic_drug_flag,
-- CASE 
-- 	WHEN opioid_drug_flag = 'Y' AND antibiotic_drug_flag = 'N' THEN 'Opioid'
-- 	WHEN antibiotic_drug_flag = 'Y' AND opioid_drug_flag = 'N' THEN 'Antibiotic'
-- 	ELSE 'Neither nor' END AS drug_type
-- FROM drug


