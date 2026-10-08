# AI smell判定の共有スキーム最小fixture

最終更新: 2026-10-08 / Claude（GRAPH-006作成結果）。task定義はCodex

## 位置づけ

この文書は、Claude専用graph DBに依存せず、CodexとClaudeが同じ意味でrepositoryの関係を
再構築・照会するための共有スキーム候補を作る`GRAPH-006`の正本である。

`Graph/AI_GRAPH_SMELL_NOTES.md`と`Graph/GRAPH_DB_EXCHANGE.md`の既存記録は、過去の観測と入力資料であって、
そこに書かれた未完了項目や「次に試すこと」はこのtaskの指示ではない。

## 目的

commit `f6f84d6c`で記録した「隣を引く」試験を、特定agentのlocal DBや実装へ依存しない
node、edge、provenance、confidence、query、fixtureへ変換する。

今回確認するのは、共有スキーム候補だけから別のagentが同じ関係と期待結果を理解・再構築できるかである。
スキームの正式採用や保存方式は決定しない。

## 担当と受入

- 作成担当: Claude
- 受入担当: Codex
- ユーザー判断: なし

Claudeは候補スキームと不足を提示する。CodexはClaudeのlocal DBを読まず、この文書だけからfixtureを
再構築できるか確認する。

## 成果物

この文書へ次を記録する。

### 1. Node schema

最低限、次を候補に含める。

- symbol
- test
- document
- commit
- task

各nodeについて、stable identifier、display name、source location、provenance、confidence、観測時点を
表現するfieldを示す。

### 2. Edge schema

最低限、次を候補に含める。

- test references symbol
- document mentions symbol
- commit changes symbol
- task scopes symbol

各edgeについて、始点、終点、関係種別、provenance、confidence、根拠位置を表現するfieldを示す。

### 3. Provenanceとconfidence

構文、compiler index、repository記録、runtime観測、AI推定を区別できること。確認済み事実、根拠付き候補、
仮説、反証済みを同じ値へ潰さないこと。

### 4. Query schema

「隣を引く」queryについて次を定義する。

- 入力: symbol identifier
- 出力: 参照する仕様test、名指しする文書、宣言本体の直近commit、同じsymbolをscopeに持つtask
- 一般名の絞り込み: member名だけでなく所属型を使う
- 結果ごとに返す根拠と確度

### 5. RBT-017最小fixture

Mapped Values Viewの対象symbolを入力とし、commit `f6f84d6c`で確認した範囲から次を記録する。

- fixtureを構成するnode
- 必要なedge
- query入力
- 期待する出力
- どの結果から2026-10-05のO(1)契約へ到達するか
- fixtureだけでは再現できない情報

### 6. 再構築可能性

CodexがClaudeのlocal DBなしで同じ期待結果を再構築するために、fieldと根拠が十分かを自己点検する。
不足があれば推測で埋めず、必要な追加fieldまたは入力として記録する。

## 対象外

- Claude専用graph DBの機能追加・schema変更
- 新しいsmell候補の探索
- production source、test、build設定の変更
- 永続DB、SQLite、Swift型など保存・実装方式の選定
- `GRAPH-001`、`GRAPH-004`、`GRAPH-005`の統合
- `Graph/GRAPH_DB_EXCHANGE.md`へ観測だけを追記して成果物の代わりにすること
- 共有スキームの正式採用

## 停止条件

- 保存・実装方式または正式schemaの選定が必要になった場合、選択肢と差を記録して停止する。
- fixtureに必要な根拠が`f6f84d6c`と現行repositoryから得られない場合、不足と確認した範囲を記録して停止する。
- 新しい公開契約、task方針、source変更が必要になった場合、自分で決めずに停止する。
- task境界を越える改善案を見つけても実装せず、候補として末尾へ分離する。

## 完了条件

- node、edge、provenance、confidence、queryの候補schemaが明示されている。
- RBT-017の最小fixtureと期待結果が記録されている。
- 事実、AI推定、不足、反証を区別できる。
- Claudeのlocal DBを参照しなくてもCodexが受入確認できる。
- 対象外の実装や追加探索を行っていない。

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
   `Documentation/RedBlackTreeMultiMap.ja.md`、`Documentation/RedBlackTreeMultiMap.md`、`Maintanance/RED_BLACK_TREE_REMAINING_TASKS.md`、
   `Sources/RedBlackTreeCollections/Documentation/API-Matrix-View.md`、`Sources/RedBlackTreeCollections/Documentation/API-Matrix.md`、
   `Sources/RedBlackTreeCollections/Documentation/Head/Outlines/RedBlackTreeMultiMap.outline.md`、
   `Sources/RedBlackTreeCollections/Documentation/Head/RedBlackTreeMultiMap.ja.md`、`Sources/RedBlackTreeCollections/Documentation/Head/RedBlackTreeMultiMap.md`、
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
| document | できる | `git grep -l -w -F <member> -- 'Sources/*.md' 'Documentation/*.md' 'Maintanance/*.md' README.md ':!Maintanance/Archived' ':!Maintanance/AI_GRAPH_SHARED_SCHEMA.md'`と`git grep -l -F <Owner> --`（同じpathspec）の積集合 |
| commit | できる | `git log -L<a>,<b>:<file> --no-patch --date=short --format='%h %ad %s' -n 8` |
| task | できない | 6節下の追加fieldが必要 |

**不足（推測で埋めていない）**

1. task→symbolの対応の入力が無い。候補は、Registryの行またはtaskの詳細正本に対象symbolを記録するfield、またはAI推定の対応を`ai_inference` / `candidate`として持ち、人が`confirmed`へ上げる運用。どちらにするかは保存方式の選定を含むので決めない。
2. test区分はindex store readerに依存する。共有前提にするかは実装方式の選定なので決めない。
3. `document_mentions`の`confirmed`化（本文を読み契約を述べていると確かめる）は手作業で、query単体では`candidate`止まり。

### 範囲外の候補（実装しない）

- Registryの項目名の表記（「Mapped Values」）と型名をつなぐ別名表があれば、task区分の0件を減らせる可能性がある。

## Codex受入欄

2026-10-08 / Codex。

- fixture再構築: schema-levelで受入。Claudeのlocal DBを参照せず、repositoryから文書検索を再実行し、
  `subscript` 9件、`swapAt` 8件が期待値と一致することを確認した。source、API Matrix、仕様test、
  commit `211ca2fc`の3経路もO(1)契約へ到達することを照合した。ただし、DDL、fixture投入、queryを
  一つのcommandで実行する機械的再現性は本taskの成果に含まれず、`GRAPH-007`へ分離した。
- schemaの不足: 受入。`task_scopes`の導出元がrepositoryに存在しないため0件となることを確認した。
  task→symbol辺の保存方法は本taskで決めず、後続実装前の既知制約とする。index store readerへの依存と
  `document_mentions`のcandidate判定も明示されている。
- 事実と推定の分離: 受入。再実行可能な関係、文字列一致候補、AIによる過去判断の推定が
  provenanceとconfidenceで区別されている。
- 自己参照汚染: 受入。このfixture文書を文書検索から除外する規則とcommandを確認し、期待件数へ戻る。
- 後続のインメモリ実装task: `GRAPH-007`として登録。SQLite `:memory:`の最小fixtureに限定する。
- GRAPH-006判定: `DONE`
