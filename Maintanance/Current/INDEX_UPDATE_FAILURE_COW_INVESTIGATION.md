# index指定更新の失敗時CoW調査

2026-10-16 / RBT-047 / 作成・受入Astra、担当Claude（姫）。CP-20261016-010から正式登録。ユーザーが姫への委任を許可した。現在の目標との関係はNEAR（赤黒木品質の不具合候補の切分け）。

## 目的と現時点の事実

更新がnilを返す場合にも共有storageが複製されるかを再現し、修正の必要性と安全な順序変更を判断できる材料を返す。Astraも3実装でensureUniqueが失敗判定に先行することを読解確認した。実行での再現、コスト、バグ認定はまだない。

対象:
- RedBlackTreeMultiSet.update(_:at:)（通常構成）
- RedBlackTreeMultiMap.updateValue(_:at:)（通常構成、戻り値Value?）
- 同互換構成の+Deprecated.swift（COMPATIBLE_ATCODER_2025、戻り値Element?）

## 依頼と完了条件

1. 現行コードで、共有時と非共有時、正常更新とnilで終了する経路を比較する。既存Test as Specの観測方法を使い、共有元・更新先の要素、storageの共有／複製を確認する。MultiSetは有効indexで不一致値、契約でnilを保証する無効indexを区別する。無関係indexの未保証動作を新しい契約にしない。
2. 互換構成を別に確認する。環境上実行できないものは理由と実行手順を返し、成功扱いしない。
3. 修正案を文章または差分案として返す。元storageで検査後、CoW後のindexを解決し直す必要性・世代・成功経路の検査回数を説明する。生ポインタをCoW越しに持ち越さない。等価判定の副作用や呼出回数も検討する。
4. 実行コマンド・終了結果・入力版・再現証拠・修正する場合の回帰テスト案を返す。性能は読解上の見積りと実測を分ける。公開性能の確定、CI起動やpushはしない。

## 編集範囲

新規の本件専用テスト `Tests/RedBlackTreeTests/IndexUpdateFailureCoWInvestigationTests.swift` と `Maintanance/Current/Evidence/RBT-047/`、下記Returnのみ。既存ファイルがあれば上書きせず返す。既存テストの変更、製品ソース、公開文書、Registry、Rules、本依頼本文は編集しない。製品修正は委任していない。調査テストが現行で意図的に失敗するなら通常suiteへ失敗状態を混ぜず、証拠側に再現手順として残す。

着手・終了時に対象3実装のhashを記録。競合時は影響範囲を止める。一時物はCOMMONSに従う。返却後は作業範囲を解放し、成果原文を固定する。commitしない。任意の観察記入とHimeキャッシュの常設許可は維持。

## 停止条件

公開契約の変更が必要、または現在の順序が不可欠と判明したら理由を返す。性能改善のため別APIや木全体の設計変更へ広げない。

## Return（Claude編集欄）

2026-10-16 20:48〜20:56 / Claude（姫）。入力版HEAD `f6e181b2`。

**対象3実装のSHA-256（着手時・終了時とも同じ）:** `RedBlackTreeMultiSet.swift` `465e345f…0901`、`RedBlackTreeMultiMap.swift` `10edbcd3…0c91`、`RedBlackTreeMultiMap+Deprecated.swift` `531a69f6…0ed9`。

**結論:** 3実装とも、共有中にnilで終わる更新でCoW複製が1回起きることを実行で再現した。修正案（検査を先に行い、複製後にindexを解決し直す）を一時コピーに当てると、失敗時の複製はなくなり、MultiSet・MultiMapの既存testも通った。今の順序が不可欠だという根拠は見つからなかった。バグ認定はユーザーの判断に残す。

1. **観測方法:** 既存のCopyOnWrite testと同じ`AC_COLLECTIONS_INTERNAL_CHECKS`の内部カウンタ`__tree_.copyCount`を使った。複製するとコピー先のheaderだけが1増える。公開契約ではない。
2. **通常構成（`normal.log`・`reproduce-normal.log`）:**
   - 共有中の成功更新は複製1回で、共有元は変わらない（MultiSet・MultiMapともpass）。
   - 非共有のnil経路は複製しない（pass）。
   - 共有中のnil経路で「複製しない」を期待すると、5件ともcopyCountが0ではなく1で失敗した。MultiSetは有効indexで`==`不一致、`endIndex`、削除済みindexの3件、MultiMapは`endIndex`と削除済みindexの2件。
   - 契約でnilを保証するのは`endIndex`と削除済みindexの範囲だけにした。無関係な木のindexは使っていない。
3. **互換構成（`compat.log`・`reproduce-compat.log`）:** `+Deprecated.swift`の`updateValue(_:at:) -> Element?`で、共有中の`endIndex`更新が複製を起こすことを同じ方法で再現した（1件fail）。成功経路と非共有のnil経路はpass。互換構成でMultiSetの`update(_:at:)`は定義されないので対象外。
4. **修正案（`fix-draft.diff`、製品には未適用）:**
   - 元のstorageで`__purified_`し、有効性を確かめる。MultiSetは`==`もここで1回だけ評価する。
   - その後`ensureUnique()`を呼び、複製後の木でindexを解決し直す。検査で得たポインタはCoWの向こうへ持ち越さない。
   - 解決し直しが失敗するのは、検査を通った後なので起きないはずの経路である。黙ってnilにせず`fatalError(.invalidIndex)`とした。nilにするかはAstraの判断に任せる。
   - 世代と検査回数:
     - `ALLOW_CROSS_TREE_INDEX`（既定で有効）では、非共有なら2回目の解決は`_lazyDetach`が同じなので速い経路を通る。
     - 共有なら、複製後の木で`__retrieve_(tag)`による引き直しになる。現行でも複製後に同じ引き直しをしているので、増えるのは非共有・共有とも速い経路の解決1回だけ。
     - `==`の呼び出しは現行と同じ1回で、評価する時点が複製の前に変わる。等価判定に副作用があっても回数は変わらない。値はまだ複製前の元storageから読む。
5. **修正案の検証（一時コピー）:** 期待を有効化して実行した。通常構成は`IndexUpdateFailure|RedBlackTreeMultiSet|RedBlackTreeMultiMap|Multiset|Multimap`の373件、互換構成は`IndexUpdateFailure|RedBlackTreeMultiMap|Multimap`の97件で、すべてpass（`fix-draft-*.log`）。全体suiteは回していない。death testは環境上skipされるものがある。
6. **性能:** 計測していない。読解上の見積りは次のとおり。
   - 成功経路：速い経路の解決が1回増える（O(1)）。
   - 失敗経路（共有時）：O(n)の複製がなくなる。
   - 公開性能の確定はCIの流儀に従う。
7. **回帰テスト案:** `IndexUpdateFailureCoWInvestigationTests.swift`の`RBT047_EXPECT_NO_COPY_ON_FAILURE`の5件＋互換1件を、修正と同時に条件なしへ移す。通常のCopyOnWrite testの置き場（`*_98_CopyOnWriteTests.swift`）へ移すかはAstraの判断。

**成果物:**
- 新規test：`Tests/RedBlackTreeTests/IndexUpdateFailureCoWInvestigationTests.swift`。通常suiteには現行で通る4件（互換構成では2件）だけを置き、失敗する期待はflagの内側に入れた。
- 証拠：`Evidence/RBT-047/`（READMEに実行コマンドと終了結果の一覧）。

**未確認:**
- 全体suite。
- Linux。
- 実測性能。
- Xcode上での実行。

**作業の経過:** testファイルは作成後、git上で`A`（staged）になっていた。私は`git add`を実行していない。誰がstageしたかは確かめていない。一時物は削除済み。

**作業終了。** 範囲を解放する。commitはしていない。

## Astra検収（2026-10-16）

調査成果を受入。3製品ファイルのhashが返却の入力版と一致し、製品差分がないことを確認。専用テスト・差分案・保存ログを読んだ。通常5経路・互換1経路でcopyCountが期待0に対して1となる失敗ログ、差分案での成功ログを確認した。Astra自身による再実行はまだしていないため、実行結果はClaudeの保存証拠による。製品への適用・全面的な安全性確認は別。

修正は検査先行・CoW後再解決の方向が妥当と考える。ただし再解決失敗時をnilからfatalErrorへ変える点は、適用前に契約と不変条件を確認する。単純に差分を適用しない。CoW費用をO(n)とする記述も現要素数だけで確定せず、削除履歴等を含むstorageの複製費用として扱う。成功経路への実測影響は未確認。

現時点で確定したのは「nilで終わる更新でも共有storageを複製する」という観測。修正を行うかのユーザー判断とcommit確認を待つ。原Returnは保持する。

## ユーザー預かりへの分離（2026-10-16）

ユーザー指示により、nil→fatalErrorを含む修正方針判断を[ RBT-048](INDEX_UPDATE_FAILURE_COW_USER_DECISION.md)へ分離した。USER_ONLYとして預かり、判断前の製品修正は行わない。本調査の受入記録は保持し、commit確認だけを本taskに残す。

## 調査完了記録（2026-10-16）

ユーザーのcommit承認によりRBT-047をDONEとする。RBT-048のユーザー預かり判断は未完了のまま維持し、製品ソースへの修正案の適用はしていない。

## 追加調査による訂正への参照（2026-10-16 / Astra）

原Returnのdeath test skip記述は、[RBT-048追加調査と受入](INDEX_UPDATE_FAILURE_COW_USER_DECISION.md#追加調査の受入2026-10-16--astra)に訂正を残した。原返却は保持。通常構成の56件成功ログを確認済み。製品修正・判断の承認ではない。
