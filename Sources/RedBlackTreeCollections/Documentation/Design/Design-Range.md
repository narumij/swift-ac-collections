# RangeとIndex反復の設計

## この文書の目的

RedBlackTreeCollectionsでは、標準ライブラリの `Range`、`RangeExpression`、
`Sequence`、`Collection` にそのまま適合すると、赤黒木に対して無視できない
計算量上のコストが発生する。

この文書では、Indexによる範囲表現について、標準の型やプロトコルを
そのまま利用しない理由と、現在の代替型の役割を記録する。

## 背景

赤黒木のIndexは、配列のIndexのような整数オフセットではなく、木のノードを
識別する。Index間の順序を判定するには木上の位置関係を調べる必要があり、
比較には O(log N) のコストがかかる。

標準の `Range` は生成時に端点を比較する。Boundが赤黒木のIndexである場合、
単に「開始Indexから終了Indexまで順方向にたどる」ための範囲を作るだけでも
O(log N) のコストが発生する。

また、Indexを `Stridable` に適合させると標準のRangeとSequenceによる反復が
利用可能になるが、その経路ではループの継続判定のたびに現在のIndexと終端の
比較による範囲チェックが行われる。赤黒木のIndex比較は O(log N) なので、
N要素の走査は期待する O(N) ではなく O(N log N) になる。範囲生成時だけでなく、
ループ中にもこの比較コストが繰り返されることが問題である。

このため、`UnsafeIndexV3` は `Stridable` に適合させない。

## 基本方針

- 赤黒木本来の計算量を損なう抽象化には適合させない。
- Index範囲の生成で、端点の順序比較を暗黙に行わない。
- 全要素または部分範囲の順方向走査は O(K) とする。Kは走査する要素数である。
- O(log N) の安全性チェックは、必要性と効果を明確にしたうえでのみ行う。
- 生メモリを扱う実装としてメモリ安全性は維持する。
- 範囲削除は反復と単要素削除の組み合わせへ誘導せず、専用APIで行う。
- Copy on Writeを不必要に発生させるAPI設計を避ける。

## 独自の範囲表現

### `UnsafeIndexV3RangeExpression`

`UnsafeIndexV3RangeExpression` は、標準のIndex範囲表現に代わる型である。

次の演算子はBoundを赤黒木のIndexとする標準の `Range` ではなく、
`UnsafeIndexV3RangeExpression` を生成する。

```swift
lowerIndex..<upperIndex
lowerIndex...upperIndex
..<upperIndex
...upperIndex
lowerIndex...
```

両端を持つ式の生成時には、両Indexが同じ木に結び付いていることだけを確認する。
この確認は `_LazyTie` の参照同一性による O(1) の処理であり、端点の順序比較は
意図的に行わない。

したがって、範囲式の生成は O(1) を維持する。

`UnsafeIndexV3RangeExpression` は次の形式を保持できる。

- 半開範囲
- 閉範囲
- 上端だけを持つ部分範囲
- 上端を含む部分範囲
- 下端だけを持つ部分範囲

範囲式を木に対する操作へ渡す際に、必要な端点を木の先頭または終端から補い、
内部の半開範囲へ正規化する。閉範囲では上端の次のノードを排他的な終端とする。

### `UnsafeIndexV3Range`

`UnsafeIndexV3Range` は、`equalRange` などが返す解決済みのIndex範囲である。
内部では `_RawRange<UnsafeIndexV3>` を保持する。

この型と `UnsafeIndexV3RangeExpression` は役割が異なる。

- `UnsafeIndexV3RangeExpression`: 演算子で作られる範囲指定
- `UnsafeIndexV3Range`: 木の操作結果として得られる解決済み範囲

いずれも、Boundを赤黒木のIndexとする標準の `Range` へ置き換えることを
目的としない。標準Rangeへの置き換えは、生成時の端点比較とループ継続判定ごとの
Index比較による O(log N) のコストを再導入する。

## 計算量の目標

| 操作 | 目標計算量 | 備考 |
| --- | ---: | --- |
| 独自の範囲式の生成 | O(1) | 同一ツリー性だけを確認する |
| K要素の順方向走査 | O(K) | successorによる走査 |
| 閉範囲の上端正規化 | O(1) | 上端の次ノードを取得する |
| 標準Rangeの端点比較 | O(log N) | 採用しない経路 |
| ループ継続判定ごとのIndex比較 | O(K log N) | 採用しない経路 |

## 原木における位置の全順序

キーの順序だけでは、同値キーを複数保持するMultiSetとMultiMapの各nodeを区別できない。
原木内部でnode位置を比較するときは、まずキーを比較し、キーが同値の場合だけrootからnodeまでの
左右経路を表すpath bitmapで中間順位置を比較する。異なるキーではbitmapを計算しない。

この順序では、実nodeは常にendより小さく、同一node同士の`<`はfalseになる。endは範囲の
上限を兼ねるため、`[end, end]`に相当する空の内部区間は有効である。一方、下端だけがendで
現在位置または上端が実nodeなら、順序が逆転した無効な区間として扱う。

path bitmapはキーの代替ではなく、同値キーのタイブレークとIndex位置比較のための内部表現である。
事前計算済みbitmapを再利用できるAPIでは、同じnodeの経路を繰り返しrootまで辿らない。

内部範囲判定には、用途に応じて半開と閉区間の双方がある。`_NodeKey.isInHalfOpenRange`は
下端を含み上端を含まない。multiplicity helperの`___ptr_range_comp`は両端が実nodeなら
両端を含む判定を行い、上端がendなら下端以降を含む。この違いを名前だけから統合しない。

## 原木の移動と距離

successor/predecessorによる一歩の移動は、木の下端または上端を越えると方向に応じた
`.lowerOutOfBounds`または`.upperOutOfBounds`を返す。N歩移動では正負のNと0を扱う。limit付き
移動は開始位置が既にlimitの場合、または要求された移動を完了する前にlimitからさらに進もうと
する場合に`.limit`として停止する。ちょうどN歩目でlimitへ着く場合はその位置を成功として返す。
limitは通常のend境界とは別の、呼び出し側が指定する走査上限である。

前方向の素朴なdistanceはsuccessorを数える。safe distanceは到達不能な後ろ向き終端を失敗として
扱う一方、signed distanceの内部既定実装は同一点を0、順方向を正、逆方向を負として表す。
これらは同じ関数の安全版・高速版とは限らず、失敗表現と符号契約を保ったまま利用する。

## 範囲削除

範囲を反復しながら単要素削除を繰り返すAPI利用は推奨しない。

反復中の削除はIndexイテレータの安全性を複雑にし、Copy on Writeが繰り返し
発生する可能性もある。範囲削除には、木が削除順序、次ノードの確保、および
一意性の確保を管理できる専用APIを使用する。

## 採用しない方向

現時点では、次の方向は採用しない。

- `UnsafeIndexV3` の `Stridable` 適合
- Boundを赤黒木のIndexとする標準の `Range` を反復用の基本型にすること
- 独自範囲を標準Rangeへ変換してから反復すること
- 各要素で端点の順序や範囲包含を O(log N) で検査すること
- 反復中の削除を一般的な利用方法として支援すること
- `Collection` または `BidirectionalCollection` への再適合を前提とすること

## 関連する既存方針

この設計は、従来の `MEMO.md` に記録されていた次の方針を具体化する。

- 範囲制限では O(log N) のチェックコストを避ける。
- `Collection` と `BidirectionalCollection` への適合を廃止する。
- `RangeExpression` を独自実装する。
- Copy on Writeを自然に避けられるAPIへ移行する。
- `for` 文による範囲削除を避け、専用APIを利用する。
- Indexと内部イテレータを `Stridable` にしない。
- N要素の走査を O(N log N) ではなく O(N) に保つ。
