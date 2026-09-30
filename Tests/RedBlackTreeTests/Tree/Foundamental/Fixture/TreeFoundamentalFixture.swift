//
//  Untitled.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/09/30.
//

import RedBlackTreeCollections
import TrailingElementsModule

struct TreeFoundamentalFixture: ~Copyable {
  var storage: TrailingArray<Header>
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

extension TreeFoundamentalFixture: _NodePtrType {
  typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
  typealias _NodeRef = UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>
}

extension TreeFoundamentalFixture: NullPtrInterface {
  var nullptr: _NodePtr { .nullptr }
}

extension TreeFoundamentalFixture: TreeAlgorithmBaseProtocol_ptr {}
extension TreeFoundamentalFixture: TreeAlgorithmProtocol_ptr {}
