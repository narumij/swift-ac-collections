//
//  ValueComparer.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/24.
//

// MARK: common

// TODO: プロトコルインジェクションを整理すること
// __treenの基本要素ではないので、別カテゴリがいい

/// ツリー使用条件をインジェクションするためのプロトコル
public protocol ValueComparer: _TreeValueType & _BaseNode_KeyProtocol & _BaseKey_CompInterface & _BaseNode_KeyProtocol & PointerCompareStaticProtocol &
_BaseValue_KeyInterface & _BaseKey_CompInterface & _BaseKey_EquivInterface {
  /// 要素から比較キー値がとれること
  @inlinable static func __key(_: _RawValue) -> _Key
  /// 比較関数が実装されていること
  @inlinable static func value_comp(_: _Key, _: _Key) -> Bool
}

extension ValueComparer {

  @inlinable
  @inline(__always)
  public static func value_equiv(_ lhs: _Key, _ rhs: _Key) -> Bool {
    !value_comp(lhs, rhs) && !value_comp(rhs, lhs)
  }
}

// Comparableプロトコルの場合標準実装を付与する
extension ValueComparer where _Key: Comparable {

  /// Comparableプロトコルの場合の標準実装
  @inlinable
  @inline(__always)
  public static func value_comp(_ a: _Key, _ b: _Key) -> Bool {
    a < b
  }
}

// Equatableプロトコルの場合標準実装を付与する
extension ValueComparer where _Key: Equatable {

  @inlinable
  @inline(__always)
  public static func value_equiv(_ lhs: _Key, _ rhs: _Key) -> Bool {
    lhs == rhs
  }
}

/// ツリー使用条件をインジェクションされる側の実装プロトコル
@usableFromInline
protocol ValueComparator: _TreeValueType & _TreeValue_KeyInterface & _TreeKey_CompInterface
where
  _Key == Base._Key,
  _RawValue == Base._RawValue
{
  associatedtype Base: ValueComparer
  @inlinable static func __key(_ e: _RawValue) -> _Key
  @inlinable static func value_comp(_ a: _Key, _ b: _Key) -> Bool
  @inlinable static func value_equiv(_ lhs: _Key, _ rhs: _Key) -> Bool
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

  @inlinable
  @inline(__always)
  public static func value_equiv(_ lhs: _Key, _ rhs: _Key) -> Bool {
    Base.value_equiv(lhs, rhs)
  }

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

extension ValueComparator {

  @inlinable
  @inline(__always)
  internal static func with_value_equiv<T>(_ f: ((_Key, _Key) -> Bool) -> T) -> T {
    f(value_equiv)
  }

  @inlinable
  @inline(__always)
  internal static func with_value_comp<T>(_ f: ((_Key, _Key) -> Bool) -> T) -> T {
    f(value_comp)
  }
}

extension ValueComparator where Base: ThreeWayComparator {

  @inlinable
  @inline(__always)
  internal func
    __lazy_synth_three_way_comparator(_ __lhs: _Key, _ __rhs: _Key)
    -> Base.__compare_result
  {
    Base.__lazy_synth_three_way_comparator(__lhs, __rhs)
  }
}
