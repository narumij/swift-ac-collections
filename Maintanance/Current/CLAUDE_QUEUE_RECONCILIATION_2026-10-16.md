# Claude採番待ち3件の正式登録

2026-10-16 / Astra。ユーザーの「ひめの未採番やって」に基づく正式登録。今回の範囲は仮IDの照合・採番と、実施済み部分／残作業の区別。成果の最終受入や新しい作業の完了認定は行っていない。

## 対応

| 仮ID | 正式ID | 内容 | 現在地 |
| --- | --- | --- | --- |
| CP-20261016-001 | HIST-003 | テスト再建の記録作成・受入と入口接続 | 5ファイルが実在。17d40163でcommit済み。独立照合と入口接続が残る |
| CP-20261016-002 | TEST-006 | テスト整備文書のTesting集約と参照更新 | dcb9e3ceで移動・一部参照更新済み。制度・Registry等の参照更新と受入が残る |
| CP-20261016-003 | TEST-007 | 判断座標草案のサルベージと恒久taskへの接続 | 依頼記録のみ。未実施 |

各taskの状態はRegistryを正本とする。恒久task TEST-005・DOC-030・HIST-001自体を完了扱いにしない。

## HIST-003

作成者はClaude（姫）、受入・入口接続はAstra。資料は[README](../History/TestRebuild2026/README.md)と[EVIDENCE](../History/TestRebuild2026/EVIDENCE.md)。CSVと図を含む5ファイルで、queueの「4ファイル」という記載とは数え方が異なる。今回確認したのは実在とcommitまでで、集計値・8件の不具合・図と説明の独立照合は未実施。

2026-10-16、ユーザーがHistoryフォルダの作成と2フォルダの移動を明示したため、Astraが`Maintanance/History/RefactoringFromAtCoder2025/`と`Maintanance/History/TestRebuild2026/`へ移動し、参照と文書入口を更新した。Fixturesは今回の移動対象に含めない。配置決定は完了したが、件数・根拠・図の独立照合と成果の受入は残る。

## TEST-006

[TESTING](../Testing/TESTING.md)と[Fixtures](../Testing/Fixtures.md)は移動済み。queueではClaudeがbuild成功を報告しているが、今回の独立再実行はしていない。

残作業はTASK_RULES_V2の配置維持例外、TEST-005の維持文書パス、DOCUMENT、AI_TECHNICAL_ORIENTATION、赤黒木品質プロファイルの参照更新と必要な確認。移動前後の差分とmanifest変更、参照先を照合して受け入れる。Tests/CLAUDE.mdはTests側に維持する。旧参照の存在を、移動済み文書を旧位置へ戻す指示とは扱わない。

## TEST-007

元資料は[判断座標の履歴](../Archived/JudgmentCoordinates/README.md)。Testingに一時的に預け、TEST-005へ紐付けるユーザー指示をqueueから引き継ぐ。

原文は保持し、写しと案内などの方法で回収する。AGENTSの原型というユーザーの見立て、テスト専用ではなく一時的な預かり先であること、姫専有ではなく誰でも参照・手入れの提案ができることを案内へ残す。草案を現行規則・権限へ昇格させない。

姫の7点の見直し所見は提案として保持し、今回採否を決めない。本文修正は配置と分け、必要な変更と範囲を示してユーザー判断へ返す。OPS-046等への将来の移管も未決。

## 原依頼

[CLAUDE_PENDING_TASKS](../CLAUDE_PENDING_TASKS.md)の各仮IDに、ユーザー指示・成果報告・停止条件を残した。正式登録済みという意味でRECONCILEDとするが、成果受入済みを意味しない。後続でqueueが圧縮された場合も、履歴への経路を保持する。
