//
//  UnsafeIndexV4.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/01.
//

@frozen
public struct UnsafeIndexV4: ~Escapable {
  
  @usableFromInline
  package var ptr: _SealedPtr
  
  @_lifetime(borrow _unsafe_end_node)
  @inlinable
  init(_unsafe_end_node: UnsafeMutablePointer<UnsafeNode>, ptr: _SealedPtr) {
    self.ptr = ptr
  }
}

extension RedBlackTreeSet {

  @_lifetime(borrow self)
  @inlinable
  func ___index(_ p: _SealedPtr) -> UnsafeIndexV4 {
    let i = UnsafeIndexV4(_unsafe_end_node: __tree_.__end_node, ptr: p)
    return unsafe _overrideLifetime(i, borrowing: self)
  }

  @_lifetime(borrow self)
  @inlinable
  func ___index_or_nil(_ p: _SealedPtr) -> UnsafeIndexV4? {
    if p.exists {
      let i = UnsafeIndexV4(_unsafe_end_node: __tree_.__end_node, ptr: p)
      return unsafe _overrideLifetime(i, borrowing: self)
    }
    return nil
  }
}

extension RedBlackTreeSet {

  /// - Complexity: O(log *n* + *k*)
  @inlinable
  @inline(__always)
  public func distance(from start: UnsafeIndexV4, to end: UnsafeIndexV4)
    -> Int
  {
    guard
      let d = __tree_.___distance(
        from: start.ptr.purified,
        to: end.ptr.purified)
    else { fatalError(.invalidIndex) }
    return d
  }
}
