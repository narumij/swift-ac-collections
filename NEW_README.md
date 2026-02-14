# swift-ac-collections

AtCoderでのデータ構造まわりのうち、Swift特有の不足を補う事を目的としたオープンソースパッケージ.

## 概要

現在の提供は RedBlackTreeModule のみ。
現行ジャッジ搭載版は別ブランチ（release/AtCoder/2025）で提供する。
本ブランチは API 互換を保証しない。

## 利用方法

### Swift Package Manager での利用

## AtCoder 2025

## 内容

### RedBlackTreeModule

赤黒木は、探索・挿入・削除において最悪 O(log n) の計算量を持つ平衡二分探索木である。
本実装は独自構造の内部ストレージを用いており、参照カウント負荷の少ないノードを特徴とする。

基本操作は Swift 標準に近い API を提供する。
インデックスを用いた操作も可能だが、探索および削除については専用の API の利用を推奨する。

#### RedBlackTreeSet

#### RedBlackTreeMultiSet

#### RedBlackTreeMultiMap

#### RedBlackTreeDictionary

#### Index

#### 削除時の Index 無効化と安全な範囲削除

#### MultiSet の remove(:)

#### MultiMap

### PermutationModule

#### 使い方

#### 説明

## アンダースコア付き宣言について

## ライセンス
