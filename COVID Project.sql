Select *
From PortfolioProject..CovidDeath
Where continent is not null
Order By 3,4

Select *
From PortfolioProject..CovidVaccinations
Order By 3,4

 --Select Data

 Select Location, date, total_cases, new_cases, total_deaths, population
 From PortfolioProject..CovidDeath
 Where continent is not null
 Order By 1,2

 --Total Cases vs Total Deaths

  Select Location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
 From PortfolioProject..CovidDeath
 Where location like '%africa%'
 and continent is not null
 Order By 1,2

 --Total Cases vs Population

 Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
 From PortfolioProject..CovidDeath
 Where location like '%africa%'
 Order By 1,2
 
 --Countries with Highest Infection Rate compared to Population

 Select Location, Population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
 From PortfolioProject..CovidDeath
 --Where location like '%africa%'
 Group By location, population
 Order By PercentPopulationInfected DESC

 --COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION

  Select Location, MAX(cast(total_deaths as float)) as TotalDeathCountPerCountry
 From PortfolioProject..CovidDeath
 --Where location like '%africa%'
 Where continent is not null
 Group By location
 Order By TotalDeathCountPerCountry DESC

  --CONTINENT WITH THE HIGHEST DEATH COUNT

  Select continent, sum(new_deaths) as TotalDeathCountPerContinent
 From PortfolioProject..CovidDeath
 --Where location like '%africa%'
 Where continent is not null
 Group By continent
 Order By TotalDeathCountPerContinent DESC

 --GLOBAL NUMBERS

 Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
 From PortfolioProject..CovidDeath
 --Where location like '%africa%'
 Where continent is not null
 --Group By date
 Order By 1,2

 --Global Numbers per day

 Select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
 From PortfolioProject..CovidDeath
 --Where location like '%africa%'
 Where continent is not null
 Group By date
 Order By 1,2


 Select *
 From PortfolioProject..CovidDeath dea
 Join PortfolioProject..CovidVaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date
  
  --Total Population vs Vaccination (USING CTE)

 With PopvsVac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated) 
 as
 (
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
 dea.date) as RollingPeopleVaccinated
 From PortfolioProject..CovidDeath dea
 Join PortfolioProject..CovidVaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null
 --Order By 2,3
 )
 
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--Creating a Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
 dea.date) as RollingPeopleVaccinated
 From PortfolioProject..CovidDeath dea
 Join PortfolioProject..CovidVaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null
 --Order By 2,3

 Select *, (RollingPeopleVaccinated/population)*100 PercentVaccinated
From #PercentPopulationVaccinated

--Creating Views

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,
 dea.date) as RollingPeopleVaccinated
 From PortfolioProject..CovidDeath dea
 Join PortfolioProject..CovidVaccinations vac
 On dea.location = vac.location
 and dea.date = vac.date
 Where dea.continent is not null
 --Order By 2,3

Select *
From PercentPopulationVaccinated