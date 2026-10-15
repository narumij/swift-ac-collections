# RedBlackTree Test as Spec 仕様レビュー

作成者：Astra。2026-10-15。ユーザー指定の「4型をざっと横断 → 型順 → 最後に再横断」を記録する詳細正本。
状態と依存関係の正本は `Maintanance/ProgressV2/TASK_REGISTRY_V2.md`。初回横断の課題候補を以下に記録。型別レビューと最終横断は未実施。

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

### 初回横断（RBT-036、2026-10-15、Astra）

基準HEAD：`c98a0908`。赤黒木source・testに未コミット変更はなかった。並行してClaudeがPermutationのtest・返却・Tests/TESTING.mdを変更しているが、今回それらは編集していない。静的な概観のみ。テスト実行・mutation検証・全API網羅レビューは未実施。

4型とも番号付きの生成・走査・検索・挿入削除・範囲・protocol・値意味論と、内部CoW・Index・Death Test群が存在する。Viewには独立した共通test群がある。共通土台がない状況ではなく、検査の強さと構成別の保証範囲を次に詰める。

#### 課題候補（修正・発注はまだ行わない）

1. **Death Testの終了判定の強さ（4型、優先確認）**。各`*_99_DeathTests.swift`に正確なSwift trap signalを指定する例と、`.failure`を受けてSIGSEGV/SIGBUS/AddressSanitizerを除外する例が混在する。例はMultiSetの逆転範囲・削除済みIndex。後者は意図した契約検査以外の失敗も通し得る。個別レビューでは期待する停止契約とsetupを照合し、必要なものだけ判定強化・negative control候補にする。製品不具合や全Death Testの無効を意味しない。
2. **Map系CoWテストのvalue観測（Dictionary/MultiMap）**。両型の`*_13_ValueSemanticsTests.swift`の`test_copyOnWrite_mutatingCopyPreservesOriginal`は最終結果をkey列だけで比較している。このケース自身はvalueの取り違え・変更を検出しない。型別レビューで既存`*_98_CopyOnWriteTests.swift`、MappedValues View testによる補完を確認し、不足する公開操作経路だけを候補化する。内部のcopy回数の検査と公開valueの独立性は別の証拠として扱う。
3. **CoW・寿命の型間の対応（確認課題）**。Setの`*_15_ValueSemanticsTests.swift`には参照要素の共有・分岐・両コピー破棄後の解放を追うケースがある。他3型の`*_13_ValueSemanticsTests.swift`には同じケースはないが、各RemovalTestsには参照解放testがある。これだけで不足とは確定しない。型別レビューで共有中の保持、最後の所有者の解放、Mapのkey/value、重複要素を既存testがどこまで見ているか確認する。参照要素のdeep copyを要求しない。
4. **空の旧テストと現行証拠の説明（確認済みの文書上の問題）**。Dictionaryの`*_0_InitializationTests.swift`の`testInitWithDuplicateKeysShouldCauseFatalError`は本文がコメントだけで「実テスト不可」と記載するが、`*_99_DeathTests.swift`に`duplicateKeysInUniqueKeysInitializer_terminateProcess`が存在する。検証不足として新規testを増やすのでなく、旧説明と実行件数の読み違いを整理する候補。Setの空のremoveFirst/Last testにはDeath Testへの説明があり、同じ扱いで不足認定しない。

#### 次の型別レビューへ渡す見取り図

- Set：共通Index/Bound/View境界とDeath Test、値意味論の観測を起点にする。
- MultiSet：Setと共通する論点に加え、重複数・等価要素の更新と寿命を確認する。
- Dictionary：上記2・4を起点に、value更新・default subscript・重複統合closureの正常/失敗経路を確認する。例外時に原状回復する等の未記載契約は作らない。
- MultiMap：重複keyごとのvalue保持・更新・削除、MappedValues ViewとCoWを確認する。
- 最終横断：共通testで本当に保証される範囲と型固有差、構成条件を再照合する。

4型のclosure内CoW testは同じ変更を双方へ行うが、Set/Dictionaryでは戻り値の検査、Multi系では個数の変化も検出に寄与する。したがって「同じ最終結果だから独立性を検証できない」と一律に断定しない。途中の非変更側の観測を補う必要があるかを型別で確認する。
MappedValuesの範囲所属検査はAPI-Matrix-Viewの現行事前条件と既存RBT-026を尊重し、今回の課題出しで契約変更・凍結解除しない。内部CoWは`AC_COLLECTIONS_INTERNAL_CHECKS`、Death Testは`DEATH_TEST && !COMPATIBLE_ATCODER_2025`等の条件があるため、testの存在と各構成での実行保証は区別する。

初回横断の到達点である見取り図・課題候補・未確認範囲の記録は完了。型別詳細レビュー・修正は未着手。コミット許可待ちとしてRBT-036をWAITING_USERとする。

2026-10-15、ユーザーがコミットを許可。初回横断の記録を保存し、RBT-036をDONEとする。型別レビューは未着手。
