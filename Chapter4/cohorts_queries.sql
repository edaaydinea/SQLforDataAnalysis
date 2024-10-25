-- Basic retention
SELECT id_bioguide
,min(term_start) as first_term
FROM legislators_terms 
GROUP BY 1
;
SELECT id_bioguide, term_start, term_end
FROM legislators_terms
WHERE term_start >= '2000-01-01' AND term_end <= '2020-12-31'
;

SELECT TIMESTAMPDIFF(YEAR, a.first_term, b.term_start) as periods
,count(distinct a.id_bioguide) as cohort_retained
FROM
(
        SELECT id_bioguide
        ,min(term_start) as first_term
        FROM legislators_terms 
        GROUP BY id_bioguide
) a
JOIN legislators_terms b on a.id_bioguide = b.id_bioguide 
GROUP BY periods
;

SELECT period,
       FIRST_VALUE(cohort_retained) OVER (ORDER BY period) AS cohort_size,
       cohort_retained,
       cohort_retained * 1.0 / FIRST_VALUE(cohort_retained) OVER (ORDER BY period) AS pct_retained
FROM (
    SELECT YEAR(TIMESTAMPDIFF(YEAR, a.first_term, b.term_start)) AS period,
           COUNT(DISTINCT a.id_bioguide) AS cohort_retained
    FROM (
        SELECT id_bioguide,
               MIN(term_start) AS first_term
        FROM legislators_terms
        GROUP BY id_bioguide
    ) a
    JOIN legislators_terms b ON a.id_bioguide = b.id_bioguide 
    GROUP BY period
) AS aa;


SELECT cohort_size,
       MAX(CASE WHEN period = 0 THEN pct_retained END) AS yr0,
       MAX(CASE WHEN period = 1 THEN pct_retained END) AS yr1,
       MAX(CASE WHEN period = 2 THEN pct_retained END) AS yr2,
       MAX(CASE WHEN period = 3 THEN pct_retained END) AS yr3,
       MAX(CASE WHEN period = 4 THEN pct_retained END) AS yr4
FROM (
    SELECT period,
           FIRST_VALUE(cohort_retained) OVER (ORDER BY period) AS cohort_size,
           cohort_retained,
           cohort_retained * 1.0 / FIRST_VALUE(cohort_retained) OVER (ORDER BY period) AS pct_retained
    FROM (
        SELECT YEAR(TIMESTAMPDIFF(YEAR, a.first_term, b.term_start)) AS period,
               COUNT(*) AS cohort_retained
        FROM (
            SELECT id_bioguide,
                   MIN(term_start) AS first_term
            FROM legislators_terms 
            GROUP BY id_bioguide
        ) a
        JOIN legislators_terms b ON a.id_bioguide = b.id_bioguide 
        GROUP BY period
    ) AS aa
) AS aaa
GROUP BY cohort_size;


SELECT a.id_bioguide, 
       a.first_term,
       b.term_start,
       CASE 
           WHEN b.term_type = 'rep' THEN DATE_ADD(b.term_start, INTERVAL 2 YEAR)
           WHEN b.term_type = 'sen' THEN DATE_ADD(b.term_start, INTERVAL 6 YEAR)
       END AS term_end
FROM (
    SELECT id_bioguide, 
           MIN(term_start) AS first_term
    FROM legislators_terms 
    GROUP BY id_bioguide
) a
JOIN legislators_terms b ON a.id_bioguide = b.id_bioguide;


SELECT a.id_bioguide, 
       a.first_term,
       b.term_start,
       DATE_SUB(LEAD(b.term_start) OVER (PARTITION BY a.id_bioguide ORDER BY b.term_start), INTERVAL 1 DAY) AS term_end
FROM (
    SELECT id_bioguide, 
           MIN(term_start) AS first_term
    FROM legislators_terms 
    GROUP BY id_bioguide
) a
JOIN legislators_terms b ON a.id_bioguide = b.id_bioguide 
ORDER BY a.id_bioguide, b.term_start;


SELECT first_year,
        period,
        FIRST_VALUE(cohort_retained) OVER (PARTITION BY first_year ORDER BY period) AS cohort_size,
        cohort_retained,
        ROUND(cohort_retained * 1.0 / FIRST_VALUE(cohort_retained) OVER (PARTITION BY first_year ORDER BY period), 2) AS pct_retained
FROM (
    SELECT YEAR(first_term) AS first_year,
            TIMESTAMPDIFF(YEAR, a.first_term, b.term_start) AS period,
            COUNT(DISTINCT a.id_bioguide) AS cohort_retained
    FROM (
         SELECT id_bioguide,
                 MIN(term_start) AS first_term
         FROM legislators_terms 
         GROUP BY id_bioguide
    ) a
    JOIN legislators_terms b ON a.id_bioguide = b.id_bioguide 
    GROUP BY first_year, period
) aa;

SELECT distinct id_bioguide
,min(term_start) over (partition by id_bioguide) as first_term
,first_value(state) over (partition by id_bioguide order by term_start) as first_state
FROM legislators_terms 
;

SELECT aa.gender, aa.first_state, cc.period, aa.cohort_size
FROM
(
        SELECT b.gender, a.first_state
        ,count(distinct a.id_bioguide) as cohort_size
        FROM 
        (
                SELECT distinct id_bioguide
                ,min(term_start) over (partition by id_bioguide) as first_term
                ,first_value(state) over (partition by id_bioguide 
                                          order by term_start) as first_state
                FROM legislators_terms 
        ) a
        JOIN legislators b on a.id_bioguide = b.id_bioguide
        WHERE a.first_term between '1917-01-01' and '1999-12-31' 
        GROUP BY b.gender, a.first_state
) aa
JOIN
(
        SELECT 0 as period UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15 UNION ALL SELECT 16 UNION ALL SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20
) cc on 1 = 1
;

----------- Defining cohorts from dates other than the first date ----------------------------------

SELECT distinct id_bioguide, term_type, date('2000-01-01') as first_term
,min(term_start) as min_start
FROM legislators_terms 
WHERE term_start <= '2000-12-31' and term_end >= '2000-01-01'
GROUP BY 1,2,3
;


----------- Survivorship ----------------------------------
SELECT id_bioguide
,min(term_start) as first_term
,max(term_start) as last_term
FROM legislators_terms
GROUP BY 1
;


SELECT id_bioguide,
        EXTRACT(CENTURY FROM MIN(term_start)) AS first_century,
        MIN(term_start) AS first_term,
        MAX(term_start) AS last_term,
        TIMESTAMPDIFF(YEAR, MIN(term_start), MAX(term_start)) AS tenure
FROM legislators_terms
GROUP BY id_bioguide;


SELECT first_century
,count(distinct id_bioguide) as cohort_size
,count(distinct case when tenure >= 10 then id_bioguide end) as survived_10
,count(distinct case when tenure >= 10 then id_bioguide end) * 1.0 
 / count(distinct id_bioguide) as pct_survived_10
FROM
(
        SELECT id_bioguide
        ,date_part('century',min(term_start)) as first_century
        ,min(term_start) as first_term
        ,max(term_start) as last_term
        ,date_part('year',age(max(term_start),min(term_start))) as tenure
        FROM legislators_terms
        GROUP BY 1
) a
GROUP BY 1
;

SELECT id_bioguide
,date_part('century',min(term_start)) as first_century
,min(term_start) as first_term
,max(term_start) as last_term
,date_part('year',age(max(term_start),min(term_start))) as tenure
FROM legislators_terms
GROUP BY 1
;


SELECT first_century
,count(distinct id_bioguide) as cohort_size
,count(distinct case when total_terms >= 5 then id_bioguide end) as survived_5
,count(distinct case when total_terms >= 5 then id_bioguide end) * 1.0
 / count(distinct id_bioguide) as pct_survived_5_terms
FROM
(
        SELECT id_bioguide
        ,date_part('century',min(term_start)) as first_century
        ,count(term_start) as total_terms
        FROM legislators_terms
        GROUP BY 1
) a
GROUP BY 1
;


SELECT a.first_century
,b.terms
,count(distinct id_bioguide) as cohort
,count(distinct case when a.total_terms >= b.terms then id_bioguide end) as cohort_survived
,count(distinct case when a.total_terms >= b.terms then id_bioguide end) * 1.0 
 / count(distinct id_bioguide) as pct_survived
FROM
(
        SELECT id_bioguide
        ,date_part('century',min(term_start)) as first_century
        ,count(term_start) as total_terms
        FROM legislators_terms
        GROUP BY 1
) a
JOIN
(
        SELECT generate_series as terms 
        FROM generate_series(1,20,1)
) b on 1 = 1
GROUP BY 1,2
;

----------- Returnship / repeat purchase behavior ----------------------------------
SELECT date_part('century',a.first_term)::int as cohort_century
,count(id_bioguide) as reps
FROM
(
        SELECT id_bioguide, min(term_start) as first_term
        FROM legislators_terms
        WHERE term_type = 'rep'
        GROUP BY 1
) a
GROUP BY 1
;

SELECT date_part('century',a.first_term) as cohort_century
,count(id_bioguide) as reps
FROM
(
        SELECT id_bioguide, min(term_start) as first_term
        FROM legislators_terms
        WHERE term_type = 'rep'
        GROUP BY 1
) a
GROUP BY 1
ORDER BY 1
;

SELECT aa.cohort_century
,bb.rep_and_sen * 1.0 / aa.reps as pct_rep_and_sen
FROM
(
        SELECT date_part('century',a.first_term) as cohort_century
        ,count(id_bioguide) as reps
        FROM
        (
                SELECT id_bioguide, min(term_start) as first_term
                FROM legislators_terms
                WHERE term_type = 'rep'
                GROUP BY 1
        ) a
        GROUP BY 1
) aa
LEFT JOIN
(
        SELECT date_part('century',b.first_term) as cohort_century
        ,count(distinct b.id_bioguide) as rep_and_sen
        FROM
        (
                SELECT id_bioguide, min(term_start) as first_term
                FROM legislators_terms
                WHERE term_type = 'rep'
                GROUP BY 1
        ) b
        JOIN legislators_terms c on b.id_bioguide = c.id_bioguide
        and c.term_type = 'sen' and c.term_start > b.first_term
        GROUP BY 1
) bb on aa.cohort_century = bb.cohort_century
;

SELECT aa.cohort_century
,bb.rep_and_sen * 1.0 / aa.reps as pct_rep_and_sen
FROM
(
        SELECT date_part('century',a.first_term) as cohort_century
        ,count(id_bioguide) as reps
        FROM
        (
                SELECT id_bioguide, min(term_start) as first_term
                FROM legislators_terms
                WHERE term_type = 'rep'
                GROUP BY 1
        ) a
        WHERE first_term <= '2009-12-31'
        GROUP BY 1
) aa
LEFT JOIN
(
        SELECT date_part('century',b.first_term) as cohort_century
        ,count(distinct b.id_bioguide) as rep_and_sen
        FROM
        (
                SELECT id_bioguide, min(term_start) as first_term
                FROM legislators_terms
                WHERE term_type = 'rep'
                GROUP BY 1
        ) b
        JOIN legislators_terms c on b.id_bioguide = c.id_bioguide
        and c.term_type = 'sen' and c.term_start > b.first_term
        WHERE age(c.term_start, b.first_term) <= interval '10 years'
        GROUP BY 1
) bb on aa.cohort_century = bb.cohort_century
;


SELECT aa.cohort_century::int as cohort_century
,round(bb.rep_and_sen_5_yrs * 1.0 / aa.reps,4) as pct_5_yrs
,round(bb.rep_and_sen_10_yrs * 1.0 / aa.reps,4) as pct_10_yrs
,round(bb.rep_and_sen_15_yrs * 1.0 / aa.reps,4) as pct_15_yrs
FROM
(
        SELECT date_part('century',a.first_term) as cohort_century
        ,count(id_bioguide) as reps
        FROM
        (
                SELECT id_bioguide, min(term_start) as first_term
                FROM legislators_terms
                WHERE term_type = 'rep'
                GROUP BY 1
        ) a
        WHERE first_term <= '2009-12-31'
        GROUP BY 1
) aa
LEFT JOIN
(
        SELECT date_part('century',b.first_term) as cohort_century
        ,count(distinct case when age(c.term_start, b.first_term) <= interval '5 years' then b.id_bioguide end) as rep_and_sen_5_yrs
        ,count(distinct case when age(c.term_start, b.first_term) <= interval '10 years' then b.id_bioguide end) as rep_and_sen_10_yrs
        ,count(distinct case when age(c.term_start, b.first_term) <= interval '15 years' then b.id_bioguide end) as rep_and_sen_15_yrs
        FROM
        (
                SELECT id_bioguide, min(term_start) as first_term
                FROM legislators_terms
                WHERE term_type = 'rep'
                GROUP BY 1
        ) b
        JOIN legislators_terms c on b.id_bioguide = c.id_bioguide
        and c.term_type = 'sen' and c.term_start > b.first_term
        GROUP BY 1
) bb on aa.cohort_century = bb.cohort_century
;

----------- Cumulative calculations ----------------------------------
SELECT date_part('century',a.first_term)::int as century
,first_type
,count(distinct a.id_bioguide) as cohort
,count(b.term_start) as terms
FROM
(
        SELECT distinct id_bioguide
        ,first_value(term_type) over (partition by id_bioguide order by term_start) as first_type
        ,min(term_start) over (partition by id_bioguide) as first_term
        ,min(term_start) over (partition by id_bioguide) + interval '10 years' as first_plus_10
        FROM legislators_terms
) a
LEFT JOIN legislators_terms b on a.id_bioguide = b.id_bioguide and b.term_start between a.first_term and a.first_plus_10
GROUP BY 1,2
;

SELECT century
,max(case when first_type = 'rep' then cohort end) as rep_cohort
,max(case when first_type = 'rep' then terms_per_leg end) as avg_rep_terms
,max(case when first_type = 'sen' then cohort end) as sen_cohort
,max(case when first_type = 'sen' then terms_per_leg end) as avg_sen_terms
FROM
(
        SELECT date_part('century',a.first_term)::int as century
        ,first_type
        ,count(distinct a.id_bioguide) as cohort
        ,count(b.term_start) as terms
        ,count(b.term_start) * 1.0 / count(distinct a.id_bioguide) as terms_per_leg
        FROM
        (
                SELECT distinct id_bioguide
                ,first_value(term_type) over (partition by id_bioguide order by term_start) as first_type
                ,min(term_start) over (partition by id_bioguide) as first_term
                ,min(term_start) over (partition by id_bioguide) + interval '10 years' as first_plus_10
                FROM legislators_terms
        ) a
        LEFT JOIN legislators_terms b on a.id_bioguide = b.id_bioguide and b.term_start between a.first_term and a.first_plus_10
        GROUP BY 1,2
) aa
GROUP BY 1
;

----------- Cross-section analysis, with a cohort lens ----------------------------------
SELECT b.date, count(distinct a.id_bioguide) as legislators
FROM legislators_terms a
JOIN date_dim b on b.date between a.term_start and a.term_end
and b.month_name = 'December' 
and b.day_of_month = 31
and b.year <= 2019
GROUP BY 1
;

SELECT b.date
,date_part('century',first_term)::int as century
,count(distinct a.id_bioguide) as legislators
FROM legislators_terms a
JOIN date_dim b on b.date between a.term_start and a.term_end and b.month_name = 'December' and b.day_of_month = 31 and b.year <= 2019
JOIN
(
        SELECT id_bioguide, min(term_start) as first_term
        FROM legislators_terms
        GROUP BY 1
) c on a.id_bioguide = c.id_bioguide        
GROUP BY 1,2
;

SELECT date
,century
,legislators
,sum(legislators) over (partition by date) as cohort
,legislators * 100.0 / sum(legislators) over (partition by date) as pct_century
FROM
(
        SELECT b.date
        ,date_part('century',first_term)::int as century
        ,count(distinct a.id_bioguide) as legislators
        FROM legislators_terms a
        JOIN date_dim b on b.date between a.term_start and a.term_end and b.month_name = 'December' and b.day_of_month = 31 and b.year <= 2019
        JOIN
        (
                SELECT id_bioguide, min(term_start) as first_term
                FROM legislators_terms
                GROUP BY 1
        ) c on a.id_bioguide = c.id_bioguide        
        GROUP BY 1,2
) a
ORDER BY 1,2
;

SELECT date
,coalesce(sum(case when century = 18 then legislators end) * 100.0 / sum(legislators),0) as pct_18
,coalesce(sum(case when century = 19 then legislators end) * 100.0 / sum(legislators),0) as pct_19
,coalesce(sum(case when century = 20 then legislators end) * 100.0 / sum(legislators),0) as pct_20
,coalesce(sum(case when century = 21 then legislators end) * 100.0 / sum(legislators),0) as pct_21
FROM
(
        SELECT b.date
        ,date_part('century',first_term)::int as century
        ,count(distinct a.id_bioguide) as legislators
        FROM legislators_terms a
        JOIN date_dim b on b.date between a.term_start and a.term_end and b.month_name = 'December' and b.day_of_month = 31 and b.year <= 2019
        JOIN
        (
                SELECT id_bioguide, min(term_start) as first_term
                FROM legislators_terms
                GROUP BY 1
        ) c on a.id_bioguide = c.id_bioguide        
        GROUP BY 1,2
) aa
GROUP BY 1
ORDER BY 1
;

SELECT id_bioguide, date
,count(date) over (partition by id_bioguide order by date rows between unbounded preceding and current row) as cume_years
FROM
(
        SELECT distinct a.id_bioguide, b.date
        FROM legislators_terms a
        JOIN date_dim b on b.date between a.term_start and a.term_end and b.month_name = 'December' and b.day_of_month = 31 and b.year <= 2019
) a
;

SELECT date, cume_years
,count(distinct id_bioguide) as legislators
FROM
(
    SELECT id_bioguide, date
    ,count(date) over (partition by id_bioguide order by date rows between unbounded preceding and current row) as cume_years
    FROM
    (
        SELECT distinct a.id_bioguide, b.date
        FROM legislators_terms a
        JOIN date_dim b on b.date between a.term_start and a.term_end
        and b.month_name = 'December' and b.day_of_month = 31
        and b.year <= 2019
        GROUP BY 1,2
    ) aa
) aaa
GROUP BY 1,2
;

SELECT date, count(*) as tenures
FROM 
(
        SELECT date, cume_years
        ,count(distinct id_bioguide) as legislators
        FROM
        (
                SELECT id_bioguide, date
                ,count(date) over (partition by id_bioguide order by date rows between unbounded preceding and current row) as cume_years
                FROM
                (
                        SELECT distinct a.id_bioguide, b.date
                        FROM legislators_terms a
                        JOIN date_dim b on b.date between a.term_start and a.term_end and b.month_name = 'December' and b.day_of_month = 31 and b.year <= 2019
                        GROUP BY 1,2
                ) aa
        ) aaa
        GROUP BY 1,2
) aaaa
GROUP BY 1
;

SELECT date, tenure
,legislators * 100.0 /
 sum(legislators) over (partition by date) as pct_legislators 
FROM
(
        SELECT date
        ,case when cume_years <= 4 then '1 to 4'
              when cume_years <= 10 then '5 to 10'
              when cume_years <= 20 then '11 to 20'
              else '21+' end as tenure
        ,count(distinct id_bioguide) as legislators
        FROM
        (
                SELECT id_bioguide, date
                ,count(date) over (partition by id_bioguide order by date rows between unbounded preceding and current row) as cume_years
                FROM
                (
                        SELECT distinct a.id_bioguide, b.date
                        FROM legislators_terms a
                        JOIN date_dim b on b.date between a.term_start and a.term_end and b.month_name = 'December' and b.day_of_month = 31 and b.year <= 2019
                        GROUP BY 1,2
                ) a
        ) aa
        GROUP BY 1,2
) aaa
;











