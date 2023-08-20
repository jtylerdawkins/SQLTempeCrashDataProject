-- SELECT * FROM TempeGovCrashData;

-- What year had the most reports?
SELECT TOP 1 YEAR, COUNT(Incidentid) AS MaxIncidentCount -- Select the year with the highest number of unique incidents
FROM TempeGovCrashData
GROUP BY YEAR -- Group and count all of the Incidentids by their Year
ORDER BY MaxIncidentCount DESC; -- Put highest at the top, descending order
-- Result: Year 2019 with 5,366

-- What year was the most fatal? There is a "Totalfatalities" that will be useful for this.
SELECT TOP 1 YEAR, SUM(CAST(Totalfatalities AS INT)) AS YearWithHighestFatalities -- Sum the fatalities, there was a mistake and Totalfatalities are "nvarchar" types so they need to be casted as integers
FROM TempeGovCrashData
GROUP BY YEAR -- Group the sums based on year
ORDER BY YearWithHighestFatalities DESC; -- Put highest at the top, descending order
-- Result: Year 2021 with 17 fatalities.

-- What streets appear most often in these incident reports? (Use both the street and cross street)
-- I want to look in both StreetName and CrossStreet columns, and count the frequency of similar strings
SELECT StreetOrCrossStreet, COUNT(*) AS Count
FROM (
    SELECT StreetName AS StreetOrCrossStreet FROM TempeGovCrashData
    UNION ALL -- I want to merge the two street columns together for this particular query
    SELECT CrossStreet AS StreetOrCrossStreet FROM TempeGovCrashData
) AS CombinedData
GROUP BY StreetOrCrossStreet
ORDER BY Count DESC; -- Put the most frequent at the top
-- Result: Rural Rd appears the most often at 6,787 incidents.

-- What type of incidents are most common?
-- I only want to look at "driver 1" since that appears to be the driver causing the reported incidents. This might be due to a data entry preference.
SELECT Violation1_Drv1, COUNT(*) AS Count
FROM TempeGovCrashData
GROUP BY Violation1_Drv1
ORDER BY Count DESC;
-- Result: The most common incident cause seems to be Speed To Fast For Conditions. Maybe they meant TOO fast? Not sure.
-- Failed To Yield Right Of Way came in at a close second.

-- What type of lighting conditions do most incidents occur?
SELECT Lightcondition, COUNT(*) AS Count
FROM TempeGovCrashData
GROUP BY Lightcondition
ORDER BY Count DESC;
-- Result: As expected, most incidents occur when it is dark and since they happen in the inner city, it is lit by street lights. "Dark Lighted"
-- A lot also happen at Dusk, when the sun is setting and the light conditions are changing and driver's eyes are adjusting to the changes. Or people forget to probably turn on their lights.

-- What type of weather do most incidents occur?
SELECT Weather, COUNT(*) AS Count
FROM TempeGovCrashData
GROUP BY Weather
ORDER BY Count DESC;
-- Result: Most incidents happen when it is clear weather. This isn't too surprising since Arizona's weather lends itself to clear skies.
-- However, now I want to know... Does rain increase the volume of incidents?
-- I will probably need to collect weather data and see how many incidents happen, on average, on a rainy day vs. a clear day.
-- Or I can continue using this data set and utilize the DateTime data to find my answer.

-- This query takes the DateTime and just returns it in YYYY/MM/DD format. We can use this to see how many incidents happen per day.
SELECT FORMAT(DateTime, 'yyyy/MM/dd') AS FormattedDate
FROM TempeGovCrashData;

-- This query actually counts how many incidents happened on each day and returns what the weather was that day.
SELECT FORMAT(DateTime, 'yyyy/MM/dd') AS FormattedDate, Weather, COUNT(Incidentid) AS IncidentCount
FROM TempeGovCrashData
GROUP BY FORMAT(DateTime, 'yyyy/MM/dd'), Weather
ORDER BY IncidentCount DESC;
-- Result: The highest incident days are still Clear weather, but one of the highest was a rainy day.
-- But there are way more Clear weather days than Rainy weather days, so maybe an "average incidents" based on weather type for that day would be better?


-- To explore further, I would like to see averages based on weather type. Since there are not many rainy days in Arizona, I want to see if they are more dangerous when they -do- happen.
SELECT
    Weather,
    COUNT(DISTINCT FormattedDate) AS UniqueDays,
    SUM(IncidentCount) AS TotalIncidents,
    CAST(SUM(IncidentCount) AS FLOAT) / COUNT(DISTINCT FormattedDate) AS AverageIncidentsPerDay
FROM (
    SELECT
        FORMAT(DateTime, 'yyyy/MM/dd') AS FormattedDate,
        Weather,
        COUNT(IncidentID) AS IncidentCount
    FROM TempeGovCrashData
    GROUP BY FORMAT(DateTime, 'yyyy/MM/dd'), Weather
) AS GroupedData
GROUP BY Weather
ORDER BY Weather;
-- Result: There are about 10-11 incidents per day when it is Clear, and 3-4 when it is Rain.
-- So, maybe weather does not seem to drastically affect the incidents. Perhaps most Arizona drivers drive safer or don't drive at all during rain.

-- How many incidents were alcohol-related?
SELECT
    SUM(CASE WHEN AlcoholUse_Drv1 = 'No Apparent Influence' THEN 1 ELSE 0 END) AS CountNoApparentInfluence,
    SUM(CASE WHEN AlcoholUse_Drv1 = 'Alcohol' THEN 1 ELSE 0 END) AS CountAlcohol,
    COUNT(*) AS TotalEntries,
    CAST(SUM(CASE WHEN AlcoholUse_Drv1 = 'Alcohol' THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) AS AlcoholRatio
FROM TempeGovCrashData;
-- Result: 2,063 out of 43,998 incidents were alcohol related. This is 0.0468 or 4.7% of incidents.
-- So, about 1 out of 21 incidents are alcohol-related.
-- On another note, this data set ranges from 2012 to 2022. That is 10 years of data, or 3,650 days.
-- If there were 2,063 alcohol incidents, that means there were enough alcohol-related incidents to span 56% (over half) of the decade if one happened each day.
-- Considering these are only the "reported" incidents, and are also limited to just Tempe, that is a little concerning (to me).

-- How many drivers were female and how many were male? I don't think this matters too much, but I am curious and already querying the data, so why not?
SELECT
    CountFemale,
    CountMale,
    (CAST(CountFemale AS FLOAT) / (CountMale + CountFemale)) * 100 AS PercentageFemale,
    (CAST(CountMale AS FLOAT) / (CountMale + CountFemale)) * 100 AS PercentageMale
FROM (
    SELECT
        SUM(CASE WHEN Gender_Drv1 = 'Female' THEN 1 ELSE 0 END) + SUM(CASE WHEN Gender_Drv2 = 'Female' THEN 1 ELSE 0 END) AS CountFemale,
        SUM(CASE WHEN Gender_Drv1 = 'Male' THEN 1 ELSE 0 END) + SUM(CASE WHEN Gender_Drv2 = 'Male' THEN 1 ELSE 0 END) AS CountMale
    FROM TempeGovCrashData
) AS GenderCounts;
-- Result: According to the data, 42.7% of drivers in incidents were female and 57.3% were male.
-- To me, this speaks less about the driving skill and more about the gender distribution of drivers overall; probably more men than women on the roads, if I had to really assume something out of this.

-- How many incidents involved injuries?
SELECT
    SUM(CASE WHEN Totalinjuries = 0 AND Totalfatalities = 0 THEN 1 ELSE 0 END) AS CountNoInjuriesNoFatalities, -- Sometimes there are 0 injuries but 1 or more fatalities. I don't want to include these. I want 0 in both.
    SUM(CASE WHEN Totalinjuries > 0 THEN 1 ELSE 0 END) AS CountInjuries,
    SUM(CASE WHEN Totalfatalities > 0 THEN 1 ELSE 0 END) AS CountFatalities,
    SUM(CAST(Totalfatalities AS INT)) AS TotalSumFatalities,
    (CAST(SUM(CASE WHEN Totalinjuries = 0 AND Totalfatalities = 0 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)) * 100 AS PercentageNoInjuriesNoFatalities,
    (CAST(SUM(CASE WHEN Totalinjuries > 0 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)) * 100 AS PercentageInjuries,
    (CAST(SUM(CASE WHEN Totalfatalities > 0 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*)) * 100 AS PercentageFatalities
FROM TempeGovCrashData;
-- Result: 67.9% of incidents have no injuries or fatalities. 31.9% have injuries. 0.3% are fatalities.
-- So, about 1 out of 3 incidents result in injuries of some kind.
-- And around 1 out of 333 incidents result in a fatality. In the year 2019, 5,366 incidents occured. That's about 16 chances of a fatality happening per year.

