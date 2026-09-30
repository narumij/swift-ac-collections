//
//  Untitled.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/09/30.
//

import RedBlackTreeCollections
import TrailingElementsModule

struct TreeFoundamentalFixture: ~Copyable {
  var root: _NodePtr
  var end_node: UnsafeNode
  var storage: TrailingArray<Header>
}

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

extension TreeFoundamentalFixture {

  struct Header: TrailingElements {
    typealias Element = Slot
    let trailingCount: Int
  }

  struct Slot {
    var node: UnsafeNode
    var value: Int
  }
}

extension TreeFoundamentalFixture: _UnsafeNodePtrType & NullPtrInterface {
  var nullptr: _NodePtr { .nullptr }
}

// 以下の二つと類似関数を基本層とする定義で構わない気がしてきた
extension TreeFoundamentalFixture: TreeAlgorithmBaseProtocol_ptr {}
extension TreeFoundamentalFixture: TreeAlgorithmProtocol_ptr {}

// キーやバリューを_NodePtrとした場合、このFixtureでさらにいろいろなテストが可能になりそう
