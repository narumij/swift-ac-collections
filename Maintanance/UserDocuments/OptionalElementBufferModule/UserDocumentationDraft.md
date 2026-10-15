# OptionalElementBufferModule利用者向け文書 本文ドラフト

> **文書状態:** 内部レビュー用ドラフト。公開文書ではない。
>
> 本書は公開媒体を決めない。Markdown、DocC、documentation commentへの配置と分割は別判断とする。
> 公開契約はsourceとTest as Specification、品質上の証拠境界はQuality ProfileとCurrent Quality Assessmentを正本とする。

## 概要

OptionalElementBufferModuleは、各位置が「未設定」または一つの値を持つ、1Dから4Dの固定shape bufferを提供する。
未設定を表す特別な番兵値を`Element`の中から選ぶ必要がなく、各slotを`Element?`として読み書きできる。

主な用途は、多次元の状態を整数座標で管理するメモ化である。標準`Array`や`Collection`の代替として一般的な
collection APIを提供する型ではない。

現行版は、主として競技プログラミング向けに明示的に有効化して使う、実験的な低レベル部品である。
更新時の性能を優先した現在の方式を、一般Swift向けのコンテナとして提供するものではない。

## 基本的な使い方

SwiftPM依存で`ENABLE_OPTIONAL_ELEMENT_BUFFER` traitを有効にし、`AcCollections`をimportする。
traitが無効のままでは、以下の型は`AcCollections`から利用できない。

```swift
import AcCollections

let memo = OptionalElementBuffer2D<Int>(width: 4, height: 3)

if memo.element(at: 2, 1) == nil {
  memo.setElement(42, at: 2, 1)
}

let value = memo.element(at: 2, 1) // 42
memo.setElement(nil, at: 2, 1)     // 未設定へ戻す
```

initializerの直後は、すべてのslotが未設定である。`element`は未設定の位置で`nil`を返し、
`setElement`は値を保存する。`setElement(nil, ...)`は現在の要素を破棄し、そのslotを未設定へ戻す。

現行の`setElement`と`removeAll()`はnonmutating methodなので、`let`で保持したbufferも更新できる。
`let`や借用で渡すことだけでは、内容が読み取り専用になるわけではない。

## 型と座標

| 次元 | 型 | initializer | accessの座標順 |
| --- | --- | --- | --- |
| 1D | `OptionalElementBuffer<Element>` | `init(capacity:)` | `position` |
| 2D | `OptionalElementBuffer2D<Element>` | `init(width:height:)` | `(x, y)` |
| 3D | `OptionalElementBuffer3D<Element>` | `init(width:height:depth:)` | `(x, y, z)` |
| 4D | `OptionalElementBuffer4D<Element>` | `init(size0:size1:size2:size3:)` | `(x, y, z, w)` |

2Dと3Dでは`width`が最内軸で、その座標が連続storage上で最も早く変化する。4Dでは`size0`が最内軸、
`size3`が最外軸である。各型の`indices`は最外軸の有効範囲を返す。

```swift
let buffer = OptionalElementBuffer3D<Int>(width: 2, height: 3, depth: 4)

for z in buffer.indices {
  for y in 0..<3 {
    for x in 0..<2 {
      // (x, y, z)の順でaccessする
      _ = buffer.element(at: x, y, z)
    }
  }
}
```

## 全要素を未設定へ戻す

`removeAll()`は設定済みの要素をすべて破棄し、各slotを未設定へ戻す。shapeと確保済みstorageは保持され、
同じ位置を再利用できる。処理時間は全slot数に比例する。

## 所有権と要素寿命

4つの所有型は`~Copyable`であり、暗黙に複製できない。各型が連続storageとその中の設定済み要素を所有する。

同じslotへ新しい値を設定すると、旧い要素は破棄される。`nil`への変更、`removeAll()`、buffer自体の破棄でも、
それぞれ対象の要素寿命が終了する。
`Element`がclassの場合、bufferが手放すのは保持していた参照であり、別の参照が残っていればinstanceは存続する。

`Element: Sendable`のとき所有型も`@unchecked Sendable`である。ただし、現行の更新APIは、
同じinstanceへの共有borrowからの並行更新を型で拒否しない。同じinstanceへの並行更新や、更新中の読み取りは避ける。
`Sendable`適合があることを、これらの並行利用の安全性の根拠にしない。

## 事前条件と空のshape

- 各次元は0以上でなければならない。
- 次元の積は`Int`で表現できなければならない。
- いずれかの次元が0なら、要素を持たないbufferを作る。
- `element`と`setElement`の各座標は、対応する次元の範囲内でなければならない。

事前条件違反は停止となる。`-Ounchecked`では、これらの実行時検査が省略される場合がある。

## 性能特性

presence mapとpayloadを別々の連続storageに保持する。`element`と`setElement`は定数回の座標検査とoffset計算で実行され、
計算量はO(1)である。初期化、`removeAll()`、および破棄は全slot数に比例する。

これらは実装構造から確認した計算量であり、特定環境の実行時間を保証しない。C++やSwiftの代替構造との具体的な
性能比も、受入水準を伴う別の品質判断であり、本文では保証しない。

## 提供境界

- 現行APIは1Dから4Dの所有型と座標accessである。過去の連鎖subscriptと非所有Viewは削除済みである。
- 標準`Collection`へは適合しない。`indices`は最外軸の有効範囲を表す。
- 1.0に向けては、明示的なtraitによる実験的提供として留保付きで対象に残す方針である。
  安定APIと同じ保証を既成事実とはしない。
- 競技プログラミングでの単一file利用を意識したsourceだが、現時点の証拠はEDPC利用例のcompileまでである。
  実提出の正答、実行時間、メモリ使用量は保証しない。

## ユーザーレビューで確認する点

- 「番兵値を必要としない固定shapeのメモ化buffer」という目的が、初見の利用者に通じるか。
- 1Dから4Dの座標順と、`indices`が最外軸だけを返すことを、例から正しく読み取れるか。
- `let`でも更新できることと、`~Copyable`や`Sendable`が並行更新の安全性を保証しないことが伝わるか。
- 性能特性は計算量だけに留め、外部比較を保証しない現段階の境界でよいか。
- 4Dの`size0`〜`size3`と座標`(x, y, z, w)`の対応が読み取れるか。

## 根拠

- 公開実装: `Sources/OptionalElementBufferModule/OptionalElementBuffer.swift`
- 提供方針: `Maintanance/Quality/QUALITY_REQUIREMENTS.md`の「1.0に向けた開発対象」
- 現行Test as Specification: `Tests/OptionalElementBufferModuleTests/`
- 品質プロファイル: `Sources/OptionalElementBufferModule/Documentation/Quality-Profile.md`
- 現在評価: `Maintanance/Quality/0.6.0-1/OptionalElementBufferModule/CurrentQualityAssessment.md`
- 体系監査と判断記録: `Maintanance/Quality/0.6.0-1/OptionalElementBufferModule/OptionalElementBufferAudit.md`
