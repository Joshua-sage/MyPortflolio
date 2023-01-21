select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--select the data

select location,date, total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


--total cases vs total deaths
--likelihood of death in nigeria

select location,date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location = 'nigeria'
and continent is not null
order by 1,2

--Total cases vs population
--shows % of population got covid

select location,date,population, total_cases, (total_deaths/population)*100 as Percentageofinfectedpopulation
from PortfolioProject..CovidDeaths
where location = 'nigeria'
order by 1,2

-- Countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as 
	Percentageofinfectedpopulation
from PortfolioProject..CovidDeaths
--where location = 'nigeria'
group by location,population
order by Percentageofinfectedpopulation desc

-- Cpuntries with Highest death rate per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location = 'nigeria'
where continent is not null
group by location
order by TotalDeathCount desc

--Filtering by continent

--continents with highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location = 'nigeria'
where continent is not null
group by continent 
order by TotalDeathCount desc


--Global numbers

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 
	as Deathpercentage
from PortfolioProject..CovidDeaths
--where location = 'nigeria'
where continent is not null
--group by date
order by 1,2



--Total population vs vaccinations
set ansi_warnings off -- Turns off warnings

-- Arithmetic overflow error converting expression to data type int  error means the column data type is not enough
-- to run the calculation 
-- so you cast it to a larger capacity i.e bigint or decimal(12,0)

-- USE CTE


with PopvsVac (Continent, location, date, population, New_vaccinations, RollingPeoplevaccinated)
as 
(
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,
	dea.date) as RollingPeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeoplevaccinated/population)*100
from PopvsVac


--TEMP TABLE

drop table if exists PercentPopulationvaccinated

create table PercentPopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeoplevaccinated numeric
)

insert into PercentPopulationvaccinated
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,
	dea.date) as RollingPeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *, (RollingPeoplevaccinated/Population)*100
from PercentPopulationvaccinated


--create view to store data for viz
create view PercentPopulationvaccinated as 
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location order by dea.location,
	dea.date) as RollingPeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
from PercentPopulationvaccinated