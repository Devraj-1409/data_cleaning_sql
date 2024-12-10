-- To see the entire table
SELECT * FROM NashvilleHousing 

-- To Fix Date (First Way)
ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate Date

-- Second Way
UPDATE NashvilleHousing
SET SaleDateUpdated = CAST(SaleDate AS DATE)

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDateUpdated

-- To populate Null Addresses
SELECT ParcelID,COUNT(*) FROM NashvilleHousing 
GROUP BY ParcelID
HAVING COUNT(*) > 1
ORDER BY ParcelID

-- To populate Null Addresses
SELECT * FROM NashvilleHousing 
WHERE PropertyAddress is NULL
ORDER BY ParcelID


SELECT A.UniqueID,A.ParcelID,A.PropertyAddress,B.UniqueID,B.ParcelID,B.PropertyAddress,
ISNULL(A.PropertyAddress, B.PropertyAddress) 
FROM NashvilleHousing A
JOIN NashvilleHousing B
ON  A.ParcelID = B.ParcelID
AND A.UniqueID <> B.UniqueID 
WHERE A.PropertyAddress is NULL 

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress) 
FROM NashvilleHousing A
JOIN NashvilleHousing B
ON  A.ParcelID = B.ParcelID
AND A.UniqueID <> B.UniqueID 
WHERE A.PropertyAddress is NULL 

-- 
SELECT PropertyAddress,
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS PropertyArea, 
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS  PropertyCity
FROM NashvilleHousing 

ALTER TABLE NashvilleHousing
ADD PropertyArea nvarchar(255),
PropertyCity nvarchar(255)

UPDATE NashvilleHousing
SET  PropertyArea = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

UPDATE NashvilleHousing
SET  PropertyCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

SELECT * FROM NashvilleHousing															 

-- To Break Down Owner Address
SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),3) OwnerArea,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) OwnerDistrict,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) OwnerCity
FROM NashvilleHousing
WHERE OwnerAddress is not null

ALTER TABLE NashvilleHousing
ADD OwnerArea nvarchar(255), OwnerCity nvarchar(255),OwnerState nvarchar(255)

UPDATE NashvilleHousing
Set OwnerArea = PARSENAME(REPLACE(OwnerAddress,',','.'),3) 

UPDATE NashvilleHousing
Set OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

UPDATE NashvilleHousing
Set OwnerState =PARSENAME(REPLACE(OwnerAddress,',','.'),1) 

-- Yes or No
SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant ='Y' Then 'Yes'
	WHEN SoldAsVacant ='N' Then 'No'
	ELSE SoldAsVacant
END 
FROM NashvilleHousing
WHERE SoldAsVacant in ('N','Y')

SELECT SoldAsVacant
FROM NashvilleHousing
WHERE SoldAsVacant in ('N','Y')

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant ='Y' Then 'Yes'
	WHEN SoldAsVacant ='N' Then 'No'
	ELSE SoldAsVacant
END 
FROM NashvilleHousing

--Duplicates
-- To see the entire table
SELECT * FROM NashvilleHousing 

SELECT *,ROW_NUMBER() OVER (
PARTITION BY ParcelID,PropertyAddress,LegalReference Order By UniqueID) AS row_num
FROM NashvilleHousing

With Row1CTE AS (
SELECT *,ROW_NUMBER() OVER (
PARTITION BY ParcelID,PropertyAddress,LegalReference Order By UniqueID) AS row_num
FROM NashvilleHousing
)
DELETE FROM Row1CTE
WHERE row_num>1

--DELETE FROM NashvilleHousing 
--WHERE UniqueID IN (
--SELECT UniqueID FROM Row2CTE
--where row_num >1 )


SELECT UniqueID, ParcelID,SaleDate,SalePrice,SoldAsVacant,OwnerName,PropertyArea,
PropertyCity,OwnerArea,OwnerCity,OwnerState,COUNT(*) AS TotalCount FROM NashvilleHousing 
GROUP BY UniqueID, ParcelID,SaleDate,SalePrice,SoldAsVacant,OwnerName,PropertyArea,
PropertyCity,OwnerArea,OwnerCity,OwnerState
having COUNT(*) >1



-- never delete columns from raw data, instead use views, temp table
ALTER TABLE NashvilleHousing
DROP COLUMN LegalReference

SELECT * FROM NashvilleHousing