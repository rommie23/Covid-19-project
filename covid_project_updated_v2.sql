

-- Chances of dying through covid in India --

select location, date_1, total_cases,total_deaths, (total_deaths/total_cases)*100 as death_rate
from covid_deaths
where location LIKE '%India%'
order by 1,2;

-- Chances of getting contaminated by Covid in India --
select location, date_1, population, total_cases, (total_cases/population)*100 as contamination_rate
from covid_deaths
where location LIKE '%India%'
order by 1,2;

--Max contamination by countries --
select location, population, MAX(total_cases) as high_infection_cases , MAX((total_cases/population)*100) as population_contaminated
from covid_deaths
Group by location, population
ORDER BY  1;

--Countries with highest deaths--

select location, MAX(total_deaths) as highest_deaths
from covid_deaths
where continent is not null
group by location
order by 2 desc;

-- Max Death rate of countries--

select location, population, MAX(total_deaths) as highest_death_cases, MAX((total_deaths/population)*100) as max_death_rate
from covid_deaths
where continent is not null
group by location, population
order by 4 desc;

-- Deaths by continent--

select location, max(total_deaths)
from covid_deaths
where continent is null
group by continent, location
order by 1;

-- Global Numbers--

select date_1, sum(new_cases), sum(new_deaths), (sum(new_deaths)/sum(new_cases))*100 as death_percentage
from covid_deaths
where continent is not null
group by date_1
order by 1,2;

-- new table glimpse--
select * 
from covid_vaccination
where continent is not null;

-- join the new table--
select *
from covid_deaths
join covid_vaccination
on covid_deaths.location = covid_vaccination.location
and covid_deaths.date_1 = covid_vaccination.date_1;

-- by giving aliasing for increasing accesibility --
-- Vaccination of people by total population--
select dea.continent, dea.location, dea.date_1, dea.population, vac.new_vaccinations
,sum(vac.new_vaccinations) over (PARTITION by dea.location order by dea.location, dea.date_1) as counting_vaccination
from covid_deaths dea
join covid_vaccination vac
    on dea.location = vac.location
    and dea.date_1 = vac.date_1
where dea.continent is not null
and dea.location = 'Canada'
order by 2,3;

-- Using CTE--
with pop_vs_vac (continent,location,date_1, population, new_vaccinations, counting_vaccinations)
as(
select dea.continent, dea.location, dea.date_1, dea.population, vac.new_vaccinations
,sum(vac.new_vaccinations) over (PARTITION by dea.location order by dea.location, dea.date_1) as counting_vaccinations
from covid_deaths dea
join covid_vaccination vac
    on dea.location = vac.location
    and dea.date_1 = vac.date_1
where dea.continent is not null
and dea.location = 'Canada'
)
select continent,location,date_1,population, new_vaccinations,counting_vaccinations,(counting_vaccinations/population)*100
from pop_vs_vac;


-- TEMP TABLE--
CREATE TABLE percent_population_vaccinated
(
continent NVARCHAR2,
location NVARCHAR2,
date_1 DATE,
population NUMERIC,
new_vaccination NUMERIC,
counting_vacciantion NUMERIC
)
insert into percent_population_vaccinated
select dea.continent, dea.location, dea.date_1, dea.population, vac.new_vaccinations
,sum(vac.new_vaccinations) over (PARTITION by dea.location order by dea.location, dea.date_1) as counting_vaccinations
from covid_deaths dea
join covid_vaccination vac
    on dea.location = vac.location
    and dea.date_1 = vac.date_1
where dea.continent is not null
and dea.location = 'Canada';


select continent,location,date_1,population, new_vaccinations,counting_vaccinations,(counting_vaccinations/population)*100
from percent_population_vaccinated;


-- Creating View--

create view percent_population as
select dea.continent, dea.location, dea.date_1, dea.population, vac.new_vaccinations
,sum(vac.new_vaccinations) over (PARTITION by dea.location order by dea.location, dea.date_1) as counting_vaccinations
from covid_deaths dea
join covid_vaccination vac
    on dea.location = vac.location
    and dea.date_1 = vac.date_1
where dea.continent is not null;

select * from percent_population;