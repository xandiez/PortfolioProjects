SELECT * 
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT * 
--FROM CovidVaccinations

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1, 2

--SELECT  location, total_cases, total_deaths
--FROM CovidDeaths
--GROUP BY
--ORDER BY 1

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location = 'Nigeria'
ORDER BY 1, 2

SELECT location, date, total_cases, population, (total_cases/population)*100 AS CasesPercentage
FROM CovidDeaths
WHERE location = 'Nigeria'
ORDER BY 1, 2

SELECT location, population, MAX(total_cases) AS TotalCaseCount, MAX((total_cases/population))*100 AS CasesPercentage
FROM CovidDeaths
GROUP BY location, population
ORDER BY TotalCaseCount desc

--Deathcount by continents

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

--SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, SUM(new_cases)/SUM(CAST(new_deaths as int))/100 AS CaseDeathpercent
--FROM CovidDeaths
--WHERE continent IS NOT NULL 
--GROUP BY date
--ORDER BY 1, 2 Divide by zero error encountered.

--GLOBAL STATS

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, 
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS CaseDeathpercent
FROM CovidDeaths
WHERE continent IS NOT NULL 
ORDER BY 1, 2

-- total poopulation and vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
ORDER BY 2, 3

--vaccinations sum by location

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location)
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
ORDER BY 2, 3

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.date) as CummulativePeopleVaccinated --cummulative sum
--, (CummulativePeopleVaccinated/population)*100 create CTE or temp table, cannot use a column created to just calc
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
ORDER BY 2, 3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, CummulativePeopleVaccinated)
as --columns here = columns in select
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.date) as CummulativePeopleVaccinated 
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
--ORDER BY 2, 3
)
Select *, (CummulativePeopleVaccinated/Population)*100
From PopvsVac


--USE TEMP TABLE

Drop Table PercentPopulationVaccinated --(add this for table alterations)
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CummulativePeopleVaccinated numeric
)

Insert into PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.date) as CummulativePeopleVaccinated 
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
--ORDER BY 2, 3

Select *, (CummulativePeopleVaccinated/Population)*100
From PercentPopulationVaccinated


--creating views to store data for visualizations

Create view PercentVaccinatedPopulation as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM (convert(bigint, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.date) as CummulativePeopleVaccinated 
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
--ORDER BY 2, 3

SELECT *
From PercentVaccinatedPopulation


