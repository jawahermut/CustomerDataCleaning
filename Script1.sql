CREATE schema WorldLayoffs;

use WorldLayoffs;

SELECT * from layoffs;

/* Start Data Cleaning Project
 * 1. Remove any Duplicate 
 * 2. Standardize the Data
 * 3. Null Values or Blank values
 * 4. Remove any Columns
 * 
 * */


/* انشاء تيبل جديد و انسخ فيه معلومات ال layoffs */
/*هنا نسخ الجدول لكن بدون البيانات*/
CREATE table layoffs_staging
like layoffs;

SELECT * from layoffs_staging;

/*هنا انسخ البيانات */
INSERT layoffs_staging select * FROM layoffs ;

/* في العمليات السابقة نسخت البيانات في ستيج جديدة عشان احللها بكل اريحيه بدون الخوف من ضياع بعض البيانات ، 
 * يعتبر اني سويت لها باك اب*/


/** 1. Remove any Duplicate
 * اضافة عامود جديد لحساب كم مره تكرر الصف */
/*اسوي فلترة اذا كان الرقم اكبر من ١ معناه عندي تكرار دبلكيت*/
SELECT * ,
ROW_NUMBER() over(
PARTITION by company, location, industry, total_laid_off,percentage_laid_off,`date`) AS row_num
from layoffs_staging;

/*تحديد الصفوف المتكررة*/
with duplicate_cte as
(
SELECT * ,
ROW_NUMBER() over(
PARTITION by company, location, industry, total_laid_off,percentage_laid_off,`date`, 
stage, country, funds_raised_millions) AS row_num
from layoffs_staging
)
select * FROM duplicate_cte WHERE row_num > 1;

/*هنا عندي اثنين متكررين */
SELECT * FROM layoffs_staging WHERE company ='Casper';



/* create table layoffs_staging2 */

-- WorldLayoffs.layoffs_staging definition

CREATE TABLE `layoffs_staging2` (
  `company` varchar(50) DEFAULT NULL,
  `location` varchar(50) DEFAULT NULL,
  `industry` varchar(50) DEFAULT NULL,
  `total_laid_off` varchar(50) DEFAULT NULL,
  `percentage_laid_off` varchar(50) DEFAULT NULL,
  `date` varchar(50) DEFAULT NULL,
  `stage` varchar(50) DEFAULT NULL,
  `country` varchar(50) DEFAULT NULL,
  `funds_raised_millions` varchar(50) DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


/* هنا الجدول نفسه لكن بدون بيانات */

SELECT * from layoffs_staging2;

/* عشان اخزن نفس البيانات اللي في ستيج١ اكتب : */

INSERT INTO layoffs_staging2
SELECT * ,
ROW_NUMBER() over(
PARTITION by company, location, industry, total_laid_off,percentage_laid_off,`date`, 
stage, country, funds_raised_millions) AS row_num
from layoffs_staging;

/* الان ابدأ الفلترة */
/* هذا الامر يطلع لي التسجيلات المكررة */
SELECT * FROM layoffs_staging2 
WHERE row_num > 1 ;

/* الان ابدأ حذف التسجيلات المتكررة */

DELETE FROM layoffs_staging2 WHERE row_num > 1;


/*Standardizing Data : it is finding issuse in the data and fixing it
 * 
 * ١. بحذف المسافة اللي في بداية الكلمات
 *  */

SELECT company, TRIM(company) from layoffs_staging2;

/*عشان اتخلص من المسافة*/
UPDATE layoffs_staging2 SET company = TRIM(company);


/*look at industry */
SELECT DISTINCT industry from layoffs_staging2
order by 1;


SELECT * FROM layoffs_staging2 WHERE industry LIKE 'Crypto%';

/*update all of them to be crypto*/

UPDATE layoffs_staging2 SET industry = 'Crypto' WHERE industry LIKE 'Crypto%';


/*look at locations */ 
SELECT DISTINCT location from layoffs_staging2 order by 1;


/*look at country */ 
SELECT DISTINCT country from layoffs_staging2 order by 1;

 /* المشكلة هنا تكرار الاسم مع وجود نقطة فالنهاية United States. 
  * 
  * الواضح انه تنكتب بدون نقطة */ 
SELECT * 
from layoffs_staging2 
WHERE country LIKE 'United States%'
order by 1;

/* لحل هذي المشكلة احذف النقطة من كل اسم 
 * 
 *  TRAILING معناه شي جاي فالنهاية*/
SELECT DISTINCT country, TRIM(TRAILING '.' FROM country) from layoffs_staging2 order by 1;

/*  بعد ماضبط التريلنق اسوي ابديت لعامود الكونتري في الجدول  */

UPDATE layoffs_staging2 SET country = TRIM(TRAILING '.' FROM country) WHERE country LIKE  'United States%';


/*Standardizing Data : it is finding issuse in the data and fixing it
 * 
 * ١. بحذف المسافة اللي في بداية الكلمات
 *  
 * 2. change the date(
 * 1. format it to mm-dd-yyyy 
 * 2. update the date to the new formate)*/

SELECT * FROM layoffs_staging2;

SELECT  `date` from layoffs_staging2;


SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
from layoffs_staging2;


SELECT * FROM layoffs_staging2 WHERE `date` is NULL;
UPDATE layoffs_staging2 SET `date` = NULL WHERE `date` = 'NULL';


SELECT * FROM layoffs_staging2 WHERE `date` is NULL;
UPDATE layoffs_staging2 SET `date` = NULL WHERE `date` = 'NULL';

/*  2. update the date to the new formate*/
UPDATE layoffs_staging2 SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');


/* اغير التاريخ من فارشار الى ديت تايب */

ALTER table layoffs_staging2 modify column `date` DATE;



/*Standardizing Data : it is finding issuse in the data and fixing it
 * step 3 : looking for blank values */
SELECT
* FROM layoffs_staging2 
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL ;


SELECT * FROM layoffs_staging2 WHERE funds_raised_millions = 'NULL' ;
UPDATE layoffs_staging2 SET funds_raised_millions = NULL WHERE funds_raised_millions = 'NULL';


SELECT * FROM layoffs_staging2 WHERE industry  = 'NULL' ;
UPDATE layoffs_staging2 SET industry = NULL WHERE industry = 'NULL';


SELECT * FROM layoffs_staging2 WHERE percentage_laid_off = 'NULL' ;
UPDATE layoffs_staging2 SET percentage_laid_off = NULL WHERE percentage_laid_off = 'NULL';


SELECT * from layoffs_staging2 WHERE industry IS NULL OR industry = '';


SELECT * FROM layoffs_staging2 WHERE company LIKE 'Bally%';


/* تعبية الفراغات */

UPDATE layoffs_staging2 SET industry = NULL WHERE industry ='';

SELECT * FROM layoffs_staging2 t1 join layoffs_staging2 t2 on t1.company =t2.company 
WHERE (t1.industry IS NULL OR t1.industry = '') 
AND  t2.industry IS NOT NULL ;


UPDATE  layoffs_staging2 t1 
join layoffs_staging2 t2 
on t1.company =t2.company 
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND  t2.industry IS NOT NULL ;

/*these doesn't have enough information for it and i think no need for it*/

SELECT
* FROM layoffs_staging2 
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL ;

DELETE  FROM layoffs_staging2 
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL ;

SELECT * FROM layoffs_staging2;

/* delete row_num because no need for it anymore*/

ALTER TABLE layoffs_staging2 DROP COLUMN row_num;



