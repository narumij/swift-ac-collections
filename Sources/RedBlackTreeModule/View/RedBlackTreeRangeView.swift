//
//  RedBlackTreeRangeView.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/29.
//

public struct RedBlackTreeKeyOnlyRangeView<Base>: UnsafeMutableTreeHost
    & _ScalarBase_ElementProtocol, BidirectionalSequence
where Base: ___TreeBase {
  @usableFromInline
  internal init(__tree_: UnsafeTreeV2<Base>, _start: _NodePtr, _end: _NodePtr) {
    self.__tree_ = __tree_
    self.startIndex = .create(_start)
    self.endIndex = .create(_end)
  }

  public typealias Index = TaggedSeal
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
  var _range: (_NodePtr, _NodePtr) {
    guard
      let _start = __tree_.resolve(startIndex).pointer,
      let _end = __tree_.resolve(endIndex).pointer
    else {
      return (__tree_.__end_node, __tree_.__end_node)
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
    return __tree_.___copy_to_array(_start, _end)
  }

  /// - Complexity: O(`count`)
  @inlinable
  @inline(__always)
  public __consuming func reversed() -> [Element] {
    let (_start, _end) = _range
    return __tree_.___rev_copy_to_array(_start, _end)
  }
}

// MARK: -

@usableFromInline
internal protocol BaseInit {
  associatedtype Tree
  init(__tree_: Tree)
}

extension RedBlackTreeSet: BaseInit {}

extension RedBlackTreeKeyOnlyRangeView
where
  Base: BaseInit,
  Base.Tree == UnsafeTreeV2<Base>
{
  func unranged() -> Base {
    Base(__tree_: __tree_)
  }
}

// MARK: -

extension RedBlackTreeKeyOnlyRangeView {

  /// - Complexity: O(`count`)
  @inlinable
  @inline(__always)
  public var count: Int {
    let (l, u) = _range
    return (try? ___safe_distance(l, u).get()) ?? 0
  }
}

extension RedBlackTreeKeyOnlyRangeView {

  /// - Complexity: O(log *n* + *k*)
  @inlinable
  @inline(__always)
  public func distance(from start: Index, to end: Index) -> Int {
    __tree_.___distance(
      from: try! start.relative(to: __tree_).get(),
      to: try! end.relative(to: __tree_).get())
  }
}

extension RedBlackTreeKeyOnlyRangeView {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var first: Element? {
    let (_start, _end) = _range
    guard _start != _end else { return nil }
    return __tree_[_start]
  }

  @inlinable
  @inline(__always)
  public var last: Element? {
    let (_start, _end) = _range
    guard _start != _end else { return nil }
    return __tree_[__tree_prev_iter(_end)]
  }
}

extension RedBlackTreeKeyOnlyRangeView {

  @inlinable
  @discardableResult
  public mutating func popFirst() -> Element? {
    __tree_.ensureUnique()
    let (_start, _end) = _range
    guard _start != _end else { return nil }
    let (_p, _r) = _unchecked_remove(at: _start)
    startIndex = .create(_p)
    return _r
  }

  @inlinable
  @discardableResult
  public mutating func popLast() -> Element? {
    __tree_.ensureUnique()
    let (_start, _end) = _range
    guard _start != _end else { return nil }
    return _unchecked_remove(at: __tree_.__tree_prev_iter(_end)).payload
  }

  @inlinable
  @discardableResult
  public mutating func removeFirst() -> Element {
    __tree_.ensureUnique()
    let (_start, _end) = _range
    guard _start != _end else { fatalError(.emptyFirst) }
    let (_p, _r) = _unchecked_remove(at: _start)
    startIndex = .create(_p)
    return _r
  }

  @inlinable
  @discardableResult
  public mutating func removeLast() -> Element {
    __tree_.ensureUnique()
    let (_start, _end) = _range
    guard _start != _end else { fatalError(.emptyLast) }
    return _unchecked_remove(at: __tree_.__tree_prev_iter(_end)).payload
  }

  @inlinable
  public mutating func removeAll() {
    __tree_.ensureUnique()
    let (_start, _end) = _range
    __tree_.___checking_erase(_start, _end)
  }

  @inlinable
  public mutating func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
    __tree_.ensureUnique()
    let (_start, _end) = _range
    try __tree_.___checking_erase_if(_start, _end, shouldBeRemoved: shouldBeRemoved)
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
    let (_start, _end) = _range
    return try __tree_.elementsEqual(_start, _end, other, by: areEquivalent)
  }

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  @inline(__always)
  public func lexicographicallyPrecedes<OtherSequence>(
    _ other: OtherSequence, by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> Bool where OtherSequence: Sequence, Element == OtherSequence.Element {
    let (_start, _end) = _range
    return try __tree_.lexicographicallyPrecedes(_start, _end, other, by: areInIncreasingOrder)
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
    return __tree_.isTriviallyIdentical(to: other.__tree_) && _start == _other_start
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
    try! tag.relative(to: __tree_)
      .map { $0.__value_().pointee }
      .get()
  }

  /// - Complexity: O(1)
  @inlinable
  public subscript(result tag: Index) -> Result<Element, SafePtrError> {
    tag.relative(to: __tree_).map { $0.__value_().pointee }
  }
}

extension RedBlackTreeKeyOnlyRangeView {

  /// - Complexity: O(1)
  @inlinable
  public func index(before i: Index) -> Index {
    i.relative(to: __tree_)
      .flatMap { ___tree_prev_iter($0) }
      .flatMap { .create($0) }
  }

  /// - Complexity: O(1)
  @inlinable
  public func index(after i: Index) -> Index {
    i.relative(to: __tree_)
      .flatMap { ___tree_next_iter($0) }
      .flatMap { .create($0) }
  }
}

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeKeyOnlyRangeView {

    @inlinable
    public subscript(bounds: TrackingTagRangeExpression) -> RedBlackTreeKeyOnlyRangeView<Base> {
      let (lower, upper) = bounds.relative(to: __tree_)
      guard __tree_.isValidRawRange(lower: lower.checked, upper: upper.checked) else {
        fatalError(.invalidIndex)
      }
      return .init(__tree_: __tree_, _start: lower, _end: upper)
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeKeyOnlyRangeView {

    /// - Complexity: O(`distance`)
    @inlinable
    public func index(_ i: Index, offsetBy distance: Int) -> Index {
      i.relative(to: __tree_)
        .flatMap { ___tree_adv_iter($0, distance) }
        .flatMap { .create($0) }
    }

    /// - Complexity: O(`distance`)
    @inlinable
    public func index(
      _ i: Index, offsetBy distance: Int, limitedBy limit: Index
    )
      -> Index?
    {
      let __l = limit.relative(to: __tree_)
      return try? i.relative(to: __tree_)
        .flatMap { ___tree_adv_iter($0, distance, __l) }
        .map { .create($0) }
        .get()
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
      _ i: inout TaggedSeal,
      offsetBy distance: Int,
      limitedBy limit: TaggedSeal
    )
      -> Bool
    {
      if let result = index(i, offsetBy: distance, limitedBy: limit) {
        i = result
        return true
      }
      return false
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeKeyOnlyRangeView {
    /// Indexがsubscriptやremoveで利用可能か判別します
    ///
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public func isValid(index: Index) -> Bool {
      guard
        let i: _NodePtr = __tree_.resolve(index).pointer,
        !i.___is_end
      else {
        return false
      }
      let (_start, _end) = _range
      return __tree_.___ptr_closed_range_contains(_start, _end, i)
    }
  }
#endif
