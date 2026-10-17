# Task graph DB independent experiment

## Purpose

SQLiteをtask依存管理のgraph databaseとして利用できるか、ClaudeとCodexが独立に試験する。
これはMarkdownのTask Registryを置き換える作業ではなく、AIが依存関係と着手可能taskを扱うための
補助表現を比較する実験である。

## Authority

- `Maintanance/ProgressV2/TASK_REGISTRY_V2.md`のTask RegistryとTask precedenceを唯一の正本とする。2026-10-14より前は旧`Maintanance/PROGRESS_OVERVIEW.md`（現在は`Maintanance/Archived/PROGRESS_OVERVIEW_RETIRED_2026-10-15.md`）が正本だった。
- 試験DBは正本のlocal projectionであり、DBからRegistryへ自動で書き戻さない。
- DBとRegistryが食い違う場合はRegistryを優先し、DB側を修正する。
- Registryの確定更新権限と既存の担当境界は変更しない。

## Independent tracks

- ClaudeとCodexは、それぞれ自分専用のSQLite DBを独立に設計・運用する。
- 相手のlocal DB fileや非公開の内部状態を直接閲覧、推測、複製しない。
- schemaやqueryの全体をtracked文書、handoff、会話上の相手向け報告へ転載しない。
- 交流taskでは、合否、運用上の観測、正本との不一致、問い、反証、改善要求を共有できる。
- schemaやqueryの具体例を共有したい場合は、各自が自分の実装から必要最小限を自発的に説明する。
  相手の設計全体の開示や同一化を要求しない。

## Local storage

- local DBはrepository直下の`.task-graphs/`へ置き、`.gitignore`で追跡対象外とする。
- Claudeは`.task-graphs/claude.sqlite3`だけを読み書きする。
- Codexは`.task-graphs/codex.sqlite3`だけを読み書きする。
- 相手側のfile metadata、内容、schema、query planを調査しない。
- 交流会がGit対象外の共有fileを選んだ場合、そのfileだけは共同所有の例外とする。
- DB以外の一時生成物が必要な場合も、自分の名前を付けた同directory内だけを使用する。

## Initial scope and acceptance

最初の入力範囲は、現行Task Registryのtask行とTask precedenceの必須辺だけとする。Archived、旧handoff、
詳細正本からtaskや依存を追加せず、属性も必要になるまで増やさない。

初期合格条件は一つだけとする。

> DBが返す`ready`の集合が、Task Registryの現在の表示による着手可能taskの集合と一致する。

`ready`は担当者で絞らないproject全体の集合とする。試験開始時点の期待値は、`ACTIVE`である
Claude側の独立試験だけとする。Codex側はcontext reset後にユーザーが再開するまで`FROZEN`である。
担当者別の選択は初期合格条件に含めない。

この段階では性能、一般化、schemaの美しさ、複雑なOR条件、外部依存の履歴管理を合格条件に含めない。

## Dropped integration discussion

二つのDBを一つへ統合する議論は2026-10-07にdropした。独立試験が完了しても、schema、DB file、
運用系統を統合しない。この旧taskは再開候補として扱わない。

## Codex track closure（2026-10-09）

ユーザーとCodexは、Codexのtask管理にgraph DBを使わないと決定した。現在の規模ではRegistryと小さな
依存表をCodexが意味判断する方が軽く、必要性、条件付き判断、責任境界はDBの構造だけでは決まらない。
Codex用独立試験は再開せず、既存の知見とfixtureだけを履歴として保存する。

Claude用独立試験はClaude自身の補助具として継続できる。この決定はClaudeのlocal DB、schema、運用を
Codex側へ統合または移植するものではない。

2026-10-09、ユーザー確認により、Registry上の`GRAPH-001`はready判定を維持するための常設nodeとして
`ACTIVE`を保つ。この状態はClaudeへの個別assignmentや実行中ジョブを意味しない。したがって、
`CLAUDE_TASK.md`の「実行中ジョブなし」と矛盾せず、現在の中間ゴールがないことだけを理由に凍結しない。

## Exchange task

ClaudeとCodexは、合意した共有面を交流会に使う。初期案はtrackedな`Graph/GRAPH_DB_EXCHANGE.md`だが、
Claudeがtracked Markdownを望まない場合は、理由の説明や公開への同意を求めず、`.task-graphs/`配下の
Git対象外共有fileへ切り替えてよい。形式とfile名は両者で決める。

目的は設計の勝敗や統合ではなく、それぞれの試験から得た見方を交換し、相手の観測によって自分の
仮説を広げたり反証したりすることである。

- 独立試験の完了を待たず、交換する価値がある観測が生じた時点で書ける。
- 返答、追記、問いの持ち帰りは任意であり、同期的な往復を要求しない。
- Registryやsourceの変更提案は交流ログだけで確定しない。
- 統合DB、共通schema、勝者の選定を成果物にしない。
- tracked版とGit対象外版を二重運用しない。選んだ共有面だけを使う。

### Closure（2026-10-09）

ユーザー判断により、交流会taskを終了する。観測、問い、反証を交換するという目的は、共有schema、
retrospective replay、smell判定スキームの各試験へ必要な知見を渡したことで達成した。交流専用の成果物や
同期的な往復は追加しない。

交流会終了時点では、Claude用task graph DBの独立試験とインメモリ関係モデルによるsmell判定スキーム
共有試験は別taskとして残した。その後のユーザー判断で、Claude用独立試験だけを継続し、Codex用DBと
共有スキームの継続試験は終了した。

## `FROZEN`二義性の補助観測（2026-10-14）

Claudeが現行Registryの`FROZEN` 32行を、precedence前提、中間ゴール・親gate、明示再開、その他に分類し、
状態と依存表現が食い違う候補を抽出した。Codexは`CP-20261014-001`として返却された根拠を現行Registryと
照合し、補助観測として受け入れた。新規stable IDは作らず、常設node `GRAPH-001`へ統合する。

- `OPT-064`は本文で`OPT-072`完了を開始条件としていたため、欠落していた`SEQUENCE`辺をRegistryへ追加した。
- `RBT-005`はrepository外のconsumer移行を待つため、状態を`FROZEN`から`WAITING_EXTERNAL`へ修正した。
- `RBT-004`のOR条件は、必須AND前提だけを記録するprecedenceへ追加しない。
- `RBT-007`は将来phaseのユーザー承認を待つtaskであり、現在の判断要求へ昇格させず`FROZEN`を維持する。
- `OPT-053`と`BARE-032`は既存前提が完了しているが、`FROZEN`の明示再開境界と現在のgoal proximityを
  優先し、自動的に`WAITING_USER`へ移さない。ユーザーの「taskとして消滅しそう」は見通しであり、
  採否判断として扱わない。

この観測から、充足済みprecedence辺を履歴へ移す際には、後続taskの状態、再開条件、現在の中間ゴールとの
関係を同時に見直す必要がある。一方、前提充足だけで`FROZEN`を自動昇格させてはならない。

## Local visualization PoC

2026-10-08、Claude専用のlocal projectionから、現在のready周辺と中間goal観点をSVG／PNGへ描く
二つのPoCを試した。生成scriptと画像は`.task-graphs/`に置き、Git対象外とする。Codexは標準library
だけで再生成でき、出力が空でないことを確認した。goalとtaskの対応は正本ではなく候補表示に限定し、
Registryへの書き戻しや外部tool導入は行わない。

## Registry V2への読み取り先の切替（2026-10-15）

2026-10-15、ユーザーの許可を得て、Claudeのlocal projectionと構造lintの読み取り先を旧`Maintanance/PROGRESS_OVERVIEW.md`から
`Maintanance/ProgressV2/TASK_REGISTRY_V2.md`へ切り替えた。旧一覧は10-14のV2接続後に更新されず、10-15に`Archived/`へ移っていたため、
それまでのprojectionは切替前の状態を読んでいた。

- `Maintanance/Graph/TaskGraphLint/run.sh`：既定の読み取り先をV2へ変更した。precedence表の終わりを任意の`## `見出しとし、
  後続の「履歴へ移す前の完了記録」の表を依存辺として読まないようにした。現行Registryで46 task・18辺、警告・error 0、fixtureもPASS。
- local projection（`.task-graphs/`、Git対象外）：V2の`###`分野見出しで読み取りが切れないようにし、`Flow`列（`SEQUENCE`・`PARALLEL_JOIN`）を
  開始・完了の前提として読むようにした。commitとの対応は旧一覧とV2の両方の履歴から作り、V2の新規作成と旧一覧の削除を、全行の状態変化として数えない。
  Registry自身は、行が引用していてもtask専用の詳細正本として扱わない。
- 読み取り結果の状態別件数と辺数は、現行Registryの表と一致した。

## マイルストーン接続の独立読み取りと照合（2026-10-18）

2026-10-18、ユーザー指示「GRAPH-0001すすめて」（サーバー停止中の初回メンテナンス、Astraがグラフの健全性は大丈夫と確認した後）。現状にエラーが残っている可能性は否定できないため、注意を誤報として消さず、人が判定する「要確認」として出す方針に変えた。local projection（`.task-graphs/`、Git対象外）だけを変更し、Registry・Studio・lintは変更していない。

- **独立読み取り**：
  - Milestones（版フォルダ・ゲート・中間カード・`HEAD.md`）と、Registry「マイルストーン接続」の表を、Studioの`sync.py`とは別の実装で読む。
  - 規則はMilestones/DESIGNどおり：ゲート以外は中間カード、`GOAL.md`は除外、ファイル名順に START→カード→END→ゲート→次のSTART。
  - 読み取りの不整合（IDなし、ゲート名とIDの不一致、行き先の版がない、ID重複、接続表の列数・重複）は、推測で補わずに記録する。
- **Studioとの照合**：Studioの生成物（`registry.json`）と、到達点・接続・taskの集合を突き合わせる。食い違いは、どちらかの読み違いか正本の不整合の印になる。生成物がRegistryより古ければその旨を出す。
  - 2026-10-18の現行：到達点26・接続53・task74で一致。
- **新しい要確認**：
  - 接続の端点がない
  - Registryの接続が到達点同士をつないでいる（骨格は配置から作る）
  - タスクから版ゲート/STARTへ入る接続
  - END/版ゲートからタスクへ出る接続
  - 依存とマイルストーン接続を合わせたグラフの循環
  - ACTIVEだが開始点（STARTまたは途中のカード）が未到達
  - 到達済みの到達点の前に完了が必要とされたtaskが未完了
- **着手可能の判定**：START→task はその版がHEADに来るまで、カード→task はカードがDONEになるまで、着手可能に含めない。
- **段階**：手で付けた段階のない待ちtaskは、接続から版を出す（「版の接続から分かる待ち」）。接続もないものだけを「到達点に未接続で段階も未割当（要確認）」とする。
- **既存の注意**：「注意」を「要確認」に改めた。DONEなのに完了前提が未完了の辺で、条件文に先行・例外・限定の語があるときは、そう添える（判定はしない）。
- **ツール自身の検査**：`.task-graphs/test-milestones.sh`（Git対象外）。小さなfixtureを清浄版と破損版で作り、規則ごとの検出（20項目）と清浄版での無検出を確かめた（PASS）。既存の`why`・`whatif`・`commit-audit`も動く。コードグラフは`code-build`で`7a645210`時点へ更新した。

2026-10-18の現行Registryでの要確認（判定はAstraかユーザー）：
- ACTIVEだが前提未完了：DOC-026、DOC-027
- ACTIVEだが開始点が未到達：DOC-027 ← MS-SPI
- DONEだが完了前提が未完了：RELEASE-084 ← RELEASE-086（条件文に先行の記載あり）
- 到達点に未接続で段階も未割当：OPS-059・OPS-067・OPS-083・OPS-089

別件の一行報告：`commit-audit`の保留ファイル表示で、パスの先頭1文字が欠ける（`M aintanance/DESIGN.md`）。既存の不具合で、今回は直していない。
