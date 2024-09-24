# WorldLayoffs Data Cleaning Project

## overview 
This project is focused on cleaning and standardizing the layoffs dataset, which tracks layoffs across companies worldwide. The project follows a series of steps to ensure that the data is clean, standardized, and ready for analysis.

## Key Steps in the Process:
- Schema Creation: A new schema WorldLayoffs is created to organize the data.
- Data Staging: A new staging table layoffs_staging is created to hold a copy of the original data for data cleaning.
- Data Cleaning: Several steps are applied to clean the data, including removing duplicates, standardizing fields, and handling NULL or empty values.

## Project Steps
1. Schema and Table Setup
Create Schema: The schema WorldLayoffs is created.
Create Staging Table: A new table layoffs_staging is created as a copy of the original layoffs table without data.
```sql
CREATE SCHEMA WorldLayoffs;
USE WorldLayoffs;
CREATE TABLE layoffs_staging LIKE layoffs;
INSERT INTO layoffs_staging SELECT * FROM layoffs;
```

2. Remove Duplicates
To remove duplicates:
- A new column is added to calculate how many times each row appears based on key fields.
- Duplicates are identified using a ROW_NUMBER() function.
```sql
SELECT *,
ROW_NUMBER() OVER (
    PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`
) AS row_num
FROM layoffs_staging;
```

- The duplicate rows are then deleted from the data.
```sql
DELETE FROM layoffs_staging2 WHERE row_num > 1;
```
3. Standardizing Data
a. Remove Leading/Trailing Spaces
To clean text fields, leading and trailing spaces are removed.
```sql
UPDATE layoffs_staging2 SET company = TRIM(company);
```
b. Standardizing Industries
Some industry names are inconsistent. For example, all variations of "Crypto" are standardized to "Crypto".
```sql
UPDATE layoffs_staging2 SET industry = 'Crypto' WHERE industry LIKE 'Crypto%';
```
c. Fixing Country Names
Trailing periods are removed from country names like "United States." to ensure consistency.
```sql
UPDATE layoffs_staging2 SET country = TRIM(TRAILING '.' FROM country) WHERE country LIKE 'United States%';
```
4. Date Formatting and Conversion
Convert date fields from VARCHAR to the DATE type after ensuring proper format (MM/DD/YYYY).
```sql
UPDATE layoffs_staging2 SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');
ALTER TABLE layoffs_staging2 MODIFY COLUMN `date` DATE;
```
5. Handling NULL and Blank Values
- Blank or NULL values are identified and corrected. For example, fields like industry, funds_raised_millions, and percentage_laid_off are updated to handle missing values.
```sql
UPDATE layoffs_staging2 SET industry = NULL WHERE industry = '';
```
- Missing data for some fields is populated using information from other rows with matching company names.
```sql
UPDATE layoffs_staging2 t1 
JOIN layoffs_staging2 t2 
ON t1.company = t2.company 
SET t1.industry = t2.industry
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;
```
- Rows with insufficient information are deleted from the dataset.
 ```sql
  DELETE FROM layoffs_staging2 
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;
```
6. Final Steps
The row_num column, used for duplicate detection, is no longer needed and is dropped.
```sql
ALTER TABLE layoffs_staging2 DROP COLUMN row_num;
```

## Conclusion
The layoffs_staging2 table now contains clean, standardized data, ready for further analysis or reporting. The steps outlined ensure the removal of duplicates, proper formatting of data, and handling of null or inconsistent values.

## Technologies Used
- SQL: For data manipulation and cleaning.
- DBeaver: As a SQL editor and database management tool.
- GitHub: For version control and collaboration.

