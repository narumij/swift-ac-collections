// Copyright 2024 narumij
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

import Foundation

public
  protocol ThreeWayCompareResult
{
  @inlinable func __less() -> Bool
  @inlinable func __greater() -> Bool
}

public
  protocol ThreeWayComparator
{
  associatedtype __compare_result: ThreeWayCompareResult
  associatedtype _Key
  @inlinable static func ___three_way_compare(_ __l: _Key, _ __r: _Key) -> __compare_result
}

@usableFromInline
protocol ThreeWayComparatorProtocol {
  associatedtype __compare_result: ThreeWayCompareResult
  associatedtype _Key
  @inlinable func __lazy_synth_three_way_comparator() -> (_Key, _Key) -> __compare_result
  @inlinable func __comp(_ __l: _Key, _ __r: _Key) -> __compare_result
}

public
  struct __lazy_three_way_compare_result: ThreeWayCompareResult
{
  @usableFromInline var compare: Int
  @inlinable
  @inline(__always)
  internal init(compare: Int) {
    self.compare = compare
  }
  @inlinable
  @inline(__always)
  internal init<_Key: Comparable>(lhs: _Key, rhs: _Key) {
    compare =
      if lhs < rhs {
        -1
      } else if lhs > rhs {
        1
      } else {
        0
      }
  }
  @inlinable
  @inline(__always)
  public func __less() -> Bool { compare < 0 }
  @inlinable
  @inline(__always)
  public func __greater() -> Bool { compare > 0 }
}

public protocol DefaultThreeWayComparator: ThreeWayComparator {}

extension DefaultThreeWayComparator where _Key: Comparable {

  @inlinable
  @inline(__always)
  public static func
  ___three_way_compare(_ __l: _Key, _ __r: _Key) -> __lazy_three_way_compare_result
  {
    __lazy_three_way_compare_result(lhs: __l, rhs: __r)
  }
}
