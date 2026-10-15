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

- 2026-10-16 04:15 JST、Debug・macOSの`swift test`は8 XCTest target・XCTest 1329件・Swift Testing 223件で失敗0件。
  内訳はRedBlackTreeTests 986、RedBlackTreeTreeTests 121、PermutationTests 63、OptionalElementBufferModuleTests 49、
  ElementBufferModuleTests 43、CppBehaviorReferenceTests 35、RedBlackTreeLegacyTests 27、AcCollectionsTests 5。
  同日、RedBlackTreeTestsはReleaseでもXCTest 834件・Swift Testing 120件で成功し、互換modeのtest buildも通る。
  Linuxは未確認。2026-10-16、RedBlackTreeとNextPermutationModuleの公開API 476件がすべて番号付き仕様testから参照されていることを
  Claudeのtask graph（index store）で再照合した。ElementBuffer系の公開名各8件の照合は2026-10-15時点のもの。
- OptionalElementBufferModule: 番号付き8仕様群を維持する。OPT-074の補完後、通常49件・Death Test 25件がDebugと
  Releaseで成功し、所有型のcompiler fixture（`Utilities/Maintenance/CompilerDiagnostics/OptionalElementBufferPublicSurface/`）
  も通る。ASanの成功記録は補完前（通常35件・Death Test 26件）のものである。View寿命とstrict memory safetyは未達、`Sendable`、`-Ounchecked`、外部性能、
  一般利用・競技利用のValidationは未検証として品質評価へ分離している。旧`OptionalArrayModule`の
  compatibility smoke testは、facade targetの終了に合わせて削除した。
- ElementBufferModule: 番号付き仕様群（`BareArray_0_`〜`BareArray_7_`）、Death Test、借用参照のDeath Testを維持する。
  旧subscript・Viewのdeprecated指定は削除済みで、Sourcesにdeprecated指定はない。1.0提供対象外で、保守範囲は
  `Maintanance/Quality/QUALITY_REQUIREMENTS.md`に従う。旧`BareArrayModule`のcompatibility smoke testは、facade targetの終了に
  合わせて削除した。2026-10-13時点の詳細記録は移動分にある。
- PermutationModule（`NextPermutationModule`）: runtime-check View通常版は番号付き7群・XCTest 29件・Swift Testing 16件
  （失効・終端のDeath Testを含む）、borrowed Span版は番号付き5群・XCTest 27件、AtCoder 2025互換modeは5件を独立した仕様として維持する。
  旧COW版（`Tests/PermutationTests/NextPermutationsSequence/`、XCTest 33件・Swift Testing 5件）は全7ファイルが`#if false`の履歴資料である。
  借用寿命のcompile-fail fixtureは再実行可能な形になっていない（`PermutationPublicSurface`は通常ownerの初期化・copy・Sequenceだけ）。
- AcCollections: RedBlackTreeCollections、PermutationModule、OptionalElementBufferModule、
  ElementBufferModuleの再公開テストを追加済み。互換modeでは旧名RedBlackTreeModuleも再公開する。
  別テストターゲットでもRedBlackTreeのDebug寿命カウンタを各テスト後に検査・初期化する。
- RedBlackTree: 4型、共有View、BoundExpressionの連番Test as Specification整理済み。RBT-036〜046の型別レビュー・補完・
  最終横断は受入済み。4型ともBoundの公開動作はRelease実行のclass（`*BoundPublicBehaviorTests`）、内部観測はDebug側に置く。

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

- 赤黒木Test as Specの補完（RBT-042〜046）は完了・受入済み。範囲版`erase(_:where:)`がpredicateのエラーをtrapにする問題は
  Astraが4型で修正し、回帰テスト8件がある。重複keyでの`.lessThanOrEqual(k)`がどの値を指すかは規定しない（RBT-041で整理）。
  経緯は`Maintanance/Quality/0.6.0-1/RED_BLACK_TREE_TEST_AS_SPEC_REVIEW.md`、各返却は`Maintanance/CLAUDE_TASK.md`。
- ElementBuffer系の仕様testのファイル名は改名前の`BareArray_*`・`OptionalArray_*`のまま。監査の正本がこの名前を
  引用しているため、改名するかは未決定（記録なし）。
- test内に未使用変数の警告が2件ある（`RedBlackTreeInternal_ComparatorsTests.swift:178`・`:219`、2026-10-16確認）。仕様には影響しない。
- `Tests/RedBlackTreeFixture/Fixtures.md`の「場所」をリポジトリ直下からのパスにそろえた（DOC-031の指摘）。

最終更新: 2026-10-16 08:40 JST / Claude Opus 5.5

このファイルは現在地を上書きして保つ。長文報告や年代順ログは追加せず、引き継ぎは
最大5項目とする。ユーザー方針の変更・削除はユーザーへ確認する。
