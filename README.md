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
