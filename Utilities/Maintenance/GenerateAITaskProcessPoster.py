#!/usr/bin/env python3
"""Codexのtask処理を主役にしたポスターを生成する。

正本: Maintanance/CODEX_TASK_OPERATION_PLAYBOOK.md / Maintanance/PROGRESS_OVERVIEW.md（Registry rules）/
AGENTS.md（Goal relevance、Routine shorthand、Ownership）/ .github/workflows/swift.yml（2026-10-09時点）。
出力: Maintanance/AI_TASK_PROCESS_POSTER.svg。PNG変換はRenderSVGToPNG.shを使う。
Python標準libraryのみ。
"""
from html import escape
from pathlib import Path

W, H = 2400, 2400
FONT = "Hiragino Sans, Hiragino Kaku Gothic ProN, sans-serif"
INK, SUB, BG = "#1d1d1f", "#555", "#f6f4ef"
USER, CODEX, CLAUDE, CHAPPY, EVID, STOP = "#c2410c", "#1d4ed8", "#7c3aed", "#047857", "#0f766e", "#b91c1c"
out = []


def text(x, y, s, size=28, weight=400, fill=INK, anchor="start"):
    out.append(f'<text x="{x}" y="{y}" font-family="{FONT}" font-size="{size}" font-weight="{weight}" '
               f'fill="{fill}" text-anchor="{anchor}">{escape(s)}</text>')


def box(x, y, w, h, stroke, fill="#ffffff", dash=None, sw=5):
    d = f' stroke-dasharray="{dash}"' if dash else ""
    out.append(f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="24" fill="{fill}" stroke="{stroke}" stroke-width="{sw}"{d}/>')


def step(n, x, y, w, h, title, body):
    box(x, y, w, h, CODEX)
    out.append(f'<circle cx="{x + 46}" cy="{y + 50}" r="30" fill="{CODEX}"/>')
    text(x + 46, y + 62, str(n), size=34, weight=800, fill="#fff", anchor="middle")
    text(x + 90, y + 64, title, size=36, weight=700, fill=CODEX)
    for i, s in enumerate(body):
        text(x + 26, y + 120 + i * 36, s, size=24)


def arrow(x1, y1, x2, y2, color=SUB):
    out.append(f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" stroke="{color}" stroke-width="6" marker-end="url(#h)"/>')


out.append(f'<rect width="100%" height="100%" fill="{BG}"/>')
out.append(f'<defs><marker id="h" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="5" markerHeight="5" '
           f'orient="auto"><path d="M0,0 L10,5 L0,10 z" fill="{SUB}"/></marker></defs>')

text(W / 2, 90, "品質をAIに任せる仕組み — Codex の task 処理", size=66, weight=800, anchor="middle")
text(W / 2, 144, "人が決めることと AI が動くことを分け、証拠がそろったときだけ「完了」にする（2026-10-09 時点・実験版）",
     size=30, weight=500, fill=SUB, anchor="middle")

# 1段目: 6つの段（ルーティーン1周）
steps = [
    ("受け取る", ["会話から抜き出す:", "・どこまで行きたいか", "・今回どこまで許すか", "内部の管理は", "ユーザーへ返さない"]),
    ("分ける", ["DISCOVERY", "　事実を集める", "DECISION", "　人の判断を1つだけ", "EXECUTION", "　判断ゼロで実行"]),
    ("つなぐ", ["必須の前提だけを辺に", "Gate: 着手前提 /", "　　　完了前提", "ready集合を求める", "中間goalへの距離で選ぶ"]),
    ("渡す", ["境界・停止条件・", "正本をつけて渡す", "Claudeへは", "　CLAUDE_TASK.md", "決めてはいけない", "ことも書く"]),
    ("受け入れる", ["diff・test・根拠と照合", "完了 / 分離 / 判断待ち", "見送り / 除外に仕分け", "作業者の「終わった」", "　≠ DONE"]),
    ("記録する", ["意味の単位で commit", "Registry が唯一の正本", "写しの要約を作らない", "履歴は消さず", "　Archived へ"]),
]
sx, sw_, gap, sy, sh = 60, 362, 21, 190, 350
for i, (t, b) in enumerate(steps):
    x = sx + i * (sw_ + gap)
    step(i + 1, x, sy, sw_, sh, t, b)
    if i < len(steps) - 1:
        arrow(x + sw_ + 2, sy + sh / 2, x + sw_ + gap - 2, sy + sh / 2, CODEX)
# ルーティーンの戻り矢印
ly = sy + sh + 30
out.append(f'<path d="M {sx + 5 * (sw_ + gap) + sw_ / 2} {sy + sh} V {ly} H {sx + sw_ / 2} V {sy + sh + 8}" '
           f'fill="none" stroke="{CODEX}" stroke-width="5" stroke-dasharray="12 9" marker-end="url(#h)"/>')
text(W / 2, ly + 40, "「ルーティーン」= この1周（どの段も空振りでよい。最新のユーザー指示が常に優先）",
     size=27, weight=600, fill=CODEX, anchor="middle")

# 2段目: 状態
yy = 640
box(60, yy, 2280, 160, "#999", fill="#ffffff", sw=3)
text(96, yy + 52, "task の状態（Registry）", size=32, weight=700, fill=INK)
chips = [("PROPOSED", "候補・まだ動かさない", "#6b7280"), ("ACTIVE", "動いてよい", CODEX), ("DONE", "証拠と正本がそろった", EVID),
         ("WAITING_USER", "人の判断待ち", USER), ("WAITING_EXTERNAL", "外部待ち", "#6b7280"),
         ("FROZEN", "明示の再開まで凍結", "#475569"), ("USER_ONLY", "AIは触らない", USER),
         ("EXCLUDED", "実施しないと確定", STOP), ("ARCHIVED", "履歴へ移動済み", "#52525b")]
cx = 96
for name, desc, c in chips:
    wch = 235
    out.append(f'<rect x="{cx}" y="{yy + 72}" width="{wch}" height="70" rx="14" fill="{c}"/>')
    text(cx + wch / 2, yy + 102, name, size=20, weight=700, fill="#fff", anchor="middle")
    text(cx + wch / 2, yy + 132, desc, size=17, weight=500, fill="#fff", anchor="middle")
    cx += wch + 11


# 2.5段目: 分解・トポロジカル判定・無駄を削る・割り当て
y4, h4, pw, pg = 830, 600, 555, 20
def panel(i, title, color, items, start=0):
    x = 60 + i * (pw + pg)
    box(x, y4, pw, h4, color)
    text(x + 30, y4 + 58, title, size=34, weight=700, fill=color)
    for k, t in enumerate(items):
        text(x + 30, y4 + 112 + start + k * 44, t, size=24)
    return x

panel(0, "タスク分解", CODEX, [
    "・到達状態と許可範囲から始める",
    "・未知を3つに分ける:",
    "　事実不足 / 人の判断 / 実行",
    "・判断は1 task に1つ（DECISION）",
    "・実行 task は判断ゼロ（EXECUTION）",
    "・固まらない候補は PROPOSED で残す",
    "・先に隣を引く: 使用箇所・仕様 test・",
    "　文書・直近の変更・過去の決定",
    "・実行中に決め事が出たら",
    "　＝ task が足りない合図。止めて分ける"])

x1 = panel(1, "トポロジカル判定", "#0369a1", [
    "・必須の前提だけを辺にする",
    "　（便利な順番は soft order へ）",
    "・前提が全部 DONE → ready 候補",
    "・凍結・判断待ち・外部待ち・",
    "　USER_ONLY は外す",
    "・cycle が出たら辺を消さず、",
    "　分け方を直す"], start=0)
# 小さなDAG
def node(cx, cy, label, c):
    out.append(f'<circle cx="{cx}" cy="{cy}" r="30" fill="{c}"/>')
    text(cx, cy + 9, label, size=24, weight=700, fill="#fff", anchor="middle")
def edge(a, b):
    out.append(f'<line x1="{a[0] + 30}" y1="{a[1]}" x2="{b[0] - 34}" y2="{b[1]}" stroke="#555" stroke-width="4" marker-end="url(#h)"/>')
gy = y4 + 470
A, B, C, D, E = (x1 + 70, gy - 40), (x1 + 70, gy + 40), (x1 + 210, gy), (x1 + 350, gy - 40), (x1 + 490, gy - 40)
edge(A, C); edge(B, C); edge(D, E)
node(*A, "A", EVID); node(*B, "B", EVID); node(*C, "C", CODEX); node(*D, "D", "#475569"); node(*E, "E", "#9ca3af")
text(x1 + 250, gy + 102, "A・B が DONE → C は ready", size=21, weight=700, fill=CODEX, anchor="middle")
text(x1 + 420, gy + 22, "D 凍結 → E は待つ", size=21, weight=700, fill="#475569", anchor="middle")

panel(2, "無駄を削る", STOP, [
    "・ready でも、今の goal に要らな",
    "　ければ動かさない（LATER / OUTSIDE）",
    "・前提が誤りなら後続ごと EXCLUDED",
    "　（除外を「達成」とみなさない）",
    "・重複・吸収は理由を残して EXCLUDED",
    "・依存辺を足しすぎない",
    "　（いらない待ちを作らない）",
    "・正本の写しの summary を作らない",
    "・ただの手順は ID にせず substep に"])

panel(3, "タスク割り当て", CLAUDE, [
    "・判断ゼロの task か、",
    "　判断材料を1つ集める task だけ",
    "・範囲・対象外・停止条件・",
    "　正本・検証・提出物を書く",
    "・担当・受入・正本が同じ実行 task は",
    "　1つの package にインライン化",
    "・新しい判断が出たら package を解除",
    "・適性は人格でなく実績で更新",
    "・委任量ではなく受入可能量で決める"])

# 3段目: 証拠の経路 / 止まる場所 / チーム
y3, h3 = 1460, 540
box(60, y3, 860, h3, EVID)
text(96, y3 + 60, "品質の証拠は、経路を変えて集める", size=34, weight=700, fill=EVID)
ev = ["Test as Specification（番号つきの仕様 test）",
      "compiler（属性を外して多構成 build で判定）",
      "CI: Debug・Release・Address Sanitizer・文書",
      "CI: 性能を base と比べ、30% 遅ければ赤",
      "git 履歴と過去の決定（逆向きの前提を先に見る）",
      "独立確認: 担当外agentの検証、第三者AIのレビュー"]
for i, s in enumerate(ev):
    text(96, y3 + 124 + i * 52, "・" + s, size=26)
text(96, y3 + h3 - 40, "AI どうしの一致を、正しさの証明にしない", size=27, weight=700, fill=EVID)

box(950, y3, 700, h3, STOP)
text(986, y3 + 60, "ここで止まって、分け直す", size=34, weight=700, fill=STOP)
st = ["未記録の公開契約を決める必要が出た",
      "性能・安全性・互換性の trade-off が出た",
      "前提が既存 test や履歴とぶつかった",
      "scope が完了判定できないほど広がった",
      "許可された変更範囲を越える必要がある"]
for i, s in enumerate(st):
    text(986, y3 + 124 + i * 52, "・" + s, size=26)
text(986, y3 + h3 - 40, "判断不足を、推測で埋めない", size=27, weight=700, fill=STOP)

box(1680, y3, 660, h3, "#999", dash="14 10", sw=4)
text(1716, y3 + 60, "だれが何を持つか", size=34, weight=700, fill=INK)
team = [(USER, "ユーザー", "方向・優先度・公開の約束・中止と再開"),
        (CODEX, "Codex", "翻訳・分解・割当・受け入れ・Registry"),
        (CLAUDE, "Claude", "境界のある調査と実行、test の第一担当"),
        (CHAPPY, "第三者AI", "独立した観点からのレビューと反証")]
for i, (c, n, d) in enumerate(team):
    yy2 = y3 + 110 + i * 100
    out.append(f'<rect x="1716" y="{yy2}" width="16" height="70" rx="6" fill="{c}"/>')
    text(1750, yy2 + 30, n, size=30, weight=700, fill=c)
    text(1750, yy2 + 64, d, size=24)


# 関係性の帯
REL = "#be185d"
box(60, 2025, 2280, 190, REL, fill="#fdf2f8")
text(96, 2090, "関係性を育てるのが大事かも", size=40, weight=800, fill=REL)
text(700, 2090, "（ユーザーの気づき。現在は観察中の仮説）", size=26, weight=500, fill=REL)
text(96, 2142, "・規則と事実を渡しても、文脈の重みづけまでは自動で再現されない。新しい会話では短いorientationが要る",
     size=26)
text(96, 2186, "・どこまで任せるか、合図の意味、相手が何を気にするか ── 対話で校正を重ねると、委任の精度が上がる",
     size=26)

# 下帯
out.append(f'<rect x="60" y="2240" width="2280" height="130" rx="24" fill="{INK}"/>')
text(W / 2, 2296, "委任は責任の放棄ではない。作業担当と完成責任を分ける。", size=40, weight=700, fill="#fff", anchor="middle")
text(W / 2, 2346, "委任する量ではなく、受け入れられる量を基準にする", size=28, weight=500, fill="#d4d4d8", anchor="middle")

svg = f'<svg xmlns="http://www.w3.org/2000/svg" width="100%" viewBox="0 0 {W} {H}">' + "".join(out) + "</svg>"
p = Path(__file__).resolve().parents[2] / "Maintanance" / "AI_TASK_PROCESS_POSTER.svg"
p.write_text(svg, encoding="utf-8")
print(p)
