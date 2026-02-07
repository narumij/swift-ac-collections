//
//  _BridgeV2.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/07.
//

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
protocol _PayloadKeyBridge: _PayloadValueBride & _KeyBride
where Base: _BasePayloadValue_KeyInterface {}

extension _PayloadKeyBridge {

  @inlinable @inline(__always)
  public func __key(_ e: _PayloadValue) -> _Key {
    Base.__key(e)
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

/// ツリー使用条件をインジェクションされる側の実装プロトコル
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
