--ACCOUNTS TABLE
SELECT * FROM accounts
LIMIT 30;

--SUBSCRIPTIONS TABLE
SELECT * FROM subscriptions
LIMIT 30;

--FEATURE USAGE TABLE
SELECT * FROM feature_usage
LIMIT 30;

--SUPPORT TICKETS TABLE
SELECT * FROM support_tickets
LIMIT 30;

--CHURN EVENTS TABLE
SELECT * FROM churn_events
LIMIT 30;

--ACCOUNTS TABLE NULLS AND DUPLICATES
SELECT
    COUNT(*)-COUNT(account_id) AS id_nulls,
    COUNT(*)-COUNT(account_name) AS name_nulls,
    COUNT(*)-COUNT(industry) AS indus_nulls,
    COUNT(*)-COUNT(country) AS con_nulls,
    COUNT(*)-COUNT(signup_date) AS date_nulls,
    COUNT(*)-COUNT(referral_source) AS source_nulls,
    COUNT(*)-COUNT(seats) AS seats_nulls,
    COUNT(account_id)-COUNT(DISTINCT account_id) AS id_duplicates
FROM accounts;

-- SUBSCRIPTIONS TABLE NULLS AND DUPLICATES
SELECT
    COUNT(*) - COUNT(subscription_id) AS sub_id_nulls,
    COUNT(*) - COUNT(account_id) AS account_id_nulls,
    COUNT(*) - COUNT(start_date) AS start_date_nulls,
    COUNT(*) - COUNT(end_date) AS end_date_nulls,
    COUNT(*) - COUNT(plan_tier) AS plan_tier_nulls,
    COUNT(*) - COUNT(seats) AS seats_nulls,
    COUNT(*) - COUNT(mrr_amount) AS mrr_nulls,
    COUNT(*) - COUNT(arr_amount) AS arr_nulls,
    COUNT(*) - COUNT(is_trial) AS is_trial_nulls,
    COUNT(*) - COUNT(upgrade_flag) AS upgrade_flag_nulls,
    COUNT(*) - COUNT(downgrade_flag) AS downgrade_flag_nulls,
    COUNT(*) - COUNT(churn_flag) AS churn_flag_nulls,
    COUNT(*) - COUNT(billing_frequency) AS billing_freq_nulls,
    COUNT(*) - COUNT(auto_renew_flag) AS auto_renew_nulls,
    COUNT(subscription_id) - COUNT(DISTINCT subscription_id) AS subscription_id_duplicates
FROM subscriptions;

-- CHURN EVENTS TABLE NULLS AND DUPLICATES
SELECT
    COUNT(*) - COUNT(churn_event_id) AS churn_id_nulls,
    COUNT(*) - COUNT(account_id) AS account_id_nulls,
    COUNT(*) - COUNT(churn_date) AS churn_date_nulls,
    COUNT(*) - COUNT(reason_code) AS reason_code_nulls,
    COUNT(*) - COUNT(refund_amount_usd) AS refund_nulls,
    COUNT(*) - COUNT(preceding_upgrade_flag) AS upgrade_flag_nulls,
    COUNT(*) - COUNT(preceding_downgrade_flag) AS downgrade_flag_nulls,
    COUNT(*) - COUNT(is_reactivation) AS reactivation_nulls,
    COUNT(*) - COUNT(feedback_text) AS feedback_nulls,
    COUNT(churn_event_id) - COUNT(DISTINCT churn_event_id) AS churn_event_id_duplicates
FROM churn_events;

-- FEATURE USAGE TABLE NULLS AND DUPLICATES
SELECT
    COUNT(*) - COUNT(usage_id) AS usage_id_nulls,
    COUNT(*) - COUNT(subscription_id) AS sub_id_nulls,
    COUNT(*) - COUNT(usage_date) AS usage_date_nulls,
    COUNT(*) - COUNT(feature_name) AS feature_name_nulls,
    COUNT(*) - COUNT(usage_count) AS usage_count_nulls,
    COUNT(*) - COUNT(usage_duration_secs) AS duration_nulls,
    COUNT(*) - COUNT(error_count) AS error_count_nulls,
    COUNT(*) - COUNT(is_beta_feature) AS beta_feature_nulls
FROM feature_usage;

-- SUPPORT TICKETS TABLE NULLS AND DUPLICATES
SELECT
    COUNT(*) - COUNT(ticket_id) AS ticket_id_nulls,
    COUNT(*) - COUNT(account_id) AS account_id_nulls,
    COUNT(*) - COUNT(submitted_at) AS submitted_at_nulls,
    COUNT(*) - COUNT(closed_at) AS closed_at_nulls,
    COUNT(*) - COUNT(resolution_time_hours) AS res_time_nulls,
    COUNT(*) - COUNT(priority) AS priority_nulls,
    COUNT(*) - COUNT(first_response_time_minutes) AS resp_time_nulls,
    COUNT(*) - COUNT(satisfaction_score) AS satisfaction_nulls,
    COUNT(*) - COUNT(escalation_flag) AS escalation_nulls,
    COUNT(ticket_id) - COUNT(DISTINCT ticket_id) AS ticket_id_duplicates
FROM support_tickets;