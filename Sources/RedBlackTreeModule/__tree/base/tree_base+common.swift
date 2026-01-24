//
//  tree_base+common.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/24.
//

public protocol _BaseNode_KeyProtocol: _BaseNode_KeyInterface & _BaseRawValue_KeyInterface
    & _BaseNode_RawValueInterface
{
  static func __get_value(_: _NodePtr) -> _Key
}

extension _BaseNode_KeyProtocol {

  public static func __get_value(_ p: _NodePtr) -> _Key {
    __key(__value_(p))
  }
}

public protocol _BaseNode_UniqueCompProtocol:
  CompareStaticProtocol
    & _BaseNode_KeyProtocol
    & _BaseKey_LessThanInterface
{}

extension _BaseNode_UniqueCompProtocol {

  public static func ___ptr_comp_unique(_ l: _NodePtr, _ r: _NodePtr) -> Bool {
    assert(!l.___is_null, "Node shouldn't be null")
    assert(!l.___is_end, "Node shouldn't be end")
    assert(!r.___is_null, "Node shouldn't be null")
    assert(!r.___is_end, "Node shouldn't be end")
    return value_comp(__get_value(l), __get_value(r))
  }
}
