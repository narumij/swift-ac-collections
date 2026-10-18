# マイルストーン接続の線の種類を廃止し、条件を制約文へ移す（OPS-062）

## TL;DR（人間向け）

到達点へつなぐ線の種類を廃止し、その意味を正本の条件文へ移した変更記録。線の統一、3列表、旧形式JSONの明示拒否を受入済みで、後の根拠追記では当時15行だった表が確認版で28行に増えたことを区別している。線だけで着手・完了を判定せず、Safariの見え方と旧JSONの画面表示は未確認。

> **Settled scope (2026-10-17, OPS-066 trial)** Accepted: abolishing the line kinds, making the Registry 「マイルストーン接続」 table 3 columns with the conditions of its 15 rows written out, and explicitly rejecting old-format JSON. Self-accepted by Fable (user instruction). Evidence: commit `9ddb150f`, 22 verify.cjs items, `sync.py --check`, stub DOM. Unconfirmed: how the single-colour lines look in Safari, and the screen display when an old JSON is read via 「JSONを開く」. Next check: confirm once in Safari the line display and loading an old JSON. The Registry is canonical for state.

2026-10-17 / canonical, implementation, verification and acceptance by Fable (acting coordinator, OPS-044). Parent is the permanent task OPS-048 (Studio). With the user present; Astra advised.

<a id="発端と方針"></a>
## Origin and policy

The user: 「今回は5種類の制度化ではなく、線の種類を減らしたい。既存の接続と条件の意味を失わず、種類を廃止できるか確認してほしい。種類でしか表現されていない条件があれば、正本の条件文へ移す案を出して。Studioの線は一種類に統一する方向で」 (rather than institutionalizing 5 kinds, reduce the line kinds; check whether the kinds can be abolished without losing the meaning of existing connections and conditions; propose moving any condition expressed only by a kind into the canonical condition text; unify Studio's lines into one kind).

Fable's investigation: the kinds were in 15 rows of the Registry 「マイルストーン接続」 (required 8, material 5, after 1, resume 1) and 17 rows of 「ゲート経路の関係種類」 (stage 15, required 1, after 1). In Studio they were used only for colour, width, dashes and the legend, not for placement or the structure checks (a single row, only END enters a version gate, the version-folder DAG). The meanings carried only by kinds were "must be completed before this arrival point" for the 8 required rows and "decision material, not binding pass/fail" for the 5 material rows. after/resume were already in the text. The 2 rows of the row line keep their meaning through card bodies and placement.

Astra's advice: avoid making "a connection means required completion by default" the default (it would leave a mechanism of reading conditions from lines). The preface should say 「接続はタスクと到達点の関係を示す。完了・着手・再開の条件は各行の制約文に記載し、線の有無や向きだけでは判定しない」, and the 8 required rows should also state it on each row. Lines after arrival may look the same. Lines show where a relation is; conditions are text.

User supplement: include the HTML, checks and generated outputs in the same commit. Old-format edit JSON must not silently lose conditions; if unsupported, reject it explicitly. Self-acceptance is fine (on condition of leaving browser checks and unconfirmed items). Unify the skeleton's width too.

<a id="範囲"></a>
## Scope

- Targets: the Registry 「マイルストーン接続」 and 「ゲート経路の関係種類」, `Milestones/README.md`, `RegistryApp/sync.py`, `index.html`, `verify.cjs`, `README.md`, and Studio's generated outputs.
- Out of scope: the Flow of task-to-task dependencies (SEQUENCE / PARALLEL_JOIN) is a separate axis and unchanged. Editing arrival-point cards and rows; HEAD.

<a id="正本の変更"></a>
## Canonical changes

- 「マイルストーン接続」: replaced the preface with Astra's sentence and made the table 3 columns instead of 4 (source, target, constraint). The 15 constraint sentences now begin with 「この到達点の前に完了が必要。」 (old required, 8 rows), 「判断材料。…合否を縛る必須条件ではない。」 (old material, 5 rows), and 「到達後。…の前提ではない。」 (old after/resume, 2 rows). The pasted rows of RELEASE-072/075/076 (`\| … \|`) were turned into sentences. Wording is as in the original.
- 「ゲート経路の関係種類」: the whole section abolished. Row lines are made from placement alone.
- The originals (the 4-column table and the relation-kind table) are saved verbatim in [Archived](../Archived/TASK_REGISTRY_RELATION_KINDS_2026-10-17.md) and reachable from the Registry's 「過去の記録への入口」.
- `Milestones/README.md`: references to line kinds changed to 「線に種類はない。条件はRegistryの制約文と各カードの本文」.

<a id="studioの変更"></a>
## Studio changes

- `sync.py`: reads the connection table as 3 columns (4 columns stop with "expected 3 columns"). Removed reading and validating relation kinds. Row lines have no kind, and their constraint text is 「接続はゲートの配置から生成。条件は各カードの本文。」. Removed kind notation from the diff report.
- `index.html`: `check()` dropped the kind checks and rejects JSON with a `relation` key (both current and baseline) with 「旧形式（線の種類あり）のJSONは読み込めません。…」. Loading (「JSONを開く」) and the pre-save check go through the same `check()`, so the screen shows 「読み込めません：旧形式…」. Lines are unified into one colour and one width (1.5), and the skeleton's width difference was removed too. Dashed task-to-task dependencies (PARALLEL_JOIN) are kept as a separate axis. The legend says 「線は関係の所在、条件は文章」. Whether a line is a connection to an arrival point or a task dependency is judged by `isMilestoneLink` (whether an end point is an arrival point), without relying on kinds. Removed the relation choice from 「到達点へつなぐ」; it now only selects the arrival point. Removed version gates from the successor candidates when rewiring, and data operations also reject rewiring to a version gate.
- `README.md`: procedures and explanations rewritten without kinds.

<a id="検証"></a>
## Verification

- `verify.cjs`: rewrote the checks that looked at kinds. Added checks: rejecting data with a `relation` key (current and baseline), added connections have no `relation`, all displayed lines to arrival points have the same flow, and rewiring rejects version gates and allows END. The structure checks (a single row, only from END, the version-folder DAG) pass unchanged.
- `sync.py`: completed, all verify items PASS, `--check` no drift, no `relation` key in `registry.json`.
- Stub DOM smoke test (`editor()` from OPS-059): the arrival-point choices are only END and MS, with no relation choice field. Connected to END-0.5.4 (32 → 33, no `relation`, waiting for consultation, dirty). `milestoneRelations` in the save diff. Deleting from the list returns to the original 32. RELEASE-084's line can be rewired to END-0.6.0, and rewiring to GATE-0.6.0 is rejected. An old JSON with `relation` is rejected by `check()`. All 25 displayed lines to arrival points are PARALLEL_JOIN without `relation`.
- Unverified: the real display in Safari (how a single colour looks), real clicks, real download of saved JSON, and the screen display when an old JSON is read via 「JSONを開く」. Same constraints as existing features; checked through user trial.

<a id="受入fableユーザー指示による自己受入"></a>
## Acceptance (Fable, self-acceptance by user instruction)

2026-10-17. Accepted after confirming: conditions are written on every row without relying on a default, as Astra advised; the originals are saved verbatim and an entry point is left; the canonical, generator, screen, checks and generated outputs are aligned in one unit; the old format is explicitly rejected; and Flow is untouched. The real display in Safari is left unconfirmed. OPS-062 is DONE; the parent OPS-048 stays ACTIVE.

<a id="取り込み側の手順studioから保存されたjsonを受けるaiへ"></a>
## Procedure on the importing side (for an AI receiving JSON saved from Studio)

If `milestoneRelations` in `changes` has rows with `conditionReview: 相談待ち` and an empty `source.path`, they are connections newly added in Studio. Decide the condition text with the user, write a sentence beginning with one of 「この到達点の前に完了が必要。」, 「判断材料。」 or 「到達後。」, add a row `| 接続元 | 接続先（END-*またはMS-*） | 制約 |` to the Registry 「マイルストーン接続」, and run `sync.py`. A line alone does not mean automatic start, unfreezing, or making a decision on someone's behalf.


<a id="根拠と更新条件の追記2026-10-17--姫opus-55--ops-076第2区切り"></a>
## Grounds and update conditions, appended (2026-10-17 / Hime, Opus 5.5 / OPS-076 break 2)

Input version `56005d06d1ad97ed544cda914e12ee725692dc58`. The body and old records were not changed. Each row is "a claim checked in that version, and the method". Checked only by reading with `git`; no browser, product tests or CI were run.

| Claim | Check method and result | Trigger for update |
| --- | --- | --- |
| The Registry 「マイルストーン接続」 has 3 columns and its constraint sentences begin with one of the 3 openings | Registry lines 331–360 in that version: 3 columns, 28 data rows (up from 15 at the time of the work). All 28 begin with 「この到達点の前に完了が必要」, 「判断材料」 or 「到達後」 | Rows added to or changed in the connection table. Check that new rows follow the opening rule |
| The 「ゲート経路の関係種類」 section is abolished | No heading of that name in the Registry of that version (only the entry to past records at line 227) | The section returning |
| Reading a 4-column table stops | `expected 3 columns` at line 254 of `sync.py` in that version | Changes to `sync.py`'s table reading |
| Old-format JSON is rejected | Line 57 of `index.template.html` in that version has 「旧形式（線の種類あり）のJSONは読み込めません」; line 320 has `isMilestoneLink` | Changes to `check()` |

The scope's `index.html` was renamed to `index.template.html` in `bbddb7ff3`. The row count 「15行」 is the value at the time of the work; it is now 28 rows (the judgment to write out conditions is unchanged). The real Safari display and the screen display of old JSON remain unconfirmed.
