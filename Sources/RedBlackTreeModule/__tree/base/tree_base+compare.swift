//
//  tree_static_interface.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/22.
//

public protocol _BaseNode_UniqueCompProtocol:
  CompareStaticProtocol
    & _BaseNode_KeyProtocol
    & _BaseKey_CompInterface
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
