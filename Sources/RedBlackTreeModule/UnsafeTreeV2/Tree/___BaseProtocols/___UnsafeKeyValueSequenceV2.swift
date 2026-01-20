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
protocol ___UnsafeKeyValueSequenceV2: ___UnsafeBaseV2, ___TreeIndex
where
  Base: KeyValueComparer,
  Element == (key: _Key, value: _MappedValue),
  _Value == RedBlackTreePair<_Key, _MappedValue>
{
  associatedtype _MappedValue
}

extension ___UnsafeKeyValueSequenceV2 {

  @inlinable
  @inline(__always)
  internal static func ___element(_ __value: _Value) -> Element {
    (__value.key, __value.value)
  }

  @inlinable
  @inline(__always)
  internal static func ___tree_value(_ __element: Element) -> _Value {
    RedBlackTreePair(__element.key, __element.value)
  }

  @inlinable
  @inline(__always)
  public static func ___pointee(_ __value: _Value) -> Element {
    Self.___element(__value)
  }
}

extension ___UnsafeKeyValueSequenceV2 {

  @inlinable
  @inline(__always)
  internal func ___element(_ __value: _Value) -> Element {
    Self.___element(__value)
  }
}

extension ___UnsafeKeyValueSequenceV2 where Self: ___UnsafeCommonV2 {

  @inlinable
  @inline(__always)
  internal var ___first: Element? {
    ___first.map(___element)
  }

  @inlinable
  @inline(__always)
  internal var ___last: Element? {
    ___last.map(___element)
  }
}

extension ___UnsafeKeyValueSequenceV2 where Self: ___UnsafeBaseSequenceV2 {

  @inlinable
  internal func ___min() -> Element? {
    ___min().map(___element)
  }

  /// - Complexity: O(log *n*)
  @inlinable
  internal func ___max() -> Element? {
    ___max().map(___element)
  }
}

extension ___UnsafeKeyValueSequenceV2 where Self: ___UnsafeIndexV2 {

  @inlinable
  internal func ___first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
    try ___first { try predicate(___element($0)) }.map(___element)
  }

  /// - Complexity: O(*n*)
  @inlinable
  internal func ___first_index(where predicate: (Element) throws -> Bool) rethrows -> Index? {
    try ___first_index { try predicate(___element($0)) }
  }
}

extension ___UnsafeKeyValueSequenceV2 {

  @inlinable
  @inline(__always)
  internal func ___value_for(_ __k: _Key) -> _Value? {
    let __ptr = __tree_.find(__k)
    return __tree_.___is_null_or_end(__ptr) ? nil : __tree_[__ptr]
  }
}

extension ___UnsafeKeyValueSequenceV2 {

  @inlinable
  @inline(__always)
  internal func _makeIterator() -> Tree._KeyValues {
    .init(tree: __tree_, start: _start, end: _end)
  }

  @inlinable
  @inline(__always)
  internal func _reversed() -> Tree._KeyValues.Reversed {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension ___UnsafeKeyValueSequenceV2 {

  public typealias Keys = RedBlackTreeIteratorV2<Base>.Keys
  public typealias Values = RedBlackTreeIteratorV2<Base>.MappedValues

  @inlinable
  @inline(__always)
  internal func _keys() -> Keys {
    .init(tree: __tree_, start: _start, end: _end)
  }

  /// - Complexity: O(1)
  @inlinable
  @inline(__always)
  internal func _values() -> Values {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension ___UnsafeKeyValueSequenceV2 {

  @inlinable
  @inline(__always)
  internal func _forEach(_ body: (Element) throws -> Void) rethrows {
    try __tree_.___for_each_(__p: _start, __l: _end) {
      try body(Self.___element(__tree_[$0]))
    }
  }
}

#if COMPATIBLE_ATCODER_2025
extension ___UnsafeKeyValueSequenceV2 {

  @available(*, deprecated, message: "性能問題があり廃止")
  @inlinable
  @inline(__always)
  internal func _forEach(_ body: (Index, Element) throws -> Void) rethrows {
    try __tree_.___for_each_(__p: _start, __l: _end) {
      try body(___index($0), Self.___element(__tree_[$0]))
    }
  }
}
#endif

extension ___UnsafeKeyValueSequenceV2 {

  /// - Complexity: O(*n*)
  @inlinable
  @inline(__always)
  internal func _sorted() -> [Element] {
    __tree_.___copy_to_array(_start, _end, transform: Self.___element)
  }
}

extension ___UnsafeKeyValueSequenceV2 {

  // コンパイラの型推論のバグを踏んでいると想定し、型をちゃんと書くことにし、様子を見ている
  // -> 今の設計だと影響があるが、過去のバグはこの方法では迂回できないことが確認できている

  @inlinable
  internal subscript(_checked position: Index) -> (key: _Key, value: _MappedValue) {
    @inline(__always) get {
      __tree_.___ensureValid(subscript: __tree_.rawValue(position))
      return ___element(__tree_[__tree_.rawValue(position)])
    }
  }

  @inlinable
  internal subscript(_unchecked position: Index) -> (key: _Key, value: _MappedValue) {
    @inline(__always) get {
      return ___element(__tree_[__tree_.rawValue(position)])
    }
  }
}

extension ___UnsafeKeyValueSequenceV2 {

  // あえてElementを返していない
  @inlinable
  @inline(__always)
  public mutating func ___element(at ptr: _NodePtr) -> _Value? {
    guard !__tree_.___is_subscript_null(ptr) else {
      return nil
    }
    return __tree_[ptr]
  }
}
