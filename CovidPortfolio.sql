
-- Total Cases vs Total Deaths
SELECT Location, date, total_cases, total_deaths, ROUND(CONVERT(FLOAT,total_deaths)/CONVERT(FLOAT, total_cases)*100, 2) AS DeathPercentage
FROM CovidDeath
WHERE Location='Italy' and continent is not null
ORDER BY 1,2

-- Total cases vs Population
SELECT location, date, population, CAST(total_cases AS INT), ROUND(CAST(total_cases AS INT)/population*100, 2) ContagiousPercentage
FROM CovidDeath
WHERE Location='Italy' and continent is not null
ORDER BY 5 DESC

-- Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(CAST(total_cases AS INT)) HighestInfectionCount, Max((CAST(total_cases AS INT)/population))*100 AS PercentPopulationInfected
FROM CovidDeath
WHERE continent is not null
GROUP BY location, population 
ORDER BY PercentPopulationInfected DESC

-- Total Deaths for Nations
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeath
WHERE continent is not null
GROUP BY location 
ORDER BY TotalDeathCount DESC

-- Total Deaths for Continents
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeath
WHERE continent IS NULL AND location IN('Europe', 'Asia', 'North America', 'South America', 'Africa', 'Oceania')
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Global numbers
SELECT SUM(new_cases) AS total_cases, 
	   SUM(new_deaths) AS total_death,
	   CASE WHEN SUM(new_cases) = 0 THEN 0 ELSE (SUM(new_deaths) * 100.0) / SUM(new_cases) END AS DeathPercentage
FROM CovidDeath
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2;


-- Total Population vs Vaccinations
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CAST(v.new_vaccinations AS BIGINT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM CovidDeath d JOIN CovidVaccinations v
	ON d.location=v.location
	AND d.date=v.date
	WHERE d.continent IS NOT NULL
	ORDER BY 2,3;

-- Using CTE % of Italians with 3 doses
WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS(
	SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CAST(v.new_vaccinations AS BIGINT)) 
	OVER (PARTITION BY d.location ORDER BY d.location, d.date) 
	AS RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)*100
FROM CovidDeath d JOIN CovidVaccinations v
	ON d.location=v.location
	AND d.date=v.date
	WHERE d.continent IS NOT NULL AND d.location='Italy'
	--ORDER BY 2,3
	)
	SELECT *, (RollingPeopleVaccinated/(population*3))*100 FROM PopVsVac;

-- Creating View for store data for later

CREATE VIEW PercentPopulationVaccined AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations,
	SUM(CAST(v.new_vaccinations AS BIGINT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS RollingPeopleVaccinated
FROM CovidDeath d JOIN CovidVaccinations v
	ON d.location=v.location
	AND d.date=v.date
	WHERE d.continent IS NOT NULL;

SELECT * FROM PercentPopulationVaccined;