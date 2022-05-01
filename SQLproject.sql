Select * From covidproject..['CovidDeath']

Select * From covidproject..['CovidVaccination']
 
 --Select data that using

-- Select location, date, total_cases, new_cases, total_deaths, population 
-- From covidproject..['CovidDeath']
-- order by 1,2

 --Total cases vs total deaths

 Select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as deathsPercentage
 From covidproject..['CovidDeath']
 Where location like '%india'
 order by 1,2

 --{show % of population}
 Select location, date, total_cases,  population, (total_deaths/total_cases)*100 as deathsPercentage
 From covidproject..['CovidDeath']
 Where location like '%india'
 order by 1,2

-- --country with highest rate
 Select location,  population, MAX(total_cases) as HighestCases, MAX(total_cases/population)*100 as infectedPercentage
 From covidproject..['CovidDeath']
Group by location, population
 order by infectedPercentage desc

 --location with highest death count/population
Select continent,  MAX(cast(total_deaths as int)) as DeathCount
 From covidproject..['CovidDeath']
where continent is not null
Group by continent
order by DeathCount desc



 --global numbers
 Select date, SUM (new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deathsPercentage
 From covidproject..['CovidDeath']
 ----Where location like '%india'
 where continent is not null
 Group BY date
 order by 1,2
 

 --- both table join
 ---looking at total population vs vaccination
 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(Cast (vac.new_vaccinations as bigint)) OVER (Partition by dea.location,  CONVERT (date,dea.date)) AS cumulative_vaccination
-- --,(cumulative_vaccination/population)*100
 from covidproject..['CovidDeath'] dea join
 covidproject..['CovidVaccination'] vac 
       on dea.location = vac.location
        and dea.date = vac.date
 where dea.continent is not null 
order by 2,3 ;

 ----USE CTE

 with popolationVsvaccination (continent, location, date, population,new_vaccinations, cumulative_vaccination)
 as
 (
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
 SUM(Cast (vac.new_vaccinations as bigint)) OVER (Partition by dea.location  , CONVERT (date,dea.date)) AS cumulative_vaccination
 --,(cumulative_vaccination/population)*100
 from covidproject..['CovidDeath'] dea join
 covidproject..['CovidVaccination'] vac 
       on dea.location = vac.location
        and dea.date = vac.date
 where dea.continent is not null 
 )
 select*, (cumulative_vaccination/population)*100 from
 popolationVsvaccination

 ----TEMP TABLE
 Create table PopsVaccine
 ( continent nvarchar(255),
   location nvarchar(255),
   date datetime,
   population numeric,
   new_vaccinations numeric,
   cumulative_vaccination numeric)
   insert into PopsVaccine
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
 SUM(Cast (vac.new_vaccinations as bigint)) OVER (Partition by dea.location  , CONVERT (date,dea.date)) AS cumulative_vaccination
 --,(cumulative_vaccination/population)*100
 from covidproject..['CovidDeath'] dea join
 covidproject..['CovidVaccination'] vac 
       on dea.location = vac.location
        and dea.date = vac.date
 where dea.continent is not null 
 select*, (cumulative_vaccination/population)*100 from
 PopsVaccine

 ---- VIEW 
 create view  percentagePopulationVaccine as
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
 SUM(Cast (vac.new_vaccinations as bigint)) OVER (Partition by dea.location  , CONVERT (date,dea.date)) AS cumulative_vaccination
 --,(cumulative_vaccination/population)*100
 from covidproject..['CovidDeath'] dea join
 covidproject..['CovidVaccination'] vac 
       on dea.location = vac.location
        and dea.date = vac.date
 where dea.continent is not null 
