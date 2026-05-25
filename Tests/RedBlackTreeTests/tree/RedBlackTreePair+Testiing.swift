//
//  RedBlackTreePair+Testiing.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/08.
//

import RedBlackTreeModule

extension RedBlackTreePair {

  public init(key: Key, value: Value) {
    self.init(tuple: (key, value))
  }
  
  public init(_ tuple: (Key, Value)) {
    self.init(tuple: tuple)
  }
}
