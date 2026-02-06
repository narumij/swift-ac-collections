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
protocol _SubSequenceV2: UnsafeTreeSealedRangeProtocol, UnsafeIndexBinding {}

extension _SubSequenceV2 {

  /// - Complexity: O(log *n* + *k*)
  ///
  /// 無効の場合0を返す
  /// 
  @inlinable
  @inline(__always)
  internal var ___count: Int {
    guard
      let start = _sealed_start.pointer,
      let end = _sealed_end.pointer
    else {
      return 0
    }
    return __tree_.__distance(start, end)
  }

  @inlinable
  @inline(__always)
  internal func ___contains(_ i: _NodePtr) -> Bool {
    guard
      let start = _sealed_start.pointer,
      let end = _sealed_end.pointer
    else {
      return false
    }
    return __tree_.___ptr_range_comp(start, i, end)
  }
}

#if COMPATIBLE_ATCODER_2025
  extension ___UnsafeSubSequenceV2 {
    @inlinable
    @inline(__always)
    internal func ___contains(_ bounds: Range<Index>) -> Bool {

      guard
        let start = _sealed_start.pointer,
        let end = _sealed_end.pointer
      else {
        return false
      }

      guard
        let l = __tree_.__sealed_(bounds.lowerBound).pointer,
        let u = __tree_.__sealed_(bounds.upperBound).pointer
      else {
        return false
      }

      return __tree_.___ptr_range_contains(start, end, l)
        && __tree_.___ptr_range_contains(start, end, u)
    }
  }
#endif
