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
protocol ___UnsafeKeyOnlySequenceV2: ___UnsafeBaseV2, ___TreeIndex, _ScalarBaseType
where _Payload == Element, Element: Comparable {}

extension ___UnsafeKeyOnlySequenceV2 {

  @inlinable
  @inline(__always)
  public static func ___pointee(_ __value: _Payload) -> Element { __value }
}

extension ___UnsafeKeyOnlySequenceV2 {

  @inlinable
  @inline(__always)
  internal func _makeIterator() -> Tree._RawValues {
    .init(start: _start, end: _end, tie: __tree_.tied)
  }

  @inlinable
  @inline(__always)
  internal func _reversed() -> Tree._RawValues.Reversed {
    .init(start: _start, end: _end, tie: __tree_.tied)
  }
}

extension ___UnsafeKeyOnlySequenceV2 {

  @inlinable
  @inline(__always)
  internal func _forEach(_ body: (_Payload) throws -> Void) rethrows {
    try __tree_.___for_each_(__p: _start, __l: _end) {
      try body(__tree_[$0])
    }
  }
}

#if COMPATIBLE_ATCODER_2025
  extension ___UnsafeKeyOnlySequenceV2 {

    @available(*, deprecated, message: "性能問題があり廃止")
    @inlinable
    @inline(__always)
    internal func _forEach(_ body: (Index, _RawValue) throws -> Void) rethrows {
      try __tree_.___for_each_(__p: _start, __l: _end) {
        try body(___index($0), __tree_[$0])
      }
    }
  }
#endif

extension ___UnsafeKeyOnlySequenceV2 {

  /// - Complexity: O(*n*)
  @inlinable
  @inline(__always)
  internal func _sorted() -> [_Payload] {
    __tree_.___copy_to_array(_start, _end)
  }
}

extension ___UnsafeKeyOnlySequenceV2 {

  @inlinable
  internal subscript(_checked position: Index) -> _Payload {
    @inline(__always) _read {
      __tree_.___ensureValid(subscript: __tree_.rawValue(position))
      yield __tree_[__tree_.rawValue(position)]
    }
  }

  @inlinable
  internal subscript(_unchecked position: Index) -> _Payload {
    @inline(__always) _read {
      yield __tree_[__tree_.rawValue(position)]
    }
  }
}

extension ___UnsafeKeyOnlySequenceV2 {

  @inlinable
  public func ___subscript(_ rawRange: UnsafeTreeRangeExpression)
    -> RedBlackTreeSliceV2<Base>.KeyOnly
  {
    let (lower, upper) = rawRange.relative(to: __tree_)
    __tree_.___ensureValid(begin: lower, end: upper)
    guard __tree_.isValidRawRange(lower: lower, upper: upper) else {
      fatalError(.invalidIndex)
    }
    return .init(tree: __tree_, start: lower, end: upper)
  }

  @inlinable
  public func ___unchecked_subscript(_ rawRange: UnsafeTreeRangeExpression)
    -> RedBlackTreeSliceV2<Base>.KeyOnly
  {
    let (lower, upper) = rawRange.relative(to: __tree_)
    return .init(tree: __tree_, start: lower, end: upper)
  }
}

extension ___UnsafeKeyOnlySequenceV2 {

  // めんどくさくなったので、KeyValue側では標準実装を使っている
  @inlinable
  @inline(__always)
  internal func _elementsEqual<OtherSequence>(
    _ other: OtherSequence, by areEquivalent: (_Payload, OtherSequence.Element) throws -> Bool
  ) rethrows -> Bool where OtherSequence: Sequence {
    try __tree_.elementsEqual(_start, _end, other, by: areEquivalent)
  }

  // 制約で値の型が一致する必要があり、KeyValue側では標準実装を使っている
  @inlinable
  @inline(__always)
  internal func _lexicographicallyPrecedes<OtherSequence>(
    _ other: OtherSequence, by areInIncreasingOrder: (_Payload, _Payload) throws -> Bool
  ) rethrows -> Bool where OtherSequence: Sequence, _Payload == OtherSequence.Element {
    try __tree_.lexicographicallyPrecedes(_start, _end, other, by: areInIncreasingOrder)
  }
}

extension ___UnsafeKeyOnlySequenceV2 {

  @inlinable
  @inline(__always)
  public mutating func ___element(at ptr: _NodePtr) -> _Payload? {
    guard !__tree_.___is_subscript_null(ptr) else {
      return nil
    }
    return __tree_[ptr]
  }
}
