#!/usr/bin/env python3
"""Generate the current AI task process poster (V2).

The poster is a visual summary, not an authoritative process definition.
Output: Maintanance/AI_TASK_PROCESS_POSTER.svg
PNG conversion: Utilities/Maintenance/RenderSVGToPNG.sh
"""

from html import escape
from pathlib import Path


W, H = 2400, 2400
FONT = "Hiragino Sans, Hiragino Kaku Gothic ProN, sans-serif"
INK = "#172033"
SUB = "#526071"
BG = "#f5f4ef"
BLUE = "#2255a4"
TEAL = "#087f72"
ORANGE = "#c45b18"
PURPLE = "#7352b8"
RED = "#b73535"
GOLD = "#a97812"
PINK = "#b42368"
WHITE = "#ffffff"

out: list[str] = []


def text(x, y, value, size=28, weight=400, fill=INK, anchor="start"):
    out.append(
        f'<text x="{x}" y="{y}" font-family="{FONT}" font-size="{size}" '
        f'font-weight="{weight}" fill="{fill}" text-anchor="{anchor}">{escape(value)}</text>'
    )


def box(x, y, w, h, stroke, fill=WHITE, width=5, dash=None, radius=24):
    dashed = f' stroke-dasharray="{dash}"' if dash else ""
    out.append(
        f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{radius}" '
        f'fill="{fill}" stroke="{stroke}" stroke-width="{width}"{dashed}/>'
    )


def line(x1, y1, x2, y2, color=SUB, width=5, arrow=True, dash=None):
    marker = ' marker-end="url(#arrow)"' if arrow else ""
    dashed = f' stroke-dasharray="{dash}"' if dash else ""
    out.append(
        f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" stroke="{color}" '
        f'stroke-width="{width}"{marker}{dashed}/>'
    )


def lines(x, y, values, size=24, gap=38, fill=INK, weight=400):
    for index, value in enumerate(values):
        text(x, y + index * gap, value, size=size, weight=weight, fill=fill)


def heading(x, y, value, color):
    text(x, y, value, size=34, weight=750, fill=color)


out.append(f'<rect width="100%" height="100%" fill="{BG}"/>')
out.append(
    '<defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" '
    'markerWidth="5" markerHeight="5" orient="auto">'
    f'<path d="M0,0 L10,5 L0,10 z" fill="{SUB}"/></marker></defs>'
)

# Header
text(W / 2, 82, "品質をAIと育てる仕組み", size=64, weight=800, anchor="middle")
text(
    W / 2,
    136,
    "主張と証拠を対応づけ、変更で失効した範囲だけを再検証する — V2（2026-10-11）",
    size=29,
    weight=550,
    fill=SUB,
    anchor="middle",
)

# Top lifecycle
step_y, step_h, step_w, gap = 185, 300, 350, 30
steps = [
    ("1", "目的と権限", BLUE, ["どこまで行きたいか", "今回どこまで許すか", "人が決めることを分離"]),
    ("2", "主張を置く", PURPLE, ["何が正しいと言うのか", "誰に・どの環境で", "要求と公開契約へ接続"]),
    ("3", "証拠を結ぶ", TEAL, ["test・compiler・測定", "利用scenario・履歴", "一致ではなく独立検証"]),
    ("4", "変更を見る", ORANGE, ["残る主張", "失効した主張と証拠", "新しく必要な証拠"]),
    ("5", "再検証する", BLUE, ["影響範囲だけ確認", "VerificationとValidation", "残余リスクを分離"]),
    ("6", "受け入れる", TEAL, ["根拠と正本を照合", "DONEか、次taskへ分離", "意味の単位で記録"]),
]
for index, (number, title, color, body) in enumerate(steps):
    x = 60 + index * (step_w + gap)
    box(x, step_y, step_w, step_h, color)
    out.append(f'<circle cx="{x + 45}" cy="{step_y + 48}" r="28" fill="{color}"/>')
    text(x + 45, step_y + 59, number, size=31, weight=800, fill=WHITE, anchor="middle")
    text(x + 84, step_y + 59, title, size=32, weight=750, fill=color)
    lines(x + 25, step_y + 125, ["・" + item for item in body], size=23, gap=45)
    if index < len(steps) - 1:
        line(x + step_w + 5, step_y + step_h / 2, x + step_w + gap - 7, step_y + step_h / 2, BLUE)

# Core thesis
box(60, 525, 2280, 130, PURPLE, fill="#f4f0ff", width=4)
text(1200, 579, "工程へ戻すのではなく、どの主張と証拠が失効したかを問う", size=39, weight=800, fill=PURPLE, anchor="middle")
text(1200, 625, "全部やり直さない。古いtestが通るだけで済ませない。", size=27, weight=600, fill=INK, anchor="middle")

# Claim/evidence impact map
box(60, 700, 1100, 650, PURPLE)
heading(95, 760, "主張と証拠の変更影響", PURPLE)

box(100, 805, 430, 175, BLUE, fill="#edf4ff", width=3, radius=18)
text(125, 850, "品質主張", size=30, weight=750, fill=BLUE)
lines(125, 895, ["例: 辞書順で列挙する", "例: 借用期間を越えない"], size=23, gap=38)

box(650, 805, 450, 175, TEAL, fill="#eaf8f4", width=3, radius=18)
text(675, 850, "対応する証拠", size=30, weight=750, fill=TEAL)
lines(675, 895, ["runtime / compile-pass", "compile-fail / lifetime / 測定"], size=23, gap=38)
line(535, 892, 640, 892, PURPLE)

text(95, 1035, "変更後の仕分け", size=29, weight=750, fill=INK)
impact = [
    ("残る", TEAL, "同じ意味の主張。証拠の現在性を確認"),
    ("失効", RED, "旧契約だけの主張・現在を証明しないtest"),
    ("置換", ORANGE, "要求は残るが、証拠形式を変える"),
    ("新規", PURPLE, "新しい契約に必要な主張と証拠"),
]
for index, (label, color, description) in enumerate(impact):
    y = 1075 + index * 60
    out.append(f'<rect x="100" y="{y - 30}" width="110" height="44" rx="12" fill="{color}"/>')
    text(155, y, label, size=22, weight=750, fill=WHITE, anchor="middle")
    text(235, y, description, size=23)

text(95, 1320, "主張・証拠・対象環境・時点を一組で扱う", size=25, weight=750, fill=PURPLE)

# Task handling and delegation
box(1200, 700, 1140, 650, BLUE)
heading(1235, 760, "taskへ変換して、安全に動かす", BLUE)

task_boxes = [
    ("DISCOVERY", "事実と選択肢を集める", TEAL),
    ("DECISION", "人の判断を一つだけ閉じる", ORANGE),
    ("EXECUTION", "判断ゼロで実装・検証する", BLUE),
]
for index, (name, description, color) in enumerate(task_boxes):
    x = 1240 + index * 355
    box(x, 805, 320, 125, color, fill=WHITE, width=3, radius=18)
    text(x + 160, 850, name, size=25, weight=800, fill=color, anchor="middle")
    text(x + 160, 895, description, size=20, anchor="middle")

box(1240, 955, 1065, 72, PURPLE, fill="#f4efff", width=3, radius=18)
text(1772, 984, "分解  ↔  依存整理  ↔  境界再設定  ↔  再構成", size=25, weight=800, fill=PURPLE, anchor="middle")
text(1772, 1013, "観測と受入結果に応じて、taskの形そのものを更新する", size=20, fill=INK, anchor="middle")

text(1235, 1070, "委任で固定するもの", size=28, weight=750, fill=INK)
lines(1250, 1115, ["・目的と対象", "・権限境界と正本", "・停止条件と受入条件"], size=23, gap=36)

text(1770, 1070, "担当へ任せるもの", size=28, weight=750, fill=PURPLE)
lines(1785, 1115, ["・得意領域の調査方法", "・分類と局所構成", "・反例と追加観測"], size=23, gap=36)

box(1235, 1235, 1070, 85, RED, fill="#fff2f2", width=3, radius=18)
text(1265, 1286, "STOP", size=27, weight=800, fill=RED)
text(1360, 1286, "公開判断・trade-off・権限外変更は推測で埋めず、分解へ戻す", size=21)

# Evidence and roles
box(60, 1390, 1050, 520, TEAL)
heading(95, 1450, "証拠は違う問いに答える", TEAL)
evidence = [
    ("仕様", "Test as Specification / 公開契約"),
    ("言語", "compiler診断 / lifetime / strict safety"),
    ("実行", "Debug / Release / Sanitizer / 回帰test"),
    ("性能", "自己回帰と外部比較を分離した測定"),
    ("利用", "導入・理解・実提出などのValidation"),
    ("履歴", "過去の決定は現在性を確認して使う"),
]
for index, (kind, description) in enumerate(evidence):
    y = 1510 + index * 62
    out.append(f'<rect x="95" y="{y - 31}" width="120" height="45" rx="12" fill="{TEAL}"/>')
    text(155, y, kind, size=22, weight=750, fill=WHITE, anchor="middle")
    text(245, y, description, size=24)
text(95, 1880, "AIどうしの合意を、独立した証拠の代わりにしない", size=25, weight=800, fill=TEAL)

box(1150, 1390, 1190, 520, "#7a8492", dash="14 10", width=4)
heading(1185, 1450, "だれが何を持つか", INK)
roles = [
    ("ユーザー", ORANGE, "方向・優先度・公開の約束・中止と再開"),
    ("Codex", BLUE, "会話の翻訳・task設計・統合・受入・Registry"),
    ("Claude", PURPLE, "得意領域の棚卸し・証拠収集・反例・限定実行"),
    ("第三者AI", TEAL, "独立した観点からのreviewと反証"),
]
for index, (name, color, description) in enumerate(roles):
    y = 1510 + index * 88
    out.append(f'<rect x="1185" y="{y - 38}" width="18" height="62" rx="7" fill="{color}"/>')
    text(1230, y - 6, name, size=27, weight=800, fill=color)
    text(1450, y - 6, description, size=23)

box(1185, 1840, 1120, 48, PINK, fill="#fdf0f6", width=2, radius=12)
text(1745, 1873, "作業担当と完成責任は分ける", size=25, weight=800, fill=PINK, anchor="middle")

# Relationship lesson
box(60, 1950, 2280, 245, PINK, fill="#fdf0f6", width=5)
text(95, 2010, "関係性は品質基盤の一部", size=38, weight=800, fill=PINK)
text(95, 2060, "規則だけでは、文脈の重みづけ・任せ方・合図の意味までは再現されない。", size=27, weight=500)
text(95, 2105, "対話 → 小さな実作業 → 受入 → 補正を重ねると、境界を減らしても適切に動ける領域が広がる。", size=27, weight=500)
text(95, 2150, "相手の自主性を残しながら、必要な停止点だけを共有する。", size=27, weight=750, fill=PINK)

# Footer
out.append(f'<rect x="60" y="2230" width="2280" height="120" rx="24" fill="{INK}"/>')
text(1200, 2282, "品質管理 = 主張と証拠の対応を、変更後も説明できること", size=38, weight=800, fill=WHITE, anchor="middle")
text(1200, 2325, "全工程を戻すのではなく、失効した証拠から再開する", size=26, weight=550, fill="#d7dce4", anchor="middle")

svg = f'<svg xmlns="http://www.w3.org/2000/svg" width="100%" viewBox="0 0 {W} {H}">' + "".join(out) + "</svg>"
path = Path(__file__).resolve().parents[2] / "Maintanance" / "AI_TASK_PROCESS_POSTER.svg"
path.write_text(svg, encoding="utf-8")
print(path)
