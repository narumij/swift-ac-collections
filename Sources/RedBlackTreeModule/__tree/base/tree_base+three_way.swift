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

public protocol _BaseKey_LazyThreeWayCompInterface:
  _KeyType
    & _ThreeWayResultType
{
  static func
    __lazy_synth_three_way_comparator(_ __lhs: _Key, _ __rhs: _Key)
    -> __compare_result
}

// TODO: プロトコルインジェクションを整理すること
// __treenの基本要素ではないので、別カテゴリがいい

public protocol LazySynthThreeWayComparator: _BaseKey_LazyThreeWayCompInterface
where Self: ValueComparer {}

extension LazySynthThreeWayComparator {

  @inlinable
  @inline(__always)
  public static func
    __lazy_synth_three_way_comparator(_ __lhs: _Key, _ __rhs: _Key)
    -> __lazy_compare_result<Self>
  {
    __lazy_compare_result(__lhs, __rhs)
  }
}

public protocol ComparableThreeWayComparator: _BaseKey_LazyThreeWayCompInterface
where _Key: Comparable {}

extension ComparableThreeWayComparator {

  @inlinable
  @inline(__always)
  public static func
    __lazy_synth_three_way_comparator(_ __lhs: _Key, _ __rhs: _Key)
    -> __comparable_compare_result<
      _Key
    >
  {
    __comparable_compare_result(__lhs, __rhs)
  }
}

public protocol HasDefaultThreeWayComparator: _BaseKey_LazyThreeWayCompInterface
where _Key: Comparable, __compare_result == __int_compare_result {}

extension HasDefaultThreeWayComparator {

  @inlinable
  @inline(__always)
  public static func
    __lazy_synth_three_way_comparator(_ __lhs: _Key, _ __rhs: _Key)
    -> __int_compare_result
  {
    __default_three_way_comparator(__lhs, __rhs)
  }
}
