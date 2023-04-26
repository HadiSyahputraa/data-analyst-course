select *
from Data_Cleaning..Nashville

--===================================================================================

--update date 

--update format dari YYYY-MM-DD TT:TT:TT menjadi YYYY-MM-DD

select SaleDate, convert(Date,SaleDate)
from Data_Cleaning..Nashville

update Data_Cleaning..Nashville
set SaleDateConverted = convert(Date,SaleDate)

alter table Data_Cleaning..Nashville
add SaleDateConverted date;

--===================================================================================

-- update property address

-- menggunakan parcelID yang sama dengan UniqueID yang berbeda untuk mengisi data null

select PropertyAddress
from Data_Cleaning..Nashville
where PropertyAddress is null

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from Data_Cleaning..Nashville a
join Data_Cleaning..Nashville b
 on a.ParcelID = b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from Data_Cleaning..Nashville a
join Data_Cleaning..Nashville b
 on a.ParcelID = b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- memisahkan data alamat dan kota

select PropertyAddress
from Data_Cleaning..Nashville

select PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS adress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS city
from Data_Cleaning..Nashville

alter table Data_Cleaning..Nashville
 add pisah_Alamat_Property nvarchar(255);

alter table Data_Cleaning..Nashville
 add pisah_Kota_Property nvarchar(255);

update Data_Cleaning..Nashville
set pisah_Alamat_Property = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

update Data_Cleaning..Nashville
set pisah_Kota_Property = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

--===================================================================================

-- update owner address

-- memisahkan menjadi format state, kota, alamat

select OwnerAddress
from Data_Cleaning..Nashville
where OwnerAddress is not null

select OwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'), 1) as state,
PARSENAME(REPLACE(OwnerAddress,',','.'), 2) as city,
PARSENAME(REPLACE(OwnerAddress,',','.'), 3) as addres
from Data_Cleaning..Nashville
where OwnerAddress is not null

alter table Data_Cleaning..Nashville
 add pisah_Alamat_Pemilik nvarchar(255);

alter table Data_Cleaning..Nashville
 add pisah_Kota_Pemilik nvarchar(255);

 alter table Data_Cleaning..Nashville
 add pisah_State_Pemilik nvarchar(255);

update Data_Cleaning..Nashville
set pisah_Kota_Pemilik = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

update Data_Cleaning..Nashville
set pisah_Alamat_Pemilik = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

update Data_Cleaning..Nashville
set pisah_State_Pemilik = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

select OwnerAddress , pisah_Kota_Pemilik, pisah_Alamat_Pemilik, pisah_State_Pemilik
from Data_Cleaning..Nashville
where OwnerAddress is not null

--===================================================================================

-- update SoldASVacant

-- merapihkan format penulisan dari Y, N, Yes, dan No menjadi Yes dan NO

select SoldAsVacant, count(SoldAsVacant)
from Data_Cleaning..Nashville
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from Data_Cleaning..Nashville
group by SoldAsVacant

update Data_Cleaning..Nashville
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
						end

--===================================================================================

-- cek apakah ada data duplikat

with duplicate_Check as(
select *,
 row_number()over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
					UniqueID
 ) row_num
from Data_Cleaning..Nashville
)
select *
from duplicate_Check
where row_num > 1

-- hapus duplikat

with duplicate_Check as(
select *,
 row_number()over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
					UniqueID
 ) row_num
from Data_Cleaning..Nashville
)
delete
from duplicate_Check
where row_num > 1

--===================================================================================

-- hapus tabel yang tidak digunakan

alter table Data_Cleaning..Nashville
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate