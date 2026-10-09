# Task graph DB independent experiment

## Purpose

SQLiteをtask依存管理のgraph databaseとして利用できるか、ClaudeとCodexが独立に試験する。
これはMarkdownのTask Registryを置き換える作業ではなく、AIが依存関係と着手可能taskを扱うための
補助表現を比較する実験である。

## Authority

- `Maintanance/PROGRESS_OVERVIEW.md`のTask RegistryとTask precedenceを唯一の正本とする。
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

この終了は、Claude用task graph DBの独立試験と、インメモリ関係モデルによるsmell判定スキーム共有試験を
終了または統合する判断ではない。両taskはそれぞれのRegistry上の条件で継続する。

## Local visualization PoC

2026-10-08、Claude専用のlocal projectionから、現在のready周辺と中間goal観点をSVG／PNGへ描く
二つのPoCを試した。生成scriptと画像は`.task-graphs/`に置き、Git対象外とする。Codexは標準library
だけで再生成でき、出力が空でないことを確認した。goalとtaskの対応は正本ではなく候補表示に限定し、
Registryへの書き戻しや外部tool導入は行わない。
