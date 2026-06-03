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

/// 資料的に残されている
///
/// 実際には特殊化されたものをつかっている
public protocol _BaseNode_KeyProtocol:
  _BaseNode_KeyInterface
    & _BasePayloadValue_KeyInterface
    & _BaseNode_PayloadValueInterface
{
  static func __get_value(_: _NodePtr) -> _Key
}

extension _BaseNode_KeyProtocol {

  /// 資料的に残されている
  ///
  /// 実際には特殊化されたものをつかっている
  ///
  /// `__key(_:)`が定義されてる場合に`__get_value(_:)`を定義する
  @inlinable
  public static func __get_value(_ p: _NodePtr) -> _Key {
    __key(__value_(p))
  }
}

public protocol _BaseComparableKey_LessThanProtocol: _BaseKey_LessThanInterface
where _Key: Comparable {}

extension _BaseComparableKey_LessThanProtocol {
  /// Comparableプロトコルの場合の標準実装
  @inlinable
  public static func value_comp(_ a: _Key, _ b: _Key) -> Bool {
    a < b
  }
}
