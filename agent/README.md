# Olist AI Data Analyst

**Natural Language to SQL | MySQL | Streamlit | Automated Visualization | AI Business Insights**

An independent AI-assisted data analytics portfolio project built on the publicly available Olist Brazilian E-Commerce Dataset.

This application enables users to ask business questions in Chinese, generate MySQL queries using a large language model (LLM), retrieve real database results, visualize them, and receive AI-generated business insights.

## 1. Project Overview

The project extends the existing Olist SQL and Python analysis workflow into an interactive AI-assisted analytics application.

**Key capabilities:**

- **Natural Language to SQL:** Translates Chinese business questions into MySQL SELECT queries.
- **SQL Validation:** Checks generated queries against predefined restrictions, including table access, supported SQL structures, and row limits.
- **Database Querying:** Executes validated queries using a MySQL account with SELECT-only permissions.
- **Automated Visualization:** Displays query results as tables, bar charts, line charts, or KPI cards according to basic data-type rules.
- **AI Business Insights:** Generates summaries, follow-up analysis suggestions, and limitations based on actual query results.
- **Human Confirmation:** Requires users to review generated SQL before executing it.

## 2. Technology Stack

| Component | Technology |
|---|---|
| Database | MySQL 8.0 |
| Programming | Python 3.11 |
| LLM Service | SiliconFlow API |
| SQL Generation | OpenAI-compatible Python SDK |
| SQL Validation | SQLGlot |
| Database Connection | SQLAlchemy + PyMySQL |
| Data Processing | pandas, NumPy |
| Web Interface | Streamlit |
| Environment Configuration | python-dotenv |

## 3. Application Workflow

```text
Business Question (Chinese)
          |
          v
      LLM API
          |
          v
    Generated SQL
          |
          v
     SQL Validation
          |
          v
   Human Confirmation
          |
          v
   MySQL Read-only Query
          |
          v
     pandas DataFrame
          |
          +----> Automated Visualization
          |
          +----> AI Business Insights
```

The application uses the `analysis_logistics_final` table prepared from the original Olist data through the project's SQL processing workflow.

## 4. Project Structure

```text
agent/
├── app.py                  # Streamlit interface
├── llm_sql.py              # Natural-language-to-SQL generation
├── sql_guard.py            # SQL validation
├── query_executor.py       # Database query execution
├── db.py                   # Database connectivity test
├── chart_utils.py          # Automated visualization
├── insights.py             # AI-generated business analysis
├── agent_demo.py           # Command-line demonstration
├── test_sql_guard.py       # Basic SQL validation tests
├── test_security.py        # Additional SQL restriction tests
├── requirements.txt        # Python dependencies
├── .env.example            # Configuration template
└── .gitignore              # Git ignore rules
```

## 5. Installation and Setup

### Step 1: Prepare the environment

Use Python 3.11 and install the required packages:

```bash
python -m pip install -r requirements.txt
```

### Step 2: Prepare the database

Install MySQL 8.0 and prepare the cleaned Olist analytical table using the SQL scripts in the parent repository.

The application expects a table named:

`olist_analysis.analysis_logistics_final`

The table contains order-level data, including customer location, purchase date, delivery delay, review score, item count, and order amount.

### Step 3: Configure environment variables

Copy `.env.example` to `.env` and enter your own database credentials and SiliconFlow API key.

```ini
DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=your_readonly_user
DB_PASSWORD=your_database_password
DB_NAME=olist_analysis

SILICONFLOW_API_KEY=your_api_key
SILICONFLOW_BASE_URL=https://api.siliconflow.cn/v1
SILICONFLOW_MODEL=deepseek-ai/DeepSeek-V4-Flash
```

The database account should have SELECT-only permissions on the required analytical tables. The configured model must be available to your SiliconFlow account.

Never commit real API keys or database passwords.

### Step 4: Run the application

From the `agent` directory, execute:

```bash
python -m streamlit run app.py
```

Open the local URL displayed in the terminal, typically:

`http://localhost:8501`

## 6. Example Questions

The application can handle supported questions such as:

- Which 10 Brazilian states have the highest late-delivery rates?
- Which states have the highest average order amounts?
- How many orders are included in the analytical dataset?
- Which states have the highest negative-review rates?

All generated SQL statements must pass validation, and users must confirm queries before execution.

## 7. Example Findings

During local testing, the application produced the following results:

- The analytical dataset contained **95,824 unique orders**.
- Alagoas (AL) had the highest late-delivery rate among the queried states, approximately **20.81%**.
- Maranhão (MA) followed at approximately **17.13%**.
- Automated charts and AI-generated explanations were successfully displayed in the Streamlit interface.

These findings are descriptive and depend on the prepared analytical dataset and its filtering rules. They do not establish causal relationships.

## 8. Security and Limitations

This application is a **local educational prototype, not a production-ready database agent**.

Its safeguards include:

- A database account restricted to SELECT permissions.
- SQL syntax and table-access validation.
- Restrictions on supported query structures and functions.
- A maximum SQL LIMIT of 100 rows.
- Database query execution-time controls for applicable SELECT statements.
- Human confirmation before query execution.

These measures reduce some risks but do not guarantee comprehensive SQL sandboxing. Row limits do not prevent expensive scans, and LLM-generated queries may contain logical or business-definition errors.

Automated chart selection uses simple heuristics. AI-generated business interpretations may also be incomplete or inaccurate and should be reviewed by a human analyst.

The current application is intended for local demonstration only.

## 9. Future Improvements

Potential improvements include:

- More robust SQL validation and execution isolation.
- Better recognition of date fields and chart types.
- More comprehensive business-metric definitions.
- Automated regression testing for generated SQL.
- Query logging and cost monitoring.
- Additional support for analytical tables.

## 10. Project Context

This is an independent portfolio project developed using publicly available data. It is not affiliated with Olist and does not represent production deployment or professional employment experience.

The original SQL analysis, Python notebook, and business report are available in the parent repository.
