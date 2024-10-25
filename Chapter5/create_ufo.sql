-- Active: 1729874690016@@127.0.0.1@3306@ufo
DROP table if exists ufo;
CREATE TABLE ufo
(
    sighting_report VARCHAR(1000),
    description TEXT
);

SET GLOBAL local_infile = 'ON';

-- change localpath to the directory where you saved the ufo .csv files

LOAD DATA LOCAL INFILE 'local/path/to/ufo1.csv'
INTO TABLE ufo
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(sighting_report, description);

LOAD DATA LOCAL INFILE 'local/path/to/ufo2.csv'
INTO TABLE ufo
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(sighting_report, description);

LOAD DATA LOCAL INFILE 'local/path/to/ufo3.csv'
INTO TABLE ufo
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(sighting_report, description);

LOAD DATA LOCAL INFILE 'local/path/to/ufo4.csv'
INTO TABLE ufo
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(sighting_report, description);

LOAD DATA LOCAL INFILE 'local/path/to/ufo5.csv'
INTO TABLE ufo
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(sighting_report, description);
