SELECT *
FROM PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we are going to use

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where Location like '%India%'
order by 1,2

--Looking at the Totals Cases vs Population
--Shows what percent of population got Covid 

Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected 
From PortfolioProject..CovidDeaths
--Where Location like '%India%'
order by 1,2


--Looking at countries with Highest Infection Rate compared to Population

Select Location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where Location like '%India%'
Group by Location, Population
order by PercentPopulationInfected desc


--Showing Countries with Highest Death Count per Population

Select Location, max(cast(Total_deaths as Int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where Location like '%India%'
where continent is not null
Group by Location
order by TotalDeathCount desc


--Now let's see data about Continent with the Highest Death Count


Select continent, max(cast(Total_deaths as Int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where Location like '%India%'
where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers

Select date, sum(new_cases) as Total_Cases, sum(cast(new_deaths as Int)) as Total_Deaths, sum(cast(new_deaths as Int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where Location like '%India%'
where continent is not null
Group by date
order by 1,2


Select sum(new_cases) as Total_Cases, sum(cast(new_deaths as Int)) as Total_Deaths, sum(cast(new_deaths as Int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where Location like '%India%'
where continent is not null
--Group by date
order by 1,2


select*
from PortfolioProject..CovidVaccinations


--Looking at Total Population vs Vaccination

select*
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date)
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Use CTE


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




--Creating View to store data for Visualization

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location,dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated