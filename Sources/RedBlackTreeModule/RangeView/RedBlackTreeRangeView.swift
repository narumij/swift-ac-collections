//
//  RedBlackTreeRangeView.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/29.
//

public struct RedBlackTreeKeyOnlyRangeView<Base>: UnsafeMutableTreeHost,
  ___UnsafeSubSequenceV2
where
  Base: ___TreeBase,
  Base._Key == Base._PayloadValue
{
  @usableFromInline
  internal init(__tree_: UnsafeTreeV2<Base>, _start: _NodePtr, _end: _NodePtr) {
    self.__tree_ = __tree_
    self._start_tag = _start.trackingTag
    self._end_tag = _end.trackingTag
  }

  public typealias Element = Base._PayloadValue

  @usableFromInline
  internal var __tree_: Tree

  @usableFromInline
  internal var _start_tag, _end_tag: _RawTrackingTag
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
    __tree_[_raw: _start_tag]
  }

  @usableFromInline
  var _end: _NodePtr {
    __tree_[_raw: _end_tag]
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
  public mutating func removeSubrange() {
    __tree_.ensureUnique()
    __tree_.___checking_erase(_start, _end)
  }

  @inlinable
  public mutating func removeSubrange(where shouldBeRemoved: (Element) throws -> Bool) rethrows {
    __tree_.ensureUnique()
    try __tree_.___checking_erase_if(_start, _end, shouldBeRemoved: shouldBeRemoved)
  }
}

extension RedBlackTreeKeyOnlyRangeView {

  /// - Complexity: O(1)
  @inlinable
  subscript(_raw trackingTag: _RawTrackingTag) -> Element? {
    let ptr = __tree_[_raw: trackingTag]
    guard !ptr.___is_null_or_end, !ptr.___is_garbaged else {
      fatalError(.invalidIndex)
    }
    return ptr.__payload_().pointee
  }

  /// - Complexity: O(1)
  @inlinable
  public subscript(tag: RedBlackTreeTrackingTag) -> Element? {
    let ptr = tag.relative(to: __tree_)
    guard !ptr.___is_null_or_end, !ptr.___is_garbaged else {
      fatalError(.invalidIndex)
    }
    return ptr.__payload_().pointee
  }
}

// MARK: -

extension RedBlackTreeKeyOnlyRangeView {

  /// - Complexity: O(log `Base.count` + `count`)
  @inlinable
  @inline(__always)
  public var count: Int { _count }
}

extension RedBlackTreeKeyOnlyRangeView {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var startIndex: RedBlackTreeTrackingTag {
    .create(_start_tag)
  }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var endIndex: RedBlackTreeTrackingTag {
    .create(_end_tag)
  }
}

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
    public func firstIndex(where predicate: (Element) throws -> Bool) rethrows -> RedBlackTreeTrackingTag {
      try ___first_tracking_tag(where: predicate)
    }
  }
#endif

extension RedBlackTreeKeyOnlyRangeView {

  /// - Complexity: O(log *n* + *k*)
  @inlinable
  @inline(__always)
  public func distance(from start: RedBlackTreeTrackingTag, to end: RedBlackTreeTrackingTag) -> Int {
    __tree_.___distance(
      from: start.relative(to: __tree_),
      to: end.relative(to: __tree_))
  }
}

extension RedBlackTreeKeyOnlyRangeView {

  /// - Complexity: O(1)
  @inlinable
  public func index(before i: RedBlackTreeTrackingTag) -> RedBlackTreeTrackingTag {
    .create(__tree_.___index(before: i.relative(to: __tree_)))
  }

  /// - Complexity: O(1)
  @inlinable
  public func index(after i: RedBlackTreeTrackingTag) -> RedBlackTreeTrackingTag {
    .create(__tree_.___index(after: i.relative(to: __tree_)))
  }

  /// - Complexity: O(`distance`)
  @inlinable
  public func index(_ i: RedBlackTreeTrackingTag, offsetBy distance: Int) -> RedBlackTreeTrackingTag {
    .create(__tree_.___index(i.relative(to: __tree_), offsetBy: distance))
  }

  /// - Complexity: O(`distance`)
  @inlinable
  public func index(_ i: RedBlackTreeTrackingTag, offsetBy distance: Int, limitedBy limit: RedBlackTreeTrackingTag)
    -> RedBlackTreeTrackingTag
  {
    .create(
      __tree_.___index(
        i.relative(to: __tree_), offsetBy: distance, limitedBy: limit.relative(to: __tree_)))
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
    _ i: inout RedBlackTreeTrackingTag, offsetBy distance: Int, limitedBy limit: RedBlackTreeTrackingTag
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
    let ptr = index.relative(to: __tree_)
    guard !ptr.___is_null, !ptr.___is_end, !ptr.___is_garbaged else {
      fatalError(.invalidIndex)
    }
    let ___e = __tree_[ptr]
    _ = __tree_.erase(ptr)
    return ___e
  }
}
