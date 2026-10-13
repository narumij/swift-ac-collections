# BareArrayModule利用者向け文書 本文ドラフト

> **文書状態:** 内部レビュー用ドラフト。公開文書ではない。
>
> 本書は公開媒体を決めない。Markdown、DocC、documentation commentへの配置と分割は別判断とする。
> 公開契約はsourceとTest as Specification、品質上の証拠境界はQuality ProfileとCurrent Quality Assessmentを正本とする。

## 概要

BareArrayModuleは、要素を一つの連続storageに所有する1Dから4Dの固定shape bufferを提供する。
動的計画法などで、大きな多次元領域を整数座標で読み書きする用途を想定している。

すべてのslotはinitializerで値を持ち、最後にbufferが破棄されるまで設定済みである。標準`Array`や`Collection`の代替として
一般的なcollection APIを提供する型ではない。

## 基本的な使い方

```swift
var table = ElementBuffer2D(repeating: 0, width: 4, height: 3)

table.setElement(42, at: 2, 1)
let value = table.element(at: 2, 1) // 42
```

全slotを同じ値で初期化する代わりに、storage順で要素を一つずつ生成できる。

```swift
var next = 0
let table = ElementBuffer2D<Int>(width: 4, height: 3) {
  defer { next += 1 }
  return next
}
```

どちらのinitializerも、要素数分のstorageを確保し、全slotを初期化する。

## 型と座標

| 次元 | 型 | 主なinitializer | accessの座標順 |
| --- | --- | --- | --- |
| 1D | `ElementBuffer<Element>` | `init(repeating:count:)` | `position` |
| 2D | `ElementBuffer2D<Element>` | `init(repeating:width:height:)` | `(x, y)` |
| 3D | `ElementBuffer3D<Element>` | `init(repeating:width:height:depth:)` | `(x, y, z)` |
| 4D | `ElementBuffer4D<Element>` | `init(repeating:size0:size1:size2:size3:)` | `(x, y, z, w)` |

各型には、繰り返し値の代わりに要素生成closureを受け取るinitializerもある。

2Dと3Dでは`width`が最内軸で、その座標が連続storage上で最も早く変化する。4Dでは`size0`が最内軸、
`size3`が最外軸である。各型の`indices`は最外軸の有効範囲を返す。

```swift
let buffer = ElementBuffer3D(repeating: 0, width: 2, height: 3, depth: 4)

for z in buffer.indices {
  for y in 0..<3 {
    for x in 0..<2 {
      _ = buffer.element(at: x, y, z)
    }
  }
}
```

## value access

`element(at:)`は指定座標の値を返す。`setElement(_:at:)`は新しい値を所有し、それまで同じslotにあった要素を破棄する。

値を一回読む、または一回入れ替える場合はこれらのmethodを使う。

## `MutableRef`による借用参照

Swift 6.4とApple OS 27以降の組み合わせでは、mutating `reference(at:)`がSwift標準ライブラリの
`MutableRef<Element>`を返す。
`value`を通じて、ownerの同じslotをscope内で繰り返し読み書きできる。

```swift
var buffer = ElementBuffer(repeating: 0, count: 4)

do {
  var reference = buffer.reference(at: 2)
  reference.value += 1
  reference.value += 2
}

let value = buffer.element(at: 2) // 3
```

`MutableRef`はstorageを所有しない。referenceの寿命は、`reference(at:)`を呼んだ可変ownerに依存する。
ownerより長くescapeさせるコードはcompilerに拒否される。referenceを保持したままownerへ独立にaccessするのではなく、
借用scope内でreferenceを使い終える。

`reference(at:)`は、Swift 6.4 toolchainと対応するApple OS 27以降で利用できる。
旧OS・旧toolchain向けの同名互換型は提供しない。

## 所有権と要素寿命

4つの所有型は`~Copyable`であり、暗黙に複製できない。各型がstorageとその全要素を所有する。
bufferが破棄されると、全要素の寿命も終了する。公開のcopy操作は提供しない。

`Element: Sendable`のとき所有型も`@unchecked Sendable`である。ただし、これは同じinstanceへの無同期な並行accessを許可する説明ではない。
借用参照を含む並行利用の意味的な保証範囲は現在未検証である。

## 事前条件と空のshape

- 各次元は0以上でなければならない。
- 次元の積は`Int`で表現できなければならない。
- いずれかの次元が0なら、要素を持たないstorageを作る。要素生成closureも呼ばれない。
- `element`、`setElement`、`reference`の各座標は、対応する次元の範囲内でなければならない。

事前条件違反は停止となる。`-Ounchecked`では、これらの実行時検査が省略される場合がある。

## 性能特性

要素は一つの連続storageに保持される。`element`、`setElement`、および`reference`は定数回の座標検査とoffset計算で実行され、
計算量はO(1)である。初期化と破棄は全要素数に比例する。

これらは実装構造から確認した計算量であり、特定環境の実行時間を保証しない。C++やSwiftの代替構造との具体的な
性能比と受入水準は、別の品質判断とする。

## 提供境界

- 現行APIは1Dから4Dの所有型、座標value access、および条件付きの借用参照である。過去の連鎖subscriptと非所有Viewは削除済みである。
- 標準`Collection`へは適合しない。`indices`は最外軸の有効範囲を表す。
- SwiftPMの`BareArrayModule`から利用でき、`AcCollections`からも再公開される。
- 競技プログラミングでのcopy & paste利用を想定したsourceだが、現時点で実問題・実提出の正答、実行時間、
  メモリ使用量を保証するValidation証拠は未確認である。

## ユーザーレビューで確認する点

- value accessと借用参照の使い分けが、初見の利用者に通じるか。
- `MutableRef`の利点より先に、owner依存寿命と可変借用の制約を強調しすぎていないか。
- 1Dから4Dの座標順と、`indices`が最外軸だけを返すことを、例から正しく読み取れるか。
- 標準`MutableRef`を直接使い、旧環境向け互換型を提供しない境界が分かりやすいか。
- 性能特性は計算量だけに留め、外部比較を保証しない現段階の境界でよいか。

## 根拠

- 公開実装: `Sources/ElementBufferModule/ElementBuffer.swift`
- 現行Test as Specification: `Tests/ElementBufferModuleTests/`
- 借用寿命compiler fixture: `Utilities/Maintenance/CompilerDiagnostics/BareArrayMutableRefLifetime/`
- 品質プロファイル: `Sources/ElementBufferModule/Documentation/Quality-Profile.md`
- 現在評価: `Maintanance/BareArrayModule/CurrentQualityAssessment.md`
- 体系監査と判断記録: `Maintanance/BareArrayModule/BareArrayAudit.md`
