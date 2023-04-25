--===================================================================================

-- pengelompokan berdasarkan negara spesifik

-- persentase kematian di negara x
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_Percentage
from Portofolio_Pt_1..CovidDeaths
where location like '%states%' and continent is not null
order by 1,2

-- persentase infeksi negara x
select location, date, population, total_cases, (total_cases/population)*100 as infection_Percentage
from Portofolio_Pt_1..CovidDeaths
where location like '%states%' and continent is not null
order by 1,2

--===================================================================================

-- pengelompokan berdasarkan negara

--persentase infeksi tertinggi per negara
select location, population, max(total_cases) as maximum_Case, (max(total_cases)/population)*100 as highest_Infection_Percentage
from Portofolio_Pt_1..CovidDeaths
where continent is not null
group by location, population
order by highest_Infection_Percentage desc

--total kematian pada setiap negara
select location, max(cast(total_deaths as int)) as maximum_Total_Deaths
from Portofolio_Pt_1..CovidDeaths
where continent is not null
group by location
order by maximum_Total_Deaths desc

--===================================================================================

--pengelompokan berdasarkan kontinen

--total kematian pada setiap kontinen
select continent, max(cast(total_deaths as int)) as maximum_Total_Deaths
from Portofolio_Pt_1..CovidDeaths
where continent is not null
group by continent
order by maximum_Total_Deaths desc

--===================================================================================

--nilai global

--total kematian
select date, sum(new_cases) as total_Case, sum(cast(new_deaths as int)) as total_Deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as death_Percentage
from Portofolio_Pt_1..CovidDeaths
where continent is not null
group by date
order by 1,2

-- total  vaksinasi vs  populasi
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by 
 dea.location, dea.date) as total_People_Vac
from Portofolio_Pt_1..CovidDeaths dea
join Portofolio_Pt_1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is  not null
order by 2, 3
--hasil dari nilai dapat ditampilkan menggunakan dua cara yaitu CTE dan temp table

--penggunaan CTE
with PopvsVac (continent, location, date, population, new_vaccinations, total_People_Vac)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by 
 dea.location, dea.date) as total_People_Vac
from Portofolio_Pt_1..CovidDeaths dea
join Portofolio_Pt_1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is  not null
)
select *, (total_People_Vac/population)*100 as percentage_Vaccinatted
from PopvsVac

--penggunaan temp table
drop table if exists number_Percent_Population_Vaccinated
create table number_Percent_Population_Vaccinated
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
new_Vaccination numeric,
total_People_Vac numeric
)

insert number_Percent_Population_Vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 ,sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by 
 dea.location, dea.date) as total_People_Vac
from Portofolio_Pt_1..CovidDeaths dea
join Portofolio_Pt_1..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is  not null

select *, (total_People_Vac/population)*100 as percentage_Vaccinatted
from number_Percent_Population_Vaccinated

--export file untuk bisa dilanjutkan ke tahap visualisasi
Create View
Total_Kematian_Setiap_Negara as
select location, max(cast(total_deaths as int)) as maximum_Total_Deaths
from Portofolio_Pt_1..CovidDeaths
where continent is not null
group by location

--===================================================================================