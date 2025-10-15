//
//  tree+tree_way_comparator.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/10/15.
//

import Foundation

public
protocol ThreeWayCompareResult {
  func less() -> Bool
  func greater() -> Bool
}

public
protocol ThreeWayComparator {
  associatedtype __compare_result: ThreeWayCompareResult
  associatedtype _Key
  static func __comp(_ lhs:_Key,_ rhs: _Key) -> __compare_result
}

@usableFromInline
protocol ThreeWayComparatorProtocol {
  associatedtype __compare_result: ThreeWayCompareResult
  associatedtype _Key
  func __comp(_ lhs:_Key,_ rhs: _Key) -> __compare_result
}

@usableFromInline
struct __default_three_way_compare_result: ThreeWayCompareResult {
  @inlinable
  @inline(__always)
  internal init(comp: Int) {
    self.comp = comp
  }
  @usableFromInline
  var comp: Int
  @inlinable
  @inline(__always)
  func less() -> Bool { comp < 0 }
  @inlinable
  @inline(__always)
  func greater() -> Bool { 0 < comp }
}

public
struct __default_three_way_compare_result_<T>: ThreeWayCompareResult
where T: Numeric & AdditiveArithmetic, T: Comparable {
  @inlinable
  @inline(__always)
  internal init(comp: T) {
    self.comp = comp
  }
  @usableFromInline
  var comp: T
  @inlinable
  @inline(__always)
  public func less() -> Bool { comp < 0 }
  @inlinable
  @inline(__always)
  public func greater() -> Bool { 0 < comp }
}

public
struct __lazy_three_way_compare_result<VC>: ThreeWayCompareResult
where VC: ValueComparer {
  @inlinable
  internal init(lhs: VC._Key, rhs: VC._Key) {
    self.lhs = lhs
    self.rhs = rhs
  }
  @usableFromInline let lhs, rhs: VC._Key
  @inlinable
  @inline(__always)
  public func less() -> Bool { VC.value_comp(lhs, rhs) }
  @inlinable
  @inline(__always)
  public func greater() -> Bool { VC.value_comp(rhs, lhs) }
}

public
struct AnyThreeWayCompareResult: ThreeWayCompareResult {
  @inlinable
  internal init(result: ThreeWayCompareResult) {
    self.result = result
  }
  @usableFromInline let result: ThreeWayCompareResult
  @inlinable
  @inline(__always)
  public func less() -> Bool { result.less() }
  @inlinable
  @inline(__always)
  public func greater() -> Bool { result.greater() }
}
