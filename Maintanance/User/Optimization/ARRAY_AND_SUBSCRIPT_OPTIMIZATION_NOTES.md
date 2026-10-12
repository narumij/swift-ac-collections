# Array・subscript最適化メモ

## TL;DR

Arrayや多重subscriptがボトルネックとして残った場合、ホットループを`@inline(never)`の非escapingな`inout`／`borrowing`関数へ切り出してみる価値がある。必ず速くなるわけではないが、独自コンテナへ置き換える前に試せる安価な方法である。

## 位置づけ

Swiftの`Array`や多次元配列風の`subscript`が遅くなる条件を、実測と生成コードから探るためのメモ。標準`Array`を主対象、非コピー所有の`RigidArray`を副対象とし、単一ストレージを持つ`BareArray`は多段subscriptの参考事例として扱う。

ここに書く一般則は仮説であり、Swiftの言語仕様や性能契約ではない。確認できた事実と、その説明として有力な仮説を分けて残す。

## 今回確認できた事実

Swift 6.4のRelease最適化で、1次元配列へ添字順に整数を書き込む処理を比較した。

### 計測構造

遅かった形では、ベンチマークtaskが保持するescaping closureから`Timer.measure`へさらにclosureを渡し、その内側で捕捉した`var Array<Int>`を更新していた。

```swift
return { timer in
  timer.measure {
    for position in array.indices {
      array[position] = position
    }
  }
}
```

速かった形では、同じループを`@inline(never)`の関数へ分離し、`Array`を`inout`で渡した。

```swift
@inline(never)
private func write(_ array: inout [Int]) {
  for position in array.indices {
    array[position] = position
  }
}

return { timer in
  timer.measure {
    write(&array)
  }
}
```

16M要素で、直接展開した形は約12.15ms、`inout`関数へ分離した形は約2.30msだった。

### 生成コード

同じ構造を最小コードで再現してReleaseアセンブリを比較した。

`inout`関数へ分離した形では、次が確認できた。

- `swift_isUniquelyReferenced_nonNull_native`はループ前に1回。
- 8要素単位のSIMD書き込みが生成された。
- SIMDループ内に要素ごとの境界検査は残らなかった。
- `Timer.measure`相当の内側は、排他的アクセスの開始、分離関数の呼び出し、排他的アクセスの終了という小さな処理になった。

直接展開した形では、一意性確認自体はループ前に出ていたが、ループがスカラーのまま残った。各反復には次の処理が含まれていた。

- 捕捉ボックスへのArrayバッファ参照の再格納。
- Arrayの`count`の再取得。
- 添字の境界検査。
- 捕捉ボックスからのArrayバッファ参照の再取得。

### 多段Arrayでの追試

`Array<Array<Int>>`と`Array<Array<Array<Int>>>`についても、直接`Timer.measure`内へ展開したループと、同じループを`@inline(never)`関数へ分離した形を比較した。write側は分離関数へ外側のArrayを`inout`で渡した。

最大要素数における平均は次のとおりだった。

| 対象 | 直接展開 | 分離後 |
|---|---:|---:|
| 2D read、4M要素 | 0.95ms | 0.90ms |
| 2D write、4M要素 | 12.91ms | 7.44ms |
| 3D read、1M要素 | 0.26ms | 0.21ms |
| 3D write、1M要素 | 4.52ms | 3.13ms |

readの変化は小さい。writeは分離によって改善したが、1D Arrayのように単純な連続書き込みと同等にはならなかった。

多段Arrayでは、各階層が独立した値型のArrayであり、それぞれがCOWストレージを持つ。write時に各階層の一意性を確認することは値 semanticsを維持するために必要であり、この残差を直ちに最適化失敗とは扱わない。

この追試が示すのは、直接展開した形には多段Arrayが本来必要とするCOW処理に加えて、closure捕捉と所有権境界に由来する偶発的なコストも含まれていた、ということまでである。

### RigidArrayでの追試

`RigidArray`は固定容量の非コピー所有コンテナであり、標準ArrayのようなCOWを持たない。1Dと、`RigidArray<RigidArray<Int>>`および`RigidArray<RigidArray<RigidArray<Int>>>`による多段構造について、同じ直接展開と`@inline(never)`関数分離を比較した。

| 対象 | 直接展開 | 分離後 |
|---|---:|---:|
| 1D read、16M要素 | 2.60ms | 2.56ms |
| 1D write、16M要素 | 5.79ms | 2.33ms |
| 2D read、4M要素 | 2.23ms | 0.68ms |
| 2D write、4M要素 | 3.17ms | 2.43ms |
| 3D read、1M要素 | 0.93ms | 0.15ms |
| 3D write、1M要素 | 0.96ms | 0.85ms |

1D readは境界の違いによる変化が小さく、1D writeは標準Arrayと同様に分離後が大幅に速かった。多段readでは分離の効果が非常に大きかった。多段writeにも改善はあるが、readほど一様ではなかった。

RigidArrayにはCOWがないため、この差をCOWでは説明できない。escaping closureに捕捉された非コピー所有値から、寿命依存のborrow・mutateアクセサを多段で使用すると、コンパイラがループ全体を単純化しにくくなる可能性がある。これは現時点では生成コードによる原因確認前の仮説である。

分離後のRigidArrayは、同じ多段構造でも標準Arrayよりwriteが速かった。これは標準Arrayで分離後にも残った差の一部が、各階層の値 semanticsとCOW処理に由来するという解釈を支持する。ただし、ストレージ配置や確保方法も異なるため、差の全量をCOWだけへ帰属させない。

### BareArrayでの参考結果

単一の連続ストレージを所有する`BareArray2D`と`BareArray3D`でも、同じ直接展開と関数分離を比較した。

| 対象 | 直接展開 | 分離後 | `reference(at:...)` |
|---|---:|---:|---:|
| 2D read、4M要素 | 0.74ms | 0.72ms | 0.70ms |
| 2D write、4M要素 | 6.48ms | 1.38ms | 1.40ms |
| 3D read、1M要素 | 0.17ms | 0.17ms | 0.18ms |
| 3D write、1M要素 | 2.64ms | 0.44ms | 0.45ms |

BareArrayは階層ごとのCOWストレージを持たない。分離後の多段subscriptは`reference(at:...)`と同等になった。この結果は、多段Arrayに残るwriteコストをsubscriptの構文だけで説明できないことの参考になる。

## 現時点の仮説

### `subscript`そのものが常に遅いわけではない

`Array`の`subscript`は、所有権、排他性、添字範囲、ストレージの一意性をコンパイラがループ全体について証明できれば、境界検査やCOW関連処理をループ外へ移動し、連続メモリアクセスとして最適化できる。

したがって、`subscript`を使用しているという表面的な事実だけでは性能を予測できない。

### 捕捉された可変Arrayは追加の最適化阻害を生む場合がある

escaping closureが可変Arrayを捕捉し、さらに非インライン化された関数へ内側のclosureを渡す構造では、Arrayの値が捕捉ボックスを介して扱われる。

このときコンパイラがループ中のストレージ同一性や添字範囲を十分に固定できず、バッファ参照の再取得、境界検査、スカラー化が残る場合がある。これはArrayが本来必要とするCOW処理とは区別する。

### `inout`境界は最適化に有利な場合がある

非escapingな`inout`で処理範囲を閉じると、その呼び出し中の排他的アクセスが明確になる。関数内部でArrayのストレージと要素数を安定した値として扱いやすくなり、COWの一意性確認の集約、境界検査の除去、SIMD化につながる場合がある。

`@inline(never)`自体が高速化するわけではない。今回の役割は、所有権の明確な関数境界を維持し、計測対象のループを呼び出し側の捕捉構造から分離することだった。

### 多段Arrayでは必要なCOWと偶発的な阻害を分ける

`array[z][y][x]`のような標準Arrayの多段アクセスでは、外側、中間、内側のArrayがそれぞれ値 semanticsとCOWストレージを持つ。write時の一意性確認は単なるコンパイラの不得手ではなく、共有されている階層だけを正しく分離するために必要な処理である。

一方、同じ多段Arrayでもループを非escapingな`inout`関数へ分離するとwriteは改善した。したがって、観測した時間には、必要なCOW処理と、closure捕捉によって追加された最適化阻害の両方が含まれ得る。

「subscriptだから遅い」「COWだから仕方がない」のどちらか一方だけで結論づけず、所有権境界を揃えた後に残るコストを、値 semanticsに必要な処理として評価する。

### 非コピー所有でもclosure捕捉の影響は消えない

RigidArrayにはCOWがないが、直接展開と関数分離の差が観測された。したがって、COWを除けば自動的に最適なループになるわけではない。

特に多段RigidArrayは、捕捉された所有値から寿命依存アクセサを連鎖させる。非escapingな関数境界へ処理を閉じることで、所有値と各borrow・mutateの関係をコンパイラが証明しやすくなる、というのが現在の仮説である。

## 実装・ベンチマーク上の注意

- Arrayと独自コンテナを比較するときは、ループを置く所有権境界を揃える。
- 一方だけをescaping closureの捕捉値として操作し、他方を単一の外部関数呼び出しにすると、コンテナ以外の差を測る可能性がある。
- 多段Arrayと単一ストレージの多次元コンテナは、同じ添字構文でも所有モデルが異なる。COW階層数の差を無視してアクセサだけを比較しない。
- RigidArrayとBareArrayはどちらもCOWを持たないが、前者の多段構造は複数の独立したストレージ、後者は一つの連続ストレージである。非コピー所有という共通点だけで同一視しない。
- `@inline(never)`は「最適化なし」を意味しない。関数内部では境界検査除去やSIMD化が行われる。
- 時間だけで原因を確定しない。生成コードで一意性確認、動的排他アクセス、境界検査、バッファ再取得、SIMD化の有無を確認する。
- 最適化条件はコンパイラ版、最適化モード、呼び出し構造、要素型によって変わり得る。今回の結果を一般的な性能保証として扱わない。

## 関連する暫定証拠

- 結果JSON: `Benchmarks/QualityAssessment/macOS/BareArray/Results/provisional-mutable-ref-2026-10-12.json`
- 1D read chart: `Benchmarks/QualityAssessment/macOS/BareArray/Charts/provisional-mutable-ref-1d-read.png`
- 1D write chart: `Benchmarks/QualityAssessment/macOS/BareArray/Charts/provisional-mutable-ref-1d-write.png`
- 比較ライブラリ: `Benchmarks/Libraries/BareArrayMutableRefExperiment.json`
- RigidArray実験workload: `Benchmarks/Sources/Benchmarks/RigidArrayOptimizationBenchmarks.swift`

アセンブリ比較にはリポジトリ外の最小再現コードを使用した。再現コードとアセンブリは現時点では正式成果物として保存していない。
