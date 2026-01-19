//
//  RedBlackTreeBound.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/19.
//

public enum RedBlackTreeBound<_Key: Comparable>: _KeyType {
  case start
  case lower(_Key)
  case upper(_Key)
  case end
}

extension RedBlackTreeBound: Comparable {
  
  public static func < (lhs: RedBlackTreeBound<_Key>, rhs: RedBlackTreeBound<_Key>) -> Bool {
    switch (lhs, rhs) {
    case (.start, _): true
    case (_, .end): true
    case (.end, _): false
    case (_, .start): false
    case (.lower(let l), .lower(let r)): l <= r
    case (.lower(let l), .upper(let r)): l < r
    case (.upper(let l), .upper(let r)): l <= r
    case (.upper, lower): fatalError("左にupper右にlowerを使うのはコーナケース対処が困難なので禁止扱い")
    // Rangeがチェックではじいてくれることを期待してのfalse
    }
  }
}
