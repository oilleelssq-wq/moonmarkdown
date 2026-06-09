# MoonMarkdown 项目申报书

## 基本信息

| 项目 | 内容 |
|------|------|
| **项目名称** | MoonMarkdown：CommonMark 规范 Markdown 解析器 |
| **参赛者** | wangyichao |
| **GitHub 仓库** | https://github.com/wangyichao/moonmarkdown |
| **GitLink 仓库** | https://gitlink.org.cn/wangyichao/moonmarkdown |
| **项目方向** | MoonBit 基础库 / 文档解析基础设施 |
| **是否为移植项目** | 否（原创实现，参考 CommonMark 规范 0.31.2） |
| **许可证** | MIT |

## 项目简介

MoonMarkdown 是一个**纯 MoonBit 实现**的 CommonMark 规范 Markdown 解析器，将 Markdown 文本转换为标准 HTML 输出。项目面向需要在 MoonBit 生态中处理文档、渲染内容或构建文档工具的开发者，提供块级解析（标题、段落、代码块、引用、列表等）和行内解析（强调、链接、代码片段、转义等）能力，并支持 GFM 扩展（表格、任务列表、删除线）。

MoonBit 生态中现有 `@mizchi/markdown`（侧重增量解析速度，牺牲规范兼容性）和 `Cmark.mbt`（C 语言 FFI 封装），尚无**纯 MoonBit 实现且追求 CommonMark 规范完整兼容**的解析器。本项目填补这一空白。

## 核心功能范围

- CommonMark 块级元素：ATX/Setext 标题、段落、围栏/缩进代码块、分隔线、引用块、有序/无序列表、HTML 块、链接引用定义；
- CommonMark 行内元素：反斜杠转义、代码片段、强调（斜体/粗体/粗斜体）、链接、图片、自动链接、HTML 实体、硬/软换行；
- GFM 扩展：管道表格（含对齐）、任务列表、删除线、裸 URL 自动链接；
- 完整 HTML 渲染器（含 HTML 实体转义、可定制 CSS 类名）；
- 代码语法高亮（支持 MoonBit / JavaScript / Python / Rust）；
- CLI 命令行工具；
- 集成 CommonMark 官方 542 个 Spec 测试用例，持续追踪兼容率；
- CI/CD 持续集成（构建、测试、Spec 兼容检查）。

## 差异化价值

| 对比维度 | @mizchi/markdown | Cmark.mbt | MoonMarkdown |
|---------|-----------------|-----------|--------------|
| 实现方式 | 纯 MoonBit CST | C 语言 FFI | **纯 MoonBit AST** |
| 规范兼容 | 207/542 (38%) | 542/542 (通过 C) | **目标 400+/542 (74%+)** |
| 平台支持 | Wasm/JS | 受限 | **Native / Wasm / JS** |
| 扩展 | GFM 部分 | 无 | **GFM 完整** |
| 编译产物 | 大 | 小（依赖 C） | **小，零外部依赖** |

## 项目规模

预计 3,500-5,000 有效 MoonBit 代码行，含完整测试套件和 Spec 合规测试。

## 实现计划

1. **已完成**：AST 类型定义、块级解析器（标题/段落/代码块/引用/列表）、行内解析器（转义/代码片段/强调/链接/自动链接）、HTML 渲染器、GFM 表格/任务列表/删除线
2. **进行中**：CommonMark Spec 测试集成、合规率提升
3. **计划**：代码高亮、CLI 完善、文档和示例

## 适用场景

- MoonBit 项目文档渲染
- 静态站点生成器
- IDE / 编辑器 Markdown 预览
- 文档处理工具链
- MoonBit 生态基础设施
