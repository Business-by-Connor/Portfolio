select *
From Housing.dbo.[Nashville Housing]
order by ParcelID

--------------------------------------------------------------------------------------------------------------------------

-- Sale Date Search
select SaleDate2
From Housing.dbo.[Nashville Housing]
--Sale Date Alter
Alter Table [Nashville Housing]
add saledate2 Date;
--Sale Date Update
Update [Nashville Housing]
Set Saledate2=convert(date,saledate)

--------------------------------------------------------------------------------------------------------------------------

-- Property Address
select PropertyAddress
From Housing.dbo.[Nashville Housing]
Where PropertyAddress is null

-- Property Address Self Join to reference blank address and use same parcel ID to find prop address
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
From Housing.dbo.[Nashville Housing] a
	join Housing.dbo.[Nashville Housing] b
		on a.ParcelID = b.ParcelID
		and a.[UniqueID ]<> b.[UniqueID ]
Where a. PropertyAddress is null

--PropertyAddress update when null
update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From Housing.dbo.[Nashville Housing] a
join Housing.dbo.[Nashville Housing] b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
select *
From Housing.dbo.[Nashville Housing]

--Property Address text split Substring
Select
SUBSTRING(PropertyAddress,1,CHARINDEX(',',propertyaddress)-1) as Address
, SUBSTRING(PropertyAddress,1,CHARINDEX(',',propertyaddress)-1) as Address
From Housing.dbo.[Nashville Housing]

--Alter Address
Alter Table [Nashville Housing]
add PropertySplitAddress Nvarchar(255);

--Alter City
Alter Table [Nashville Housing]
add PropertySplitCity Nvarchar(255);

--Update Address
Update [Nashville Housing]
Set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',propertyaddress)-1)

--Update City
Update [Nashville Housing]
Set PropertySplitCity=SUBSTRING(PropertyAddress,1,CHARINDEX(',',propertyaddress)-1)

--------------------------------------------------------------------------------------------------------------------------

--Owner Address Split text Parse
Select
	parsename(replace(owneraddress, ',','.'),3)
	,parsename(replace(owneraddress, ',','.'),2)
	,parsename(replace(owneraddress, ',','.'),1)
from Housing.dbo.[Nashville Housing]

--Alter Address
Alter Table [Nashville Housing]
add OwnerSplitAddress Nvarchar(255);
--Alter City
Alter Table [Nashville Housing]
add OwnerSplitCity Nvarchar(255);
--Alter State
Alter Table [Nashville Housing]
add OwnerSplitState Nvarchar(255);
--Update Address
Update [Nashville Housing]
Set OwnerSplitAddress=parsename(replace(owneraddress, ',','.'),3)
--Update City
Update [Nashville Housing]
Set OwnerSplitCity =parsename(replace(owneraddress, ',','.'),2)
--Update State
Update [Nashville Housing]
Set OwnerSplitState =parsename(replace(owneraddress, ',','.'),2)

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct (soldAsVacant), 
		  Count (SoldAsVacant)
From Housing.dbo.[Nashville Housing]
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, Case	When SoldAsVacant='Y' then 'Yes'
		When SoldAsVacant='N' then 'No'
		Else SoldAsVacant
		End
From Housing.dbo.[Nashville Housing]

Update [Nashville Housing]
Set SoldAsVacant=
		Case	
		When SoldAsVacant='Y' then 'Yes'
		When SoldAsVacant='N' then 'No'
		Else SoldAsVacant
		End

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates CTE 
With RowNumCTE 
AS(
	Select*, 
		ROW_NUMBER() 
		Over(
			Partition by ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			Order by
			UniqueID
		) Row_num
	From Housing.dbo.[Nashville Housing]
)

Delete
From RowNumCTE
Where Row_num>1

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
Select*
From Housing.dbo.[Nashville Housing]

Alter Table Housing.dbo.[Nashville Housing]
Drop Column Saledate2
