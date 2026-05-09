//
//  unsafe_node+pointer+base.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/09.
//

public protocol _Base_Pointer: _UnsafeNodePtrType, _KeyType, _PayloadValueType {
  static func __key_ptr(_ :UnsafeMutablePointer<UnsafeNode>) -> UnsafeMutablePointer<_Key>
  static func __payload_ptr(_ :UnsafeMutablePointer<UnsafeNode>) -> UnsafeMutablePointer<_PayloadValue>
}

extension _Base_Pointer {
  static func __payload_ptr(_ p: _NodePtr) -> UnsafeMutablePointer<_Key> {
    p.__value_()
  }
}

extension _Base_Pointer where Self: _ScalarBaseType {

  /// `_PayloadValue`と`_Key`が一致する場合に、 ペイロードをキーとみなしたポインタ
  ///
  /// ```
  /// ...|Node|Key|Node...
  ///    |    ^--__key_ptr
  ///    ^self
  /// ```

  static func __key_ptr(_ p: _NodePtr) -> _KeyPtr {
    p.__value_()
  }
}

extension _Base_Pointer where Self: _PairBaseType {

  static func __key_ptr(_ p: _NodePtr) -> _KeyPtr {
    p.__value_()
  }
  
  static func __mapped_value_ptr(_ p: _NodePtr) -> _MappedValuePtr {
    _ref(to: &__payload_ptr(p).pointee.value)
  }
}
