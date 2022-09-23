-- Creating Database
CREATE DATABASE TrueCar;

-- Checking Vehicles Table
SELECT TOP 10 *
FROM TrueCar..Vehicles

-- Checking Listings Table
SELECT TOP 10 *
FROM TrueCar..Listings

-- Join table
SELECT TOP 1000 *
FROM TrueCar..Listings l
INNER JOIN TrueCar..Vehicles v
ON l.Id = v.Id;

-- Checking for null values in both tables (Vehicles & Listings)
SELECT	
	SUM(CASE WHEN l.Id IS NULL THEN 1 ELSE 0 END) AS null_id1,
	SUM(CASE WHEN Price IS NULL THEN 1 ELSE 0 END) AS null_price,
	SUM(CASE WHEN Mileage IS NULL THEN 1 ELSE 0 END) AS null_city_state,
	SUM(CASE WHEN Region IS NULL THEN 1 ELSE 0 END) AS null_region,
	SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS null_city,
	SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS null_state,
	SUM(CASE WHEN v.Id IS NULL THEN 1 ELSE 0 END) AS null_id2,
	SUM(CASE WHEN Year IS NULL THEN 1 ELSE 0 END) AS null_year,
	SUM(CASE WHEN Vin IS NULL THEN 1 ELSE 0 END) AS null_vin,
	SUM(CASE WHEN Make IS NULL THEN 1 ELSE 0 END) AS null_make,
	SUM(CASE WHEN model IS NULL THEN 1 ELSE 0 END) AS null_model
FROM TrueCar..Listings l
INNER JOIN TrueCar..Vehicles v
ON l.Id = v.Id; 
-- There is no null value


-- Separate City & State into 2 columns (City column and State column)
ALTER TABLE TrueCar..Listings
ADD City VARCHAR(50),
	State VARCHAR(5);

UPDATE TrueCar..Listings
SET City = SUBSTRING(TRIM([City State]), 1, LEN(TRIM([City State])) - 2),
	State = SUBSTRING(TRIM([City State]), LEN(TRIM([City State])) - 2, 
			LEN(TRIM([City State])));

SELECT TOP 5 [City State], City, State
FROM TrueCar..Listings;

-- Checking for duplicate row using CTEs
WITH RowNumber AS
(
SELECT l.id, Vin, Make, Model, Year, Mileage, City,
		State, Region, Price,
		ROW_NUMBER() OVER(
		PARTITION BY Vin, Make, Model, Year, 
		Mileage, City, State, Region, Price
		ORDER BY l.Id) as NumberOfRow
FROM TrueCar..Listings l
INNER JOIN TrueCar..Vehicles v
ON l.Id = v.Id
)

SELECT *
FROM RowNumber
WHERE NumberOfRow > 1;


-- Create new table (Cars)
CREATE TABLE TrueCar..Cars (
	Vehicle_ID INT PRIMARY KEY NOT NULL,
	VIN VARCHAR(20) UNIQUE NOT NULL,
	Make VARCHAR(50) NOT NULL,
	Model VARCHAR(100) NOT NULL,
	Year SmallINT NOT NULL,
	Mileage INT NOT NULL,
	City VARCHAR(50) NOT NULL,
	State VARCHAR(5) NOT NULL,
	Region VARCHAR(50) NOT NULL,
	Price INT NOT NULL
	);

INSERT INTO TrueCar..Cars
SELECT l.id, Vin, Make, Model, Year, Mileage, City, State, Region, Price
FROM TrueCar..Listings l
INNER JOIN TrueCar..Vehicles v
ON l.Id = v.Id;

-- DELETE Year 2018
DELETE FROM TrueCar..Cars WHERE Year = 2018;

-- Checking Mileage Outlier
SELECT TOP 5 *
FROM TrueCar..Cars
ORDER BY Mileage DESC;

-- Delete Mileage Outlier
DELETE FROM TrueCar..Cars WHERE Mileage > 70000000;


-- Questions to Answer

	-- 1. How many car listed per region and average car price per region
CREATE VIEW Per as
SELECT Region, count(CONVERT(NUMERIC, Vehicle_ID)) as TotalCarsPerRegion,
		avg(CONVERT(BIGINT, price)) as AveragePrice,
		SUM(CONVERT(NUMERIC, count(Vehicle_ID))) OVER () as NumberOfCars
FROM TrueCar..Cars
GROUP BY Region

SELECT Region, TotalCarsPerRegion, AveragePrice, (TotalCarsPerRegion/NumberOfCars)*100 as PercentageCarsRegion
FROM Per
ORDER BY PercentageCarsRegion DESC;


	-- 2. How many luxury vehicles listed per region and average car price per region
CREATE VIEW LuxuryPer as
SELECT Region, count(CONVERT(NUMERIC, Vehicle_ID)) as TotalCarsPerRegion,
		avg(CONVERT(BIGINT, price)) as AveragePrice,
		SUM(CONVERT(NUMERIC, count(Vehicle_ID))) OVER () as NumberOfCars
FROM TrueCar..Cars
WHERE Price > 100000
GROUP BY Region

SELECT Region, TotalCarsPerRegion, AveragePrice, (TotalCarsPerRegion/NumberOfCars)*100 as PercentageCarsRegion
FROM LuxuryPer
ORDER BY PercentageCarsRegion DESC;

	-- 3. Most popular Car Brand
SELECT Make, AVG(CONVERT(BIGINT, price)) as AveragePrice, COUNT(Vehicle_ID) as TotalCars
FROM TrueCar..Cars
GROUP BY Make
ORDER BY TotalCars DESC;

	-- 4. What about Median of Car Brand Price
SELECT a.Make, MAX(B.Median) as MedianPrice, COUNT(a.Vehicle_ID) as TotalCar
FROM TrueCar..Cars as a
INNER JOIN (SELECT DISTINCT Make, PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY Price)
OVER (PARTITION BY Make) as Median FROM TrueCar..Cars) as b
ON a.Make = b.Make
GROUP BY a.Make
ORDER BY TotalCar DESC;


-- Cars Table for import to analyst in Python and visualize in Tableau
SELECT *
FROM TrueCar..Cars

