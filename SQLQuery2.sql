


/*SELECT * 
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT * 
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4 */

--Select Data that we are going to be using 

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY Location, Date;

--Looking at Total Cases Vs Total Deaths
--Shows percentage of death per covid cases in each country

SELECT Location, date, total_cases,total_deaths, (Total_deaths/total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY Location, Date;

--Looking at Total Cases vs Population 
--Shows what percentage of population got covid 
SELECT Location, date, Population, total_cases, (total_cases/population)*100 AS CasePerPopulation 
FROM PortfolioProject..CovidDeaths 
WHERE location like '%states%'
ORDER BY Location, Date;

--Countries with highest infection rate compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationIfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationIfected DESC;

--Showing countries with highest death count per population

SELECT Location, MAX(CAST(Total_deaths AS BIGINT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;

--Breaking things down by continent

SELECT location, MAX(CAST(Total_deaths AS BIGINT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

--Showing the continents with the highest death count 

SELECT continent, MAX(CAST(Total_deaths AS BIGINT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--Global numbers 
SELECT date, SUM(new_cases) AS GlobalCases, SUM(CAST(new_deaths AS BIGINT)) AS GlobalDeaths, SUM(CAST(New_deaths AS BIGINT))/SUM(New_cases)*100 AS NewDeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date, GlobalCases;

SELECT  SUM(new_cases) AS GlobalCases, SUM(CAST(new_deaths AS BIGINT)) AS GlobalDeaths, SUM(CAST(New_deaths AS BIGINT))/SUM(New_cases)*100 AS NewDeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

--Joining the Death table with Vaccination table

SELECT *
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date;


--Total population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
 --ORDER BY 2,3


 --USE Common Table Expression

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, SumofVaccinated) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS SumOfVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
 --ORDER BY 2,3
 )
SELECT *
FROM PopvsVac

--TEMP Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
 ORDER BY 2,3

 SELECT *, (RollingPeopleVaccinated /Population) *100
 FROM #PercentPopulationVaccinated


 --Creating a view to store data for later vizulizations

 CREATE VIEW PercentPopulationVaccinated AS 

 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS SumOfVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

