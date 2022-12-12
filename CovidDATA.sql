/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
 From Project_Covid.[dbo].[Covid_Deaths]
 WHERE continent is NOT null
 ORDER BY 3,4
 GO

 --SELECT *
 --From Project_Covid.dbo.Covid_Vaccinatons
 --ORDER BY 3,4
 --GO

 --Selecting Data we need 

 SELECT location ,date, new_cases, total_cases,total_deaths, population
 FROM Project_Covid.dbo.Covid_Deaths
 WHERE continent is NOT null
 ORDER BY 1,2
 GO

 --Total cases Vs Total Deaths
 
 SELECT location ,date, total_cases,total_deaths, (total_deaths/total_cases)*100 as death_to_cases_percentage
 FROM Project_Covid.dbo.Covid_Deaths
 --WHERE location like '% States%'
 WHERE continent is NOT null
 ORDER BY 1,2
 GO

 --Population Vs Total Cases
 SELECT location ,date, total_cases,population, (total_cases/population)*100 as Positive_to_population_percentage
 FROM Project_Covid.dbo.Covid_Deaths
 --WHERE location like '% States%'
 WHERE continent is NOT null
 ORDER BY 1,2
 GO

 -- Countries with highest infection
 SELECT location, population ,  Max(total_cases) as highest_infection, MAX((total_cases/population)*100) as percentpopulationinfected
 FROM Project_Covid.dbo.Covid_Deaths
 --WHERE location like '% States%'
 WHERE continent is NOT null
 GROUP BY location, population
 ORDER BY percentpopulationinfected DESC
 GO

 -- Countries with highest death
 SELECT location ,Max(cast(total_deaths as int)) as highest_deaths
 FROM Project_Covid.dbo.Covid_Deaths
 --WHERE location like '% States%'
 WHERE continent is NOT null
 GROUP BY location
 ORDER BY highest_deaths DESC
 GO

 -- Countries with highest death percentage
 SELECT location, population ,  Max(cast(total_deaths as int)) as highest_deaths, MAX((cast(total_deaths as int)/population)*100) as percentpopulationdeaths
 FROM Project_Covid.dbo.Covid_Deaths
 --WHERE location like '% States%'
 WHERE continent is NOT null 
             and total_deaths is not null
 GROUP BY location, population
 ORDER BY 3 DESC
 GO

 -- Continents with highest death
 SELECT continent ,Max(cast(total_deaths as int)) as highest_deaths
 FROM Project_Covid.dbo.Covid_Deaths
 --WHERE location like '% States%'
 WHERE continent is NOT null
 GROUP BY continent
 ORDER BY highest_deaths DESC
 GO

 --Global sum of cases
  SELECT date, sum(new_cases) as totalCases,sum(cast(new_deaths as int)) as total_death , (sum(cast(new_deaths as int))/sum(new_cases))*100 as deathpercentage
 FROM Project_Covid.dbo.Covid_Deaths
 --WHERE location like '% States%'
 WHERE continent is NOT null
 group by date
 ORDER BY 1
 GO

 --Total cases and deaths
   SELECT  sum(new_cases) as totalCases,sum(cast(new_deaths as int)) as total_death , (sum(cast(new_deaths as int))/sum(new_cases))*100 as deathpercentage
 FROM Project_Covid.dbo.Covid_Deaths
 --WHERE location like '% States%'
 WHERE continent is NOT null
 --group by date
 ORDER BY 1
 GO


 Select dea.continent,dea.location,dea.date,dea.new_cases,vac.new_vaccinations , 
     SUM(
	     CAST(vac.new_vaccinations as int)) 
	       OVER ( PARTITION BY dea.location 
	                 ORDER BY dea.location,dea.date) as RollingVaccinatedPeople
				        
 From Project_Covid.dbo.CovidVaccinatoins vac
  JOIN Project_Covid.dbo.Covid_Deaths dea
   on  vac.location=dea.location
    and vac.date=dea.date
 where dea.continent is not null
 --GROUP BY vac.location
 order by 2,3
 GO


 --use CTE
 WITH PopulationVAc ( Continent, Location, Date, Population, new_cases, New_vaccination, RollingVaccinatedPeople )
 as
 (
  Select dea.continent,dea.location,dea.date, dea.population,dea.new_cases,vac.new_vaccinations , 
     SUM(
	     CAST(vac.new_vaccinations as int)) 
	       OVER ( PARTITION BY dea.location 
	                 ORDER BY dea.location,dea.date) as RollingVaccinatedPeople
				        
 From Project_Covid.dbo.CovidVaccinatoins vac
  JOIN Project_Covid.dbo.Covid_Deaths dea
   on  vac.location=dea.location
    and vac.date=dea.date
 where dea.continent is not null
 )
 Select *,(RollingVaccinatedPeople/Population)*100 as Vaccinationpercentage
 From PopulationVAc

 --USING TEMP TABLE
 
DROP TABLE IF EXISTS #PercentpeopleVaccinated
create table #PercentpeopleVaccinated
(Continent nvarchar(255), 
 Location nvarchar(255), 
 Date datetime,
 Population numeric, 
 New_cases numeric, 
 New_vaccination numeric, 
 RollingVaccinatedPeople numeric)

 Insert into #PercentpeopleVaccinated(Continent , Location , Date ,Population, New_cases , New_vaccination , RollingVaccinatedPeople)
 Select dea.continent,dea.location,dea.date, dea.population,dea.new_cases,vac.new_vaccinations ,SUM(CAST(vac.new_vaccinations as int)) OVER ( PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingVaccinatedPeople
 From Project_Covid.dbo.CovidVaccinatoins vac JOIN Project_Covid.dbo.Covid_Deaths dea on  vac.location=dea.location and vac.date=dea.date
 where dea.continent is not null

 Select *,(RollingVaccinatedPeople/Population)*100 as Vaccinationpercentage
 From #PercentpeopleVaccinated

 --Create view
 
 Create View PercentPopulationVaccinated as
 Select dea.continent,dea.location,dea.date, dea.population,dea.new_cases,vac.new_vaccinations ,SUM(CAST(vac.new_vaccinations as int)) OVER ( PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingVaccinatedPeople
 From Project_Covid.dbo.CovidVaccinatoins vac JOIN Project_Covid.dbo.Covid_Deaths dea on  vac.location=dea.location and vac.date=dea.date
 where dea.continent is not null

 select * 
 from PercentPopulationVaccinated