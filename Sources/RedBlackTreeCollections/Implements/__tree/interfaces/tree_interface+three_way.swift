//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project.
//
// Copyright (c) 2024-2026 narumij.
// Licensed under the Apache License v2.0.
//
// SPDX-License-Identifier: Apache-2.0
//
// This implementation includes code derived from LLVM libc++'s red-black tree
// implementation, originally distributed under the Apache License v2.0 with
// LLVM Exceptions.
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by
// narumij.
//
//===----------------------------------------------------------------------===//

// 三方比較結果
//
// <=>演算子に対応するものらしい
//
// <=>はspaceship operatorというらしい
@usableFromInline
package
  protocol ThreeWayCompareResult
{
  @inlinable func __less() -> Bool
  @inlinable func __greater() -> Bool
}

// 三方比較結果型の定義
@usableFromInline
package protocol _ThreeWayResultType: ~Copyable {
  // 三方比較結果型
  associatedtype __compare_result: ThreeWayCompareResult
}

// MARK: -

@usableFromInline
package
  protocol _TreeKey_LazyThreeWayCompInterface: ~Copyable, _KeyType & _ThreeWayResultType
{
  @inlinable
  borrowing func __lazy_synth_three_way_comparator(_ __lhs: borrowing _Key, _ __rhs: borrowing _Key)
    -> __compare_result
}

@usableFromInline
package
  protocol _TreeKey_ThreeWayCompInterface: ~Copyable, _KeyType & _ThreeWayResultType
{
  @inlinable borrowing func __comp(_ __lhs: borrowing _Key, _ __rhs: borrowing _Key) -> __compare_result
}
