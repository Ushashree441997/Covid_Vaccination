
select *
from PortfolioProject..covidDeath


select *
from PortfolioProject..CovidVacination

select *
from PortfolioProject..covidDeath
order by 3,4


-- select *
-- from PortfolioProject..CovidVacination
-- order by 3,4

-- select the data that we are going to use it.
select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..covidDeath
order by 1,2

--Looking at total cases vs total deaths
select Location, date, total_cases, total_deaths, (total_cases/total_deaths) as Death_Percent
from PortfolioProject..covidDeath
order by 1,2

-- shows likelihood of dying if you contract covid in your country.
select Location, date, total_cases, total_deaths, (total_cases/total_deaths) as Death_Percent
from PortfolioProject..covidDeath
where Location like '%states%'
order by 1,2

-- Looking at total_cases vs population
-- shows what percentage of population got Covid
select Location, date, total_cases, population, cast(total_cases/population as float)*100 as population_Percent_infected
from PortfolioProject..covidDeath
where Location like '%states%'
order by 1,2


-- Looking at countries with highest infection rate compared to population
select Location, max(cast(total_cases as float)) as HighestInfectedCount, population, max(cast(total_cases/population as float))*100 as population_Percent_infected
from PortfolioProject..covidDeath
group by Location, population
order by population_Percent_infected desc


-- Showing countries with Highest Death count per Population
select location, max(cast(total_deaths as float)) as TotalDeathCount
from PortfolioProject..covidDeath
where continent is not null
group by location
order by TotalDeathCount desc

select *
from PortfolioProject..covidDeath
where continent is not null
order by 3,4


-- Lets break thinks down for continent

-- showing continents with the highest death count per population
select continent, max(cast(total_deaths as float)) as TotalDeathCount
from PortfolioProject..covidDeath
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global numbers
-- select Data that we are going to be used
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from PortfolioProject..covidDeath
where continent is not null
order by 1,2

-- Looking at TotalPopulation vs Vaccination

-- Use CTE
with PopVsVac (continent, location, date, population, life_expectancy, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.iso_code as new_vaccination, 
sum(convert(int, vac.life_expectancy)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..covidDeath dea
join PortfolioProject..CovidVacination vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopVsVac;


-- Temp Table
Drop Table if exists #PercentageVaccinated12
Create Table #PercentageVaccinated12 (
	continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccination numeric,
	RollingPeopleVaccinated numeric
)

insert into #PercentageVaccinated12
select dea.continent, dea.location, dea.date, dea.population, vac.population_density as new_vaccination, 
sum(convert(int, vac.population_density)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..covidDeath dea
join PortfolioProject..CovidVacination vac
on dea.location = vac.location and dea.date = vac.date

select *, (RollingPeopleVaccinated/population)*100
from #PercentageVaccinated12;

-- Creating view to store data for later visualisation
CREATE VIEW PerPercentageVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.population_density as new_vaccination, 
sum(convert(int, vac.population_density)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..covidDeath dea
join PortfolioProject..CovidVacination vac
on dea.location = vac.location and dea.date = vac.date
where  dea.continent is not null

select *
from PerPercentageVaccinated;

