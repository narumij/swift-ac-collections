# Registry V3 隔離DB読取実験

## TL;DR
設計案を小さな隔離実験で確かめる。構造・順序・HEADによる読取範囲が保存できることを試す。本番DB、Studio、現行正本のデータは変更しない。

OPS-160 / EXECUTION / Astra調整・姫。2026-10-19ユーザー「いえす」により実装承認。

## 範囲と受入

設計元は[TASK_REGISTRY_V3_DESIGN.md](TASK_REGISTRY_V3_DESIGN.md)の「既決事項の回収と設計調査の結論」。明示順fixtureを使い、汎用folder比較方法や到達状態の新規規則は決めない。

成果は `Maintanance/RegistryApp/Experiments/registry_v3_read/` の独立コード・fixture・再現手順。SQLiteはメモリ内または実験専用一時領域のみ。現行server/import/syncの実装は変更しない。更新/採番APIと本番移行は範囲外。

正常構造、未接続・末尾ゲート・任意ゲートID、カード順、現在区間/全体、境界端点、グラフ区別、重複/端点欠落/循環の拒否を試験する。共通部分のみ現行readerと照合し、既知の実装差は仕様期待値を使う。期待値を実装自身から生成するだけの検査にしない。

姫は実験フォルダを担当。Astraは正本とRegistryおよび独立受入を担当。返却は連絡DB。commitはAstra。
