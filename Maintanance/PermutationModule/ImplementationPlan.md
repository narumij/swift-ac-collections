# PermutationModule 削減実施記録

本書は `Maintanance/CLAUDE_TASK.md` のユーザー最終決定(バリアント削減、2026-10-03)に
基づき実施した `PermutationModule` の公開API削除の記録である。削除前の調査所見は
`Maintanance/PermutationModule/ProductReadinessAssessment.md`、現行の公開API仕様は
`Tests/PermutationTests/NextPermutationsSequence/`のTest as Specification（2026-10-07に`Specification.md`から切り替え）である。

## 実施したこと(2026-10-03、完了)

### Phase 1A — 削除ゲート(swift-algorithms等価性PoC)

`unsafePermutations()`/`Permutations.All`を削除する前に、「`swift-algorithms`の
`permutations()`で代替可能」という削除根拠そのものを検証した。

- `Package.swift`の`PermutationTests`ターゲットへ`Algorithms`依存と
  `USING_ALGORITHMS`定義を一時的に有効化。
- `Tests/PermutationTests/PermutationTests.swift`に
  `testPhase1A_unsafePermutationsEquivalentToAlgorithmsPermutations`を追加し、
  空コレクション・単一要素・重複なし昇順/非昇順・降順・重複値あり・`Array`以外の
  `Collection`(`Range<Int>`、`Index == Int`)の7ケースで、即時`Array`化した結果を
  `Algorithms.permutations()`と比較。
- `swift test --filter PermutationTests`で実行し、結果数・順序・重複の見え方を含めて
  全ケースで完全一致(反例なし)を確認。
- PoC用の一時変更(依存有効化・比較テスト)は削除ゲートの通過後、下記Phase 1Bの
  削除作業と合わせて除去し、`Package.swift`は元の状態(`Algorithms`依存コメントアウト)
  に復元した。エビデンスはコミット履歴に残る。

### Phase 1B — 削除の実施

1. 保持する`nextPermutations()`契約のテストを先に追加
   (`Tests/PermutationTests/PermutationTests.swift`):
   空コレクション・単一要素・降順先頭ではない開始位置からの継続・CoWによる
   既取得結果の不変性(`testNextPermutationsRetainedResultsRemainStable`)。
2. `Sources/PermutationModule/Permutations.swift`から次を削除:
   - `unsafePermutations()`(Collection拡張メソッド)
   - `Permutations.All`、`.init(safe:)`/`.init(unsafe:)`、`IteratorA`、`SubSequenceA`
   - `unsafeNextPermutations()`(Collection拡張メソッド)
   - `Permutations.Nexts`/`IteratorN`の`_unsafe`フラグとエイリアシング経路。
     `Nexts`は常にCoWする単一経路へ単純化し、`init`は`internal`化した
     (`nextPermutations()`からのみ到達可能)。
   - `Permutations.Buffer.prepare(count:)`(`All`の位置インデックス列初期化専用で、
     `All`削除後に未参照となったため削除)。
3. `Tests/PermutationTests/PermutationTests.swift`から、削除したAPIのみを対象とする
   `testUnsafePermutations`・`testUnsafeNextPermutations`・Phase 1A PoCテスト・
   `testPerformance1`(`unsafePermutations()`を測定)を削除。
4. ドキュメントを現行APIに合わせて全面的に書き直し
   (`Specification.md`・本書・`ProductReadinessAssessment.md`)。削除した変種は
   「対応中の選択肢」としてではなく、削除済みの履歴として記録する。

## 検証

- `swift test --filter PermutationTests` — 全ケース成功(削除後、2テスト)。
- `swift build` / `swift test`(リポジトリルート、通常モード)— 成功、既存テストに
  退行なし。
- `COMPATIBLE_ATCODER_2025`を一時的に有効化して
  `swift test --filter 'AcCollectionsTests|PermutationTests'`を実行 — 成功
  (`AcCollections`が互換モードで`PermutationModule`を再公開する経路を含む)、
  `Package.swift`は元の状態へ復元。
- `git diff --check` — クリーン。

## 追加の削減(2026-10-03、完了)

`Tests/PermutationTests/NextPermutation.swift`(本体の`PermutationModule`からは未参照の
別世代実装。`Array: NextPermutation`という独自protocol、`NextPermutationUnsafeHandle`、
`UnsafeMutableBufferPointer`直接操作のアルゴリズムを含む)を削除し、これを唯一使用していた
`testPerformance00`(`ENABLE_PERFORMANCE_TESTING`配下)を`PermutationTests.swift`から削除した。
実装バリアントを1経路(`Sources/PermutationModule/NextPermutationProtocol.swift`経由)へ
さらに縮小する、というユーザー方針に基づく。

## 保留・凍結中の判断

- `Sendable`対応はSwift 6以降に必要とする方針で確定し、全公開型で実施済み。
  `IteratorN`/`SubSequenceN`は、共有CoW bufferの`final`化と変更前detachを根拠に
  `@unchecked Sendable where C.Element: Sendable`へ適合した。詳細は
  `Maintanance/StrictMemorySafetyReadiness.md` §9を参照。公開APIのコメントドックも整備済み。
- `PermutationModule`への`.strictMemorySafety()`も恒久適用済み。内部Bufferのunsafe操作は
  所有境界ごとのscoped `unsafe`へ整理し、strict設定下で警告0件を確認した。
- ABC328E実提出による性能検証(ベースライン記録・削除後の再提出比較)は、ユーザーが
  手作業で行う専任項目として凍結する。AIは着手・代行・催促しない。制約は`N <= 8`, `M <= 28`で、AtCoderの
  判定環境は`import AcCollections`に依存できないため、自己完結したコピー&ペースト用の
  単一Swiftファイルが必要(package内の再公開テストとは別の検証)。
