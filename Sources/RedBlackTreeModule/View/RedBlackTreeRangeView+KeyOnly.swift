//
//  RedBlackTreeRangeView.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/29.
//

import Foundation

@frozen
public struct RedBlackTreeKeyOnlyRangeView<Base>: UnsafeMutableTreeHost
where Base: ___TreeBase & ScalarValueTrait {

  @usableFromInline
  internal init(__tree_: UnsafeTreeV2<Base>, _start: _SealedPtr, _end: _SealedPtr) {
    self.__tree_ = __tree_
    self.startIndex = _start.band(__tree_.tied)
    self.endIndex = _end.band(__tree_.tied)
  }

  public typealias Index = _TieWrappedPtr
  public typealias Element = Base._PayloadValue

  @usableFromInline
  internal var __tree_: Tree
  
  // _SealedPtr不可
  public var startIndex: Index
  public let endIndex: Index
}

#if AC_COLLECTIONS_INTERNAL_CHECKS
  extension RedBlackTreeKeyOnlyRangeView {
    package var _copyCount: UInt {
      __tree_.copyCount
    }
  }
#endif

extension RedBlackTreeKeyOnlyRangeView {

  @inlinable
  var _raw_range: (_NodePtr, _NodePtr) {
    guard
      let _start = __tree_.__purified_(startIndex).pointer,
      let _end = __tree_.__purified_(endIndex).pointer
    else {
      return (__tree_.__end_node, __tree_.__end_node)
    }
    return (_start, _end)
  }

  // TODO: _NodePtrであるべきか、_SealedPtrであるべきか。使い分けの吟味

  @inlinable
  var _range: (_SealedPtr, _SealedPtr) {
    let _start = __tree_.__purified_(startIndex)
    let _end = __tree_.__purified_(endIndex)
    guard
      _start.isValid, _end.isValid
    else {
      return (__tree_.__end_node.sealed, __tree_.__end_node.sealed)
    }
    return (_start, _end)
  }
}

extension RedBlackTreeKeyOnlyRangeView {

  @inlinable
  func ___index(_ p: _SealedPtr) -> UnsafeIndexV3 {
    p.band(__tree_.tied)
  }

  @inlinable
  func ___index_or_nil(_ p: _SealedPtr) -> UnsafeIndexV3? {
    p.exists ? p.band(__tree_.tied) : nil
  }
}

extension RedBlackTreeKeyOnlyRangeView: Sequence {}

extension RedBlackTreeKeyOnlyRangeView {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public __consuming func makeIterator() -> UnsafeIterator.ValueObverse<Base> {
    let (_start, _end) = _range
    return .init(start: _start, end: _end, tie: __tree_.tied)
  }

  /// - Complexity: O(`count`)
  @inlinable
  @inline(__always)
  public __consuming func sorted() -> [Element] {
    let (_start, _end) = _range
    return __tree_.___copy_to_array(_start.pointer!, _end.pointer!)
  }

  /// - Complexity: O(`count`)
  @inlinable
  @inline(__always)
  public __consuming func reversed() -> [Element] {
    let (_start, _end) = _range
    return __tree_.___rev_copy_to_array(_start.pointer!, _end.pointer!)
  }
}

// MARK: -

public protocol ScalarBaseInit: ___TreeBase & ScalarValueTrait {
  static func create(_ view: RedBlackTreeKeyOnlyRangeView<Self>) -> Self
}

extension RedBlackTreeSet: ScalarBaseInit {
  public static func create(_ view: RedBlackTreeKeyOnlyRangeView<Self>) -> Self {
    .init(__tree_: view.__tree_)
  }
}

extension RedBlackTreeMultiSet: ScalarBaseInit {
  public static func create(_ view: RedBlackTreeKeyOnlyRangeView<Self>) -> Self {
    .init(__tree_: view.__tree_)
  }
}

extension RedBlackTreeKeyOnlyRangeView where Base: ScalarBaseInit {
  public func unranged() -> Base { .create(self) }
}

// MARK: -

extension RedBlackTreeKeyOnlyRangeView {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var isEmpty: Bool {
    let (l, u) = _raw_range
    return l != u
  }

  /// - Complexity: O(`count`)
  @inlinable
  @inline(__always)
  public var count: Int {
    let (l, u) = _raw_range
    return (try? ___safe_distance(l, u).get()) ?? 0
  }
}

extension RedBlackTreeKeyOnlyRangeView {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var first: Element? {
    let (_start, _end) = _raw_range
    guard _start != _end else { return nil }
    return __tree_[_unsafe_raw: _start]
  }

  @inlinable
  @inline(__always)
  public var last: Element? {
    let (_start, _end) = _raw_range
    guard _start != _end else { return nil }
    return __tree_[_unsafe_raw: __tree_prev_iter(_end)]
  }
}

extension RedBlackTreeKeyOnlyRangeView {

  @inlinable
  @discardableResult
  public mutating func popFirst() -> Element? {
    __tree_.ensureUnique()
    let (_start, _end) = _raw_range
    guard _start != _end else { return nil }
    let (_p, _r) = _unchecked_remove(at: _start)
    startIndex = ___index(_p.sealed)
    return _r
  }

  @inlinable
  @discardableResult
  public mutating func popLast() -> Element? {
    __tree_.ensureUnique()
    let (_start, _end) = _raw_range
    guard _start != _end else { return nil }
    return _unchecked_remove(at: __tree_.__tree_prev_iter(_end)).payload
  }

  @inlinable
  @discardableResult
  public mutating func removeFirst() -> Element {
    __tree_.ensureUnique()
    let (_start, _end) = _raw_range
    guard _start != _end else { fatalError(.emptyFirst) }
    let (_p, _r) = _unchecked_remove(at: _start)
    startIndex = ___index(_p.sealed)
    return _r
  }

  @inlinable
  @discardableResult
  public mutating func removeLast() -> Element {
    __tree_.ensureUnique()
    let (_start, _end) = _raw_range
    guard _start != _end else { fatalError(.emptyLast) }
    return _unchecked_remove(at: __tree_.__tree_prev_iter(_end)).payload
  }
}

extension RedBlackTreeKeyOnlyRangeView {

  @inlinable
  public mutating func erase() {
    __tree_.ensureUnique()
    let (_start, _end) = _raw_range
    __tree_.___erase(_start, _end)
  }

  @inlinable
  public mutating func erase(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
    __tree_.ensureUnique()
    let (_start, _end) = _range
    let result = try __tree_.___erase_if(_start, _end, shouldBeRemoved: shouldBeRemoved)
    if case .failure(let e) = result {
      fatalError(e.localizedDescription)
    }
  }
}

extension RedBlackTreeKeyOnlyRangeView {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  @inline(__always)
  public func elementsEqual<OtherSequence>(
    _ other: OtherSequence, by areEquivalent: (Element, OtherSequence.Element) throws -> Bool
  ) rethrows -> Bool where OtherSequence: Sequence {
    let (_start, _end) = _raw_range
    return try __tree_.elementsEqual(_start, _end, other, by: areEquivalent)
  }

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  @inline(__always)
  public func lexicographicallyPrecedes<OtherSequence>(
    _ other: OtherSequence, by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> Bool where OtherSequence: Sequence, Element == OtherSequence.Element {
    let (_start, _end) = _raw_range
    return try __tree_.lexicographicallyPrecedes(
      _start, _end, other, by: areInIncreasingOrder)
  }
}

extension RedBlackTreeKeyOnlyRangeView where _PayloadValue: Equatable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  @inline(__always)
  public func elementsEqual<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence: Sequence, Element == OtherSequence.Element {
    elementsEqual(other, by: ==)
  }
}

extension RedBlackTreeKeyOnlyRangeView where _PayloadValue: Comparable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  @inline(__always)
  public func lexicographicallyPrecedes<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence: Sequence, Element == OtherSequence.Element {
    lexicographicallyPrecedes(other, by: <)
  }
}

extension RedBlackTreeKeyOnlyRangeView: Equatable where _PayloadValue: Equatable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs._isdentical(to: rhs) || lhs.elementsEqual(rhs)
  }
}

extension RedBlackTreeKeyOnlyRangeView: Comparable where _PayloadValue: Comparable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    !lhs._isdentical(to: rhs) && lhs.lexicographicallyPrecedes(rhs)
  }
}

#if swift(>=5.5)
  extension RedBlackTreeKeyOnlyRangeView: @unchecked Sendable
  where Element: Sendable {}
#endif

// MARK: - Is Identical To

extension RedBlackTreeKeyOnlyRangeView {

  @inlinable
  @inline(__always)
  public func _isdentical(to other: Self) -> Bool {
    let (_start, _end) = _range
    let (_other_start, _other_end) = other._range
    return __tree_._isIdentical(to: other.__tree_) && _start == _other_start
      && _end == _other_end
  }
}

// MARK: -

extension RedBlackTreeKeyOnlyRangeView {

  /// Indexがsubscriptで利用可能か判別します
  ///
  /// endも含めた有効判定がしたい場合は、Index.isValidが利用可能です。
  ///
  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func isValid(index: Index) -> Bool {
    let i = __tree_.__purified_(index)  // __retrieve_でもテストは通る
    guard i.___is_end == false, let i = i.pointer else { return false }
    let (_start, _end) = _raw_range
    return __tree_.___ptr_range_comp(_start, i, _end)
  }
}
