# Olist E-commerce Analytics

**SQL Data Analysis | Python Visualization | Customer Segmentation | Logistics & Customer Satisfaction**

An independent data analytics portfolio project based on the public Olist Brazilian E-Commerce Dataset.

This project explores product-category sales performance, customer repurchase behavior, RFM segmentation, and the relationship between delivery delays and customer satisfaction.

## 1. Project Overview

This project demonstrates an end-to-end analytical workflow, including:

- Data cleaning and validation using MySQL 8.0
- Multi-table joins and order-level aggregation
- Sales contribution and customer behavior analysis
- RFM customer segmentation
- Exploratory data analysis and visualization using Python
- Business insights and actionable recommendations

The analysis is conducted using publicly available historical data and does not represent an actual company internship.

## 2. Tools & Technologies

| Tool | Application |
|---|---|
| MySQL 8.0 | Data cleaning, joins, aggregations, window functions |
| Python | Data analysis and statistical exploration |
| pandas & NumPy | Data processing and feature engineering |
| Matplotlib | Business data visualization |
| Kaggle | Reproducible Python Notebook |
| GitHub | Project documentation and source code |

## 3. SQL Analysis Modules

The `SQL/` directory contains the following scripts:

| Script | Description |
|---|---|
| `05_product_category_analysis_clean.sql` | Product-category sales and cumulative revenue contribution |
| `06_customer_repurchase_analysis_clean.sql` | Customer repurchase rate and purchase frequency |
| `07_rfm_customer_segmentation_clean.sql` | Recency, Frequency, Monetary analysis and customer segmentation |
| `08_prepare_reviews_clean.sql` | Review deduplication and quality validation |
| `09_build_analysis_dataset_portfolio.sql` | Construction of the order-level logistics analysis dataset |

## 4. Key Findings

### 4.1 Product Sales Concentration

- The largest sales category is `beleza_saude` (health and beauty), accounting for **9.33%** of product sales.
- The top 18 product categories account for **81.29%** of cumulative sales value under the analysis definition.
- Product-category performance is measured using item prices, excluding freight charges.

### 4.2 Customer Repurchase Behavior

- The analysis covers **93,358 purchasing customers** and **96,478 delivered orders**.
- **2,801 customers** made at least two purchases during the observation period.
- The cumulative customer repurchase rate is **3.00%**.

### 4.3 RFM Customer Segmentation

Customers are segmented using purchase recency, frequency, and monetary value.

The median customer monetary value is **89.73**.

| Customer Segment | Customers | Average Monetary Value |
|---|---:|---:|
| Other Customers | 46,679 | 47.26 |
| One-time High Spend | 44,336 | 232.66 |
| Inactive Repeat High Spend | 1,821 | 296.49 |
| Recent Repeat High Spend | 522 | 306.68 |

Segment thresholds are analytical choices rather than universally optimal business rules.

### 4.4 Logistics & Customer Satisfaction

The logistics dataset contains **95,824 delivered orders** with valid delivery dates and review scores.

- Overall late-delivery rate: **6.66%**
- Overall negative review rate: **12.81%**
- On-time delivery negative review rate: **9.27%**
- Delays of 1–3 days: **32.13%**
- Delays of 4–7 days: **67.68%**
- Delays of 8–14 days: **80.15%**
- Delays of 15+ days: **78.35%**

The results indicate a strong association between delivery delays and negative customer reviews.

Across the four selected states (SP, RJ, MG, and RS), late orders consistently have higher negative review rates than on-time orders.

## 5. Python Analysis on Kaggle

The Python Notebook includes:

- Dataset validation
- Exploratory data analysis
- Order amount distribution and logarithmic transformation
- Delivery delay group analysis
- Regional negative review rate comparison
- Business recommendations and limitations

**[View the Kaggle Notebook](https://www.kaggle.com/code/kunnyand/olist-e-commerce-logistics-customer-satisfaction)**

## 6. Data Preparation & Reproducibility

The original data comes from the publicly available Olist Brazilian E-Commerce Dataset.

The project uses MySQL to prepare analytical tables and Python to explore the cleaned data.

The portfolio SQL scripts for review deduplication and logistics dataset construction have been checked against the existing analysis tables. The rebuilt logistics dataset matched the original order-level dataset across 95,824 orders and nine fields.

The Kaggle Notebook reproduces the Python analysis using an attached cleaned CSV dataset.

**Current reproducibility scope:** The verified SQL scripts operate on an already imported MySQL database. The complete raw-data import and initialization workflow is not yet included in this repository.

The SQL scripts should be reviewed for execution order and existing table names before rerunning them.

## 7. Business Recommendations

- Investigate early-warning systems for potentially delayed orders.
- Prioritize further operational investigation in regions with relatively high late-delivery and negative review rates.
- Use RFM segmentation to guide customer retention experiments.
- Monitor high-contribution product categories while considering profitability and operational costs.

These recommendations are hypotheses for further business testing, not proven causal effects.

## 8. Limitations

- The data is historical and publicly available.
- Repurchase rates depend on the observation period and are not equivalent to cohort retention rates.
- Product sales contribution is not the same as profit contribution.
- The logistics analysis excludes orders without the required delivery or review information.
- Observational relationships do not establish causality.
- Full end-to-end reproduction from original CSV files requires additional setup and import documentation.

## 9. AI-Powered Data Analytics Agent

In addition to traditional SQL and Python analysis, this project includes a locally developed **AI-powered data analytics prototype**.

The application integrates an LLM API, MySQL, SQLGlot, pandas, and Streamlit to support an interactive analytical workflow:

**Natural Language Question → SQL Generation → SQL Validation → Human Confirmation → MySQL Query → Visualization → AI Business Insights**

### Key Features

- **Text-to-SQL:** Converts Chinese business questions into MySQL SELECT queries.
- **SQL Validation:** Applies predefined query restrictions and checks table access.
- **Read-only Data Access:** Uses a database account with SELECT-only permissions.
- **Automated Visualization:** Generates bar charts and KPI cards based on query results.
- **AI Business Insights:** Summarizes findings, suggests further analysis, and highlights data limitations.
- **Interactive Interface:** Provides a local Streamlit web application.

### Example

**Question:** Which 10 states have the highest late-delivery rates?

The application generates SQL, retrieves results from the prepared Olist database, and displays a ranked table, chart, and AI-generated interpretation.

### Technology Stack

Python · MySQL 8.0 · SiliconFlow LLM API · SQLGlot · SQLAlchemy · pandas · Streamlit

**[View the AI Agent Source Code and Setup Guide](agent/README.md)**

**Development Status:** Functional local prototype. Not production-ready or publicly deployed.

The Agent uses the prepared logistics dataset. Its SQL restrictions and AI-generated business interpretations require human review.
