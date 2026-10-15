# Memoize関連リポジトリの依存状況調査

2026-10-16、Astra記録。RBT-005。

## 目的と現在の扱い

ユーザー指定のローカルcheckout `swift-ac-memoize`と`Memoization`について、このリポジトリへの依存状況を調べるDISCOVERY task。ユーザー指示によりACTIVEへ変更した。担当はCodex。状態の正本は[Task Registry](../ProgressV2/TASK_REGISTRY_V2.md)。今回行ったのはtaskの訂正であり、調査結果はまだない。

ユーザーの説明では、もともと必要だったのはこの依存調査である。AIに調査を引き受けてもらえそうになく、進行が負担になって凍結していた。ユーザーによる方針判断待ちとして整理したのは誤りだった。

## 調べる範囲と返すもの

- `/Users/narumij/Documents/GitHub/swift-ac-memoize/`と`/Users/narumij/Documents/GitHub/Memoization/`を調べる。remote URL、branch・commit、未commit差分を記録し、ローカル状態と公開版を混同しない。以前の`Memoize`表記は対象名の誤りとして訂正する。
- 各対象の依存宣言と実際の利用コードから、このリポジトリのどの製品・module・APIに依存しているかを確認する。
- Memoize関連部分の変更・削除がどの利用箇所に影響するか、移行が必要かを根拠付きで整理する。必要に応じて対象を絞ったコンパイル確認を行い、確認済みと未確認を分ける。
- 二つのリポジトリについて依存先・利用箇所・影響・残る不明点をまとめれば、調査の返却条件を満たす。その結果を基に必要な判断や作業を具体化する。

## 境界

旧記録の「外部consumer 2件の移行」を、調査開始の待ち条件にしない。移行の要否自体を今回調べる。移行済みとも、必ず移行が必要とも先に決めない。

「公開終了／正式API化」の二択を調査の結論として固定しない。外部リポジトリの変更、製品方針の決定、APIの削除・公開変更はこの調査に含めない。

## 資料

- [既存監査](../Quality/EXTERNAL_TYPE_EXTENSION_AUDIT.md)
- [ユーザー判断扱いにする前の記録](../Archived/RBT-005_BEFORE_USER_DECISION_2026-10-16.md)
- [今回の訂正前の記録](../Archived/RBT-005_BEFORE_DEPENDENCY_DISCOVERY_2026-10-16.md)
