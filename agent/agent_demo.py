
from llm_sql import generate_sql
from query_executor import execute_query

question = "帮我找出超期配送率最高的10个州"

try:
    # 第一步：大模型生成SQL
    sql = generate_sql(question)

    print("用户问题：", question)
    print("\nAI生成的SQL：")
    print(sql)

    # 第二步：确认是否执行
    confirm = input("\n是否执行这条SQL？输入 yes 确认：")

    if confirm.strip().lower() == "yes":

        # 第三步：校验并查询数据库
        df = execute_query(sql)

        print("\n查询结果：")
        print(df.to_string(index=False))

    else:
        print("已取消查询。")

except Exception as e:
    print("运行失败：", type(e).__name__, str(e))
