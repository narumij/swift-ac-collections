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
protocol ___UnsafeCommonV2: ___UnsafeRangeBaseV2 {}

extension ___UnsafeCommonV2 {

  @inlinable
  @inline(__always)
  internal var ___is_empty: Bool {
    __tree_.___is_empty || _start == _end
  }

  @inlinable
  @inline(__always)
  internal var ___first: _PayloadValue? {
    ___is_empty ? nil : __tree_[_start]
  }

  @inlinable
  @inline(__always)
  internal var ___last: _PayloadValue? {
    ___is_empty ? nil : __tree_[__tree_.__tree_prev_iter(_end)]
  }
}

extension ___UnsafeCommonV2 {

  @inlinable
  @inline(__always)
  internal func ___is_valid(_ index: _NodePtr) -> Bool {
    !__tree_.___is_subscript_null(index)
  }

  @inlinable
  @inline(__always)
  internal func ___is_valid_range(_ p: _NodePtr, _ l: _NodePtr) -> Bool {
    !__tree_.___is_range_null(p, l)
  }
}

extension ___UnsafeCommonV2 {

  @inlinable
  @inline(__always)
  internal var ___key_comp: (_Key, _Key) -> Bool {
    __tree_.value_comp
  }

  @inlinable
  @inline(__always)
  internal var ___value_comp: (_PayloadValue, _PayloadValue) -> Bool {
    { __tree_.value_comp(Base.__key($0), Base.__key($1)) }
  }
}

extension ___UnsafeCommonV2 {

  @inlinable
  @inline(__always)
  internal func _isTriviallyIdentical(to other: Self) -> Bool {
    __tree_.isTriviallyIdentical(to: other.__tree_) && _start == other._start && _end == other._end
  }
}

extension ___UnsafeCommonV2 where Self: ___UnsafeIndexRangeBaseV2 {

  @inlinable
  @inline(__always)
  internal func _distance(from start: Index, to end: Index) -> Int {
    __tree_.___distance(
      from: __tree_._remap_to_ptr(start),
      to: __tree_._remap_to_ptr(end))
  }

  @inlinable
  @inline(__always)
  internal var _indices: Indices {
    .init(start: _start, end: _end, tie: __tree_.tied)
  }
}
