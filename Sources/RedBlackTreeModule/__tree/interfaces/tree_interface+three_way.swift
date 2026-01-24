//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project
//
// Copyright (c) 2024 - 2026 narumij.
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.
//
//===----------------------------------------------------------------------===//

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
