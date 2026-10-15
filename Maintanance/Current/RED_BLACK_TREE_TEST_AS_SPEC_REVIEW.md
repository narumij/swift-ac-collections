# RedBlackTree Test as Spec 仕様レビュー

作成者：Astra。2026-10-15。ユーザー指定の「4型をざっと横断 → 型順 → 最後に再横断」を記録する詳細正本。
状態と依存関係の正本は `Maintanance/ProgressV2/TASK_REGISTRY_V2.md`。今回は計画・登録のみで、レビュー結果はまだない。

## 目的と境界

現行の公開契約に対し、既存のTest as Specが何を保証し、何を保証できていないかを確認する。テスト件数ではなく、仕様の不足、境界条件、誤った実装でも通る検査を重視する。
担当はAstra。型順はSet → MultiSet → Dictionary → MultiMapとする。各段階を記録してから次へ進む。
今回の委任はレビューであり、production・既存test・公開契約の修正、Claudeへの追加発注、凍結taskの再開は含めない。必要な修正は結果から切り出す。

## 入力と確認方法

- `Sources/RedBlackTreeCollections/Documentation/API-Matrix.md`、`API-Matrix-View.md`、`Quality-Profile.md`と、関連するDesign文書・現行公開APIコメントを必要な範囲で読む。
- `Sources/RedBlackTreeCollections/RedBlackTreeSet/`、`RedBlackTreeMultiSet/`、`RedBlackTreeDictionary/`、`RedBlackTreeMultiMap/`と`Tests/RedBlackTreeTests/`を起点に、実際の契約・test・共通実装へたどる。資料間の食い違いは仕様の新規決定で埋めない。
- 順序・重複・検索境界・挿入削除・空状態・Index/Viewの有効範囲・CoWと値意味論・参照要素の寿命を、各型に実在する契約に応じて見る。全組合せの先行展開はしない。
- 静的照合を基本とし、成立が不明な点は必要な対象だけ実行・compilerで確かめる。実行時は関連のテスト手順を確認し、実行と未実行、対象構成を区別する。
- 各段階で基準commitと関係ファイルの未コミット差分を記録する。並行変更があれば影響する結論を再照合する。Permutationの作業範囲は編集しない。

## 工程と受入条件

| ID | 範囲 | 到達点 |
| --- | --- | --- |
| RBT-036 | 4型の初回横断 | 共通契約・型固有契約と既存testの配置を概観し、型別レビューの見取り図と未確認範囲を残す。初回だけで品質の合否を結論しない。 |
| RBT-037 | RedBlackTreeSet | 初回横断を入力に、Setの公開契約とtestを照合し、不足・偽陽性・境界条件を根拠付きで記録する。 |
| RBT-038 | RedBlackTreeMultiSet | Setレビューの共通論点を引き継ぎ、MultiSet固有の重複・順序・操作契約とtestを照合する。Setの結果をそのまま保証として転用しない。 |
| RBT-039 | RedBlackTreeDictionary | 先行レビューを入力に、Dictionaryのkey/value・更新・Viewを含む現行公開契約とtestを照合する。 |
| RBT-040 | RedBlackTreeMultiMap | 先行レビューを入力に、MultiMapの重複keyとvalue・更新・Viewを含む現行公開契約とtestを照合する。 |
| RBT-041 | 4型の最終横断 | 4型の個別結果を再照合し、型間の不整合・共通実装の未検証・重複指摘・個別レビューの見落としを整理し、修正候補と判断待ちを分ける。 |

各段階の受入条件は、対象契約と確認したtestへの経路、保証範囲、未確認事項、根拠付きの指摘を残すこと。問題がなければ確認範囲を明記して指摘なしとする。実装反映の完了や品質全体の合格まで意味を広げない。
新しい製品判断が必要なら、その論点を分離してユーザーへ返し、未決の答えをtest仕様として作らない。既存taskと重なる指摘は既存IDを示し、同じ仕事を重複登録しない。
最終横断は、個別レビューを単に連結するのでなく、共通契約の扱いと型固有の差を改めて照合する。

## レビュー結果

未実施。各段階の結果をここへ追記する。
