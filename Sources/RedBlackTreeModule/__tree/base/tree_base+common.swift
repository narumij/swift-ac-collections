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

/// Index用のメソッド中継
///
/// `__key(_:)`が定義されてる場合に`__get_value(_:)`を定義する
public protocol _BaseNode_KeyProtocol:
  _BaseNode_KeyInterface
    & _BaseRawValue_KeyInterface
    & _BaseNode_PayloadValueInterface
{
  static func __get_value(_: _NodePtr) -> _Key
}

extension _BaseNode_KeyProtocol {

  public static func __get_value(_ p: _NodePtr) -> _Key {
    __key(__value_(p))
  }
}

public protocol _BaseKey_LessThanProtocol: _BaseKey_LessThanInterface {}

extension _BaseKey_LessThanProtocol where _Key: Comparable {
  /// Comparableプロトコルの場合の標準実装
  @inlinable
  @inline(__always)
  public static func value_comp(_ a: _Key, _ b: _Key) -> Bool {
    a < b
  }
}

public protocol _BaseKey_EquivProtocol: _BaseKey_EquivInterface & _BaseKey_LessThanInterface {}

extension _BaseKey_EquivProtocol {

  @inlinable
  @inline(__always)
  public static func value_equiv(_ lhs: _Key, _ rhs: _Key) -> Bool {
    !value_comp(lhs, rhs) && !value_comp(rhs, lhs)
  }
}

// Equatableプロトコルの場合標準実装を付与する
extension _BaseKey_EquivProtocol where _Key: Equatable {

  @inlinable
  @inline(__always)
  public static func value_equiv(_ lhs: _Key, _ rhs: _Key) -> Bool {
    lhs == rhs
  }
}
