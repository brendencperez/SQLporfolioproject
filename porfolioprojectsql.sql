Select *
From [sql projext]..coviddeaths
Where continent is not null
order by 3,4

--select data that we start with

Select Location, date, total_cases, new_cases, total_deaths, population
From [sql projext]..coviddeaths
Where continent is not null
order by 1,2



--looking at Total cases vs Total Deaths
-- shows the likelyhood of dieing if you get covid in your country 
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [sql projext]..coviddeaths
Where location like '%states%'
and continent is not null
order by 1,2



--looking at total cases vs population
Select Location, date, Population, total_cases, (total_cases/population)*100 as covidPercentage
From [sql projext]..coviddeaths
order by 1,2
-- looking at countrys with highist infection rate compaird to populataion 
Select Location, Population, MAX(total_cases) as HighistInfectionCount, MAX((total_cases/population))*100 as covidPercentage
From [sql projext]..coviddeaths
Group by Location, Population
order by covidPercentage desc
--Showing countrys with highist death count per pipulation
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [sql projext]..coviddeaths
Where continent is not null
Group by location
order by TotalDeathCount desc
--braking things down by continent
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [sql projext]..coviddeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc 
-- Global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [sql projext]..coviddeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2
--Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [sql projext]..coviddeaths dea
Join [sql projext]..covidvaccc vac
	On dea.location = vac.location                       
	and dea.date = vac.date
	where dea.continent is not null 
	order by 2,3



With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [sql projext]..coviddeaths dea
Join [sql projext]..covidvaccc vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


DROP Table if exists #covidPercentage
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [sql projext]..coviddeaths dea
Join [sql projext]..covidvaccc vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated 

-- Creating View to store data for later visualizations




CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [sql projext]..coviddeaths dea
Join [sql projext]..covidvaccc vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null  



Select *
From PercentPopulationVaccinated