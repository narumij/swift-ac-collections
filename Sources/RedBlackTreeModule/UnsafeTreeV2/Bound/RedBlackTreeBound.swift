//
//  RedBlackTreeBound.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/19.
//

public enum RedBlackTreeBound<_Key>: _KeyType {
  case start
  case lower(_Key)
  case upper(_Key)
  case end
}

