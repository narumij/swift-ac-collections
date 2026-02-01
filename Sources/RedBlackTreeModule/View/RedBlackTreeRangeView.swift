//
//  RedBlackTreeRangeView.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/29.
//

public struct RedBlackTreeKeyOnlyRangeView<Base>: UnsafeMutableTreeRangeProtocol,
  ___UnsafeSubSequenceV2, ___UnsafeCommonV2
where
  Base: ___TreeBase & ___TreeIndex,
  Base._Key == Base._PayloadValue
{
  @usableFromInline
  internal init(__tree_: UnsafeTreeV2<Base>, _start: _NodePtr, _end: _NodePtr) {
    self.__tree_ = __tree_
    self.startIndex = .create(_start.trackingTag)
    self.endIndex = .create(_end.trackingTag)
  }

  public typealias Element = Base._PayloadValue

  @usableFromInline
  internal var __tree_: Tree

  public let startIndex, endIndex: RedBlackTreeTrackingTag
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
  var _start: _NodePtr {
    try! __tree_[startIndex].get()
  }

  @usableFromInline
  var _end: _NodePtr {
    try! __tree_[endIndex].get()
  }
}

extension RedBlackTreeKeyOnlyRangeView: Sequence {}

extension RedBlackTreeKeyOnlyRangeView {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public __consuming func makeIterator() -> UnsafeIterator.ValueObverse<Base> {
    .init(start: _start, end: _end, tie: __tree_.tied)
  }
}

extension RedBlackTreeKeyOnlyRangeView {

  @inlinable
  public mutating func removeAll() {
    __tree_.ensureUnique()
    __tree_.___checking_erase(_start, _end)
  }

  @inlinable
  public mutating func removeAll(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
    __tree_.ensureUnique()
    try __tree_.___checking_erase_if(_start, _end, shouldBeRemoved: shouldBeRemoved)
  }
}

extension RedBlackTreeKeyOnlyRangeView {

  /// - Complexity: O(1)
  @inlinable
  public subscript(tag: RedBlackTreeTrackingTag) -> Element? {
    (try? __tree_[tag].get())?.__payload_().pointee
  }
}

// MARK: -

extension RedBlackTreeKeyOnlyRangeView {

  /// - Complexity: O(`count`)
  @inlinable
  @inline(__always)
  public var count: Int { ___count }
}

//extension RedBlackTreeKeyOnlyRangeView {
//
//  /// - Complexity: O(1)
//  @inlinable
//  @inline(__always)
//  public var startIndex: RedBlackTreeTrackingTag {
//    startIndex
//  }
//
//  /// - Complexity: O(1)
//  @inlinable
//  @inline(__always)
//  public var endIndex: RedBlackTreeTrackingTag {
//    endIndex
//  }
//}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeKeyOnlyRangeView {

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var first: Element? {
      guard _start != _end else { return nil }
      return __tree_[_start]
    }

    /// - Complexity: O( log `count` )
    @inlinable
    public func firstIndex(of member: Element) -> RedBlackTreeTrackingTag {
      ___first_tracking_tag { $0 == member }
    }

    /// - Complexity: O( `count` )
    @inlinable
    public func firstIndex(where predicate: (Element) throws -> Bool) rethrows
      -> RedBlackTreeTrackingTag
    {
      try ___first_tracking_tag(where: predicate)
    }
  }
#endif

extension RedBlackTreeKeyOnlyRangeView {

  /// - Complexity: O(log *n* + *k*)
  @inlinable
  @inline(__always)
  public func distance(from start: RedBlackTreeTrackingTag, to end: RedBlackTreeTrackingTag) -> Int
  {
    __tree_.___distance(
      from: try! start.relative(to: __tree_).get(),
      to: try! end.relative(to: __tree_).get())
  }
}

extension RedBlackTreeKeyOnlyRangeView {

  /// - Complexity: O(1)
  @inlinable
  public func index(before i: RedBlackTreeTrackingTag) -> RedBlackTreeTrackingTag {
    try? i.relative(to: __tree_)
      .flatMap { ___tree_prev_iter($0) }
      .map { .create($0) }
      .get()
  }

  /// - Complexity: O(1)
  @inlinable
  public func index(after i: RedBlackTreeTrackingTag) -> RedBlackTreeTrackingTag {
    try? i.relative(to: __tree_)
      .flatMap { ___tree_next_iter($0) }
      .map { .create($0) }
      .get()
  }

  /// - Complexity: O(`distance`)
  @inlinable
  public func index(_ i: RedBlackTreeTrackingTag, offsetBy distance: Int) -> RedBlackTreeTrackingTag
  {
    try? i.relative(to: __tree_)
      .flatMap { ___tree_adv_iter($0, distance) }
      .map { .create($0) }
      .get()
  }

  /// - Complexity: O(`distance`)
  @inlinable
  public func index(
    _ i: RedBlackTreeTrackingTag, offsetBy distance: Int, limitedBy limit: RedBlackTreeTrackingTag
  )
    -> RedBlackTreeTrackingTag
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
  public func formIndex(before i: inout RedBlackTreeTrackingTag) {
    i = index(before: i)
  }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func formIndex(after i: inout RedBlackTreeTrackingTag) {
    i = index(after: i)
  }

  /// - Complexity: O(*d*)
  @inlinable
  //  @inline(__always)
  public func formIndex(_ i: inout RedBlackTreeTrackingTag, offsetBy distance: Int) {
    i = index(i, offsetBy: distance)
  }

  /// - Complexity: O(*d*)
  @inlinable
  @inline(__always)
  public func formIndex(
    _ i: inout RedBlackTreeTrackingTag,
    offsetBy distance: Int,
    limitedBy limit: RedBlackTreeTrackingTag
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

// 以下は実験的な実装。Viewには載せない

extension RedBlackTreeKeyOnlyRangeView {

  @inlinable
  @discardableResult
  public mutating func remove(at index: RedBlackTreeTrackingTag) -> Element {
    __tree_.ensureUnique()
    guard case .success(let __p) = index.relative(to: __tree_) else {
      fatalError(.invalidIndex)
    }
    return _unchecked_remove(at: __p).payload
  }
}
