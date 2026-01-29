//
//  RedBlackTreeRangeView.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/29.
//

public struct RedBlackTreeKeyOnlyRangeView<Base>: ___UnsafeMutableTreeBaseV2,
  ___UnsafeSubSequenceV2
where
  Base: ___TreeBase,
  Base._Key == Base._PayloadValue,
  Base._Key: Comparable
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
  internal var _start_tag, _end_tag: _TrackingTag
}

extension RedBlackTreeKeyOnlyRangeView {

  @usableFromInline
  var _start: _NodePtr {
    __tree_[_unchecked_tag: _start_tag]
  }

  @usableFromInline
  var _end: _NodePtr {
    __tree_[_unchecked_tag: _end_tag]
  }
}

extension RedBlackTreeKeyOnlyRangeView: Sequence {}

extension RedBlackTreeKeyOnlyRangeView {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public __consuming func makeIterator() -> AnyIterator<Element> {
    fatalError()
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

#if AC_COLLECTIONS_INTERNAL_CHECKS
  extension RedBlackTreeKeyOnlyRangeView {
    package var _copyCount: UInt {
      __tree_.copyCount
    }
  }
#endif

extension RedBlackTreeKeyOnlyRangeView {

  /// - Complexity: O(1)
  @inlinable
  public subscript(unchecked tag: _TrackingTag) -> Element? {
    __tree_[_unchecked_tag: tag].__payload_().pointee
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
  public var startIndex: _TrackingTag { _start_tag }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var endIndex: _TrackingTag { _end_tag }
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
    public func firstIndex(of member: Element) -> _TrackingTag? {
      ___first_tracking_tag { $0 == member }
    }

    /// - Complexity: O( `count` )
    @inlinable
    public func firstIndex(where predicate: (Element) throws -> Bool) rethrows -> _TrackingTag? {
      try ___first_tracking_tag(where: predicate)
    }
  }
#endif

extension RedBlackTreeKeyOnlyRangeView {

  /// - Complexity: O(log *n* + *k*)
  @inlinable
  @inline(__always)
  public func distance(from start: _TrackingTag, to end: _TrackingTag) -> Int {
    __tree_.___distance(
      from: __tree_[_unchecked_tag: start],
      to: __tree_[_unchecked_tag: end])
  }
}

extension RedBlackTreeKeyOnlyRangeView {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func index(before i: _TrackingTag) -> _TrackingTag {
    __tree_
      .___index(before: __tree_[tag: i])
      .trackingTag
  }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func index(after i: _TrackingTag) -> _TrackingTag {
    __tree_
      .___index(after: __tree_[tag: i])
      .trackingTag
  }

  #if !COMPATIBLE_ATCODER_2025
    @inlinable
    //  @inline(__always)
    public func index(_ i: _TrackingTag, offsetBy distance: Int) -> _TrackingTag {
      __tree_
        .___index(__tree_[tag: i], offsetBy: distance)
        .trackingTag
    }
  #endif

  /// - Complexity: O(*d*)
  @inlinable
  //  @inline(__always)
  public func index(_ i: _TrackingTag, offsetBy distance: Int, limitedBy limit: _TrackingTag)
    -> _TrackingTag?
  {
    __tree_
      .___index(__tree_[tag: i], offsetBy: distance, limitedBy: __tree_[tag: limit])?
      .trackingTag
  }
}

extension RedBlackTreeKeyOnlyRangeView {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func formIndex(after i: inout _TrackingTag) {
    i = index(after: i)
  }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func formIndex(before i: inout _TrackingTag) {
    i = index(before: i)
  }

  /// - Complexity: O(*d*)
  @inlinable
  //  @inline(__always)
  public func formIndex(_ i: inout _TrackingTag, offsetBy distance: Int) {
    i = index(i, offsetBy: distance)
  }

  /// - Complexity: O(*d*)
  @inlinable
  @inline(__always)
  public func formIndex(
    _ i: inout _TrackingTag, offsetBy distance: Int, limitedBy limit: _TrackingTag
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

  /// `lowerBound(_:)` は、指定した要素 `member` 以上の値が格納されている
  /// 最初の位置（`Index`）を返します。
  ///
  /// たとえば、ソートされた `[1, 3, 5, 7, 9]` があるとき、
  /// - `lowerBound(0)` は最初の要素 `1` の位置を返します。（つまり `startIndex`）
  /// - `lowerBound(3)` は要素 `3` の位置を返します。
  /// - `lowerBound(4)` は要素 `5` の位置を返します。（`4` 以上で最初に出現する値が `5`）
  /// - `lowerBound(10)` は `endIndex` を返します。
  ///
  /// - Parameter member: 二分探索で検索したい要素
  /// - Returns: 指定した要素 `member` 以上の値が格納されている先頭の `Index`
  /// - Complexity: O(log *n*), where *n* is the number of elements.
  @inlinable
  public func lowerBound(_ member: Element) -> _TrackingTag {
    __tree_.lower_bound(member).trackingTag
  }

  /// `upperBound(_:)` は、指定した要素 `member` より大きい値が格納されている
  /// 最初の位置（`Index`）を返します。
  ///
  /// たとえば、ソートされた `[1, 3, 5, 5, 7, 9]` があるとき、
  /// - `upperBound(3)` は要素 `5` の位置を返します。
  ///   （`3` より大きい値が最初に現れる場所）
  /// - `upperBound(5)` は要素 `7` の位置を返します。
  ///   （`5` と等しい要素は含まないため、`5` の直後）
  /// - `upperBound(9)` は `endIndex` を返します。
  ///
  /// - Parameter member: 二分探索で検索したい要素
  /// - Returns: 指定した要素 `member` より大きい値が格納されている先頭の `Index`
  /// - Complexity: O(log *n*), where *n* is the number of elements.
  @inlinable
  public func upperBound(_ member: Element) -> _TrackingTag {
    __tree_.upper_bound(member).trackingTag
  }
}
