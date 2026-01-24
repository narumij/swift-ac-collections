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

extension ValueComparator where Base: _BaseKey_LazyThreeWayCompInterface {

  @usableFromInline
  typealias __compare_result = Base.__compare_result

  @inlinable
  @inline(__always)
  static func
    __lazy_synth_three_way_comparator(_ __lhs: _Key, _ __rhs: _Key)
    -> __compare_result
  {
    Base.__lazy_synth_three_way_comparator(__lhs, __rhs)
  }
}

extension ValueComparator where Base: _BaseKey_LazyThreeWayCompInterface {

  @inlinable
  @inline(__always)
  func
    __lazy_synth_three_way_comparator(_ __lhs: _Key, _ __rhs: _Key)
    -> __compare_result
  {
    Base.__lazy_synth_three_way_comparator(__lhs, __rhs)
  }
}
