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
text(W / 2, 82, "判断を減らし、正しく止まるtask管理", size=60, weight=800, anchor="middle")
text(
    W / 2,
    136,
    "偶有的な判断を消し、本質的な判断だけを残す — V2（2026-10-11）",
    size=29,
    weight=550,
    fill=SUB,
    anchor="middle",
)

# Top lifecycle: the three principles and their execution consequences
step_y, step_h, step_w, gap = 185, 300, 350, 30
steps = [
    ("1", "疑義を検知", TEAL, ["新しい判断・依存", "前提・証拠の変化", "継続条件への影響"]),
    ("2", "先に保留", RED, ["影響範囲だけ止める", "確証を待たない", "graph更新より先"]),
    ("3", "判断を整理", ORANGE, ["偶有的判断を消す", "本質的判断を残す", "判断不要を見分ける"]),
    ("4", "境界を分ける", PURPLE, ["taskかsubstepか", "成果・状態・受入", "一判断を一つにする"]),
    ("5", "graphを再構成", BLUE, ["前提と後続を探す", "Flowを分類する", "readyを再計算"]),
    ("6", "再開を確認", PINK, ["readyは成立したか", "委任は有効か", "成立範囲だけ再開"]),
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
text(1200, 579, "判断を増やさない。taskを増やす前に、判断が本当に残るかを問う。", size=39, weight=800, fill=PURPLE, anchor="middle")
text(1200, 625, "細かな規則ではなく、判断整理・task境界・graph再構成から行動を導く。", size=27, weight=600, fill=INK, anchor="middle")

# Judgment classification
box(60, 700, 1100, 650, ORANGE)
heading(95, 760, "1. 何を判断する必要があるか", ORANGE)

judgments = [
    ("本質的な判断", RED, ["整理しても消えない", "権限を持つ者が決める"]),
    ("偶有的な判断", ORANGE, ["未整理だから判断に見える", "整理で自明になれば消える"]),
    ("判断不要", TEAL, ["前提と方針が閉じている", "実行・検証へ渡せる"]),
]
for index, (name, color, body) in enumerate(judgments):
    y = 810 + index * 165
    box(100, y, 1015, 135, color, fill=WHITE, width=3, radius=18)
    text(135, y + 48, name, size=29, weight=800, fill=color)
    lines(470, y + 42, ["・" + item for item in body], size=22, gap=38)

box(100, 1290, 1015, 40, PURPLE, fill="#f4efff", width=2, radius=12)
text(607, 1318, "偶有的判断を消し、本質的判断だけを露出させる", size=23, weight=800, fill=PURPLE, anchor="middle")

# Task boundary and graph reconstruction
box(1200, 700, 1140, 650, BLUE)
heading(1235, 760, "2. 何を独立したtaskにするか", BLUE)

boundary = [
    ("task", "独立した成果・状態・依存・判断・証拠・受入", BLUE),
    ("substep", "独立した状態や受入を持たない実行手順", TEAL),
]
for index, (name, description, color) in enumerate(boundary):
    y = 810 + index * 125
    box(1240, y, 1065, 95, color, fill=WHITE, width=3, radius=18)
    text(1270, y + 58, name, size=27, weight=800, fill=color)
    text(1480, y + 58, description, size=22)

text(1235, 1085, "3. graphへ組み込み、readyを再計算", size=30, weight=800, fill=PURPLE)
graph_steps = [
    ("前提", "新taskが必要とするもの"),
    ("後続", "新taskの成果を待つもの"),
    ("Flow", "SEQUENCE / PARALLEL_JOIN / soft order"),
    ("再計算", "cycle・critical path・ready集合"),
]
for index, (label, description) in enumerate(graph_steps):
    y = 1135 + index * 47
    text(1260, y, label, size=22, weight=800, fill=PURPLE)
    text(1400, y, description, size=22)

# Ready and flow
box(60, 1390, 1100, 520, TEAL)
heading(95, 1450, "継続条件は実行中も評価する", TEAL)

flows = [
    ("SEQUENCE", RED, "新しい必須前提ならreadyを失い、停止"),
    ("PARALLEL_JOIN", BLUE, "独立部分は進める。合流前に完了しない"),
    ("soft order", GOLD, "readyは保つ。優先順だけを見直す"),
]
for index, (name, color, description) in enumerate(flows):
    y = 1530 + index * 95
    box(95, y - 50, 250, 65, color, fill=WHITE, width=3, radius=15)
    text(220, y - 8, name, size=22, weight=800, fill=color, anchor="middle")
    text(385, y - 8, description, size=22)

box(95, 1820, 1020, 62, RED, fill="#fff2f2", width=3, radius=16)
text(605, 1860, "疑義が生じたら先に保留。graph更新は停止後に行う。", size=24, weight=800, fill=RED, anchor="middle")

# Authority gate
box(1200, 1390, 1140, 520, "#7a8492", dash="14 10", width=4)
heading(1235, 1450, "実行には二つの成立条件が要る", INK)

box(1240, 1495, 500, 165, BLUE, fill="#edf4ff", width=4, radius=20)
text(1490, 1550, "task graph", size=31, weight=800, fill=BLUE, anchor="middle")
text(1490, 1600, "依存上、今もreadyか", size=23, anchor="middle")

box(1800, 1495, 500, 165, PINK, fill="#fdf0f6", width=4, radius=20)
text(2050, 1550, "委任", size=31, weight=800, fill=PINK, anchor="middle")
text(2050, 1600, "実行権限は今も有効か", size=23, anchor="middle")

text(1770, 1705, "両方が成立した範囲だけ実行・再開する", size=30, weight=800, fill=INK, anchor="middle")
text(1770, 1755, "readyでも委任がなければ止まる", size=23, fill=PINK, anchor="middle")
text(1770, 1795, "委任があってもreadyでなければ止まる", size=23, fill=RED, anchor="middle")

box(1240, 1830, 1060, 55, PURPLE, fill="#f4efff", width=2, radius=14)
text(1770, 1866, "停止は失敗ではなく、成立条件を復元するための保留", size=23, weight=800, fill=PURPLE, anchor="middle")

# Return path
box(60, 1950, 2280, 245, PINK, fill="#fdf0f6", width=5)
text(95, 2010, "疎でも漏らさない戻り道", size=38, weight=800, fill=PINK)
text(95, 2060, "新しい判断や依存によって継続条件を信頼できなくなったら、影響範囲を保留して分解へ戻る。", size=27, weight=500)
text(95, 2105, "疑義検知 → 先に保留 → 判断整理 → task分解 → graph再構成 → ready・委任確認 → 再開", size=27, weight=750, fill=PURPLE)
text(95, 2150, "原理から停止と再開を導き、本質的な判断だけを人へ返す。", size=27, weight=750, fill=PINK)

# Footer
out.append(f'<rect x="60" y="2230" width="2280" height="120" rx="24" fill="{INK}"/>')
text(1200, 2282, "task管理 = 偶有的判断を消し、本質的判断だけを残すこと", size=38, weight=800, fill=WHITE, anchor="middle")
text(1200, 2325, "実行・停止・再開は、継続条件と委任から導く", size=26, weight=550, fill="#d7dce4", anchor="middle")

svg = f'<svg xmlns="http://www.w3.org/2000/svg" width="100%" viewBox="0 0 {W} {H}">' + "".join(out) + "</svg>"
path = Path(__file__).resolve().parents[2] / "Maintanance" / "AI_TASK_PROCESS_POSTER.svg"
path.write_text(svg, encoding="utf-8")
print(path)
