# Permutation利用者向け文書 本文ドラフト

> **文書状態:** 内部レビュー用ドラフト。公開文書ではない。
>
> 本書は公開媒体を決めない。Markdown、DocC、documentation commentへの配置と分割は別判断とする。
> 公開契約はsourceとTest as Specification、品質上の証拠境界はQuality ProfileとCurrent Quality Assessmentを正本とする。

## 概要

NextPermutationModuleは、要素が`Comparable`に適合する`Collection`の現在の並びから始めて、
辞書順で後続する順列を一つずつ生成する。

`nextPermutations()`が返す`NextPermutations`は、要素を格納する一つの可変bufferを所有する。
各`next()`が返す`Permutation`は、その時点のbufferを読む一時的なViewである。全順列を値として保存する
`Sequence`ではなく、Viewを処理してから次へ進む手動反復APIとして使う。

## 基本的な使い方

```swift
import AcCollections

var permutations = [1, 2, 3].nextPermutations()

while let permutation = permutations.next() {
  print(Array(permutation))
}
```

出力は入力自身から始まり、辞書順で後続する並びになる。

```text
[1, 2, 3]
[1, 3, 2]
[2, 1, 3]
[2, 3, 1]
[3, 1, 2]
[3, 2, 1]
```

入力がすでに途中の並びなら、それ以前の順列へ戻らず、現在の並びとそれより後だけを返す。
すべての異なる値の並びを列挙するには、この例のように昇順の入力から始める。
未整列の入力なら、`input.sorted().nextPermutations()`で開始できる。
降順の入力、空の入力、要素が一つだけの入力は、それぞれ入力自身を一度返して終了する。
同じ値を複数含む入力では、同じ値の並びを重複して返さない。

## 一時Viewの有効期間

`Permutation`は独立した配列ではない。現在のViewは、次のmutating `next()`を呼ぶまで、または
所有者である`NextPermutations`が破棄されるまで有効である。
次の`next()`が終了を表す`nil`を返す場合も、それまでのViewは失効する。
View自体を別の変数へcopyしても、要素はcopyされず、有効期間は延びない。

次へ進む前に、Viewから必要な処理を完了する。

```swift
var permutations = [1, 2, 3].nextPermutations()

while let permutation = permutations.next() {
  let sum = permutation.reduce(0, +)
  print(sum)
}
```

後から読み返す必要がある場合は、有効な間に所有する値へcopyする。

```swift
var permutations = [1, 2, 3].nextPermutations()
var saved: [[Int]] = []

while let permutation = permutations.next() {
  saved.append(Array(permutation))
}
```

保持した古いViewを、次の`next()`の後やowner破棄後に読むとprecondition failureになる。
失効は要素pointerを読む前に検出される。
`-Ounchecked`では、失効や範囲に関するpreconditionの実行時検査が省略される場合がある。

## CollectionとしてのView

有効な`Permutation`は`RandomAccessCollection`であり、0始まりの`Int` indexを使う。
入力Collectionのindex型や開始位置には依存しない。

- `startIndex`は`0`。
- `endIndex`は要素数。
- `startIndex ..< endIndex`の範囲で反復・subscriptできる。
- 範囲外のsubscriptはprecondition failureになる。

入力Collectionの要素は開始時にownerのbufferへcopyされる。列挙によって元のCollectionは変更されない。

## APIの境界

- `NextPermutations`は`~Copyable`であり、暗黙に複製できない。
- `NextPermutations`は`Sequence`ではない。`map`や`for-in`ではなく、mutating `next()`で進める。
- ownerの直接初期化ではなく、`Collection.nextPermutations()`から開始する。
- Viewの`Equatable`、`Hashable`、`Sendable`、永続的な値セマンティクスは、現行通常版の契約ではない。

## swift-algorithmsとの違い

このAPIは、入力の現在位置から辞書順で後続する値の並びを列挙する。
swift-algorithmsの`permutations()`は、入力中の位置を区別して、すべての並べ替えを列挙する。両moduleは同時にimportできるが、
重複要素の扱い、開始位置、返される値の寿命が異なるため、用途に応じて選ぶ。

## 性能特性

開始時に入力要素を一つの所有bufferへcopyする。反復中は同じbufferをin-placeで更新し、順列ごとの
全要素copyやallocationを行わない。入力要素数をnとすると、後続順列を一つ生成する処理は最悪O(n)、
有効なViewのindex accessはO(1)である。例にある`Array(permutation)`のcopyは、利用側が明示的に行う処理である。

異なるn要素の全順列はn!通りになる。外部実装との具体的な性能比は、測定条件と受入水準を
伴う別の品質判断であり、この本文では保証しない。

## 提供境界

この本文が対象とするのは通常版のruntime-check付きAPIである。Swift 6.4以降では、`Span`を返し、
借用寿命をcompilerで検査する`borrowedNextPermutations()`も別の公開APIとして提供している。
borrowed版とAtCoder 2025互換modeは、公開表面、寿命契約、build条件、検証経路が異なるため、
この本文の通常版と区別する。

## ユーザーレビューで確認する点

- 「後続順列」と「全順列」の説明は、初見の利用者が選択できる粒度になっているか。
- 一時Viewの利点より先に制約を強調しすぎていないか。
- `Array(permutation)`による保存を、必要な場合だけのcopyとして適切に説明できているか。
- 通常版だけを説明する初版として十分か。互換modeへの導線が必要か。
- 性能特性は定性的説明に留め、具体的な測定値を載せない現段階の境界でよいか。

## 根拠

- 公開実装: `Sources/NextPermutationModule/NextPermutations.swift`
- borrowed版の公開実装・利用例: `Sources/NextPermutationModule/BorrowedNextPermutations.swift`
- 現行Test as Specification: `Tests/PermutationTests/NextPermutations/`
- compiler表面: `Utilities/Maintenance/CompilerDiagnostics/PermutationPublicSurface/`
- 品質プロファイル: `Maintanance/Quality/Profiles/NextPermutationModule.md`
- 現在評価: `Maintanance/Quality/0.6.0-1/PermutationModule/CurrentQualityAssessment.md`
- 再構成と検収記録: `Maintanance/Quality/0.6.0-1/PermutationModule/RuntimeCheckedPermutationTestPlan.md`
