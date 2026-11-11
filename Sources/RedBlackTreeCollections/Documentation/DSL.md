## 位置指定 DSL

サブスクリプトや削除などの位置指定に利用できる。

位置指定 DSL は、API の利用時に対象の木に対して評価され、
対応する要素位置へ変換される。

終端 (`end`) や評価失敗をどのように扱うかは、
位置指定 DSL を利用する API によって異なる。

位置指定を連結した場合は左から順に評価され、
前段で得られた位置に対して後続の相対位置指定が適用される。

### 基本位置

| 式 | 意味 | 該当する位置がない場合 | 評価時の計算量 |
|---|---|---|---|
| `.start` | 最初の要素 | `end` | O(1) |
| `.last` | 最後の要素 | `end` | O(log `count`) |
| `.end` | 終端 | - | O(1) |
| `.lowerBound(k)` | `k` 以上の最初の要素 | `end` | O(log `count`) |
| `.upperBound(k)` | `k` より大きい最初の要素 | `end` | O(log `count`) |
| `.find(k)` | `k` と等しい要素 | `end` | O(log `count`) |
| `.first(k)` | `k` と等しい要素のうち走査順の先頭 | `end` | O(log `count`) |

`.first(k)` は同値要素の群の先頭を指す。`.find(k)` は同値要素の先頭を指定するものではない。
トップレベル関数 `first(k)` も `.first(k)` と同じ境界式を作る。

### 相対位置

位置指定式に対して、さらに相対的な位置指定を連結できる。

| 式 | 意味 | 評価時の追加計算量 |
|---|---|---|
| `.before` | 1つ前の位置 | 最悪 O(log `count`), みなし O(1) |
| `.after` | 1つ後の位置 | 最悪 O(log `count`), みなし O(1) |
| `.advanced(by: n)` | `n` 個移動した位置 | みなし O(`n`) |
| `.advanced(by: n, limit: limit)` | `limit` を境界として `n` 個移動した位置 | みなし O(`n`) + `limit` の評価コスト |

`.before`、`.after`、`.advanced(by:)` は、
それまでに評価された位置を基準として処理される。

先頭より前、または終端より後へ移動しようとした場合は評価失敗となる。

`advanced(by:limit:)` の `limit` には別の位置指定 DSL を指定できる。
`limit` は対象の木に対して独立して評価される。

移動処理が `limit` への到達を報告した場合、
評価結果は `limit` の位置となる。

位置指定式全体の計算量は、各位置指定の評価コストの合計となる。

### 例

```swift
var numbers = RedBlackTreeSet<Int>(0..<10)
let number = numbers[.start.after]
// .start -> 0
// .after -> 1
print(number!) // -> 1
```

```swift
var numbers = RedBlackTreeSet<Int>(0..<10)
let number = numbers[.lowerBound(20).before.advanced(by: -1)]
// .lowerBound(20) → end
// .before         → 9
// .advanced(-1)   → 8
print(number!) // -> 8
```
