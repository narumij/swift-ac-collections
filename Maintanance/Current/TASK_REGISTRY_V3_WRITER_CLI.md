# V3更新CLIの隔離接続

## TL;DR
受入済みDB操作を、AIが明示要求ファイルで実行・照会できるコマンドにする。更新内容や権限を推定しない。本番DBには接続しない。

OPS-174 / EXECUTION / Astra調整・姫 / OPS-167 K7 / 2026-10-19継続指示。

## 範囲と受入
既存read/export/operation照会、w3.apply、adapter.plan_groups/apply_groupsの薄いCLI。明示DB path・operation ID・世代・actor・evidence、保存群の選択・resolution・ancestryをJSONで渡す。内容を推定補完せず、成功・再送・競合・保留・拒否とexit statusを機械可読で返す。応答不明時に新しいoperation IDを勝手に作らない。既存DBを誤pathで空作成しない。

試験はTemporaryDirectoryのfixture DBとsubprocess。更新、履歴照会、再送、異なる要求、世代違い、復元後停止、群の部分結果、入力不正と存在しないDBを検証する。計画確認だけではDBを書き換えない。stateや目的の判断はCLIの仕事にしない。

新しい書込operation、focus/gate/recordedDone、復旧再開、generated views、本番server接続は対象外。既存機能の無効化を切替条件として採用しない。変更はexperiment内CLI/test/README、必要な既存helperの限定接続補正のみ。姫が実装/試験、Astraが受入/記録/commit。
