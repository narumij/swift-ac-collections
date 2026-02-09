//
//  UnsafeMutableTreeRangeProtocol.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/31.
//

@usableFromInline
protocol UnsafeMutableTreeRangeProtocol: UnsafeMutableTreeRangeBaseInterface, _PayloadValueBride {}

extension UnsafeMutableTreeRangeProtocol {

  @discardableResult
  @inlinable @inline(__always)
  package mutating func ___remove_first() -> (__r: _NodePtr, payload: _PayloadValue)? {
    guard _start != _end else { return nil }
    return _unchecked_remove(at: _start)
  }

  @discardableResult
  @inlinable @inline(__always)
  package mutating func ___remove_last() -> (__r: _NodePtr, payload: _PayloadValue)? {
    guard _start != _end else { return nil }
    return _unchecked_remove(at: __tree_.__tree_prev_iter(_end))
  }
}

extension UnsafeMutableTreeRangeProtocol {

  @discardableResult
  @inlinable @inline(__always)
  package mutating func ___remove(from: _NodePtr, to: _NodePtr) -> _NodePtr {
    guard from != _end else { return __tree_.end }
    guard __tree_.isValidSealedRange(lower: from.sealed, upper: to.sealed) else {
      fatalError(.invalidIndex)
    }
    return __tree_.erase(from, to)
  }

  @discardableResult
  @inlinable @inline(__always)
  package mutating func ___unchecked_remove(from: _NodePtr, to: _NodePtr) -> _NodePtr {
    guard from != _end else { return __tree_.end }
    return __tree_.___checking_erase(from, to)
  }
}
