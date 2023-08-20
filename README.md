# SQLTempeCrashDataProject
SQL queries for exploring traffic incident data provided by the city of Tempe: https://data.tempe.gov/ <br>

This is a project where I downloaded a CSV from https://data.tempe.gov/ for traffic crash reports and attempted data exploration using SQL. This data set has around 44,000 entries, so I could have utilized Excel, but I chose to use SQL for the sake of practicing my SQL skills.<br>

I used Microsoft SQL Server for this project. I imported the downloaded CSV and selected the Incidentid column as the Primary Key since that appears to be the unique value for individual traffic incidents.<br>

I noticed that driver 1 is usually the driver committing a violation, and driver 2 is usually coded as an innocent casualty of some sort. My assumption is this is simply how the data is entered to make it easier to keep track of. Thus, I will be more critically analyzing driver 1 when exploring potential causes or reasons.

I used this opportunity to do some simple data exploration using SQL queries. First, I looked at the columns and type of information they held, then I asked myself some questions:<br>
1.	What year had the most reports?<br>
2.	What year was the most fatal?<br>
3.	What street appears most often? (In both street and cross street columns)<br>
4.	What type of incidents are most common? (Count the violations from driver 1 since those appear to be the driver at fault)<br>
5.	What time of day do most incidents occur?<br>
6.	What type of weather do most incidents occur?<br>
7.	How many were alcohol-related?<br>
8.	What is the ratio of men to women involved in incidents?<br>
9.	What is the ratio of incidents with injuries versus no injuries?<br>

Images
![alt_text](https://github.com/jtylerdawkins/SQLTempeCrashDataProject/blob/main/SQLTempeGovCrashDataPic1.PNG?raw=true)
