# リリースゲート手前の判断を一度に出す — 試作と提案

2026-10-16 / Claude（姫、Opus 5.5）。ユーザーの依頼（「未採番で、あすとらさんに提案タスクとして、なんかやってみて」）による試作。採番待ち`CP-20261016-006`。
Astraへの提案であり、方式の採用・実装の確定ではない。

## 困りごと

判断を各正本に書くようになり、散らばっていて追いにくい（ユーザー、同日）。AIはセッションをまたいで覚えていないので、
作業やリリース判断の前に「関係する判断を漏れなく拾う」ことと「置き換わった古い判断を使わない」ことが難しい。

## 提案の形

範囲を「リリースゲートの上流」に切る。ゲートIDを渡すと、Registryの依存とマイルストーン関係をさかのぼり、上流のtaskを次の3つに分けて出す。

- **A. ユーザーの判断待ち（未決）**：`USER_ONLY`、または担当にUserを含み未完了のtask。
- **B. 判断の言及がある上流task**：条件・詳細欄に判断を示す語があるtask。中身は正本の原文で確かめる。
- **C. ゲートへの直接の条件**：ゲートに入る辺の制約文。

ゲートで切ると、範囲が機械的に決まり、使う瞬間（リリース判断）もはっきりする。判断座標の草案でいう「保留を確定として扱う決断」の前に、
何が決まっていて何が保留かを一枚で見られる。

## 試作の結果（MS-060、`registry.json`のRegistry SHA-256先頭 `4b8468e7c6c7`）

```text
# MS-060 の上流 6件

## A. ユーザーの判断待ち（未決） 1
- DOC-037 [WAITING_USER] [DECISION] 赤黒木本文の受入判断 — 担当:User — 語:保留

## B. 判断の言及がある上流task（原文で確認） 4
- RELEASE-078 [PROPOSED] [DISCOVERY] 0.6.0開始条件と現行提供区分の再照合 — 担当:Codex — 語:ユーザー判断
- DOC-035 [ACTIVE] [EXECUTION] 0.6.0全公開対象の文書初版確認 — 担当:Astra — 語:ユーザー指示
- DOC-034 [ACTIVE] [EXECUTION] 赤黒木4型の本文完成と派生成果の同期 — 担当:Astra — 語:ユーザー指示
- DOC-033 [ACTIVE] [DISCOVERY] 赤黒木4型アウトラインと現行契約の照合 — 担当:Astra — 語:ユーザー指示・保留

## C. ゲートへの直接の条件
- RELEASE-078 → MS-060 (material) RELEASE-078で現行提供区分・文書状態と旧開始条件を照合し、その結果を本書の判断材料に接続する。
- MS-DOC → MS-060 (material) 赤黒木の本文準備も必要な文書入力へ接続する
- DOC-035 → MS-060 (required) DOC-035の全公開対象の文書初版確認を、本書の文書初版条件の必須入力とする。
```

同じ方法で、MS-070は上流12件（Aが5件）、QUALITY-001は上流24件（Aが11件）になった。

## 分かった限界

1. **Bは雑音が多い。** 「ユーザー指示」は「ユーザーの指示で登録した」という経緯の語で、判断そのものではない。語の照合だけでは、判断と経緯を分けられない。
2. **正本の中の判断は見ていない。** 読むのはRegistry行の条件・詳細欄だけで、詳細正本に書かれた判断は拾えない。
3. **置き換えの関係が分からない。** 古い判断と新しい判断を区別する手がかりがない。

## 次の一歩の案（Astraの判断で）

1. 判断の場所に、決まった書式の印を添える：`（判断; 対象=<task ID>; 日付=YYYY-MM-DD; 判断者=…; 要旨=…; 置き換え=<前の場所>）`。
   配置維持の印と同じ考え方で、正本は散らばったまま、一覧は生成する写しにする。
2. 上の試作のBを「印」に置き換え、詳細正本の本文からも印を拾う。印のない昔の判断は、語の照合で「候補」として別枠に出す。
3. Registry Studioに「ゲートの判断」タブを足す（`registry.json`に依存の辺がすでにあるので、SQLiteは不要）。Git履歴を横断して探す必要が出たら、
   OPS-036のTask履歴索引へ広げる。

## 試作スクリプト

一時ディレクトリで動かしたもの（repositoryの道具としては追加していない）。`python3 digest.py MS-060`のように、repositoryの直下で実行する。

```python
import json, re, sys, collections
d = json.load(open('Maintanance/RegistryApp/registry.json'))
gate = sys.argv[1]
nodes = {t['id']: t for t in d['tasks']} | {m['id']: m for m in d['milestones']}
edges = [(e['prerequisite'], e['successor'], e.get('flow') or e.get('relation'), e.get('constraint','')) for e in d['edges']] + \
        [(e['prerequisite'], e['successor'], e['relation'], e.get('constraint','')) for e in d['milestoneRelations']]
into = collections.defaultdict(list)
for a, b, k, c in edges: into[b].append((a, k, c))
# upstream walk; stop at other gates' upstream? no: full closure
seen, order, q = set(), [], [gate]
while q:
    n = q.pop(0)
    for a, k, c in into[n]:
        if a not in seen: seen.add(a); order.append(a); q.append(a)
pat = re.compile(r'(ユーザー(?:が|の)?(?:判断|決定|承認|指示|明示)|判断はユーザー|ユーザー判断|USER_ONLY|未決|保留)')
print(f'# {gate} の上流 {len(order)}件')
user_open, user_done, ai = [], [], []
for n in order:
    t = nodes.get(n, {'state':'?','owner':'?','item':'?','detail':'','condition':''})
    text = (t.get('condition') or '') + ' ' + (t.get('detail') or '')
    hits = sorted(set(m.group(0) for m in pat.finditer(text)))
    row = (n, t['state'], t.get('owner',''), t['item'], hits)
    if t['state'] == 'USER_ONLY' or 'User' in str(t.get('owner','')) and t['state'] not in ('DONE',):
        user_open.append(row)
    elif hits: user_done.append(row)
for title, rows in [('A. ユーザーの判断待ち（未決）', user_open), ('B. 判断の言及がある上流task（原文で確認）', user_done)]:
    print('\n##', title, len(rows))
    for n, s, o, i, h in rows: print(f'- {n} [{s}] {i} — 担当:{o}' + (f' — 語:{"・".join(h)}' if h else ''))
print('\n## C. ゲートへの直接の条件')
for a, k, c in into[gate]: print(f'- {a} → {gate} ({k}) {c[:70]}')
```
