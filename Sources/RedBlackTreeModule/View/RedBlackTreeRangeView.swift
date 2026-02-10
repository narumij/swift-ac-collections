//
//  RedBlackTreeRangeView.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/29.
//

import Foundation

public struct RedBlackTreeKeyOnlyRangeView<Base>: UnsafeMutableTreeHost, BidirectionalSequence
where Base: ___TreeBase & ScalarValueTrait {

  @usableFromInline
  internal init(__tree_: UnsafeTreeV2<Base>, _start: _SealedPtr, _end: _SealedPtr) {
    self.__tree_ = __tree_
    self.startIndex = _start.tag
    self.endIndex = _end.tag
  }

  public typealias Index = _SealedTag
  public typealias Element = Base._PayloadValue

  @usableFromInline
  internal var __tree_: Tree

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

  @usableFromInline
  var _raw_range: (_NodePtr, _NodePtr) {
    guard
      let _start = __tree_.__retrieve_(startIndex).pointer,
      let _end = __tree_.__retrieve_(endIndex).pointer
    else {
      return (__tree_.__end_node, __tree_.__end_node)
    }
    return (_start, _end)
  }

  // TODO: _NodePtrであるべきか、_SealedPtrであるべきか。使い分けの吟味

  @usableFromInline
  var _range: (_SealedPtr, _SealedPtr) {
    let _start = __tree_.__retrieve_(startIndex)
    let _end = __tree_.__retrieve_(endIndex)
    guard
      _start.isValid, _end.isValid
    else {
      return (__tree_.__end_node.sealed, __tree_.__end_node.sealed)
    }
    return (_start, _end)
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

extension RedBlackTreeKeyOnlyRangeView where Base: ScalarBaseInit {
  public func unranged() -> Base { .create(self) }
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

// MARK: -

extension RedBlackTreeKeyOnlyRangeView {

  /// - Complexity: O(`count`)
  @inlinable
  @inline(__always)
  public var count: Int {
    let (l, u) = _raw_range
    return (try? ___safe_distance(l, u).get()) ?? 0
  }
}

extension RedBlackTreeKeyOnlyRangeView
where Base: _UnsafeNodePtrType & _BaseNode_SignedDistanceInterface {

  /// - Complexity: O(log *n* + *k*)
  @inlinable
  @inline(__always)
  public func distance(from start: Index, to end: Index) -> Int {
    guard
      let d = __tree_.___distance(
        from: __tree_.__purified_(start),
        to: __tree_.__purified_(end))
    else {
      fatalError(.invalidIndex)
    }
    return d
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
    startIndex = .sealedTag(_p)
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
    startIndex = .sealedTag(_p)
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

  @inlinable
  public mutating func removeAll() {
    __tree_.ensureUnique()
    let (_start, _end) = _raw_range
    __tree_.___erase(_start, _end)
  }

  @inlinable
  public mutating func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
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
    lhs.isTriviallyIdentical(to: rhs) || lhs.elementsEqual(rhs)
  }
}

extension RedBlackTreeKeyOnlyRangeView: Comparable where _PayloadValue: Comparable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    !lhs.isTriviallyIdentical(to: rhs) && lhs.lexicographicallyPrecedes(rhs)
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
  public func isTriviallyIdentical(to other: Self) -> Bool {
    let (_start, _end) = _range
    let (_other_start, _other_end) = other._range
    return __tree_._isIdentical(to: other.__tree_) && _start == _other_start
      && _end == _other_end
  }
}

extension RedBlackTreeKeyOnlyRangeView {

  package func ___node_positions() -> UnsafeIterator._RemoveAwarePointers {
    let (_start, _end) = _range
    return .init(_start: _start, _end: _end)
  }
}

// MARK: -

extension RedBlackTreeKeyOnlyRangeView {

  /// - Complexity: O(1)
  @inlinable
  public subscript(tag: Index) -> Element {
    try! self[result: tag].get()
  }

  /// - Complexity: O(1)
  @inlinable
  public subscript(result tag: Index) -> Result<Element, SealError> {
    __tree_.__purified_(tag)
      .map { $0.pointer.__value_().pointee }
  }
}

extension RedBlackTreeKeyOnlyRangeView {

  /// - Complexity: O(1)
  @inlinable
  public func index(before i: Index) -> Index {
    __tree_.__purified_(i)
      .flatMap { ___tree_prev_iter($0.pointer) }
      .flatMap { .sealedTag($0) }
  }

  /// - Complexity: O(1)
  @inlinable
  public func index(after i: Index) -> Index {
    __tree_.__purified_(i)
      .flatMap { ___tree_next_iter($0.pointer) }
      .flatMap { .sealedTag($0) }
  }
}

extension RedBlackTreeKeyOnlyRangeView {

  /// - Complexity: O(`distance`)
  @inlinable
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    __tree_.__purified_(i)
      .flatMap { ___tree_adv_iter($0.pointer, distance) }
      .flatMap { .sealedTag($0) }
  }

  /// - Complexity: O(`distance`)
  @inlinable
  public func index(
    _ i: Index, offsetBy distance: Int, limitedBy limit: Index
  )
    -> Index?
  {
    var i = i
    let result = formIndex(&i, offsetBy: distance, limitedBy: limit)
    return result ? i : nil
  }
}

extension RedBlackTreeKeyOnlyRangeView {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func formIndex(before i: inout Index) {
    i = index(before: i)
  }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func formIndex(after i: inout Index) {
    i = index(after: i)
  }

  /// - Complexity: O(*d*)
  @inlinable
  //  @inline(__always)
  public func formIndex(_ i: inout Index, offsetBy distance: Int) {
    i = index(i, offsetBy: distance)
  }

  /// - Complexity: O(*d*)
  @inlinable
  @inline(__always)
  public func formIndex(
    _ i: inout _SealedTag,
    offsetBy distance: Int,
    limitedBy limit: _SealedTag
  )
    -> Bool
  {
    guard let ___i = __tree_.__purified_(i).pointer else { return false }
    let __l = __tree_.__purified_(limit).map(\.pointer)
    return ___form_index(___i, offsetBy: distance, limitedBy: __l) {
      i = $0.flatMap { .sealedTag($0) }
    }
  }
}

extension RedBlackTreeKeyOnlyRangeView {

  /// Indexがsubscriptで利用可能か判別します
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
