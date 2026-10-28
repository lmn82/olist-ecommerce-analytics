
import os

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL
from sqlalchemy.pool import NullPool

from sql_guard import validate_sql

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
load_dotenv(os.path.join(BASE_DIR, ".env"))

db_url = URL.create(
    "mysql+pymysql",
    username=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    host=os.getenv("DB_HOST", "127.0.0.1"),
    port=int(os.getenv("DB_PORT", "3307")),
    database=os.getenv("DB_NAME", "olist_analysis"),
)

engine = create_engine(
    db_url,
    poolclass=NullPool,
    connect_args={
        "connect_timeout": 10,
        "read_timeout": 15,
        "write_timeout": 15,
    },
)


def execute_query(sql: str) -> pd.DataFrame:
    """校验 SQL 并使用只读连接执行查询。"""

    safe_sql = validate_sql(sql)

    with engine.connect() as conn:

        # 将当前数据库会话设置为只读
        conn.execute(
            text("SET SESSION TRANSACTION READ ONLY")
        )

        # 限制符合条件的 SELECT 最长执行5秒
        conn.execute(
            text("SET SESSION max_execution_time = 5000")
        )

        # 结束配置阶段的隐式事务
        conn.commit()

        # 执行已通过校验的查询
        result = pd.read_sql_query(text(safe_sql), conn)

        # 查询结束后回滚并关闭连接
        conn.rollback()

    return result


if __name__ == "__main__":

    test_sql = """
    SELECT
        customer_state,
        COUNT(*) AS order_count,
        ROUND(AVG(is_late) * 100, 2) AS late_rate
    FROM analysis_logistics_final
    GROUP BY customer_state
    ORDER BY late_rate DESC
    LIMIT 10
    """

    try:
        df = execute_query(test_sql)
        print("Query executed successfully!")
        print(df.to_string(index=False))

    except Exception as e:
        print("Query failed:", e)
