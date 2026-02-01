//
//  UnsafeMutableTreeRangeProtocol.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/31.
//

@usableFromInline
protocol UnsafeMutableTreeRangeProtocol: UnsafeMutableTreeRangeBaseInterface, _PayloadValueBride {}

extension UnsafeMutableTreeRangeProtocol {

  @inlinable
  @inline(__always)
  @discardableResult
  package mutating func ___remove_first() -> (__r: _NodePtr, payload: _PayloadValue)? {
    guard _start != _end else { return nil }
    let ___e = __tree_[_start]
    let __r = __tree_.erase(_start)
    return (__r, ___e)
  }

  @inlinable
  @inline(__always)
  @discardableResult
  package mutating func ___remove_last() -> (__r: _NodePtr, payload: _PayloadValue)? {
    guard _start != _end else { return nil }
    let ___l = __tree_prev_iter(_end)
    let ___e = __tree_[___l]
    let __r = __tree_.erase(___l)
    return (__r, ___e)
  }
}

extension UnsafeMutableTreeRangeProtocol {

  @inlinable
  @inline(__always)
  @discardableResult
  package mutating func ___remove(at ptr: _NodePtr) -> (__r: _NodePtr, payload: _PayloadValue)? {
    guard !ptr.___is_subscript_null else { return nil }
    let ___e = __tree_[ptr]
    let __r = __tree_.erase(ptr)
    return (__r, ___e)
  }
}

extension UnsafeMutableTreeRangeProtocol {

  @inlinable
  @inline(__always)
  @discardableResult
  package mutating func ___remove(from: _NodePtr, to: _NodePtr) -> _NodePtr {
    guard from != _end else { return __tree_.end }
    guard __tree_.isValidRawRange(lower: from.checked, upper: to.checked) else {
      fatalError(.invalidIndex)
    }
    return __tree_.erase(from, to)
  }

  @inlinable
  @inline(__always)
  @discardableResult
  package mutating func ___unchecked_remove(from: _NodePtr, to: _NodePtr) -> _NodePtr {
    guard from != _end else { return __tree_.end }
    return __tree_.___checking_erase(from, to)
  }

  @inlinable
  package mutating func ___remove(_ rawRange: UnsafeTreeRangeExpression) -> _NodePtr {
    let (lower, upper) = rawRange._relative(to: __tree_)
    return ___remove(from: lower, to: upper)
  }

  @inlinable
  package mutating func ___unchecked_remove(_ rawRange: UnsafeTreeRangeExpression) -> _NodePtr {
    let (lower, upper) = rawRange._relative(to: __tree_)
    return ___unchecked_remove(from: lower, to: upper)
  }
}
