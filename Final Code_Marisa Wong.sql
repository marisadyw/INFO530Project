/* INFO 521, Spring 2023 - Final Project
Name: Marisa Wong
Date: April 3, 2023 */

/*------------------------------------------------------------------------------*/
/* Creating a database with a new database schema */
CREATE SCHEMA nors_outbreaks;

CREATE TABLE `nors_outbreaks`.`timeframe`(
	`outbreak_id` INT NOT NULL AUTO_INCREMENT,
    `outbreak_year` YEAR NOT NULL,
    `outbreak_month` INT NOT NULL,
    `state` VARCHAR(50) NOT NULL,
    PRIMARY KEY (`outbreak_id`));

CREATE TABLE `nors_outbreaks`.`etiology` (
  `etiology_id` INT NOT NULL AUTO_INCREMENT,
  `transmission_mode` VARCHAR(1000) NULL,
  `serotype` VARCHAR(1000) NULL,
  `pathogen` VARCHAR(1000) NULL,
  `etiology_status` VARCHAR(1000) NULL,
  `outbreak_id` INT NOT NULL,
  PRIMARY KEY (`etiology_id`));
  
CREATE TABLE `nors_outbreaks`.`outcomes` (
	`outcomes_id` INT NOT NULL AUTO_INCREMENT,
    `num_illnesses` INT NULL,
    `num_hospitalizations` INT NULL,
    `num_deaths` INT NULL,
    `outbreak_id` INT NOT NULL,
    PRIMARY KEY (`outcomes_id`));
    
CREATE TABLE `nors_outbreaks`.`situation` (
	`situation_id` INT NOT NULL AUTO_INCREMENT,
    `setting` VARCHAR(1000) NULL,
    `food_vehicle` VARCHAR(1000) NULL,
    `contaminated_ingredient` VARCHAR(1000) NULL,
    `outbreak_id` INT NOT NULL,
    PRIMARY KEY (`situation_id`));

/* Number of rows in each table */
-- timeframe table
SELECT * FROM timeframe;

-- etiology table
SELECT * FROM etiology;

-- outcomes table
SELECT * FROM outcomes;

-- situation table
SELECT * FROM situation;

/*------------------------------------------------------------------------------*/
/* Analytical Questions */

/* 1. How many total illnesses were reported to the National Outbreak Response System 
(NORS) in 2017 compared to 2018, grouped by state and outbreak year? Include outbreak 
year and total number of illnesses. Report the answer as a view.*/

/* Query for answer */
CREATE VIEW total_illnesses_year_vw AS
SELECT SUM(num_illnesses) AS total_illnesses, outbreak_year
FROM timeframe
LEFT JOIN outcomes
ON timeframe.outbreak_id = outcomes.outbreak_id
GROUP BY outbreak_year;

/* 2. Which pathogens cause the most and least number of illnesses in 2017? Create a list of 
pathogens and total illnesses in descending order of total illnesses. Conduct the same 
analysis for 2018. */
/* Query for answer */

-- 2017;
SELECT SUM(num_illnesses) as total_illnesses, pathogen
FROM timeframe
INNER JOIN etiology
ON timeframe.outbreak_id = etiology.outbreak_id
INNER JOIN outcomes
ON timeframe.outbreak_id = outcomes.outbreak_id
WHERE outbreak_year = 2017
GROUP BY pathogen
ORDER BY total_illnesses DESC;

-- 2018;
SELECT SUM(num_illnesses) as total_illnesses, pathogen
FROM timeframe
INNER JOIN etiology
ON timeframe.outbreak_id = etiology.outbreak_id
INNER JOIN outcomes
ON timeframe.outbreak_id = outcomes.outbreak_id
WHERE outbreak_year = 2018
GROUP BY pathogen
ORDER BY total_illnesses DESC;

/* 3. What transmission mode led to the most outbreaks in 2017? What about in 2018? */
/* Query for answer */

-- 2017
SELECT COUNT(transmission_mode) as num_outbreaks, transmission_mode, outbreak_year
FROM etiology
LEFT JOIN timeframe
ON etiology.outbreak_id = timeframe.outbreak_id
WHERE outbreak_year = 2017
GROUP BY transmission_mode
ORDER BY num_outbreaks DESC;

-- 2018
SELECT COUNT(transmission_mode) as num_outbreaks, transmission_mode, outbreak_year
FROM etiology
LEFT JOIN timeframe
ON etiology.outbreak_id = timeframe.outbreak_id
WHERE outbreak_year = 2018
GROUP BY transmission_mode
ORDER BY num_outbreaks DESC;

/* 4. Create a flag for all norovirus related outbreaks from 2017-2018. How many 
norovirus outbreaks occurred in California that led to more than 10 illnesses? */
CREATE TABLE etiology_flag
SELECT etiology_id, transmission_mode, serotype, pathogen, etiology_status, outbreak_id,
	CASE
		WHEN pathogen LIKE "%Noro%" THEN "Yes"
        ELSE "No"
	END AS norovirus_flag
FROM etiology;

SELECT e.outbreak_id, t.outbreak_year, t.state, o.num_illnesses, e.pathogen
FROM etiology_flag AS e, outcomes AS o, timeframe AS t, situation AS s
WHERE t.outbreak_id = o.outbreak_id AND
	t.outbreak_id = e.outbreak_id AND
    t.outbreak_id = s.outbreak_id AND
	t.state LIKE "%Calif%" AND
    o.num_illnesses > 10 AND
    e.norovirus_flag = "Yes";
    
/* 5. How many unique food vehicles were associated with more hospitalizations than
 outbreak_id 982 in 2017? What about in 2018? Create as a view*/

-- 2017;
CREATE VIEW 2017_food_vehicles_vw AS
(SELECT COUNT(DISTINCT(food_vehicle)) AS num_distinct_foods
FROM situation, outcomes, timeframe
WHERE situation.outbreak_id = outcomes.outbreak_id AND 
	situation.outbreak_id = timeframe.outbreak_id AND
	num_hospitalizations > (SELECT num_hospitalizations 
							FROM outcomes 
                            WHERE outbreak_id = 982) AND
    outbreak_year = 2017);
    
-- 2018;
CREATE VIEW 2018_food_vehicles_vw AS
SELECT COUNT(DISTINCT(food_vehicle)) AS num_distinct_foods
FROM situation, outcomes, timeframe
WHERE situation.outbreak_id = outcomes.outbreak_id AND 
	situation.outbreak_id = timeframe.outbreak_id AND
	num_hospitalizations > (SELECT num_hospitalizations 
							FROM outcomes 
                            WHERE outbreak_id = 982) AND
    outbreak_year = 2018;