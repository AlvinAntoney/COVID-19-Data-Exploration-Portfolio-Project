/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/



SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL


SELECT *
FROM PortfolioProject..CovidVaccinations
WHERE continent is not NULL

-- Select Data that we are going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100  AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like 'india'
AND continent is not NULL
ORDER BY 1,2

-- Looking at Total Cases vs population

SELECT location, date, total_cases, population, (total_cases/population)*100  AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location like 'india'
AND continent is not NULL
ORDER BY 1,2

-- Looking at countries with Highest Infection Rate compared to Population

SELECT location,  MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100  AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
where continent is not NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count with Population

SELECT location,  MAX(CAST(total_deaths AS int)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not NULL
GROUP BY location 
ORDER BY HighestDeathCount DESC

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

SELECT continent,  MAX(CAST(total_deaths AS int)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
where continent is not NULL
GROUP BY continent 
ORDER BY HighestDeathCount DESC

-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, 
(SUM(CAST(new_deaths as int))/SUM(new_cases))*100  AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like 'india'
WHERE continent is not NULL
--GROUP BY date
ORDER BY 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
     SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
	 as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location
   and dea.date=vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3

-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac( continent, location, date, population, new_vaccinations,RollingPopulationVaccinations)
as
(
SELECT dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
     SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
	 as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location
   and dea.date=vac.date
WHERE dea.continent is not NULL
)
SELECT * , (RollingPopulationVaccinations/population)*100
FROM PopvsVac


-- TEMP TABLE


DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
( continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPopulationVaccinations numeric)

Insert into #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
     SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
	 as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location
   and dea.date=vac.date
WHERE dea.continent is not NULL

SELECT * , (RollingPopulationVaccinations/population)*100
FROM  #PercentPopulationVaccinated


-- Creating View to store data for later visualization


CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent,dea.location,dea.date, dea.population, vac.new_vaccinations,
     SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date)
	 as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location
   and dea.date=vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVaccinated



