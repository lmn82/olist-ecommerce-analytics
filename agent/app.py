from insights import generate_insights
from chart_utils import show_auto_chart
import streamlit as st

from llm_sql import generate_sql
from query_executor import execute_query

st.set_page_config(
    page_title="Olist AI Data Analyst",
    page_icon="📊",
    layout="wide",
)

st.title("📊 Olist AI Data Analyst")
st.caption("自然语言转 SQL · MySQL 数据查询 · Python 数据分析")

st.info("当前为本地开发原型。查询执行前需要人工确认。")

if "sql" not in st.session_state:
    st.session_state.sql = None

if "question" not in st.session_state:
    st.session_state.question = None

question = st.text_input(
    "请输入你的业务问题",
    placeholder="例如：超期配送率最高的10个州是哪些？",
)

if st.button("生成 SQL", type="primary"):
    if not question.strip():
        st.warning("请先输入业务问题。")
    else:
        st.session_state.sql = None
        st.session_state.question = question

        with st.spinner("AI 正在生成 SQL..."):
            try:
                st.session_state.sql = generate_sql(question)
            except Exception as e:
                st.error(f"生成失败：{type(e).__name__}: {e}")

if st.session_state.sql:
    st.subheader("AI 生成的 SQL")
    st.code(st.session_state.sql, language="sql")

    st.warning("请检查 SQL 是否符合你的业务问题，再决定是否执行。")

    if st.button("确认并查询数据库"):
        with st.spinner("正在查询 MySQL..."):
            try:
                df = execute_query(st.session_state.sql)
                st.success("查询成功！")
                # 展示结果：数值保留两位小数
                st.dataframe(
                    df.round(2),
                    use_container_width=True
                )

                # 根据查询结果的数据类型自动选择图表
                st.subheader("📈 自动数据可视化")
                show_auto_chart(df)

                
                st.subheader("🤖 AI 业务分析")

                with st.spinner("AI 正在分析查询结果..."):
                    insight = generate_insights(
                        st.session_state.question,
                        df
                    )
                    st.markdown(insight)

            except Exception as e:
                st.error(f"查询失败：{type(e).__name__}: {e}")
