//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2024 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

import Foundation

@frozen
public struct RedBlackTreeSlice<Base>: RedBlackTreeSliceInternal where Base: ___TreeBase & ___TreeIndex {

  public typealias Tree = ___Tree<Base>
  public typealias _Value = Tree._Value
  public typealias Element = Tree._Value
  public typealias Index = Tree.Index
  public typealias Indices = Tree.Indices
  public typealias SubSequence = Self

  @usableFromInline
  let __tree_: Tree

  @usableFromInline
  var _start, _end: _NodePtr

  @inlinable
  @inline(__always)
  internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
    __tree_ = tree
    _start = start
    _end = end
  }
}

extension RedBlackTreeSlice: Sequence & Collection & BidirectionalCollection {}

extension RedBlackTreeSlice {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public __consuming func makeIterator() -> Tree._Values {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension RedBlackTreeSlice {

  @inlinable
  @inline(__always)
  internal func forEach(_ body: (Element) throws -> Void) rethrows {
    try __tree_.___for_each_(__p: _start, __l: _end) {
      try body(__tree_[$0])
    }
  }
}

extension RedBlackTreeSlice {

  @inlinable
  @inline(__always)
  public func forEach(_ body: (Index, Element) throws -> Void) rethrows {
    try __tree_.___for_each_(__p: _start, __l: _end) {
      try body(___index($0), __tree_[$0])
    }
  }

  @inlinable
  @inline(__always)
  public func ___forEach(_ body: (_NodePtr, Element) throws -> Void) rethrows {
    try __tree_.___for_each_(__p: _start, __l: _end) {
      try body($0, __tree_[$0])
    }
  }
}

extension RedBlackTreeSlice {

  /// - Complexity: O(log *n* + *k*)
  @inlinable
  @inline(__always)
  public var count: Int {
    __tree_.___distance(from: _start, to: _end)
  }
}

extension RedBlackTreeSlice {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var startIndex: Index {
    ___index(_start)
  }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var endIndex: Index {
    ___index(_end)
  }
}

extension RedBlackTreeSlice {

  /// - Complexity: O(1)
  @inlinable
  public subscript(position: Index) -> Element {
    @inline(__always) _read {
      __tree_.___ensureValid(subscript: position.rawValue)
      yield __tree_[position.rawValue]
    }
  }
}

extension RedBlackTreeSlice {

  #if COMPATIBLE_ATCODER_2025
    @inlinable
    public subscript(_unsafe position: Index) -> Element {
      @inline(__always) _read {
        yield __tree_[position.rawValue]
      }
    }
  #else
    /// - Warning: This subscript trades safety for performance. Using an invalid index results in undefined behavior.
    /// - Complexity: O(1)
    @inlinable
    public subscript(unchecked position: Index) -> Element {
      @inline(__always) _read {
        yield __tree_[position.rawValue]
      }
    }
  #endif
}

extension RedBlackTreeSlice {

  /// - Complexity: O(log *n*)
  @inlinable
  @inline(__always)
  public subscript(bounds: Range<Index>) -> SubSequence {
    // TODO: ベースでの有効性しかチェックしていない。__containsのチェックにするか要検討
    __tree_.___ensureValid(
      begin: bounds.lowerBound.rawValue,
      end: bounds.upperBound.rawValue)
    return .init(
      tree: __tree_,
      start: bounds.lowerBound.rawValue,
      end: bounds.upperBound.rawValue)
  }

  #if COMPATIBLE_ATCODER_2025
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public subscript(_unsafe bounds: Range<Index>) -> SubSequence {
      .init(
        tree: __tree_,
        start: bounds.lowerBound.rawValue,
        end: bounds.upperBound.rawValue)
    }
  #else
    @inlinable
    @inline(__always)
    public subscript<R>(bounds: R) -> SubSequence where R: RangeExpression, R.Bound == Index {
      let bounds: Range<Index> = bounds.relative(to: self)
      // TODO: ベースでの有効性しかチェックしていない。__containsのチェックにするか要検討
      __tree_.___ensureValid(
        begin: bounds.lowerBound.rawValue,
        end: bounds.upperBound.rawValue)
      return .init(
        tree: __tree_,
        start: bounds.lowerBound.rawValue,
        end: bounds.upperBound.rawValue)
    }

    /// - Warning: This subscript trades safety for performance. Using an invalid index results in undefined behavior.
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public subscript(unchecked bounds: Range<Index>) -> SubSequence {
      .init(
        tree: __tree_,
        start: bounds.lowerBound.rawValue,
        end: bounds.upperBound.rawValue)
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
        start: bounds.lowerBound.rawValue,
        end: bounds.upperBound.rawValue)
    }
  #endif
}

extension RedBlackTreeSlice {

  /// - Complexity: O(log *n* + *k*)
  @inlinable
  //  @inline(__always)
  public func distance(from start: Index, to end: Index) -> Int {
    __tree_.___distance(from: start.rawValue, to: end.rawValue)
  }
}

extension RedBlackTreeSlice {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func index(before i: Index) -> Index {
    // 標準のArrayが単純に加算することにならい、範囲チェックをしない
    ___index(__tree_.___index(before: i.rawValue))
  }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func index(after i: Index) -> Index {
    // 標準のArrayが単純に加算することにならい、範囲チェックをしない
    ___index(__tree_.___index(after: i.rawValue))
  }

  /// - Complexity: O(*d*)
  @inlinable
  //  @inline(__always)
  public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
    // 標準のArrayが単純に加減算することにならい、範囲チェックをしない
    __tree_.___index(i.rawValue, offsetBy: distance, limitedBy: limit.rawValue)
      .map { ___index($0) }
  }
}

extension RedBlackTreeSlice {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func formIndex(after i: inout Index) {
    // 標準のArrayが単純に加算することにならい、範囲チェックをしない
    __tree_.___formIndex(after: &i.rawValue)
  }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func formIndex(before i: inout Index) {
    // 標準のArrayが単純に減算することにならい、範囲チェックをしない
    __tree_.___formIndex(before: &i.rawValue)
  }

  /// - Complexity: O(*d*)
  @inlinable
  //  @inline(__always)
  public func formIndex(_ i: inout Index, offsetBy distance: Int) {
    // 標準のArrayが単純に加減算することにならい、範囲チェックをしない
    __tree_.___formIndex(&i.rawValue, offsetBy: distance)
  }

  /// - Complexity: O(*d*)
  @inlinable
  @inline(__always)  // コールスタック無駄があるのでalways
  public func formIndex(_ i: inout Index, offsetBy distance: Int, limitedBy limit: Index)
    -> Bool
  {
    // 標準のArrayが単純に加減算することにならい、範囲チェックをしない
    if let ii = index(i, offsetBy: distance, limitedBy: limit) {
      i = ii
      return true
    }
    return false
  }
}

// MARK: - Utility

extension RedBlackTreeSlice {

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
    ___contains(i.rawValue)
  }
}

extension RedBlackTreeSlice {

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
}

extension RedBlackTreeSlice {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public func reversed() -> Tree._Values.Reversed {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension RedBlackTreeSlice {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var indices: Indices {
    __tree_.makeIndices(start: _start, end: _end)
  }
}

extension RedBlackTreeSlice {

  /// - Complexity: O(*n*)
  @inlinable
  @inline(__always)
  public func sorted() -> [Element] {
    __tree_.___copy_to_array(_start, _end)
  }
}

extension RedBlackTreeSlice {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  @inline(__always)
  public func elementsEqual<OtherSequence>(
    _ other: OtherSequence, by areEquivalent: (Element, OtherSequence.Element) throws -> Bool
  ) rethrows -> Bool where OtherSequence: Sequence {
    try __tree_.elementsEqual(_start, _end, other, by: areEquivalent)
  }

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  @inline(__always)
  public func lexicographicallyPrecedes<OtherSequence>(
    _ other: OtherSequence, by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> Bool where OtherSequence: Sequence, Element == OtherSequence.Element {
    try __tree_.lexicographicallyPrecedes(_start, _end, other, by: areInIncreasingOrder)
  }
}

extension RedBlackTreeSlice where _Value: Equatable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  @inline(__always)
  public func elementsEqual<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence: Sequence, Element == OtherSequence.Element {
    __tree_.elementsEqual(_start, _end, other, by: ==)
  }
}

extension RedBlackTreeSlice where _Value: Comparable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  @inline(__always)
  public func lexicographicallyPrecedes<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence: Sequence, Element == OtherSequence.Element {
    __tree_.lexicographicallyPrecedes(_start, _end, other, by: <)
  }
}

extension RedBlackTreeSlice: Equatable where _Value: Equatable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.isIdentical(to: rhs) || lhs.elementsEqual(rhs)
  }
}

extension RedBlackTreeSlice: Comparable where _Value: Comparable {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of `lhs` and `rhs`.
  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    !lhs.isIdentical(to: rhs) && lhs.lexicographicallyPrecedes(rhs)
  }
}

extension RedBlackTreeSlice {

  @inlinable
  @inline(__always)
  mutating func ___element(at ptr: _NodePtr) -> Element? {
    guard !__tree_.___is_subscript_null(ptr) else {
      return nil
    }
    return __tree_[ptr]
  }
}

#if swift(>=5.5)
  extension RedBlackTreeSlice: @unchecked Sendable
  where Element: Sendable {}
#endif

// MARK: - Is Identical To

extension RedBlackTreeSlice: ___RedBlackTreeIsIdenticalTo {}
