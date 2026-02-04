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
protocol ___UnsafeKeyOnlySequenceV2__: UnsafeTreeSealedRangeBaseInterface, _ScalarBase_ElementProtocol,
  _PayloadValueBride, _KeyBride
where
  Base: ___TreeIndex
{}

extension ___UnsafeKeyOnlySequenceV2__ {

  @inlinable
  @inline(__always)
  internal func _makeIterator() -> Tree._PayloadValues {
    .init(start: _sealed_start, end: _sealed_end, tie: __tree_.tied)
  }

  @inlinable
  @inline(__always)
  internal func _reversed() -> Tree._PayloadValues.Reversed {
    .init(start: _sealed_start, end: _sealed_end, tie: __tree_.tied)
  }
}

extension ___UnsafeKeyOnlySequenceV2__ {

  @inlinable
  @inline(__always)
  internal func _forEach(_ body: (_PayloadValue) throws -> Void) rethrows {
    try __tree_.___for_each_(__p: _sealed_start.pointer!, __l: _sealed_end.pointer!) {
      try body(__tree_[$0])
    }
  }
}

extension ___UnsafeKeyOnlySequenceV2__ {

  /// - Complexity: O(*n*)
  @inlinable
  @inline(__always)
  internal func _sorted() -> [_PayloadValue] {
    __tree_.___copy_to_array(_sealed_start.pointer!, _sealed_end.pointer!)
  }
}

extension ___UnsafeKeyOnlySequenceV2__ {

  @inlinable
  public func ___subscript(_ rawRange: UnsafeTreeSealedRangeExpression)
    -> RedBlackTreeSliceV2<Base>.KeyOnly
  {
    let (lower, upper) = unwrapLowerUpperOrFatal(rawRange.relative(to: __tree_))
    guard __tree_.isValidRawRange(lower: lower, upper: upper) else {
      fatalError(.invalidIndex)
    }
    return .init(tree: __tree_, start: lower, end: upper)
  }

  @inlinable
  public func ___unchecked_subscript(_ rawRange: UnsafeTreeSealedRangeExpression)
    -> RedBlackTreeSliceV2<Base>.KeyOnly
  {
    let (lower, upper) = unwrapLowerUpperOrFatal(rawRange.relative(to: __tree_))
    return .init(tree: __tree_, start: lower, end: upper)
  }
  
  @inlinable
  public func ___subscript(_ rawRange: UnsafeTreeSealedRangeExpression)
    -> RedBlackTreeKeyOnlyRangeView<Base>
  {
    let (lower, upper) = unwrapLowerUpperOrFatal(rawRange.relative(to: __tree_))
    guard __tree_.isValidRawRange(lower: lower.checked, upper: upper.checked) else {
      fatalError(.invalidIndex)
    }
    return .init(__tree_: __tree_, _start: lower, _end: upper)
  }

  @inlinable
  public func ___unchecked_subscript(_ rawRange: UnsafeTreeSealedRangeExpression)
  -> RedBlackTreeKeyOnlyRangeView<Base>
  {
    let (lower, upper) = unwrapLowerUpperOrFatal(rawRange.relative(to: __tree_))
    return .init(__tree_: __tree_, _start: lower, _end: upper)
  }
}

extension ___UnsafeKeyOnlySequenceV2__ {

  // めんどくさくなったので、KeyValue側では標準実装を使っている
  @inlinable
  @inline(__always)
  internal func _elementsEqual<OtherSequence>(
    _ other: OtherSequence, by areEquivalent: (_PayloadValue, OtherSequence.Element) throws -> Bool
  ) rethrows -> Bool where OtherSequence: Sequence {
    try __tree_.elementsEqual(_sealed_start.pointer!, _sealed_end.pointer!, other, by: areEquivalent)
  }

  // 制約で値の型が一致する必要があり、KeyValue側では標準実装を使っている
  @inlinable
  @inline(__always)
  internal func _lexicographicallyPrecedes<OtherSequence>(
    _ other: OtherSequence, by areInIncreasingOrder: (_PayloadValue, _PayloadValue) throws -> Bool
  ) rethrows -> Bool where OtherSequence: Sequence, _PayloadValue == OtherSequence.Element {
    try __tree_.lexicographicallyPrecedes(_sealed_start.pointer!, _sealed_end.pointer!, other, by: areInIncreasingOrder)
  }
}

@usableFromInline
protocol ___UnsafeKeyOnlySequenceV2: ___UnsafeKeyOnlySequenceV2__, ___UnsafeIndexBaseV2 {}

#if COMPATIBLE_ATCODER_2025
  extension ___UnsafeKeyOnlySequenceV2 {

    @available(*, deprecated, message: "性能問題があり廃止")
    @inlinable
    @inline(__always)
    internal func _forEach(_ body: (Index, _PayloadValue) throws -> Void) rethrows {
      try __tree_.___for_each_(__p: _sealed_start.pointer!, __l: _sealed_end.pointer!) {
        try body(___index($0), __tree_[$0])
      }
    }
  }
#endif

extension ___UnsafeKeyOnlySequenceV2 {

  @inlinable
  internal subscript(_checked position: Index) -> _PayloadValue {
    @inline(__always) _read {
      yield __tree_[try! __tree_._remap_to_safe_(position).get().pointer]
    }
  }
}
