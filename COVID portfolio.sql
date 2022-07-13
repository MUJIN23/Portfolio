--2020 to 2022
Select*
from PortfolioProject..['Covid Deaths Feb20-20-to-Jul12-$']
Where continent is not null
order  by 3,4

Select Location, date, total_cases, New_cases, total_deaths, population
From PortfolioProject..['Covid Deaths Feb20-20-to-Jul12-$']
order by 1,2



--Total cases vs Total deaths
--Chances of dying when got Covid

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..['Covid Deaths Feb20-20-to-Jul12-$']
Where location like '%states%'
Order by 1,2



--Total case vs Population
--Percentage of the population who got Covid

Select Location, date, total_cases,population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..['Covid Deaths Feb20-20-to-Jul12-$']
Order by 1,2



--Countries with highest infection rate compared to population

Select Location,population, MAX(total_cases)as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..['Covid Deaths Feb20-20-to-Jul12-$']
Group by Location, Population
Order by PercentPopulationInfected desc



--Countries with Highest Death Count per Population

Select Location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['Covid Deaths Feb20-20-to-Jul12-$']
Where continent is not null
Group by Location
Order by TotalDeathCount desc






--Breaking Things Down By Continent
--Continents with highest death count

Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..['Covid Deaths Feb20-20-to-Jul12-$']
Where continent is not null
Group by continent
Order by TotalDeathCount desc 



--GLOBAL NUMBERS

Select date, SUM(new_cases)as Total_Cases, SUM(cast(new_deaths as int))as Total_Deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..['Covid Deaths Feb20-20-to-Jul12-$']
Where continent is not null
Group by date
Order by 1,2



--TOTAL DEATHS AND CASES

Select SUM(new_cases)as Total_Cases, SUM(cast(new_deaths as int))as Total_Deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From PortfolioProject..['Covid Deaths Feb20-20-to-Jul12-$']
Where continent is not null
Order by 1,2



--Looking at total population vs vaccination

Select dea.continent, dea.location, dea.date, dea.population ,vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint))OVER(Partition by dea.location Order by dea.location, dea.date)as RollingPeopleVaccinated
From PortfolioProject..['Covid Deaths Feb20-20-to-Jul12-$'] dea
join PortfolioProject..['Covid Vaccinations Feb20-20-to-$'] vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 1,2,3



--USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population ,vac.new_vaccinations, SUM(cast(vac.new_vaccinations as bigint))OVER(Partition by dea.location Order by dea.location, dea.date)as RollingPeopleVaccinated
From PortfolioProject..['Covid Deaths Feb20-20-to-Jul12-$'] dea
join PortfolioProject..['Covid Vaccinations Feb20-20-to-$'] vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
)
Select*,(RollingPeopleVaccinated/population)*100
From PopvsVac



--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(225),
Date datetime,
population Numeric,
New_vaccination numeric,
Rollingpeoplecvaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population ,vac.new_vaccinations, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)as RollingPeopleVaccinated
From PortfolioProject..['Covid Deaths Feb20-20-to-Jul12-$'] dea
join PortfolioProject..['Covid Vaccinations Feb20-20-to-$'] vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null

Select*,(Rollingpeoplecvaccinated/population)*100
From #PercentPopulationVaccinated



--Creating VIew 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population ,vac.new_vaccinations, SUM(Convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date)as RollingPeopleVaccinated
From PortfolioProject..['Covid Deaths Feb20-20-to-Jul12-$'] dea
join PortfolioProject..['Covid Vaccinations Feb20-20-to-$'] vac
	On dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
