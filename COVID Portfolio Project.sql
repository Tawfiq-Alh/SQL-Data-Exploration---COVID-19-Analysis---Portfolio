
Select *
From CovidDeaths$
--to delete continent colums
Where continent is not null
order by 3,4

--Select *
--From CovidVaccinations$
--order by 3,4

--Select Data that we are going to be using
Select Location, Date,new_cases, Total_Cases, Total_Deaths,population
From CovidDeaths$
Order by 1,2

--looking at Total Cases vs Total Deaths 

Select Location, Date,Total_Cases, Total_Deaths , (Total_Deaths/Total_Cases)*100 as Death_Rate
From CovidDeaths$
where location like '%state%'
and Continent is not null
Order by 1,2

--looking at Total Cases vs population
--Shows what percentage of the population has been infected with Covid-19 in the United States
Select Location, Date,Total_Cases, (Total_Cases/population)*100 as Case_Rate
From CovidDeaths$
where location like '%states%'
Order by 1,2

--looking at country with Highest Infection Rate compared to population
Select Location, population,MAX(Total_Cases) as HighestDeathRate , MAX ((Total_Cases/population))*100 as ParcentPopulationInfected
From CovidDeaths$
--where location like '%states%'
Group by Location, Population
Order by ParcentPopulationInfected desc

--showing Countries with the highest death rate compared count per population
Select Location,MAX(cast(Total_Deaths as int)) as HighestDeathRate 
From CovidDeaths$
where continent is not null
Group by Location
Order by HighestDeathRate desc

-- by Continent
Select continent,MAX(cast(Total_Deaths as int)) as HighestDeathRate 
From CovidDeaths$
where continent is not null
Group by continent
Order by HighestDeathRate desc


--Global Numbers
Select  Sum(new_cases) as total_cases ,sum(cast(new_Deaths as int))as total_deaths , sum(cast(new_Deaths as int))/Sum(new_cases)*100 as Death_Rate
From CovidDeaths$
--where location like '%state%'
where Continent is not null
--Group by Date
Order by 1,2

----------------------------
--looking at total population vs vaccinated  
Select CovidDeaths$.continent, CovidDeaths$.location,CovidDeaths$.Date, CovidDeaths$.population,
CovidVaccinations$.new_vaccinations,
Sum(Convert(int, CovidVaccinations$.new_vaccinations)) over (partition by CovidDeaths$.location order by CovidDeaths$.location,CovidDeaths$.Date) as RollingpeopleVaccinations
--,(RollingpeopleVaccinations/CovidDeaths$.population)*100 as PercentPopulationVaccinated
From CovidDeaths$
join CovidVaccinations$
on CovidDeaths$.location = CovidVaccinations$.location
and CovidDeaths$.date = CovidVaccinations$.date
where CovidDeaths$.continent is not null
order by 2,3

--USE CTE

with PopvsVac(continent, location, Date, population,new_vaccinations,RollingpeopleVaccinations)
as
 (
 Select CovidDeaths$.continent, CovidDeaths$.location,CovidDeaths$.Date, CovidDeaths$.population,
CovidVaccinations$.new_vaccinations,
Sum(Convert(int, CovidVaccinations$.new_vaccinations)) over (partition by CovidDeaths$.location order by CovidDeaths$.location,CovidDeaths$.Date) as RollingpeopleVaccinations
--,(RollingpeopleVaccinations/CovidDeaths$.population)*100 as PercentPopulationVaccinated
From CovidDeaths$
join CovidVaccinations$
on CovidDeaths$.location = CovidVaccinations$.location
and CovidDeaths$.date = CovidVaccinations$.date
where CovidDeaths$.continent is not null
--order by 2,3
)
Select*,(RollingpeopleVaccinations/population)*100 as PercentPopulationVaccinated
From PopvsVac


--Temporary table


--from edit 
Drop table if exists #PercentPopulationVaccinated

 create Table #PercentPopulationVaccinated
(continent nvarchar(255), 
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingpeopleVaccinations numeric
)

insert into #PercentPopulationVaccinated
 Select CovidDeaths$.continent, CovidDeaths$.location,CovidDeaths$.Date, CovidDeaths$.population,
CovidVaccinations$.new_vaccinations,
Sum(Convert(int, CovidVaccinations$.new_vaccinations)) over (partition by CovidDeaths$.location order by CovidDeaths$.location,CovidDeaths$.Date) as RollingpeopleVaccinations
--,(RollingpeopleVaccinations/CovidDeaths$.population)*100 as PercentPopulationVaccinated
From CovidDeaths$
join CovidVaccinations$
on CovidDeaths$.location = CovidVaccinations$.location
and CovidDeaths$.date = CovidVaccinations$.date
--where CovidDeaths$.continent is not null
--order by 2,3

Select*,(RollingpeopleVaccinations/population)*100 as PercentPopulationVaccinated
From #PercentPopulationVaccinated

--create view to store data for later Visualization
Create view PercentPopulationVaccinated as

Select CovidDeaths$.continent, CovidDeaths$.location,CovidDeaths$.Date, CovidDeaths$.population,
CovidVaccinations$.new_vaccinations,
Sum(Convert(int, CovidVaccinations$.new_vaccinations)) over (partition by CovidDeaths$.location order by CovidDeaths$.location,CovidDeaths$.Date) as RollingpeopleVaccinations
--,(RollingpeopleVaccinations/CovidDeaths$.population)*100 as PercentPopulationVaccinated
From CovidDeaths$
join CovidVaccinations$
on CovidDeaths$.location = CovidVaccinations$.location
and CovidDeaths$.date = CovidVaccinations$.date
where CovidDeaths$.continent is not null
--order by 2,3