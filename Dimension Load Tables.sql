--CREATE THE DIMPRODUCT DIMENSION TABLE

CREATE TABLE dbo.dimProduct 
(
dimProductKey INT IDENTITY(1,1) PRIMARY KEY,
ProductID INT,
Product NVARCHAR(255) NOT NULL,
ProductCategory NVARCHAR(255) NOT NULL,
ProductType NVARCHAR(255) NOT NULL,
Color NVARCHAR(255) NULL,
Style NVARCHAR(255) NULL,
Weight DECIMAL(20,4) NULL,
Price DECIMAL(20,4) NULL,
Cost  DECIMAL(20,4) NULL,
WholesalePrice DECIMAL(20,4) NULL,
WholesaleProfitMargin INT NULL,
ProfitMargin INT NULL,
UnitofMeasure NVARCHAR(255) NOT NULL,
);



--CREATE THE DIMCHANNEL DIMENSION TABLE

CREATE TABLE dbo.dimChannel
(
dimChannelkey INT IDENTITY(1,1) PRIMARY KEY,
ChannelID int,
Channel NVARCHAR(255) NOT NULL,
ChannelCategory NVARCHAR(255) NOT NULL,
);

--CREATE THE DIMLOCATION DIMENSION TABLE

CREATE TABLE dbo.dimLocation
(
dimLocationID INT IDENTITY(1,1) PRIMARY KEY,
Address NVARCHAR(255) NOT NULL,
City NVARCHAR(255) NOT NULL,
StateProvince NVARCHAR(255) NOT NULL,
Country NVARCHAR(255) NOT NULL,
PostalCode NVARCHAR(255) NOT NULL,
);

--CREATE THE DIMCUSTOMER DIMENSION TABLE

CREATE TABLE dbo.dimCustomer
(
dimCustomerKey INT IDENTITY(1,1) PRIMARY KEY,
CustomerID uniqueidentifier,
FirstName NVARCHAR(255),
LastName NVARCHAR(255),
Gender NVARCHAR(255),
EmailAddress NVARCHAR(255),
PhoneNumber NVARCHAR(255) NOT NULL,
SubSegmentID int,
dimCustomerLocationID INT FOREIGN KEY REFERENCES dimLocation(dimLocationID)
);

--CREATE THE DIMSTORE DIMENSION TABLE

CREATE TABLE dbo.dimStore
(
dimStoreKey INT IDENTITY(1,1) PRIMARY KEY,
StoreID int,
StoreNumber NVARCHAR(255) NOT NULL,
StoreManager NVARCHAR(255) NOT NULL,
PhoneNumber NVARCHAR(255) NOT NULL,
SubSegmentID int,
dimStoreLocationID INT FOREIGN KEY REFERENCES dimLocation(dimLocationID)
);


--CREATE THE DIMRESELLER DIMENSION TABLE

CREATE TABLE dbo.dimReseller
(
dimResellerKey INT IDENTITY(1,1) PRIMARY KEY,
ResellerID uniqueidentifier,
ResellerName NVARCHAR(255) NOT NULL,
Contact NVARCHAR(255) NOT NULL,
EmailAddress NVARCHAR(255) NOT NULL,
PhoneNumber NVARCHAR(255) NOT NULL,
dimResellerLocationID INT FOREIGN KEY REFERENCES dimLocation(dimLocationID)
);


--CREATE THE DIMSEGMENT DIMENSION TABLE

CREATE TABLE dbo.dimSegment
(
dimSegmentKey INT IDENTITY(1,1) PRIMARY KEY,
SegmentID int,
SubSegmentID int,
Segment NVARCHAR(255) NOT NULL,
SubSegment NVARCHAR(255) NOT NULL,
);




-- ====================================
-- Create DimDate table
-- ====================================

IF EXISTS (SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'DimDate')
BEGIN
	DROP TABLE dbo.DimDate;
END
GO

CREATE TABLE dbo.DimDate
(
DimDateID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_DimDate PRIMARY KEY,
FullDate [date] NOT NULL,
DayNumberOfWeek [tinyint] NOT NULL,
DayNameOfWeek [NVARCHAR] (9) NOT NULL,
DayNumberOfMonth [tinyint] NOT NULL,
DayNumberOfYear [int] NOT NULL,
WeekdayFlag [int] NOT NULL,
WeekNumberOfYear [tinyint] NOT NULL,
[MonthName] [NVARCHAR](9) NOT NULL,
MonthNumberOfYear [tinyint] NOT NULL,
CalendarQuarter [tinyint] NOT NULL,
CalendarYear [int] NOT NULL,
CalendarSemester [tinyint] NOT NULL,
CreatedDate DATETIME NOT NULL
,CreatedBy NVARCHAR(255) NOT NULL
,ModifiedDate DATETIME NULL
,ModifiedBy NVARCHAR(255) NULL
);
GO

--CREATE STORED PROCEUDRE INSDIMDATEYEARLY TO LOAD ONE YEAR OF DATA


IF EXISTS (SELECT name FROM sys.procedures WHERE name = 'InsDimDateYearly')
BEGIN
	DROP PROCEDURE dbo.InsDimDateYearly;
END
GO

CREATE PROC [dbo].[InsDimDateYearly]
( 
	@Year INT=NULL
)
AS
SET NOCOUNT ON;

DECLARE @Date DATE, @FirstDate Date, @LastDate Date;

SELECT @Year=COALESCE(@Year,YEAR(DATEADD(d,1,MAX(DimDateID)))) FROM dbo.DimDate;

SET @FirstDate=DATEFROMPARTS(COALESCE(@Year,YEAR(GETDATE())-1), 01, 01); -- First Day of the Year
SET @LastDate=DATEFROMPARTS(COALESCE(@Year,YEAR(GETDATE())-1), 12, 31); -- Last Day of the Year

SET @Date=@FirstDate;
-- create CTE with all dates needed for load
;WITH DateCTE AS
(
SELECT @FirstDate AS StartDate -- earliest date to load in table
UNION ALL
SELECT DATEADD(day, 1, StartDate)
FROM DateCTE -- recursively select the date + 1 over and over
WHERE DATEADD(day, 1, StartDate) <= @LastDate -- last date to load in table
)

-- LOAD DATE DIMENSION TABLE WITH ALL DATES
INSERT INTO dbo.DimDate 
	(
	FullDate 
	,DayNumberOfWeek 
	,DayNameOfWeek 
	,DayNumberOfMonth 
	,DayNumberOfYear 
	,WeekdayFlag
	,WeekNumberOfYear 
	,[MonthName] 
	,MonthNumberOfYear 
	,CalendarQuarter 
	,CalendarYear 
	,CalendarSemester
	,CreatedDate
	,CreatedBy
	,ModifiedDate
	,ModifiedBy 
	)
SELECT 
	 CAST(StartDate AS DATE) AS FullDate
	,DATEPART(dw, StartDate) AS DayNumberOfWeek
	,DATENAME(dw, StartDate) AS DayNameOfWeek
	,DAY(StartDate) AS DayNumberOfMonth
	,DATEPART(dy, StartDate) AS DayNumberOfYear
	,CASE DATENAME(dw, StartDate) WHEN 'Saturday' THEN 0 WHEN 'Sunday' THEN 0 ELSE 1 END AS WeekdayFlag
	,DATEPART(wk, StartDate) AS WeekNumberOfYear
	,DATENAME(mm, StartDate) AS [MonthName]
	,MONTH(StartDate) AS MonthNumberOfYear
	,DATEPART(qq, StartDate) AS CalendarQuarter
	,YEAR(StartDate) AS CalendarYear
	,(CASE WHEN MONTH(StartDate)>=1 AND MONTH(StartDate) <=6 THEN 1 ELSE 2 END) AS CalendarSemester
	,DATEADD(dd,DATEDIFF(dd,GETDATE(), '2013-01-01'),GETDATE()) AS CreatedDate
	,'company\SQLServerServiceAccount' AS CreatedBy
	,NULL AS ModifiedDate
	,NULL AS ModifiedBy
FROM DateCTE
OPTION (MAXRECURSION 0);-- prevents infinate loop from running more than once
GO


-- EXECUTE THE PROCEDURE FOR 2013 AND 2014 (THOSE ARE THE YEARS YOU NEED)


EXEC InsDimDateYearly 2013

EXEC InsDimDateYearly 2014
