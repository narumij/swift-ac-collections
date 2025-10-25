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
