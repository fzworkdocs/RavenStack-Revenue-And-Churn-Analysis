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
    COUNT(subscription_id) AS total_subs,
    COUNT(CASE WHEN downgrade_flag THEN 1 END) AS downgrade_count,
    ROUND((COUNT(CASE WHEN downgrade_flag THEN 1 END)::NUMERIC/COUNT(*))*100,2) AS downgrade_pct,
    SUM(mrr_amount) AS mrr_impact
FROM subscriptions
GROUP BY plan_tier

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
    COUNT(CASE WHEN s.downgrade_flag THEN 1 END) AS downgrade_events,
    SUM(s.mrr_amount) AS total_mrr,
    ROUND(COUNT(*)::NUMERIC/SUM(COUNT(*)) OVER() *100,2) AS pct_total
FROM subscriptions s
JOIN churn_events c ON c.account_id=s.account_id
WHERE s.plan_tier='Pro' AND s.downgrade_flag = TRUE
GROUP BY c.reason_code

--ARE CERTAIN INDUSTRIES HAVING HIGHER DOWNGRADES IN PRO PLAN
SELECT
    a.industry,
    COUNT(DISTINCT s.subscription_id) AS total_subs,
    COUNT(CASE WHEN s.downgrade_flag THEN 1 END) AS total_downgrades,
    ROUND(COUNT(CASE WHEN s.downgrade_flag THEN 1 END)::NUMERIC/COUNT(*)*100,2) AS downgrade_pct
FROM subscriptions s
JOIN accounts a ON a.account_id=s.account_id
WHERE s.plan_tier='Pro'
GROUP BY a.industry

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
ORDER BY  ROUND(AVG(f.error_count),2) DESC -- COUNT(DISTINCT s.subscription_id) DESC --ROUND(COUNT(CASE WHEN s.downgrade_flag THEN 1 END)::NUMERIC/COUNT(*)*100,2) DESC

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

--ARE CERTAIN REFFERAL SOURCE FOR PRO PLAN CAUSING HIGHER DOWNGRADES
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