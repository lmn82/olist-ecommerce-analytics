
import pandas as pd
import streamlit as st
from pandas.api.types import (
    is_numeric_dtype,
    is_datetime64_any_dtype,
)


def show_auto_chart(df: pd.DataFrame):
    """根据查询结果自动选择简单的可视化方式。"""

    if df.empty:
        st.info("查询结果为空，没有可展示的数据。")
        return

    numeric_cols = [
        col for col in df.columns
        if is_numeric_dtype(df[col])
    ]

    other_cols = [
        col for col in df.columns
        if col not in numeric_cols
    ]

    # 情况1：查询只返回单个数值
    if len(df) == 1 and len(numeric_cols) == 1:
        col = numeric_cols[0]
        st.metric(
            label=col,
            value=f"{df[col].iloc[0]:,.2f}"
        )
        return

    # 情况2：包含一个分类字段和数值指标
    if other_cols and numeric_cols:
        x_col = other_cols[0]
        y_col = numeric_cols[0]

        st.subheader(f"{y_col} 按 {x_col} 对比")

        # 如果是时间字段，优先画折线图
        if is_datetime64_any_dtype(df[x_col]):
            st.line_chart(
                df,
                x=x_col,
                y=y_col
            )
        else:
            st.bar_chart(
                df,
                x=x_col,
                y=y_col,
                sort=False
            )
        return

    # 情况3：只有数值列，暂不自动生成图表
    st.info("当前结果不适合自动绘图，请查看数据表。")
