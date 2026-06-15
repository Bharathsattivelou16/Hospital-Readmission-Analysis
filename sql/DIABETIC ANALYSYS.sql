#CREATE_SCHEMA
CREATE DATABASE IF NOT EXISTS healthcare_db;
USE healthcare_db;
DROP TABLE IF EXISTS diabetic_patients;
CREATE TABLE diabetic_patients (
    encounter_id              INT PRIMARY KEY,
    patient_nbr               INT,
    race                      VARCHAR(20),
    gender                    VARCHAR(20),
    age                       VARCHAR(10),
    weight                    VARCHAR(15),
    admission_type_id         INT,
    discharge_disposition_id  INT,
    admission_source_id       INT,
    time_in_hospital          INT,
    payer_code                VARCHAR(10),
    medical_specialty         VARCHAR(50),
    num_lab_procedures        INT,
    num_procedures            INT,
    num_medications           INT,
    number_outpatient         INT,
    number_emergency          INT,
    number_inpatient          INT,
    diag_1                    VARCHAR(10),
    diag_2                    VARCHAR(10),
    diag_3                    VARCHAR(10),
    number_diagnoses          INT,
    max_glu_serum             VARCHAR(10),
    A1Cresult                 VARCHAR(10),
    metformin                 VARCHAR(10),
    repaglinide               VARCHAR(10),
    nateglinide               VARCHAR(10),
    chlorpropamide            VARCHAR(10),
    glimepiride               VARCHAR(10),
    acetohexamide             VARCHAR(10),
    glipizide                 VARCHAR(10),
    glyburide                 VARCHAR(10),
    tolbutamide               VARCHAR(10),
    pioglitazone              VARCHAR(10),
    rosiglitazone             VARCHAR(10),
    acarbose                  VARCHAR(10),
    miglitol                  VARCHAR(10),
    troglitazone              VARCHAR(10),
    tolazamide                VARCHAR(10),
    examide                   VARCHAR(10),
    citoglipton               VARCHAR(10),
    insulin                   VARCHAR(10),
    `glyburide-metformin`     VARCHAR(10),
    `glipizide-metformin`     VARCHAR(10),
    `glimepiride-pioglitazone` VARCHAR(10),
    `metformin-rosiglitazone` VARCHAR(10),
    `metformin-pioglitazone`  VARCHAR(10),
    `change`                  VARCHAR(10),
    diabetesMed               VARCHAR(5),
    readmitted                VARCHAR(10)
);
#LOAD_DATA
LOAD DATA LOCAL INFILE 'C:/Users/Bharath/Desktop/Project1/Data/diabetic_data.csv'
INTO TABLE diabetic_patients
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
SELECT COUNT(*) AS total_rows FROM diabetic_patients;
SET GLOBAL local_infile = 1;
#DROPPING UNWANTED COLUMNS
ALTER TABLE diabetic_patients
    DROP COLUMN weight,
    DROP COLUMN payer_code,
    DROP COLUMN medical_specialty,
    DROP COLUMN metformin,
    DROP COLUMN repaglinide,
    DROP COLUMN nateglinide,
    DROP COLUMN chlorpropamide,
    DROP COLUMN glimepiride,
    DROP COLUMN acetohexamide,
    DROP COLUMN glipizide,
    DROP COLUMN glyburide,
    DROP COLUMN tolbutamide,
    DROP COLUMN pioglitazone,
    DROP COLUMN rosiglitazone,
    DROP COLUMN acarbose,
    DROP COLUMN miglitol,
    DROP COLUMN troglitazone,
    DROP COLUMN tolazamide,
    DROP COLUMN examide,
    DROP COLUMN citoglipton,
    DROP COLUMN `glyburide-metformin`,
    DROP COLUMN `glipizide-metformin`,
    DROP COLUMN `glimepiride-pioglitazone`,
    DROP COLUMN `metformin-rosiglitazone`,
    DROP COLUMN `metformin-pioglitazone`;

 ALTER TABLE diabetic_patients
    CHANGE COLUMN `change` change_med VARCHAR(5);
    DESCRIBE diabetic_patients;
    
    SET SQL_SAFE_UPDATES = 0;
#select @@secure_file_priv;
#DATA_CLEANING
#CHECKING NULL & ?
SELECT
    COUNT(CASE WHEN race = '?' THEN 1 END)       AS missing_race,
    COUNT(CASE WHEN diag_1 = '?' THEN 1 END)     AS missing_diag1,
    COUNT(CASE WHEN diag_2 = '?' THEN 1 END)     AS missing_diag2,
    COUNT(CASE WHEN gender = 'Unknown/Invalid' THEN 1 END) AS invalid_gender
FROM diabetic_patients;
#REPLACING ? with NULL
SET SQL_SAFE_UPDATES = 0;
UPDATE diabetic_patients SET race  = NULL WHERE race  = '?';
UPDATE diabetic_patients SET diag_1 = NULL WHERE diag_1 = '?';
UPDATE diabetic_patients SET diag_2 = NULL WHERE diag_2 = '?';
UPDATE diabetic_patients SET diag_3 = NULL WHERE diag_3 = '?';
#REMOVE INVALID GENDER
DELETE FROM diabetic_patients WHERE gender = 'Unknown/Invalid';
#FOR READMISSION CREATE A CLEAN BINARY VALUES
ALTER TABLE diabetic_patients ADD COLUMN readmitted_30 TINYINT DEFAULT 0;
UPDATE diabetic_patients 
SET readmitted = TRIM(REPLACE(REPLACE(readmitted, '\r', ''), '\n', ''));

UPDATE diabetic_patients SET readmitted_30 = 1 WHERE readmitted = '<30';
SELECT readmitted, readmitted_30, COUNT(*) as count
FROM diabetic_patients
GROUP BY readmitted, readmitted_30
ORDER BY readmitted;

#ANALYSIS
SELECT
    COUNT(*) AS total_patients,
    SUM(readmitted_30) AS readmitted_within_30,
    ROUND(SUM(readmitted_30) * 100.0 / COUNT(*), 2) AS readmission_rate_pct
FROM diabetic_patients;
 #READMISSION BY AGE GROUP
 SELECT
    age,
    COUNT(*) AS patient_count,
    SUM(readmitted_30) AS readmissions,
    ROUND(SUM(readmitted_30) * 100.0 / COUNT(*), 2) AS readmission_rate_pct
FROM diabetic_patients
GROUP BY age
ORDER BY readmission_rate_pct DESC;

SELECT
    gender,
    COUNT(*) AS patient_count,
    ROUND(SUM(readmitted_30) * 100.0 / COUNT(*), 2) AS readmission_rate_pct
FROM diabetic_patients
GROUP BY gender;

SELECT
    CASE WHEN readmitted_30 = 1 THEN 'Readmitted <30 days'
         ELSE 'Not readmitted / Later'
    END AS readmission_group,
    ROUND(AVG(time_in_hospital), 2)     AS avg_days_in_hospital,
    ROUND(AVG(num_medications), 2)       AS avg_medications,
    ROUND(AVG(num_lab_procedures), 2)    AS avg_lab_procedures,
    ROUND(AVG(number_diagnoses), 2)      AS avg_diagnoses,
    COUNT(*) AS patient_count
FROM diabetic_patients
GROUP BY readmission_group;
#Top 10 primary diagnoses with highest readmission rates
SELECT
    diag_1 AS primary_diagnosis,
    COUNT(*) AS patient_count,
    SUM(readmitted_30) AS readmissions,
    ROUND(SUM(readmitted_30) * 100.0 / COUNT(*), 2) AS readmission_rate_pct
FROM diabetic_patients
WHERE diag_1 IS NOT NULL
GROUP BY diag_1
HAVING patient_count >= 100
ORDER BY readmission_rate_pct DESC
LIMIT 10;
#Ranking patients by number of medications within each age group( Window function)
SELECT
    age,
    encounter_id,
    num_medications,
    readmitted_30,
    RANK() OVER(PARTITION BY age ORDER BY num_medications DESC) AS med_rank,
    AVG(num_medications) OVER(PARTITION BY age) AS avg_meds_in_age_group
FROM diabetic_patients;
#Insulin usage and readmission relationship
SELECT
    insulin,
    COUNT(*) AS patient_count,
    ROUND(SUM(readmitted_30) * 100.0 / COUNT(*), 2) AS readmission_rate_pct
FROM diabetic_patients
GROUP BY insulin
ORDER BY  readmission_rate_pct desc;
select * from diabetic_patients;

WITH high_risk AS (
    SELECT
        encounter_id,
        patient_nbr,
        age,
        time_in_hospital,
        num_medications,
        number_diagnoses,
        readmitted_30,
        CASE
            WHEN time_in_hospital > 7 THEN 1 ELSE 0
        END AS long_stay,
        CASE
            WHEN num_medications > 15 THEN 1 ELSE 0
        END AS high_meds,
        CASE
            WHEN number_diagnoses > 7 THEN 1 ELSE 0
        END AS multi_diagnosis
    FROM diabetic_patients
)
SELECT
    (long_stay + high_meds + multi_diagnosis) AS risk_score,
    COUNT(*) AS patient_count,
    ROUND(SUM(readmitted_30) * 100.0 / COUNT(*), 2) AS readmission_rate_pct
FROM high_risk
GROUP BY risk_score
ORDER BY risk_score DESC;

ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root123';
FLUSH PRIVILEGES;
INSTALL COMPONENT 'file://component_mysql_native_password';
INSTALL COMPONENT 'file://component_mysql_native_password';
