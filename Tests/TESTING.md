# テストメンテナンス・ダッシュボード

現在情報だけを保持する。作業規則は `Tests/CLAUDE.md`、CodexからClaudeへの依頼は
`Maintanance/CLAUDE_TASK.md`、2026-10-03以前の詳細は `Maintanance/Archived/TestDashboard/TESTING_REFERENCE.md`、2026-10-15までに完了した
作業記録と旧handoffは `Maintanance/Archived/TestDashboard/TESTING_HISTORY_2026-10-15.md` にある。
参照資料は必要な箇所だけ検索し、通常は通読しない。

## 目的

- テストを継続的に整理し、公開APIの仕様不足や実装不具合を発見する。
- テスト成功だけで完了とせず、公開API一覧と実装に対する不足を確認する。

## 優先事項

赤黒木の完成判断を優先する。C++挙動比較はSet/MultiSet/Dictionary/MultiMapの
4組へ展開済みで、`CppBehaviorReferenceTests` 35件の比較が成功している。
挙動比較ターゲットはルートパッケージへ置き、性能測定用の`CppBenchmarks`は
`Benchmarks`へ残す。独立した公開範囲の縮小は区切り済みである。現在の確認地点は、
Swift Collectionsの`ContainersPreview`が安定した時点で行うIndex契約の最終判断である。

## 現在地

- 2026-10-15 05:52 JST、Debug・macOSの`swift test`は8 XCTest target・XCTest 1258件・Swift Testing 197件で失敗0件。
  RedBlackTreeとPermutationModuleの公開API 476件、ElementBufferModuleとOptionalElementBufferModuleの公開名各8件は、
  いずれも番号付き仕様testから参照されている（後者2つは名前の文字列照合）。互換mode・Release・Linuxは未確認。
- OptionalElementBufferModule: 番号付き8仕様群を維持し、通常35件・Death Test 26件がDebug、Release、ASanで
  成功した現行記録がある。View寿命とstrict memory safetyは未達、`Sendable`、`-Ounchecked`、外部性能、
  一般利用・競技利用のValidationは未検証として品質評価へ分離している。旧`OptionalArrayModule`の
  compatibility smoke testは、facade targetの終了に合わせて削除した。
- ElementBufferModule: 番号付き仕様群（`BareArray_0_`〜`BareArray_7_`）、Death Test、借用参照のDeath Testを維持する。
  旧subscript・Viewのdeprecated指定は削除済みで、Sourcesにdeprecated指定はない。1.0提供対象外で、保守範囲は
  `Maintanance/QUALITY_REQUIREMENTS.md`に従う。旧`BareArrayModule`のcompatibility smoke testは、facade targetの終了に
  合わせて削除した。2026-10-13時点の詳細記録は移動分にある。
- PermutationModule: runtime-check View通常版は有効な通常runtime test 2件（Span反復1件・手動列挙1件）と
  失効Death Test 2件だけが現行契約を直接確認し、旧COW版38件は`#if false`の履歴資料である。
  borrowed Span版は番号付き5群・runtime 25件が成功しているが、借用寿命のcompile-pass／compile-failは
  再実行可能なfixtureになっていない。AtCoder 2025互換modeの5件は独立した仕様として維持する。
- AcCollections: RedBlackTreeCollections、PermutationModule、OptionalElementBufferModule、
  ElementBufferModuleの再公開テストを追加済み。互換modeでは旧名RedBlackTreeModuleも再公開する。
  別テストターゲットでもRedBlackTreeのDebug寿命カウンタを各テスト後に検査・初期化する。
- RedBlackTree: 4型、共有View、BoundExpressionの連番Test as Specification整理済み。

## 判断待ち

- UnsafeNode/RawBufferのテスト層は統合しない。単層テストはテスト内の算術から期待値を
  独立計算し、`MemoryLayout`、UnsafeNodeの移動・payload位置、Bucket全体の所有byte、
  queue/accessor/traverser間のstrideをそれぞれ検証する。層間クロスチェックは、別実装の
  reference計算とRawBuffer計算、および各要素位置が一致することを複数型・容量で検証する。
  fixtureやproduction helperへ期待値算術を共有すると同じ誤りで両辺が一致し得るため、
  helperとpayload matrixの重複は意図的に維持する。
  stride一致の重複assertionは型範囲の広さのため残す。`RawBufferHeadFixture`がproductionの
  `pairLayout.alignment`ではなく同じ分岐結果になるpayload alignmentを渡す差異は、必要に
  なった場合だけ直す凍結中の任意改善とする。
- `RedBlackTreeTestSupport`は自動テストから呼ばれるfixture・assertion・invariant・test-only
  accessor等の再利用基盤、`DebugAdditionals`は人間向けdump/Graphvizと凍結した旧実験を置く。
  `_LazyTieWrap+Debug.swift`と`unsafe_node+debug.swift`は自動テストから使われるが、現配置を
  文書化された例外として許容し、移動だけを目的とする作業は行わない。
  `TransitionFromLegacy/`、`ThreeWay+Old/`、無効化されたUnsafeTree debug/fixture群、
  `_NodePtr_.swift`内の`#if false`部は、ユーザーが再開を決めるまで凍結する。
- 未結線コードは段階的に削除する方針だが、個々の削除はユーザーが決定し、再開指示まで
  凍結する: `_Reverse4`関連、`swap_key`/`swap_mapped_value`、`outOfRange`/`keyMismatch`、
  `payloadLayout`/`__root_ptr()`、RawRangeの`contains(range:pointer:)`、`_TrackingTag.retire`。

## 直近の引き継ぎ

- `Tests/TESTING.md`の古い記載を`Maintanance/Archived/TestDashboard/TESTING_HISTORY_2026-10-15.md`へ原文のまま移した。
- ElementBuffer系の仕様testのファイル名は改名前の`BareArray_*`・`OptionalArray_*`のまま。監査の正本がこの名前を
  引用しているため、改名するかは未決定（記録なし）。
- test内に未使用変数の警告が数件ある（`RedBlackTreeInternal_ComparatorsTests.swift`など）。仕様には影響しない。
- RBT-042 S1〜S4：Setのヒント付きinsert/updateの参照identity、throwするpredicate（filter・erase(where:)）、
  form系集合演算の共有元・相手の不変、削除済みIndex Death Testのsetup分離を追加した。範囲版`erase(_:where:)`の
  predicateエラーがtrapになる問題はAstraが4型で修正し、修正前失敗・修正後成功の回帰テスト8件を追加。
  修正と検証の記録は`Maintanance/Current/RED_BLACK_TREE_TEST_AS_SPEC_REVIEW.md`末尾。Claude返却原文は`Maintanance/CLAUDE_TASK.md`。
- RBT-043（MultiSet）・RBT-044（Dictionary）は受入済み。RBT-045（MultiMap）：Bound公開動作を
  `RedBlackTreeMultiMapBoundPublicBehaviorTests`へ分離（3型とも同じ形、Debug専用の`isValid`・copy countは元の条件）。
  削除済みIndexへのupdateValue、throwする変換・filter・erase、同一参照Valueを複数エントリに持つ場合の寿命を追加した。
  重複keyでの`.lessThanOrEqual(k)`はDSL.mdで`find(k)`の位置と定義され、どの値かは規定外。返却は`Maintanance/CLAUDE_TASK.md`。

最終更新: 2026-10-16 03:15 JST / Claude Opus 5.5

このファイルは現在地を上書きして保つ。長文報告や年代順ログは追加せず、引き継ぎは
最大5項目とする。ユーザー方針の変更・削除はユーザーへ確認する。
