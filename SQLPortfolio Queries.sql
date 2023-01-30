USING EXPLORITORY ANALYSIS 

SELECT * FROM covid_deaths
ORDER BY 3,4

SELECT * FROM covid_vaccinations
ORDER BY 3,4

** selecting data to be used **
	SELECT location, date, total_cases, new_cases, total_deaths, population
	FROM covid_deaths
	ORDER by 1,2

** CONVERT DATE COLUMN TO PROPER DATE TYPE **
	ALTER TABLE covid_deaths
	ADD COLUMN date_converted DATE

	UPDATE covid_deaths
	SET date_converted = STR_TO_DATE(date, '%m/%d/%y')

	ALTER TABLE covid_deaths
	DROP COLUMN date

	ALTER TABLE `covid_deaths` 
	CHANGE `date_converted` `date` DATE NULL DEFAULT NULL;

** LOOKING FOR TOTAL CASES AND DEATHS PERCENTAGE **
	SELECT location, date, total_cases, total_deaths, ROUND((total_deaths / total_cases) * 100, 2) AS death_percentage
	FROM covid_deaths
	WHERE location like '%states%' and continent is not null
	ORDER by location, date;

** PERCENTAGE OF POP WITH COVID **
	SELECT location, date, total_cases, population, (total_cases / population) * 100 AS pop_percentage
	FROM covid_deaths
	WHERE location LIKE '%states%' and continent is not null
	ORDER BY location, date;

	SELECT location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population)) * 100 AS pop_percentage_infected
	FROM covid_deaths
	WHERE continent is not null
	GROUP BY location, population
	ORDER BY pop_percentage_infected DESC;

** TOTAL DEATHS FROM COVID PER LOCATION **
	SELECT location, MAX(total_deaths) as highest_death_count
	FROM covid_deaths
    	WHERE continent is not null 
    	AND location !='world' AND location not like '%income%'
	GROUP BY location
	ORDER BY highest_death_count DESC;

	SELECT location, MAX(total_deaths) as highest_death_count
	FROM covid_deaths
    	WHERE continent is not null AND continent != ' ' 
	GROUP BY location
    	ORDER BY highest_death_count DESC;

** Joining both tables **
	SELECT * 
	from covid_deaths as dea
	INNER JOIN covid_vaccinations as vac
	ON dea.location = vac.location AND dea.date = vac.date;

	SELECT dea.continent, dea.date, dea.population, vac.new_vaccinations
	FROM covid_deaths dea
	INNER JOIN covid_vaccinations vac
	ON dea.id = vac.id
	WHERE dea.continent IS NOT NULL
	ORDER BY 2,3;

	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_vac
	FROM covid_deaths dea
	INNER JOIN covid_vaccinations vac
	ON dea.id = vac.id
	WHERE dea.continent is not null
	ORDER BY 2,3;

** CTE rolling vaccination percentages **
	with PopVsVac (
	Continent, location, date, population, new_vaccinations, rolling_vac)
	as
	(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_vac
	FROM covid_deaths dea
	INNER JOIN covid_vaccinations vac
	ON dea.id = vac.id
	WHERE dea.continent is not null
	ORDER BY 2,3
	)
	select (rolling_vac/population) * 100
	from PopVsVac
