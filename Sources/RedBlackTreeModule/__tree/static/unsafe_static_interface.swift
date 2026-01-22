//
//  tree_static_interface.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/22.
//

public protocol _KeyStaticInterface: _KeyType & _ValueType {
  static func __key(_: _Value) -> _Key
}

public protocol ValueCompStaticInterface: _KeyType {
  static func value_comp(_: _Key, _: _Key) -> Bool
}

public protocol TreeValueStaticInterface: _NodePtrType & _ValueType {
  static func __value_(_ p: _NodePtr) -> _Value
}

public protocol TreeNodeValueStaticInterface: _KeyType & _KeyStaticInterface
    & TreeValueStaticInterface
{
  associatedtype _NodePtr
  static func __get_value(_: _NodePtr) -> _Key
}

extension TreeNodeValueStaticInterface {

  public static func __get_value(_ p: _NodePtr) -> _Key {
    __key(__value_(p))
  }
}

public protocol IsMultiTraitStaticInterface {
  static var isMulti: Bool { get }
}

public protocol CompareUniqueStaticInterface: _UnsafeNodePtrType {
  static func ___ptr_comp_unique(_ l: _NodePtr, _ r: _NodePtr) -> Bool
}

public protocol PointerCompareStaticProtocol:
  TreeNodeValueStaticInterface
    & ValueCompStaticInterface
    & CompareStaticProtocol
{}

extension PointerCompareStaticProtocol {

  public static func ___ptr_comp_unique(_ l: _NodePtr, _ r: _NodePtr) -> Bool {
    assert(!l.___is_null, "Node shouldn't be null")
    assert(!l.___is_end, "Node shouldn't be end")
    assert(!r.___is_null, "Node shouldn't be null")
    assert(!r.___is_end, "Node shouldn't be end")
    return value_comp(__get_value(l), __get_value(r))
  }
}
