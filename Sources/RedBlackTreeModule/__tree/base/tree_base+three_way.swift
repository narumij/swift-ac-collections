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
// Copyright © 2003-2025 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

import Foundation

// 三方比較関連は各現場で決定する方針に変わった。コレクション側では決定しない

@usableFromInline
package
  protocol LazySynthThreeWayComparator: _TreeKey_LazyThreeWayCompInterface
where
  Self: _BaseKey_LessThanInterface, __compare_result == __lazy_compare_result<Self>
{}

extension LazySynthThreeWayComparator {

  @inlinable
  @inline(__always)
  public func
    __lazy_synth_three_way_comparator(_ __lhs: _Key, _ __rhs: _Key)
    -> __lazy_compare_result<Self>
  {
    __lazy_compare_result(__lhs, __rhs)
  }
}

@usableFromInline
package
  protocol ComparableThreeWayComparator: _TreeKey_LazyThreeWayCompInterface
where _Key: Comparable, __compare_result == __comparable_compare_result<_Key> {}

extension ComparableThreeWayComparator {

  @inlinable
  @inline(__always)
  public func
    __lazy_synth_three_way_comparator(_ __lhs: _Key, _ __rhs: _Key)
    -> __comparable_compare_result<
      _Key
    >
  {
    __comparable_compare_result(__lhs, __rhs)
  }
}

@usableFromInline
package
  protocol IntThreeWayComparator: _TreeKey_LazyThreeWayCompInterface
where _Key: Comparable, __compare_result == __int_compare_result {}

extension IntThreeWayComparator {

  @inlinable
  @inline(__always)
  public func
    __lazy_synth_three_way_comparator(_ __lhs: _Key, _ __rhs: _Key)
    -> __int_compare_result
  {
    __default_three_way_comparator(__lhs, __rhs)
  }
}
