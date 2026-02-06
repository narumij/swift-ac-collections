// Copyright 2024-2026 narumij
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
// Copyright © 2003-2025 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

@usableFromInline
protocol ___UnsafeKeyValueSequenceV2__:
  UnsafeTreeSealedRangeProtocol
    & UnsafeTreeRangeProtocol
    & _PayloadValueBride
    & _KeyBride
    & _MappedValueBride
    & _ElementBride
where
  Base: KeyValueComparer & _PairBase_ElementProtocol
{}

@usableFromInline
protocol ___UnsafeKeyValueSequenceV2:
  ___UnsafeKeyValueSequenceV2__
    & ___UnsafeIndexRangeBaseV2
{}

extension ___UnsafeKeyValueSequenceV2__ {

  @inlinable
  @inline(__always)
  internal func ___value_for(_ __k: _Key) -> _PayloadValue? {
    let __ptr = __tree_.find(__k)
    return __ptr.___is_null_or_end ? nil : __tree_[__ptr]
  }
}

extension ___UnsafeKeyValueSequenceV2__ {

  @inlinable
  @inline(__always)
  internal var ___first: Element? {
    ___first.map(Base.__element_)
  }

  @inlinable
  @inline(__always)
  internal var ___last: Element? {
    ___last.map(Base.__element_)
  }
}

extension ___UnsafeKeyValueSequenceV2__ where Self: ___UnsafeBaseSequenceV2 {

  @inlinable
  internal func ___min() -> Element? {
    ___min().map(Base.__element_)
  }

  /// - Complexity: O(log *n*)
  @inlinable
  internal func ___max() -> Element? {
    ___max().map(Base.__element_)
  }
}

extension ___UnsafeKeyValueSequenceV2__ where Self: ___UnsafeIndexV2 {

  @inlinable
  internal func ___first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
    try ___first { try predicate(Base.__element_($0)) }.map(Base.__element_)
  }

  /// - Complexity: O(*n*)
  @inlinable
  internal func ___first_index(where predicate: (Element) throws -> Bool) rethrows -> Index? {
    try ___first_index { try predicate(Base.__element_($0)) }
  }
}

extension ___UnsafeKeyValueSequenceV2__ {

  @inlinable
  @inline(__always)
  internal func _makeIterator() -> Tree._KeyValues {
    .init(start: _sealed_start, end: _sealed_end, tie: __tree_.tied)
  }
}

extension ___UnsafeKeyValueSequenceV2__ {

  /// - Complexity: O(*n*)
  @inlinable
  @inline(__always)
  internal func _sorted() -> [Element] {
    __tree_.___copy_to_array(
      _sealed_start.pointer!, _sealed_end.pointer!, transform: Base.__element_)
  }
}

extension ___UnsafeKeyValueSequenceV2__ {

  @inlinable
  @inline(__always)
  internal func _reversed() -> Tree._KeyValues.Reversed {
    .init(start: _sealed_start, end: _sealed_end, tie: __tree_.tied)
  }
}

extension ___UnsafeKeyValueSequenceV2__ {

  public typealias Keys = RedBlackTreeIteratorV2.Keys<Base>
  public typealias Values = RedBlackTreeIteratorV2.MappedValues<Base>

  @inlinable
  @inline(__always)
  internal func _keys() -> Keys {
    .init(start: _sealed_start, end: _sealed_end, tie: __tree_.tied)
  }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  internal func _values() -> Values {
    .init(start: _sealed_start, end: _sealed_end, tie: __tree_.tied)
  }
}

extension ___UnsafeKeyValueSequenceV2__ {

  @inlinable
  public func ___subscript(_ rawRange: UnsafeTreeSealedRangeExpression)
    -> RedBlackTreeSliceV2<Base>.KeyValue
  {
    let (lower, upper) = rawRange.relative(to: __tree_)
    guard __tree_.isValidSealedRange(lower: lower, upper: upper) else {
      fatalError(.invalidIndex)
    }
    return .init(tree: __tree_, start: lower, end: upper)
  }

  @inlinable
  public func ___unchecked_subscript(_ rawRange: UnsafeTreeSealedRangeExpression)
    -> RedBlackTreeSliceV2<Base>.KeyValue
  {
    let (lower, upper) = rawRange.relative(to: __tree_)
    return .init(tree: __tree_, start: lower, end: upper)
  }
}

extension ___UnsafeKeyValueSequenceV2__ {

  @inlinable
  @inline(__always)
  internal func _forEach(_ body: (Element) throws -> Void) rethrows {
    try __tree_.___for_each_(__p: _sealed_start, __l: _sealed_end) {
      try body(Base.__element_(__tree_[$0]))
    }
  }
}

#if COMPATIBLE_ATCODER_2025
  extension ___UnsafeKeyValueSequenceV2 {

    @available(*, deprecated, message: "性能問題があり廃止")
    @inlinable
    @inline(__always)
    internal func _forEach(_ body: (Index, Element) throws -> Void) rethrows {
      try __tree_.___for_each_(__p: _sealed_start, __l: _sealed_end) {
        try body(___index($0.sealed), Base.__element_(__tree_[$0]))
      }
    }
  }
#endif

extension ___UnsafeKeyValueSequenceV2 {

  // コンパイラの型推論のバグを踏んでいると想定し、型をちゃんと書くことにし、様子を見ている
  // -> 今の設計だと影響があるが、過去のバグはこの方法では迂回できないことが確認できている

  @inlinable
  internal subscript(_checked position: Index) -> (key: _Key, value: _MappedValue) {
    @inline(__always) get {
      return Base.__element_(__tree_[try! __tree_.__sealed_(position).get().pointer])
    }
  }
}
