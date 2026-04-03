# Meta_AI

> 文献初筛（R + 大模型）与浏览器端人工复核 · **v1.1.0**

R 对标题/摘要批量生成 `exclude`、`exclude_prob`、`reason`；本地打开 `tools.html` 完成 RIS→CSV、复核与 `_checked.csv` 导出。数据不出本机；密钥勿入库（`.gitignore` 已含 `.Rhistory`、`.Renviron`、`.env`）。

```
RIS → tools.html(CSV) → code.R(API) → tools.html(复核) → *_checked.csv
```

---

### 使用

1. **R**：`httr`、`jsonlite`、`tidyverse`；Key 建议 `Sys.getenv("DASHSCOPE_API_KEY")`，勿写进 Git。  
2. **网页**：打开 `tools.html`（需外网加载 CDN）。  
3. **百炼**：[控制台与 API 文档](https://bailian.console.aliyun.com/cn-beijing?tab=api#/api)

### `tools.html`

| 页签 | 要点 |
|------|------|
| 介绍 | 流程说明、一键复制 R 示例 |
| RIS→CSV | 合并重复标签、预览、UTF-8 BOM 导出 |
| 人工复核 | CSV/xlsx、`TI`·`AB`、IndexedDB 记进度、行号跳转；快捷键：`←↑AW` 上一条，`→↓DS Space` 下一条，`X` 排除 |

<p align="center">
<img src="images/aliyun.png" width="48%" alt="百炼 API" />
&nbsp;
<img src="images/manual_check.png" width="48%" alt="人工复核" />
</p>

### 目录

`code.R` · `tools.html` · `Data/` · `rda/` · `images/` · `Meta_AI.Rproj`

---

**声明**：模型输出仅供初筛参考；纳入/排除以方案、全文与人工复核为准。论文中请写明流程与复核环节。
