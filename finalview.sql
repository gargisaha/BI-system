create view dbo.ProductView
as
select dp.Product, dp.ProductCategory, dp.ProductType, SUM(fs.TotalQuantity) as TotalSalesQuantity, sum(fs.TotalAmount) as TotalAmount, dd.FullDate, dd.MonthName, dd.CalendarYear, fsp.SalesQuantityTarget as SalesQuantityTarget, dp.Color,dp.Price,dp.ProfitMargin,dp.cost
from factSalesProduct fsp

LEFT JOIN 
(
select dimProductID,dimDateID,sum(SalesQuantity) As TotalQuantity, sum(SalesAmount) as TotalAmount
from factSales
GROUP BY dimProductID, dimDateID
) fs 
on fsp.dimProductID = fs.dimProductID and fsp.dimDateID=fs.dimDateID
JOIN dimProduct dp
on fsp.dimProductID = dp.dimProductKey
jOIN DimDate dd
on fsp.dimDateID = dd.DimDateID
group by
dp.ProductCategory, dp.ProductType, dp.Product,fsp.SalesQuantityTarget,dd.FullDate,dd.CalendarYear,dd.MonthName,dp.Color,dp.Price,dp.ProfitMargin,dp.Cost

select * from ProductView
drop view ProductView