--TOTAL MRR
SELECT
    SUM(mrr_amount) AS total_mrr
FROM subscriptions  

SELECT 
    EXTRACT(MONTH FROM start_date) AS month,
    EXTRACT (YEAR FROM start_date) AS year
FROM subscriptions
GROUP BY month,year
ORDER BY month ,year

--2024 NRR

WITH cohort_2024 AS(
    SELECT
        account_id,
        SUM(CASE
            WHEN start_date<='2024-01-01' AND (end_date IS NULL OR end_date>='2024-01-01')
            THEN mrr_amount
            ELSE 0
            END) AS starting_mrr,
        SUM(CASE
            WHEN start_date<='2024-01-01' AND (end_date IS NULL OR end_date>='2024-12-31')
            THEN mrr_amount
            ELSE 0
            END) AS ending_mrr
    FROM subscriptions 
    GROUP BY account_id
)

SELECT
    SUM(starting_mrr) AS total_start_mrr,
    SUM(ending_mrr) AS total_end_mrr,
    ROUND((SUM(ending_mrr)::NUMERIC/NULLIF(SUM(starting_mrr),0))*100,2) AS nrr_percent
FROM cohort_2024
WHERE starting_mrr>0

--WHERE IS THE REVENUE LOOSING:DIVISION OF NRR COMPONENTS
WITH cohorts AS(
    SELECT
        account_id,
        SUM(CASE
            WHEN start_date<='2024-01-01' AND (end_date IS NULL OR end_date>='2024-01-01')
            THEN mrr_amount
            ELSE 0
            END) AS start_mrr,
        SUM(CASE
            WHEN start_date<='2024-01-01' AND (end_date IS NULL OR end_date>='2024-12-31')
            THEN mrr_amount
            ELSE 0
            END) AS end_mrr
    FROM subscriptions
    GROUP BY account_id
    HAVING SUM(CASE WHEN start_date<='2024-01-01' AND (end_date IS NULL OR end_date>'2024-01-01')THEN mrr_amount ELSE 0 END) >0
)

SELECT
    SUM(start_mrr) AS total_start_mrr,
    SUM(CASE
        WHEN end_mrr>start_mrr THEN end_mrr-start_mrr ELSE 0 END) AS expansion_mrr,
    SUM(CASE
        WHEN end_mrr<start_mrr AND end_mrr>0 THEN start_mrr-end_mrr ELSE 0 END) AS contraction_mrr,
    SUM(CASE
        WHEN end_mrr=0 THEN start_mrr ELSE 0 END) AS churn_mrr,
    SUM(end_mrr) AS total_end_mrr
FROM cohorts

--WHICH REFERRAL SOURCE HAVE HIGHEST DOWNGRADES
SELECT
    a.referral_source,
    ROUND((COUNT(CASE WHEN s.downgrade_flag THEN 1 END)::NUMERIC/COUNT(*))*100,2) AS downgrade_pct
FROM subscriptions s
INNER JOIN accounts a ON a.account_id=s.account_id
GROUP BY a.referral_source


-- WHICH INDUSTRY HAVE HIGHEST DOWNGRADES
SELECT
    a.industry,
    ROUND((COUNT(CASE WHEN s.downgrade_flag THEN 1 END)::NUMERIC/COUNT(*))*100,2) AS downgrade_pct
FROM subscriptions s
INNER JOIN accounts a ON a.account_id=s.account_id
GROUP BY a.industry

--WHICH PLAN TIER HAS HIGH DOWNGRADES
SELECT
    plan_tier,
    COUNT(DISTINCT subscription_id) AS total_subs,
    COUNT(DISTINCT CASE WHEN downgrade_flag THEN subscription_id END) AS downgrade_count,
    ROUND(
        COUNT(DISTINCT CASE WHEN downgrade_flag THEN subscription_id END)::NUMERIC / 
        COUNT(DISTINCT subscription_id) * 100, 
        2
    ) AS downgrade_pct,
    SUM(CASE WHEN downgrade_flag THEN mrr_amount ELSE 0 END) AS downgrade_mrr_impact
FROM subscriptions
GROUP BY plan_tier
ORDER BY downgrade_pct DESC;

--WHY PRO HAS HIGH CONTRACTIONS
SELECT
    s.plan_tier,
    ROUND(AVG(fu.usage_count),2) AS avg_daily_use,
    ROUND(AVG(fu.usage_duration_secs)/60.0,2) AS avg_duration_mins,
    ROUND(AVG(fu.error_count),2) AS avg_error_count
FROM subscriptions s
INNER JOIN feature_usage fu ON fu.subscription_id=s.subscription_id
GROUP BY s.plan_tier

SELECT
    s.plan_tier,
    ROUND(AVG(satisfaction_score),2) AS avg_satisfaction_score,
    COUNT(ticket_id)AS total_support_tickets
FROM subscriptions s
JOIN support_tickets st ON st.account_id=s.account_id
GROUP BY s.plan_tier

--ARE CERTAIN FEATURES USED BY PRO PLAN TIER ARE CAUSING DOWNGRADES

--HIGHEST DOWNGRADE INDUCING FEATURE FOR PRO PLAN
SELECT
    f.feature_name,
    ROUND((COUNT(CASE WHEN s.downgrade_flag THEN 1 END)::NUMERIC/COUNT(*))*100,2) AS downgrade_pct
FROM subscriptions s
JOIN feature_usage f ON f.subscription_id=s.subscription_id
WHERE s.plan_tier='Pro'
GROUP BY feature_name
ORDER BY  ROUND((COUNT(CASE WHEN s.downgrade_flag THEN 1 END)::NUMERIC/COUNT(*))*100,2) DESC
LIMIT 5

--MOST POPULAR FEATURE IN PRO PLAN
SELECT
    f.feature_name,
    COUNT(DISTINCT s.subscription_id) AS total_pro_subs
FROM subscriptions s
JOIN feature_usage f ON f.subscription_id=s.subscription_id
WHERE s.plan_tier='Pro'
GROUP BY f.feature_name
ORDER BY COUNT(DISTINCT s.subscription_id) DESC
LIMIT 5

--FEATURE USED THE MOST OFTEN IN A DAY IN PRO PLAN
SELECT
    f.feature_name,
    ROUND(AVG(f.usage_count),2) AS avg_usage_count
FROM subscriptions s
JOIN feature_usage f ON f.subscription_id=s.subscription_id
WHERE s.plan_tier='Pro'
GROUP BY feature_name
ORDER BY ROUND(AVG(f.usage_count),2) DESC
LIMIT 5

--FEATURE WITH MOST USAGE FREQUENCY IN PRO PLAN
SELECT
    f.feature_name,
    ROUND(AVG(f.usage_duration_secs)/60.0,2) AS avg_usage_mins
FROM subscriptions s
JOIN feature_usage f ON f.subscription_id=s.subscription_id
WHERE s.plan_tier='Pro'
GROUP BY feature_name
ORDER BY ROUND(AVG(f.usage_duration_secs)/60.0,2) DESC
LIMIT 5 

--FEATURE WITH MOST ERRORS IN PRO PLAN
SELECT
    f.feature_name,
    ROUND(AVG(f.error_count),2) AS avg_error_count
FROM subscriptions s
JOIN feature_usage f ON f.subscription_id=s.subscription_id
WHERE s.plan_tier='Pro'
GROUP BY feature_name
ORDER BY ROUND(AVG(f.error_count),2) DESC
LIMIT 5

--MOST POPULAR FEATURE WITH HIGH SUBSCRIPTIONS, MRR, HIGH USAGE COUNT ,FREQUENCY AND ERROR COUNT
SELECT
    f.feature_name,
    COUNT(DISTINCT s.subscription_id) AS total_subs,
    ROUND((COUNT(CASE WHEN s.downgrade_flag THEN 1 END)::NUMERIC/COUNT(*))*100,2) AS downgrade_pct,
    SUM(s.mrr_amount) AS total_mrr,
    ROUND(AVG(f.usage_count),2) AS avg_usage_count,
    ROUND(AVG(f.usage_duration_secs)/60.0,2) AS avg_usage_mins,
    ROUND(AVG(f.error_count),2) AS avg_error_count
FROM subscriptions s
JOIN feature_usage f ON f.subscription_id=s.subscription_id
GROUP BY feature_name
ORDER BY total_subs DESC

--ARE ISSUES IN SUPPORT SERVICES AND RESOLUTION CAUSING PRO PLAN CUSTOMERS TO DOWNGRADE
SELECT
    s.downgrade_flag,
    COUNT(st.ticket_id) AS total_tickets,
    ROUND(COUNT(st.ticket_id)/COUNT(DISTINCT subscription_id),2) AS ticket_per_sub,
    ROUND(AVG(st.resolution_time_hours),2) AS avg_resolution_time_hrs,
    ROUND(AVG(st.satisfaction_score),2) AS avg_satisfaction_score,
    COUNT(CASE WHEN st.escalation_flag THEN 1 END) AS total_escalations
FROM subscriptions s
JOIN support_tickets st ON st.account_id=s.account_id
WHERE s.plan_tier='Pro'
GROUP BY s.downgrade_flag

--ARE SPECIFIC CHURN REASONS HAVING DOWNGRADES IN PRO PLAN
SELECT
    c.reason_code,
    ROUND(
        COUNT(DISTINCT s.subscription_id)::NUMERIC / 
        SUM(COUNT(DISTINCT s.subscription_id)) OVER() * 100, 
        2
    ) AS pct_total
FROM subscriptions s
JOIN churn_events c ON c.account_id = s.account_id
WHERE s.plan_tier = 'Pro' 
  AND s.downgrade_flag = TRUE
GROUP BY c.reason_code
ORDER BY downgrade_events DESC;

SELECT
    c.reason_code,
      ROUND(
        COUNT(DISTINCT subscription_id) FILTER (WHERE s.downgrade_flag=TRUE ) :: NUMERIC/
        COUNT(DISTINCT subscription_id) *100
        ,2
    )AS downgrade_rate
FROM subscriptions s
JOIN churn_events c ON c.account_id = s.account_id
WHERE s.plan_tier = 'Pro' 
GROUP BY c.reason_code
ORDER BY downgrade_rate DESC;

SELECT
    account_id,
    COUNT(*) AS churn_event_count
FROM churn_events
GROUP BY account_id
HAVING COUNT(*) > 1
ORDER BY churn_event_count DESC;

WITH latest_churn AS (
    SELECT
        account_id,
        reason_code,
        churn_date,
        ROW_NUMBER() OVER (
            PARTITION BY account_id
            ORDER BY churn_date DESC
        ) AS rn
    FROM churn_events
)

SELECT
    c.reason_code,
    COUNT(DISTINCT s.subscription_id) AS downgrade_events,
    SUM(s.mrr_amount) AS total_mrr,
    ROUND(
        COUNT(DISTINCT s.subscription_id)::NUMERIC
        / SUM(COUNT(DISTINCT s.subscription_id)) OVER() * 100,
        2
    ) AS pct_total
FROM subscriptions s
JOIN latest_churn c
    ON c.account_id = s.account_id
    AND c.rn = 1
WHERE s.plan_tier = 'Pro'
  AND s.downgrade_flag = TRUE
GROUP BY c.reason_code
ORDER BY downgrade_events DESC;

--ARE CERTAIN INDUSTRIES HAVING HIGHER DOWNGRADES IN PRO PLAN
SELECT
    a.industry,
    COUNT(DISTINCT s.subscription_id) AS total_subs,
    COUNT(DISTINCT CASE WHEN s.downgrade_flag THEN s.subscription_id END) AS total_downgrades,
    ROUND(
        COUNT(DISTINCT CASE WHEN s.downgrade_flag THEN s.subscription_id END)::NUMERIC / 
        COUNT(DISTINCT s.subscription_id) * 100, 
        2
    ) AS downgrade_pct
FROM subscriptions s
JOIN accounts a ON a.account_id = s.account_id
WHERE s.plan_tier = 'Pro'
GROUP BY a.industry
ORDER BY downgrade_pct DESC;

--FEATURE PERFORMANCE IN EDTECH INDUSTRY UNDER PRO PLAN
SELECT
    f.feature_name,
    COUNT(DISTINCT s.subscription_id) total_subs,
    COUNT(CASE WHEN s.downgrade_flag THEN 1 END) AS total_downgrades,
    ROUND(COUNT(CASE WHEN s.downgrade_flag THEN 1 END)::NUMERIC/COUNT(*)*100,2) AS downgrade_pct,
    ROUND(AVG(f.error_count),2) AS avg_error_count
FROM subscriptions s
JOIN accounts a ON a.account_id=s.account_id
JOIN feature_usage f ON f.subscription_id=s.subscription_id
WHERE s.plan_tier='Pro' AND a.industry='EdTech'
GROUP BY f.feature_name
ORDER BY downgrade_pct DESC  

--SUPPORT PERFORMANCE IN EDTECH INDUSTRY UNDER PRO PLAN
SELECT
    s.downgrade_flag,
    COUNT(st.ticket_id) AS total_tickets,
    ROUND(AVG(st.resolution_time_hours),2) AS avg_resolution_time_hrs,
    ROUND(AVG(st.satisfaction_score),2) AS avg_csat,
    COUNT(CASE WHEN st.escalation_flag THEN 1 END) AS total_escalations
FROM subscriptions s
JOIN support_tickets st ON st.account_id=s.account_id
JOIN accounts a ON a.account_id=s.account_id
WHERE s.plan_tier='Pro' AND a.industry='EdTech'
GROUP BY s.downgrade_flag

--CHECKING POPULAR AND MOST DOWNGRADING FEATURES PERFORMANCE
SELECT
    f.feature_name,
    COUNT(st.ticket_id) AS total_tickets,
    ROUND(AVG(st.resolution_time_hours),2) AS avg_resolution_time_hrs,
    ROUND(AVG(st.satisfaction_score),2) AS avg_csat,
    COUNT(CASE WHEN st.escalation_flag THEN 1 END) AS total_escalations,
    ROUND(AVG(f.error_count),2) AS avg_error_count
FROM subscriptions s
JOIN support_tickets st ON st.account_id=s.account_id
JOIN accounts a ON a.account_id=s.account_id
JOIN feature_usage f ON f.subscription_id=s.subscription_id
WHERE s.plan_tier='Pro' AND a.industry='EdTech' AND f.feature_name IN (
    'feature_5','feature_34','feature_8',
    'feature_19','feature_23','feature_40',
    'feature_24','feature_21','feature_4','feature_28')
GROUP BY f.feature_name
ORDER BY --COUNT(st.ticket_id) DESC 
--ROUND(AVG(st.resolution_time_hours),2) DESC
--ROUND(AVG(st.satisfaction_score),2) DESC
--COUNT(CASE WHEN st.escalation_flag THEN 1 END) DESC
ROUND(AVG(f.error_count),2) DESC

--ARE CERTAIN REFFERAL SOURCE FOR PRO PLAN HAVING HIGHER DOWNGRADES
SELECT
    a.referral_source,
    ROUND(COUNT(CASE WHEN s.downgrade_flag THEN 1 END)::NUMERIC/COUNT(*)*100,2) AS downgrade_pct
FROM subscriptions s
JOIN accounts a ON a.account_id=s.account_id
WHERE s.plan_tier='Pro'
GROUP BY a.referral_source
ORDER BY downgrade_pct DESC

--ARE ORGANIC SOURCES BRINGING THE UNFIT EDTECH CUSTOMERS
SELECT 
    a.referral_source,
    a.industry,
    COUNT(s.subscription_id) AS total_pro_subs,
    ROUND(COUNT(CASE WHEN s.downgrade_flag THEN 1 END)::NUMERIC / COUNT(*) * 100, 2) AS downgrade_pct
FROM subscriptions s
JOIN accounts a ON a.account_id = s.account_id
WHERE s.plan_tier = 'Pro' 
GROUP BY a.referral_source, a.industry
ORDER BY downgrade_pct DESC;

--DO DOWNGRADED AND NON DOWGRADED SUBSCRIPTIONS HAVE DIFFERENT SEATS
SELECT
    downgrade_flag,
    ROUND(avg(seats),2) AS avg_seats
FROM subscriptions
GROUP BY downgrade_flag

--COHORT ANALYSIS:DOWNGRADE PCT BY SIGNUP DATE

WITH signup_cohort AS(
    SELECT
        a.account_id,
        DATE_TRUNC('quarter',a.signup_date) as cohort_date,
        CASE
            WHEN COUNT(s.subscription_id) FILTER( WHERE s.downgrade_flag = TRUE) >0
            THEN 1
            ELSE 0
        END AS downgrades
    FROM accounts a
    LEFT JOIN subscriptions s ON s.account_id=a.account_id
    GROUP BY 
        a.account_id,
        DATE_TRUNC('quarter',a.signup_date)
)

SELECT
    cohort_date,
    COUNT(account_id) AS total_customers,
    SUM(downgrades) AS total_downgrades,
    ROUND(
        SUM(downgrades)::NUMERIC/
        NULLIF(COUNT(account_id),0)
        *100
        ,2
    ) AS downgrade_pct
FROM signup_cohort
GROUP BY cohort_date
ORDER BY cohort_date

--MONTHWISE DOWNGRADE PCT
SELECT
    DATE_TRUNC('month',start_date) AS start_month,
    ROUND(COUNT(CASE WHEN downgrade_flag THEN 1 END)::NUMERIC/COUNT(*)*100,2) AS downgrade_pct   
FROM subscriptions
GROUP BY DATE_TRUNC('month',start_date)
ORDER BY DATE_TRUNC('month',start_date)

--WHICH PLAN TIER AND BILLING FREQUENCY ARE CAUSING DOWNGRADES IN CERTAIN MONTHS
SELECT 
    DATE_TRUNC('month', s.start_date) AS month,
    s.plan_tier,
    s.billing_frequency,
    COUNT(*) AS total_subscriptions,
    COUNT(CASE WHEN s.downgrade_flag = TRUE THEN 1 END) AS total_downgrades,
    ROUND(
        100.0 * COUNT(CASE WHEN s.downgrade_flag = TRUE THEN 1 END) / COUNT(*), 
        2
    ) AS downgrade_pct
FROM subscriptions s
GROUP BY 1, 2, 3
ORDER BY month, downgrade_pct DESC;

--CHURN RATE
SELECT
    ROUND(
        COUNT(DISTINCT s.account_id) FILTER(WHERE a.churn_flag=TRUE)::NUMERIC/
        COUNT(DISTINCT s.account_id)*100,2
    ) AS churn_rate_pct
FROM subscriptions s
JOIN accounts a ON a.account_id=s.account_id

--2023 AND 2024 CHURN RATE
SELECT
    EXTRACT(YEAR FROM start_date) AS year,
    ROUND(
        COUNT(DISTINCT s.account_id) FILTER(WHERE a.churn_flag=TRUE)::NUMERIC/
        COUNT(DISTINCT s.account_id)*100,2
    ) AS churn_rate_pct
FROM subscriptions s
JOIN accounts a ON a.account_id=s.account_id
GROUP BY year
ORDER BY year DESC

--IS CERTAIN REFERRAL SOURCE HAVING HIGH CHURN RATES
SELECT
    referral_source,
    ROUND(
        COUNT(*) FILTER (WHERE churn_flag=TRUE ) :: NUMERIC/
        COUNT(*) *100
        ,2
    )AS churn_rate
FROM accounts
GROUP BY referral_source
ORDER BY churn_rate DESC

--IS CERTAIN REFERRAL SOURCE HAVING HIGH DOWNGRADE RATES
SELECT
    a.referral_source,
    ROUND(
        COUNT(*) FILTER (WHERE s.downgrade_flag=TRUE ) :: NUMERIC/
        COUNT(*) *100
        ,2
    )AS downgrade_rate
FROM accounts a
JOIN subscriptions s ON s.account_id=a.account_id
GROUP BY referral_source
ORDER BY downgrade_rate DESC

--ARE CERTAIN REASON CODES RELATED TO HIGH CHURN RATES IN SPECIFIC REFERRAL SOURCES LIKE EVENT ADS ETC
SELECT
    referral_source,
    c.reason_code,
    ROUND(
        COUNT(*) FILTER (WHERE churn_flag=TRUE ) :: NUMERIC/
        COUNT(*) *100
        ,2
    )AS churn_rate
FROM accounts a
JOIN churn_events c ON a.account_id=c.account_id
GROUP BY a.referral_source,c.reason_code
ORDER BY churn_rate DESC

--ARE SPECIFIC CHURN REASONS HAVING HIGHER DOWNGRADES 
SELECT
    a.referral_source,
    c.reason_code,
     ROUND(
        COUNT(*) FILTER (WHERE s.downgrade_flag=TRUE ) :: NUMERIC/
        COUNT(*) *100
        ,2
    )AS downgrade_rate
FROM accounts a
JOIN churn_events c ON c.account_id=a.account_id
JOIN subscriptions s ON s.account_id=a.account_id
GROUP BY a.referral_source,c.reason_code
ORDER BY downgrade_rate DESC

--ARE SPECIFIC CHURN REASONS HAVING HIGHER DOWNGRADES IN PRO PLAN
SELECT
    a.referral_source,
    c.reason_code,
     ROUND(
        COUNT(*) FILTER (WHERE s.downgrade_flag=TRUE ) :: NUMERIC/
        COUNT(*) *100
        ,2
    )AS downgrade_rate
FROM accounts a
JOIN churn_events c ON c.account_id=a.account_id
JOIN subscriptions s ON s.account_id=a.account_id
WHERE a.plan_tier='Pro'
GROUP BY a.referral_source,c.reason_code
ORDER BY downgrade_rate DESC

--ARE BEST PRO PLAN EDTECH INDUSTRY FEATURES PROVIDED IN BASIC PLAN IN EDTECH INDUSTRY TOO
SELECT
    f.feature_name
FROM subscriptions s
JOIN accounts a ON a.account_id=s.account_id
JOIN feature_usage f ON f.subscription_id=s.subscription_id
WHERE a.industry='EdTech' AND s.plan_tier='Basic' AND f.feature_name IN ('feature_40','feature_24','feature_21','feature_24','feature_28')

--BEST EDTECH PRO PLAN FEATURES BASED ON FEATURE ADOPTION RATE=USERS WHO USE THE FEATURE/TOTAL USERS

SELECT *
FROM feature_metrics
ORDER BY adoption_pct DESC;

--DO PRO PLAN HAVE HIGHEST BETA FEATURES
SELECT
    s.plan_tier,
    
    COUNT(*) AS total_feature_records,
    
    COUNT(*) FILTER (
        WHERE f.is_beta_feature = TRUE
    ) AS beta_feature_records,
    
    ROUND(
        COUNT(*) FILTER (
            WHERE f.is_beta_feature = TRUE
        )::NUMERIC
        / COUNT(*) * 100,
        2
    ) AS beta_feature_pct

FROM subscriptions s
JOIN feature_usage f
    ON s.subscription_id = f.subscription_id

GROUP BY s.plan_tier
ORDER BY beta_feature_pct DESC;

--SEAT AND CHURN RATE
SELECT
    s.seat_category,
     ROUND(
        COUNT(DISTINCT a.account_id) FILTER (WHERE a.churn_flag=TRUE ) :: NUMERIC/
        COUNT(DISTINCT a.account_id) *100
        ,0
    )AS churn_rate
FROM accounts a
JOIN subscriptions s ON s.account_id=a.account_id
GROUP BY seat_category
ORDER BY churn_rate

--BILLING FREQUENCY AND CHURN RATE
SELECT
    s.billing_frequency,
     ROUND(
        COUNT(DISTINCT a.account_id) FILTER (WHERE a.churn_flag=TRUE ) :: NUMERIC/
        COUNT(DISTINCT a.account_id) *100
        ,0
    )AS churn_rate
FROM accounts a
JOIN subscriptions s ON s.account_id=a.account_id
GROUP BY s.billing_frequency
ORDER BY churn_rate

--FEATURE AND CHURN RATE
SELECT
    f.feature_name,
    ROUND(
        COUNT(DISTINCT a.account_id) FILTER (WHERE a.churn_flag=TRUE ) :: NUMERIC/
        COUNT(DISTINCT a.account_id) *100
        ,0
    )AS churn_rate
FROM accounts a
JOIN subscriptions s ON s.account_id=a.account_id
JOIN feature_usage f ON f.subscription_id=s.subscription_id
GROUP BY f.feature_name
ORDER BY churn_rate DESC

--DOWNGRADE PCT
SELECT
    ROUND(
        COUNT(*) FILTER (WHERE s.downgrade_flag=TRUE ) :: NUMERIC/
        COUNT(*) *100
        ,2
    )AS downgrade_rate
FROM subscriptions s


--PLAN TIER AND CHURN
SELECT
    a.plan_tier,
    ROUND(
        COUNT(DISTINCT a.account_id) FILTER (WHERE a.churn_flag=TRUE ) :: NUMERIC/
        COUNT(DISTINCT a.account_id) *100
        ,2
    )AS churn_rate
FROM accounts a
GROUP BY a.plan_tier
ORDER BY churn_rate DESC

--YoY MRR AND ARR
SELECT
    SUM(CASE 
        WHEN EXTRACT(YEAR FROM start_date) = 2024 
        THEN mrr_amount ELSE 0 
    END) AS mrr_2024,

    SUM(CASE 
        WHEN EXTRACT(YEAR FROM start_date) = 2023 
        THEN mrr_amount ELSE 0 
    END) AS mrr_2023,

    ROUND(
        (
            SUM(CASE 
                WHEN EXTRACT(YEAR FROM start_date) = 2024 
                THEN mrr_amount ELSE 0 
            END)
            -
            SUM(CASE 
                WHEN EXTRACT(YEAR FROM start_date) = 2023 
                THEN mrr_amount ELSE 0 
            END)
        )
        /
        NULLIF(
            SUM(CASE 
                WHEN EXTRACT(YEAR FROM start_date) = 2023 
                THEN mrr_amount ELSE 0 
            END),
            0
        ) * 100,
        2
    ) AS mrr_yoy_pct,

    SUM(CASE 
        WHEN EXTRACT(YEAR FROM start_date) = 2024 
        THEN arr_amount ELSE 0 
    END) AS arr_2024,

    SUM(CASE 
        WHEN EXTRACT(YEAR FROM start_date) = 2023 
        THEN arr_amount ELSE 0 
    END) AS arr_2023,

    ROUND(
        (
            SUM(CASE 
                WHEN EXTRACT(YEAR FROM start_date) = 2024 
                THEN arr_amount ELSE 0 
            END)
            -
            SUM(CASE 
                WHEN EXTRACT(YEAR FROM start_date) = 2023 
                THEN arr_amount ELSE 0 
            END)
        )
        /
        NULLIF(
            SUM(CASE 
                WHEN EXTRACT(YEAR FROM start_date) = 2023 
                THEN arr_amount ELSE 0 
            END),
            0
        ) * 100,
        2
    ) AS arr_yoy_pct

FROM subscriptions;

--ARPU 2023 AND 2024
SELECT
    EXTRACT(YEAR FROM start_date) AS year,
    SUM(mrr_amount) AS total_mrr,
    COUNT(DISTINCT account_id) AS total_accounts,
    ROUND(
        SUM(mrr_amount) / NULLIF(COUNT(DISTINCT account_id), 0),
        2
    ) AS arpu
FROM subscriptions
GROUP BY EXTRACT(YEAR FROM start_date)
ORDER BY year;

WITH yearly_metrics AS (
    SELECT
        year,
        SUM(mrr_amount) AS mrr,
        SUM(mrr_amount) * 12 AS arr,
        COUNT(DISTINCT account_id) AS active_accounts
    FROM (
        SELECT
            2023 AS year,
            s.account_id,
            s.mrr_amount
        FROM subscriptions s
        WHERE s.start_date <= '2023-12-31'
          AND (
              s.end_date IS NULL
              OR s.end_date >= '2023-12-31'
          )

        UNION ALL

        SELECT
            2024 AS year,
            s.account_id,
            s.mrr_amount
        FROM subscriptions s
        WHERE s.start_date <= '2024-12-31'
          AND (
              s.end_date IS NULL
              OR s.end_date >= '2024-12-31'
          )
    ) active_subscriptions
    GROUP BY year
),

metrics AS (
    SELECT
        year,
        mrr,
        arr,
        active_accounts,
        mrr / NULLIF(active_accounts, 0) AS arpu
    FROM yearly_metrics
)

SELECT
    year,
    ROUND(mrr, 2) AS mrr,
    ROUND(arr, 2) AS arr,
    active_accounts,
    ROUND(arpu, 2) AS arpu,

    ROUND(
        (
            (mrr - LAG(mrr) OVER (ORDER BY year))
            / NULLIF(LAG(mrr) OVER (ORDER BY year), 0)
        ) * 100,
        2
    ) AS mrr_yoy_pct,

    ROUND(
        (
            (arr - LAG(arr) OVER (ORDER BY year))
            / NULLIF(LAG(arr) OVER (ORDER BY year), 0)
        ) * 100,
        2
    ) AS arr_yoy_pct,

    ROUND(
        (
            (arpu - LAG(arpu) OVER (ORDER BY year))
            / NULLIF(LAG(arpu) OVER (ORDER BY year), 0)
        ) * 100,
        2
    ) AS arpu_yoy_pct

FROM metrics
ORDER BY year;

--DOWNGRADE % OF 2024 AND 2023 ,YOY % FOR DOWMGRADE
SELECT
    ROUND(
        COUNT(*) FILTER (
            WHERE EXTRACT(YEAR FROM start_date) = 2024
            AND downgrade_flag = TRUE
        )::NUMERIC
        /
        NULLIF(
            COUNT(*) FILTER (
                WHERE EXTRACT(YEAR FROM start_date) = 2024
            ),
            0
        ) * 100,
        2
    ) AS downgrade_pct_2024,

    ROUND(
        COUNT(*) FILTER (
            WHERE EXTRACT(YEAR FROM start_date) = 2023
            AND downgrade_flag = TRUE
        )::NUMERIC
        /
        NULLIF(
            COUNT(*) FILTER (
                WHERE EXTRACT(YEAR FROM start_date) = 2023
            ),
            0
        ) * 100,
        2
    ) AS downgrade_pct_2023,

    ROUND(
        (
            (
                COUNT(*) FILTER (
                    WHERE EXTRACT(YEAR FROM start_date) = 2024
                    AND downgrade_flag = TRUE
                )::NUMERIC
                /
                NULLIF(
                    COUNT(*) FILTER (
                        WHERE EXTRACT(YEAR FROM start_date) = 2024
                    ),
                    0
                )
            )
            -
            (
                COUNT(*) FILTER (
                    WHERE EXTRACT(YEAR FROM start_date) = 2023
                    AND downgrade_flag = TRUE
                )::NUMERIC
                /
                NULLIF(
                    COUNT(*) FILTER (
                        WHERE EXTRACT(YEAR FROM start_date) = 2023
                    ),
                    0
                )
            )
        )
        /
        NULLIF(
            COUNT(*) FILTER (
                WHERE EXTRACT(YEAR FROM start_date) = 2023
                AND downgrade_flag = TRUE
            )::NUMERIC
            /
            NULLIF(
                COUNT(*) FILTER (
                    WHERE EXTRACT(YEAR FROM start_date) = 2023
                ),
                0
            ),
            0
        ) * 100,
        2
    ) AS downgrade_yoy_pct

FROM subscriptions;

--USAGE COUNT VS CHURN RATE

SELECT
    usage_count,
    ROUND(
        COUNT(DISTINCT s.account_id) FILTER(WHERE a.churn_flag=TRUE)::NUMERIC/
        COUNT(DISTINCT s.account_id)*100,2
    ) AS churn_rate_pct
FROM subscriptions s
JOIN accounts a ON a.account_id=s.account_id
JOIN feature_usage f ON f.subscription_id=s.subscription_id
GROUP BY usage_count
ORDER BY usage_count

SELECT
    satisfaction_score,
    ROUND(
        COUNT(DISTINCT s.account_id) FILTER(WHERE a.churn_flag=TRUE)::NUMERIC/
        COUNT(DISTINCT s.account_id)*100,2
    ) AS churn_rate_pct
FROM subscriptions s
JOIN accounts a ON a.account_id=s.account_id
JOIN support_tickets st ON st.account_id=s.account_id
GROUP BY satisfaction_score
ORDER BY satisfaction_score


SELECT
    satisfaction_score
FROM subscriptions s
JOIN support_tickets st ON st.account_id=s.account_id
GROUP BY satisfaction_score
ORDER BY satisfaction_score

--COHORT ANALYSIS (SIGNUP DATE VS CHURN DATE)

CREATE VIEW cohort_analysis AS

WITH first_churn AS (
    SELECT
        account_id,
        MIN(churn_date) AS first_churn_date
    FROM churn_events
    GROUP BY account_id
),

customer_cohort AS (
    SELECT
        a.account_id,
        DATE_TRUNC('month', a.signup_date)::DATE AS signup_month,
        fc.first_churn_date
    FROM accounts a
    LEFT JOIN first_churn fc
        ON a.account_id = fc.account_id
),

cohort_summary AS (
    SELECT
        signup_month,
        COUNT(*) AS cohort_size,

        COUNT(*) FILTER (
            WHERE first_churn_date IS NOT NULL
              AND first_churn_date < signup_month + INTERVAL '1 month'
        ) AS m0_churns,

        COUNT(*) FILTER (
            WHERE first_churn_date IS NOT NULL
              AND first_churn_date < signup_month + INTERVAL '2 months'
        ) AS m1_churns,

        COUNT(*) FILTER (
            WHERE first_churn_date IS NOT NULL
              AND first_churn_date < signup_month + INTERVAL '3 months'
        ) AS m2_churns,

        COUNT(*) FILTER (
            WHERE first_churn_date IS NOT NULL
              AND first_churn_date < signup_month + INTERVAL '4 months'
        ) AS m3_churns,

        COUNT(*) FILTER (
            WHERE first_churn_date IS NOT NULL
              AND first_churn_date < signup_month + INTERVAL '5 months'
        ) AS m4_churns

    FROM customer_cohort
    GROUP BY signup_month
),

cohort_retention AS (
    SELECT
        *,
        (DATE '2024-12-31' >=
            signup_month + INTERVAL '1 month') AS m0_observed,
        (DATE '2024-12-31' >=
            signup_month + INTERVAL '2 months') AS m1_observed,
        (DATE '2024-12-31' >=
            signup_month + INTERVAL '3 months') AS m2_observed,
        (DATE '2024-12-31' >=
            signup_month + INTERVAL '4 months') AS m3_observed,
        (DATE '2024-12-31' >=
            signup_month + INTERVAL '5 months') AS m4_observed
    FROM cohort_summary
)

SELECT
    signup_month,
    cohort_size,

    CASE WHEN m0_observed
        THEN m0_churns END AS m0_churns,
    CASE WHEN m0_observed
        THEN ROUND(
            (1 - m0_churns::NUMERIC / cohort_size) * 100, 2
        ) END AS m0_retention_pct,

    CASE WHEN m1_observed
        THEN m1_churns END AS m1_churns,
    CASE WHEN m1_observed
        THEN ROUND(
            (1 - m1_churns::NUMERIC / cohort_size) * 100, 2
        ) END AS m1_retention_pct,

    CASE WHEN m2_observed
        THEN m2_churns END AS m2_churns,
    CASE WHEN m2_observed
        THEN ROUND(
            (1 - m2_churns::NUMERIC / cohort_size) * 100, 2
        ) END AS m2_retention_pct,

    CASE WHEN m3_observed
        THEN m3_churns END AS m3_churns,
    CASE WHEN m3_observed
        THEN ROUND(
            (1 - m3_churns::NUMERIC / cohort_size) * 100, 2
        ) END AS m3_retention_pct,

    CASE WHEN m4_observed
        THEN m4_churns END AS m4_churns,
    CASE WHEN m4_observed
        THEN ROUND(
            (1 - m4_churns::NUMERIC / cohort_size) * 100, 2
        ) END AS m4_retention_pct

FROM cohort_retention
ORDER BY signup_month;


