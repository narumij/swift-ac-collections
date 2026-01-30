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
protocol ___UnsafeSubSequenceV2: UnsafeTreeRangeProtocol, UnsafeIndexBinding {}

extension ___UnsafeSubSequenceV2 {

  /// - Complexity: O(log *n* + *k*)
  @inlinable
  @inline(__always)
  internal var ___count: Int {
    __tree_.__distance(_start, _end)
  }

  @inlinable
  @inline(__always)
  internal func ___contains(_ i: _NodePtr) -> Bool {
    !__tree_.___is_subscript_null(i) && __tree_.___ptr_closed_range_contains(_start, _end, i)
  }

#if COMPATIBLE_ATCODER_2025
  @inlinable
  @inline(__always)
  internal func ___contains(_ bounds: Range<Index>) -> Bool {
    !__tree_.___is_offset_null(__tree_._remap_to_ptr(bounds.lowerBound))
      && !__tree_.___is_offset_null(__tree_._remap_to_ptr(bounds.upperBound))
      && __tree_.___ptr_range_contains(_start, _end, __tree_._remap_to_ptr(bounds.lowerBound))
      && __tree_.___ptr_range_contains(_start, _end, __tree_._remap_to_ptr(bounds.upperBound))
  }
  #endif
}
