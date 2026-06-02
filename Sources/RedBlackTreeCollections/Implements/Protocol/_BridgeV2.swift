//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project.
//
// Copyright (c) 2024-2026 narumij.
// Licensed under the Apache License v2.0.
//
// SPDX-License-Identifier: Apache-2.0
//
// This implementation includes code derived from LLVM libc++'s red-black tree
// implementation, originally distributed under the Apache License v2.0 with
// LLVM Exceptions.
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by
// narumij.
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

/// ツリー使用条件をインジェクションされる側の実装プロトコル
@usableFromInline
protocol _PayloadValueBridge_Key: _PayloadValueBride & _KeyBride
where Base: _BasePayloadValue_KeyInterface {}

extension _PayloadValueBridge_Key {

  @inlinable
  public func __key(_ e: _PayloadValue) -> _Key {
    Base.__key(e)
  }
}

/// ツリー使用条件をインジェクションされる側の実装プロトコル
@usableFromInline
protocol _ValueCompBridge: _KeyBride
where Base: _BaseKey_LessThanInterface {}

extension _ValueCompBridge {

  @inlinable
  func value_comp(_ a: _Key, _ b: _Key) -> Bool {
    Base.value_comp(a, b)
  }
}

@usableFromInline
protocol _PaylodValueBridge_Element: _BaseBridge & _PayloadValueBridge_Key & _ElementBride
where Base: _BasePaylodValue_ElementInterface {}

extension _PaylodValueBridge_Element {

  @inlinable
  func __element_(_ __value: _PayloadValue) -> Element {
    Base.__element_(__value)
  }
}
