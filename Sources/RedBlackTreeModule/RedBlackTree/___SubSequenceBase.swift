// Copyright 2024 narumij
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

@usableFromInline
protocol ___SubSequenceBase: ___RedBlackTree & Sequence & Collection
    & BidirectionalCollection
where
  Base: ___RedBlackTreeSubSequence,
  Tree == ___Tree<Base>,
  Index == Tree.Index,
  Indices == Tree.Indices,
  Element == Tree.Element,
  Iterator == ElementIterator<Tree>,
  SubSequence == Self
{
  associatedtype Base
  var __tree_: Tree { get }
  var _start: _NodePtr { get set }
  var _end: _NodePtr { get set }
  init(tree: Tree, start: _NodePtr, end: _NodePtr)
}

extension ___SubSequenceBase {

  @inlinable @inline(__always)
  func ___index(_ rawValue: _NodePtr) -> Index {
    .init(tree: __tree_, rawValue: rawValue)
  }

  @inlinable @inline(__always)
  func ___raw_index(_ p: _NodePtr) -> RawIndex {
    __tree_.makeRawIndex(rawValue: p)
  }
}

extension ___SubSequenceBase {

  /// - Complexity: O(1)
  @inlinable @inline(__always)
  public __consuming func makeIterator() -> ElementIterator<Tree> {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension ___SubSequenceBase {

  @inlinable
  internal func forEach(_ body: (Element) throws -> Void) rethrows {
    try __tree_.___for_each_(__p: _start, __l: _end, body: body)
  }
}

extension ___SubSequenceBase {

  @inlinable
  public func forEach(_ body: (RawIndex, Element) throws -> Void) rethrows {
    try __tree_.___for_each_(__p: _start, __l: _end) {
      try body(___raw_index($0), __tree_[$0])
    }
  }

  @inlinable
  public func ___forEach(_ body: (_NodePtr, Element) throws -> Void) rethrows {
    try __tree_.___for_each_(__p: _start, __l: _end) {
      try body($0, __tree_[$0])
    }
  }
}

extension ___SubSequenceBase {

  /// - Complexity: O(log *n* + *k*)
  @inlinable @inline(__always)
  public var count: Int {
    __tree_.___distance(from: _start, to: _end)
  }
}

extension ___SubSequenceBase {

  /// - Complexity: O(1)
  @inlinable @inline(__always)
  public var startIndex: Index {
    ___index(_start)
  }

  /// - Complexity: O(1)
  @inlinable @inline(__always)
  public var endIndex: Index {
    ___index(_end)
  }
}

extension ___SubSequenceBase {

  // 断念
  //    @inlinable
  //    public func lowerBound(_ member: Element) -> Index {
  //      base.__lower_bound(base.__key(member), base.__root(), endIndex)
  //    }
  //
  //    @inlinable
  //    public func upperBound(_ member: Element) -> Index {
  //      base.__upper_bound(base.__key(member), base.__root(), endIndex)
  //    }
}

extension ___SubSequenceBase {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public subscript(position: Index) -> Element {

    _read {
      //      guard _tree.___ptr_less_than_or_equal(_start, position.rawValue),
      //        _tree.___ptr_less_than(position.rawValue, _end)
      //      else {
      //        fatalError(.outOfRange)
      //      }
      yield __tree_[position.rawValue]
    }
  }
}

extension ___SubSequenceBase {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public subscript(position: RawIndex) -> Element {
    @inline(__always)
    _read {
      //      guard _tree.___ptr_less_than_or_equal(_start, position.rawValue),
      //        _tree.___ptr_less_than(position.rawValue, _end)
      //      else {
      //        fatalError(.outOfRange)
      //      }
      yield __tree_[position.rawValue]
    }
  }
}

extension ___SubSequenceBase {

  /// - Complexity: O(log *n*)
  @inlinable
  public subscript(bounds: Range<Index>) -> SubSequence {
    guard __tree_.___ptr_less_than_or_equal(_start, bounds.lowerBound.rawValue),
      __tree_.___ptr_less_than_or_equal(bounds.upperBound.rawValue, _end)
    else {
      fatalError(.outOfRange)
    }
    return .init(
      tree: __tree_,
      start: bounds.lowerBound.rawValue,
      end: bounds.upperBound.rawValue)
  }
}

extension ___SubSequenceBase {

  /// - Complexity: O(log *n* + *k*)
  @inlinable
  public func distance(from start: Index, to end: Index) -> Int {
    __tree_.___distance(from: start.rawValue, to: end.rawValue)
  }
}

extension ___SubSequenceBase {

  /// - Complexity: O(1)
  @inlinable @inline(__always)
  public func index(before i: Index) -> Index {
    // 標準のArrayが単純に加算することにならい、範囲チェックをしない
    ___index(__tree_.___index(before: i.rawValue))
  }

  /// - Complexity: O(1)
  @inlinable @inline(__always)
  public func index(after i: Index) -> Index {
    // 標準のArrayが単純に加算することにならい、範囲チェックをしない
    ___index(__tree_.___index(after: i.rawValue))
  }

  /// - Complexity: O(*d*)
  @inlinable
  public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
    // 標準のArrayが単純に加減算することにならい、範囲チェックをしない
    __tree_.___index(i.rawValue, offsetBy: distance, limitedBy: limit.rawValue)
      .map { ___index($0) }
  }
}

extension ___SubSequenceBase {

  /// - Complexity: O(1)
  @inlinable
  public func formIndex(after i: inout Index) {
    // 標準のArrayが単純に加算することにならい、範囲チェックをしない
    __tree_.___formIndex(after: &i.rawValue)
  }

  /// - Complexity: O(1)
  @inlinable
  public func formIndex(before i: inout Index) {
    // 標準のArrayが単純に減算することにならい、範囲チェックをしない
    __tree_.___formIndex(before: &i.rawValue)
  }

  /// - Complexity: O(*d*)
  @inlinable
  public func formIndex(_ i: inout Index, offsetBy distance: Int) {
    // 標準のArrayが単純に加減算することにならい、範囲チェックをしない
    __tree_.___formIndex(&i.rawValue, offsetBy: distance)
  }

  /// - Complexity: O(*d*)
  @inlinable
  @inline(__always) // コールスタック無駄があるのでalways
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

// MARK: - Raw Index Sequence

extension ___SubSequenceBase {

  /// RawIndexは赤黒木ノードへの軽量なポインタとなっていて、rawIndicesはRawIndexのシーケンスを返します。
  /// 削除時のインデックス無効対策がイテレータに施してあり、削除操作に利用することができます。
  ///
  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var rawIndices: RawIndexSequence<Tree> {
    RawIndexSequence(
      tree: __tree_,
      start: _start,
      end: _end)
  }
}

// MARK: - Utility

extension ___SubSequenceBase {
  // TODO: 計算量

  @inlinable
  @inline(__always)
  func ___is_valid_index(index i: _NodePtr) -> Bool {
    guard i != .nullptr, __tree_.___is_valid(i) else {
      return false
    }
    return __tree_.___ptr_closed_range_contains(_start, _end, i)
  }

  @inlinable
  @inline(__always)
  public func isValid(index i: Index) -> Bool {
    ___is_valid_index(index: i.___unchecked_rawValue)
  }

  @inlinable
  @inline(__always)
  public func isValid(index i: RawIndex) -> Bool {
    ___is_valid_index(index: i.rawValue)
  }
}

extension ___SubSequenceBase {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public __consuming func reversed() -> ReversedElementIterator<Self.Tree> {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension ___SubSequenceBase {

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  public var indices: Indices {
    __tree_.makeIndices(start: _start, end: _end)
  }
}

extension ___SubSequenceBase {

  @inlinable
  @inline(__always)
  mutating func ___element(at ptr: _NodePtr) -> Element? {
    guard
      !___is_null_or_end(ptr),
      __tree_.___is_valid_index(ptr)
    else {
      return nil
    }
    return __tree_[ptr]
  }

  @inlinable
  @inline(__always)
  public __consuming func ___makeIterator() -> NodeIterator<Tree> {
    NodeIterator(tree: __tree_, start: _start, end: _end)
  }

  @inlinable
  @inline(__always)
  public __consuming func ___makeIterator() -> NodeElementIterator<Tree> {
    NodeElementIterator(tree: __tree_, start: __tree_.__begin_node, end: __tree_.__end_node())
  }
}

extension ___SubSequenceBase {

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  public func elementsEqual<OtherSequence>(
    _ other: OtherSequence, by areEquivalent: (Element, OtherSequence.Element) throws -> Bool
  ) rethrows -> Bool where OtherSequence: Sequence {
    try makeIterator().elementsEqual(other, by: areEquivalent)
  }

  /// - Complexity: O(*m*), where *m* is the lesser of the length of the
  ///   sequence and the length of `other`.
  @inlinable
  public func lexicographicallyPrecedes<OtherSequence>(
    _ other: OtherSequence, by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> Bool where OtherSequence: Sequence, Element == OtherSequence.Element {
    try makeIterator().lexicographicallyPrecedes(other, by: areInIncreasingOrder)
  }
}
