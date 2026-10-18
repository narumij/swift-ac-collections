# AI smell判定スキームのSQLiteインメモリfixture

## TL;DR（人間向け）

共有スキーム候補（GRAPH-006）を、SQLite `:memory:`上で一つのcommandから再現できる最小fixtureへ変換したGRAPH-007の正本。Claudeが実装し、Codexが期待件数の一致とlocal DB非依存を確かめてDONEで受け入れた。task→symbol辺はrepository根拠がないため作らず（0件を「導出元なし」として再現）、自動抽出やスキームの正式採用は含まない。

Last updated: 2026-10-08 / Claude (GRAPH-007 implementation result). Task definition by Codex

<a id="位置づけ"></a>
## Position

This document is the canonical of `GRAPH-007`, which converts the shared schema candidate made in `GRAPH-006` into a minimal fixture runnable on SQLite `:memory:`.

`GRAPH-006` produced a schema candidate that people can read and re-investigate relations from, but no deliverable that reproduces DDL, fixture loading and query execution with one command. This task fills only that gap.

<a id="担当と受入"></a>
## Owners and acceptance

- Implementation: Claude
- Acceptance: Codex
- User decision: settled to use SQLite `:memory:` for the minimal fixture

<a id="目的"></a>
## Purpose

Load the shared schema and the RBT-017 fixture into an empty SQLite in-memory DB, and make it reproducible, without Claude's private DB, that the "pull the neighbours" query returns the expected results in `Graph/AI_GRAPH_SHARED_SCHEMA.md`.

<a id="必須成果物"></a>
## Required deliverables

Store them under `Maintanance/`, like this document, and create at least the following as tracked files.

1. DDL for SQLite
   - node
   - edge
   - provenance
   - confidence
   - the needed constraints and indexes
2. `INSERT`s of the RBT-017 fixture
   - `subscript(_:)`
   - `swapAt(_:_:)`
   - test, document, commit and task nodes
   - the known edges
3. The "pull the neighbours" `SELECT`
   - takes a symbol as input and returns test, document, commit and task separately
   - includes provenance, confidence and evidence in the result
4. A reproduction procedure with one command
   - starts from an empty `:memory:`
   - does not refer to DB files outside the repository
   - the expected counts can be checked after running
5. Expected results
   - `subscript(_:)`: test 2, document 9, commit 6, task 0
   - `swapAt(_:_:)`: test 4, document 8, commit 7, task 0

Even if the SQL is split into files, provide an entry point that runs with one command, without users guessing the order.

<a id="a-1とa-2の扱い"></a>
## Handling A-1 and A-2

<a id="tasksymbol辺の不在"></a>
### Absence of task → symbol edges

RBT-017, RBT-018 and RBT-026 may be included as task nodes in the fixture, but `task_scopes` edges with repository grounds do not exist, so do not create them. Do not promote the AI's guess "they are really related" into a confirmed edge. Fix the query's task result of 0 as the expected value.

<a id="fixtureによる自己参照汚染"></a>
### Self-reference contamination by the fixture

This task does not implement an extractor, so explicitly enumerate the document nodes loaded into the SQL fixture. Do not add the fixture or the task definition document itself as document nodes, so the expected values do not self-multiply. State in the README or the reproduction procedure that this exclusion is specific to the hand-made fixture.

<a id="対象外"></a>
## Out of scope

- Automatic extraction from source, compiler index, Git or Markdown
- Reading, converting or updating Claude's private graph DB
- Creating a persistent SQLite file
- Changes to production source, tests or build settings
- Deciding how task → symbol edges are stored
- Formally adopting the shared schema
- New smell searches

<a id="停止条件"></a>
## Stop conditions

- If a storage base other than SQLite `:memory:` becomes necessary, do not implement it and stop.
- If the expected counts need to change, record the grounds and the difference and return them to Codex.
- If adding AI-guessed edges to the fixture as facts becomes necessary, stop.
- If automatic extraction becomes necessary, do not include it in this task; separate it as a follow-up task candidate.

<a id="完了条件"></a>
## Completion conditions

- In a new environment, one command loads the DDL and fixture into an empty SQLite `:memory:`.
- The query returns the expected counts and the evidence rows for the 2 symbols.
- A task result of 0 can be reproduced as "nothing to derive from".
- It runs with only the SQL and the reproduction procedure, without referring to Claude's local DB.
- Codex runs the command and records the result in the acceptance field.

## Claude実装結果（2026-10-08）

### 再現command

repository rootで実行する（`.read`はrepository rootからの相対pathで書いてある）。

```sh
sqlite3 :memory: < Maintanance/Graph/InMemoryFixture/run.sql
```

最終行が`PASS: all 8 section counts match`なら期待件数どおり。sqlite3 3.54.0（macOS同梱）で確認した。

### file（trackedのfixture）

| file | 内容 |
| --- | --- |
| `AIGraphInMemoryFixture/run.sql` | 入口。下の3fileを順に読み、外部キー検査、一覧、件数、期待件数との照合を出力 |
| `AIGraphInMemoryFixture/schema.sql` | DDL。`node`、`edge`、`provenance`、`confidence`、`derivation`と、CHECK・外部キー・index。provenance・confidenceの値の定義もここに置く |
| `AIGraphInMemoryFixture/rbt017_fixture.sql` | RBT-017 fixtureの`INSERT`。symbol 2、test 4、document 9、commit 8、task 3のnodeと、test 6・document 17・commit 13のedge |
| `AIGraphInMemoryFixture/neighbors.sql` | 「隣を引く」。入力table `query_input`、一覧view `neighbors`、区分別件数view `neighbor_counts` |

### `Graph/AI_GRAPH_SHARED_SCHEMA.md`の候補から足したもの

- `derivation` table: relationごとに導出元があるかを持つ。`task_scopes`は`available = 0`。件数0のとき、`neighbor_counts.status`が`derived`（導出元はあり、本当に0件）か`nothing to derive from`（導出元なし）かを返す。schema候補の「0件と未作成の区別」をSQLで表すために追加した。
- `edge.rank`: 導出元自身が与える順序。`commit_changes`は`git log`の順（1が最新）。同じ日のcommitが複数あり、日付だけでは「新しい順」を再現できないため追加した。

### A-1とA-2の扱い（実装上の事実）

- task: `RBT-017`・`RBT-018`・`RBT-026`はtask nodeとして入れたが、`task_scopes` edgeは作っていない。task区分は両symbolとも`0 / nothing to derive from`。
- 自己参照: 手作業のfixtureなので、document nodeは`Graph/AI_GRAPH_SHARED_SCHEMA.md` 5節の9件を明示的に列挙している。fixtureのfile群、`Graph/AI_GRAPH_SHARED_SCHEMA.md`、この文書はdocument nodeに入れていないので、件数は増えない。自動抽出にする場合は、この除外を抽出規則として別に持つ必要がある。

### 確認したこと

- 正常系: 上のcommandで8区分すべてPASS。外部キー違反なし。
- 不一致の検出: 期待値を一時的に書き換えてpipeで流すと、FAILになることを確認した（file自体は変更していない）。
  - swapAtのcommit件数を8にした場合: `FAIL: 2 mismatch(es)`
  - task区分のstatusを`derived`にした場合: `FAIL: 4 mismatch(es)`
  - 期待側と実際側の両方を数えるため、1区分のずれで2件になる。

<a id="codex受入欄"></a>
## Codex acceptance field

2026-10-08 / Codex.

- Reproduction command: accepted. Ran `sqlite3 :memory: < Maintanance/Graph/InMemoryFixture/run.sql` from the repository root.
- Expected counts: accepted. `subscript` test 2, document 9, commit 6, task 0 and `swapAt` test 4, document 8, commit 7, task 0 matched, and `PASS: all 8 section counts match` was confirmed.
- Independence from a local DB: accepted. Only the 4 tracked SQL files are read from an empty `:memory:`, with no foreign-key violations.
- Known constraints: task is `nothing to derive from`, and the fixture documents are excluded from manual enumeration to prevent self-contamination of the expected values.
- GRAPH-007 judgment: `DONE`
