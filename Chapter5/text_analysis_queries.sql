-- Active: 1729874690016@@127.0.0.1@3306@ufo
---- Text characteristics
SELECT length(sighting_report), count(*) as records
FROM ufo
GROUP BY 1
ORDER BY 1
;

---- Text parsing
SELECT left(sighting_report,8) as left_digits
,count(*)
FROM ufo
GROUP BY 1
;

SELECT right(left(sighting_report,25),14) as occurred
FROM ufo
;

SELECT SUBSTRING_INDEX(sighting_report, 'Occurred : ', -1) as split_1
FROM ufo
;

SELECT SUBSTRING_INDEX(sighting_report, ' (Entered', 1) as split_2
FROM ufo
;

SELECT SUBSTRING_INDEX(
SUBSTRING_INDEX(sighting_report,' (Entered',1)
,'Occurred : ', -1) as occurred
FROM ufo
;

SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(sighting_report, ' (Entered', 1), 'Occurred : ', -1), 'Reported', 1) as occurred
FROM ufo
;

SELECT 
    SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(sighting_report, ' (Entered', 1), 'Occurred : ', -1), 'Reported', 1) AS occurred,
    SUBSTRING_INDEX(SUBSTRING_INDEX(sighting_report, ')', 1), 'Entered as : ', -1) AS entered_as,
    SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(sighting_report, 'Post', 1), 'Reported: ', -1), ' AM', 1), ' PM', 1) AS reported,
    SUBSTRING_INDEX(SUBSTRING_INDEX(sighting_report, 'Location', 1), 'Posted: ', -1) AS posted,
    SUBSTRING_INDEX(SUBSTRING_INDEX(sighting_report, 'Shape', 1), 'Location: ', -1) AS location,
    SUBSTRING_INDEX(SUBSTRING_INDEX(sighting_report, 'Duration', 1), 'Shape: ', -1) AS shape,
    SUBSTRING_INDEX(sighting_report, 'Duration:', -1) AS duration
FROM ufo;

---- Text transformations
SELECT DISTINCT shape, UPPER(LEFT(shape, 1)) AS shape_clean
FROM
(
    SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(sighting_report, 'Duration', 1), 'Shape: ', -1) AS shape
    FROM ufo
) a;

SELECT duration, TRIM(duration) AS duration_clean
FROM
(
    SELECT SUBSTRING_INDEX(sighting_report, 'Duration:', -1) AS duration
    FROM ufo
) a;

SELECT 
    STR_TO_DATE(occurred, '%Y-%m-%d %H:%i:%s') AS occurred,
    STR_TO_DATE(reported, '%Y-%m-%d %H:%i:%s') AS reported,
    DATE(posted) AS posted
FROM
(
    SELECT 
        SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(sighting_report, ' (Entered', 1), 'Occurred : ', -1), 'Reported', 1) AS occurred,
        SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(sighting_report, 'Post', 1), 'Reported: ', -1), ' AM', 1), ' PM', 1) AS reported,
        SUBSTRING_INDEX(SUBSTRING_INDEX(sighting_report, 'Location', 1), 'Posted: ', -1) AS posted
    FROM ufo
    LIMIT 10
) a;

SELECT 
    CASE 
        WHEN occurred = '' THEN NULL 
        WHEN CHAR_LENGTH(occurred) < 8 THEN NULL 
        ELSE STR_TO_DATE(occurred, '%Y-%m-%d %H:%i:%s') 
    END AS occurred,
    CASE 
        WHEN CHAR_LENGTH(reported) < 8 THEN NULL 
        ELSE STR_TO_DATE(reported, '%Y-%m-%d %H:%i:%s') 
    END AS reported,
    CASE 
        WHEN posted = '' THEN NULL 
        ELSE DATE(posted)  
    END AS posted
FROM
(
    SELECT 
        SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(sighting_report, '(Entered', 1), 'Occurred : ', -1), 'Reported', 1) AS occurred,
        SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(sighting_report, 'Post', 1), 'Reported: ', -1), ' AM', 1), ' PM', 1) AS reported,
        SUBSTRING_INDEX(SUBSTRING_INDEX(sighting_report, 'Location', 1), 'Posted: ', -1) AS posted
    FROM ufo
) a;

SELECT location,
    REPLACE(REPLACE(location, 'close to', 'near'), 'outside of', 'near') AS location_clean
FROM
(
    SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(sighting_report, 'Shape', 1), 'Location: ', -1) AS location
    FROM ufo
) a;

SELECT 
    CASE 
        WHEN occurred = '' THEN NULL 
        WHEN CHAR_LENGTH(occurred) < 8 THEN NULL 
        ELSE STR_TO_DATE(occurred, '%Y-%m-%d %H:%i:%s') 
    END AS occurred,
    entered_as,
    CASE 
        WHEN CHAR_LENGTH(reported) < 8 THEN NULL 
        ELSE STR_TO_DATE(reported, '%Y-%m-%d %H:%i:%s') 
    END AS reported,
    CASE 
        WHEN posted = '' THEN NULL 
        ELSE DATE(posted)  
    END AS posted,
    REPLACE(REPLACE(location, 'close to', 'near'), 'outside of', 'near') AS location,
    UPPER(LEFT(shape, 1)) AS shape,
    TRIM(duration) AS duration
FROM
(
    SELECT 
        SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(sighting_report, ' (Entered', 1), 'Occurred : ', -1), 'Reported', 1) AS occurred,
        SUBSTRING_INDEX(SUBSTRING_INDEX(sighting_report, ')', 1), 'Entered as : ', -1) AS entered_as,
        SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(sighting_report, 'Post', 1), 'Reported: ', -1), ' AM', 1), ' PM', 1) AS reported,
        SUBSTRING_INDEX(SUBSTRING_INDEX(sighting_report, 'Location', 1), 'Posted: ', -1) AS posted,
        SUBSTRING_INDEX(SUBSTRING_INDEX(sighting_report, 'Shape', 1), 'Location: ', -1) AS location,
        SUBSTRING_INDEX(SUBSTRING_INDEX(sighting_report, 'Duration', 1), 'Shape: ', -1) AS shape,
        SUBSTRING_INDEX(sighting_report, 'Duration:', -1) AS duration
    FROM ufo
) a;

---- Finding elements within larger blocks of text
-- Wildcard matches
SELECT COUNT(*)
FROM ufo
WHERE description LIKE '%wife%';

SELECT COUNT(*)
FROM ufo
WHERE LOWER(description) LIKE '%wife%';

SELECT COUNT(*)
FROM ufo
WHERE description LIKE '%wife%';

SELECT COUNT(*)
FROM ufo
WHERE LOWER(description) NOT LIKE '%wife%';

SELECT COUNT(*)
FROM ufo
WHERE LOWER(description) LIKE '%wife%' OR LOWER(description) LIKE '%husband%';

SELECT COUNT(*)
FROM ufo
WHERE LOWER(description) LIKE '%wife%' OR (LOWER(description) LIKE '%husband%' AND LOWER(description) LIKE '%mother%');

SELECT COUNT(*)
FROM ufo
WHERE (LOWER(description) LIKE '%wife%' OR LOWER(description) LIKE '%husband%') AND LOWER(description) LIKE '%mother%';

SELECT 
case when lower(description) like '%driving%' then 'driving'
     when lower(description) like '%walking%' then 'walking'
     when lower(description) like '%running%' then 'running'
     when lower(description) like '%cycling%' then 'cycling'
     when lower(description) like '%swimming%' then 'swimming'
     else 'none' end as activity
,count(*)
FROM ufo
GROUP BY 1
ORDER BY 2 desc
;

SELECT 
    description LIKE '%south%' AS south,
    description LIKE '%north%' AS north,
    description LIKE '%east%' AS east,
    description LIKE '%west%' AS west,
    COUNT(*)
FROM ufo
GROUP BY 1, 2, 3, 4
ORDER BY 1, 2, 3, 4;

SELECT 
    COUNT(CASE WHEN description LIKE '%south%' THEN 1 END) AS south,
    COUNT(CASE WHEN description LIKE '%north%' THEN 1 END) AS north,
    COUNT(CASE WHEN description LIKE '%west%' THEN 1 END) AS west,
    COUNT(CASE WHEN description LIKE '%east%' THEN 1 END) AS east
FROM ufo;

-- Exact matches
SELECT first_word, description
FROM
(
    SELECT SUBSTRING_INDEX(description, ' ', 1) AS first_word,
    description
    FROM ufo
) a
WHERE first_word IN ('Red', 'Orange', 'Yellow', 'Green', 'Blue', 'Purple', 'White');

SELECT 
    CASE 
        WHEN LOWER(first_word) IN ('red', 'orange', 'yellow', 'green', 'blue', 'purple', 'white') THEN 'Color'
        WHEN LOWER(first_word) IN ('round', 'circular', 'oval', 'cigar') THEN 'Shape'
        WHEN first_word LIKE 'triang%' THEN 'Shape'
        WHEN first_word LIKE 'flash%' THEN 'Motion'
        WHEN first_word LIKE 'hover%' THEN 'Motion'
        WHEN first_word LIKE 'pulsat%' THEN 'Motion'
        ELSE 'Other' 
    END AS first_word_type,
    COUNT(*)
FROM
(
    SELECT SUBSTRING_INDEX(description, ' ', 1) AS first_word,
    description
    FROM ufo
) a
GROUP BY 1
ORDER BY 2 DESC;

-- Regular expressions
-- Finding and replacing with Regex
SELECT LEFT(description, 50)
FROM ufo
WHERE LEFT(description, 50) REGEXP '[0-9]+ light[s ,.]';

SELECT SUBSTRING_INDEX(SUBSTRING_INDEX(description, ' ', 1), '[0-9]+ light[s ,.]') AS matched_text,
    COUNT(*)
FROM ufo
WHERE description REGEXP '[0-9]+ light[s ,.]'
GROUP BY 1
ORDER BY 2 DESC;

SELECT MIN(CAST(first_word AS SIGNED)) AS min_first_word
FROM
(
    SELECT SUBSTRING_INDEX(description, ' ', 1) AS first_word
    FROM ufo
    WHERE description REGEXP '^[0-9]'
) a;

SELECT 
    CASE 
        WHEN description REGEXP 'light' THEN 'light'
        WHEN description REGEXP 'object' THEN 'object'
        ELSE 'other' 
    END AS first_word_type,
    COUNT(*)
FROM ufo
GROUP BY 1;

-- Extracting duration and counting reports
SELECT 
    SUBSTRING_INDEX(sighting_report, 'Duration:', -1) AS duration,
    COUNT(*) AS reports
FROM ufo
GROUP BY duration;

-- Extracting matched minutes from duration
SELECT 
    duration,
    REGEXP_SUBSTR(duration, '\\b[Mm][Ii][Nn][Aa][Zz]*\\b') AS matched_minutes
FROM (
    SELECT 
        SUBSTRING_INDEX(sighting_report, 'Duration:', -1) AS duration,
        COUNT(*) AS reports
    FROM ufo
    GROUP BY duration
) AS a;

-- Extracting matched minutes and replacing text
SELECT 
    duration,
    REGEXP_SUBSTR(duration, '\\b[Mm][Ii][Nn][Aa][Zz]*\\b') AS matched_minutes,
    REGEXP_REPLACE(duration, '\\b[Mm][Ii][Nn][Aa][Zz]*\\b', 'min') AS replaced_text
FROM (
    SELECT 
        SUBSTRING_INDEX(sighting_report, 'Duration:', -1) AS duration,
        COUNT(*) AS reports
    FROM ufo
    GROUP BY duration
) AS a;

-- Extracting matched hours and minutes and replacing text
SELECT 
    duration,
    REGEXP_SUBSTR(duration, '\\b[Hh][Oo][Uu][Rr][Aa][Zz]*\\b') AS matched_hours,
    REGEXP_SUBSTR(duration, '\\b[Mm][Ii][Nn][Aa][Zz]*\\b') AS matched_minutes,
    REGEXP_REPLACE(
        REGEXP_REPLACE(duration, '\\b[Mm][Ii][Nn][Aa][Zz]*\\b', 'min'), 
        '\\b[Hh][Oo][Uu][Rr][Aa][Zz]*\\b', 'hr'
    ) AS replaced_text
FROM (
    SELECT 
        SUBSTRING_INDEX(sighting_report, 'Duration:', -1) AS duration,
        COUNT(*) AS reports
    FROM ufo
    GROUP BY duration
) AS a;

----- Constructing and reshaping text
SELECT 
    CONCAT(shape, ' (shape)') AS shape,
    CONCAT(reports, ' reports') AS reports
FROM (
    SELECT 
        SUBSTRING_INDEX(SUBSTRING_INDEX(sighting_report, 'Duration', 1), 'Shape: ', -1) AS shape,
        COUNT(*) AS reports
    FROM ufo
    GROUP BY shape
) AS a;

SELECT 
    CONCAT(shape, ' - ', location) AS shape_location,
    reports
FROM (
    SELECT 
        SUBSTRING_INDEX(SUBSTRING_INDEX(sighting_report, 'Shape', 1), 'Location: ', -1) AS location,
        SUBSTRING_INDEX(SUBSTRING_INDEX(sighting_report, 'Duration', 1), 'Shape: ', -1) AS shape,
        COUNT(*) AS reports
    FROM ufo
    GROUP BY location, shape
) AS a;

SELECT 
    CONCAT('There were ', reports, ' reports of ', LOWER(shape), 
           ' objects. The earliest sighting was ', 
           DATE_FORMAT(earliest, '%M %d, %Y'), 
           ' and the most recent was ', 
           DATE_FORMAT(latest, '%M %d, %Y'), '.')
FROM (
    SELECT 
        shape,
        MIN(STR_TO_DATE(occurred, '%Y-%m-%d')) AS earliest,
        MAX(STR_TO_DATE(occurred, '%Y-%m-%d')) AS latest,
        SUM(reports) AS reports
    FROM (
        SELECT 
            SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(sighting_report, ' (Entered', 1), 'Occurred : ', -1), 'Reported', 1) AS occurred,
            SUBSTRING_INDEX(SUBSTRING_INDEX(sighting_report, 'Duration', 1), 'Shape: ', -1) AS shape,
            COUNT(*) AS reports
        FROM ufo
        GROUP BY occurred, shape
    ) AS a
    WHERE LENGTH(occurred) >= 8
    GROUP BY shape
) AS aa;

-- Reshaping
SELECT 
    location,
    GROUP_CONCAT(DISTINCT shape ORDER BY shape ASC) AS shapes
FROM (
    SELECT 
        CASE 
            WHEN SUBSTRING_INDEX(SUBSTRING_INDEX(sighting_report, 'Duration', 1), 'Shape: ', -1) = '' THEN 'Unknown'
            WHEN SUBSTRING_INDEX(SUBSTRING_INDEX(sighting_report, 'Duration', 1), 'Shape: ', -1) = 'TRIANGULAR' THEN 'Triangle'
            ELSE SUBSTRING_INDEX(SUBSTRING_INDEX(sighting_report, 'Duration', 1), 'Shape: ', -1) 
        END AS shape,
        SUBSTRING_INDEX(SUBSTRING_INDEX(sighting_report, 'Shape', 1), 'Location: ', -1) AS location,
        COUNT(*) AS reports
    FROM ufo
    GROUP BY location, shape
) AS a
GROUP BY location;

SELECT 
    word, 
    COUNT(*) AS frequency
FROM (
    SELECT 
        REGEXP_SUBSTR(LOWER(description), '\\S+') AS word
    FROM ufo
) AS a
GROUP BY word
ORDER BY frequency DESC;

SELECT 
    word, 
    COUNT(*) AS frequency
FROM (
    SELECT 
        REGEXP_SUBSTR(LOWER(description), '\\S+') AS word
    FROM ufo
) AS a
LEFT JOIN stop_words b ON a.word = b.stop_word
WHERE b.stop_word IS NULL
GROUP BY word
ORDER BY frequency DESC;
