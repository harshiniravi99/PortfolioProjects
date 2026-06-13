SELECT * FROM CovidDeaths
WHERE continent is not null
ORDER BY 3,4

-- Select the data that we will be using for this project:

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract COVID in your country
Select location, date, total_cases, total_deaths, (total_deaths*1.0/total_cases)*100 as DeathPercentage
from CovidDeaths
WHERE location like '%states%'
order by 1

-- Looking at Total Cases vs Population
-- Shows what percentage of population contracted COVID
Select location, date, total_cases, population, (total_cases*1.0/population)*100 as PercentPopulationInfected
from CovidDeaths
WHERE location like '%states%'
order by 1

-- Looking at countries with the Highest Infection Rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases*1.0/population))*100 as PercentPopulationInfected
from CovidDeaths
GROUP BY location, population
order by PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population
Select location, MAX(total_deaths*1.0) as TotalDeathCount
from CovidDeaths WHERE continent is not null
GROUP BY location
order by TotalDeathCount DESC

-- Showing Regions with Highest Death Count per Population
Select location, MAX(total_deaths*1.0) as TotalDeathCount
from CovidDeaths WHERE continent is null
GROUP BY location
order by TotalDeathCount DESC

-- Showing Continents with Highest Death Count per Population
Select continent, MAX(total_deaths*1.0) as TotalDeathCount
from CovidDeaths WHERE continent is not null
GROUP BY continent
order by TotalDeathCount DESC

-- Global Numbers
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths*1.0) as total_deaths, SUM(new_deaths*1.0)/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1

--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
 , SUM(vac.new_vaccinations*1.0) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
 , SUM(vac.new_vaccinations*1.0) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date=vac.date
WHERE dea.continent is not null
)
SELECT * , (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- TEMP TABLE
CREATE TABLE PercentPopulationVaccinated
(
Continent  TEXT,
Location TEXT,
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
 , SUM(vac.new_vaccinations*1.0) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date=vac.date
WHERE dea.continent is not null

SELECT * , (RollingPeopleVaccinated/Population)*100
FROM PercentPopulationVaccinated

-- Creating View to store data for later visualization
CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, population, vac.new_vaccinations
 , SUM(vac.new_vaccinations*1.0) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date=vac.date
WHERE dea.continent is not null

SELECT * FROM PercentPopulationVaccinated
