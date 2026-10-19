# V3保存処理の現用モジュール統合

## TL;DR
受入済みのV3保存処理をinbox.pyへ統合し、二重実装をなくす。取込履歴が壊れていても正常保存は再開でき、旧保存の照合状態は「不明」と表示する。本番切替や再起動はしない。

OPS-179 / EXECUTION / Astra調整・姫 / OPS-167 S3a / 2026-10-19継続指示。

## 範囲
S3内訳LTR-20261019-7CA4DD1A19B3406CBEF66A62C6EE79A6の保存統合のみ。RegistryApp/inbox.pyへ受入済みv3_inbox機能を統合し、v3_inbox実装を削除して利用側/試験を一本化。従来CLIのdefault Inbox/environmentとlegacy-only動作を維持する。実Inboxは触らない。

IMPORTSの不正行は行番号/理由付きで報告し、V3 workspaceの再開を妨げない。この場合はreconciliation unknown、unresolvedLegacyはNoneとし処理済み/未処理を推定しない。record_importは重複照合不能なら拒否。既存imports呼出し側を確認し、返却型変更で既存利用者を壊さない。隔離P6に不明表示を追加。現用templateへのpatch移植とserveのV3 modeは後続。

## 検証と境界
一時folderで現行legacy互換、mixed保存、不正保存/不正IMPORTS・正常保存再開・記録拒否を試す。既存226試験と関係する現用inbox/serve試験を実行。実server起動/再起動、実DB/Inbox/Cacheの書換えは禁止。姫が実装と返却、Astraが独立受入・commit。
