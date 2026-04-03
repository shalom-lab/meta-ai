# Meta_AI · 文献初筛与人工复核工具箱

**当前版本：V1.1.0**

面向系统综述 / Meta 分析流程的辅助工具：用 **R** 调用大模型对标题与摘要生成结构化初筛字段（`exclude`、`exclude_prob`、`reason`），再用浏览器端 **`tools.html`** 完成 **RIS→CSV**、**人工复核** 与带 BOM 的 CSV 导出。数据在本地处理；**请勿将 API Key 写入仓库**（已忽略 `.Rhistory`、`.Renviron`、`.env`）。

---

## 功能概览

| 模块 | 说明 |
|------|------|
| **R 批处理** (`code.R`) | 构建提示词、调用 DashScope 文本生成 API、解析 JSON、循环写回数据框，支持断点续跑 |
| **浏览器工具箱** (`tools.html`) | 三个标签：工具介绍 · RIS 转 CSV · 文献人工复核；IndexedDB 保存复核进度 |
| **数据目录** | `Data/` 原始表、`rda/` 中间与分块导出（大 CSV 已由 `.gitignore` 忽略时以你本地为准） |

---

## 快速开始

1. **R**：安装依赖后，在 `code.R` 中配置 API Key（建议用环境变量，勿提交真实密钥）。
2. **浏览器**：双击或用浏览器打开根目录下的 `tools.html`（需能访问 CDN：React、Tailwind、PapaParse、SheetJS 等）。
3. **流程**：数据库导出 **RIS** → `tools.html` 转 **CSV** → R 跑模型写回列 → `tools.html` **人工复核** → 导出 **`_checked.csv`**。

---

## 仓库结构

| 路径 | 说明 |
|------|------|
| `code.R` | 主脚本：提示词、`call_qwen()`、解析与循环 |
| `Data/` | 原始文献表（示例：`Global_health_*.csv`） |
| `rda/` | 中间结果与按行号切分的导出 |
| `tools.html` | 单文件 Web 工具（介绍 / RIS 转 CSV / 人工复核） |
| `images/aliyun.png` | 阿里云百炼 / API Key 相关示意 |
| `images/manual_check.png` | 人工复核界面示意 |
| `Meta_AI.Rproj` | RStudio 项目文件 |

---

## R 环境

依赖包示例：`httr`、`jsonlite`、`tidyverse`（或等价的 `dplyr` / `readr` / `purrr`）。

在 `code.R` 中请将占位符替换为你的密钥，或改为：

```r
api_key <- Sys.getenv("DASHSCOPE_API_KEY")
```

并在本机配置环境变量（**不要**把真实 Key 写进 Git）。

### 阿里云百炼（DashScope）

- **控制台与文档**：[阿里云百炼开放平台](https://bailian.console.aliyun.com/cn-beijing?tab=api#/api)
- 建议在控制台开启 **额度/用量告警**，必要时勾选 **免费额度用完即停**。
- 模型名称可在 `call_qwen()` 中修改（如 `qwen-flash`、`qwen-plus` 等）。

<p align="center">
  <img src="images/aliyun.png" alt="阿里云百炼与 API 配置示意" width="720" />
  <br />
  <sub>图：百炼 / API Key 相关操作示意（以控制台实际界面为准）</sub>
</p>

---

## 文献处理工具箱（`tools.html`）

本地打开即可使用；**所有导入数据与复核结果默认只在当前浏览器内处理**，不会上传到本项目服务器。

### 三个标签页

1. **工具介绍** — 流程说明、可一键复制的 R 示例代码、API 文档链接与风险提示。  
2. **RIS 转 CSV** — 解析 `.ris`（重复标签如多位 `AU` 会合并），预览前 50 条，导出带 **UTF-8 BOM** 的 CSV。  
3. **文献人工复核** — 导入 CSV / `.xlsx`；识别 `TI`/`Title`、`AB`/`Abstract`；展示 `exclude_prob`/`prob`、`reason` 等；人工覆盖 `exclude`；导出 **`{原文件名}_checked.csv`**；**IndexedDB** 持久化当前文件与进度；支持行号跳转与「exclude=0」快速定位。

### 人工复核快捷键（焦点不在输入框时）

| 操作 | 按键 |
|------|------|
| 上一条 | `←` `↑` `A` `W` |
| 下一条 | `→` `↓` `D` `S` `Space` |
| 标记排除 | `X` |

<p align="center">
  <img src="images/manual_check.png" alt="文献人工复核界面" width="720" />
  <br />
  <sub>图：人工复核界面示意</sub>
</p>

---

## 安全与隐私

- **API Key** 只应保存在本机环境变量或私密配置中；**不要**提交 `.Rhistory`、`.Renviron`、含密钥的脚本版本。  
- 若密钥曾误入历史提交，应在云平台 **轮换/作废** 旧 Key，并清理 Git 历史（本仓库已用 `git filter-repo` 等方式移除误提交文件示例，仍建议轮换已暴露的 Key）。

---

## 重要声明：AI 输出仅作辅助

本项目中的模型输出（含排除建议、概率、理由及衍生字段）**仅供流程中的初步参考**，不能替代：

- 研究方案与纳入排除标准  
- 对全文的阅读与团队共识  
- 法规、伦理或临床相关结论的最终判断  

请在论文或报告中如实说明 **AI 初筛 + 人工复核** 的流程；使用方对基于本工具结果所做的决定自行负责。

---

如在协作或二次开发中引用本仓库，请同步告知合作者上述限制，避免将「模型标签」误解为已完成的系统评价筛选结论。
