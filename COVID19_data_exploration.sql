select * 
from covid19_data_exploration..CovidDeaths$
order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
from covid19_data_exploration..CovidDeaths$
order by 1,2



select location, date, total_cases, total_deaths, population,(total_deaths/total_cases)*100 as death_percentage
from covid19_data_exploration..CovidDeaths$
where location like 'Egypt'
order by 1,2


select location, date, population, total_cases,(total_cases/population)*100 as cases_percentage
from covid19_data_exploration..CovidDeaths$
where location like '%states%'
order by 1,2


select location, population, max(total_cases) as HigestInfectionCount,max((total_cases/population))*100 as cases_percentage
from covid19_data_exploration..CovidDeaths$
group by location
order by cases_percentage desc



select location, max(cast (total_deaths as int)) as HigestDeathCount 
from covid19_data_exploration..CovidDeaths$
where continent is not null
group by location
order by HigestDeathCount desc




select date, SUM(new_cases ) as new_cases_today, Sum(cast (new_deaths as int)) as new_deaths_today,  
sum(new_deaths )/Sum(cast (new_deaths as int))*100 as deaths_percentage
from covid19_data_exploration..CovidDeaths$
where continent is not null
group by date
order by 1,2



select * 
from covid19_data_exploration..CovidVaccinations$
order by 3,4



select * 
from covid19_data_exploration..CovidVaccinations$ vac
join covid19_data_exploration..CovidDeaths$ dea
  on vac.location=dea.location and vac.date = dea.date



with population_vs_vaccination (continent, location, date, population, new_vaccinations, total_vaccinated)
as
(
select dea.continent,  dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as total_vaccinated
from covid19_data_exploration..CovidVaccinations$ vac
join covid19_data_exploration..CovidDeaths$ dea
  on vac.location=dea.location and vac.date = dea.date
where dea.continent is not null
--order by 2,3
)

select * ,(total_vaccinated/population)*100 as vaccinationPercentage
from population_vs_vaccination


DROP Table if exists #PercentPopulationVaccinated
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
select dea.continent,  dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as total_vaccinated
from covid19_data_exploration..CovidVaccinations$ vac
join covid19_data_exploration..CovidDeaths$ dea
  on vac.location=dea.location and vac.date = dea.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
