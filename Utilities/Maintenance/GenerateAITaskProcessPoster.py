#!/usr/bin/env python3
"""Generate the current AI task process poster (V3).

The poster is a visual summary, not an authoritative process definition.
Output: Maintanance/Archived/Posters/AI_TASK_PROCESS_POSTER.svg
"""

from html import escape
from pathlib import Path


W, H = 2400, 2400
FONT = "Hiragino Sans, Hiragino Kaku Gothic ProN, sans-serif"
INK, SUB, BG, WHITE = "#172033", "#526071", "#f5f4ef", "#ffffff"
BLUE, TEAL, ORANGE = "#2255a4", "#087f72", "#c45b18"
PURPLE, RED, GOLD, PINK = "#7352b8", "#b73535", "#a97812", "#b42368"
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
text(W / 2, 76, "事実へ接続し、次の仕事を成立させる", 58, 800, anchor="middle")
text(W / 2, 127, "協働を自走させるtask運用 — V3（2026-10-12）", 29, 600, SUB, "middle")

# The full collaboration cycle
step_y, step_h, step_w, gap = 175, 270, 260, 25
steps = [
    ("1", "現在地", TEAL, ["Registryから復元", "正本へ接続"]),
    ("2", "答えの所在", GOLD, ["誰・何が答えるか", "推測を分離"]),
    ("3", "必須前提", RED, ["欠けた条件を発見", "疑義なら先に保留"]),
    ("4", "判断整理", ORANGE, ["偶有的判断を消す", "本質だけ残す"]),
    ("5", "task / graph", BLUE, ["境界と依存を作る", "readyを再計算"]),
    ("6", "実行・委譲", PINK, ["一つの受入境界", "権限内で進める"]),
    ("7", "証拠・受入", PURPLE, ["成立を確かめる", "反証も保存"]),
    ("8", "次を成立", TEAL, ["必要性を再評価", "次の一周へ"]),
]
for index, (number, title, color, body) in enumerate(steps):
    x = 55 + index * (step_w + gap)
    box(x, step_y, step_w, step_h, color, width=4, radius=20)
    out.append(f'<circle cx="{x + 38}" cy="{step_y + 42}" r="25" fill="{color}"/>')
    text(x + 38, step_y + 52, number, 27, 800, WHITE, "middle")
    text(x + 74, step_y + 53, title, 27, 750, color)
    lines(x + 18, step_y + 120, ["・" + item for item in body], 20, 43)
    if index < len(steps) - 1:
        line(x + step_w + 4, step_y + step_h / 2, x + step_w + gap - 6, step_y + step_h / 2, BLUE, 4)

box(55, 475, 2290, 120, PURPLE, "#f4f0ff", 4)
text(1200, 523, "Routine = 受入から次の仕事の成立までを、自律的につなぐinterface", 35, 800, PURPLE, "middle")
text(1200, 565, "手順の短縮ではない。現在地・成立条件・権限を保ちながら協働を前進させる。", 25, 600, INK, "middle")

# Answer sources
box(55, 640, 1110, 610, GOLD)
heading(90, 700, "答えの所在を先に捉える", GOLD)
sources = [
    ("repository / Git", "何が存在し、何が起きたか"),
    ("compiler / test / benchmark", "実際に成立し、どう振る舞うか"),
    ("一次仕様・外部正本", "外部契約が何を要求するか"),
    ("作者・権限者", "意図、優先、公開判断は何か"),
    ("まだ誰も持たない", "仮説として残し、観測方法を作る"),
]
for index, (source, answer) in enumerate(sources):
    y = 755 + index * 88
    box(90, y, 1035, 68, GOLD if index != 4 else RED, width=2, radius=14)
    text(115, y + 43, source, 19, 800, GOLD if index != 4 else RED)
    text(535, y + 43, answer, 20)
text(607, 1218, "答えを持たない者同士の合意を、答えとしない。", 25, 800, RED, "middle")

# Registry as index
box(1200, 640, 1145, 610, BLUE)
heading(1235, 700, "Task Registryは協働の索引", BLUE)
text(1235, 746, "台帳を埋めること自体が目的ではない。", 24, 650, SUB)
index_items = [
    ("現在地", "何が進行中で、何が止まっているか"),
    ("前提", "何が成立すれば着手・継続できるか"),
    ("証拠", "どの正本・結果へ辿れば確かめられるか"),
    ("権限", "誰が決め、誰が実行できるか"),
    ("次の仕事", "いま必要な作業を導けるか"),
]
for index, (label, description) in enumerate(index_items):
    y = 800 + index * 76
    text(1260, y, label, 23, 800, BLUE)
    text(1435, y, description, 22)
box(1240, 1175, 1060, 48, RED, "#fff2f2", 2, radius=12)
text(1770, 1207, "圧縮後に次を導けないなら、履歴が残っていても失敗", 22, 800, RED, "middle")

# Core model
box(55, 1300, 1110, 500, ORANGE)
heading(90, 1360, "中心モデル（運用しながら検証中）", ORANGE)
box(90, 1410, 1035, 135, BLUE, "#edf4ff", 3, radius=18)
text(120, 1458, "依存の最小性", 28, 800, BLUE)
lines(120, 1500, ["後続の成果・検証・受入に必要な前提だけへ依存する"], 21)
box(90, 1570, 1035, 135, TEAL, "#edfaf7", 3, radius=18)
text(120, 1618, "受入境界の局所性", 28, 800, TEAL)
lines(120, 1660, ["何を成立させ、何で受け入れ、失敗時どこへ戻るかを閉じる"], 21)
text(607, 1760, "分解で観測し、整理後は削除・移動・inlineで境界を回復する", 22, 750, PURPLE, "middle")

# Execution gate and return path
box(1200, 1300, 1145, 500, PINK)
heading(1235, 1360, "実行と再開は、二条件で決まる", PINK)
box(1240, 1415, 490, 135, BLUE, "#edf4ff", 3, radius=18)
text(1485, 1468, "ready", 30, 800, BLUE, "middle")
text(1485, 1512, "依存上、今も成立する", 21, anchor="middle")
box(1810, 1415, 490, 135, PINK, "#fdf0f6", 3, radius=18)
text(2055, 1468, "委任", 30, 800, PINK, "middle")
text(2055, 1512, "実行権限が今も有効", 21, anchor="middle")
text(1770, 1605, "両方が成立する範囲だけ実行する", 29, 800, INK, "middle")
text(1770, 1653, "前提が疑わしければ先に保留し、答えの所在へ戻る", 23, 750, RED, "middle")
text(1770, 1700, "訂正は会話だけでなく、正本・task・依頼・受入へ反映する", 22, 650, PURPLE, "middle")
text(1770, 1750, "停止は失敗ではなく、成立条件と主導権を守る動作", 22, 750, PINK, "middle")

# Compression check and footer
box(55, 1845, 2290, 300, PURPLE, "#f4f0ff", 5)
text(90, 1905, "圧縮・アーカイブ後も復元できるか", 35, 800, PURPLE)
checks = ["現在地", "必須前提", "証拠への経路", "判断・実行権限", "次に必要な仕事"]
for index, item in enumerate(checks):
    x = 105 + index * 445
    box(x, 1950, 380, 80, TEAL, WHITE, 3, radius=16)
    text(x + 190, 2001, item, 22, 800, TEAL, "middle")
text(1200, 2090, "全部を保存するのではなく、協働を再開し次へ進める経路を保存する。", 27, 750, INK, "middle")

out.append(f'<rect x="55" y="2190" width="2290" height="150" rx="24" fill="{INK}"/>')
text(1200, 2250, "task運用 = 事実へ接続し、欠けた前提と判断を整理し、次の仕事を成立させること", 32, 800, WHITE, "middle")
text(1200, 2298, "Registryはそのための索引。Routineは一周を呼び出すinterface。", 25, 600, "#d7dce4", "middle")

svg = f'<svg xmlns="http://www.w3.org/2000/svg" width="100%" viewBox="0 0 {W} {H}">' + "".join(out) + "</svg>"
path = Path(__file__).resolve().parents[2] / "Maintanance" / "Archived" / "Posters" / "AI_TASK_PROCESS_POSTER.svg"
path.write_text(svg, encoding="utf-8")
print(path)
