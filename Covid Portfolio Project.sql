select *
from covid_deaths
order by 3,4;


-- select *
from covid_vaccination
order by 3,4


-- select Data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows Likelihood of dying if you contract covid in youe country
select location, date, total_cases, total_deaths, (total_deaths / total_cases)* 100 as DeathPercentage
from coviddeaths
where location like '%state%'
order by 1,2


-- Looking at total case vc pupulation (What percantage of the population got Covid)
select location, date, Population, total_cases, (total_cases / Population)* 100 as PercentPopulationInfected
from coviddeaths
where location like '%states%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population
select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases / Population))*100 as PercentPopulationInfected
from coviddeaths
group by location, Population
order by PercentPopulationInfected DESC


-- Showing Countries with Highest Death Count per Population
select location, MAX(total_deaths) as TotalDeathCount
from coviddeaths
where continent is not null
group by location
order by TotalDeathCount DESC


-- Let's break things down by Continent
-- Showing continents with the highest death count per population
select continent, MAX(total_deaths) as TotalDeathCount
from coviddeaths
group by continent
order by TotalDeathCount DESC


-- Global Numbers
select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, sum(new_deaths)/sum(new_Cases) *100 as DeathPercentage
from coviddeaths
where continent is not null
group by date
order by date DESC



-- Looking at Total Population vs Vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeapleVaccinated
from coviddeaths dea
join covid_vaccination vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
order by 1,2


-- Use CTE
with PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeapleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeapleVaccinated
from coviddeaths dea
join covid_vaccination vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
)
select * ,(RollingPeapleVaccinated/population)*100 as PercentVaccinated
from PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP table if exists PercentPopulationVaccinated
create Table PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date date,
Population numeric,
New_vaccinations numeric,
RollingPeapleVaccinated numeric
);

Insert into PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeapleVaccinated
from coviddeaths dea
join covid_vaccination vac
   on dea.location = vac.location
   and dea.date = vac.date;
-- where dea.continent is not null

select * ,(RollingPeapleVaccinated/population)*100 as PercentVaccinated
from PercentPopulationVaccinated



-- Creating View to store data for later visualization

CREATE VIEW PercentPopulationVaccinated1 as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as RollingPeapleVaccinated
from coviddeaths dea
join covid_vaccination vac
   on dea.location = vac.location
   and dea.date = vac.date;

