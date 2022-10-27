
/* DATA CLEANING SQL QUERIES of the Nashivelle Housing Dataset*/
-- The dataset is available on https://www.kaggle.com/tmthyjames/nashville-housing-data

SELECT *
FROM  HousingData.dbo.nashivellehousing
------------------------------------------------------
--Standardize Date format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM  HousingData.dbo.nashivellehousing

UPDATE HousingData.dbo.nashivellehousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE  HousingData.dbo.nashivellehousing
ADD SaleDateConverted Date;
UPDATE  HousingData.dbo.nashivellehousing
SET convertedsaledate = CONVERT(Date, SaleDate)

-- Populate Property address data
SELECT *
FROM HousingData.dbo.nashivellehousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID  -- Same ParcelID = Same address


SELECT hd1.ParcelID, hd1.PropertyAddress, hd2.ParcelID, hd2.PropertyAddress, ISNULL(hd1.PropertyAddress, hd2.PropertyAddress)
FROM HousingData.dbo.nashivellehousing hd1
join HousingData.dbo.nashivellehousing hd2
ON hd1.ParcelID = hd2.ParcelID
AND hd1.[UniqueID ] <> hd2.[UniqueID ]
WHERE hd1.PropertyAddress IS NULL

UPDATE hd1
SET PropertyAddress = ISNULL(hd1.PropertyAddress, hd2.PropertyAddress)
FROM HousingData.dbo.nashivellehousing hd1
join HousingData.dbo.nashivellehousing hd2
ON hd1.ParcelID = hd2.ParcelID
AND hd1.[UniqueID ] <> hd2.[UniqueID ]
WHERE hd1.PropertyAddress IS NULL

 --split property address into individual columns (Address, City)
select
substring(propertyaddress,1,CHARINDEX(',',propertyaddress) -1) as address
,substring(propertyaddress,CHARINDEX(',',propertyaddress) +1,len(propertyaddress)) as address
from HousingData.dbo.nashivellehousing

alter table HousingData.dbo.nashivellehousing
add propertysplitaddress nvarchar(255);

update  HousingData.dbo.nashivellehousing
set propertysplitaddress = substring(propertyaddress,1,CHARINDEX(',',propertyaddress) -1)


alter table HousingData.dbo.nashivellehousing
add propertysplitcity nvarchar(255);
update  HousingData.dbo.nashivellehousing
Set propertysplitcity = substring(propertyaddress,CHARINDEX(',',propertyaddress) +1,len(propertyaddress))

select * from HousingData.dbo.nashivellehousing


--Split OwnerAddress using parsename

select
PARSENAME(replace(owneraddress,',','.'),3),
PARSENAME(replace(owneraddress,',','.'),2),
PARSENAME(replace(owneraddress,',','.'),1)
from  HousingData.dbo.nashivellehousing

alter table HousingData.dbo.nashivellehousing  ---(address)
add ownersplitaddress nvarchar(255);
update  HousingData.dbo.nashivellehousing
Set ownersplitaddress =PARSENAME(replace(owneraddress,',','.'),3)

alter table HousingData.dbo.nashivellehousing ---(city)
add ownersplitcity nvarchar(255);
update  HousingData.dbo.nashivellehousing
Set ownersplitcity =PARSENAME(replace(owneraddress,',','.'),2)

alter table HousingData.dbo.nashivellehousing  ---(state)
add ownersplitstate nvarchar(255);
update  HousingData.dbo.nashivellehousing
Set ownersplitstate =PARSENAME(replace(owneraddress,',','.'),1)

select * from HousingData.dbo.nashivellehousing


--case statement 

select  distinct  soldasvacant from HousingData.dbo.nashivellehousing;

select soldasvacant,
case  when soldasvacant = 'y' then 'yes'
 when soldasvacant ='N' then 'No'
 else soldasvacant
 end
 from HousingData.dbo.nashivellehousing

 update HousingData.dbo.nashivellehousing
 set soldasvacant=case  when soldasvacant = 'y' then 'yes'
 when soldasvacant ='N' then 'No'
 else soldasvacant
 end


 --removing duplicates
 with rownumcte as(
 select *,
 ROW_NUMBER() over (partition by parcelid,propertyaddress,saleprice,saledate,legalreference
 order by uniqueid)row_num
 from HousingData.dbo.nashivellehousing)
 select * from rownumcte
 where row_num > 1
 --delete from rownumcte
 --where row_num > 1

 --Delete unused coulumn

 alter table HousingData.dbo.nashivellehousing
 drop column saledate,propertyaddress,owneraddress

 Select * from HousingData.dbo.nashivellehousing
 









