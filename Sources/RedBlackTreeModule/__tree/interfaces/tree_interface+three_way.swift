//
//  tree_interface+three_way.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/24.
//

/// 三方比較結果
///
/// <=>演算子に対応するものらしい
public
  protocol ThreeWayCompareResult
{
  @inlinable func __less() -> Bool
  @inlinable func __greater() -> Bool
}

/// 三方比較結果型の定義
@usableFromInline
 package protocol _ThreeWayResultType
{
  /// 三方比較結果型
  associatedtype __compare_result: ThreeWayCompareResult
}

// MARK: -

@usableFromInline package
protocol _TreeKey_LazyThreeWayCompInterface: _KeyType & _ThreeWayResultType {
  @inlinable
  func __lazy_synth_three_way_comparator(_ __lhs: _Key, _ __rhs: _Key)
    -> __compare_result
}

@usableFromInline package
protocol _TreeKey_ThreeWayCompInterface: _KeyType & _ThreeWayResultType {
  func __comp(_ __lhs: _Key, _ __rhs: _Key) -> __compare_result
}
