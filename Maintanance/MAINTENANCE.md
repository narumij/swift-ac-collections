<!-- CodexとClaudeによるCodexとClaudeのためのメモ -->

# Documentation maintenance notes

最終更新: 2026-10-07 / Codex

この文書は、公開ドキュメント、コメントドック、Swift-DocC、CHANGELOGを継続整備するための
恒久ルールと現在のhandoffだけを保持する。2026-10-07までの履歴と旧handoffは
`Archived/MAINTENANCE_HISTORY_2026-10-07.md`へ移した。

## Current dashboard

- C++挙動比較の証拠正本は`Sources/RedBlackTreeCollections/Documentation/Cpp-Matrix.md`。
- Index PoCとcross-tree監査の完了記録は`Archived/`に保存済み。
- 公開コメント、DocC、API Matrixの大規模監査は一区切り済み。
- Index契約確定後に、公開コメント、Design、API Matrix、DocC Topicsを最終同期する。
- テストの現在地は`Tests/TESTING.md`、全体進捗は`PROGRESS_OVERVIEW.md`を正とする。
- Claudeの現行権限とhandoffは`CLAUDE_TASK.md`、完了履歴は`Archived/CLAUDE_TASK_HISTORY.md`を正とする。

## Document roles

| 文書 | 役割 |
| --- | --- |
| `PROGRESS_OVERVIEW.md` | Task Registryと現在状態の唯一の入口 |
| `MAINTENANCE.md` | 文書整備の恒久ルールと現在handoff |
| `RED_BLACK_TREE_REMAINING_TASKS.md` | RedBlackTree残taskの設計正本 |
| `Tests/TESTING.md` | テスト基盤とテスト整理の正本 |
| `Sources/RedBlackTreeCollections/Documentation/` | 利用者・実装者向けの現行設計資料 |
| `Archived/` | 完了した調査、旧handoff、履歴スナップショット |

## Maintenance rules

- 公開仕様はTest as Specification、実装、Design文書を照合し、推測で埋めない。
- 1型で不備を見つけた場合は、4型と共有Viewの対応箇所を横断確認する。
- 公開APIの意味、制約、計算量を、実装を読まなくても把握できる状態を目指す。
- 日本語・英語の利用者向け文書、コメントドック、DocC、API Matrixを同期する。
- 個別taskの長文結果は詳細正本へ置き、本書へ時系列ログを重複させない。
- 完了した履歴はArchivedへ移し、現役文書を追記型ログにしない。
- soft-deprecated API、互換mode、構成限定APIを現役の推奨APIと混同しない。

## Swift-DocC

- Release構成かつ`--warnings-as-errors`で検証する。
- Topicsへ追加したsymbolは、実在、access level、正しいmodule所属を確認する。
- overloadは曖昧な短縮表記を避け、必要なら引数labelまで含める。
- source上のコメントだけでなく、生成結果の警告とリンク解決を確認する。

基準command:

```bash
swift package -c release --allow-writing-to-directory .build/documentation \
  generate-documentation \
  --target RedBlackTreeCollections \
  --output-path .build/documentation \
  --warnings-as-errors
```

## Comments, API Matrix, and CHANGELOG

- コメントドックは動作説明だけでなく、境界、失敗条件、計算量、Index無効化を必要に応じて記す。
- Test as Specificationで固定した公開契約を、利用者が知る必要がある場合はDocCまたはDesignへ反映する。
- API Matrixは現行の公開面を表し、履歴や実験APIの一覧として使わない。
- source-breakingな公開面縮小、挙動変更、互換性上重要な修正はCHANGELOGへ記録する。
- CHANGELOGには検証していない性能・安全性の一般化を書かない。

## Current handoff

- RedBlackTree文書の最終同期はIndex契約の外部条件待ち。
- `Result`のpublic比較overloadとpublic `_NodePtr`の整理は完了済み。
- Debug限定Comparable群とBalanced群、Memoize群はTask Registryどおり凍結を維持する。
- Permutationの現行契約基準固定と互換mode文書は、それぞれのtask再開後に扱う。
- 完了済み履歴を参照する必要がある場合だけ、`Archived/MAINTENANCE_HISTORY_2026-10-07.md`を読む。
