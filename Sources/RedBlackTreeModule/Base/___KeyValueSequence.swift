// Copyright 2024-2025 narumij
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
protocol ___KeyValueSequence: ___Base
where
  Base: KeyValueComparer,
  Element == (key: _Key, value: _MappedValue),
  _Value == RedBlackTreePair<_Key, _MappedValue>
{
  associatedtype _MappedValue
}

extension ___KeyValueSequence {

  @inlinable
  @inline(__always)
  static func ___element(_ __value: _Value) -> Element {
    (__value.key, __value.value)
  }

  @inlinable
  @inline(__always)
  public static func ___tree_value(_ __element: Element) -> _Value {
    RedBlackTreePair(__element.key, __element.value)
  }
  
  @inlinable
  @inline(__always)
  public static func ___pointee(_ __value: _Value) -> Element {
    Self.___element(__value)
  }
}

extension ___KeyValueSequence {

  @inlinable
  @inline(__always)
  func ___element(_ __value: _Value) -> Element {
    Self.___element(__value)
  }
}

extension ___KeyValueSequence where Self: ___Common {

  @inlinable
  @inline(__always)
  var ___first: Element? {
    ___first.map(___element)
  }

  @inlinable
  @inline(__always)
  var ___last: Element? {
    ___last.map(___element)
  }
}

extension ___KeyValueSequence where Self: ___BaseSequence {

  @inlinable
  func ___min() -> Element? {
    ___min().map(___element)
  }

  /// - Complexity: O(log *n*)
  @inlinable
  func ___max() -> Element? {
    ___max().map(___element)
  }
}

extension ___KeyValueSequence where Self: ___IndexProvider {

  @inlinable
  func ___first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
    try ___first { try predicate(___element($0)) }.map(___element)
  }
  
  /// - Complexity: O(*n*)
  @inlinable
  func ___first_index(where predicate: (Element) throws -> Bool) rethrows -> Index? {
    try ___first_index { try predicate(___element($0)) }
  }
}

extension ___KeyValueSequence {

  @inlinable
  @inline(__always)
  func ___value_for(_ __k: _Key) -> _Value? {
    let __ptr = __tree_.find(__k)
    return ___is_null_or_end(__ptr) ? nil : __tree_[__ptr]
  }
}

extension ___KeyValueSequence {

  @inlinable
  @inline(__always)
  func _makeIterator() -> Tree._KeyValues {
    .init(tree: __tree_, start: _start, end: _end)
  }

  @inlinable
  @inline(__always)
  func _reversed() -> Tree._KeyValues.Reversed {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension ___KeyValueSequence {

  @inlinable
  @inline(__always)
  func _forEach(_ body: (Element) throws -> Void) rethrows {
    try __tree_.___for_each_(__p: _start, __l: _end) {
      try body(Self.___element(__tree_[$0]))
    }
  }
}

extension ___KeyValueSequence {

  @inlinable
  @inline(__always)
  func _forEach(_ body: (Index, Element) throws -> Void) rethrows {
    try __tree_.___for_each_(__p: _start, __l: _end) {
      try body(___index($0), Self.___element(__tree_[$0]))
    }
  }
}

extension ___KeyValueSequence {

  @inlinable
  @inline(__always)
  public func ___forEach(_ body: (_NodePtr, Element) throws -> Void) rethrows {
    try __tree_.___for_each_(__p: _start, __l: _end) {
      try body($0, Self.___element(__tree_[$0]))
    }
  }
}

extension ___KeyValueSequence {

  /// - Complexity: O(*n*)
  @inlinable
  @inline(__always)
  func _sorted() -> [Element] {
    __tree_.___copy_to_array(_start, _end, transform: Self.___element)
  }
}
