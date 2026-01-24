//
//  ValueComparator.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/25.
//

/// ツリー使用条件をインジェクションされる側の実装プロトコル
@usableFromInline
protocol ValueComparator:
  _TreeValueType
    & _TreeRawValue_KeyInterface
    & _TreeKey_CompInterface
    & _BaseRawValue_KeyInterface
    & _BaseKey_LessThanInterface
where
  _Key == Base._Key,
  _RawValue == Base._RawValue
{
  associatedtype
    Base:
      _BaseRawValue_KeyInterface
        & _BaseKey_LessThanInterface
}

extension ValueComparator {

  @inlinable
  @inline(__always)
  public static func __key(_ e: _RawValue) -> _Key {
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
  public func __key(_ e: _RawValue) -> _Key {
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
  static func ___mapped_value(_ __v: _RawValue) -> _MappedValue {
    Base.___mapped_value(__v)
  }
}

extension ValueComparator where Base: _BaseRawValue_MappedValueInterface {
  
  @inlinable
  @inline(__always)
  func ___mapped_value(_ __v: _RawValue) -> _MappedValue {
    Base.___mapped_value(__v)
  }
}
