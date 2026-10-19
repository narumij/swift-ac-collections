# V3構造更新の隔離実装

## TL;DR
辺の削除・つなぎ替え、親子の変更、マイルストーンへの接続をDBでも更新できるようにする。まず作業内訳を確認し、原子的な更新と循環/競合の拒否を隔離試験する。本番変更なし。

OPS-169 / EXECUTION / Astra調整・姫 / OPS-167 K2 / 2026-10-19継続指示。

## 最初の区切り
現行仕様と受入済みV3モデルを読み、edge remove/rewire/constraint、management reparent、milestone link add/remove、task group/permanentの操作契約とファイル単位の内訳を提案する。実装はAstra確認後。

変更前の期待値で競合検査し、削除と追加を伴う操作は一transaction。端点存在/退役/重複/循環を更新後構造で検査する。管理と進捗グラフを混同しない。conditionReviewは未適用編集側に残す。既存UIの禁止条件を無条件に原型仕様へ昇格させず、正本の根拠と分けて示す。

実験folderのみ変更可能。現用template/sync/serve/DB/Inboxは変更しない。版やカード自体の構造更新、採番journal、本番接続は別工程。既存115試験を維持し、拒否時に構造が不変、つなぎ替え途中失敗、旧期待値、再送を検証する。返却は連絡DB、Astraが受入/記録/commit。

## 初回内訳の限定採用（2026-10-19）
LTR-20261019-07CAC2CC55FA4C08A36C63592A7B8BE4を受領。まずprogress/management辺のremove・rewire、progressのflow/constraint変更、明確な方向のmilestone link add/remove/set/rewire、task group更新を隔離実装する。期待値の完全一致・transaction・再送・監査・失敗時復元は提案どおり。

未決方針をコードへ採用しない。単一親制約とreparent専用操作、END→taskの許否、恒久区分変更の権限/操作は今回実装しない。該当操作は実験未対応と明示する（正式禁止ではない）。管理辺の既存モデルへ単一親制約を足さない。制約文のprefixは形式契約へ昇格させず、明示した文が必要という範囲に留める。未決項目は切替設計OPS-167で解決する必要がある。

## 初回実装の受入確認（未完了）
2026-10-19。返却LTR-20261019-6FFFB7E6DF4C41C08B867C5FF335B10C。Astraが全129試験を再実行し成功。しかし追加確認でremove_edge(progress, TASK-002→TASK-003, base={})が成功し、基準値検査を省略できることを再現。補正の詳細は連絡DBのOPS-169受入補正依頼を参照。削除/つなぎ替えの必要base必須化、未知/不正base拒否、setterで退役端点の更新拒否を依頼した。受入・commitは補正後。

## 限定区切りの受入（2026-10-19）
補正返却LTR-20261019-EBB117B63B87471399D5A9BC6AAC211Cを受入。Astraが全134試験をResourceWarning有効で独立再実行し25.542秒で成功、警告なし。必要baseの完全一致検査とsetterのlive端点検査をコードでも確認。削除/つなぎ替えの空・不足・未知・不正base拒否、退役端点の更新拒否と削除許可、失敗時全取消、再送を検証した。

今回の明確な規則に限る構造更新APIは完了。単一親方針・reparent専用操作・END→task・恒久区分setter・制約prefixは未採用のままOPS-167で追跡。Studio保存の構造変更群への変換、版/カード編集、本番接続は別工程。
