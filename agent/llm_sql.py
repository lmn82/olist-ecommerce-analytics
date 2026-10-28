
import os
from pathlib import Path

from dotenv import load_dotenv
from openai import OpenAI

from sql_guard import validate_sql

# 读取本地环境变量
load_dotenv(Path(__file__).with_name(".env"))

client = OpenAI(
    api_key=os.getenv("SILICONFLOW_API_KEY"),
    base_url=os.getenv(
        "SILICONFLOW_BASE_URL",
        "https://api.siliconflow.cn/v1"
    ),
    timeout=60.0,
    max_retries=0,
)

# 告诉大模型：数据库有哪些字段
SCHEMA = """
Table: analysis_logistics_final

Columns:
order_id: 订单ID
purchase_date: 下单日期
customer_state: 客户所在州
delay_days: 实际送达日期减去预计送达日期
is_late: 是否超期配送，1代表超期，0代表未超期
review_score: 客户评分，1至5分
is_bad_review: 是否差评，1代表1-2星，0代表3-5星
item_count: 商品数量
order_amount: 订单金额
"""

# 对模型输出设置限制
SYSTEM_PROMPT = f"""
你是一名专业的数据分析师，负责将中文业务问题转换成MySQL 8.0查询语句。

数据库结构：
{SCHEMA}

必须遵守：
1. 只输出一条SELECT语句，不要解释。
2. 只能访问analysis_logistics_final表。
3. 只能使用已提供的字段。
4. SQL必须包含LIMIT，范围为1到100。
5. 不允许子查询、CTE、JOIN、UNION。
6. 仅使用COUNT、SUM、AVG、MIN、MAX、ROUND等基础统计函数。
7. 不要使用Markdown代码块。
8. 超期配送率 = AVG(is_late) * 100。
9. 差评率 = AVG(is_bad_review) * 100。
10. 不要编造字段或查询结果。
"""


def generate_sql(question: str) -> str:
    response = client.chat.completions.create(
        model=os.getenv("SILICONFLOW_MODEL"),
        messages=[
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": question},
        ],
        max_tokens=1024,
        stream=False,
        extra_body={"enable_thinking": False},
    )

    generated_sql = (response.choices[0].message.content or "").strip()

    if not generated_sql:
        raise ValueError("模型没有返回SQL内容")

    # 校验SQL，但暂时不执行
    return validate_sql(generated_sql)


if __name__ == "__main__":
    question = "帮我找出超期配送率最高的10个州"

    try:
        sql = generate_sql(question)
        print("用户问题：", question)
        print("\n模型生成的SQL：")
        print(sql)
        print("\nSQL校验通过，尚未执行数据库查询。")

    except Exception as e:
        print("发生错误：", type(e).__name__)
        print(str(e))
