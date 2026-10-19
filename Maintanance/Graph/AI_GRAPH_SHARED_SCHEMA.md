# AI smell判定の共有スキーム最小fixture

## TL;DR（人間向け）

共有スキーム候補から関係と期待結果を再構築できるかを、最小fixtureで確認した記録。Codexは文書検索とO(1)契約への経路を照合して受入したが、正式採用・保存方式は未決で、機械的再現はGRAPH-007へ分離した。

Last update: 2026-10-08 / Claude (GRAPH-006 output). Task definition: Codex.

<a id="位置づけ"></a>
## Position

Canonical for `GRAPH-006`, preparing a shared schema candidate to reconstruct/query repository relations with shared meaning independently of Claude's local graph DB.

Existing `Archived/AI_GRAPH_SMELL_NOTES.md` and `Graph/GRAPH_DB_EXCHANGE.md` are past observations/inputs; their unfinished items and 「次に試すこと」 are not assignments here.

<a id="目的"></a>
## Purpose

Convert the 「隣を引く」 experiment recorded at commit `f6f84d6c` into agent-independent node/edge/provenance/confidence/query/fixture definitions.

Check whether another agent can understand/reconstruct the same relations/expected results from the candidate alone. Do not decide formal adoption/storage.

<a id="担当と受入"></a>
## Roles and acceptance

- Drafting: Claude
- Acceptance: Codex
- User decision: none

Claude presents candidate/gaps. Codex checks reconstructability from this document without reading Claude's local DB.

<a id="成果物"></a>
## Deliverables

Record the following here.

<a id="1-node-schema"></a>
### 1. Node schema

At minimum: symbol, test, document, commit, task. Specify fields for stable identifier, display name, source location, provenance, confidence and observation time.

<a id="2-edge-schema"></a>
### 2. Edge schema

At minimum: test references symbol, document mentions symbol, commit changes symbol, task scopes symbol. Specify endpoints, relation, provenance, confidence and evidence location.

<a id="3-provenanceとconfidence"></a>
### 3. Provenance and confidence

Distinguish syntax, compiler index, repository records, runtime observations and AI inference; do not collapse confirmed facts, evidence-supported candidates, hypotheses and refutations.

<a id="4-query-schema"></a>
### 4. Query schema

Define neighbor queries: symbol identifier input; output referencing specification tests, naming documents, recent declaration-body commits and tasks scoping the symbol. Disambiguate generic members using owner type. Return evidence/confidence per result.

<a id="5-rbt-017最小fixture"></a>
### 5. Minimal RBT-017 fixture

For Mapped Values View symbols, record nodes, required edges, query input, expected output, paths to the 2026-10-05 O(1) contract and information not reproducible from fixture alone, within `f6f84d6c` observations.

<a id="6-再構築可能性"></a>
### 6. Reconstructability

Self-check fields/evidence for Codex reconstruction without Claude's DB. Record missing fields/inputs rather than inventing them.

<a id="対象外"></a>
## Excluded

- Claude-specific graph DB features/schema changes
- New smell-candidate exploration
- Production source/tests/build changes
- Storage/implementation choices such as persistent DB, SQLite or Swift types
- Integrating `GRAPH-001`, `GRAPH-004`, `GRAPH-005`
- Substituting observations in `Graph/GRAPH_DB_EXCHANGE.md` for deliverables
- Formal shared-schema adoption

<a id="停止条件"></a>
## Stopping conditions

- If storage/implementation/formal-schema choices arise, record options/differences and stop.
- If required evidence is unavailable from `f6f84d6c` and current repository, record gaps/checked scope and stop.
- If new public contracts/task policy/source changes are required, stop rather than decide.
- Separate out-of-scope improvement candidates at the end without implementing.

<a id="完了条件"></a>
## Completion criteria

- Candidate node/edge/provenance/confidence/query schemas explicit.
- Minimal RBT-017 fixture/expected results recorded.
- Facts/inference/gaps/refutations distinct.
- Codex can accept without Claude's DB.
- No excluded implementation/exploration.

## Claude作成結果（2026-10-08）

観測時点: HEAD `729637c9`。`f6f84d6c`から`Sources/`と`Tests/`に差分なし（`git diff --stat f6f84d6c..HEAD -- Sources Tests`が空）。
以下のfield名は説明用の候補であり、保存方式や正式名は決めない。

### 1. Node schema（候補）

全nodeの共通field:

| field | 意味 |
| --- | --- |
| `id` | stable identifier。種別ごとの規則は下表 |
| `kind` | `symbol` / `test` / `document` / `commit` / `task` |
| `display` | 人が読む名前 |
| `location` | repository相対path、必要なら行範囲 |
| `provenance` | 3節の値 |
| `confidence` | 3節の値 |
| `observed_at` | 観測したcommit（短縮hash）。作業ツリーに未commit変更があればその旨 |

| kind | `id`の規則 | `display` | `location` |
| --- | --- | --- | --- |
| `symbol` | compilerのprecise identifier（USR）。symbol graphの`identifier.precise`とindex storeのUSRは同じ値 | `Owner.member(labels)` | 宣言のfileと行。`span`（宣言行〜本体を閉じる`}`の行、本体なしは宣言行のみ）を別fieldに持つ |
| `test` | test fileのrepository相対path | file名 | path。`spec`（file名が`<名>_<N>_*.swift`で`N < 90`）かどうかを`role`として持つ |
| `document` | Markdownのrepository相対path | file名 | path |
| `commit` | 短縮hash（衝突時は完全hash） | 件名と日付 | なし |
| `task` | Registryのtask ID | Registryの項目名 | `PROGRESS_OVERVIEW.md` |

### 2. Edge schema（候補）

共通field: `src`、`dst`、`relation`、`provenance`、`confidence`、`evidence`（根拠位置: file:行、commit、または再現command）。

| relation | src → dst | 導出方法 | `evidence` |
| --- | --- | --- | --- |
| `test_references` | test → symbol | index storeのoccurrenceでrole=referenceのもの。対象symbolのUSR、またはそのsymbolへ`memberOf`で属するsymbolのUSR | test fileのpath（index storeの行番号は任意） |
| `document_mentions` | document → symbol | member名を単語境界で含み、かつ所属型の名前も含むMarkdown。型自身なら型名だけで判定 | file path。行は任意 |
| `commit_changes` | commit → symbol | `git log -L<span>:<file> --no-patch`が返すcommit | commit hash |
| `task_scopes` | task → symbol | repositoryに記録された対応表は無い。6節の不足を参照 | — |

<a id="3-provenanceとconfidence-1"></a>
### 3. Provenanceとconfidence

`provenance`（どこから来たか）:

| 値 | 意味 | 本fixtureでの例 |
| --- | --- | --- |
| `compiler_symbolgraph` | `swift package dump-symbol-graph`の出力 | symbolのUSR、宣言行、`memberOf` |
| `compiler_index` | index storeのoccurrence | `test_references` |
| `syntax` | sourceの字句走査 | `span`の終端（波括弧の対応） |
| `repo_git` | git履歴 | `commit_changes` |
| `repo_text` | trackedな文書の文字列照合 | `document_mentions` |
| `runtime` | testや実行の観測 | 本fixtureでは使わない |
| `ai_inference` | AIが根拠から推定した対応 | 「どの結果が契約に届くか」の判定 |

`confidence`（どこまで確かか）:

| 値 | 意味 |
| --- | --- |
| `confirmed` | 導出方法を再実行すれば同じ結果になる事実 |
| `candidate` | 根拠付きだが関係の意味は未確認（文字列一致で文脈を読んでいない、など） |
| `hypothesis` | 根拠が部分的な推定 |
| `refuted` | 反証済み。削除せず残し、反証の根拠を`evidence`へ持つ |

`provenance`と`confidence`は独立に持つ。例: `repo_text`の一致は`candidate`、本文を読んで契約を述べていると確認すれば`confirmed`へ上げる。

### 4. Query schema: 隣を引く

- 入力: symbolの`id`（USR）。人が使う場合は`display`からUSRへ解決し、複数一致なら全件を返す。
- 出力（symbolごとに4区分）:
  1. `test_references`のtest。`role=spec`を先に、spec以外は件数と一覧
  2. `document_mentions`のdocument
  3. `commit_changes`のcommit。新しい順、既定で上位8件
  4. `task_scopes`のtask。完了・除外以外を先に
- 一般名の絞り込み: member（`subscript`、`swapAt`、`init`など）は所属型の名前との組で判定する。型名だけの一致は数えない。
- 各結果へedgeの`provenance`・`confidence`・`evidence`をそのまま付けて返す。区分の件数が0のときも「0件」を返し、「未作成」（導出元が無い）と区別する。
- 対象から外すもの: `Maintanance/Archived/`、`.build/`、この文書自身（fixtureの期待値を書いた時点で自分が一致してしまうため）。対象文書は`Sources/`・`Documentation/`・`Maintanance/`配下の`*.md`と`README.md`。

<a id="5-rbt-017最小fixture-1"></a>
### 5. RBT-017最小fixture

**query入力**

| `display` | `id` | `location` | `span` |
| --- | --- | --- | --- |
| `RedBlackTreeMappedValuesView.subscript(_:)` | `s:23RedBlackTreeCollections0abC16MappedValuesViewVy4Base_01_E5ValueAA01_eI4TypePQZAA12_LazyTieWrapVyAA15_NodePtrSealingVGcip` | `Sources/RedBlackTreeCollections/RedBlackTreeView/RedBlackTreeMappedValuesView.swift:152` | 152–162 |
| `RedBlackTreeMappedValuesView.swapAt(_:_:)` | `s:23RedBlackTreeCollections0abC16MappedValuesViewV6swapAtyyAA12_LazyTieWrapVyAA15_NodePtrSealingVG_AItF` | 同file:175 | 175–189 |

両symbolとも`memberOf`で属するsymbolは0件（自分自身のUSRだけで照合する）。provenanceは`compiler_symbolgraph`、`span`終端は`syntax`、いずれも`confirmed`。

**期待する出力: `subscript(_:)`**

1. test: spec 1件 `Tests/RedBlackTreeTests/RedBlackTreeView/RedBlackTreeView_0_MappedValuesViewTests.swift`、spec以外1件 `Tests/RedBlackTreeTests/RedBlackTreeDictionary/RedBlackTreeDictionary_99_DeathTests.swift`（`compiler_index` / `confirmed`）
2. document 9件（`repo_text` / `candidate`）:
   `Documentation/RedBlackTreeMultiMap.ja.md`、`Documentation/RedBlackTreeMultiMap.md`、`Maintanance/Archived/Canonical/RED_BLACK_TREE_REMAINING_TASKS.md`、
   `Sources/RedBlackTreeCollections/Documentation/API-Matrix-View.md`、`Sources/RedBlackTreeCollections/Documentation/API-Matrix.md`、
   `Maintanance/UserDocuments/RedBlackTreeCollections/Head/Outlines/RedBlackTreeMultiMap.outline.md`、
   `Maintanance/UserDocuments/RedBlackTreeCollections/Head/RedBlackTreeMultiMap.ja.md`、`Maintanance/UserDocuments/RedBlackTreeCollections/Head/RedBlackTreeMultiMap.md`、
   `Sources/RedBlackTreeCollections/RedBlackTreeCollections.docc/RedBlackTreeMappedValuesView.md`
3. commit（新しい順、`repo_git` / `confirmed`）: `211ca2fc` 2026-10-05、`3349e4b3` 2026-10-03、`3e79163c` 2026-10-01、`4e5c3306`・`0266bfd5`・`0bbde8a0` 2026-09-28
4. task: 0件（導出元なし。6節）

**期待する出力: `swapAt(_:_:)`**

1. test: spec 3件 `RedBlackTreeMultiMap/RedBlackTreeMultiMap_7_UtilityTests.swift`、`RedBlackTreeMultiMap/RedBlackTreeMultiMap_8_RangeViewTests.swift`、`RedBlackTreeView/RedBlackTreeView_0_MappedValuesViewTests.swift`（いずれも`Tests/RedBlackTreeTests/`配下）、spec以外1件 `RedBlackTreeDictionary_99_DeathTests.swift`
2. document 8件: `subscript(_:)`の9件から`API-Matrix.md`を除いたもの
3. commit: `211ca2fc` 2026-10-05、`3349e4b3` 2026-10-03、`3e79163c` 2026-10-01、`beb80c1b`・`0266bfd5`・`a67b736c`・`0bbde8a0` 2026-09-28
4. task: 0件

**2026-10-05のO(1)契約への到達経路**

| 経路 | 結果 | 契約に届く根拠 | confidence |
| --- | --- | --- | --- |
| commit | 両symbolの先頭`211ca2fc` | 件名「make mapped values index operations constant time」。差分で`subscript`・`swapAt`の`isElement(at:)`検査を削除し、Complexityを`O(1)`へ変更 | `confirmed` |
| document | `API-Matrix-View.md` | 52〜56行に「MappedValues Viewの`subscript(position:)`と`swapAt(_:_:)`はO(1)」「範囲所属は呼び出し側の事前条件」。同行の`git log -L52,52`の先頭も`211ca2fc` | `confirmed`（本文確認済み） |
| test | `RedBlackTreeView_0_MappedValuesViewTests.swift` | 121行`test_subrangeValuesSingleIndexOperations_doNotCompareKeys`。`git log -S`で導入は`211ca2fc` | `confirmed` |

3経路は同じcommit `211ca2fc`へ収束する（同commitが上記source・文書・testの3fileを同時に変更）。「3経路のどれでも、着手前に読めば`RBT-018`の前提誤りを避けられた」は`ai_inference` / `hypothesis`（当時の作業者がこの結果を読んで判断を変えたかは検証できない）。

**fixtureだけでは再現できない情報**

- `task_scopes`: `RBT-017`・`RBT-018`・`RBT-026`はこのsymbolを扱うが、Registryの項目名は「Mapped Values」（空白区切り）で、型名`RedBlackTreeMappedValuesView`を含まない。repositoryにtask→symbolの対応記録は無いので、期待出力は0件になる。query結果に正しいtaskが出ないことを、このfixtureの既知の欠落として扱う。
- spec以外のtest 1件（Death Test）を出すかどうかは表示上の選択で、意味上の期待値ではない。
- document 9件の大半は名前の一致だけで、契約を述べているかは未読（`candidate`）。本文確認済みは`API-Matrix-View.md`だけ。

### 6. 再構築可能性の自己点検

| 区分 | Claude local DBなしで再構築できるか | 必要な入力・command |
| --- | --- | --- |
| symbol | できる | `swift package dump-symbol-graph --minimum-access-level private`の`RedBlackTreeCollections`出力から`identifier.precise`と`location` |
| span | できる | 宣言行から波括弧を数える（行コメント`//`以降は除外）。上限200行 |
| test | index store readerがあればできる | `swift build --build-tests --build-system native --enable-index-store`後、`.build/<triple>/debug/index/store`のoccurrence。readerが無い場合、`git grep`での代替は一般名で過剰一致するため同じ結果にならない |
| document | できる | `git grep -l -w -F <member> -- 'Sources/*.md' 'Documentation/*.md' 'Maintanance/*.md' README.md ':!Maintanance/Archived' ':!Maintanance/Graph/AI_GRAPH_SHARED_SCHEMA.md'`と`git grep -l -F <Owner> --`（同じpathspec）の積集合 |
| commit | できる | `git log -L<a>,<b>:<file> --no-patch --date=short --format='%h %ad %s' -n 8` |
| task | できない | 6節下の追加fieldが必要 |

**不足（推測で埋めていない）**

1. task→symbolの対応の入力が無い。候補は、Registryの行またはtaskの詳細正本に対象symbolを記録するfield、またはAI推定の対応を`ai_inference` / `candidate`として持ち、人が`confirmed`へ上げる運用。どちらにするかは保存方式の選定を含むので決めない。
2. test区分はindex store readerに依存する。共有前提にするかは実装方式の選定なので決めない。
3. `document_mentions`の`confirmed`化（本文を読み契約を述べていると確かめる）は手作業で、query単体では`candidate`止まり。

### 範囲外の候補（実装しない）

- Registryの項目名の表記（「Mapped Values」）と型名をつなぐ別名表があれば、task区分の0件を減らせる可能性がある。

<a id="codex受入欄"></a>
## Codex acceptance

2026-10-08 / Codex.

- Fixture reconstruction: accepted at schema level. Without Claude DB, reran repository document search: `subscript` 9 / `swapAt` 8, matching expected. Compared source/API Matrix/specification test/commit `211ca2fc` routes to O(1). One-command DDL/fixture/query mechanical reproduction is outside this output, separated into `GRAPH-007`.
- Schema gaps: accepted. Confirmed absent `task_scopes` derivation input yields zero. Task→symbol storage remains undecided, a pre-implementation limit. Index-store-reader dependency and candidate `document_mentions` explicit.
- Fact/inference separation: accepted. Reproducible relations, string-match candidates and AI speculation about past decisions distinguished by provenance/confidence.
- Self-contamination: accepted. Confirmed rule/command excluding this fixture from document searches restores expected counts.
- Follow-up in-memory implementation registered `GRAPH-007`, limited to SQLite `:memory:` minimal fixture.
- GRAPH-006: `DONE`.
