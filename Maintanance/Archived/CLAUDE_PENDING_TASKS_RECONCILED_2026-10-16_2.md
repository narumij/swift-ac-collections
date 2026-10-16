# Claude採番待ちの照合記録 2026-10-16（2）

2026-10-16、Claude。`CLAUDE_PENDING_TASKS.md`から、Astraが照合済み（`RECONCILED`）とした`CP-20261016-001`〜`003`を、本文の要約・改変なしで移した。
正式IDは`CP-20261016-001`→`HIST-003`、`002`→`TEST-006`、`003`→`TEST-007`。照合の記録は[照合記録](../Current/CLAUDE_QUEUE_RECONCILIATION_2026-10-16.md)。
移動は同書「規則」の常設委任による。相対リンクだけを本書の位置に合わせて調整した。末尾のAstraの注記も、対象entryと一緒に移した。

## 処理前原文

### `CP-20261016-001` — テスト再建の記録（2026年秋）の作成

- queue状態: `RECONCILED`
- 発見元・ユーザー指示: 2026-10-16 05時台の会話。`MILESTONES.md`の画像を見たあと、ユーザーが「ひめもテスト再構築の歩みみたいなのつくるかい？」と提案した。続けて次の指示があった。
  - 置き場所：`Tests/`ではなく`Maintanance/`内のフォルダ。`Maintanance/`外のmdは徐々に減らしたい。
  - 形：`RefactoringFromAtCoder2025`のようなリファクタリング記録。
  - 中身は姫に任せる。`Fixtures.md`の移動は「まだいい」。queueで記録し、正本は作る。
- 種別候補: `EXECUTION`
- 対象範囲: `Maintanance/TestRebuild2026/`の新設（`README.md`説明正本、`EVIDENCE.md`事実正本、`Data/`、`Images/`）と、このentry。
- 対象外: `Fixtures.md`等の移動、`DOCUMENT.md`・Registry・採番表・配置維持例外の変更、source・testの変更。
- 完了条件: 説明と事実の正本、集計データ、図がそろい、件数と記述がgit履歴・保存資料・実行結果と照合できる。
- 前提・既存task候補: 恒久task `TEST-005`の関連記録。`DOC-030`（文書の入口・参照）と`HIST-001`（移行史）に隣接する。
- 担当候補・受入担当: 姫（Claude）作成 / Codex・Astra（入口への接続・受入）。
- 停止条件: 作業主体や作者を記録から確かめられない場合は、推測で埋めず「確認していない」と書く。
- 成果・検証: 2026-10-16 / Claude Opus 5.5。4ファイル（README、EVIDENCE、CSV、SVG・PNG）を作成した。
  - 宣言数の数え方を、既存の`repository-test-counts.csv`の`165c81aa`（1739件）と照合し、一致した。
  - 不具合8件は、各commitのdiffと、変更ファイルにtestが含まれることを確認した。
  - パレット検証scriptはNode.jsがないため実行していない。理由と代わりの措置は`EVIDENCE.md`の6.に書いた。
  - commitしていない。`DOCUMENT.md`や`MILESTONES.md`など入口からのリンクは張っていない（Codex・Astraの判断）。
- Codex reconciliation: 2026-10-16 / Astra。`HIST-003`としてACTIVEへ正式登録。実施済み部分と残作業は[照合記録](../Current/CLAUDE_QUEUE_RECONCILIATION_2026-10-16.md)に分離。今回の処理は採番・接続であり成果の受入完了ではない。
- 追記（同日）: ユーザーとの会話で、置き場所は`HIST-001`の正本と並べて`History/`系にまとめる案が出た（採番がHISTなら`History/`、とユーザー）。
  移動は未実施。採番時に`HIST`の番号と置き場所をあわせて決めてもらう想定。

### `CP-20261016-002` — `Maintanance/Testing/`の新設とテスト整備文書の移動

- queue状態: `RECONCILED`
- 発見元・ユーザー指示: 2026-10-16 09時頃の会話。ユーザーが「Testingほって、md移動するのは可。採番待ちで記録しておいて」と指示した。
  前段として、`Maintanance/`外のmdを減らしたい、見て楽しむ記録は`Misc`や`History`に分けたい、という方針が示されている。
- 種別候補: `EXECUTION`
- 対象範囲: `Tests/TESTING.md`と`Tests/RedBlackTreeFixture/Fixtures.md`を`Maintanance/Testing/`へ`git mv`する。
  移動に伴い、`Package.swift`の`RedBlackTreeFixture` targetにあった`exclude: ["Fixtures.md"]`を削除する。
  次の参照も更新する。
  - `Tests/CLAUDE.md`（7か所）
  - `Tests/RedBlackTreeTests/RedBlackTreeInternal/Base/RedBlackTreeInternal_EmptySingletonTests.swift`のコメント1か所
  - `Maintanance/TestRebuild2026/README.md`のリンク
  - 移した`TESTING.md`の引き継ぎ1項目
- 対象外（未更新・Astra・Codexへ渡す）: 次の参照は旧パスのまま残している。
  - `Maintanance/ProgressV2/TASK_RULES_V2.md`の配置維持例外の表（161行付近）
  - `Maintanance/ProgressV2/TASK_REGISTRY_V2.md`の`TEST-005`行
  - `Maintanance/DOCUMENT.md`の24・65・66行のリンク
  - `Maintanance/Current/AI_TECHNICAL_ORIENTATION.md`の26・391行
  - `Maintanance/Quality/Profiles/RedBlackTreeCollections.md`の159行
- 対象外（触らない）: 過去の返却・監査・面談記録にある当時のパス。
- 残すもの: `Tests/CLAUDE.md`は移さない。Claude Codeは作業中のfolderの`CLAUDE.md`を自動で読むので、`Tests/`配下で規則が効く状態を保つため。
- 完了条件: 2文書が`Maintanance/Testing/`にあり、build・testに影響がなく、上記の対象外の参照が受入担当によって更新される。
- 前提・既存task候補: 恒久task `TEST-005`（維持文書の配置）、`DOC-030`（参照の保守）、`OPS-044`（規則とRegistry）。
- 担当候補・受入担当: 姫（Claude）移動 / Astra・Codex（規則・Registry・`DOCUMENT.md`の更新と受入）。
- 停止条件: 移動でbuildやtestの発見に影響が出たら止めて報告する。
- 成果・検証: 2026-10-16 / Claude Opus 5.5。
  - 移動と上記の参照更新を実施した。
  - `swift build --build-tests`は警告なしで完了した（`Fixtures.md`の除外指定がなくなっても、未処理resourceの警告は出なかった）。
  - commitしていない。
- Codex reconciliation: 2026-10-16 / Astra。`TEST-006`としてACTIVEへ正式登録。実施済み部分と残作業は[照合記録](../Current/CLAUDE_QUEUE_RECONCILIATION_2026-10-16.md)に分離。今回の処理は採番・接続であり成果の受入完了ではない。

### `CP-20261016-003` — 判断座標の草案のサルベージ（`Testing/`へ配置し`TEST-005`に紐付け）

- queue状態: `RECONCILED`（依頼の記録のみ。Claudeは実行しない）
- 発見元・ユーザー指示: 2026-10-16 09時台の会話。ユーザーが`Maintanance/Archived/JudgmentCoordinates/`を示し、
  「いまだと修正ポイントなにかあるかな？」と尋ねた。姫の所見を受けて、ユーザーが次のように指示した。
  「採番待ちで、サルベージ依頼するのがいいんじゃないかな？ Testingに配置するよう依頼して、恒久タスク紐付けに。テストの恒久もあるよね？」
- 種別候補: `EXECUTION`
- 対象範囲:
  - `Maintanance/Archived/JudgmentCoordinates/`の判断座標の草案（中心は`JUDGMENT_COORDINATES_DRAFT.md`）を現行の資料へ戻す。
  - 置き場所は`Maintanance/Testing/`。テスト整備の恒久task `TEST-005`の紐付け資料にする。
  - Archivedの原文は改変しない。戻す方式（移動か、写しと対応表か）は担当が決める。
- 戻すときの入力（姫の所見、2026-10-16。採否は持ち主が決める）:
  1. §3の持ち主の表は、人の名前ではなく役割で書く。文書の持ち主は、Registryの恒久taskと維持文書・紐付け資料を引く形に変え、表にはどちらにも書かれていないものだけを残す。
  2. §2の軸1に「repositoryの外」を足す。一時ファイルの扱いは効果からは導けず、持ち主の事実として扱う必要がある。
  3. §6のレスポンシビリティに「担当範囲を返すまで」を含める（OPT-074の返却漏れ）。
  4. §7の「判断点が出たら止める」の差に、「影響する項目だけ止める」という実地の形を足す（RBT-042の範囲eraseの不具合）。
  5. §8・§11の番号の使い回しとG-1の採番状態は、`TASK_RULES_V2.md`の「Task ID採番状態」で解消済みと書ける。
  6. §8・§11のcommitとtaskの結びつき：10-15以降のcommit 149件のうち、件名にtask番号があるのは2件。まだ未決。
  7. §9の検証案は未実施。代わりに、担当適性の面談と、型別補完の往復の観測がある。
- 配置の理由: `Maintanance/`直下のfolderを減らしたいので、しばらくは`Testing/`で預かる（ユーザー、同日「しばらく我慢してTestingであずかっててほしい」）。
  内容がテスト専用だからではなく、一時的な預かり先である。
- 資料の由来: ユーザーの見立てでは、この草案は`AGENTS.md`の原型である（同日）。`Testing/Fixtures.md`冒頭の
  ユーザーの振り返り（情報共有の始まり・正本運用の原型）と同じ形で、README冒頭に由来を残す。
  あわせて、`Fixtures.md`1行目のように「姫の持ち物ではなく、誰でも参照・手入れの提案をしてよい」と明記する。
- 預かり後の見直し候補: 内容は協働全体の判断の物差しなので、直下の整理が済んだら`OPS-046`（調整ノウハウ）などの紐付け先と置き場所を見直す。判断はユーザー。
- 対象外: `AGENTS.md`・`CLAUDE.md`・Registryの規則への昇格。草案は「規則へは昇格させず、この区別のまま保持する」としている。
- 前提・既存task候補: `TEST-005`（紐付け先）。元の作成taskは`OPS-037`（DONE）。配置の変更・紐付けには`OPS-044`・`DOC-030`の手順が関わる。
- 担当候補・受入担当: Astra（採番・配置・紐付け）/ 内容の採否はユーザー。姫は所見の提供と、`TEST-005`の維持文書側の参照更新。
- 停止条件: 草案の本文を書き換える必要が出たら、占有の差し戻し（草案§4「確定は手放すこと」）をユーザーに確かめる。
- 成果・検証: 未着手（記録のみ）
- Codex reconciliation: 2026-10-16 / Astra。`TEST-007`としてACTIVEへ正式登録。実施済み部分と残作業は[照合記録](../Current/CLAUDE_QUEUE_RECONCILIATION_2026-10-16.md)に分離。今回の処理は採番・接続であり成果の受入完了ではない。

<!-- 2026-10-16 Astra: ユーザー指示により、上記の作成時パス Maintanance/TestRebuild2026/ は Maintanance/History/TestRebuild2026/ へ移動済み。原依頼・成果報告の記載は当時のまま保持する。現在の配置と受入状況はHIST-003の詳細正本を参照。 -->
