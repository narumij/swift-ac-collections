//
//  Untitled.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/09/30.
//

import RedBlackTreeCollections

@available(anyAppleOS 26.0, *)
struct TreeNodeOnlyFixture: ~Copyable {
  var end_node: UnsafeNode
  var storage: InlineArray<128, UnsafeNode>
}

@available(anyAppleOS 26.0, *)
extension TreeNodeOnlyFixture {

  /// 本家の`__tree`と同じく、rootは独立フィールドとして持たず、常に`end_node.__left_`から
  /// 都度求める(参考: `unsafe_tree+algorithm.swift`冒頭のレイアウト解説コメント)。
  /// キャッシュして持つと同期漏れの不具合を生むため、計算プロパティにする。
  var root: _NodePtr {
    end_node.__left_
  }
}

@available(anyAppleOS 26.0, *)
extension TreeNodeOnlyFixture {

  static func makeEmpty() -> Self {
    Self(
      end_node: .create(tag: .end, nullptr: .nullptr),
      storage: .init(repeating: .create(tag: .nullptr, nullptr: .nullptr)))
  }
}

@available(anyAppleOS 26.0, *)
extension TreeNodeOnlyFixture {

  /// `storage`内のインデックス`i`のノードへの生ポインタを得る。
  /// `self`が移動・破棄されない間だけ有効。
  mutating func node(_ i: Int) -> _NodePtr {
    withUnsafeMutablePointer(to: &storage[i]) { $0 }
  }

  /// `end_node`への生ポインタを得る。
  /// `self`が移動・破棄されない間だけ有効。
  mutating func endPtr() -> _NodePtr {
    withUnsafeMutablePointer(to: &end_node) { $0 }
  }
}

@available(anyAppleOS 26.0, *)
extension TreeNodeOnlyFixture {

  /// `root`(= `end_node.__left_`)が赤黒木として正しいことを、実際の`__tree_invariant`
  /// (色・黒高さ等)で検証する。空の木(`root == nullptr`)は`__tree_invariant`の定義上true。
  mutating func invariant() -> Int {
    __tree_invariant(root) ? 1 : 0
  }
}

@available(anyAppleOS 26.0, *)
extension TreeNodeOnlyFixture: _UnsafeNodePtrType & NullPtrInterface {
  var nullptr: _NodePtr { .nullptr }
}

// 以下の二つと類似関数を基本層とする定義で構わない気がしてきた
@available(anyAppleOS 26.0, *)
extension TreeNodeOnlyFixture: TreeAlgorithmBaseProtocol_ptr {}

@available(anyAppleOS 26.0, *)
extension TreeNodeOnlyFixture: TreeAlgorithmProtocol_ptr {}

// キーやバリューを_NodePtrとした場合、このFixtureでさらにいろいろなテストが可能になりそう

@available(anyAppleOS 26.0, *)
extension TreeNodeOnlyFixture {

  /// `_NodeKey<Base>`用の最小の`Base`。ノードにpayloadが無いため、
  /// テスト内で挿入時に設定した`___recycle_count`をキーとして使う。
  ///
  /// `___tracking_tag`は使わない: `.end`以外は先頭から0始まりの連番(=保管スロット番号)
  /// であることが不変条件のため、重複キーの再現などテストの都合で自由に書き換えてはならない。
  /// `___recycle_count`にはそのような制約が無いため、こちらをキー代わりに使う。
  enum SealKey: _UnsafeNodePtrType & _BaseNode_KeyInterface {
    typealias _Key = UnsafeNode.Seal
    static func __get_value(_ p: _NodePtr) -> UnsafeNode.Seal {
      p.pointee.___recycle_count
    }
  }
  
  enum TrackingTagKey: _UnsafeNodePtrType & _BaseNode_KeyInterface {
    typealias _Key = _TrackingTag
    static func __get_value(_ p: _NodePtr) -> _TrackingTag {
      p.pointee.___tracking_tag
    }
  }
}
