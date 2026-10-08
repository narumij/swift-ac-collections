# AI smell判定スキームのSQLiteインメモリfixture

最終更新: 2026-10-08 / Claude（GRAPH-007実装結果）。task定義はCodex

## 位置づけ

この文書は、`GRAPH-006`で作成した共有スキーム候補を、SQLite `:memory:`上で実行可能な最小fixtureへ
変換する`GRAPH-007`の正本である。

`GRAPH-006`は、人が読んで関係を再調査できるschema候補までを作ったが、DDL、fixture投入、query実行を
一つのcommandで再現する成果物は作っていない。本taskはその不足だけを埋める。

## 担当と受入

- 実装担当: Claude
- 受入担当: Codex
- ユーザー判断: SQLite `:memory:`を最小fixtureに使うことで確定済み

## 目的

空のSQLiteインメモリDBへ共有schemaとRBT-017 fixtureを投入し、「隣を引く」queryが
`AI_GRAPH_SHARED_SCHEMA.md`の期待結果を返すことを、Claude専用DBなしで再現可能にする。

## 必須成果物

保存場所はこの文書と同じ`Maintanance/`配下とし、少なくとも次をtracked fileとして作る。

1. SQLite用DDL
   - node
   - edge
   - provenance
   - confidence
   - 必要な制約とindex
2. RBT-017 fixtureの`INSERT`
   - `subscript(_:)`
   - `swapAt(_:_:)`
   - test、document、commit、taskのnode
   - 既知のedge
3. 「隣を引く」`SELECT`
   - symbolを入力としてtest、document、commit、taskを区分して返す
   - provenance、confidence、evidenceを結果へ含める
4. 一つのcommandによる再現手順
   - 空の`:memory:`から開始する
   - repository外のDB fileを参照しない
   - 実行後に期待件数を確認できる
5. 期待結果
   - `subscript(_:)`: test 2、document 9、commit 6、task 0
   - `swapAt(_:_:)`: test 4、document 8、commit 7、task 0

SQL fileを分割する場合も、利用者が順番を推測せず一つのcommandで実行できる入口を用意する。

## A-1とA-2の扱い

### task→symbol辺の不在

RBT-017、RBT-018、RBT-026をtask nodeとしてfixtureへ含めてもよいが、repository根拠のある
`task_scopes` edgeは存在しないため作らない。「本当は関係する」というAI推定をconfirmed edgeへ
昇格しない。queryのtask結果0件を期待値として固定する。

### fixtureによる自己参照汚染

本taskは抽出器を実装しないため、SQL fixtureへ投入するdocument nodeを明示列挙する。
fixtureやtask定義文書自身をdocument nodeへ追加せず、期待値を自己増殖させない。この除外が
手作業fixture固有であることをREADMEまたは再現手順へ明記する。

## 対象外

- source、compiler index、Git、Markdownからの自動抽出
- Claude専用graph DBの読込、変換、更新
- 永続SQLite fileの作成
- production source、test、build設定の変更
- task→symbol辺の保存方式決定
- shared schemaの正式採用
- 新しいsmell探索

## 停止条件

- SQLite `:memory:`以外の保存基盤が必要になった場合は実装せず停止する。
- 期待件数を変える必要が生じた場合は、根拠と差を記録してCodexへ返す。
- fixtureへAI推定のedgeを事実として追加する必要が生じた場合は停止する。
- 自動抽出が必要になった場合は、本taskへ含めず後続task候補として分離する。

## 完了条件

- 新しい環境で、一つのcommandから空のSQLite `:memory:`へDDLとfixtureを読み込める。
- queryが2 symbolについて期待件数と根拠行を返す。
- task結果0件を「導出元なし」として再現できる。
- SQLと再現手順だけで実行でき、Claudeのlocal DBを参照しない。
- Codexがcommandを実行し、結果を受入欄へ記録する。

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

### `AI_GRAPH_SHARED_SCHEMA.md`の候補から足したもの

- `derivation` table: relationごとに導出元があるかを持つ。`task_scopes`は`available = 0`。件数0のとき、`neighbor_counts.status`が`derived`（導出元はあり、本当に0件）か`nothing to derive from`（導出元なし）かを返す。schema候補の「0件と未作成の区別」をSQLで表すために追加した。
- `edge.rank`: 導出元自身が与える順序。`commit_changes`は`git log`の順（1が最新）。同じ日のcommitが複数あり、日付だけでは「新しい順」を再現できないため追加した。

### A-1とA-2の扱い（実装上の事実）

- task: `RBT-017`・`RBT-018`・`RBT-026`はtask nodeとして入れたが、`task_scopes` edgeは作っていない。task区分は両symbolとも`0 / nothing to derive from`。
- 自己参照: 手作業のfixtureなので、document nodeは`AI_GRAPH_SHARED_SCHEMA.md` 5節の9件を明示的に列挙している。fixtureのfile群、`AI_GRAPH_SHARED_SCHEMA.md`、この文書はdocument nodeに入れていないので、件数は増えない。自動抽出にする場合は、この除外を抽出規則として別に持つ必要がある。

### 確認したこと

- 正常系: 上のcommandで8区分すべてPASS。外部キー違反なし。
- 不一致の検出: 期待値を一時的に書き換えてpipeで流すと、FAILになることを確認した（file自体は変更していない）。
  - swapAtのcommit件数を8にした場合: `FAIL: 2 mismatch(es)`
  - task区分のstatusを`derived`にした場合: `FAIL: 4 mismatch(es)`
  - 期待側と実際側の両方を数えるため、1区分のずれで2件になる。

## Codex受入欄

2026-10-08 / Codex。

- 再現command: 受入。repository rootから`sqlite3 :memory: < Maintanance/Graph/InMemoryFixture/run.sql`を実行した。
- 期待件数: 受入。`subscript`のtest 2・document 9・commit 6・task 0、`swapAt`のtest 4・document 8・commit 7・task 0が一致し、`PASS: all 8 section counts match`を確認した。
- local DB非依存: 受入。空の`:memory:`からtracked SQL 4 fileだけを読み、外部キー違反なし。
- 既知制約: taskは`nothing to derive from`、fixture文書は手動列挙対象外として期待値の自己汚染を防ぐ。
- GRAPH-007判定: `DONE`
