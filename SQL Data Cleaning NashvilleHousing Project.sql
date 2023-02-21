-- Looking through the data
SELECT *
FROM PortfolioProject..NashvilleHousing

-- Just to check if CONVERT works
SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- To check if it's updated, it doesn't work.
SELECT SaleDate
FROM PortfolioProject..NashvilleHousing

-- Added new column & updated the column with the converted date format.
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-----------------------------------------------------------------------------------------------------

-- Populate Property Address. Found that ParcelID = PropertyAddress. Convert null values based on that.
SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

-- If it's null, replace null with the PropertyAddress using ISNULL()
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing AS a 
JOIN PortfolioProject..NashvilleHousing AS b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing AS a 
JOIN PortfolioProject..NashvilleHousing AS b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]

-----------------------------------------------------------------------------------------------------

-- Breaking out  Property address into individual columns (Address, City, State) using SUBSTRING
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject..NashvilleHousing

-- Adding column and add split address (Address, City)
ALTER TABLE NashvilleHousing
Add PropertySplitAdd NvarChar(225);

UPDATE NashvilleHousing
SET PropertySplitAdd =SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity NvarChar(225);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject..NashvilleHousing

-----------------------------------------------------------------------------------------------------

-- Breaking out OwnerAddress using PARSENAME 
SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

-- Need to replace , to . as PARSENAME only look at . 
SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) AS Address,
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2) AS City,
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1) AS State
FROM PortfolioProject..NashvilleHousing

-- Create new columns, add split address for OwnerAddress
ALTER TABLE NashvilleHousing
ADD OwnerSplitAdd NvarChar(225);

UPDATE NashvilleHousing
SET OwnerSplitAdd = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NvarChar(225);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NvarChar(225);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

-----------------------------------------------------------------------------------------------------

-- Changing Y & N to Yes & No in "Sold as Vacant" field - Make everything standardized
SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END
FROM PortfolioProject..NashvilleHousing

-- Updating the table
UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
	END

-----------------------------------------------------------------------------------------------------

-- Remove duplicates -- Partition on something unique
WITH RowNum AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID
	) AS row_num

FROM PortfolioProject..NashvilleHousing
)

-- row_num 2 = duplicates of data, deleting those with row_num = 2 
DELETE
FROM RowNum
WHERE row_num > 1

-----------------------------------------------------------------------------------------------------

-- Delete unused columns **SELF NOTE : USE IT ONLY ON DUPLICATED DATA. NEVER ON RAW DATA** 
SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate





