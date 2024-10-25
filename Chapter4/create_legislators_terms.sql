-- Active: 1729874690016@@127.0.0.1@3306@legislators
-- Drop the table if it exists
DROP TABLE IF EXISTS legislators_terms;

-- Create the legislators_terms table
CREATE TABLE legislators_terms (
    id_bioguide VARCHAR(255),
    term_number INT,
    term_id VARCHAR(255) PRIMARY KEY,
    term_type VARCHAR(255),
    term_start DATE,
    term_end DATE,
    state VARCHAR(255),
    district INT,
    class INT,
    party VARCHAR(255),
    how VARCHAR(255),
    url VARCHAR(255),                 -- terms_1_url
    address VARCHAR(255),             -- terms_1_address
    phone VARCHAR(255),               -- terms_1_phone
    fax VARCHAR(255),                 -- terms_1_fax
    contact_form VARCHAR(255),        -- terms_1_contact_form
    office VARCHAR(255),              -- terms_1_office
    state_rank VARCHAR(255),          -- terms_1_state_rank
    rss_url VARCHAR(255),             -- terms_1_rss_url
    caucus VARCHAR(255)               -- terms_1_caucus
);

-- Load data from the CSV file into the legislators_terms table

SET GLOBAL local_infile = 'ON';

LOAD DATA LOCAL INFILE 'local/path/to/legislators_terms.csv'
INTO TABLE legislators_terms
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;


