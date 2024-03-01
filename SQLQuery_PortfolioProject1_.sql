SELECT *
FROM PortfolioProject..Covid_Death;

SELECT *
FROM PortfolioProject..Covid_Vaccination;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..Covid_Death
ORDER BY 1,2;

--Total cases vs Total deaths:

SELECT location, date, total_cases, total_deaths, (cast(total_deaths as float) / cast(total_cases as float)) * 100 as DeathPercentage
FROM PortfolioProject..Covid_Death
ORDER BY 1,2;

--looking at covid death percentage for location that contains 'state' in its name eg. United States...
SELECT location, date, total_cases, total_deaths, (cast(total_deaths as float) / cast(total_cases as float)) * 100 as DeathPercentage
FROM PortfolioProject..Covid_Death
WHERE location like '%state%'
ORDER BY 1,2;

--Looking at covid death percentage for Nigeria.
SELECT date, total_cases, total_deaths, (cast(total_deaths as float) / cast(total_cases as float)) * 100 as DeathPercentage
FROM PortfolioProject..Covid_Death
WHERE location = 'Nigeria'
ORDER BY 1;

--Percentage of the population that caught the covid virus.
SELECT location, date, population, total_cases, (cast(total_cases as float) / population) * 100 as InfectedPopulation
FROM PortfolioProject..Covid_Death
ORDER BY 1,2;

--Countries with Highest Infection Rate compared to Population

SELECT location, Population, MAX(total_cases) as HighestInfectionCount, MAX(cast(total_cases as float) / population) * 100 as InfectedPopulationPercentage
FROM PortfolioProject..Covid_Death
WHERE continent is not null
GROUP BY location, population
ORDER BY InfectedPopulationPercentage desc;

--Countries with Highest Death Rate compared to Population

SELECT location, MAX(total_deaths) as TotalDeathCount 
FROM PortfolioProject..Covid_Death
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc;

SELECT continent, MAX(total_deaths) as TotalDeathCount 
FROM PortfolioProject..Covid_Death
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc;

--global Numbers

--SELECT date, SUM(new_cases) as TotalNewCases, SUM(new_deaths) as TotalNewDeaths, (SUM(new_deaths) / SUM(new_cases))*100 as GlobalDeathPercentage
--FROM PortfolioProject..Covid_Death
--WHERE continent is not null
--GROUP BY date
--ORDER BY 1, 2;

--Join covid deaths table to covid vaccination table.
SELECT *
FROM PortfolioProject..Covid_Death dth
Join PortfolioProject..Covid_Vaccination vac
    On dth.location = vac.location
	and dth.date = vac.date

SELECT dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations
FROM PortfolioProject..Covid_Death dth
Join PortfolioProject..Covid_Vaccination vac
    On dth.location = vac.location
	and dth.date = vac.date
WHERE dth.continent is not null
ORDER BY 1,2,3;

SELECT dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations 
   , SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition By dth.location Order By dth.location, dth.date) As RollingVaccinated
FROM PortfolioProject..Covid_Death dth
Join PortfolioProject..Covid_Vaccination vac
    On dth.location = vac.location
	and dth.date = vac.date
WHERE dth.continent is not null
ORDER BY 2,3



--Use CTE

With PopVsVac (continent, location, date, population, new_vaccinations, RollingVaccinated)
As
(
SELECT dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations 
   , SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition By dth.location Order By dth.location, dth.date) As RollingVaccinated
FROM PortfolioProject..Covid_Death dth
Join PortfolioProject..Covid_Vaccination vac
    On dth.location = vac.location
	and dth.date = vac.date
WHERE dth.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingVaccinated/Population)*100
FROM PopVsVac



--TEMP Table

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations 
   , SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition By dth.location Order By dth.location, dth.date) As RollingVaccinated
FROM PortfolioProject..Covid_Death dth
Join PortfolioProject..Covid_Vaccination vac
    On dth.location = vac.location
	and dth.date = vac.date
--WHERE dth.continent is not null
--ORDER BY 2,3
SELECT *, (RollingVaccinated/Population)*100
FROM #PercentPopulationVaccinated



--Creating View to store data for later visualizations.

CREATE VIEW PercentPopulationVaccinated as
SELECT dth.continent, dth.location, dth.date, dth.population, vac.new_vaccinations 
   , SUM(CONVERT(float, vac.new_vaccinations)) OVER (Partition By dth.location Order By dth.location, dth.date) As RollingVaccinated
FROM PortfolioProject..Covid_Death dth
Join PortfolioProject..Covid_Vaccination vac
    On dth.location = vac.location
	and dth.date = vac.date
WHERE dth.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated;
