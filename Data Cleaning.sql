
Select * 
From NashvilleHousing

--standardise date format

Select Saledateformat, CONVERT(Date, SaleDate)
From NashvilleHousing

ALTER TABLE NashVilleHousing
Add SaleDateFormat Date;

Update NashVilleHousing
set SaleDateFormat = CONVERT(Date, SaleDate)

--populate null property address

Select *
From NashvilleHousing
where PropertyAddress is null
order by ParcelID

select n.ParcelID, n.PropertyAddress, v.ParcelID, v.PropertyAddress, ISNULL(n.PropertyAddress, v.PropertyAddress)
from NashVilleHousing n
join NashVilleHousing v
	on n.ParcelID = v.ParcelID
	and n.[UniqueID ] <> v.[UniqueID ]
where n.PropertyAddress is null


update n
set PropertyAddress = ISNULL(n.PropertyAddress, v.PropertyAddress)
from NashVilleHousing n
join NashVilleHousing v
	on n.ParcelID = v.ParcelID
	and n.[UniqueID ] <> v.[UniqueID ]
where n.PropertyAddress is null

--seperate property address into columns

Select PropertyAddress
From NashvilleHousing

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From NashvilleHousing

--create two new columns 

ALTER TABLE NashVilleHousing
Add Address nvarchar(255);

Update NashVilleHousing
set Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashVilleHousing
Add City nvarchar(255);

Update NashVilleHousing
set City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


--split owner address into columns

Select OwnerAddress
From NashvilleHousing

Select
PARSENAME(REPLACE (OwnerAddress, ',', '.'), 3) --parsename is useful with periods, so replace
,PARSENAME(REPLACE (OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE (OwnerAddress, ',', '.'), 1)
From NashvilleHousing

ALTER TABLE NashVilleHousing
Add OwnAddress nvarchar(255);

Update NashVilleHousing
set OwnAddress = PARSENAME(REPLACE (OwnerAddress, ',', '.'), 3)

ALTER TABLE NashVilleHousing
Add OwnCity nvarchar(255);

Update NashVilleHousing
set OwnCity = PARSENAME(REPLACE (OwnerAddress, ',', '.'), 2)

ALTER TABLE NashVilleHousing
Add OwnState nvarchar(255);

Update NashVilleHousing
set OwnState = PARSENAME(REPLACE (OwnerAddress, ',', '.'), 1)

--update Y and N in soldasvacant column

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
order by 2 

Select SoldAsvacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
       when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From NashvilleHousing

Update  NashVilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
       when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--remove duplicates (create temp tables to remove duplicates, dont delete on the actual DB)
-- can use RANK, ORDER RANK, ROW_NUM

WITH RowNumCTE AS (
Select * ,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				  PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY
					UniqueID
					) row_num
From NashvilleHousing
)
DELETE
from RowNumCTE
where row_num > 1


-- delete unused columns dont delete raw data on DB

Select * 
From NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate













