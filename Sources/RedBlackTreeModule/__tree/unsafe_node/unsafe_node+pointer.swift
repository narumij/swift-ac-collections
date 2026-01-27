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

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
  public typealias _NodeRef = UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>

  @inlinable @inline(__always)
  static var nullptr: _NodePtr {
    UnsafeNode.nullptr
  }

  @inlinable
  var __left_: _NodePtr {
    _read { yield pointee.__left_ }
    _modify { yield &pointee.__left_ }
  }

  @inlinable
  var __right_: _NodePtr {
    _read { yield pointee.__right_ }
    _modify { yield &pointee.__right_ }
  }

  @inlinable
  var __parent_: _NodePtr {
    _read { yield pointee.__parent_ }
    _modify { yield &pointee.__parent_ }
  }

  @inlinable
  var __parent_unsafe: _NodePtr {
    _read { yield pointee.__parent_ }
    _modify { yield &pointee.__parent_ }
  }

  @inlinable
  var __set_parent: _NodePtr {
    _read { yield pointee.__parent_ }
    _modify { yield &pointee.__parent_ }
  }

  @inlinable
  var __is_black_: Bool {
    _read { yield pointee.__is_black_ }
    _modify { yield &pointee.__is_black_ }
  }

  @inlinable
  @inline(__always)
  var __left_ref: _NodeRef {
    _ref(to: &pointee.__left_)
  }

  @inlinable
  @inline(__always)
  var __right_ref: _NodeRef {
    _ref(to: &pointee.__right_)
  }
}

//extension UnsafeMutablePointer where Pointee == UnsafeNode {
//  @inlinable @inline(__always)
//  var isPayloadEmpty: Bool { pointee.isPayloadEmpty }
//}

extension UnsafeMutablePointer where Pointee == UnsafeNode {
  
  /// ゆっくりendを返す
  ///
  /// どのくらいゆっくりかというとO(log N)ぐらい
  ///
  /// ルートのペアレントまたはペアレントがヌルなのがend
  func __slow_end() -> _NodePtr {
    var __r = self
    while __r.__parent_ != .nullptr {
      __r = __r.__parent_
    }
    return __r
  }
  
  /// ゆっくりbeginを返す
  ///
  /// どのくらいゆっくりかというとO(log N)ぐらい
  ///
  /// ルートからたどれる最小値ノードがbegin
  func __slow_begin() -> _NodePtr {
    __tree_min(__slow_end().__left_)
  }
}

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  /// ペイロードの生ポインタ
  ///
  /// ```
  /// ...|Node|Payload|Node...
  ///    |    ^--__raw_value_
  ///    ^self
  /// ```
  // TODO: 名称変更
  // 型名の変更で意味が合わなくなっている
  @inlinable
  @inline(__always)
  var __payload_: UnsafeMutableRawPointer {
    UnsafeMutableRawPointer(advanced(by: 1))
  }

  /// ペイロードを値とみなしたポインタ
  ///
  /// ```
  /// ...|Node|RawValue|Node...
  ///    |    ^--__value_
  ///    ^self
  /// ```
  ///
  /// 型推論で型が決定する
  @inlinable
  @inline(__always)
  func __value_<_RawValue>() -> UnsafeMutablePointer<_RawValue> {
    UnsafeMutableRawPointer(advanced(by: 1))
      .assumingMemoryBound(to: _RawValue.self)
  }

  /// ペイロードを値とみなしたポインタ
  ///
  /// ```
  /// ...|Node|RawValue|Node...
  ///    |    ^--__value_
  ///    ^self
  /// ```
  ///
  /// 引数で型が決定する
  @inlinable
  @inline(__always)
  package func __value_<_RawValue>(as t: _RawValue.Type) -> UnsafeMutablePointer<_RawValue> {
    UnsafeMutableRawPointer(advanced(by: 1))
      .assumingMemoryBound(to: _RawValue.self)
  }

  /// `_RawValue`と`_Key`が一致する場合に、 ペイロードをキーとみなしたポインタ
  ///
  /// ```
  /// ...|Node|RawValue|Node...
  ///    |    ^--__key_ptr
  ///    ^self
  /// ```
  @inlinable
  @inline(__always)
  func __key_ptr<Base: _ScalarBaseType>(with t: Base.Type)
    -> UnsafeMutablePointer<Base._Key>
  {
    __value_()
  }

  /// `_RawValue`が`Pair`の場合のキーへのポインタ
  ///
  /// ```
  /// ...|Node|Key|MappedValue|Node...
  ///    |    ^--__key_ptr
  ///    ^self
  /// ```
  @inlinable
  @inline(__always)
  func __key_ptr<Base: _PairBaseType>(with t: Base.Type)
    -> UnsafeMutablePointer<Base._Key>
  {
    _ref(to: &__value_(as: Base._Payload.self).pointee.key)
  }

  /// `_RawValue`が`Pair`の場合のバリューへのポインタ
  ///
  /// ```
  /// ...|Node|Key|MappedValue|Node...
  ///    |        ^--__mapped_value_ptr
  ///    ^self
  /// ```
  @inlinable
  @inline(__always)
  func __mapped_value_ptr<Base: _PairBaseType>(with t: Base.Type)
    -> UnsafeMutablePointer<Base._MappedValue>
  {
    _ref(to: &__value_(as: Base._Payload.self).pointee.value)
  }
}

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  @inlinable
  @inline(__always)
  func _advanced(raw bytes: Int) -> UnsafeMutablePointer {
    UnsafeMutableRawPointer(self)
      .advanced(by: bytes)
      .assumingMemoryBound(to: UnsafeNode.self)
  }

  /// 単位移動量と移動量を指定して、他のノードを取得する
  ///
  /// ```
  /// ...|Node|stride|Node|stride|...
  ///    |           ^self       |
  ///    ^--_advanced -1         ^--_advanced +1
  /// ```
  @inlinable
  @inline(__always)
  func _advanced(with stride: Int, count: Int) -> UnsafeMutablePointer {
    _advanced(raw: (MemoryLayout<UnsafeNode>.stride + stride) * count)
  }

  /// 型と移動量を指定して、他のノードを取得する
  ///
  /// ```
  /// ...|Node|RawValue|Node|RawValue|...
  ///    |             ^self         |
  ///    ^--_advanced -1             ^--_advanced +1
  /// ```
  @inlinable
  @inline(__always)
  func _advanced<_RawValue>(with t: _RawValue.Type, count: Int) -> UnsafeMutablePointer {
    _advanced(raw: (MemoryLayout<UnsafeNode>.stride + MemoryLayout<_RawValue>.stride) * count)
  }
}

@inlinable @inline(__always)
package func _ref<T>(to a: inout T) -> UnsafeMutablePointer<T> {
  withUnsafeMutablePointer(to: &a) { $0 }
}
