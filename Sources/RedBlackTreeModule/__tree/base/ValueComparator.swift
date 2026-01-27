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

// TODO: 名称変更

/// ツリー使用条件をインジェクションされる側の実装プロトコル
@usableFromInline
protocol ValueComparator:
  _BaseType
    & _TreeRawValue_KeyInterface
    & _TreeKey_CompInterface
    & _BaseRawValue_KeyInterface
    & _BaseKey_LessThanInterface
where
  _Key == Base._Key,
  _Payload == Base._Payload
{
  associatedtype
    Base:
      _BaseRawValue_KeyInterface
        & _BaseKey_LessThanInterface
}

extension ValueComparator {

  @inlinable
  @inline(__always)
  public static func __key(_ e: _Payload) -> _Key {
    Base.__key(e)
  }

  @inlinable
  @inline(__always)
  public static func value_comp(_ a: _Key, _ b: _Key) -> Bool {
    Base.value_comp(a, b)
  }
}

extension ValueComparator {

  @inlinable
  @inline(__always)
  public func __key(_ e: _Payload) -> _Key {
    Base.__key(e)
  }

  @inlinable
  @inline(__always)
  public func value_comp(_ a: _Key, _ b: _Key) -> Bool {
    Base.value_comp(a, b)
  }
}

extension ValueComparator where Base: _BaseRawValue_MappedValueInterface {
  
  @usableFromInline
  typealias _MappedValue = Base._MappedValue
  
  @inlinable
  @inline(__always)
  static func ___mapped_value(_ __v: _Payload) -> _MappedValue {
    Base.___mapped_value(__v)
  }
}

extension ValueComparator where Base: _BaseRawValue_MappedValueInterface {
  
  @inlinable
  @inline(__always)
  func ___mapped_value(_ __v: _Payload) -> _MappedValue {
    Base.___mapped_value(__v)
  }
}
