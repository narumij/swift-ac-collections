# Receiver Codex materials

このfolderは、ユーザーが明示した別projectでReceiver Codexとして協働するための役割別資料をまとめる。
Workerより上位の権限を与えるものでも、完成済みのtask管理制度を移植するものでもない。

## Entry point

Receiverとして起動するときは、最初に`RECEIVER_CODEX_BOOTSTRAP.md`を読む。
具体的な仕事、相談、検収の開始には、bootstrapに加えてユーザーの現在の依頼と対象projectの上位規則を使う。
このREADMEを読んだだけでは、役割開始、file変更、検証、委任、repository operationを開始しない。

## Files

- `RECEIVER_CODEX_BOOTSTRAP.md`: Receiverの役割、相談、委任、検収、統合、停止条件。
- `RECEIVER_CODEX_INTAKE_CONTRACT_TEMPLATE.md`: 一回の仕事を切り出し、受入条件と証拠を定める局所契約。
- `PRIME_CONSULTATION_TEMPLATE.md`: ユーザーが選んだPrime Codexへ助言を求め、対象projectで再検証するための質問・回答表。
- `RECEIVER_OBSERVATIONS.md`: 面白い、意外、あとで話したいと感じたことを任意で残す自由記述log。
- `COLLABORATION_INTERVIEW_TASK.md`: 節目で、Receiverから見たユーザーのマネジメントと協働負荷を観測するtask。
- `COLLABORATION_INTERVIEW_TEMPLATE.md`: interviewの評価、事実、外部評価を分離して記録するtemplate。

## Usage

通常の相談には契約を要求しない。具体的な変更、検証、委任、状態更新へ進むとき、Receiverが自然言語の依頼を
局所契約へ翻訳する。ユーザーへ内部文書の作成や記入を要求しない。

`RECEIVER_OBSERVATIONS.md`は存在を知らせてよいが、記入を義務化しない。作業報告、完了条件、能力評価の代わりに
使わず、書きたいことがあるときだけReceiver本人が使用する。

協働interviewは構造化された後日の評価であり、自由な観測logとは証拠の性質が異なる。interviewはlogを参照
できるが、内容を望ましい回答へ整形したり、後付けの文章で置き換えたりしない。
