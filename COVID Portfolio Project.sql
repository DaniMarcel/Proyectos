SELECT * FROM CovidDeaths
WHERE continent IS NOT NULL
SELECT * FROM CovidVaccinations

-- SELECCIONAR LOS DATOS QUE USAREMOS
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2 -- ORDENAMOS POR LOCATION Y DATE


-- TOTAL DE CASOS VS TOTAL DE MUERTES
-- MOSTRAR LA PROBABILIDAD DE MORIR SI TENIAS COVID EN TU PAIS
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE location LIKE 'Chile'
AND continent IS NOT NULL
ORDER BY 1,2


-- CASOS TOTALES VS LA POBLACION
-- MOSTRAR QUE PORCENTAJE DE LA POBLACION TUVO COVID
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationsInfected
FROM CovidDeaths
--WHERE location LIKE 'Chile'
WHERE continent IS NOT NULL
ORDER BY 1,2


-- PAISES CON LA MAYOR TASA DE INFECCION EN COMPARACION CON LA POBLACION
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationsInfected
FROM CovidDeaths
--WHERE location LIKE 'Chile'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationsInfected DESC


-- PAISES CON EL MAYOR RECUENTO DE MUERTES POR POBLACION
SELECT location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
--WHERE location LIKE 'Chile'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- VAMOS A DIVIDIRLO POR CONTINENTE

-- MUESTRA LOS CONTINENTE CON EL MAYOR RECUENTO DE MUERTES POR POBLACION
SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
--WHERE location LIKE 'Chile'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- NUMEROS GLOBALES
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_death, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
--WHERE location LIKE 'Chile'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

--------------------------------------------------------------------------------------------------------------

SELECT * FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

-- POBLACION TOTAL VS VACUNADOS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- USANDO CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Caccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


-- USANDO TABLA TEMPORAL
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



-- CREAR VISTAS PARA VISUALIZARLAS DESPUES
CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Location, dea.Date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT * FROM PercentPopulationVaccinated