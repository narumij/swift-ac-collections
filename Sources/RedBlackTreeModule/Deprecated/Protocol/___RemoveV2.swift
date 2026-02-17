//
//  ___RemoveV2.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/17.
//

@usableFromInline
protocol ___RemoveV2: UnsafeMutableTreeRangeBaseInterface, _PayloadValueBride {}

extension ___RemoveV2 {

  @inlinable
  func isValidNodeRange(lower: _NodePtr, upper: _NodePtr) -> Bool {
    lower == upper || Base.___ptr_comp(lower, upper)
  }

  @discardableResult
  @inlinable @inline(__always)
  package mutating func ___remove(from: _NodePtr, to: _NodePtr) -> _NodePtr {
    guard from != _end else { return __tree_.end }
    guard isValidNodeRange(lower: from, upper: to) else {
      fatalError(.invalidIndex)
    }
    return __tree_.erase(from, to)
  }

  @discardableResult
  @inlinable @inline(__always)
  package mutating func ___unchecked_remove(from: _NodePtr, to: _NodePtr) -> _NodePtr {
    guard from != _end else { return __tree_.end }
    return __tree_.___erase(from, to)
  }
}
