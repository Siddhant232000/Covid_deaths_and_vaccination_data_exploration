Select *
From project_portfolio..CovidDeathsEW
where continent is not null
order by 3,4


--Select *
--From project_portfolio..covidVaccinationEW
--order by 3,4


-- select data that we are going to using

select Location, date,total_cases,new_cases,total_deaths, population
from project_portfolio..covidDeathsEW
order by 1,2

--total case vs total death
-- shows likelyhood of dying if you get infected
select Location, date,total_cases,total_deaths,(total_cases/total_deaths)*100 as deathPercentage
from project_portfolio..covidDeathsEW
where location like '%ndia%'
and continent is not null
order by 1,2


--total case vs population of country
--this will show what percentage of population got infected

select Location, date,total_cases,population,(total_cases/population)*100 as infection_percentage
from project_portfolio..covidDeathsEW
where location like '%ndia%'
order by 1,2

-- what country has highest infection rate compare to population

select Location,population,max(total_cases) as highest_infection_country ,max((total_cases/population))*100 as percenet_population_infected
from project_portfolio..covidDeathsEW
--where location like '%ndia%'
group by location,population
order by percenet_population_infected desc

-- shows highest country deathcount

select Location,max(cast(total_deaths as int)) as total_deathcount
from project_portfolio..covidDeathsEW
--where location like '%ndia%'
where continent is not null
group by location
order by total_deathcount desc

-- same upper query by continent
select continent,max(cast(total_deaths as int)) as total_deathcount
from project_portfolio..covidDeathsEW
--where location like '%ndia%'
where continent is not null 
group by continent
order by total_deathcount desc 

 --showing continent with the highest death count pe population 

 select continent,max(cast(total_deaths as int)) as total_deathcount
from project_portfolio..covidDeathsEW
--where location like '%ndia%'
where continent is not null 
group by continent
order by total_deathcount desc 


--world numbers

select sum(new_cases) as total_cases ,sum(cast(new_deaths as int)) as total_deaths,SUM(CAST(new_deaths as int))/
sum(new_cases)*100  as deathPercentage
from project_portfolio..covidDeathsEW
--where location like '%ndia%'
where continent is not null
--group by date
order by 1,2



-- looking at total population vs vaccination
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location
, dea.date) as RollingPeoplevaccinated
-- (RollingPeoplevaccinated/population)*100 
from project_portfolio..covidDeathsEW  dea
join project_portfolio..covidVaccinationEW  vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use cte

with popvsvac (continent,location ,Date,population,new_vaccinations,RollingPeoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location
, dea.date) as RollingPeoplevaccinated
--, (RollingPeoplevaccinated/population)*100 
from project_portfolio..covidDeathsEW  dea
join project_portfolio..covidVaccinationEW  vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeoplevaccinated/population)*100 
from popvsvac

--temp table
DROP Table if exists #PercentPopulationVaccinatedNEW
create table #percentpopulationvaccinatedNEW
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeoplevaccinated numeric
)

insert into #percentpopulationvaccinatedNEW
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location
, dea.date) as RollingPeoplevaccinated
--, (RollingPeoplevaccinated/population)*100 
from project_portfolio..covidDeathsEW  dea
join project_portfolio..covidVaccinationEW  vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *,(RollingPeoplevaccinated/population)*100 
from #percentpopulationvaccinatedNEW



----create view to store data for viz 

drop view if exists percentpopulationvaccinatedNEW

USE project_portfolio
go
Create View percentpopulationvaccinatedNEW as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From project_portfolio..covidDeathsEW  dea
join project_portfolio..covidVaccinationEW  vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


--
select *
from percentpopulationvaccinatedNEW