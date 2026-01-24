//
//  tree_base+common.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/24.
//

public protocol _BaseNode_KeyProtocol: _BaseNode_KeyInterface & _BaseValue_KeyInterface
    & _BaseNode_ValueInterface
{
  static func __get_value(_: _NodePtr) -> _Key
}

extension _BaseNode_KeyProtocol {

  public static func __get_value(_ p: _NodePtr) -> _Key {
    __key(__value_(p))
  }
}
