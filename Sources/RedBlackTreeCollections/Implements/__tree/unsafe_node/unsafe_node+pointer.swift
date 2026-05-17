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

  @inlinable
  nonisolated(unsafe)
  static var nullptr: _NodePtr {
    UnsafeNode.nullptr
  }

  @inlinable
  var __left_: _NodePtr {
    _read { yield pointee.__left_ }
    nonmutating _modify { yield &pointee.__left_ }
  }

  @inlinable
  var __right_: _NodePtr {
    _read { yield pointee.__right_ }
    nonmutating _modify { yield &pointee.__right_ }
  }

  @inlinable
  var __parent_: _NodePtr {
    _read { yield pointee.__parent_ }
    nonmutating _modify { yield &pointee.__parent_ }
  }
  
  // NOTE: 移植の命名互換のための別名。意味は`__parent_`と同じ。
  @inlinable
  var __parent_unsafe: _NodePtr {
    _read { yield pointee.__parent_ }
    nonmutating _modify { yield &pointee.__parent_ }
  }

  @inlinable
  func __set_parent(_ p: _NodePtr) {
    pointee.__parent_ = p
  }

  @inlinable
  var __is_black_: Bool {
    _read { yield pointee.__is_black_ }
    nonmutating _modify { yield &pointee.__is_black_ }
  }

  @inlinable
  var __left_ref: _NodeRef {
    _ref(to: &pointee.__left_)
  }

  @inlinable
  var __right_ref: _NodeRef {
    _ref(to: &pointee.__right_)
  }
}

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  /// ゆっくりendを返す
  ///
  /// どのくらいゆっくりかというとO(log N)ぐらい
  ///
  /// ルートのペアレントまたはペアレントがヌルなのがend
  @usableFromInline
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
  ///    |    ^--__payload_
  ///    ^self
  /// ```
  @inlinable
  var __raw_payload_: UnsafeMutableRawPointer {
    UnsafeMutableRawPointer(advanced(by: 1))
  }

  /// ペイロードを値とみなしたポインタ
  ///
  /// ```
  /// ...|Node|PayloadValue|Node...
  ///    |    ^--__value_
  ///    ^self
  /// ```
  ///
  /// 型推論で型が決定する
  ///
  /// インスタンス名は既存踏襲で`__value_`。型としてはより明確な`_PayloadValue`となる。
  @inlinable
  func __value_<_PayloadValue>() -> UnsafeMutablePointer<_PayloadValue> {
    UnsafeMutableRawPointer(advanced(by: 1))
      .assumingMemoryBound(to: _PayloadValue.self)
  }

  /// ペイロードを値とみなしたポインタ
  ///
  /// ```
  /// ...|Node|PayloadValue|Node...
  ///    |    ^--__value_
  ///    ^self
  /// ```
  ///
  /// 引数で型が決定する
  ///
  /// インスタンス名は既存踏襲で`__value_`。型としてはより明確な`_PayloadValue`となる。
  @inlinable
  package func __value_<_PayloadValue>(as t: _PayloadValue.Type) -> UnsafeMutablePointer<
    _PayloadValue
  > {
    UnsafeMutableRawPointer(advanced(by: 1))
      .assumingMemoryBound(to: _PayloadValue.self)
  }
}

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  @inlinable
  var trackingTag: _TrackingTag {
    pointee.___tracking_tag
  }
}

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  @inlinable
  func _advanced(raw bytes: Int) -> UnsafeMutablePointer {
    UnsafeMutableRawPointer(self)
      .advanced(by: bytes)
      .assumingMemoryBound(to: UnsafeNode.self)
  }

  /// 単位移動量と移動量を指定して、他のノードアドレスを取得する
  ///
  /// ```
  /// ...|Node|stride|Node|stride|...
  ///    |           ^self       |
  ///    ^--_advanced -1         ^--_advanced +1
  /// ```
  @inlinable
  func _advanced(with stride: Int, count: Int) -> UnsafeMutablePointer {
    _advanced(raw: (MemoryLayout<UnsafeNode>.stride + stride) * count)
  }

  /// 型と移動量を指定して、他のノードアドレスを取得する
  ///
  /// ```
  /// ...|Node|PayloadValue|Node|PayloadValue|...
  ///    ^--_advanced -1   ^--self           ^--_advanced +1
  /// ```
  @inlinable
  func _advanced<_PayloadValue>(with t: _PayloadValue.Type, count: Int) -> UnsafeMutablePointer {
    _advanced(raw: (MemoryLayout<UnsafeNode>.stride + MemoryLayout<_PayloadValue>.stride) * count)
  }
}

@inlinable
package func _ref<T>(to a: inout T) -> UnsafeMutablePointer<T> {
  withUnsafeMutablePointer(to: &a) { $0 }
}
