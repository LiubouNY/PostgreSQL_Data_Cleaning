-- Exploratory Data Analysis

SELECT * 
FROM world_layoffs.layoffs_staging_2;

-- Looking into date range
SELECT MIN(date), MAX(date) 
FROM world_layoffs.layoffs_staging_2;

-- Looking at maximum number of laid offs in one day
-- And find out the companies who laid off all of their workers 
-- If percentage_laid_off = 1 then company laid off all of their workers

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM world_layoffs.layoffs_staging_2;


--The biggest companies who had to laid of all of their workers
SELECT * 
FROM world_layoffs.layoffs_staging_2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

--The companies who raised the most fundings after laid offs
SELECT * 
FROM world_layoffs.layoffs_staging_2
WHERE percentage_laid_off = 1
ORDER BY funds_raised DESC;

-- Find out the companies with most laid off in last years
SELECT company, SUM(total_laid_off) 
FROM world_layoffs.layoffs_staging_2
WHERE total_laid_off IS NOT NULL
GROUP BY company
ORDER BY SUM(total_laid_off) DESC;

--Looking at the industry with largest laid off numbers
SELECT industry, SUM(total_laid_off) 
FROM world_layoffs.layoffs_staging_2
WHERE total_laid_off IS NOT NULL
GROUP BY industry
ORDER BY SUM(total_laid_off) DESC;

--Looking at the country with largest laid off numbers
SELECT country, SUM(total_laid_off) 
FROM world_layoffs.layoffs_staging_2
WHERE total_laid_off IS NOT NULL 
GROUP BY country
ORDER BY SUM(total_laid_off) DESC;

--Looking at the country with largest laid off numbers in 2024
SELECT country, SUM(total_laid_off) 
FROM world_layoffs.layoffs_staging_2
WHERE total_laid_off IS NOT NULL 
AND EXTRACT(YEAR FROM date) = 2024
GROUP BY country
ORDER BY SUM(total_laid_off) DESC;

--Find out most of the laid off by the year
SELECT EXTRACT(YEAR FROM date), SUM(total_laid_off) 
FROM world_layoffs.layoffs_staging_2
WHERE total_laid_off IS NOT NULL 
GROUP BY EXTRACT(YEAR FROM date)
ORDER BY SUM(total_laid_off) DESC;


--Looking at the progression of laid offs (rolling total of laid offs)
SELECT TO_CHAR(date, 'YYYY-MM') AS month, SUM(total_laid_off)
FROM world_layoffs.layoffs_staging_2
WHERE total_laid_off IS NOT NULL 
GROUP BY TO_CHAR(date, 'YYYY-MM')
ORDER BY 1 ASC;

WITH rolling_total AS (
SELECT TO_CHAR(date, 'YYYY-MM') AS month, SUM(total_laid_off) as total_off
FROM world_layoffs.layoffs_staging_2
WHERE total_laid_off IS NOT NULL 
GROUP BY TO_CHAR(date, 'YYYY-MM')
ORDER BY 1 ASC
)
SELECT month, total_off, 
SUM(total_off) OVER(ORDER BY month) AS rolling_total
FROM rolling_total;

-- Finding company with most of the laid offs in a given year
SELECT company, TO_CHAR(date, 'YYYY'), SUM(total_laid_off) 
FROM world_layoffs.layoffs_staging_2
WHERE total_laid_off IS NOT NULL
GROUP BY company, TO_CHAR(date, 'YYYY')
ORDER BY company ASC, TO_CHAR(date, 'YYYY') ASC;


--Ranking companies by laid offs in a year
WITH company_year (company, years, total_laid_off) AS 
(
SELECT company, TO_CHAR(date, 'YYYY'), SUM(total_laid_off) 
FROM world_layoffs.layoffs_staging_2
WHERE total_laid_off IS NOT NULL
GROUP BY company, TO_CHAR(date, 'YYYY')
)
SELECT *,
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM company_year
WHERE years IS NOT NULL
ORDER BY ranking
;

--Top 5 companies with most laid offs per year
WITH company_year (company, years, total_laid_off) AS 
(
SELECT company, TO_CHAR(date, 'YYYY'), SUM(total_laid_off) 
FROM world_layoffs.layoffs_staging_2
WHERE total_laid_off IS NOT NULL
GROUP BY company, TO_CHAR(date, 'YYYY')
),
company_year_rank AS 
(
SELECT *,
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS ranking
FROM company_year
WHERE years IS NOT NULL
)
SELECT * 
FROM company_year_rank
WHERE ranking <=5
;