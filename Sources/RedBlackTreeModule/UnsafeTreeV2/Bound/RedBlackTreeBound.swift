//
//  RedBlackTreeBound.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/19.
//

public enum RBTBound<T: Comparable> {
  case start
  case lower(T)
  case upper(T)
  case end
}

extension RBTBound: Comparable {
  public static func < (lhs: RBTBound<T>, rhs: RBTBound<T>) -> Bool {
    switch (lhs, rhs) {
    case (.start, _): true
    case (_, .end): true
    case (.end, _): false
    case (_, .start): false
    case (.lower(let l), .lower(let r)): l < r
    case (.lower(let l), .upper(let r)): l <= r
    case (.upper, _): false  // fatalError("左にupperを使うのはコーナケース対処が困難なので禁止扱い")
    // Rangeがチェックではじいてくれることを期待してのfalse
    }
  }
  func relative<C: RBTCollection>(to collection: C) -> C.Index where T == C.Key {
    switch self {
    case .start: collection.startIndex
    case .end: collection.endIndex
    case .lower(let l): collection.lowerBound(l)
    case .upper(let r): collection.upperBound(r)
    }
  }
}
