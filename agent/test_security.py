
from sql_guard import validate_sql

# 这里只测试 SQL 校验器，不会执行数据库查询
tests = [
    (
        "正常统计查询",
        """SELECT customer_state, COUNT(*) AS n
           FROM analysis_logistics_final
           GROUP BY customer_state
           LIMIT 10""",
        True,
    ),
    (
        "删除数据",
        "DELETE FROM analysis_logistics_final",
        False,
    ),
    (
        "跨数据库访问",
        "SELECT * FROM mysql.user LIMIT 10",
        False,
    ),
    (
        "加锁查询",
        "SELECT * FROM analysis_logistics_final FOR UPDATE LIMIT 10",
        False,
    ),
    (
        "子查询",
        """SELECT *
           FROM analysis_logistics_final
           WHERE order_id IN (
               SELECT order_id FROM analysis_logistics_final
           )
           LIMIT 10""",
        False,
    ),
    (
        "SELECT INTO 文件",
        """SELECT customer_state
           INTO OUTFILE '/tmp/test.csv'
           FROM analysis_logistics_final
           LIMIT 10""",
        False,
    ),
]

for name, sql, expected in tests:
    try:
        validate_sql(sql)
        allowed = True
    except (ValueError, Exception) as e:
        allowed = False
        print(f"{name}: 被拒绝，原因：{e}")

    status = "PASS" if allowed == expected else "FAIL"
    print(f"[{status}] {name}")
