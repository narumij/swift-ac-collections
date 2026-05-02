//
//  UnsafeIndexV4.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/01.
//

@frozen
public struct UnsafeIndexV4: ~Escapable {
  
  @usableFromInline
  package var __end_node: UnsafeMutablePointer<UnsafeNode>

  @usableFromInline
  package var ptr: _SealedPtr

  @_lifetime(borrow _unsafe_end_node)
  @inlinable
  init(_unsafe_end_node: UnsafeMutablePointer<UnsafeNode>, ptr: _SealedPtr) {
    self.__end_node = _unsafe_end_node
    self.ptr = ptr
  }
}

extension UnsafeIndexV4 {
  
  public func assumeExactSameTree(_unsafe_end_node: UnsafeMutablePointer<UnsafeNode>) {
    guard __end_node == _unsafe_end_node else {
      fatalError()
    }
  }

  public mutating func edit(_ transform: (_SealedPtr) -> _SealedPtr) {
    ptr = transform(ptr)
  }
}

extension RedBlackTreeSet {

  //　コンパイルは通るが、CoWが効いた場合に、これだとやはりまずいかもしれない
  // Undefined Behaviorにはできないので、end_node比較でトラップする必要がある
  @_lifetime(borrow self)
  @inlinable
  func ___index(_ p: _SealedPtr) -> UnsafeIndexV4 {
    let i = UnsafeIndexV4(_unsafe_end_node: __tree_.__end_node, ptr: p)
    return unsafe _overrideLifetime(i, borrowing: self)
  }

  //　コンパイルは通るが、CoWが効いた場合に、これだとやはりまずいかもしれない
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
    start.assumeExactSameTree(_unsafe_end_node: __tree_.__end_node)
    end.assumeExactSameTree(_unsafe_end_node: __tree_.__end_node)
    guard
      let d = __tree_.___distance(
        from: start.ptr.purified,
        to: end.ptr.purified)
    else { fatalError(.invalidIndex) }
    return d
  }
}

extension RedBlackTreeSet {

  /// - Complexity: O(1)
  @inlinable
  public func index(before i: UnsafeIndexV4) -> UnsafeIndexV4 {
    var i = i
    formIndex(before: &i)
    return i
  }

  /// - Complexity: O(1)
  @inlinable
  public func index(after i: UnsafeIndexV4) -> UnsafeIndexV4 {
    var i = i
    formIndex(after: &i)
    return i
  }

  /// - Complexity: O(`distance`)
  @inlinable
  public func index(_ i: UnsafeIndexV4, offsetBy distance: Int)
    -> UnsafeIndexV4
  {
    var i = i
    formIndex(&i, offsetBy: distance)
    return i
  }

  /// - Complexity: O(`distance`)
  @inlinable
  public func index(
    _ i: UnsafeIndexV4, offsetBy distance: Int, limitedBy limit: UnsafeIndexV4
  )
    -> UnsafeIndexV4?
  {
    var i = i
    let result = formIndex(&i, offsetBy: distance, limitedBy: limit)
    return result ? i : nil
  }
}

extension RedBlackTreeSet {

  /// - Complexity: O(1)
  @inlinable
  public func formIndex(before i: inout UnsafeIndexV4) {
    i.assumeExactSameTree(_unsafe_end_node: __tree_.__end_node)
    i.edit { $0.purified.flatMap { ___tree_prev_iter($0.pointer).sealed } }
  }

  /// - Complexity: O(1)
  @inlinable
  public func formIndex(after i: inout UnsafeIndexV4) {
    i.assumeExactSameTree(_unsafe_end_node: __tree_.__end_node)
    i.edit { $0.purified.flatMap { ___tree_next_iter($0.pointer).sealed } }
  }

  /// - Complexity: O(*d*)
  @inlinable
  public func formIndex(_ i: inout UnsafeIndexV4, offsetBy distance: Int) {
    i.assumeExactSameTree(_unsafe_end_node: __tree_.__end_node)
    i.edit { $0.purified.flatMap { ___tree_adv_iter($0.pointer, distance).sealed } }
  }

  /// - Complexity: O(*d*)
  @inlinable
  public func formIndex(
    _ i: inout UnsafeIndexV4,
    offsetBy distance: Int,
    limitedBy limit: UnsafeIndexV4
  )
    -> Bool
  {
    i.assumeExactSameTree(_unsafe_end_node: __tree_.__end_node)
    limit.assumeExactSameTree(_unsafe_end_node: __tree_.__end_node)

    guard let ___i = i.ptr.purified.pointer
    else { return false }

    let __l = limit.ptr.purified.map(\.pointer)

    return ___form_index(___i, offsetBy: distance, limitedBy: __l) {
      i.ptr = $0.sealed
    }
  }
}
