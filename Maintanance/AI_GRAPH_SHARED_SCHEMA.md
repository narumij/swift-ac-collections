# AI smell判定の共有スキーム最小fixture

最終更新: 2026-10-08 / Codex（GRAPH-006 task定義）

## 位置づけ

この文書は、Claude専用graph DBに依存せず、CodexとClaudeが同じ意味でrepositoryの関係を
再構築・照会するための共有スキーム候補を作る`GRAPH-006`の正本である。

`AI_GRAPH_SMELL_NOTES.md`と`GRAPH_DB_EXCHANGE.md`の既存記録は、過去の観測と入力資料であって、
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
- `GRAPH_DB_EXCHANGE.md`へ観測だけを追記して成果物の代わりにすること
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

## Codex受入欄

作成完了後にCodexが記録する。

- fixture再構築: 未確認
- schemaの不足: 未確認
- 事実と推定の分離: 未確認
- 後続のインメモリ実装task: 未登録
- GRAPH-006判定: `ACTIVE`
