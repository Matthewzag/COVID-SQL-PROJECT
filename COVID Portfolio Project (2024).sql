Select *
From PortfolioProject..CovidDeaths
order by 3,4

--Select *
--from PortfolioProject..covidVaccinations
--order by 3,4

--Selecting Data i'm going to use

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where Continent is not null
order by 1,2


--Looking at Total Cases vs Total Deaths (Canada)
--Shows liklihood of dying if you contract covid in your country


Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like 'Canada'
and Continent is not null
order by 1,2

--Looking At Total Cases vs Population
--Shows what percentage of population got Covid

Select location, date, population, total_cases, (cast(total_cases as float)/cast(population as float))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where Continent is not null
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select location, population, Max(cast(total_cases as int)) as HighestInfectionCount, Max((cast(total_cases as float)/cast(population as float)))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where Continent is not null
Group by location, population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population

Select location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where Continent is not null
Group by location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT
--showing continents with highest death count

Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where Continent is null and not location like '%income%' 
Group by location
order by TotalDeathCount desc

--Death Percent based on income

Select Location, MAX(population) as Population, Max(cast(Total_deaths as int)) as TotalDeathCount, Max(cast(Total_deaths as int))/MAX(population) as DeathPercentage
From PortfolioProject..CovidDeaths
where Continent is null and location like '%income%' 
Group by location, population
order by TotalDeathCount desc

--Global Numbers

Select date, sum(cast(total_cases as int)) as total_cases, SUM(cast(total_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int))/nullif(SUM(new_Cases),0)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
Group By date
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--USE CTE

with PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select*, (RollingPeopleVaccinated/Population)*100 
From PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select*, (RollingPeopleVaccinated/Population)*100 
From #PercentPopulationVaccinated


--Creating View to store for later Visualizations
DROP View if exists PercentPopulationVaccinated

Create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3