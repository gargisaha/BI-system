--CREATE FACT TABLE factSalesProduct

CREATE TABLE factSalesProduct(
factSalesProductID int Identity(1,1),
dimDateID int default -1,
dimProductID int default -1,
SalesQuantityTarget NVARCHAR(255)
Constraint fk_fsp_dim_date foreign key (dimDateID)
references dimDate(dimDateID),
Constraint fk_fsp_dim_product foreign key (dimProductID)
references dimProduct(dimProductKey)
)


--CREATE FACT TABLE factSalesAmount

CREATE TABLE factSalesAmount(
factSalesTargetID int Identity(1,1),
dimResellerID int default -1,
dimChannelID int default -1,
dimDateID int default -1,
dimStoreID int default -1,
TargetSalesAmount decimal(20,4)
Constraint fk_fst_dim_reseller foreign key (dimResellerID)
references dimReseller(dimResellerKey),
Constraint fk_fst_dim_channel foreign key (dimChannelID)
references dimChannel(dimChannelKey),
Constraint fk_fst_dim_date foreign key (dimDateID)
references dimDate(dimDateID),
Constraint fk_fst_dim_store foreign key (dimStoreID)
references dimStore(dimStoreKey)
)

--CREATE FACT TABLE factSales

CREATE TABLE factSales(
factSalesID int,
dimProductID int default -1,
dimResellerID int default -1,
dimChannelID int default -1,
dimDateID int default -1,
dimStoreID int default -1,
dimCustomerID int default -1,
dimSegmentID int default -1,
SalesAmount decimal(20,4),
SalesQuantity int
Constraint fk_fs_dim_product foreign key (dimProductID)
references dimProduct(dimProductKey),
Constraint fk_fs_dim_reseller foreign key (dimResellerID)
references dimReseller(dimResellerKey),
Constraint fk_fs_dim_channel foreign key (dimChannelID)
references dimChannel(dimChannelKey),
Constraint fk_fs_dim_date foreign key (dimDateID)
references dimDate(dimDateID),
Constraint fk_fs_dim_store foreign key (dimStoreID)
references dimStore(dimStoreKey),
Constraint fk_fs_dim_customer foreign key (dimCustomerID)
references dimCustomer(dimCustomerKey),
Constraint fk_fs_dim_segment foreign key (dimSegmentID)
references dimSegment(dimSegmentKey)
)


