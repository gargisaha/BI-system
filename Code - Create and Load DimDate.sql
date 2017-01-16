
drop table dimDate
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
DayNameOfWeek [varchar] (9) NOT NULL,
DayNumberOfMonth [tinyint] NOT NULL,
DayNumberOfYear [int] NOT NULL,
WeekdayFlag [int] NOT NULL,
WeekNumberOfYear [tinyint] NOT NULL,
[MonthName] [varchar](9) NOT NULL,
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

-- =========================================================================
-- Create Stored Proceudre InsDimDateyearly to load one year of data
-- =========================================================================

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

-- load date dimension table with all dates
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

-- ========================================================================
-- Execute the procedure for 2013 and 2014 (those are the years you need)
-- ========================================================================
EXEC InsDimDateYearly 2013

EXEC InsDimDateYearly 2014
