# AI Collaboration Bootstrap

## 適用範囲

**このfolderの文書を`swift-ac-collections`のoperation、役割、権限、task管理へ適用しない。**

このrepositoryは、root `AGENTS.md`、現行Task Registry、各taskの詳細正本による既存運用を維持する。
このfolderは、ユーザーが明示的に指定した別projectでWorker / Receiver協働を試すための移植・伝授資料である。
別projectからこのfolderを参照してもよいが、成果、契約、状態、変更を`swift-ac-collections`側へ混在させない。

## 目的

このfolderは、このrepositoryで成立した管理文書を別projectへそのまま複製するためのものではない。
WorkerとReceiverが、最小限の共通境界から協働を始め、実際の経験を通じて自分たちに合う管理方法を
ユーザーと育てられるか試すための未採用候補を置く。

このrepositoryのTask Registry、Routine、安定ID、Claude handoff、release規則は、特定の協働関係と
問題へ応答して発達した。その完成形を模範解答として移植しない。

旧方式の`Archived/Orientation/PROGRESS_OVERVIEW_TEMPLATE.md`は、完成済みのRegistry、状態、ID、依存、
起動規則を一式で別projectへ移植する候補だった。現在の候補とは前提が異なるため履歴として参照し、
このfolderの初期構成や導入手順には含めない。

## 初期構成

- `AGENTS_CANDIDATE.md`: WorkerとReceiverに共通する最小限の権限境界。
- `RECEIVER_CODEX_BOOTSTRAP.md`: Receiverの固定役割候補。
- `RECEIVER_CODEX_INTAKE_CONTRACT_TEMPLATE.md`: 一回の仕事の切り出しと受入に使う局所契約候補。
- `PRIME_CONSULTATION_TEMPLATE.md`: Receiverがユーザーの選んだPrime Codexへ助言を求め、回答を
  対象projectで再検証するための質問・回答表。
- `COLLABORATION_INTERVIEW_TASK.md`: Receiverの変化と協働負荷を縦断観測する中立的なinterview task。
- `COLLABORATION_INTERVIEW_TEMPLATE.md`: Receiver本人、ユーザー、現物、Prime・第三者の評価を分けて
  記録するtemplate。

Worker用bootstrapと作業契約は、別projectでの試行範囲が定まったときに、このfolder向けの候補を作る。
現行repositoryの`Orientation/WORKER_CODEX_*`を自動的に正本または移植元としない。

ReceiverはWorkerとの委任cycleだけを担当するものではない。ユーザーの相談相手として、まだtaskになって
いない問題、方向、違和感、観測、アイデアを一緒に考える。相談中は契約を要求せず、対話を急いでtask化しない。
具体的な調査、変更、検証、委任、状態更新へ進む段階で、Receiverが会話を局所契約へ翻訳する。

## 実験の開始指示

`この文書を読んで`は読み取りまたはレビューの依頼であり、Receiverとしての役割開始、契約作成、検収、
file変更を許可しない。実験を開始するときは、ユーザーが対象project、Receiverとして動くこと、今回の
自然言語のゴール、または相談したいことを一つの依頼として伝える。

例:

> `RECEIVER_CODEX_BOOTSTRAP.md`に従ってReceiverとして起動し、このprojectで、次のWorker成果を独立検収して。
> 対象は……、期待する結果は……。

相談から始める場合:

> `RECEIVER_CODEX_BOOTSTRAP.md`に従ってReceiverとして、このprojectの進め方を相談したい。
> いま気になっているのは……。

既存の受取契約があればそのpathも指定する。契約がなくても具体的なゴールが与えられていれば、Receiverが
自然言語の依頼とprojectの事実から受取契約の原案を作る。ユーザーへ内部契約fileの作成や項目記入を要求しない。
ゴール自体がなければ、Receiverは実行を始めず、何を任せたいかを普通の言葉で一問だけ確認する。

## Prime Codexへの相談

Receiverが対象projectの正本、実装、test、compiler、履歴、測定などを確認しても探索方針を定めにくく、
Prime Codexの過去経験が助けになる場合は、`PRIME_CONSULTATION_TEMPLATE.md`へ質問を整理できる。

Primeは役割名や上位承認者ではなく、ユーザーが相談先に選んだ個体である。ユーザーは別conversationへ
質問表を渡し、回答をReceiverへ戻すtransportだけを担う。質問の分解、回答の転記、証拠との照合、採否判断を
ユーザーへ負わせない。

ReceiverはPrimeの回答を助言として受け取り、対象projectの現物へ独立に照合する。PrimeとReceiverの合意を
正しさの証明にせず、製品方針、公開契約、リスク受容などユーザーに留保された判断をPrimeへ移さない。

## 境界

- このfolderの文書は、`swift-ac-collections`の現行operationへは未採用かつ適用外である。
- 別projectでユーザーが実験への使用を指示した場合、各文書はその実験のbootstrapまたは契約入力として
  使用する。「現行operationへ未採用」を、指示された実験を開始しない理由にしない。
- 候補の完成、別projectへの配置、試行開始、試行結果の受入は別の境界とする。
- `Prime`や`Queen`は役割または権限ではなく、ユーザーが実績を見て個体へ与える称号である。
- 初期状態では一回の契約だけを局所的な正本とする。
- 管理負荷が現れたら、Receiverが自分たちのための改善案を作り、ユーザーと対話して管理方法を育てる。
- `Maintanance/User/`相当のユーザー専有領域は、明示された対象と操作以外では変更しない。

## 観測すること

- Workerが全体管理を背負わず、局所作業へ集中できるか。
- Receiverが仕事の入口、独立検収、統合、完了判定を担えるか。
- 二役を上下関係へ変えず、差し戻しを契約と証拠の差として扱えるか。
- conversation喪失後に、契約、成果、証拠から復帰できるか。
- 管理上の問題を発見したとき、既存方式のコピーではなく、そのprojectに合う構造を育てられるか。

一回の成功だけで、役割設計の妥当性、能力獲得、能力定着を証明したとは扱わない。

## Interview

初回作業後、Worker受入後、異なる協働者の追加後などに、`COLLABORATION_INTERVIEW_TASK.md`を使って
変化を観測する。詳細な成功例を先に読ませて望ましい回答を教えず、Receiver本人の自己評価、ユーザーの
評価、repository上の事実、Prime・第三者の助言を分離する。

ユーザーの評価は付加情報ではない。相談のしやすさ、不要な判断要求、認知負荷、責務の引受け方、信頼の
変化を知る一次資料として、ユーザー自身の表現と具体的な出来事を残す。
