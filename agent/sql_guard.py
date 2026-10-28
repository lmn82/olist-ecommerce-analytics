import sqlglot
from sqlglot import exp

# 第一版只开放这张经过验证的订单级分析表
ALLOWED_TABLES = {"analysis_logistics_final"}

def validate_sql(sql: str) -> str:
    """
    校验 AI 生成的 SQL。
    只允许一条 SELECT 查询，且只能读取白名单表。
    """
    try:
        statements = sqlglot.parse(sql, read="mysql")
    except sqlglot.errors.ParseError as e:
        raise ValueError("SQL 语法解析失败") from e

    if len(statements) != 1 or statements[0] is None:
        raise ValueError("只允许执行一条 SQL")

    statement = statements[0]

    if not isinstance(statement, exp.Select):
        raise ValueError("只允许 SELECT 查询")

    # 限制危险的语句结构
    forbidden = (
        exp.Insert,
        exp.Update,
        exp.Delete,
        exp.Drop,
        exp.Create,
        exp.Alter,
        exp.Command,
        exp.Union,
        exp.Intersect,
        exp.Except,
        exp.Subquery,
        exp.With,
    )

    for node_type in forbidden:
        if statement.find(node_type):
            raise ValueError("包含暂不支持的 SQL 结构")

    # 禁止访问白名单以外的数据表
    tables = {
        table.name.lower()
        for table in statement.find_all(exp.Table)
    }

    if not tables or not tables.issubset(ALLOWED_TABLES):
        raise ValueError("SQL 访问了未授权的数据表")

    # 禁止任意数据库限定名
    for table in statement.find_all(exp.Table):
        if table.db or table.catalog:
            raise ValueError("暂不允许跨数据库查询")

    # 第一版不允许调用数据库函数
    # 但放行常用统计函数
    allowed_functions = {
        "COUNT", "SUM", "AVG", "MIN", "MAX", "ROUND"
    }

    for func in statement.find_all(exp.Func):
        name = func.sql_name().upper()
        if name not in allowed_functions:
            raise ValueError(f"暂不允许使用函数: {name}")

        # 禁止 SELECT INTO 等额外操作
    if statement.args.get("into"):
        raise ValueError("不允许 SELECT INTO")

    if statement.args.get("locks"):
        raise ValueError("不允许加锁查询")

    # 必须设置 LIMIT，且最多返回100行
    limit = statement.args.get("limit")

    if limit is None:
        raise ValueError("查询必须包含 LIMIT")

    limit_value = limit.expression

    if not isinstance(limit_value, exp.Literal) or not limit_value.is_int:
        raise ValueError("LIMIT 必须是整数")

    row_limit = int(limit_value.this)

    if not 1 <= row_limit <= 100:
        raise ValueError("LIMIT 必须在1到100之间")

    return statement.sql(dialect="mysql")