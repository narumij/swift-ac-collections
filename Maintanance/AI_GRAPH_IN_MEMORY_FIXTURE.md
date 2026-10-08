# AI smell判定スキームのSQLiteインメモリfixture

最終更新: 2026-10-08 / Codex（GRAPH-007 task定義）

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

## Codex受入欄

- 再現command: 未確認
- 期待件数: 未確認
- local DB非依存: 未確認
- GRAPH-007判定: `ACTIVE`
