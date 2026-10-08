# 過去graph知見のインメモリ追試

最終更新: 2026-10-08 / Codex（GRAPH-008・GRAPH-009 task定義）

## 位置づけ

この文書は、過去のgraph系文書に記録された観測・仮説・反証のうち、`GRAPH-007`で確立した
SQLite `:memory:` fixture方式で追試可能な範囲を分類し、再実行可能な回帰fixtureへ変換する作業の正本である。

作業は、可能性を分類する`GRAPH-008`と、受入済みの対象だけを実装する候補`GRAPH-009`へ分ける。
分類と実装を同時に行わず、過去記録の印象だけでfixtureを増やさない。

## 対象文書

- `AI_GRAPH_SMELL_NOTES.md`
- `GRAPH_DB_EXCHANGE.md`
- `TASK_GRAPH_DB_EXPERIMENT.md`

`AI_GRAPH_SHARED_SCHEMA.md`と`AI_GRAPH_IN_MEMORY_FIXTURE.md`は追試方式の入力であり、過去知見の
棚卸し対象には数えない。Archived文書は、上の3文書から具体的根拠として参照される場合だけ読む。

## GRAPH-008: 追試可能性台帳

### 担当と受入

- 作成担当: Claude
- 受入担当: Codex
- 種別: `DISCOVERY`
- ユーザー判断: なし

### 目的

対象文書のgraphに関する試験記録・知見・候補を項目単位で列挙し、現行のSQLiteインメモリ方式で
どこまで追試可能かを分類する。SQLやfixtureの実装は行わない。

### 分類

各項目を必ず次のいずれかへ分類する。

- `A`: 現行schemaと手書きfixtureだけで追試可能
- `B`: SQLite `:memory:`内の小さなschemaまたはquery追加で追試可能
- `C`: source、compiler index、runtime、機械語、性能測定などの自動抽出・外部検証が必要
- `D`: 歴史的説明、主観的評価、期待値を安定定義できないため回帰fixtureにしない

`B`は永続DBやproduction変更を必要としないものに限る。task→symbolのようにrepositoryに入力がない
関係を、AI推定だけで`A`または`B`へ分類しない。

### 台帳の必須列

| 列 | 内容 |
| --- | --- |
| replay ID | この文書内だけで使う安定した識別子 |
| source | 文書名と見出し |
| original claim | 過去記録が述べる観測・仮説・反証 |
| expected result | PASS条件または期待される行・件数 |
| required input | 必要なnode・edge・外部観測 |
| query shape | 追試に必要なqueryの概要 |
| class | `A / B / C / D` |
| reason | その分類にした根拠 |
| overlap | GRAPH-007で既に覆われる部分 |

同じ事実を複数文書が述べる場合は別fixture候補へ重複させず、代表項目と参照元をまとめる。

### 対象外

- SQL、DDL、fixture、抽出器の作成・変更
- 過去のsmell判定の正誤を新しく決定すること
- Claude専用graph DBの参照・更新
- production source、test、build設定の変更
- task→symbol辺をAI推定で補うこと
- 新しいsmell探索

### 停止条件

- 分類に新しい公開契約または保存方式の判断が必要になった場合、選択肢を記録して停止する。
- 過去記録だけでは期待結果を特定できない場合、推測せず`D`または不足として記録する。
- 対象が広すぎて項目単位の完了判定ができない場合、文書・節単位の子task候補を提示して停止する。

### 完了条件

- 対象3文書のgraph試験・知見が台帳へ一度ずつ対応している。
- 全項目に`A / B / C / D`と根拠がある。
- `A / B`について、実装前に必要な入力、query、期待結果が明記されている。
- GRAPH-007との重複を除き、GRAPH-009へ渡す候補集合をCodexが選べる。

## GRAPH-009: 受入済み項目のSQLite追試fixture化

状態は`PROPOSED`とする。GRAPH-008のCodex受入後、`A / B`から実装対象を確定し、対象項目、期待結果、
schema変更範囲、完了条件をこの節へ追記してから`ACTIVE`へ移す。それまでは着手・委任しない。

現時点の共通境界は次のとおり。

- SQLite `:memory:`とtracked SQLだけを使う。
- 一つのcommandで空DBから全fixtureを実行する。
- 過去結果と現在結果の一致・不一致を項目ごとに表示する。
- Claude専用DB、永続DB、production変更に依存しない。
- 自動抽出が必要な`C`と回帰fixtureにしない`D`は実装しない。

## Codex受入欄

### GRAPH-008

- coverage: 未確認
- 分類根拠: 未確認
- GRAPH-009候補集合: 未確定
- 判定: `ACTIVE`

### GRAPH-009

- scope: 未確定
- 状態: `PROPOSED`
