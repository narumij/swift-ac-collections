//
//  Untitled.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/09/30.
//

import RedBlackTreeCollections

@available(anyAppleOS 26.0, *)
struct TreeFoundamentalFixture: ~Copyable {
  var root: _NodePtr
  var end_node: UnsafeNode
  var storage: InlineArray<128, UnsafeNode>
}

@available(anyAppleOS 26.0, *)
extension TreeFoundamentalFixture {

  mutating func invariant() -> Int {
    if end_node.__left_ != .nullptr {
      return 0
    }
    if withUnsafePointer(to: &end_node, { root != $0 }) {
      return 0
    }
    return 1
  }
}

@available(anyAppleOS 26.0, *)
extension TreeFoundamentalFixture: _UnsafeNodePtrType & NullPtrInterface {
  var nullptr: _NodePtr { .nullptr }
}

// 以下の二つと類似関数を基本層とする定義で構わない気がしてきた
@available(anyAppleOS 26.0, *)
extension TreeFoundamentalFixture: TreeAlgorithmBaseProtocol_ptr {}

@available(anyAppleOS 26.0, *)
extension TreeFoundamentalFixture: TreeAlgorithmProtocol_ptr {}

// キーやバリューを_NodePtrとした場合、このFixtureでさらにいろいろなテストが可能になりそう
