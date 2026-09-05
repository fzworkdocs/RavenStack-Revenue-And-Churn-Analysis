# %% HYPOTHESIS TESTING-
# PERFORMING CHISQUARE TEST OF INDEPENDECE TO DETERMINE IF PLAN TIER AND DOWNGRADES
# HAVE ANY ASSOCIATION

import pandas as pd
from sqlalchemy import create_engine
from scipy.stats import chi2_contingency


engine=create_engine(
    "postgresql+psycopg2://postgres:faizasweety66@localhost:5432/project3_saas"
)

query="""
SELECT
    plan_tier,
    downgrade_flag
FROM subscriptions
"""
df=pd.read_sql(query,engine)

contingency_table=pd.crosstab(
    df["plan_tier"],
    df["downgrade_flag"]
)

print("CONTINGENCY TABLE:")
print(contingency_table)

#CHISQUARE TEST OF INDEPENDENCE
chi2,p_value,dof,expected=chi2_contingency(contingency_table)

#CRAMER'S V EFFECT SIZE
n=contingency_table.to_numpy().sum()
min_dimension=min(contingency_table.shape) - 1
cramers_v=(chi2 / (n-min_dimension) )**0.5

print("Chisquare Test Results:")
print(f"Chi Square Statistic: {chi2:.4f}")
print(f"Dof: {dof}")
print(f"p_value: {p_value:.4f}")
print("Effect Size:")
print(f"Cramer's V: {cramers_v:.4f}")

alpha=0.05
if p_value<=alpha:
    print("\nRESULT: Significant association between plan tier and downgrade behaviour")
else:
    print("\nRESULT: No significant association between plan tier and downgrade behaviour")

if cramers_v < 0.10:
    strength = "negligible/very weak"
elif cramers_v < 0.30:
    strength = "weak"
elif cramers_v < 0.50:
    strength = "moderate"
else: 
    strength = "strong"

print(f"Effect Size Interpretation: {strength}")

# %% HYPOTHESIS TESTING-
# PERFORMING CHISQUARE TEST OF INDEPENDECE TO DETERMINE IF INDUSTRY AND DOWNGRADES
# HAVE ANY ASSOCIATION

import pandas as pd
from sqlalchemy import create_engine
from scipy.stats import chi2_contingency


engine=create_engine(
    "postgresql+psycopg2://postgres:faizasweety66@localhost:5432/project3_saas"
)

query="""
SELECT
    a.industry,
    s.downgrade_flag
FROM subscriptions s
INNER JOIN accounts a ON a.account_id=s.account_id
"""
df=pd.read_sql(query,engine)

contingency_table=pd.crosstab(
    df["industry"],
    df["downgrade_flag"]
)

print("CONTINGENCY TABLE:")
print(contingency_table)

#CHISQUARE TEST OF INDEPENDENCE
chi2,p_value,dof,expected=chi2_contingency(contingency_table)

#CRAMER'S V EFFECT SIZE
n=contingency_table.to_numpy().sum()
min_dimension=min(contingency_table.shape) - 1
cramers_v=(chi2 / (n-min_dimension) )**0.5

print("Chisquare Test Results:")
print(f"Chi Square Statistic: {chi2:.4f}")
print(f"Dof: {dof}")
print(f"p_value: {p_value:.4f}")
print("Effect Size:")
print(f"Cramer's V: {cramers_v:.4f}")

alpha=0.05
if p_value<=alpha:
    print("\nRESULT: Significant association between industry and downgrade behaviour")
else:
    print("\nRESULT: No significant association between industry and downgrade behaviour")

if cramers_v < 0.10:
    strength = "negligible/very weak"
elif cramers_v < 0.30:
    strength = "weak"
elif cramers_v < 0.50:
    strength = "moderate"
else: 
    strength = "strong"

print(f"Effect Size Interpretation: {strength}")

# %% HYPOTHESIS TESTING-
# PERFORMING CHISQUARE TEST OF INDEPENDECE TO DETERMINE IF REFERRAL SOURCE AND DOWNGRADES
# HAVE ANY ASSOCIATION

import pandas as pd
from sqlalchemy import create_engine
from scipy.stats import chi2_contingency


engine=create_engine(
    "postgresql+psycopg2://postgres:faizasweety66@localhost:5432/project3_saas"
)

query="""
SELECT
    a.referral_source,
    downgrade_flag
FROM subscriptions s
INNER JOIN accounts a ON a.account_id=s.account_id
"""
df=pd.read_sql(query,engine)

contingency_table=pd.crosstab(
    df["referral_source"],
    df["downgrade_flag"]
)

print("CONTINGENCY TABLE:")
print(contingency_table)

#CHISQUARE TEST OF INDEPENDENCE
chi2,p_value,dof,expected=chi2_contingency(contingency_table)

#CRAMER'S V EFFECT SIZE
n=contingency_table.to_numpy().sum()
min_dimension=min(contingency_table.shape) - 1
cramers_v=(chi2 / (n-min_dimension) )**0.5

print("Chisquare Test Results:")
print(f"Chi Square Statistic: {chi2:.4f}")
print(f"Dof: {dof}")
print(f"p_value: {p_value:.4f}")
print("Effect Size:")
print(f"Cramer's V: {cramers_v:.4f}")

alpha=0.05
if p_value<=alpha:
    print("\nRESULT: Significant association between plan tier and downgrade behaviour")
else:
    print("\nRESULT: No significant association between plan tier and downgrade behaviour")

if cramers_v < 0.10:
    strength = "negligible/very weak"
elif cramers_v < 0.30:
    strength = "weak"
elif cramers_v < 0.50:
    strength = "moderate"
else: 
    strength = "strong"

print(f"Effect Size Interpretation: {strength}")

# %% HYPOTHESIS TESTING-
# PERFORMING CHISQUARE TEST OF INDEPENDECE TO DETERMINE IF BILLING FREQUENCY AND DOWNGRADES
# HAVE ANY ASSOCIATION

import pandas as pd
from sqlalchemy import create_engine
from scipy.stats import chi2_contingency


engine=create_engine(
    "postgresql+psycopg2://postgres:faizasweety66@localhost:5432/project3_saas"
)

query="""
SELECT
    billing_frequency,
    downgrade_flag
FROM subscriptions
"""
df=pd.read_sql(query,engine)

contingency_table=pd.crosstab(
    df["billing_frequency"],
    df["downgrade_flag"]
)

print("CONTINGENCY TABLE:")
print(contingency_table)

#CHISQUARE TEST OF INDEPENDENCE
chi2,p_value,dof,expected=chi2_contingency(contingency_table)

#CRAMER'S V EFFECT SIZE
n=contingency_table.to_numpy().sum()
min_dimension=min(contingency_table.shape) - 1
cramers_v=(chi2 / (n-min_dimension) )**0.5

print("Chisquare Test Results:")
print(f"Chi Square Statistic: {chi2:.4f}")
print(f"Dof: {dof}")
print(f"p_value: {p_value:.4f}")
print("Effect Size:")
print(f"Cramer's V: {cramers_v:.4f}")

alpha=0.05
if p_value<=alpha:
    print("\nRESULT: Significant association between plan tier and downgrade behaviour")
else:
    print("\nRESULT: No significant association between plan tier and downgrade behaviour")

if cramers_v < 0.10:
    strength = "negligible/very weak"
elif cramers_v < 0.30:
    strength = "weak"
elif cramers_v < 0.50:
    strength = "moderate"
else: 
    strength = "strong"

print(f"Effect Size Interpretation: {strength}")

# %% HYPOTHESIS TESTING-
# PERFORMING CHISQUARE TEST OF INDEPENDECE TO DETERMINE IF AUTO RENEW AND DOWNGRADES
# HAVE ANY ASSOCIATION

import pandas as pd
from sqlalchemy import create_engine
from scipy.stats import chi2_contingency


engine=create_engine(
    "postgresql+psycopg2://postgres:faizasweety66@localhost:5432/project3_saas"
)

query="""
SELECT
    auto_renew_flag,
    downgrade_flag
FROM subscriptions
"""
df=pd.read_sql(query,engine)

contingency_table=pd.crosstab(
    df["auto_renew_flag"],
    df["downgrade_flag"]
)

print("CONTINGENCY TABLE:")
print(contingency_table)

#CHISQUARE TEST OF INDEPENDENCE
chi2,p_value,dof,expected=chi2_contingency(contingency_table)

#CRAMER'S V EFFECT SIZE
n=contingency_table.to_numpy().sum()
min_dimension=min(contingency_table.shape) - 1
cramers_v=(chi2 / (n-min_dimension) )**0.5

print("Chisquare Test Results:")
print(f"Chi Square Statistic: {chi2:.4f}")
print(f"Dof: {dof}")
print(f"p_value: {p_value:.4f}")
print("Effect Size:")
print(f"Cramer's V: {cramers_v:.4f}")

alpha=0.05
if p_value<=alpha:
    print("\nRESULT: Significant association between plan tier and downgrade behaviour")
else:
    print("\nRESULT: No significant association between plan tier and downgrade behaviour")

if cramers_v < 0.10:
    strength = "negligible/very weak"
elif cramers_v < 0.30:
    strength = "weak"
elif cramers_v < 0.50:
    strength = "moderate"
else: 
    strength = "strong"

print(f"Effect Size Interpretation: {strength}")

# %% HYPOTHESIS TESTING-
# PERFORMING CHISQUARE TEST OF INDEPENDECE TO DETERMINE IF PREVIOUS UPGRADE HISTORY AND DOWNGRADES
# HAVE ANY ASSOCIATION

import pandas as pd
from sqlalchemy import create_engine
from scipy.stats import chi2_contingency


engine=create_engine(
    "postgresql+psycopg2://postgres:faizasweety66@localhost:5432/project3_saas"
)

query="""
SELECT
    c.preceding_upgrade_flag,
    s.downgrade_flag
FROM subscriptions S
INNER JOIN churn_events c ON c.account_id=s.account_id
"""
df=pd.read_sql(query,engine)

contingency_table=pd.crosstab(
    df["preceding_upgrade_flag"],
    df["downgrade_flag"]
)

print("CONTINGENCY TABLE:")
print(contingency_table)

#CHISQUARE TEST OF INDEPENDENCE
chi2,p_value,dof,expected=chi2_contingency(contingency_table)

#CRAMER'S V EFFECT SIZE
n=contingency_table.to_numpy().sum()
min_dimension=min(contingency_table.shape) - 1
cramers_v=(chi2 / (n-min_dimension) )**0.5

print("Chisquare Test Results:")
print(f"Chi Square Statistic: {chi2:.4f}")
print(f"Dof: {dof}")
print(f"p_value: {p_value:.4f}")
print("Effect Size:")
print(f"Cramer's V: {cramers_v:.4f}")

alpha=0.05
if p_value<=alpha:
    print("\nRESULT: Significant association between plan tier and downgrade behaviour")
else:
    print("\nRESULT: No significant association between plan tier and downgrade behaviour")

if cramers_v < 0.10:
    strength = "negligible/very weak"
elif cramers_v < 0.30:
    strength = "weak"
elif cramers_v < 0.50:
    strength = "moderate"
else: 
    strength = "strong"

print(f"Effect Size Interpretation: {strength}")

# %% DOES SEATS DIFFER FOR DOWNGRADED AND NON DOWNGRADED SUBS

import pandas as pd
from sqlalchemy import create_engine
from scipy.stats import mannwhitneyu

engine=create_engine(
    "postgresql+psycopg2://postgres:faizasweety66@localhost:5432/project3_saas"
)

query="""
SELECT
    downgrade_flag,
    seats
FROM subscriptions 
"""
df=pd.read_sql(query,engine)

downgraded_seats = df.loc[
    df["downgrade_flag"] == True,
    "seats"
].dropna()

non_downgraded_seats = df.loc[
    df["downgrade_flag"] == False,
    "seats"
].dropna()

# Mann-Whitney U test
u_stat, p_value = mannwhitneyu(
    downgraded_seats,
    non_downgraded_seats,
    alternative="two-sided"
)

print(f"Downgraded median seats: {downgraded_seats.median():.2f}")
print(f"Non-downgraded median seats: {non_downgraded_seats.median():.2f}")
print(f"U statistic: {u_stat:.2f}")
print(f"p-value: {p_value:.4f}")

if p_value < 0.05:
    print("Conclusion: Significant difference in seats between the two groups.")
else:
    print("Conclusion: No statistically significant difference.")

# %% DOES MRR DIFFER FOR DOWNGRADED AND NON DOWNGRADED SUBS

import pandas as pd
from sqlalchemy import create_engine
from scipy.stats import mannwhitneyu

engine=create_engine(
    "postgresql+psycopg2://postgres:faizasweety66@localhost:5432/project3_saas"
)

query="""
SELECT
    downgrade_flag,
    mrr_amount
FROM subscriptions 
"""
df=pd.read_sql(query,engine)

downgraded_mrr = df.loc[
    df["downgrade_flag"] == True,
    "mrr_amount"
].dropna()

non_downgraded_mrr = df.loc[
    df["downgrade_flag"] == False,
    "mrr_amount"
].dropna()

# Mann-Whitney U
u_stat, p_value = mannwhitneyu(
    downgraded_mrr,
    non_downgraded_mrr,
    alternative="two-sided"
)

print(f"Downgraded median MRR: ${downgraded_mrr.median():,.2f}")
print(f"Non-downgraded median MRR: ${non_downgraded_mrr.median():,.2f}")
print(f"U statistic: {u_stat:.2f}")
print(f"p-value: {p_value:.4f}")

if p_value < 0.05:
    print("Conclusion: Significant difference in mrr amount between the two groups.")
else:
    print("Conclusion: No statistically significant difference.")
    
# %%
