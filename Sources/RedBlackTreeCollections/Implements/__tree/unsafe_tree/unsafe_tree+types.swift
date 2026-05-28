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

/// ポインタベースの木の基本型定義
public protocol _UnsafeNodePtrType: ~Copyable, _NodePtrType
where
  _NodePtr == UnsafeMutablePointer<UnsafeNode>,
  _NodeRef == UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>
{}

// MARK: -
// 以下はヘルパー類

extension _KeyType where Self: _UnsafeNodePtrType {
  public typealias _KeyPtr = UnsafeMutablePointer<_Key>
}

extension _PayloadValueType where Self: _UnsafeNodePtrType {
  public typealias _PayloadPtr = UnsafeMutablePointer<_PayloadValue>
  public typealias _PayloadBuffer = UnsafeMutableBufferPointer<_PayloadValue>
}

extension _MappedValueType where Self: _UnsafeNodePtrType {
  public typealias _MappedValuePtr = UnsafeMutablePointer<_MappedValue>
}

extension _ElementType where Self: _UnsafeNodePtrType {
  public typealias _ElementValuePtr = UnsafeMutablePointer<Element>
}

extension _UnsafeNodePtrType where Self: _PayloadValueType {

  /// ペイロードのポインタ
  ///
  /// ```
  /// ...|Node|Payload|Node...
  ///    |    ^--__payload_
  ///    ^-- UnsafeMutablePointer<UnsafeNode>
  /// ```
  @inlinable
  static func __payload_ptr(_ p: _NodePtr) -> _PayloadPtr {
    p.__value_()
  }
  @inlinable
  static func __payload_ptr(_ p: _NodeRef) -> _PayloadPtr {
    p.pointee.__value_()
  }

  @inlinable
  static func __payload_(_ p: _NodePtr) -> _PayloadValue {
    p.__value_().pointee
  }
  @inlinable
  static func __payload_(_ p: _NodeRef) -> _PayloadValue {
    p.pointee.__value_().pointee
  }
  
  @inlinable
  static func __payload_buffer(_ p: _NodePtr) -> _PayloadBuffer {
    .init(start: __payload_ptr(p), count: 1)
  }
  @inlinable
  static func __payload_buffer(_ p: _NodeRef) -> _PayloadBuffer {
    .init(start: __payload_ptr(p), count: 1)
  }
}

extension _UnsafeNodePtrType where Self: _ScalarBaseType {

  /// `_PayloadValue`と`_Key`が一致する場合に、 ペイロードをキーとみなしたポインタ
  ///
  /// ```
  /// ...|Node|Key|Node...
  ///    |    ^--__key_ptr
  ///    ^-- UnsafeMutablePointer<UnsafeNode>
  /// ```
  @inlinable
  static func __key_ptr(_ p: _NodePtr) -> _KeyPtr {
    __payload_ptr(p)
  }
  @inlinable
  static func __key_ptr(_ p: _NodeRef) -> _KeyPtr {
    __payload_ptr(p)
  }

  @inlinable
  static func __key_(_ p: _NodePtr) -> _Key {
    __key_ptr(p).pointee
  }
  @inlinable
  static func __key_(_ p: _NodeRef) -> _Key {
    __key_ptr(p).pointee
  }
}

extension _UnsafeNodePtrType where Self: _PairBaseType {
  
  /// `_PayloadValue`が`Pair`の場合のキーへのポインタ
  ///
  /// ```
  /// ...|Node|Key|MappedValue|Node...
  ///    |    ^--__key_ptr
  ///    ^-- UnsafeMutablePointer<UnsafeNode>
  /// ```
  @inlinable
  static func __key_ptr(_ p: _NodePtr) -> _KeyPtr {
    _ref(to: &__payload_ptr(p).pointee.tuple.key)
  }
  @inlinable
  static func __key_ptr(_ p: _NodeRef) -> _KeyPtr {
    _ref(to: &__payload_ptr(p.pointee).pointee.tuple.key)
  }
  
  @inlinable
  static func __key_(_ p: _NodePtr) -> _Key {
    __payload_(p).tuple.key
  }
  @inlinable
  static func __key_(_ p: _NodeRef) -> _Key {
    __payload_(p).tuple.key
  }
  
  /// `_PayloadValue`が`Pair`の場合のバリューへのポインタ
  ///
  /// ```
  /// ...|Node|Key|MappedValue|Node...
  ///    |        ^--__mapped_value_ptr
  ///    ^-- UnsafeMutablePointer<UnsafeNode>
  /// ```
  @inlinable
  static func __mapped_value_ptr(_ p: _NodePtr) -> _MappedValuePtr {
    _ref(to: &__payload_ptr(p).pointee.tuple.value)
  }
  @inlinable
  static func __mapped_value_ptr(_ p: _NodeRef) -> _MappedValuePtr {
    _ref(to: &__payload_ptr(p.pointee).pointee.tuple.value)
  }
  
  @inlinable
  static func __mapped_value_(_ p: _NodePtr) -> _MappedValue {
    __payload_(p).tuple.value
  }
  @inlinable
  static func __mapped_value_(_ p: _NodeRef) -> _MappedValue {
    __payload_(p).tuple.value
  }
}

extension _UnsafeNodePtrType where Self: _PairBaseType & _KeyValueElementType {
  
  @inlinable
  static func __element__ptr(_ p: _NodePtr) -> _ElementValuePtr {
    _ref(to: &__payload_ptr(p).pointee.tuple)
  }
  
  @inlinable
  static func __element_(_ p: _NodePtr) -> Element {
    __payload_(p).tuple
  }
}
