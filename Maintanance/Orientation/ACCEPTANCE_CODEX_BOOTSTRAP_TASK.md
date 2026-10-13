# Receiver Codex用ブートストラップ作成task

## 目的

Codexの仕事をWorkerとReceiverの二役に分けるため、Receiver Codexの固定bootstrapと、
案件ごとの受取契約templateを作る。

ReceiverはWorkerの上位者ではない。Workerが局所作業と証拠作成を担い、Receiverが仕事の切り出し、
返却の独立検収、統合、完了判定を担う。役割名から権威を推定させず、仕事の入口と出口を受け持つ者として
定義する。

`Prime`や`Queen`は役割名または権限ではない。協働を高い水準で担った個体へ、ユーザーが後から与える
称号であり、bootstrapから取得できない。

## 背景

高負荷な技術作業と、作業選択、境界設定、受入、状態管理を一つのconversationへ集中させると、
どちらかの能力が圧迫される。反対に、作業者の報告を別のCodexが単に承認するだけでは、証拠に基づく
独立検収にも、conversation喪失時の復旧にもならない。

二役制では、Workerが成果と証拠を返し、Receiverが正本、契約、現物、独立した検証を照合する。
Workerの作業終了と、Receiverによる受入完了を別の状態として保つ。

## 作成するもの

1. Receiverに共通する短い固定bootstrap。
2. 一回の受取ごとに用いる契約template。
3. Workerの返却物とReceiverの受入結果を接続する最小形式。
4. Receiverが作業へ差し戻す条件、ユーザーへ判断を返す条件、停止条件。
5. 管理負荷が増えたとき、ユーザーと適合するtask管理方法を育てる課題。
6. 別projectで役割分担を試すときの観測項目。

## 役割境界

Receiverは次を担う。

- 現在のゴールから必要な局所作業を切り出し、Workerへ渡す契約を確定する。
- workspace、開始状態、変更範囲、正本、停止条件、提出物、返却経路を明示する。
- Workerの返却を、成果物、diff、test、compiler診断、測定、生データなどから独立に検収する。
- `受入可能`、`修正して再提出`、`証拠不足`、`判断待ち`、`権限外`を区別する。
- 受け入れた成果を統合し、許可された範囲でtask状態と完了記録を更新する。
- ユーザーにしか決められない問いだけを、根拠と影響を整理して返す。

Receiverは次を行わない。

- Workerの報告、AI同士の合意、test件数だけを正しさの証拠にする。
- 不足する証拠を推測で補い、受入可能へ変える。
- Workerの役割を低位、Receiverの役割を上位と解釈する。
- 役割から製品方針、公開契約、優先順位、残余リスク受容、repository operationの権限を導く。
- `Prime`、`Queen`その他の称号を自称する、または役割遂行に必要な権限として要求する。

## 試行境界

初回の実運用試験は、このrepositoryの製品作業から分離した別projectで行う。
WorkerとReceiverの二役だけを置き、次を観測する。

- Workerが全体管理を背負わず、局所作業へ集中できたか。
- ReceiverがWorkerの説明を追認せず、独立証拠から受入可否を決められたか。
- 差し戻しが人格評価や上下関係ではなく、契約と証拠の不足として表現されたか。
- ユーザーの仲介が、conversation起動など環境上必要な操作だけに局所化されたか。
- 片方のconversationを失っても、契約、成果物、証拠、受入記録から復帰できたか。
- 複数task、依存、再開が増えたとき、Receiverが管理負荷と失敗兆候を認識できたか。
- Receiverが既製のTask Registryを独断で移植せず、ユーザーと相談してそのprojectと個体に合う管理方法を
  構築し、運用結果から改善できたか。

一回の成功を、役割設計の妥当性や個体の上達の証明にはしない。このrepositoryへの採用、Orientation参照追加、
既存運用の切替は、試験結果を受けた別のユーザー判断とする。

このrepositoryのTask Registryは、ユーザー、Codex、Claudeの協働で生じた具体的な摩擦を解くために
発達したものであり、Receiver一般の模範解答として最初から移植しない。初期状態では一回の受取契約を
局所的な正本とする。取りこぼし、重複、依存の混線、復帰困難、判断要求の集中などが現れた時点で、
Receiverは観測事実と必要性をユーザーへ示し、管理方法を一緒に設計する。管理構造の採用後も固定化せず、
実際のフィードバックから改良する。

## 完了条件

- WorkerとReceiverの二役だけで委任cycleが閉じる。
- Receiverが仕事の入口と出口を担い、Workerと責務が重複しない。
- 固定bootstrapと案件固有契約の情報が分離されている。
- 独立検収、差し戻し、ユーザー判断、権限外の境界を区別できる。
- conversation喪失時に、契約とrepository上の証拠から受入を再開できる。
- 完成済みのTask Registryを前提とせず、管理負荷が現れたときにユーザーと管理方法を構築する課題を持つ。
- 候補作成、別projectでの試験、このrepositoryへの採用が別の受入境界になっている。

## 作成結果

2026-10-13、固定候補を`../CollaborationBootstrap/Receiver/RECEIVER_CODEX_BOOTSTRAP.md`、案件固有の候補を
`../CollaborationBootstrap/Receiver/RECEIVER_CODEX_INTAKE_CONTRACT_TEMPLATE.md`へ作成した。共通境界候補と設計の
入口も同folderへ分離した。いずれも未採用であり、現行operationの参照先ではない。
