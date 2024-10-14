-- 1a) Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

-- SELECT npi, SUM(total_claim_count) AS sum_claim
-- FROM prescription
-- GROUP by npi
-- ORDER BY sum_claim DESC

-- SELECT scriber.npi, SUM(scription.total_claim_count) AS sum_claim
-- FROM prescriber AS scriber
-- JOIN prescription AS scription
-- USING(npi)
-- GROUP BY scriber.npi
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

-- SELECT p.specialty_description, SUM(total_claim_count) as sum_claim
-- FROM prescriber as p
-- INNER JOIN prescription as pr
-- USING(npi)
-- INNER JOIN drug as d
-- USING(drug_name)
-- WHERE d.opioid_drug_flag = 'Y'
-- GROUP BY p.specialty_description
-- ORDER BY sum_claim DESC

-- SELECT prescriber.specialty_description, SUM(prescription.total_claim_count) AS sum_claim
-- FROM prescriber
-- JOIN prescription
-- USING(npi)
-- JOIN 
-- 	(SELECT * 
-- 		FROM prescription
-- 		JOIN drug
-- 		USING(drug_name)
-- 		WHERE opioid_drug_flag = 'Y')
-- USING(npi)
-- GROUP BY prescriber.specialty_description
-- ORDER BY sum_claim DESC;

-- A: Family Practice had the highest number of opioid claims at 51,589,557.

-- 3a) Which drug (generic_name) had the highest total drug cost?

-- SELECT drug.generic_name, ROUND(SUM(prescription.total_drug_cost),-1)
-- FROM prescription
-- JOIN drug
-- USING(drug_name)
-- GROUP BY drug.generic_name
-- ORDER BY SUM(prescription.total_drug_cost) DESC;

-- A: Insulin

-- 3b) Which drug (generic_name) has the hightest total cost per day? Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.

Need to divide total drug cost by total day supply for each drug

SELECT DISTINCT drug.generic_name, CAST(ROUND(prescription.total_drug_cost/prescription.total_day_supply,2) AS MONEY) AS total_cost_per_day
FROM drug
JOIN prescription
USING(drug_name)
ORDER BY total_cost_per_day DESC;

SELECT drug.generic_name,	
	(SUM(prescription.total_drug_cost)/SUM(prescription.total_day_supply)) :: MONEY as daily_drug_cost
	FROM prescription
		INNER JOIN drug
			USING (drug_name)
	GROUP BY drug.generic_name
	ORDER BY daily_drug_cost DESC

-- A: ??

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

-- 4b) Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

SELECT prescription.total_drug_cost, drug.opioid_drug_flag, drug.antibiotic_drug_flag,
	CASE
		WHEN opioid_drug_flag = 'Y' THEN CAST(opioid_drug_flag * total_drug_cost) AS opioid_costs
		WHEN antibiotic_drug_flag = 'Y' THEN CAST(antibiotic_drug_flag * total_drug_cost) AS antibiotic_costs
		ELSE 0 END AS 'NA'
FROM prescription
JOIN drug
USING(drug_name)
GROUP BY total_drug_cost;

SELECT 
    CAST(SUM(CASE WHEN drug.opioid_drug_flag = 'Y' THEN prescription.total_drug_cost ELSE 0 END) AS MONEY) AS opioid_cost,
    CAST(SUM(CASE WHEN drug.antibiotic_drug_flag = 'Y' THEN prescription.total_drug_cost ELSE 0 END) AS MONEY) AS antibiotic_cost
FROM prescription
JOIN drug
USING(drug_name);

SELECT drug.opioid_drug_flag, drug.antibiotic_drug_flag,
	SUM(CASE WHEN drug.opioid_drug_flag = 'Y' THEN CAST(prescription.total_drug_cost AS DECIMAL),'L99G999G999.00') ELSE 0 END) AS opioid_costs,
	SUM(CASE WHEN drug.antibiotic_drug_flag = 'Y' THEN CAST(prescription.total_drug_cost AS DECIMAL),'L99G999G999.00') ELSE 0 END) AS antibiotic_costs
FROM prescription
JOIN drug
USING(drug_name)
GROUP BY drug.opioid_drug_flag, drug.antibiotic_drug_flag

-- A: More was spent on opioids.
	
-- 5a) How many CBSAs are in Tennessee? Warning: The cbsa table contains information for all states, not just Tennessee.

SELECT COUNT(*) 
FROM fips_county AS f
INNER JOIN cbsa AS c
ON f.fipscounty = c.fipscounty
WHERE f.state = 'TN'

-- A: 33 cbsas are in TN.

-- 5b) Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

(SELECT cbsaname, SUM(population) AS total_population, 'largest' as flag
FROM cbsa 
INNER JOIN population
USING(fipscounty)
GROUP BY cbsaname
ORDER BY total_population DESC
limit 1)
UNION
(SELECT cbsaname, SUM(population) AS total_population, 'smallest' as flag
FROM cbsa 
INNER JOIN population
USING(fipscounty)
GROUP BY cbsaname
ORDER BY total_population 
limit 1) order by total_population desc

-- A: Memphis has the highest populated CBSA with 937,847, and Nashville-Davidson has the smallest population with 8,773. 

-- 5c) What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

SELECT f.county, SUM(p.population) as combined_population
FROM fips_county AS f
INNER JOIN population AS p 
	ON f.fipscounty = p.fipscounty
WHERE f.fipscounty IN
		(SELECT fipscounty FROM fips_county 
		EXCEPT
		SELECT fipscounty FROM cbsa) 
GROUP BY f.county
ORDER BY combined_population desc

SELECT county, population
FROM fips_county
INNER JOIN population
USING(fipscounty)
WHERE fipscounty NOT IN (SELECT fipscounty
	FROM cbsa)
ORDER BY population DESC;

-- 6a) Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

SELECT p.drug_name, SUM(p.total_claim_count)
FROM prescription AS p
WHERE p.total_claim_count >= 3000
GROUP BY p.drug_name
ORDER BY SUM(p.total_claim_count) DESC

-- 6b) For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

SELECT d.drug_name, p.total_claim_count, d.opioid_drug_flag,
	 CASE
	 WHEN d.opioid_drug_flag = 'Y' THEN 'YES'
	 ELSE 'NO'
	 END AS is_opioid
	 FROM prescription P
	 INNER JOIN drug AS d
	 ON p.drug_name = d.drug_name
	WHERE total_claim_count >= 3000;

-- 6c) Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
 
SELECT total_claim_count,d.drug_name,CONCAT(pres.nppes_provider_last_org_name,' ',
		pres.nppes_provider_first_name) as prescriber_name,
CASE WHEN opioid_drug_flag = 'Y' THEN 'Opioid'
	WHEN opioid_drug_flag = 'N' THEN 'Not Opioid' END as opioid
FROM prescription as pr
INNER JOIN drug as d
ON pr.drug_name=d.drug_name
INNER JOIN prescriber as pres
ON pr.npi=pres.npi
WHERE total_claim_count >= 3000

-- 7a) First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). Warning: Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

SELECT 	p.npi, d.drug_name
FROM prescriber as p
CROSS JOIN drug as d
WHERE p.specialty_description ='Pain Management' 
AND p.nppes_provider_city = 'NASHVILLE' 
AND d.opioid_drug_flag = 'Y'

-- 7b) Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

SELECT prescriber.npi, drug.drug_name,SUM(prescription.total_claim_count) AS sum_total_claims
FROM prescriber
CROSS JOIN drug
LEFT JOIN prescription
USING (drug_name)
WHERE prescriber.specialty_description = 'Pain Management'
	AND prescriber.nppes_provider_city = 'NASHVILLE'
	AND drug.opioid_drug_flag = 'Y'
GROUP BY prescriber.npi,drug.drug_name
ORDER BY prescriber.npi;

-- 7c) Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.

SELECT prescriber.npi, drug.drug_name, COALESCE(SUM(prescription.total_claim_count), 0) AS sum_total_claims
FROM prescriber
CROSS JOIN drug
LEFT JOIN prescription
USING (drug_name)
WHERE prescriber.specialty_description = 'Pain Management'
	AND prescriber.nppes_provider_city = 'NASHVILLE'
	AND drug.opioid_drug_flag = 'Y'
GROUP BY prescriber.npi, drug.drug_name
	ORDER BY prescriber.npi;
