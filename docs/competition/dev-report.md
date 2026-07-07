# MoonMarkdown 开发报告

## 项目概述

MoonMarkdown 是一个纯 MoonBit 实现的 CommonMark 规范 Markdown 解析器。项目目标是为 MoonBit 生态提供一个规范兼容、零依赖、跨平台的 Markdown 到 HTML 转换库。

## 开发过程

### 阶段一：项目初始化和类型设计

- 安装 MoonBit 工具链（moon 0.1.20260529, moonc v0.9.3）
- 使用 `moon new` 创建项目骨架
- 设计 AST 类型体系：Block（12 种变体）和 Inline（11 种变体）
- 实现工具模块：字符分类、行分割器、HTML 转义表

### 阶段二：块级解析器

按复杂度递增顺序实现：

1. ATX 标题解析（# 前缀识别、级别计数、尾部 # 剥离）
2. 分隔线解析（--- / *** / ___ 及空格变体）
3. 围栏代码块（``` 和 ~~~、info string 提取、嵌套 backtick 处理）
4. 缩进代码块（4+ 空格前缀检测）
5. 段落解析（行累积、块起始检测、Setext 标题下划线）
6. 引用块（> 前缀剥离、递归解析、懒续行）
7. 列表解析（有序/无序、start 数字提取、tight/loose 判定）
8. HTML 块（7 种类型条件识别）
9. 链接引用定义（label/url/title 提取）

### 阶段三：行内解析器

实现字符级递归下降解析：

1. 反斜杠转义（CommonMark 定义的 ASCII 标点集）
2. 代码片段（变长 backtick 开闭匹配、空白规范化）
3. 强调算法（分隔符栈、左/右 flanking 判定、* / _ 双路径）
4. 链接解析（行内 + 引用、嵌套括号 URL、可选 title）
5. 图片解析（! 前缀 + 链接语法复用）
6. 自动链接（<url> 和 <email> 格式）
7. 硬/软换行判别

### 阶段四：HTML 渲染器

- 块级元素到 HTML 标签的映射
- 行内元素渲染（含 HTML 实体自动转义）
- 容器块递归渲染
- 代码语法高亮（MoonBit / JavaScript / Python / Rust 关键词匹配）
- CSS 类名定制框架

### 阶段五：GFM 扩展

- 管道表格（分隔符行解析、对齐方向检测、行列拆分）
- 任务列表（- [x] / - [ ] 复选框识别）
- 删除线（~~ 开闭匹配、内联解析嵌套）

### 阶段六：测试和质量保证

- 55 个黑盒测试覆盖所有公开 API
- 6 个白盒测试模块覆盖内部解析函数（100+ 附加测试）
- CommonMark Spec 测试框架集成（651 个用例提取框架已就绪，完整 Spec 兼容率提升为后续工作）
- CI/CD 工作流配置（GitHub Actions：check + build + test，已通过）

## 技术架构

```
Source Text
  → Line Scanner (行分割、\r\n 标准化)
  → Block Parser (行级结构识别、递归容器解析)
  → Inline Parser (字符级扫描、分隔符栈匹配)
  → HTML Renderer (AST 遍历、转义、格式化)
  → HTML String
```

核心设计决策：
- 两阶段解析（块优先、行内后处理），与 cmark 参考实现一致
- AST 而非 token 流输出，保持结构信息便于扩展
- StringView 兼容处理（自定义 trim 函数避免 MoonBit 类型陷阱）
- 上下文使用 Array[(String, String)] 而非 Map，简化跨模块传递

## 遇到的挑战

1. **MoonBit String 索引返回 UInt16**：`s[i]` 不是 Char 而是 UTF-16 码元，需要 `s.substring(start=i, end=i+1)` 取单字符
2. **trim_start() 返回 StringView**：不可直接调用 substring/contains，需要自定义 ltrim/rtrim
3. **跨包 struct 可见性**：需要 `pub(all) struct` 和 `pub` 字段才能从其他包构造
4. **强调算法复杂性**：分隔符栈匹配涉及左右 flanking 判定、多层嵌套、* 和 _ 的不同规则
5. **列表模糊边界**：有序列表数字、空行分割、缩进敏感等原因导致需要多轮调优

## 测试结果

| 测试类型 | 数量 | 状态 |
|---------|------|------|
| 公开 API 黑盒测试 | 55 | 全部通过 |
| 块解析白盒测试 | 25+ | 全部通过 |
| 行内解析白盒测试 | 20+ | 全部通过 |
| 渲染器白盒测试 | 30+ | 全部通过 |
| 工具模块白盒测试 | 25+ | 全部通过 |
| GFM 扩展白盒测试 | 17+ | 全部通过 |
| **合计** | **161+** | **全部通过** |

编译状态：0 errors, 0 warnings（通过 `moon check --deny-warn` 和 `moon test --deny-warn` 严格检查）

## 项目统计

- MoonBit 源码：约 4,380 行
- 源文件数：28 个 .mbt 文件
- 包数量：8 个（types、util、block、inline、render、ext、tests、cmd/main）
- Git 提交：30 次
- 依赖：零外部依赖

## 后续计划

- Spec 合规率提升至 400+/651（当前框架已就绪，需调试性能瓶颈）
- 支持更多 GFM 扩展（脚注、定义列表）
- 与 MoonTemplate 集成形成静态站点生成工具链
