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
- 統合議論を再開するまで、互いのDB、schema、query、migration、内部表現を閲覧、推測、複製しない。
- schemaやqueryをtracked文書、handoff、会話上の相手向け報告へ記載しない。
- 共有してよいのは、合否、運用上の観測、正本との不一致、およびschemaを明かさない改善要求だけとする。

## Local storage

- local DBはrepository直下の`.task-graphs/`へ置き、`.gitignore`で追跡対象外とする。
- Claudeは`.task-graphs/claude.sqlite3`だけを読み書きする。
- Codexは`.task-graphs/codex.sqlite3`だけを読み書きする。
- 相手側のfile metadata、内容、schema、query planを調査しない。
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

## Integration discussion

Claude側とCodex側の独立試験が完了しても、自動的に統合しない。統合議論は凍結taskとし、両方の
結果が揃った後にユーザーが明示的に再開した場合だけ、互いの設計を開示して比較する。
