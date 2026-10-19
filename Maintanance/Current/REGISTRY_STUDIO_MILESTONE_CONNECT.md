# Registry Studio：タスクを到達点へつなぐ操作の追加（OPS-061）

> **確定範囲（2026-10-17、OPS-066試行）** 受入済み：タスク編集欄の「到達点へつなぐ」（行き先は版のENDか途中カード、版ゲートは拒否）。Fable自己受入（ユーザー指示）。証拠：commit `9ddb150f`、verify.cjs・sync・stub DOMスモークテスト。未確認：Safariでの実表示・実クリック・保存JSONの実ダウンロード。次の確認点：ユーザー試用で画面を一度触る。本書の「関係の種類」の記述は同日のOPS-062で失効。状態の正本はRegistry。

## TL;DR（人間向け）

線のないタスクも版のENDや途中カードへつなげられる操作を追加し、ユーザー指定の自己受入で完了した記録。版ゲートへの直接接続は拒否し、正本への反映は別の照合手順で扱う。当時の4種類の関係選択は後続変更で失効しており、Safari操作・保存JSONの実ダウンロードは未確認。

2026-10-17 / Author, implementation, verification and acceptance: Fable (deputy, OPS-044). Parent permanent OPS-048 (Studio, Astra). User present. The confirmed-scope block above and the 姫 appendix below remain original evidence.

<a id="発端とユーザー指示"></a>
## Trigger and user instruction

User: 「これなんだけど、タスクをENDにつなぐことができないんだよね」. Investigation found 「前提を追加」 candidates only include tasks; milestones could only be reached by 「つなぎ替え」 of existing edges, leaving edge-free tasks without an entry (README also said 「マイルストーン編集は未実装」). Fable offered direct Registry rows or a Studio operation; user: 「うん。自分でタスク作って、自分で確認して、自分で受け入れて」.

Self-acceptance is this explicit exception, not a general change to deputy principle 「自身の実装成果の独立受入は他者へ」.

<a id="範囲"></a>
## Scope

- Included: `Maintanance/RegistryApp/index.html` editor/data operations; `verify.cjs` checks; `README.md` procedure.
- Excluded: `sync.py`/`registry.json` structure; Registry canonicalization (import AI adds saved JSON connections to Registry; Studio does not read/write Registry), milestone cards/column edits and HEAD.

<a id="実装"></a>
## Implementation

- `addMilestoneRelation(data, taskId, targetId, relation)` clones data, appends `{prerequisite: task, successor: 到達点, relation, constraint: '', conditionReview: '相談待ち', source: {path: '', quote: ''}}` to `milestoneRelations`, passes `check()` and returns without changing source.
  - Targets: version `END-x.y.z` or intermediate `MS-*`; reject `GATE-x.y.z` under `Milestones/README.md` 「版ゲートへ入る線は、そのフォルダのENDからだけ」. User rationale: tasks act within versions; END identifies the version. GATE joins versions and is not a task destination.
  - Initially choosing GATE silently rewired to END; user 「GATEにつないじゃだめ」 led to removing/rejecting GATE that day.
  - Relation types limited to `required / material / after / resume`; `stage` is backbone-only.
  - Reject duplicate edges and unknown task/milestone endpoints.
- Editor for selected task lists 「このタスクがつながる到達点」 (END/MS unchanged, existing `removeRelation`), selects 「到達点（版のENDか途中のカード。版ゲートへは直接つなげない）」 and 「関係」, and provides 「到達点へつなぐ」. Show END destination gate, e.g. 「END-0.5.4（→ GATE-0.6.0）」; default first unmet END. Block `formDirty` using existing guidance. Addition marks `dirty`, redraws and appears as `milestoneRelations` in save `changes`.
- Options from `doc.milestones` exclude `GATE-*` (include `END-*`/`MS-*`). END is hidden in drawing but selectable as destination.

<a id="検証"></a>
## Verification

- Added `verify.cjs` checks: add `END-0.5.4` with `required`, pass `check`; reject `GATE-0.6.0`; preserve source/baseline; `delta()` contains `milestoneRelations`; allow direct `MS-VALIDATION`/`material`; reject duplicates/`stage`/unknown endpoints; `graphData()` draws edge to following gate (`shownFor` = END).
- `sync.py` with bundled marked and Codex runtime node v24.19.0 completed; all verify PASS; `--check` agrees.
- Stub DOM smoke: `editor()` for `OPS-059` shows headings/button/「まだありません。」. Options: `MS-DOC, END-0.5.3（→ GATE-0.5.4）, END-0.5.4（→ GATE-0.6.0）, MS-VALIDATION, END-0.6.0（→ GATE-0.7.0）, MS-SPI, END-0.7.0（→ GATE-0.8.0）, MS-HUMAN, END-0.8.0（→ GATE-0.9.0）, MS-QUALITY, END-0.9.0（→ GATE-1.0.0）, END-1.0.0`; no GATE; default `END-0.5.4`, four relations. Click `END-0.5.4`/`required`: count 32→33, `END-0.5.4 / required / 相談待ち`, `dirty=true`. Direct `GATE-0.6.0` rejects with 「版ゲートへはタスクをつなげません。…その版のEND-x.y.zを選んでください。」. Initial GATE→END implementation had already checked duplicate 「この接続は既にあります」 and `formDirty` 「先に入力の『変更を適用』を押してください。」; those paths unchanged.
- Unverified: actual Safari display/clicks/save-JSON download, same limits as existing features.

## 受入（Fable、ユーザー指示による自己受入）

2026-10-17。上記の実装が範囲内に収まり、verify・sync・スモークテストの証拠が揃っていること、既存の検査（列の一本道、版ゲートへ入るのはENDだけ、各版フォルダのDAG）を壊していないこと、Registry への自動反映を加えていないことを確認して受け入れる。Safari 実表示はユーザー試用で確認する。OPS-061 は DONE、親 OPS-048 は ACTIVE のまま。

<a id="取り込み側の手順この操作で保存されたjsonを受けるaiへ"></a>
## Import procedure for AI receiving this operation’s saved JSON

Rows in `changes`/`milestoneRelations` with `conditionReview: 相談待ち` and empty `source.path` are newly added Studio connections. Decide condition text with user, then add a row `| 接続元 | 接続先（END-*またはMS-*） | 関係 | 制約 |` to Registry 「マイルストーン接続」 and run `sync.py`. A line does not authorize automatic start, unfreezing or deciding for the user.

<a id="後続2026-10-17ops-062"></a>
## Follow-up (2026-10-17, OPS-062)

That day the user, advised by Astra, abolished relation types. This document's 「関係の種類は required / material / after / resume に限る」 is superseded; 「到達点へつなぐ」 now selects destination only. Conditions live in constraint text. See [OPS-062 canonical](REGISTRY_STUDIO_SINGLE_LINE_KIND.md).

## 根拠と更新条件の追記（2026-10-17 / 姫・Opus 5.5 / OPS-076第2区切り）

入力版`56005d06d1ad97ed544cda914e12ee725692dc58`。本文・旧記録は変えていない。各行は「その版で確かめた主張・方法」。確認は`git`の読み取りだけで、ブラウザ・製品テスト・CIは実行していない。

| 主張 | 確認方法と結果 | 更新のきっかけ |
| --- | --- | --- |
| 範囲の`Maintanance/RegistryApp/index.html` | 本版にはない。`bbddb7ff3`（2026-10-17）で`index.template.html`へ改名（サーバー実行型への移行）。事実は古くなったが、実装の判断は変わらない | Studioのファイル構成の変更 |
| 版ゲートへの接続を拒否する | `index.template.html`の本版336行目に「版ゲートへはタスクをつなげません」、341行目に`function addMilestoneRelation` | 該当関数・文言の変更 |
| 関係の種類4つ | 冒頭ブロックと後続節のとおりOPS-062で失効（下の文書の追記を参照） | — |

Safari実表示は未確認のまま（本文どおり）。
