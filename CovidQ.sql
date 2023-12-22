--Deaths vs Cases
Select 
	location
	, date
	, total_cases
	, population
	,(total_deaths/total_cases)*100 AS DeathPercentage
From 
	[PP Covid].[dbo].[Covid Dead]
Order by 1,2

--------------------------------------------------------------------------------------------------------

--Highest cases & % of pop infected
Select
	Location
	, Population
	, Max(total_cases) as 'Highest Cases'
	, max((total_cases/population))*100 as '%Pop Infected'
From
	[PP Covid]..[Covid Dead]
Group by
		population
		, location
Order by '%Pop Infected' desc

----------------------------------------------------------------------------------------------------------

--Highest Deaths per Country
Select
	Location
	, max(total_deaths) as '#Total Deaths'
From
	[PP Covid]..[Covid Dead] Where continent!=''
Group by
		location
Order by 
	'#Total Deaths' desc

----------------------------------------------------------------------------------------------------------

--Highest Deaths per Continent
Select
	continent
	, max(total_deaths) as '#Total Deaths'
From
	[PP Covid]..[Covid Dead] Where continent!=''
Group by
	continent
Order by 
	'#Total Deaths' desc

----------------------------------------------------------------------------------------------------------

--Global Numbers (New Cases and New Deaths)
Select 
	date
	, sum(new_cases) as 'SumNewCases'
	, sum(new_deaths) as 'SumNewDeath'
	, sum(new_deaths)/(nullif(sum(new_cases),0))*100 as 'nDeath%nCases'
From 
	[PP Covid].[dbo].[Covid Dead]
Group by date
Order by 
	1,2

----------------------------------------------------------------------------------------------------------

--Rolling vaxd vs population
With PopvsVac	(continent
				, location
				, date
				, population
				, new_vaccinations
				, RollingPPLVaxd
				) as
(
	Select
			dea.continent
			, dea.location
			, dea.date
			, dea.population
			, vac.new_vaccinations
			, sum(vac.new_vaccinations) 
				over (
					partition by
						dea.location 
					order by 
						dea.location
						, dea.date
				) as RollingPPLVaxd
	From
			[PP Covid]..[Covid Dead] as dea 
		join 
			[PP Covid]..[Covid Vaccines] vac
		on
			dea.location = vac.location
		and
			dea.date = vac.date
	Where
			dea.continent!=''
)
Select*
	  , (RollingPPLVaxd/population)*100 as 'RollingVaxd%Pop'
From PopvsVac

--------------------------------------------------------------------------------------------------------