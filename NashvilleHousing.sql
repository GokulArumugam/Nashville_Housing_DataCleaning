-- Cleaning Data in SQL Queries

SELECT * FROM NashvilleHousing

-- 1) Standardize Date format


--Adding a new column
ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

--Upading the date column 
UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE,SaleDate)


SELECT saleDateConverted, CONVERT(Date,SaleDate)
FROM NashvilleHousing


----------------------------------------------------------------------------------------------------------------------------



--2)Populate Property Address Data
-- On the data if the Parcell ID have the same value then the PropertyAddress is also the same.
-- Based on this condition I have tried to populate the address with the null fiels on PropertyAddress.

SELECT * FROM NashvilleHousing
ORDER BY ParcelID

--Joining table on table to look for the ParcelID that do not have PropertyAddress
SELECT t1.ParcelID,t2.ParcelID,t1.PropertyAddress,t2.PropertyAddress, ISNULL(t1.PropertyAddress,t2.PropertyAddress)
FROM NashvilleHousing t1
JOIN NashvilleHousing t2
	ON t1.ParcelID = t2.ParcelID
	AND t1.[UniqueID ] <> t2.[UniqueID ]
WHERE t1.PropertyAddress IS NULL

--Updating the Null value cells with the PropertyAddress which has the same ParcelID

UPDATE t1
SET PropertyAddress = ISNULL(t1.PropertyAddress,t2.PropertyAddress)
FROM NashvilleHousing t1
JOIN NashvilleHousing t2
	ON t1.ParcelID = t2.ParcelID
	AND t1.[UniqueID ] <> t2.[UniqueID ]
WHERE t1.PropertyAddress IS NULL


----------------------------------------------------------------------------------------------------------------------------

--3) Breaking out the PropertAddress Column into 2 as it has the address locations and the City
SELECT PropertyAddress FROM NashvilleHousing

--Spliting address using SUBSTRING

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS SPLIT_ADDRESS,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS SPLIT_CITY
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SPLIT_ADDRESS NVARCHAR(255);

UPDATE NashvilleHousing
SET SPLIT_ADDRESS = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
ADD SPLIT_CITY NVARCHAR(255);

UPDATE NashvilleHousing
SET SPLIT_CITY = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


--Spliting the owner address with PARSENAME
-- I have replaced , with periods to split the data

SELECT OwnerAddress FROM NashvilleHousing WHERE OwnerAddress IS NOT NULL

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1), 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)



----------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

--Checking how many 'Y' and 'N' are present on the SoldAsVacant column

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP by SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'NO'
		END


---------------------------------------------------------------------------------------------------------------------------

--Remove Duplicate
--Using the row numbers and partitioning each row to the unique ID


WITH RowNumCTE AS(
SELECT * ,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM NashvilleHousing
--ORDER BY ParcelID
)

--DELETE  
--FROM RowNumCTE
--WHERE row_num > 1


SELECT * 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


-----------------------------------------------------------------------------------------------------------------

--DELETING UNUSED COLUMNS

SELECT * FROM NashvilleHousing


ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate