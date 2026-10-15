# Claude採番待ちqueue — 2026-10-15 reconciliation済み原文（2）

2026-10-15 18:24 JST、`Maintanance/CLAUDE_PENDING_TASKS.md`の「採番待ち」から、Codexの照合・統合が済んだ
`CP-20261015-006`（正式ID`OPS-042`）を原文のまま移した。移動時点の履歴であり、現在の依頼・規則・着手条件ではない。
移動はqueueの規則にあるユーザーの常設委任による。同日の先行分は`CLAUDE_PENDING_TASKS_RECONCILED_2026-10-15.md`にある。

### `CP-20261015-006` — `Tests/TESTING.md`の古い記載のアーカイブ

- queue状態: `RECONCILED`
- 発見元・ユーザー指示: 2026-10-15の会話。Test as Specificationの維持確認の後、ユーザーが`Tests/TESTING.md`を示し
  「これ若干古いんで、古い記載をアーカイブしてほしい」と依頼した。
- 種別候補: `EXECUTION`
- 対象範囲: 完了済みの作業記録・旧handoff・旧監査手順を`Maintanance/Archived/TestDashboard/TESTING_HISTORY_2026-10-15.md`へ原文のまま移し、
  `Tests/TESTING.md`を現在の状態・有効な方針だけに整える。`Maintanance/Archived/TestDashboard/README.md`へ移動分を追記する。
- 対象外: 有効な方針（テスト層の区分、凍結中の削除候補、ABC328E実提出の凍結）と優先事項の内容変更、Registry。
- 完了条件: 移した節が原文のまま保存され、TESTING.mdから辿れる。現在地は確かめた事実だけにする。
- 担当候補・受入担当: 姫（Claude）実行 / Codex受入。
- 停止条件: 方針か作業記録か判別できない節は移さずに残す。
- 成果・検証: 実施済み（詳細は会話で差分を提示）。
- Codex reconciliation: `OPS-042`へ正式統合。成果は`3d5fc0cd`で保存され、`ed3fd951`で現配置へ移動済み。2026-10-15、Codexが現行文書、履歴、索引、commitを照合して受入。
