-------------Exploratory Data Analysis EDA -------------------
----1. View tables
SELECT * FROM BRIGHTTV.TV.VIEWERSHIP;

SELECT * FROM BRIGHTTV.TV.USERPROFILES;

----2. Checking number of records in each table and view data
SELECT COUNT(*) FROM BRIGHTTV.TV.USERPROFILES; ---53375
SELECT * FROM BRIGHTTV.TV.USERPROFILES;

SELECT COUNT(*) FROM BRIGHTTV.TV.VIEWERSHIP;  ----10000
SELECT * FROM BRIGHTTV.TV.VIEWERSHIP;

---3.Counting different types of userid from the  USERPROFILE table 
SELECT COUNT(DISTINCT userid)
FROM BRIGHTTV.TV.USERPROFILES

---4.Counting all userid's from the viewership table

SELECT COUNT(userid)
FROM BRIGHTTV.TV.VIEWERSHIP;

--5. checking the youngest age
SELECT 
    MIN(age)
FROM BRIGHTTV.TV.USERPROFILES;
-----6. checking the oldest age
SELECT 
    MAX(age)
FROM BRIGHTTV.TV.USERPROFILES;
----7. check when the BrightTV started operating
SELECT 
    MIN(RECORDDATE2) First_Time_Update
FROM BRIGHTTV.TV.VIEWERSHIP;  ----2016/01/01 00:32

---8. check the latest time of operation
SELECT 
    MAX(RECORDDATE2) AS Last_Time_update
FROM BRIGHTTV.TV.VIEWERSHIP;  ----2016/03/31 23:37


-------------------------------------------------------------------------------------------------------------
--------Data Cleaning----------------------------------------------------------------------------------------

--Checking if there is any duplicates in the table userprofiles

SELECT *, 
    COUNT(*)
FROM BRIGHTTV.TV.USERPROFILES
GROUP BY ALL
HAVING COUNT(*) > 1;   ----no duplicates found

--Checking if there is any duplicates in the table viewership

SELECT *, 
    COUNT(*)
FROM brighttv.tv.viewership
GROUP BY ALL
HAVING COUNT(*) > 1;   ----5  duplicates records where found

-- Creating a temporary table without duplicates  and name it viewership_new

SELECT DISTINCT *
FROM BRIGHTTV.TV.VIEWERSHIP;

---creating a temp table
CREATE TEMPORARY TABLE BRIGHTTV.TV.viewership_new AS (
    SELECT DISTINCT *
    FROM BRIGHTTV.TV.VIEWERSHIP
);
-----Then insert data that has no duplicates into the temp table created
SELECT *, 
    COUNT(*)
FROM  BRIGHTTV.TV.viewership_new
GROUP BY ALL
HAVING COUNT(*) > 1;

SELECT COUNT(*)
FROM   BRIGHTTV.TV.viewership_new;

-- Looking for  missing values in the tables

SELECT * FROM BRIGHTTV.TV.USERPROFILES
WHERE userid IS NULL OR NAME IS NULL OR surname IS NULL OR email IS NULL OR gender IS NULL OR RACE IS NULL OR AGE IS NULL OR PROVINCE IS NULL OR SOCIAL_MEDIA_HANDLE IS NULL;

SELECT * FROM  BRIGHTTV.TV.VIEWERSHIP_NEW

WHERE userid IS NULL OR channel2 IS NULL OR recorddate2 IS NULL OR duration2 IS NULL; ---No NULL 

-- Let's replace missing records with 'None' and creating a temp table

CREATE TEMPORARY TABLE BRIGHTTV.TV.user_profiles_new AS (
    SELECT 
        userid,
        age,
        IFNULL(name, 'None') AS Name,
        IFNULL(surname, 'None') AS Surname,
        IFNULL(email, 'None') AS email,
        IFNULL(gender, 'None') AS Gender,
        IFNULL(race, 'None') AS Race,
        IFNULL(province, 'None') AS Province,
        IFNULL(social_media_handle, 'None') AS social_media_handle,
        CASE
            WHEN age BETWEEN 1 AND 12 THEN 'Younger than 13'
            WHEN age BETWEEN 13 AND 25 THEN '13 to 25'
            WHEN age BETWEEN 26 AND 44 THEN '26 to 44'
            WHEN age >= 45 THEN '45 and older'
            ELSE 'Not Specified'
        END AS Age_group
    FROM BRIGHTTV.TV.USERPROFILES
);

-----convert string date format yyyy/mm/dd to date format yyyy-mm-dd and also overight the column with the new convertion


UPDATE BRIGHTTV.TV.viewership_new
SET RECORDDATE2 = TO_CHAR(
  TO_TIMESTAMP(RECORDDATE2, 'YYYY/MM/DD HH24:MI'),
  'YYYY-MM-DD HH24:MI:SS'
);

----extract time from  timestamp column RECORDDATE2 


SELECT RECORDDATE2::TIMESTAMP::TIME AS new_time
FROM BRIGHTTV.TV.VIEWERSHIP_NEW;

----------------------------------------------------------------------------------------------------------------------------------------------------------
-----------------------Final and big query-----------------------------------------------------------------------------------------------------------------

SELECT
    a.userid,
    a.Name,
    a.Surname,
    -- Display the count of users and viewership per gender
    a.Gender, COUNT(b.userid) AS user_count,
    -- Display the users and viewership per race
    a.Race, COUNT(a.userid) AS user_count,
    -- Display the users and viewership per province
    a.Province, COUNT(a.userID) AS user_count,
    -- Display the count of users and viewership per age group
    a.Age_group, COUNT(b.userid) AS user_count,
    -- Display the users and viewership per channel
    b.channel2, COUNT(a.userID) AS user_count, 
                
    b.duration2,
    CASE
        WHEN b.duration2 between '00:00:00' AND '02:59:59' THEN '0 - 3 Hrs'
        WHEN b.duration2 between '03:00:00' AND '05:59:59' THEN '3 - 6 Hrs'
        WHEN b.duration2 between '06:00:00' AND '08:59:59' THEN '6 - 9 Hrs'
        ELSE '9 - 12 Hrs'
    END AS Watch_Time,
    -- Display the count of users and viewership per duration
    COUNT(a.userid) AS user_count,
       b.RECORDDATE2::TIMESTAMP::TIME AS time,
   CASE
       WHEN  b.RECORDDATE2::TIMESTAMP::TIME between '06:00:00' AND '11:59:59' THEN 'Morning'
        WHEN b.RECORDDATE2::TIMESTAMP::TIME between '12:00:00' AND '17:59:59' THEN 'Afternoon'
       WHEN  b.RECORDDATE2::TIMESTAMP::TIME between '18:00:00' AND '23:59:59' THEN 'Evening'
        ELSE 'Night'
    END AS Time_Type,
    -- Display the count of users and viewership per time of day
    COUNT(a.userid) AS user_count,
    RECORDDATE2,
    MONTHNAME(RECORDDATE2) AS Month_Name,
    -- Display the count of users and viewership by month
    Month_Name, COUNT(b.userid) AS user_count,
    DAYNAME(RECORDDATE2) AS Day_name,
    Day_name, COUNT(b.userid) AS user_count
FROM BRIGHTTV.TV.user_profiles_new AS a 
INNER JOIN BRIGHTTV.TV.viewership_new AS b ON a.userid = b.userid
GROUP BY ALL;






 











