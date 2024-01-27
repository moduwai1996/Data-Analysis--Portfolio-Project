select * from dbo.Sheet1$
select location, date,total_cases, new_cases,total_deaths, population from dbo.Sheet1$

--looking  at total cases vs total Death 

SELECT
    location,
    date,
    total_cases,
    total_deaths,
    CASE
        WHEN total_cases > 0 THEN total_deaths * 1.0 / total_cases
        ELSE NULL
    END AS death_rate
FROM
    dbo.Sheet1$
ORDER BY
    location,
    date;

--SELECT
--    location,
--    date,
--    CONVERT(INT, total_cases) AS total_cases,
--    CONVERT(INT, total_deaths) AS total_deaths,
--    CASE
--        WHEN total_cases > 0 THEN CONVERT(FLOAT, total_deaths) / total_cases
--        ELSE NULL
--    END AS death_rate
--FROM
--    dbo.Sheet1$
--ORDER BY
--    location,
--    date;

select 
 location,
    date,
    total_cases,
    total_deaths,
	population from dbo.Sheet1$
	where location = 'Liberia'

	-- looking at the total cases vs the population 
SELECT
    location,
    date,
    total_cases,
    total_deaths,
    population,
    CASE
        WHEN population > 0 THEN (total_deaths * 100.0) / population
        ELSE NULL
    END AS DeathParcentage 
FROM
    dbo.Sheet1$
WHERE
    location = 'Liberia'
ORDER BY
    1, 2;

	--checking country with highest infection rate 
	
SELECT
    location,
    population,
    MAX(CAST(total_cases AS INT)) AS HighestInfectionCount,
    MAX(CAST(total_cases AS FLOAT) * 100.0 / NULLIF(CAST(population AS FLOAT), 0)) AS PopulationPercentageInfected
FROM
    dbo.sheet1$
	--where location = 'liberia'
GROUP BY
    location, population
ORDER BY
    population DESC;

select location, max(cast(total_deaths as int)) As TotalDeath from dbo.Sheet1$
Where continent is null
group by Location 

order by TotalDeath desc 

-- breaking things down by continent 

select continent, max(cast(total_deaths as int)) As TotalDeath from dbo.Sheet1$
Where continent is not null
group by continent

order by TotalDeath desc 

--globel checking 
select sum(new_cases) as TotalCases, 
sum(cast(new_deaths as int)) as totaldeath,
sum(cast(new_deaths as int))
/ sum(new_cases) * 100 as TotalDeathParcentage 
from dbo.Sheet1$
where continent is not null
order by 1,2

--looking at total populaton vs vaccinations 

SELECT
    continent,
    location,
   population
    new_vaccinations,
    SUM(CONVERT(bigint, new_vaccinations)) OVER (PARTITION BY location ORDER BY date) AS total_vaccinations_per_location
FROM
    dbo.Sheet1$
WHERE
    continent IS NOT NULL
ORDER BY
    location, population


	--checking rolling vaccinations per_polulaton

	with PovVac ( 
	continent,
    location,
	date,
   population,
    new_vaccinations,
	rollingPeoplevaccinated)
	as
	(
	
	SELECT
    continent,
    location,
	date,
   population,
    new_vaccinations,
    SUM(CONVERT(bigint, new_vaccinations)) OVER (PARTITION BY location ORDER BY date) As rollingPeoplevaccinated
FROM
    dbo.Sheet1$
WHERE
    continent IS NOT NULL
--ORDER BY
)
select *,( rollingPeoplevaccinated/population) *100 as parcentagevaccinated
from PovVac


--tem TABLE
drop table if exists #PercentPopulationVaccinated 
create table #PercentPopulationVaccinated 
(
continent nvarchar(255),
    location nvarchar(255),
	date datetime,
   population numeric,
    new_vaccinations numeric,
	rollingPeoplevaccinated numeric
	)
	insert into  #PercentPopulationVaccinated 
	SELECT
    continent,
    location,
	date,
   population,
    new_vaccinations,
	--rollingPeoplevaccinated,
    SUM(CONVERT(bigint, new_vaccinations)) OVER (PARTITION BY location ORDER BY date) As rollingPeoplevaccinated
FROM
    dbo.Sheet1$
WHERE
    continent IS NOT NULL
--ORDER BY

select *,( rollingPeoplevaccinated/population) *100 as parcentagevaccinated
from #PercentPopulationVaccinated 

select * from #PercentPopulationVaccinated 


--crerating view to store data for later 



create view PercentPopulationVaccinated  AS


	SELECT
    continent,
    location,
	date,
   population,
    new_vaccinations,
    SUM(CONVERT(bigint, new_vaccinations)) OVER (PARTITION BY location ORDER BY date) As rollingPeoplevaccinated
FROM
    dbo.Sheet1$
WHERE
    continent IS NOT NULL
--ORDER BY



/*

Queries used for Tableau Project

*/



-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From dbo.Sheet1$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From dbo.Sheet1$
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From  dbo.Sheet1$
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From dbo.Sheet1$
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc












-- Queries I originally had, but excluded some because it created too long of video
-- Here only in case you want to check them out


-- 1.

Select dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From dbo.Sheet1$ dea
Join  dbo.Sheet1$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3




-- 2.
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From  dbo.Sheet1$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2


-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 3.

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From  dbo.Sheet1$
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc



-- 4.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From  dbo.Sheet1$
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc



-- 5.

--Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where continent is not null 
--order by 1,2

-- took the above query and added population
Select Location, date, population, total_cases, total_deaths
From  dbo.Sheet1$
--Where location like '%states%'
where continent is not null 
order by 1,2


-- 6. 


With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From  dbo.Sheet1$ dea
Join  dbo.Sheet1$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 as PercentPeopleVaccinated
From PopvsVac


-- 7. 

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From dbo.Sheet1$
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc



