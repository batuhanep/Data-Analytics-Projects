--Alex The Analyst Data Analyst Bootcamp Portfolio Project

SELECT *
FROM PortfolioProject..CovidDeaths
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--order by 3,4

-- We displayed the data we imported using 'Select'

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
order by 1,2

-- Total Cases vs Total Deaths , Covid death rates
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
Where location like '%Turkey%'
order by 1,2

-- Ratio of cases to population

SELECT Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%Turkey%'
order by 1,2

-- Ratio of highest infection to population per country

SELECT Location, MAX(total_cases) as HighestInfectionNumber, population, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--Where location like '%Turkey%'
Group by Location, population
order by PercentPopulationInfected desc

-- Ratio of highest death count to population per country

SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%Turkey%'
Where continent is not null
Group by Location
order by TotalDeathCount desc


--Ratio of highest number of deaths to population per continent

SELECT location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--Where location like '%Turkey%'
Where continent is null
Group by location
order by TotalDeathCount desc 


-- Global numbers by date

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2

-- Without date

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
--Group by date
order by 1,2


--Total population vs vaccinations by using JOIN

--Step 1

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3

--Step 2

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER(Partition by dea.location)
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Step 3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location, dea.date) as TotalNumberofPeopleVaccinated
From PortfolioProject..CovidDeaths dea 
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Step 4

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location, dea.date)
From PortfolioProject..CovidDeaths dea 
--, (TotalNumberofPeopleVaccinated/population)*100
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--CTE 

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, TotalNumberofPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location, dea.date)
as TotalNumberofPeopleVaccinated
From PortfolioProject..CovidDeaths dea 
--, (TotalNumberofPeopleVaccinated/population)*100
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (TotalNumberofPeopleVaccinated/Population)*100
From PopvsVac


-- Temp Table

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalNumberofPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location, dea.date)
as TotalNumberofPeopleVaccinated
From PortfolioProject..CovidDeaths dea 
--, (TotalNumberofPeopleVaccinated/population)*100
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (TotalNumberofPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for Tableau Visualization

USE PortfolioProject
GO
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER(Partition by dea.location Order by dea.location, dea.date)
as TotalNumberofPeopleVaccinated
From PortfolioProject..CovidDeaths dea 
--, (TotalNumberofPeopleVaccinated/population)*100
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3


-- Dataset :https://ourworldindata.org/covid-deaths