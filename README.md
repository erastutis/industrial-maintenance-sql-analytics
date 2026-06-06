# Industrial Maintenance SQL Analytics

## Project Overview

This project analyses industrial machine operating data to identify failure patterns, high-risk operating conditions and potential maintenance priorities.

The goal is to use SQL and Python to turn raw machine sensor data into practical engineering insights. The project focuses on failure rate analysis, operating condition segmentation and rule-based risk scoring.

## Dataset

The project uses the AI4I 2020 Predictive Maintenance Dataset.

The dataset contains 10,000 machine operating records with information about:

- product type
- air temperature
- process temperature
- rotational speed
- torque
- tool wear
- machine failure
- specific failure types

## Tools Used

- SQL
- SQLite
- Python
- pandas
- VS Code

## Main Analysis Questions

1. What is the overall machine failure rate?
2. Which product types fail most often?
3. Which failure types are most common?
4. How do failed and non-failed operating conditions differ?
5. How does tool wear affect failure risk?
6. How does torque affect failure risk?
7. Can simple engineering rules separate low-risk and high-risk machine records?

## Key Findings

### 1. Machine failures are rare

The dataset contains 10,000 records and 339 machine failures.

Overall failure rate:

3.39%

This means that failures are relatively rare. Because of this, accuracy alone would be a misleading metric for any future machine learning model. Precision, recall and F1-score would be more useful.

### 2. Product type L has the highest failure rate

Failure rate by product type:

| Product type | Records | Failures | Failure rate |
|---|---:|---:|---:|
| L | 6000 | 235 | 3.92% |
| M | 2997 | 83 | 2.77% |
| H | 1003 | 21 | 2.09% |

Product type L has the highest failure rate. However, it also represents the largest share of the dataset, so this result should be interpreted together with product volume.

### 3. Failed machines show different operating conditions

Average operating conditions:

| Machine failure | Avg air temp | Avg process temp | Avg RPM | Avg torque | Avg tool wear |
|---|---:|---:|---:|---:|---:|
| No failure | 299.97 | 310.00 | 1540.26 | 39.63 | 106.69 |
| Failure | 300.89 | 310.29 | 1496.49 | 50.17 | 143.78 |

Failed records had higher torque and higher tool wear on average. Rotational speed was lower in failed records.

### 4. Heat dissipation failure is the most common failure type

Failure type distribution:

| Failure type | Count |
|---|---:|
| Heat Dissipation Failure | 115 |
| Overstrain Failure | 98 |
| Power Failure | 95 |
| Tool Wear Failure | 46 |
| Random Failure | 19 |

Heat dissipation failure was the most frequent failure type.

### 5. Tool wear above 200 minutes strongly increases failure risk

Failure rate by tool wear segment:

| Tool wear segment | Records | Failures | Failure rate |
|---|---:|---:|---:|
| 0-49 | 2349 | 52 | 2.21% |
| 50-99 | 2271 | 51 | 2.25% |
| 100-149 | 2290 | 52 | 2.27% |
| 150-199 | 2289 | 61 | 2.66% |
| 200+ | 801 | 123 | 15.36% |

The failure rate rises sharply when tool wear reaches 200+ minutes.

### 6. High torque is a strong failure indicator

Failure rate by torque segment:

| Torque segment | Records | Failures | Failure rate |
|---|---:|---:|---:|
| <30 | 1576 | 43 | 2.73% |
| 30-39 | 3364 | 19 | 0.56% |
| 40-49 | 3487 | 66 | 1.89% |
| 50-59 | 1334 | 111 | 8.32% |
| 60+ | 239 | 100 | 41.84% |

Torque above 60 Nm is strongly associated with machine failure.

### 7. Simple rule-based risk segmentation works well

Risk segmentation rule:

High risk: tool_wear_min >= 200 AND torque_nm >= 50
Medium risk: tool_wear_min >= 150 OR torque_nm >= 45
Low risk: all other records

Failure rate by risk segment:

| Risk segment | Records | Failures | Failure rate |
|---|---:|---:|---:|
| High risk | 121 | 66 | 54.55% |
| Medium risk | 5128 | 240 | 4.68% |
| Low risk | 4751 | 33 | 0.69% |

The rule-based segmentation separates high-risk and low-risk operating conditions clearly.

## Engineering Interpretation

The analysis suggests that torque and tool wear are the strongest practical indicators of failure risk in this dataset.

From an engineering maintenance perspective, machines operating with both high tool wear and high torque should be prioritized for inspection. A simple SQL-based risk segmentation already identifies a small group of high-risk records with a much higher failure rate than the dataset average.

## Repository Structure

industrial-maintenance-sql-analytics/
│
├── README.md
├── data/
│   ├── raw/
│   └── processed/
├── reports/
│   └── sql_results.txt
├── sql/
│   ├── 02_basic_analysis.sql
│   ├── 03_failure_analysis.sql
│   └── 04_risk_segments.sql
└── src/
    ├── load_data.py
    └── run_sql.py

## How to Run

1. Place the raw dataset in:

data/raw/ai4i2020.csv

2. Load the CSV into SQLite:

python src/load_data.py

3. Run the SQL analysis:

python src/run_sql.py

4. View the output in:

reports/sql_results.txt

## Next Steps

Possible next steps:

1. Build a machine learning model to predict machine failure.
2. Compare logistic regression, random forest and gradient boosting.
3. Evaluate the model using recall, precision and F1-score.
4. Create a simple dashboard showing failure risk by product type and operating condition.
5. Add explainability using feature importance.
