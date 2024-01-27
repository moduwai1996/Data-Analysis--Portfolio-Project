/*

Cleaning Data in SQL Queries

*/


Select *
From dbo.housingData

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select SaleDateConverted, CONVERT(Date,SaleDate) 
From dbo.housingData



Update dbo.housingData
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE dbo.housingData
Add SaleDateConverted Date;

Update dbo.housingData
SET SaleDateConverted = CONVERT(Date,SaleDate)




 --------------------------------------------------------------------------------------------------------------------------


 --Property address Data
 Select *
From dbo.housingData
--Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.dbo.housingData, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From dbo.housingData a
JOIN dbo.housingDatab
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From dbo.housingData a
JOIN dbo.housingData b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------------------------
--Breaking Out Address into Individual colunm(Address, City, State)
Select propertyAddress
from dbo.housingData

select 
SUBSTRING
( propertyAddress,1, CHARINDEX (',',  propertyAddress )-1) as Adddress,
SUBSTRING
( propertyAddress, CHARINDEX (',',  propertyAddress) +1, len(propertyAddress)) as Adddress
from dbo.housingData

ALTER TABLE dbo.housingData
Add PropertySplitAddress Nvarchar(255);

Update dbo.housingData
SET PropertySplitAddress = SUBSTRING
( propertyAddress,1, CHARINDEX (',',  propertyAddress )-1)

ALTER TABLE dbo.housingData
Add PropertySplitcity Nvarchar(255);

Update dbo.housingData
SET PropertySplitcity = SUBSTRING
( propertyAddress, CHARINDEX (',',  propertyAddress) +1, len(propertyAddress))

select * from dbo.housingData






select ownerAddress from dbo.housingData

select PARSENAME(replace(OwnerAddress, ',', '.'), 3),
PARSENAME(replace(OwnerAddress, ',', '.'), 2),
PARSENAME(replace(OwnerAddress, ',', '.'), 1)
from dbo.housingData
----------------------------------------------------------------------------
ALTER TABLE dbo.housingData
Add OwnerSplitAddress Nvarchar(255);

Update dbo.housingData
SET OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3)
------------------------------------------------------------------------------
ALTER TABLE dbo.housingData
Add OwnerSplitCity Nvarchar(255);

Update dbo.housingData
SET OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2)
-------------------------------------------------------------------------------
ALTER TABLE dbo.housingData
Add OwnerSplitState Nvarchar(255);

Update dbo.housingData
SET OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'), 1)

select * from dbo.housingData

-------------------------------------------------------------------------------------------------------------------------------------------------

--change Y and N to YES and NO

Select distinct(SoldAsVacant),count(SoldAsVacant) AS CNT

from dbo.housingData
group by SoldAsVacant
order by 2


select SoldAsVacant,
case 
when SoldAsVacant = 'Y' then 'YES'
when SoldAsVacant = 'N' then 'NO'
else SoldAsVacant
end 
from dbo.housingData

update dbo.housingData
set SoldAsVacant = case 
when SoldAsVacant = 'Y' then 'YES'
when SoldAsVacant = 'N' then 'NO'
else SoldAsVacant
end 


-- remove duplicate value

DECLARE @tableName NVARCHAR(255)
DECLARE @columnName NVARCHAR(255)

DECLARE table_cursor CURSOR FOR
SELECT t.name AS tableName, c.name AS columnName
FROM sys.tables t
INNER JOIN sys.columns c ON t.object_id = c.object_id
ORDER BY t.name, c.name;

OPEN table_cursor;

FETCH NEXT FROM table_cursor INTO @tableName, @columnName;

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @sql NVARCHAR(MAX)
    
    SET @sql = 'SELECT ' + QUOTENAME(@columnName) + ' AS duplicate_value, COUNT(' + QUOTENAME(@columnName) + ') AS occurrence_count
                FROM ' + QUOTENAME(@tableName) + '
                GROUP BY ' + QUOTENAME(@columnName) + '
                HAVING COUNT(' + QUOTENAME(@columnName) + ') > 1;'
    
    EXEC sp_executesql @sql;

    FETCH NEXT FROM table_cursor INTO @tableName, @columnName;
END;

CLOSE table_cursor;
DEALLOCATE table_cursor;

with Row_NumCTE AS(
select *, 
ROW_NUMBER() over (
Partition by ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 order by
			 UniqueID) row_num
	from dbo.housingData)
	--order by ParcelID)

	Select * from Row_NumCTE
	where row_num > 1
	--order  by PropertyAddress
	------------------------------------------------------------------------------------------------------------------------------------------

	-- Delete Unuse date 

	select * from dbo.housingData

	Alter table dbo.housingData
	Drop Column SaleDate
 