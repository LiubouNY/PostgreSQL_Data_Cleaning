--Data Cleaning

---Remove Duplicates
---Standardize the Data
---NULL or Blank Values
---Removing unnecessary columns

--Creating table and coping data from CSV file into table

CREATE OR REPLACE TABLE world_layoffs.layoffs (
	company VARCHAR(50),
	location VARCHAR(50),
	industry VARCHAR(50),
	total_laid_of NUMERIC(10),
	percentage_laid_off NUMERIC(3,2),
	date DATE,
	stage VARCHAR(50),
	country VARCHAR(50),
	funds_raised NUMERIC(10)
);

COPY world_layoffs.layoffs 
FROM 'C:\Users\16469\Downloads\layoffs.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM world_layoffs.layoffs;

--Creating staging table for further manipulations

CREATE  TABLE world_layoffs.layoffs_staging
AS SELECT * FROM world_layoffs.layoffs;
	
--Check how new statging table working

SELECT * FROM world_layoffs.layoffs_staging;



---Removing Duplicates
--Creating SELECT statement with ROW_NUMBER window function to assing row numbers, 
--PARTITION BY all column for more accurate results. Rows with number 2 will be duplicates.
--Creating CTE based on this SELECT statement

SELECT *, 
ROW_NUMBER() OVER(
	PARTITION BY company, location, industry, total_laid_off, 
	percentage_laid_off, date, stage, country, funds_raised) AS row_num
FROM world_layoffs.layoffs_staging;


WITH duplicates_CTE AS
(
SELECT *, 
ROW_NUMBER() OVER(
	PARTITION BY company, location, industry, total_laid_off, 
	percentage_laid_off, date, stage, country, funds_raised) AS row_num
FROM world_layoffs.layoffs_staging
)
SELECT * 
FROM duplicates_CTE
WHERE row_num > 1;

--Double check how CTE is working

SELECT * 
FROM world_layoffs.layoffs_staging
WHERE company = 'Beyond Meat';

--Creating new staging table to delete duplicate, because you can't just delete duplicates from CTE

CREATE TABLE world_layoffs.layoffs_staging_2
AS 
SELECT *, 
ROW_NUMBER() OVER(
	PARTITION BY company, location, industry, total_laid_off, 
	percentage_laid_off, date, stage, country, funds_raised) AS row_num
FROM world_layoffs.layoffs_staging;

--Identify duplicates and delete them

SELECT * FROM 
world_layoffs.layoffs_staging_2
WHERE row_num > 1;

DELETE  FROM 
world_layoffs.layoffs_staging_2
WHERE row_num > 1;

SELECT * FROM 
world_layoffs.layoffs_staging_2;



---Standardizing Data

--Trimming extra space in companies' names

SELECT company, TRIM(company)
FROM  world_layoffs.layoffs_staging_2;

UPDATE  world_layoffs.layoffs_staging_2
SET company = TRIM(company);

SELECT DISTINCT industry
FROM  world_layoffs.layoffs_staging_2
ORDER BY 1;

UPDATE world_layoffs.layoffs_staging_2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

--Unifying location names

SELECT DISTINCT location
FROM  world_layoffs.layoffs_staging_2
ORDER BY 1;

SELECT location
FROM 
world_layoffs.layoffs_staging_2
WHERE location = 'Düsseldorf' OR location = 'Dusseldorf';

UPDATE world_layoffs.layoffs_staging_2
SET location = 'Dusseldorf'
WHERE location LIKE 'Düsseldorf';

--Deleting dot in the end of country name

SELECT DISTINCT country 
FROM world_layoffs.layoffs_staging_2
ORDER BY 1;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM world_layoffs.layoffs_staging_2
ORDER BY 1;

UPDATE  world_layoffs.layoffs_staging_2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United states%';


--Handling NULL values

--Looking for NULL values

SELECT *
FROM world_layoffs.layoffs_staging_2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM world_layoffs.layoffs_staging_2
WHERE company = 'Appsmith';

--Using SELF JOIN to indentify populated and not populated columns

SELECT * 
FROM world_layoffs.layoffs_staging_2 t1
JOIN world_layoffs.layoffs_staging_2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;

--Updateting table to populate columnns

--Changing rows with blank to NULL value

UPDATE world_layoffs.layoffs_staging_2 
SET industry = NULL
WHERE industry = '';

UPDATE world_layoffs.layoffs_staging_2 
SET industry = t2.industry
FROM world_layoffs.layoffs_staging_2 t1
JOIN world_layoffs.layoffs_staging_2 t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT * 
FROM world_layoffs.layoffs_staging_2
WHERE industry IS NULL;

SELECT *
FROM world_layoffs.layoffs_staging_2;

--Deleting not useful rows with NULL value (not trustful data)

SELECT *
FROM world_layoffs.layoffs_staging_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM world_layoffs.layoffs_staging_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM world_layoffs.layoffs_staging_2;

--Droping unnecessary columns
ALTER TABLE world_layoffs.layoffs_staging_2
DROP COLUMN row_num;


