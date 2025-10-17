//
//  tree+tree_way_comparator.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/10/15.
//

import Foundation

public
protocol ThreeWayCompareResult {
  func __less() -> Bool
  func __greater() -> Bool
}

public
protocol ThreeWayComparator {
  associatedtype __compare_result: ThreeWayCompareResult
  associatedtype _Key
  static func __lazy_synth_three_way_comparator() -> (_Key,_Key) -> __compare_result
}

@usableFromInline
protocol ThreeWayComparatorProtocol {
  associatedtype __compare_result: ThreeWayCompareResult
  associatedtype _Key
  func __lazy_synth_three_way_comparator() -> (_Key,_Key) -> __compare_result
}

// High Frequency Samplingでの計測で、これが一番速かった
public
struct __lazy_three_way_compare_result<_Key>: ThreeWayCompareResult
where _Key: Comparable {
  @inlinable
  @inline(__always)
  internal init(lhs: _Key, rhs: _Key) {
    self.lhs = lhs
    self.rhs = rhs
  }
  @usableFromInline let lhs, rhs: _Key
  @inlinable
  @inline(__always)
  public func __less() -> Bool { lhs < rhs }
  @inlinable
  @inline(__always)
  public func __greater() -> Bool { lhs > rhs }
}

// MARK: -

#if false
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
where T: BinaryInteger {
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
struct __lazy_three_way_compare_result__<VC>: ThreeWayCompareResult
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
  @inline(__always)
  internal init(result: any ThreeWayCompareResult) {
    self.result = result
  }
  @usableFromInline let result: any ThreeWayCompareResult
  @inlinable
  @inline(__always)
  public func less() -> Bool { result.less() }
  @inlinable
  @inline(__always)
  public func greater() -> Bool { result.greater() }
}
#endif
