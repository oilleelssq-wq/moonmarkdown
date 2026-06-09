#!/usr/bin/env python3
"""Generate the project proposal PDF using fpdf2."""

from fpdf import FPDF


class ProposalPDF(FPDF):
    def __init__(self):
        super().__init__("P", "mm", "A4")
        self.set_auto_page_break(True, 20)
        # Add a built-in CJK-compatible font
        self.add_font("NotoSansCJK", "", r"C:\Windows\Fonts\msyh.ttc", uni=True)
        self.add_font("NotoSansCJK", "B", r"C:\Windows\Fonts\msyhbd.ttc", uni=True)

    def header(self):
        self.set_font("NotoSansCJK", "B", 10)
        self.set_text_color(128, 128, 128)
        self.cell(0, 6, "MoonMarkdown - 2026 MoonBit OSC 项目申报书", align="C")
        self.ln(8)

    def footer(self):
        self.set_y(-15)
        self.set_font("NotoSansCJK", "", 8)
        self.set_text_color(128, 128, 128)
        self.cell(0, 10, f"第 {self.page_no()} 页", align="C")

    def section_title(self, title):
        self.set_font("NotoSansCJK", "B", 14)
        self.set_text_color(0, 51, 102)
        self.cell(0, 10, title)
        self.ln(10)

    def body_text(self, text):
        self.set_font("NotoSansCJK", "", 10)
        self.set_text_color(51, 51, 51)
        self.multi_cell(0, 6, text)
        self.ln(2)

    def key_value(self, key, value):
        self.set_font("NotoSansCJK", "B", 10)
        self.set_text_color(0, 0, 0)
        self.cell(40, 7, key + "：")
        self.set_font("NotoSansCJK", "", 10)
        self.cell(0, 7, value)
        self.ln(7)

    def table_header(self, cols, widths):
        self.set_font("NotoSansCJK", "B", 9)
        self.set_fill_color(0, 51, 102)
        self.set_text_color(255, 255, 255)
        for i, col in enumerate(cols):
            self.cell(widths[i], 8, col, border=1, fill=True, align="C")
        self.ln()

    def table_row(self, cells, widths):
        self.set_font("NotoSansCJK", "", 9)
        self.set_text_color(51, 51, 51)
        for i, cell in enumerate(cells):
            self.cell(widths[i], 7, cell, border=1, align="C")
        self.ln()


def build_pdf():
    pdf = ProposalPDF()
    pdf.add_page()

    # Title
    pdf.set_font("NotoSansCJK", "B", 22)
    pdf.set_text_color(0, 51, 102)
    pdf.cell(0, 14, "MoonMarkdown 项目申报书", align="C")
    pdf.ln(12)

    pdf.set_font("NotoSansCJK", "", 11)
    pdf.set_text_color(80, 80, 80)
    pdf.cell(0, 8, "2026 MoonBit 国产开源生态竞赛", align="C")
    pdf.ln(16)

    # Basic Info
    pdf.section_title("一、基本信息")
    pdf.key_value("项目名称", "MoonMarkdown：CommonMark 规范 Markdown 解析器")
    pdf.key_value("参赛者", "wangyichao")
    pdf.key_value("GitHub 仓库", "https://github.com/oilleelssq-wq/moonmarkdown")
    pdf.key_value("GitLink 仓库", "（待创建镜像）")
    pdf.key_value("项目方向", "MoonBit 基础库 / 文档解析基础设施")
    pdf.key_value("是否移植项目", "否（原创实现，参考 CommonMark 规范 0.31.2）")
    pdf.key_value("许可证", "MIT")
    pdf.ln(4)

    # Project Introduction
    pdf.section_title("二、项目简介")
    pdf.body_text(
        "MoonMarkdown 是一个纯 MoonBit 实现的 CommonMark 规范 Markdown 解析器，"
        "将 Markdown 文本转换为标准 HTML 输出。项目面向需要在 MoonBit 生态中处理文档、"
        "渲染内容或构建文档工具的开发者，提供块级解析（标题、段落、代码块、引用、列表等）"
        "和行内解析（强调、链接、代码片段、转义等）能力，并支持 GFM 扩展（表格、任务列表、删除线）。"
    )
    pdf.body_text(
        "MoonBit 生态中现有 @mizchi/markdown（侧重增量解析速度，牺牲规范兼容性，仅通过 38% CommonMark 测试）"
        "和 Cmark.mbt（C 语言 FFI 封装），尚无纯 MoonBit 实现且追求规范完整兼容的解析器。本项目填补这一空白。"
    )

    # Core Features
    pdf.section_title("三、核心功能")
    features = [
        "CommonMark 块级元素：ATX/Setext 标题、段落、围栏/缩进代码块、分隔线、引用块、有序/无序列表、HTML 块、链接引用定义",
        "CommonMark 行内元素：反斜杠转义、代码片段、强调（斜体/粗体/粗斜体）、链接、图片、自动链接、HTML 实体、硬/软换行",
        "GFM 扩展：管道表格（含对齐）、任务列表、删除线、裸 URL 自动链接",
        "完整 HTML 渲染器（含 HTML 实体转义，可定制 CSS 类名）",
        "代码语法高亮（支持 MoonBit / JavaScript / Python / Rust）",
        "CLI 命令行工具",
        "集成 CommonMark 官方 651 个 Spec 测试用例",
        "CI/CD 持续集成（构建、测试、Spec 兼容检查）",
    ]
    for f in features:
        pdf.set_font("NotoSansCJK", "", 10)
        pdf.set_text_color(51, 51, 51)
        pdf.cell(6, 6, "  •")
        pdf.cell(0, 6, f)
        pdf.ln(6)
    pdf.ln(4)

    # Differentiation
    pdf.section_title("四、差异化价值")
    cols = ["对比维度", "@mizchi/markdown", "Cmark.mbt", "MoonMarkdown"]
    widths = [36, 42, 42, 42]
    pdf.table_header(cols, widths)
    rows = [
        ["实现方式", "纯 MoonBit CST", "C 语言 FFI", "纯 MoonBit AST"],
        ["规范兼容", "207/651 (38%)", "651/651 (C 实现)", "目标 400+/651"],
        ["平台支持", "Wasm/JS", "受限", "Native/Wasm/JS"],
        ["扩展", "GFM 部分", "无", "GFM 完整"],
        ["外部依赖", "有", "依赖 C 库", "零依赖"],
    ]
    for row in rows:
        pdf.table_row(row, widths)
    pdf.ln(4)

    # Scale
    pdf.section_title("五、项目规模与实现进度")
    pdf.body_text(
        "预计 3,500-5,000 有效 MoonBit 代码行（含完整测试套件）。"
        "当前已完成 AST 类型定义、块级解析器、行内解析器、HTML 渲染器、GFM 扩展、"
        "代码高亮、CLI、Spec 测试框架和 CI 配置，13 个基础测试全部通过。"
    )

    # Use Cases
    pdf.section_title("六、适用场景")
    cases = [
        "MoonBit 项目文档渲染与静态站点生成",
        "IDE / 编辑器 Markdown 预览功能",
        "文档处理工具链与 CI 文档自动化",
        "MoonBit 生态基础设施（为其他工具提供 Markdown 解析能力）",
    ]
    for c in cases:
        pdf.set_font("NotoSansCJK", "", 10)
        pdf.set_text_color(51, 51, 51)
        pdf.cell(6, 6, "  •")
        pdf.cell(0, 6, c)
        pdf.ln(6)

    # Output
    pdf.output("docs/competition/MoonMarkdown项目申报书.pdf")
    print("PDF generated: docs/competition/MoonMarkdown项目申报书.pdf")


if __name__ == "__main__":
    build_pdf()
