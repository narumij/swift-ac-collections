# 判断の補助DB（CLI運用）

## TL;DR
2026-10-19に日常利用を開始。判断の正本は文書/決定記録のまま、本文の写し・出典・改訂・参照をSQLiteへ保存する。Studioサーバーや画面には未接続。

- DB: `Maintanance/RegistryApp/Data/decision-assist.sqlite3`（Git対象外）
- 初期登録: `DEC-VERSION-ORDER`（版順）、`DEC-CARD-DOCUMENT`（文書先行）、`DEC-RESTORE-ISSUANCE`（復元後の採番条件）。IDは判断専用でRegistry task IDではない。
- 原記録と導入結果: [DECISION_DB_STUDY](../../Current/DECISION_DB_STUDY.md)、[導入証拠](../../Current/Evidence/OPS-158/production-activation.json)。

## 普段の照会
リポジトリ直下で実行する。照会は読取専用。
```sh
python3 Maintanance/RegistryApp/decisions/decision_cli.py query --db Maintanance/RegistryApp/Data/decision-assist.sqlite3 --id DEC-CARD-DOCUMENT
```
`--review`を足すと、その判断の古い/撤回済みコピーの確認候補を表示する。記録があることは現在の効力や権限の証明ではない。未登録の判断もある。出典と適用範囲を確認する。

## 更新
単一の調整担当が元の決定を確認して行う。登録者actorと決定者decided_byを分ける。
1. CLI `backup --db <DB> --to <新しいsnapshot>`。保存先は `/Users/narumij/Documents/RegistryStudioBackups/swift-ac-collections/`。既存snapshotへ上書きしない。
2. `apply --db <DB> --op <固有操作ID> --request <JSON>`。操作はregister/propose/record_adoption/record_withdrawal/add_reference。既存実装docstringに入力欄がある。
3. 応答不明なら同じID・同じ本文で再送。内容を変更する場合は新ID。競合は原記録と現在の採用改訂を照合し、後勝ちにしない。
4. query/export/validateで反映結果を確認し、反映後にも別名backupを作る。新IDと出典は作業正本へ記録する。

元判断を変更しただけではコピー本文は変わらない。確認後、add_referenceのsupersedesで参照を置き換え、旧参照も残す。誤記も新改訂として扱う。撤回された改訂を直接再採用せず、新改訂を提案する。

## 保全と停止
backupはSQLite APIで一貫したsnapshotを作る。validateは整合性・schema・履歴からの状態復元を確認するが、最新性や決定内容の正しさを保証しない。同じMac内のbackupは端末全損を防がない。
喪失/破損時は書込停止。backupはqueryの--dbに指定して読取確認できる。古いsnapshotから新しい判断がなかったと推測しない。initの再実行や文書からの自動再構築は行わず、復旧方針を確認する。復旧writerは未提供。

## 実装と検査
Evidence/OPS-158/durableは受入時の固定証拠。今後の変更先はこのディレクトリ。17試験は一時DBのみ。
```sh
python3 -B -m unittest discover -s Maintanance/RegistryApp/decisions -v
```
参照の意味、決定権限、別範囲の関係は機械判定しない。出典監視・UI・全量移行はない。全履歴の畳み込みで照会するため、規模が増えたら計測して改善する。
