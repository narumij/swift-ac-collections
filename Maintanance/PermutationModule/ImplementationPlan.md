# PermutationModule テストファースト実装計画(フェーズ1ドラフト)

本書は `Maintanance/PermutationModule/ProductReadinessAssessment.md`(調査所見)と
`Sources/PermutationModule/Documentation/Specification.md`(仕様ドラフト)を前提に、
今後の実装作業をテストファーストで進めるための計画を示す。この時点でコード・
テストへの変更は行っていない。着手順・要否の最終判断はユーザーが行う。

## 既存テストの扱い

| ファイル | 扱い | 理由 |
| --- | --- | --- |
| `Tests/PermutationTests/PermutationTests.swift` | 維持・Test as Specificationの土台として再利用 | 3公開APIの基本契約(列挙順序・終了条件・重複・CoW差)を既に押さえている |
| `Tests/PermutationTests/NextPermutation.swift` | 削除せず現状保持、扱いはユーザー判断待ち | `Array: NextPermutation` という独自protocol経由の別世代実装。本体からは未参照(`ProductReadinessAssessment.md` 既出)。削除するとPermutations.swiftのアルゴリズムとの比較対象が消える懸念があるため、テストとして残すか参考実装として残すかは決定待ち |

`Tests/CLAUDE.md` の番号付けルール(`_98_` 実装・coverage、`_97_` 未分類、
`_99_DeathTests` 事前条件)は、RedBlackTree側の慣例であり、PermutationModuleには
まだ適用されていない。再設計時にPermutationTests側へ同様のファイル分割を導入するか
どうかは、Task 1の範囲外の実装判断としてここに記録するに留める。

## 不足しているTest as Specificationケース(所見ベース)

`Specification.md` の「観測可能な公開契約」各項目のうち、現状テストで直接
裏付けられていないもの。

1. **`unsafePermutations()` と `nextPermutations()`/`unsafeNextPermutations()` の
   列挙順序が一致すること**: 現在のテストはAPIごとに個別の期待値配列と比較しており、
   3 API間の相互比較(同じ入力に対して全て同じ並び順を返すこと)を直接検証していない。
2. **空コレクション・単一要素の境界**: `testNextPermutations`/`testUnsafeNextPermutations`
   は2要素以上の入力のみ。`[]`・`[1]` に対する3 APIの挙動(1回で終了するか、クラッシュ
   しないか)が未確認。
3. **`unsafePermutations()` のCoWキャンセル挙動の直接検証**: `testUnsafeNextPermutations`
   にある「保持すると値が収束する」という非直感的挙動の確認は `unsafeNextPermutations()`
   のみ。`unsafePermutations()`(全列挙側)についても同様の確認が無い。
4. **`Permutations.All.init(safe:)` / `IteratorA.ensureUnique()`**: 呼び出す公開APIが
   無いため未到達(coverage 0%、`ProductReadinessAssessment.md` 既出)。公開API化する
   場合、`nextPermutations()` と同等の「CoWあり」契約を満たすテストが必要になる。
5. **`USING_ALGORITHMS` 比較テストの範囲**: 現在 `testExample0` のみが
   `swift-algorithms` の `permutations()` と比較しており、`unsafePermutations()` との
   比較テストは無い(`unsafePermutations()` 自体のテストは独立した期待値配列で直接検証)。
   設計ドラフトで3 APIの順序一致を要求するなら、比較対象を揃えるか検討が要る。

## パフォーマンス検証の計画

既存の `#if ENABLE_PERFORMANCE_TESTING` ブロック(`testPerformance00`/`testPerformance1`、
および `USING_ALGORITHMS` 時の `testPerformance0`)は維持し、再設計後も同条件での比較
(素の `nextPermutation()` ループ・`swift-algorithms`・`unsafePermutations()`)を継続する。
追加で検討する項目:

- `nextPermutations()`(CoWあり版)のオーバーヘッドを、現行の `unsafeNextPermutations()`
  と同条件で比較するベンチマークが無い。再設計で「安全な全列挙」を公開APIに追加する
  場合、同様に測定対象へ加える。
- 現行ベンチマークは `0..<9`(DEBUG)/`0..<10`(RELEASE)の範囲固定。ABC328E相当の
  N=14程度までのスケールでの計測は無い。

## ABC328E 実提出による性能検証の実務計画

`ProductReadinessAssessment.md` に記録の通り、本モジュールの存在理由はABC328Eでの
実行時間問題である。再設計後の退行防止には、ベンチマーク数値だけでなく**実際の
AtCoder提出**で確認することが望ましい。

1. 現行の `COMPATIBLE_ATCODER_2025` ビルド設定下で、ABC328E用の単一ファイル
   提出コードを用意する(`import AcCollections` 経由で `PermutationModule` が
   再公開されることを利用、`Tests/AcCollectionsTests/AcCollectionsTests.swift:72`
   の `test_importAcCollections_compatModeExposesNextPermutations` が前提とする
   再公開契約に依拠)。
2. 再設計前(現行コード)での提出結果(AC/TLE、実行時間)を記録し、ベースラインとする。
3. 再設計後、同一の提出コードで再提出し、実行時間が悪化していないことを確認する。
   公開API名や戻り値の型を変更する場合は、提出コード側の書き換えが必要になる点を
   先に明記し、どこまでのAPI変更なら許容するかをユーザーに確認する。
4. 提出は外部サービス(AtCoder)への投稿を伴うため、実行はユーザー自身が行う前提とし、
   Claude/Codexはコード準備とベースライン記録までを担当する。

## 着手順序の提案(ユーザー確認待ち)

1. `Specification.md` の論点(命名、`init(safe:)` の結線要否)についてユーザー決定を得る。
2. 決定に基づき、上記「不足しているTest as Specificationケース」を先に追加し、
   現行実装に対してすべてパスすることを確認する(退行検出の土台を先に作る)。
3. 決定された公開API変更を実装し、同テストで検証する。
4. ABC328Eベースラインとの比較を行う。

## 保留中の判断(ユーザー確認が必要)

- `Tests/PermutationTests/NextPermutation.swift` を削除/参考実装として残すかの決定。
- `Permutations.All.init(safe:)` を公開APIとして結線するか否か。
- `unsafe` 接頭辞のままとするか、命名を見直すか。
- PermutationTestsへ `_98_`/`_97_`/`_99_` 相当のファイル分割を導入するか否か。
