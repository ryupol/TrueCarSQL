-- Creating Database
CREATE DATABASE TrueCar;

SELECT TOP 10 *
FROM TrueCar..Vehicles

SELECT TOP 10 *
FROM TrueCar..Listings

SELECT TOP 1000 *
FROM TrueCar..Listings l
INNER JOIN TrueCar..Vehicles v
ON l.Id = v.Id;

-- Checking for null values in both tables (Vehicles & Listings)
SELECT *
FROM TrueCar..Listings l
INNER JOIN TrueCar..Vehicles v
ON l.Id = v.Id
WHERE coalesce(1, 2, 3, 4, 5, 6, 7, 8, 9, 10) IS NULL; -- There is no null value


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
DELETE FROM TrueCar..Cars WHERE Year = 2018

SELECT TOP 5 *
FROM TrueCar..Cars
ORDER BY Mileage DESC

DELETE FROM TrueCar..Cars WHERE Mileage > 70000000

-- Questions to Answer
	-- How many car listed per region and average car price per region

CREATE VIEW Per as
SELECT Region, COUNT(CONVERT(NUMERIC, Vehicle_ID)) as TotalCarsPerRegion,
		AVG(CONVERT(BIGINT, price)) as AveragePrice,
		SUM(CONVERT(NUMERIC, count(Vehicle_ID))) OVER () as NumberOfCars
FROM TrueCar..Cars
GROUP BY Region

SELECT Region, TotalCarsPerRegion, AveragePrice, (TotalCarsPerRegion/NumberOfCars)*100 as PercentageCarsRegion
FROM Per
ORDER BY PercentageCarsRegion DESC;


	-- Average car brand price

SELECT TOP 10 Region, Make, AVG(CONVERT(BIGINT, price)) as AveragePrice, COUNT(Vehicle_ID) as TotalCars
FROM TrueCar..Cars
GROUP BY Make, Region
ORDER BY TotalCars DESC;

	-- How many luxury vehicles listings per region
SELECT Region, count(CAST(Vehicle_ID as NUMERIC)) as TotalCars, avg(CAST(price as BIGINT)) as AveragePrice
FROM TrueCar..Cars
WHERE price > 100000
GROUP BY Region

CREATE VIEW Per as
SELECT Region, count(CONVERT(NUMERIC, Vehicle_ID)) as TotalCarsPerRegion,
		avg(CONVERT(BIGINT, price)) as AveragePrice,
		SUM(CONVERT(NUMERIC, count(Vehicle_ID))) OVER () as NumberOfCars
FROM TrueCar..Cars
GROUP BY Region

SELECT Region, TotalCarsPerRegion, AveragePrice, (TotalCarsPerRegion/NumberOfCars)*100 as PercentageCarsRegion
FROM Per
ORDER BY PercentageCarsRegion DESC;


	-- Luxury
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

SELECT Make, AVG(CONVERT(BIGINT, price)) as AveragePrice, COUNT(Vehicle_ID) as TotalCars
FROM TrueCar..Cars
GROUP BY Make
ORDER BY TotalCars DESC;

SELECT *
FROM TrueCar..Cars