import os
import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL

# 读取与 db.py 同一目录下的 .env 文件
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
load_dotenv(os.path.join(BASE_DIR, ".env"))

# 创建 MySQL 数据库连接
db_url = URL.create(
    "mysql+pymysql",
    username=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    host=os.getenv("DB_HOST", "127.0.0.1"),
    port=int(os.getenv("DB_PORT", "3306")),
    database=os.getenv("DB_NAME"),
)

engine = create_engine(db_url, pool_pre_ping=True)

# 测试只读查询
sql = """
SELECT
    customer_state,
    COUNT(*) AS order_count,
    ROUND(AVG(is_late) * 100, 2) AS late_rate
FROM analysis_logistics_final
GROUP BY customer_state
ORDER BY late_rate DESC
LIMIT 10
"""

with engine.connect() as conn:
    result = pd.read_sql_query(text(sql), conn)

print("MySQL connection successful!")
print(result.to_string(index=False))