SELECT * FROM portfolioproject.coviddeaths;
use portfolioproject;
select count(*) from coviddeaths;
select location, date, total_cases, new_cases, total_deaths, population from coviddeaths;
describe coviddeaths;

-- calculate deathpercentage
select location, convertdate, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage 
from coviddeaths
where location like '%states%'
and continent is not null;

-- calculate covid_rate
select location, date, total_cases, population, (total_cases/population)*100 as covid_rate
from coviddeaths
where location like '%states%'
and continent is not null;



-- countries with highest infection rate as compared to population
select location, population, max(total_cases) as Highest_Infection_count,  max((total_cases/population))*100 as highest_infection_rate
from coviddeaths
where continent is not null
group by location, population
order by highest_infection_rate desc;

-- countries with highest Death count per Population
select distinct continent from coviddeaths;
select location, max(convert(total_deaths, unsigned)) as highest_Death_Count
from coviddeaths
where continent is not null and upper(continent) in ('ASIA','AFRICA','OCEANIA','NORTH AMERICA','SOUTH AMERICA','EUROPE') 
group by location
order by highest_Death_Count desc;

-- continents with highest Death count per Population 
select distinct continent from coviddeaths;
select continent, max(convert(total_deaths, unsigned)) as highest_Death_Count
from coviddeaths
where continent is not null and upper(continent) in ('ASIA','AFRICA','OCEANIA','NORTH AMERICA','SOUTH AMERICA','EUROPE') 
group by continent
order by highest_Death_Count desc;

-- Global number

select sum(convert(new_cases, signed)) as total_cases, sum(CAST(new_deaths AS SIGNED)) as total_deaths, 
sum(convert(new_deaths, signed))/sum(convert(new_cases, signed))*100 as Death_percentage
from coviddeaths
where continent is not null and upper(continent) in ('ASIA','AFRICA','OCEANIA','NORTH AMERICA','SOUTH AMERICA','EUROPE')
order by 1,2;

select * from covidvaccinations;
select continent, location, date, new_tests, total_tests from covidvaccinations
where continent ='Asia'and location = 'Maldives' and date = '10/11/2020';

select convert(new_vaccinations, signed) from covidvaccinations;
-- total population vs vaccinated
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations, 
sum(convert(new_vaccinations, signed)) over( partition by dea.location order by dea.location, dea.date) as Rolling_vaccination
from coviddeaths dea join covidvaccinations vacc
on dea.location = vacc.location
and dea.date = vacc.date
where dea.continent is not null and 
upper(dea.continent) in ('ASIA','AFRICA','OCEANIA','NORTH AMERICA','SOUTH AMERICA','EUROPE')
order by location, date;

-- Use CTE   population vs  population vaccinated
with PopvsVac (continent, location, date, population_int, new_vaccinations, Rolling_vaccination) as
(
select dea.continent, dea.location, str_to_date(dea.date, '%m/%d/%Y') as date, convert(population, signed) as population_int, 
vacc.new_vaccinations, 
sum(convert(new_vaccinations, signed)) over( partition by dea.location order by dea.location, dea.date) as Rolling_vaccination
from coviddeaths dea join covidvaccinations vacc
on dea.location = vacc.location
and str_to_date(dea.date, '%m/%d/%Y') = str_to_date(vacc.date, '%m/%d/%Y')
where dea.continent is not null and upper(dea.continent) in ('ASIA','AFRICA','OCEANIA','NORTH AMERICA','SOUTH AMERICA','EUROPE')
)
select *, (Rolling_vaccination/population_int)*100 as Rolling_percentage from PopvsVac;

select date, str_to_date(date, '%m/%d/%Y') as date_time from coviddeaths;


-- Temp Table
drop table if exists percentpopulationvaccinated;
create Table percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population_int numeric,
new_vacc_int numeric,
Rolling_vaccination numeric 
);

insert into percentpopulationvaccinated
select 
dea.continent, 
dea.location, 
str_to_date(dea.date, '%m/%d/%Y') as date, 
case when population = '' then 0 else population end  as population_int, 
case when vacc.new_vaccinations = '' then 0 else  vacc.new_vaccinations end as new_vacc_int,
sum(vacc.new_vaccinations ) over( partition by dea.location order by dea.location, dea.date) as Rolling_vaccination
from coviddeaths dea join covidvaccinations vacc
on dea.location = vacc.location
and str_to_date(dea.date, '%m/%d/%Y') = str_to_date(vacc.date, '%m/%d/%Y')
where dea.continent is not null and upper(dea.continent) in ('ASIA','AFRICA','OCEANIA','NORTH AMERICA','SOUTH AMERICA','EUROPE');
select *, (Rolling_vaccination/population_int)*100 as Rolling_percentage from percentpopulationvaccinated;
select count(*) from percentpopulationvaccinated;

-- creating view
Create view populationvaccinated as 
select 
dea.continent, 
dea.location, 
str_to_date(dea.date, '%m/%d/%Y') as date, 
case when population = '' then 0 else population end  as population_int, 
case when vacc.new_vaccinations = '' then 0 else  vacc.new_vaccinations end as new_vacc_int,
sum(vacc.new_vaccinations ) over( partition by dea.location order by dea.location, dea.date) as Rolling_vaccination
from coviddeaths dea join covidvaccinations vacc
on dea.location = vacc.location
and str_to_date(dea.date, '%m/%d/%Y') = str_to_date(vacc.date, '%m/%d/%Y')
where dea.continent is not null and upper(dea.continent) in ('ASIA','AFRICA','OCEANIA','NORTH AMERICA','SOUTH AMERICA','EUROPE');







