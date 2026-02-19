//
//  UnsafeMutableTreeRangeProtocol.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/31.
//

@usableFromInline
protocol _RemoveV2: UnsafeMutableTreeRangeBaseInterface, _PayloadValueBride {}

extension _RemoveV2 {

  @discardableResult
  @inlinable @inline(__always)
  package mutating func ___remove_first() -> (__r: _NodePtr, payload: _PayloadValue)? {
    guard _start != _end else { return nil }
    return __tree_._unchecked_remove(at: _start)
  }

  @discardableResult
  @inlinable @inline(__always)
  package mutating func ___remove_last() -> (__r: _NodePtr, payload: _PayloadValue)? {
    guard _start != _end else { return nil }
    return __tree_._unchecked_remove(at: __tree_.__tree_prev_iter(_end))
  }
}
