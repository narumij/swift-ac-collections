//
//  RedBlackTreeBound.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/19.
//

public enum RedBlackTreeBound<T: Comparable> {
  case start
  case lower(T)
  case upper(T)
  case end
}

extension RedBlackTreeBound: Comparable {
  public static func < (lhs: RedBlackTreeBound<T>, rhs: RedBlackTreeBound<T>) -> Bool {
    switch (lhs, rhs) {
    case (.start, _): true
    case (_, .end): true
    case (.end, _): false
    case (_, .start): false
    case (.lower(let l), .lower(let r)): l <= r
    case (.lower(let l), .upper(let r)): l < r
    case (.upper(let l), .upper(let r)): l <= r
    case (.upper, lower): false  // fatalError("左にupperを使うのはコーナケース対処が困難なので禁止扱い")
    // Rangeがチェックではじいてくれることを期待してのfalse
    }
  }
}
