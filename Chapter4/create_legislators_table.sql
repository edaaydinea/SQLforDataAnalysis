DROP table if exists legislators;

CREATE TABLE legislators
(
    full_name VARCHAR(255), -- name_official_full
    first_name VARCHAR(255), -- name_first
    last_name VARCHAR(255), -- name_last
    middle_name VARCHAR(255), -- name_middle
    nickname VARCHAR(255), -- name_nickname
    suffix VARCHAR(255), -- name_suffix
    other_names_end DATE, -- other_names_0_end date
    other_names_middle VARCHAR(255), -- other_names_0_middle
    other_names_last VARCHAR(255), -- other_names_0_last
    birthday DATE, -- bio_birthday
    gender VARCHAR(255), -- bio_gender
    id_bioguide VARCHAR(255) PRIMARY KEY,
    id_bioguide_previous_0 VARCHAR(255),
    id_govtrack INT,
    id_icpsr INT,
    id_wikipedia VARCHAR(255),
    id_wikidata VARCHAR(255),
    id_google_entity_id VARCHAR(255),
    id_house_history BIGINT,
    id_house_history_alternate INT,
    id_thomas INT,
    id_cspan INT,
    id_votesmart INT,
    id_lis VARCHAR(255),
    id_ballotpedia VARCHAR(255),
    id_opensecrets VARCHAR(255),
    id_fec_0 VARCHAR(255),
    id_fec_1 VARCHAR(255),
    id_fec_2 VARCHAR(255)
)
;

SET GLOBAL local_infile = 'ON';

LOAD DATA LOCAL INFILE '/local/path/to/legislators.csv'
INTO TABLE legislators
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;