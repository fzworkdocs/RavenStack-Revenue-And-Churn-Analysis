--ACCOUNTS TABLE
CREATE TABLE accounts(
    account_id VARCHAR(50) PRIMARY KEY,
    account_name VARCHAR(255) NOT NULL,
    industry VARCHAR(100),
    country VARCHAR(100),
    signup_date DATE NOT NULL,
    referral_source VARCHAR(100) NOT NULL,
    plan_tier VARCHAR(50) NOT NULL,
    seats INT NOT NULL CHECK (seats>=0),
    is_trial BOOLEAN NOT NULL DEFAULT FALSE,
    churn_flag BOOLEAN NOT NULL DEFAULT FALSE
);

--SUBSCRIPTIONS TABLE
CREATE TABLE subscriptions(
    subscription_id VARCHAR(50) PRIMARY KEY,
    account_id VARCHAR(50) NOT NULL REFERENCES accounts(account_id) ON DELETE CASCADE,
    start_date DATE NOT NULL,
    end_date DATE,
    plan_tier VARCHAR(50) NOT NULL,
    seats INT NOT NULL CHECK (seats>=0),
    mrr_amount NUMERIC(10,2) NOT NULL CHECK (mrr_amount>=0),
    arr_amount NUMERIC(12,2) NOT NULL CHECK (arr_amount>=0),
    is_trial BOOLEAN NOT NULL DEFAULT FALSE,
    upgrade_flag BOOLEAN NOT NULL DEFAULT FALSE,
    downgrade_flag BOOLEAN NOT NULL DEFAULT FALSE,
    churn_flag BOOLEAN NOT NULL DEFAULT FALSE,
    billing_frequency VARCHAR(50) NOT NULL,
    auto_renew_flag BOOLEAN NOT NULL DEFAULT TRUE
);

--CHURN EVENTS TABLE
CREATE TABLE churn_events(
    churn_event_id VARCHAR(50) PRIMARY KEY,
    account_id VARCHAR(50) NOT NULL REFERENCES accounts(account_id) ON DELETE CASCADE,
    churn_date DATE NOT NULL,
    reason_code VARCHAR(100) NOT NULL,
    refund_amount_usd NUMERIC(10,2) NOT NULL DEFAULT 0.00 CHECK (refund_amount_usd>=0),
    preceding_upgrade_flag BOOLEAN NOT NULL DEFAULT FALSE,
    preceding_downgrade_flag BOOLEAN NOT NULL DEFAULT FALSE,
    is_reactivation BOOLEAN NOT NULL DEFAULT FALSE,
    feedback_text TEXT
);

--FEATURE USAGE TABLE
DROP TABLE IF EXISTS feature_usage CASCADE;

CREATE TABLE feature_usage (
    usage_id VARCHAR(50) NOT NULL,
    subscription_id VARCHAR(50) NOT NULL REFERENCES subscriptions(subscription_id) ON DELETE CASCADE,
    usage_date DATE NOT NULL,
    feature_name VARCHAR(100) NOT NULL,
    usage_count INT NOT NULL DEFAULT 0 CHECK (usage_count >= 0),
    usage_duration_secs INT NOT NULL DEFAULT 0 CHECK (usage_duration_secs >= 0),
    error_count INT NOT NULL DEFAULT 0 CHECK (error_count >= 0),
    is_beta_feature BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (usage_id, subscription_id, usage_date, feature_name)
);

--SUPPORT TICKETS TABLE
CREATE TABLE support_tickets(
    ticket_id VARCHAR(50) PRIMARY KEY,
    account_id VARCHAR(50) NOT NULL REFERENCES accounts(account_id) ON DELETE CASCADE,
    submitted_at TIMESTAMP NOT NULL,
    closed_at TIMESTAMP,
    resolution_time_hours NUMERIC(10,2) NOT NULL CHECK (resolution_time_hours>=0),
    priority VARCHAR(50) NOT NULL,
    first_response_time_minutes INT NOT NULL CHECK(first_response_time_minutes>=0),
    satisfaction_score iNT CHECK (satisfaction_score BETWEEN 1 AND 5),
    escalation_flag BOOLEAN NOT NULL DEFAULT FALSE
);

ALTER TABLE support_tickets 
    ALTER COLUMN satisfaction_score TYPE NUMERIC(3,1);

