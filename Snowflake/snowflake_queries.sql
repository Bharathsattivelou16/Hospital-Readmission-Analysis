CREATE WAREHOUSE IF NOT EXISTS HEALTHCARE_WH
    WAREHOUSE_SIZE = 'X-SMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE;
 
-- Create database and schema
CREATE DATABASE IF NOT EXISTS HEALTHCARE_DB;
USE DATABASE HEALTHCARE_DB;
CREATE SCHEMA IF NOT EXISTS READMISSION;
USE SCHEMA READMISSION;

-- Create the patient table
CREATE OR REPLACE TABLE DIABETIC_PATIENTS (
    encounter_id      INT,
    patient_nbr       INT,
    race              VARCHAR(20),
    gender            VARCHAR(10),
    age               VARCHAR(10),
    time_in_hospital  INT,
    num_lab_procedures INT,
    num_medications   INT,
    number_diagnoses  INT,
    diag_1            VARCHAR(10),
    insulin           VARCHAR(10),
    diabetesMed       VARCHAR(5),
    readmitted        VARCHAR(10),
    readmitted_30     INT
);

 CREATE OR REPLACE STAGE patient_stage;

DROP TABLE IF EXISTS DIABETIC_PATIENTS;

CREATE OR REPLACE TABLE DIABETIC_PATIENTS (
    encounter_id                 INT,
    patient_nbr                  INT,
    race                         VARCHAR(20),
    gender                       VARCHAR(10),
    age                          VARCHAR(10),
    weight                       VARCHAR(10),
    admission_type_id            INT,
    discharge_disposition_id     INT,
    admission_source_id          INT,
    time_in_hospital             INT,
    payer_code                   VARCHAR(10),
    medical_specialty            VARCHAR(50),
    num_lab_procedures           INT,
    num_procedures               INT,
    num_medications              INT,
    number_outpatient            INT,
    number_emergency             INT,
    number_inpatient             INT,
    diag_1                       VARCHAR(10),
    diag_2                       VARCHAR(10),
    diag_3                       VARCHAR(10),
    number_diagnoses             INT,
    max_glu_serum                VARCHAR(10),
    A1Cresult                    VARCHAR(10),
    metformin                    VARCHAR(10),
    repaglinide                  VARCHAR(10),
    nateglinide                  VARCHAR(10),
    chlorpropamide               VARCHAR(10),
    glimepiride                  VARCHAR(10),
    acetohexamide                VARCHAR(10),
    glipizide                    VARCHAR(10),
    glyburide                    VARCHAR(10),
    tolbutamide                  VARCHAR(10),
    pioglitazone                 VARCHAR(10),
    rosiglitazone                VARCHAR(10),
    acarbose                     VARCHAR(10),
    miglitol                     VARCHAR(10),
    troglitazone                 VARCHAR(10),
    tolazamide                   VARCHAR(10),
    examide                      VARCHAR(10),
    citoglipton                  VARCHAR(10),
    insulin                      VARCHAR(10),
    glyburide_metformin          VARCHAR(10),
    glipizide_metformin          VARCHAR(10),
    glimepiride_pioglitazone     VARCHAR(10),
    metformin_rosiglitazone      VARCHAR(10),
    metformin_pioglitazone       VARCHAR(10),
    change_med                   VARCHAR(5),
    diabetesMed                  VARCHAR(5),
    readmitted                   VARCHAR(10)
);

COPY INTO DIABETIC_PATIENTS
    FROM @patient_stage/diabetic_data.csv
    FILE_FORMAT = (
        TYPE = 'CSV'
        SKIP_HEADER = 1
        NULL_IF = ('?', '', 'NULL')
        EMPTY_FIELD_AS_NULL = TRUE
    )
    ON_ERROR = 'CONTINUE';

    SELECT COUNT(*) FROM DIABETIC_PATIENTS;

    ALTER TABLE DIABETIC_PATIENTS ADD COLUMN readmitted_30 INT DEFAULT 0;
UPDATE DIABETIC_PATIENTS SET readmitted_30 = 1 WHERE readmitted = '<30';

SELECT readmitted, readmitted_30, COUNT(*) AS count
FROM DIABETIC_PATIENTS
GROUP BY readmitted, readmitted_30
ORDER BY readmitted;
--Readmission rate summary
SELECT
    COUNT(*) AS total_patients,
    SUM(readmitted_30) AS readmitted,
    ROUND(SUM(readmitted_30) * 100.0 / COUNT(*), 2) AS readmission_pct
FROM DIABETIC_PATIENTS;

 --top readmission analysis
SELECT age, diag_1,
    COUNT(*) AS patient_count,
    SUM(readmitted_30) AS readmissions,
    ROUND(SUM(readmitted_30)*100.0/COUNT(*),2) AS readmission_pct
FROM DIABETIC_PATIENTS
WHERE diag_1 IS NOT NULL
GROUP BY age, diag_1
QUALIFY ROW_NUMBER() OVER(PARTITION BY age ORDER BY readmissions DESC) = 1
ORDER BY age;

CREATE OR REPLACE VIEW VW_READMISSION_SUMMARY AS
SELECT
    age, gender, insulin,
    COUNT(*) AS patients,
    ROUND(AVG(time_in_hospital), 1)  AS avg_stay,
    ROUND(AVG(num_medications), 1)   AS avg_meds,
    ROUND(SUM(readmitted_30)*100.0/COUNT(*), 2) AS readmission_rate
FROM DIABETIC_PATIENTS
GROUP BY age, gender, insulin;

SELECT * FROM VW_READMISSION_SUMMARY;

SELECT COUNT(*) AS current_count FROM DIABETIC_PATIENTS;

--deleting a row
DELETE FROM DIABETIC_PATIENTS WHERE age = '[0-10)';
SELECT COUNT(*) AS after_delete FROM DIABETIC_PATIENTS;

SELECT COUNT(*) AS before_delete
FROM DIABETIC_PATIENTS AT(OFFSET => -300);

--Restoring the deleted rows using TIME TRAVEL
INSERT INTO DIABETIC_PATIENTS
    SELECT * FROM DIABETIC_PATIENTS AT(OFFSET => -300)
    WHERE age = '[0-10)'
    AND encounter_id NOT IN (SELECT encounter_id FROM DIABETIC_PATIENTS);

SELECT COUNT(*) AS restored_count FROM DIABETIC_PATIENTS;
 
CREATE TABLE DIABETIC_PATIENTS_TEST CLONE DIABETIC_PATIENTS;
SELECT COUNT(*) FROM DIABETIC_PATIENTS_TEST;
