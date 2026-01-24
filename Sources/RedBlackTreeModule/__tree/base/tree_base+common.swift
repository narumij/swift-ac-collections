//
//  tree_base+common.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/24.
//

/// `__key(_:)`が定義されてる場合に`__get_value(_:)`を定義する
public protocol _BaseNode_KeyProtocol:
  _BaseNode_KeyInterface
    & _BaseRawValue_KeyInterface
    & _BaseNode_RawValueInterface
{
  static func __get_value(_: _NodePtr) -> _Key
}

extension _BaseNode_KeyProtocol {

  public static func __get_value(_ p: _NodePtr) -> _Key {
    __key(__value_(p))
  }
}

public protocol _BaseNode_PtrUniqueCompProtocol:
  _BaseNode_KeyProtocol
    & _BaseKey_LessThanInterface
    & _BaseNode_PtrUniqueCompInterface
{}

extension _BaseNode_PtrUniqueCompProtocol {

  public static func ___ptr_comp_unique(_ l: _NodePtr, _ r: _NodePtr) -> Bool {
    assert(!l.___is_null, "Node shouldn't be null")
    assert(!l.___is_end, "Node shouldn't be end")
    assert(!r.___is_null, "Node shouldn't be null")
    assert(!r.___is_end, "Node shouldn't be end")
    return value_comp(__get_value(l), __get_value(r))
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
