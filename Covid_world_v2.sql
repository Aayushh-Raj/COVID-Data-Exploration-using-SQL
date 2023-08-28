SELECT *
FROM PortfolioProject_1..CovidDeaths
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject_1..CovidVaccinations
--ORDER BY 3,4

-- SELECT DATA TO BE USED
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject_1..CovidDeaths
ORDER BY 1,2

-- Total cases vs Total deaths (shows likelihood of dying from COVID in Australia from 26th Jan 2020 till 30th April 2021)
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject_1..CovidDeaths
WHERE location = 'Australia'
ORDER BY 1,2

--Total cases vs population (shows what percentage of population got covid in Australia) 
SELECT location, date, population,total_cases, (total_cases/population)*100 as InfectedPercentage
FROM PortfolioProject_1..CovidDeaths
WHERE location = 'Australia'
ORDER BY 1,2

--Looking at countries with Highest infection rate compared to population
SELECT location, population,MAX(total_cases) HighestInfectionCount, MAX((total_cases/population)*100) as InfectedPercentage
FROM PortfolioProject_1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY 4 DESC

--Showing Countries with Highest death count
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject_1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

-- Showing highest death count based on continent
SELECT continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject_1..CovidDeaths
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY 2 DESC

--Global numbers on new cases vs death everyday
SELECT date, SUM(new_cases) as Total_cases_everyday, SUM(CAST(new_deaths as int)) as Total_deaths_everyday,SUM(CAST(new_deaths as int))/SUM(new_cases)*100  as DeathPercentage_perday
FROM PortfolioProject_1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

-- Overall new cases vs death scenario
SELECT SUM(new_cases) as Total_cases_everyday, SUM(CAST(new_deaths as int)) as Total_deaths_everyday,SUM(CAST(new_deaths as int))/SUM(new_cases)*100  as DeathPercentage_perday
FROM PortfolioProject_1..CovidDeaths
WHERE continent IS NOT NULL



-- Looking at population that got vaccinated

SELECT dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location)
FROM PortfolioProject_1..CovidDeaths dea
Join PortfolioProject_1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3

-- Rolling People vaccinated vs new vacc

SELECT dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject_1..CovidDeaths dea
Join PortfolioProject_1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL 
ORDER BY 2,3

-- Percentage of population vaccinated
-- Using CTE

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccination, RollingPeopleVaccinated)
as (
SELECT dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject_1..CovidDeaths dea
Join PortfolioProject_1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL 
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentageOfPopulationVaccinated
FROM PopvsVac

-- Using Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject_1..CovidDeaths dea
Join PortfolioProject_1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL 
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentagePopulationVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject_1..CovidDeaths dea
Join PortfolioProject_1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL 
