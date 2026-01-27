//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project
//
// Copyright (c) 2024 - 2026 narumij.
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.
//
//===----------------------------------------------------------------------===//

import Foundation

extension RedBlackTreeSliceV2 {

  public struct KeyValue: ___UnsafeCommonV2 & ___UnsafeSubSequenceV2
      & ___UnsafeIndexV2 & ___UnsafeKeyValueSequenceV2
  where
    Base: ___TreeBase & ___TreeIndex & KeyValueComparer,
    Base._Payload == RedBlackTreePair<Base._Key, Base._MappedValue>
  {

    public typealias Tree = UnsafeTreeV2<Base>
    public typealias _Key = Base._Key
    public typealias _RawValue = Tree._Payload
    public typealias _MappedValue = Base._MappedValue
    public typealias Element = (key: _Key, value: _MappedValue)
    public typealias Index = Tree.Index
    public typealias Indices = Tree.Indices
    public typealias SubSequence = Self

    @usableFromInline
    internal let __tree_: Tree

    @usableFromInline
    internal var _start, _end: _NodePtr

    @inlinable
    @inline(__always)
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      __tree_ = tree
      _start = start
      _end = end
    }
  }
}

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSliceV2.KeyValue: Sequence & Collection & BidirectionalCollection {}
#else
  extension RedBlackTreeSliceV2.KeyValue: Sequence {}
#endif

extension RedBlackTreeSliceV2.KeyValue {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public __consuming func makeIterator() -> Tree._KeyValues {
    _makeIterator()
  }
}

extension RedBlackTreeSliceV2.KeyValue {

  #if !COMPATIBLE_ATCODER_2025
    // 2025でpublicになってなかったのは痛恨のミス。でも標準実装が動くはず
    @inlinable
    @inline(__always)
    public func forEach(_ body: (Element) throws -> Void) rethrows {
      try _forEach(body)
    }
  #endif
}

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSliceV2.KeyValue {

    @available(*, deprecated, message: "性能問題があり廃止")
    @inlinable
    @inline(__always)
    public func forEach(_ body: (Index, Element) throws -> Void) rethrows {
      try _forEach(body)
    }
  }
#endif

extension RedBlackTreeSliceV2.KeyValue {

  /// - Complexity: O(log *n* + *k*)
  @inlinable
  @inline(__always)
  public var count: Int { _count }
}

extension RedBlackTreeSliceV2.KeyValue {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var startIndex: Index { _startIndex }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var endIndex: Index { _endIndex }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSliceV2.KeyValue {

    @inlinable
    @inline(__always)
    public var first: Element? {
      guard !___is_empty else { return nil }
      return ___element(__tree_[_start])
    }

    @inlinable
    @inline(__always)
    public var last: Element? {
      guard !___is_empty else { return nil }
      return ___element(__tree_[__tree_prev_iter(_end)])
    }

    /// - Complexity: O(log *n*)
    @inlinable
    public func firstIndex(of key: _Key) -> Index? {
      ___first_index { ($0 as _RawValue).key == key }
    }

    /// - Complexity: O(*n*)
    @inlinable
    public func firstIndex(where predicate: (Element) throws -> Bool) rethrows -> Index? {
      try ___first_index(where: predicate)
    }
  }
#endif

extension RedBlackTreeSliceV2.KeyValue {

  /// - Complexity: O(1)
  @inlinable
  //  public subscript(position: Index) -> Element {
  public subscript(position: Index) -> (key: _Key, value: _MappedValue) {
    //    @inline(__always) get { ___element(self[_checked: position]) }
    @inline(__always) get { self[_checked: position] }
  }
}

extension RedBlackTreeSliceV2.KeyValue {

  #if !COMPATIBLE_ATCODER_2025
    /// - Warning: This subscript trades safety for performance. Using an invalid index results in undefined behavior.
    /// - Complexity: O(1)
    @inlinable
    //    public subscript(unchecked position: Index) -> Element {
    public subscript(unchecked position: Index) -> (key: _Key, value: _MappedValue) {
      //      @inline(__always) get { ___element(self[_unchecked: position]) }
      @inline(__always) get { self[_unchecked: position] }
    }
  #endif
}

extension RedBlackTreeSliceV2.KeyValue {

  #if COMPATIBLE_ATCODER_2025
    /// - Complexity: O(log *n*)
    @inlinable
    @inline(__always)
    public subscript(bounds: Range<Index>) -> SubSequence {
      // TODO: ベースでの有効性しかチェックしていない。__containsのチェックにするか要検討
      __tree_.___ensureValid(
        begin: __tree_.rawValue(bounds.lowerBound),
        end: __tree_.rawValue(bounds.upperBound))
      return .init(
        tree: __tree_,
        start: __tree_.rawValue(bounds.lowerBound),
        end: __tree_.rawValue(bounds.upperBound))
    }
  #endif

  #if !COMPATIBLE_ATCODER_2025 && false
    @inlinable
    @inline(__always)
    public subscript<R>(bounds: R) -> SubSequence where R: RangeExpression, R.Bound == Index {
      let bounds: Range<Index> = bounds.relative(to: self)
      // TODO: ベースでの有効性しかチェックしていない。__containsのチェックにするか要検討
      __tree_.___ensureValid(
        begin: __tree_.rawValue(bounds.lowerBound),
        end: __tree_.rawValue(bounds.upperBound))
      return .init(
        tree: __tree_,
        start: __tree_.rawValue(bounds.lowerBound),
        end: __tree_.rawValue(bounds.upperBound))
    }

    /// - Warning: This subscript trades safety for performance. Using an invalid index results in undefined behavior.
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public subscript(unchecked bounds: Range<Index>) -> SubSequence {
      .init(
        tree: __tree_,
        start: __tree_.rawValue(bounds.lowerBound),
        end: __tree_.rawValue(bounds.upperBound))
    }

    /// - Warning: This subscript trades safety for performance. Using an invalid index results in undefined behavior.
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public subscript<R>(unchecked bounds: R) -> SubSequence
    where R: RangeExpression, R.Bound == Index {
      let bounds: Range<Index> = bounds.relative(to: self)
      return .init(
        tree: __tree_,
        start: __tree_.rawValue(bounds.lowerBound),
        end: __tree_.rawValue(bounds.upperBound))
    }
  #endif
}

extension RedBlackTreeSliceV2.KeyValue {

  /// - Complexity: O(log *n* + *k*)
  @inlinable
  @inline(__always)
  public func distance(from start: Index, to end: Index) -> Int {
    _distance(from: start, to: end)
  }
}

extension RedBlackTreeSliceV2.KeyValue {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func index(before i: Index) -> Index {
    // 標準のArrayが単純に加算することにならい、範囲チェックをしない
    _index(before: i)
  }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func index(after i: Index) -> Index {
    // 標準のArrayが単純に加算することにならい、範囲チェックをしない
    _index(after: i)
  }

  #if !COMPATIBLE_ATCODER_2025
    @inlinable
    //  @inline(__always)
    public func index(_ i: Index, offsetBy distance: Int) -> Index {
      // 標準のArrayが単純に加減算することにならい、範囲チェックをしない
      _index(i, offsetBy: distance)
    }
  #endif

  /// - Complexity: O(*d*)
  @inlinable
  //  @inline(__always)
  public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
    // 標準のArrayが単純に加減算することにならい、範囲チェックをしない
    _index(i, offsetBy: distance, limitedBy: limit)
  }
}

extension RedBlackTreeSliceV2.KeyValue {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func formIndex(after i: inout Index) {
    // 標準のArrayが単純に加算することにならい、範囲チェックをしない
    _formIndex(after: &i)
  }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func formIndex(before i: inout Index) {
    // 標準のArrayが単純に減算することにならい、範囲チェックをしない
    _formIndex(before: &i)
  }

  /// - Complexity: O(*d*)
  @inlinable
  //  @inline(__always)
  public func formIndex(_ i: inout Index, offsetBy distance: Int) {
    // 標準のArrayが単純に加減算することにならい、範囲チェックをしない
    _formIndex(&i, offsetBy: distance)
  }

  /// - Complexity: O(*d*)
  @inlinable
  @inline(__always)  // コールスタック無駄があるのでalways
  public func formIndex(_ i: inout Index, offsetBy distance: Int, limitedBy limit: Index)
    -> Bool
  {
    // 標準のArrayが単純に加減算することにならい、範囲チェックをしない
    _formIndex(&i, offsetBy: distance, limitedBy: limit)
  }
}

// MARK: - Utility

extension RedBlackTreeSliceV2.KeyValue {

  /// Indexがsubscriptやremoveで利用可能か判別します
  ///
  /// - Complexity:
  ///
  ///   ベースがset, map, dictionaryの場合、O(1)
  ///
  ///   ベースがmultiset, multimapの場合 O(log *n*)
  @inlinable
  @inline(__always)
  public func isValid(index i: Index) -> Bool {
    ___contains(__tree_.rawValue(i))
  }
}

extension RedBlackTreeSliceV2.KeyValue {

  #if COMPATIBLE_ATCODER_2025
    /// RangeExpressionがsubscriptやremoveで利用可能か判別します
    ///
    /// - Complexity:
    ///
    ///   ベースがset, map, dictionaryの場合、O(1)
    ///
    ///   ベースがmultiset, multimapの場合 O(log *n*)
    @inlinable
    @inline(__always)
    public func isValid<R: RangeExpression>(
      _ bounds: R
    ) -> Bool where R.Bound == Index {
      let bounds = bounds.relative(to: self)
      return ___contains(bounds)
    }
  #endif
}

extension RedBlackTreeSliceV2.KeyValue {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func reversed() -> Tree._KeyValues.Reversed {
    _reversed()
  }
}

extension RedBlackTreeSliceV2.KeyValue {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var indices: Indices {
    _indices
  }
}

extension RedBlackTreeSliceV2.KeyValue {

  public typealias Keys = RedBlackTreeIteratorV2.Keys<Base>
  public typealias Values = RedBlackTreeIteratorV2.MappedValues<Base>

  #if !COMPATIBLE_ATCODER_2025
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var keys: Keys {
      _keys()
    }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var values: Values {
      _values()
    }
  #endif
}

extension RedBlackTreeSliceV2.KeyValue {

  /// - Complexity: O(*n*)
  @inlinable
  @inline(__always)
  public func sorted() -> [Element] {
    _sorted()
  }
}

extension RedBlackTreeSliceV2.KeyValue where _Key: Equatable, _MappedValue: Equatable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  @inline(__always)
  public func elementsEqual<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence: Sequence, Element == OtherSequence.Element {
    elementsEqual(other, by: ==)
  }
}

extension RedBlackTreeSliceV2.KeyValue where _Key: Comparable, _MappedValue: Comparable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  @inline(__always)
  public func lexicographicallyPrecedes<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence: Sequence, Element == OtherSequence.Element {
    lexicographicallyPrecedes(other, by: <)
  }
}

extension RedBlackTreeSliceV2.KeyValue: Equatable where _Key: Equatable, _MappedValue: Equatable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.isTriviallyIdentical(to: rhs) || lhs.elementsEqual(rhs, by: ==)
  }
}

extension RedBlackTreeSliceV2.KeyValue: Comparable
where _Key: Comparable, _MappedValue: Comparable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    !lhs.isTriviallyIdentical(to: rhs) && lhs.lexicographicallyPrecedes(rhs, by: <)
  }
}

#if swift(>=5.5)
  extension RedBlackTreeSliceV2.KeyValue: @unchecked Sendable
  where Element: Sendable {}
#endif

// MARK: - Is Identical To

extension RedBlackTreeSliceV2.KeyValue: ___UnsafeIsIdenticalToV2 {}

// MARK: - CustomStringConvertible

extension RedBlackTreeSliceV2.KeyValue: CustomStringConvertible {

  @inlinable
  public var description: String {
    _dictionaryDescription(for: self)
  }
}

// MARK: - CustomDebugStringConvertible

extension RedBlackTreeSliceV2.KeyValue: CustomDebugStringConvertible {

  public var debugDescription: String {
    description
  }
}
