//
//  RedBlackTreePair+Testiing.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/08.
//

import RedBlackTreeModule

extension RedBlackTreePair {

  @inlinable @inline(__always)
  package init(_ tuple: (Key, Value)) {
    self.init(key: tuple.0, value: tuple.1)
  }
}
