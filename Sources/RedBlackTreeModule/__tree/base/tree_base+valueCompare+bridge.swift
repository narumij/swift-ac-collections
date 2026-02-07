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

/// ツリー使用条件をインジェクションされる側の実装プロトコル
@usableFromInline
protocol _ValueComparerBridge:
  _BaseType
    & _NodePtrType
    & _TreePayloadValue_KeyInterface
    & _TreeKey_CompInterface
where
  _Key == Base._Key,
  _NodePtr == Base._NodePtr,
  _NodeRef == Base._NodeRef,
  _PayloadValue == Base._PayloadValue
{
  associatedtype
    Base:
      _NodePtrType
        & _BasePayloadValue_KeyInterface
        & _BaseKey_LessThanInterface
}

extension _ValueComparerBridge {

  @inlinable
  @inline(__always)
  public func __key(_ e: _PayloadValue) -> _Key {
    Base.__key(e)
  }

  @inlinable
  @inline(__always)
  func value_comp(_ a: _Key, _ b: _Key) -> Bool {
    Base.value_comp(a, b)
  }
}

extension _ValueComparerBridge where Base: _BaseNode_SignedDistanceInterface {

  @inlinable
  @inline(__always)
  func ___signed_distance(_ l: _NodePtr, _ r: _NodePtr) -> Int {
    Base.___signed_distance(l, r)
  }
}
