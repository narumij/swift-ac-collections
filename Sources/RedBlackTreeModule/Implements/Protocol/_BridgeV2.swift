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

/// ベースのキー型を受け継ぐ
public protocol _KeyBride: _BaseBridge & _KeyType
where _Key == Base._Key, Base: _KeyType {}

/// ベースの積載型を受け継ぐ
public protocol _PayloadValueBride: _BaseBridge & _PayloadValueType
where _PayloadValue == Base._PayloadValue, Base: _PayloadValueType {}

/// ベースのバリュー型を受け継ぐ
public protocol _MappedValueBride: _BaseBridge & _MappedValueType
where _MappedValue == Base._MappedValue, Base: _MappedValueType {}

/// ベースの要素型を受け継ぐ
public protocol _ElementBride: _BaseBridge & _ElementType
where Element == Base.Element, Base: _ElementType {}

@usableFromInline
protocol _PayloadPointerBridge: _UnsafeNodePtrType & _BaseBridge
where Base: _UnsafeNodePtrType & _PayloadValueType {}

extension _PayloadPointerBridge {

  @inlinable @inline(__always)
  func __payload_ptr(_ p: Base._NodePtr) -> Base._PayloadPtr {
    Base.__payload_ptr(p)
  }

  @inlinable @inline(__always)
  func __payload_(_ p: Base._NodePtr) -> Base._PayloadValue {
    Base.__payload_(p)
  }
}

/// ツリー使用条件をインジェクションされる側の実装プロトコル
@usableFromInline
protocol _PayloadKeyBridge: _PayloadValueBride & _KeyBride
where Base: _BasePayloadValue_KeyInterface {}

extension _PayloadKeyBridge {

  @inlinable @inline(__always)
  public func __key(_ e: _PayloadValue) -> _Key {
    Base.__key(e)
  }
}

@usableFromInline
protocol _PayloadMappedValueBridge: _PayloadValueBride & _MappedValueBride
where Base: _BasePayloadValue_MappedValueInterface {}

extension _PayloadMappedValueBridge {

  @inlinable @inline(__always)
  func ___mapped_value(_ p: _PayloadValue) -> _MappedValue {
    Base.___mapped_value(p)
  }
}

@usableFromInline
protocol _PaylodElementBridge: _BaseBridge & _PayloadKeyBridge & _ElementBride
where Base: _BasePaylodValue_ElementInterface {}

extension _PaylodElementBridge {

  @inlinable @inline(__always)
  func __element_(_ __value: _PayloadValue) -> Element {
    Base.__element_(__value)
  }
}

@usableFromInline
protocol _ElementPayloadBridge: _BaseBridge & _PayloadKeyBridge & _ElementBride
where Base: _KeyValueBasePaylodValue_ElementInterface {}

extension _ElementPayloadBridge {

  @inlinable @inline(__always)
  func __payload_(_ __e: Element) -> _PayloadValue {
    Base.__payload_(__e)
  }
}

/// ツリー使用条件をインジェクションされる側の実装プロトコル
@usableFromInline
protocol _ValueCompBridge: _KeyBride
where Base: _BaseKey_LessThanInterface {}

extension _ValueCompBridge {

  @inlinable @inline(__always)
  func value_comp(_ a: _Key, _ b: _Key) -> Bool {
    Base.value_comp(a, b)
  }
}

@usableFromInline
protocol _SignedDistanceBridge: _BaseBridge
where Base: _BaseNode_SignedDistanceInterface {
}

extension _SignedDistanceBridge {

  @inlinable @inline(__always)
  func ___signed_distance(_ l: Base._NodePtr, _ r: Base._NodePtr) -> Int {
    Base.___signed_distance(l, r)
  }
}

@usableFromInline
protocol _PtrCompBridge: _BaseBridge
where Base: _BaseNode_PtrCompInterface & _NodePtrType {}

extension _PtrCompBridge {

  @inlinable @inline(__always)
  func ___ptr_comp(_ l: Base._NodePtr, _ r: Base._NodePtr) -> Bool {
    Base.___ptr_comp(l, r)
  }
}

@usableFromInline
protocol _PtrRangeCompBridge: _BaseBridge
where Base: _BaseNode_PtrRangeCompProtocol & _NodePtrType {}

extension _PtrRangeCompBridge {

  @inlinable @inline(__always)
  func ___ptr_range_comp(_ __f: Base._NodePtr, _ __p: Base._NodePtr, _ __l: Base._NodePtr) -> Bool {
    Base.___ptr_range_comp(__f, __p, __l)
  }
}
