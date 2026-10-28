from sql_guard import validate_sql

tests = {
    "正常查询": """
        SELECT customer_state,
               COUNT(*) AS order_count
        FROM analysis_logistics_final
        GROUP BY customer_state
LIMIT 10
    """,

    "删除数据": "DELETE FROM orders",

    "查询其他表": "SELECT * FROM customers",

    "多条语句": """
        SELECT * FROM analysis_logistics_final;
        DELETE FROM orders;
    """,
    "没有LIMIT": """
    SELECT *
    FROM analysis_logistics_final
""",

"LIMIT超过100": """
    SELECT *
    FROM analysis_logistics_final
    LIMIT 1000
""",
}

for name, sql in tests.items():
    try:
        validated = validate_sql(sql)
        print(f"[PASS] {name}: 允许执行")
    except ValueError as e:
        print(f"[BLOCKED] {name}: {e}")