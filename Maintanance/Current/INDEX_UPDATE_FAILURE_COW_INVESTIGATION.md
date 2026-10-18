# index指定更新の失敗時CoW調査

## TL;DR（人間向け）

index更新がnilで終わっても共有storageが複製されることを3実装で再現し、調査を受け入れた記録。修正案は製品未適用で、nilからfatalErrorへの変更を含む方針はユーザー専任の別判断へ分離した。全体suite・Linux・実測性能は未確認。

2026-10-16 / RBT-047 / Astra drafting/acceptance; Claude (姫) investigation. Registered from CP-20261016-010 with user permission to delegate. Goal relation: NEAR (red-black-tree quality defect-candidate diagnosis).

<a id="目的と現時点の事実"></a>
## Purpose and facts at registration

Reproduce whether shared storage is copied even when update returns nil, and return evidence to judge need for a fix and safe reordering. Astra read all three implementations and confirmed ensureUnique precedes failure detection. Runtime reproduction, cost and bug designation were not yet established.

Targets:
- RedBlackTreeMultiSet.update(_:at:) (normal)
- RedBlackTreeMultiMap.updateValue(_:at:) (normal, Value?)
- Compatibility +Deprecated.swift (COMPATIBLE_ATCODER_2025, Element?)

<a id="依頼と完了条件"></a>
## Assignment and completion criteria

1. Compare shared/unshared storage and success/nil paths in current code. Use existing Test as Spec observations to check source/target elements and sharing/copying. For MultiSet distinguish mismatch at valid index from invalid indices whose nil is contractual; do not create a contract for unrelated-index unspecified behavior.
2. Check compatibility separately; return reason/procedure for unavailable configurations, not success.
3. Return prose/diff proposal. Explain checking original storage then resolving index after CoW, generations and success-path check counts. Carry no raw pointer across CoW; consider equality side effects/counts.
4. Return commands, exits, input revision, reproduction evidence and regression suggestions. Separate read-based cost estimates from measurements. No public-performance conclusions, CI start or push.

<a id="編集範囲"></a>
## Editing scope

Only new dedicated `Tests/RedBlackTreeTests/IndexUpdateFailureCoWInvestigationTests.swift`, `Maintanance/Current/Evidence/RBT-047/` and Return below. If already present, return instead of overwrite. No existing tests, product sources, public docs, Registry, Rules or assignment edits. Product repair is not delegated. Keep intentionally failing reproduction out of ordinary suites and preserve its procedure as evidence.

Record hashes of three implementations at start/end. Stop affected scope on conflict. Follow COMMONS for temporary artifacts. Release work scope after Return and fix original output. No commit. Standing optional observations/Hime-cache permission remains.

<a id="停止条件"></a>
## Stopping conditions

Return reasons if public-contract changes are required or current ordering proves necessary. Do not broaden into other APIs or whole-tree design for performance.

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

<a id="astra検収2026-10-16"></a>
## Astra acceptance review (2026-10-16)

Accepted investigation. Confirmed three product hashes match input and no product diff. Read dedicated tests, draft diff and logs: five normal/one compatibility failure paths have copyCount 1 versus expected 0; draft-fix logs pass. Astra has not rerun, so execution results rely on Claude's saved evidence. Adoption/full safety are separate.

Check-first/re-resolve-after-CoW seems reasonable, but changing re-resolution failure from nil to fatalError requires contract/invariant review before applying. Do not simply apply the diff. CoW O(n) refers to storage-copy cost including deletion history, not just live count. Measured success-path effects unknown.

Established observation: shared storage is copied for updates ending in nil (「nilで終わる更新でも共有storageを複製する」). Await user repair decision/commit confirmation; preserve original Return.

<a id="ユーザー預かりへの分離2026-10-16"></a>
## Separate user-reserved decision (2026-10-16)

At user direction, separated repair-policy judgment including nil→fatalError into [ RBT-048](INDEX_UPDATE_FAILURE_COW_USER_DECISION.md), USER_ONLY. No product repair before decision. Preserve acceptance here, retaining only commit confirmation in this task.

<a id="調査完了記録2026-10-16"></a>
## Investigation completion (2026-10-16)

User commit approval makes RBT-047 DONE. RBT-048 remains unresolved; no draft applied to product sources.

<a id="追加調査による訂正への参照2026-10-16--astra"></a>
## Reference to additional-investigation correction (2026-10-16 / Astra)

Correction to original Return's death-test skip statement is in [RBT-048 additional investigation/acceptance](INDEX_UPDATE_FAILURE_COW_USER_DECISION.md#追加調査の受入2026-10-16--astra). Original retained. Confirmed normal-configuration 56-success log. Not approval of product repair or policy.

## 根拠と更新条件の追記（2026-10-17 / 姫・Opus 5.5 / OPS-076第4区切り）

入力版`1175e583b1857819e9e0b07b83a1cb5fc8be657a`。本文・原返却は変えていない。確認は`git show <版>:…`等の固定treeの読み取りだけで、実行・再レビューはしていない。

| 主張 | 確認方法と結果（成立範囲） | 更新のきっかけ |
| --- | --- | --- |
| 調査は入力版HEAD`f6e181b2ab31dcd17c51c11236a6b5dd4b1024b8`で行われた（33行目） | 対象3実装のSHA-256を版で計算すると、`Sources/RedBlackTreeCollections/RedBlackTreeMultiSet/RedBlackTreeMultiSet.swift` `465e345f`、`…/RedBlackTreeMultiMap/RedBlackTreeMultiMap.swift` `10edbcd3`、`…/RedBlackTreeMultiMap+Deprecated.swift` `531a69f6`で、35行目の先頭8桁と一致。`f6e181b2`→版の`Sources`・`Package.swift`の差分は3ファイル（`AcCollections.docc`・`OptionalElementBufferModule`の2つ）で、`Sources/RedBlackTreeCollections/`の差分はない | 対象3ファイル、または呼出先（CoW・index解決）を含む`Sources/RedBlackTreeCollections/`の変更 |
| 調査用testと証拠が版にある | `Tests/RedBlackTreeTests/IndexUpdateFailureCoWInvestigationTests.swift`（`RBT047_EXPECT_NO_COPY_ON_FAILURE` 4か所）と`Evidence/RBT-047/`：あり | testや証拠の移動・削除 |

成立範囲：言えるのは「対象実装は変わっておらず、過去の結果がどこにあるか」まで。過去の実行結果を現行版で再現したことにはしない（toolchain・構成・テスト側にも依存する）。RBT-048の判断（ユーザー）の有効性も保証しない。再調査するなら、上の差分の所在から絞れる。
