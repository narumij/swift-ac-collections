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
  @inlinable static func __lazy_synth_three_way_comparator(_ __l: _Key, _ __r: _Key) -> __compare_result
}

@usableFromInline
protocol ThreeWayComparatorProtocol {
  associatedtype __compare_result: ThreeWayCompareResult
  associatedtype _Key
  @inlinable func __lazy_synth_three_way_comparator(_ __l: _Key, _ __r: _Key) -> __compare_result
//  @inlinable func __comp(_ __l: _Key, _ __r: _Key) -> __compare_result
}

@inlinable
@inline(__always)
func __default_three_way_comparator<T: Comparable>(_ __lhs:T,_ __rhs: T) -> Int {
  if __lhs < __rhs {
    -1
  } else if __lhs > __rhs {
    1
  } else {
    0
  }
}

// 特殊なキーを使いたい場合に使える
public
struct __lazy_compare_result<Base: ValueComparer>: ThreeWayCompareResult
{
  public typealias LHS = Base._Key
  public typealias RHS = Base._Key
  public var __lhs_: LHS
  public var __rhs_: RHS
  @inlinable
  @inline(__always)
  public init(_ __lhs_: LHS,_ __rhs_: RHS) {
    self.__lhs_ = __lhs_
    self.__rhs_ = __rhs_
  }
  @inlinable
  @inline(__always)
  public func __comp_(_ __lhs_: LHS,_ __rhs_: RHS) -> Bool {
    Base.value_comp(__lhs_, __rhs_)
  }
  @inlinable
  @inline(__always)
  public func __less() -> Bool { __comp_(__lhs_, __rhs_) }
  @inlinable
  @inline(__always)
  public func __greater() -> Bool { __comp_(__rhs_, __lhs_) }
}

// L1に載るとこれが一番速い
public
struct __comparable_compare_result<T: Comparable>: ThreeWayCompareResult
{
  public var __lhs_,__rhs_: T
  @inlinable
  @inline(__always)
  public init(_ __lhs_: T,_ __rhs_: T) {
    self.__lhs_ = __lhs_
    self.__rhs_ = __rhs_
  }
  @inlinable
  @inline(__always)
  public func __less() -> Bool { __lhs_ < __rhs_ }
  @inlinable
  @inline(__always)
  public func __greater() -> Bool { __rhs_ > __lhs_ }
}

// 安定して速い
public
  struct __eager_compare_result: ThreeWayCompareResult
{
  public var __res_: Int
  @inlinable
  @inline(__always)
  public init(_ __res_: Int) {
    self.__res_ = __res_
  }
  @inlinable
  @inline(__always)
  public func __less() -> Bool { __res_ < 0 }
  @inlinable
  @inline(__always)
  public func __greater() -> Bool { __res_ > 0 }
}

public protocol LazySynthThreeWayComparator: ThreeWayComparator {}

extension LazySynthThreeWayComparator where Self: ValueComparer {

  @inlinable
  public static func
  __lazy_synth_three_way_comparator(_ __l: _Key, _ __r: _Key) -> __lazy_compare_result<Self>
  {
    __lazy_compare_result(__l, __r)
  }
}

public protocol ComparableThreeWayComparator: ThreeWayComparator {}

extension ComparableThreeWayComparator where _Key: Comparable {

  @inlinable
  public static func
  __lazy_synth_three_way_comparator(_ __l: _Key, _ __r: _Key) -> __comparable_compare_result<_Key>
  {
    __comparable_compare_result(__l, __r)
  }
}

public protocol HasDefaultThreeWayComparator: ThreeWayComparator {}

extension HasDefaultThreeWayComparator where _Key: Comparable {

  @inlinable
  public static func
  __lazy_synth_three_way_comparator(_ __l: _Key, _ __r: _Key) -> __eager_compare_result
  {
    __eager_compare_result(__default_three_way_comparator(__l, __r))
  }
}
