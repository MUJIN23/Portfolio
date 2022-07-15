/*
Cleaning Data in SQL Queries Project
*/

Select*
From PortfolioProject..[Nashville Housing]


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate) as SaleDate
From PortfolioProject..[Nashville Housing]

Update [Nashville Housing]
Set SaleDate = CONVERT(Date,SaleDate)

-- Didn't Update properly

ALTER TABLE [Nashville Housing]
add SaleDateConverted Date;

Update [Nashville Housing]
Set SaleDateConverted = CONVERT(Date,SaleDate)



 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select PropertyAddress
From PortfolioProject..[Nashville Housing]
Where PropertyAddress is null

Select *
From PortfolioProject..[Nashville Housing]
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..[Nashville Housing] a
Join PortfolioProject..[Nashville Housing] b
	on a.ParcelID = b.ParcelID
	And a. [UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set propertyaddress = Isnull(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..[Nashville Housing] a
Join PortfolioProject..[Nashville Housing] b
	on a.ParcelID = b.ParcelID
	And a. [UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject..[Nashville Housing]

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))as Address
From PortfolioProject..[Nashville Housing]

ALTER TABLE [Nashville Housing]
add PropertySplitAddress Nvarchar(255);

Update [Nashville Housing]
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE [Nashville Housing]
add PropertySplitCity Nvarchar(255);

Update [Nashville Housing]
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))
 

 Select *
From PortfolioProject..[Nashville Housing]




---Owner Address---



Select OwnerAddress
From PortfolioProject..[Nashville Housing]

Select 
Parsename(REPLACE(OwnerAddress,',','.'), 3),
Parsename(REPLACE(OwnerAddress,',','.'), 2),
Parsename(REPLACE(OwnerAddress,',','.'), 1)
From PortfolioProject..[Nashville Housing]

--Table 1 Address
ALTER TABLE [Nashville Housing]
add OwnerSplitAddress Nvarchar(255);

Update [Nashville Housing]
Set OwnerSplitAddress = Parsename(REPLACE(OwnerAddress,',','.'), 3)

--Table 2 City
ALTER TABLE [Nashville Housing]
add OwnerSplitCity Nvarchar(255);

Update [Nashville Housing]
Set OwnerSplitCity = Parsename(REPLACE(OwnerAddress,',','.'), 2)

--Table 3 State
ALTER TABLE [Nashville Housing]
add OwnerSplitState Nvarchar(255);

Update [Nashville Housing]
Set OwnerSplitState = Parsename(REPLACE(OwnerAddress,',','.'), 1)


--Check
Select*
 From PortfolioProject..[Nashville Housing]

--------- -----------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject..[Nashville Housing]
Group by SoldAsVacant
Order by 2



Select SoldAsVacant
,CASE when SoldAsVacant= 'Y' THEN 'Yes'
	  when SoldAsVacant= 'N' then 'No'
	  ELSE SoldAsVacant
	  END
From PortfolioProject..[Nashville Housing]

Update [Nashville Housing]
SET SoldAsVacant = CASE when SoldAsVacant= 'Y' THEN 'Yes'
	  when SoldAsVacant= 'N' then 'No'
	  ELSE SoldAsVacant
	  END





-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNumCTE AS(
Select*,
	ROW_NUMBER() OVER (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				ORDER BY 
					UniqueID
				 )row_num
From PortfolioProject..[Nashville Housing]
--Order by ParcelID
)
--DELETE
Select*
From RowNumCTE
Where row_num >1
Order by PropertyAddress


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select*
From PortfolioProject..[Nashville Housing]
Order by 1, 2


ALTER TABLE PortfolioProject..[Nashville Housing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..[Nashville Housing]
DROP COLUMN SaleDate




-----DONE--------------------------------------------------------------------------------------------------