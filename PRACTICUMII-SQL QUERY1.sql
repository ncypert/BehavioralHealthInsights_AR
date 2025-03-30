
--=========================================================================================================================
--=========================================================================================================================
--=========================================================================================================================
--Step 1--Data Understanding
--=========================================================================================================================
--=========================================================================================================================
--=========================================================================================================================

select * from [dbo].[data_2021_2023_masked_final]

--=========================================================================================================================
--Total Unique Patients--656407
--=========================================================================================================================
--=========================================================================================================================

select count(distinct masked_memberids) from [dbo].[data_2021_2023_masked_final]

select [age], count(distinct masked_memberids) as unique_patients
from data_2021_2023_masked_final
group by [age]
order by [age]

--Claims data from 3/1/2005 through 9/1/2023--
select min([firstdate]), max(lastdate) 
from data_2021_2023_masked_final

select avg(CAST(SMOKERS_COUNTY_PCT AS INT)) as state_avg_to_ED
from data_2021_2023_masked_final
where County_Name like '%jefferson%'

--Unique patients = 656407--
select count(distinct masked_memberids) as unique_patients, YEAR([MONTH]) as coverage_year 
from data_2021_2023_masked_final
group by Year([month]) 
order by coverage_year desc


--=========================================================================================================================
--=========================================================================================================================
--=========================================================================================================================
--Step 2--Data Understanding (BH Population)
--=========================================================================================================================
--=========================================================================================================================
--=========================================================================================================================

select * from data_2021_2023_masked_final
where [bh] = '1'

select * from data_2021_2023_masked_final
where [bh] = '1' and Rural_County_Pct > '30'

select distinct(masked_memberids) as unique_BH_patients, count(distinct masked_memberids) as unique_patients, [gender], YEAR(month) as Coverage_Year, SUM(CAST([paid_all] AS INT)) AS TOTAL_AMT_PAID,
SUM(CAST([paid_calc_pharm] AS INT)) AS TOTAL_RX_AMT_PAID, [Race], [White], [Black], [Hispanic], [Asian], [Some_College_County_Pct],
	CASE 
        WHEN [Age] < 10 THEN '0-9'
        WHEN [Age] BETWEEN 10 AND 19 THEN '10-19'
        WHEN [Age] BETWEEN 20 AND 29 THEN '20-29'
        WHEN [Age] BETWEEN 30 AND 39 THEN '30-39'
        WHEN [Age] BETWEEN 40 AND 49 THEN '40-49'
        WHEN [Age] BETWEEN 50 AND 59 THEN '50-59'
        WHEN [Age] BETWEEN 60 AND 69 THEN '60-69'
        WHEN [Age] BETWEEN 70 AND 79 THEN '70-79'
        WHEN [Age] BETWEEN 80 AND 89 THEN '80-89'
        ELSE '90+' 
    END AS Age_Bucket
from data_2021_2023_masked_final
WHERE Rural_County_Pct > 30 and [bh] = 1
group by masked_memberids, Age, Gender, YEAR(MONTH), [Race], [White], [Black], [Hispanic], [Asian],[Some_College_County_Pct]
order by [unique_BH_patients], Coverage_Year, TOTAL_AMT_PAID desc

--=========================================================================================================================
--AVerage cost per patient by age group
--=========================================================================================================================

SELECT 
    CASE 
        WHEN [Age] < 10 THEN '0-9'
        WHEN [Age] BETWEEN 10 AND 19 THEN '10-19'
        WHEN [Age] BETWEEN 20 AND 29 THEN '20-29'
        WHEN [Age] BETWEEN 30 AND 39 THEN '30-39'
        WHEN [Age] BETWEEN 40 AND 49 THEN '40-49'
        WHEN [Age] BETWEEN 50 AND 59 THEN '50-59'
        WHEN [Age] BETWEEN 60 AND 69 THEN '60-69'
        WHEN [Age] BETWEEN 70 AND 79 THEN '70-79'
        WHEN [Age] BETWEEN 80 AND 89 THEN '80-89'
        ELSE '90+' 
    END AS Age_Bucket,
    COUNT(DISTINCT masked_memberids) AS unique_BH_patients,
    SUM(CAST([paid_all] AS INT)) AS TOTAL_AMT_PAID,
    SUM(CAST([paid_all] AS INT)) * 1.0 / COUNT(DISTINCT masked_memberids) AS AVG_COST_PER_PATIENT
FROM 
    data_2021_2023_masked_final
WHERE 
    Rural_County_Pct > 30 
    AND [bh] = 1
GROUP BY  
    CASE 
        WHEN [Age] < 10 THEN '0-9'
        WHEN [Age] BETWEEN 10 AND 19 THEN '10-19'
        WHEN [Age] BETWEEN 20 AND 29 THEN '20-29'
        WHEN [Age] BETWEEN 30 AND 39 THEN '30-39'
        WHEN [Age] BETWEEN 40 AND 49 THEN '40-49'
        WHEN [Age] BETWEEN 50 AND 59 THEN '50-59'
        WHEN [Age] BETWEEN 60 AND 69 THEN '60-69'
        WHEN [Age] BETWEEN 70 AND 79 THEN '70-79'
        WHEN [Age] BETWEEN 80 AND 89 THEN '80-89'
        ELSE '90+' 
    END
ORDER BY 
    AVG_COST_PER_PATIENT DESC;


--=========================================================================================================================
--=========================================================================================================================
--=========================================================================================================================
--Step 3--New Table Creation (BH Population)
--Datatypes were changed in this step. All types were varchar, so values were cast as the needed datatype into a new table
--for analysis.
--Table with BH diagnosis information based on unique member ID and rural county category of 'rural' and binary BH variable = 1
--=========================================================================================================================
--=========================================================================================================================
--=========================================================================================================================


--drop table BCBS_BHPOP


SELECT DISTINCT
    CAST(masked_memberids AS INT) AS UNIQUE_BH_PATIENTS,
    YEAR(CAST([month] AS DATE)) AS COVERAGE_YEAR,
    CAST([All_SVI_Cat] AS VARCHAR(50)) AS Barrier_to_Care_Risk_Category,
    CAST([er] AS INT) AS ER_Utilization,
    CAST([ip] AS INT) AS IP_Utilization,
    CAST([op] AS INT) AS OP_Utilization,
    CAST([urgent] AS INT) as Urgent_Care_Utilization,
    CAST([office] AS INT) AS Office_Visit_Utilization,
    SUM(CAST([paid_all] AS INT)) AS TOTAL_AMT_PAID,
    SUM(CAST([paid_calc_pharm] AS INT)) AS TOTAL_RX_AMT_PAID,
    CAST([bh] AS INT) AS BH_Condition,
    CAST([alcohol_abuse] AS INT) AS Alcohol_Abuse_Diagnosis,
    CAST([anxiety_stress_ptsd] AS INT) AS Anxiety_Diagnosis,
    CAST([depression] AS INT) AS Depression_Diagnosis,
    CAST([drug_abuse] AS INT) AS Drug_Abuse_Diagnosis,
    CAST([psychoses] AS INT) AS Psychoses_Diagnosis,
    CAST([Gender] AS VARCHAR(10)) AS Patient_Gender,
    CAST([age] AS INT) AS Patient_Age,
    CASE
        WHEN Age BETWEEN 18 AND 25 THEN '18-25'
        WHEN Age BETWEEN 26 AND 35 THEN '26-35'
        WHEN Age BETWEEN 36 AND 45 THEN '36-45'
        WHEN Age BETWEEN 46 AND 55 THEN '46-55'
        WHEN Age BETWEEN 56 AND 65 THEN '56-65'
        WHEN Age BETWEEN 66 AND 75 THEN '66-75'
        WHEN Age BETWEEN 76 AND 85 THEN '76-85'
        WHEN Age > 85 THEN '86+'
        ELSE 'Unknown'
    END AS Age_Range,
    CAST([Race] AS VARCHAR(50)) AS Patient_Race,
    CAST([Race_Minority_Cat] AS VARCHAR(50)) AS Patient_Race_Category,
    CAST([Insurer_Relationship] AS VARCHAR(50)) AS Patient_Insurer_Status,
    CAST([Nearest_ED_Dist_Tract] AS FLOAT) AS Nearest_ER,
    CAST([Nearest_MedSurg_ICU_Dist_Tract] AS FLOAT) AS Nearest_IP_Facility,
    CAST([Nearest_Clinic_Dist_Tract] AS FLOAT) AS Nearest_OP_Clinic,
    CAST([Mbr_County_Name] AS VARCHAR(100)) AS Patient_County,
    CAST([Mbr_State] AS VARCHAR(50)) AS Patient_State,
    CAST([Pop_County] AS INT) AS County_Population,
    CAST([Internet_Access_County] AS FLOAT) AS Internet_County_Percentage,
    CAST([Some_College_County_Pct] AS FLOAT) AS Some_College_Percentage,
    CAST([PCP_per_100K_FCC] AS FLOAT) AS PCP_Distribution,
    CAST([BH_Prov_per_100K_FCC] AS FLOAT) AS BH_Provider_Distribution,
	Rural_County_Cat, zc.zip
INTO BCBS_BHPOP
FROM [dbo].[data_2021_2023_masked_final] bc
JOIN [uscountyzips] ZC ON zc.county_name = bc.County_Name
WHERE Rural_County_Cat = 'rural' AND [bh] = 1
GROUP BY
    masked_memberids, [month], YEAR([month]), [All_SVI_Cat], [employed], [er], [ip], [op], [urgent], [office], [bh], [alcohol_abuse],
    [anxiety_stress_ptsd], [depression], [drug_abuse], [psychoses], [Gender], [age],
    [Race], [Race_Minority_Cat], [Insurer_Relationship], [Nearest_ED_Dist_Tract],
    [Nearest_MedSurg_ICU_Dist_Tract], [Nearest_Trauma_Center_Dist_Tract], [Nearest_Clinic_Dist_Tract], [Mbr_County_Name], [Mbr_State],
    [Pop_County], [Internet_Access_County], [Some_College_County_Pct], [PCP_per_100K_FCC], [BH_Prov_per_100K_FCC], Rural_County_Cat, zc.zip
ORDER BY TOTAL_AMT_PAID DESC;



select * from BCBS_BHPOP

ALTER TABLE BCBS_BHPOP
ADD telehealth_utilization INT;

UPDATE BCBS_BHPOP
SET telehealth_utilization = CAST(CAST(src.[th] AS FLOAT) AS INT)
FROM BCBS_BHPOP pop
JOIN [dbo].[data_2021_2023_masked_final] src
    ON pop.[UNIQUE_BH_PATIENTS] = src.[masked_memberids];

ALTER TABLE BCBS_BHPOP
ADD Rural_County_Pct INT

UPDATE POP
SET Rural_County_Pct = CAST(CAST(src.RURAL_COUNTY_PCT AS FLOAT) AS INT)
FROM BCBS_BHPOP POP
JOIN [dbo].[data_2021_2023_masked_final] src
    ON pop.[UNIQUE_BH_PATIENTS] = src.[masked_memberids];


ALTER TABLE BCBS_BHPOP
DROP COLUMN zip;

Select * 
from BCBS_BHPOP
where Rural_County_Cat = 'rural' and Patient_County = 'pulaski'

select * from uscountyzips

SELECT county_name, COUNT(*)
FROM uscountyzips
GROUP BY county_name
HAVING COUNT(*) > 1;

SELECT 
    county_name,
    state_id,
    county_fips,
    AVG(CAST(lat AS FLOAT)) AS Avg_Latitude,
    AVG(CAST(lng AS FLOAT)) AS Avg_Longitude
FROM uscountyzips
GROUP BY county_name, state_id, county_fips





