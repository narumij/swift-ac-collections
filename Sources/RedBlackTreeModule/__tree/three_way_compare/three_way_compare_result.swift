//
//  three_way_compare_resul.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/20.
//

// 特殊なキーを使いたい場合に使える
public
  struct __lazy_compare_result<Base: _BaseKey_LessThanInterface>: ThreeWayCompareResult
{
  public typealias LHS = Base._Key
  public typealias RHS = Base._Key
  @usableFromInline internal var __lhs_: LHS
  @usableFromInline internal var __rhs_: RHS
  @inlinable
  @inline(__always)
  internal init(_ __lhs_: LHS, _ __rhs_: RHS) {
    self.__lhs_ = __lhs_
    self.__rhs_ = __rhs_
  }
  @inlinable
  @inline(__always)
  internal func __comp_(_ __lhs_: LHS, _ __rhs_: RHS) -> Bool {
    Base.value_comp(__lhs_, __rhs_)
  }
  @inlinable
  @inline(__always)
  public func __less() -> Bool { __comp_(__lhs_, __rhs_) }
  @inlinable
  @inline(__always)
  public func __greater() -> Bool { __comp_(__rhs_, __lhs_) }
}

// バグって速かった。直したら普通
public
  struct __comparable_compare_result<T: Comparable>: ThreeWayCompareResult
{
  @usableFromInline internal var __lhs_, __rhs_: T
  @inlinable
  @inline(__always)
  internal init(_ __lhs_: T, _ __rhs_: T) {
    self.__lhs_ = __lhs_
    self.__rhs_ = __rhs_
  }
  @inlinable
  @inline(__always)
  public func __less() -> Bool { __lhs_ < __rhs_ }
  @inlinable
  @inline(__always)
  public func __greater() -> Bool { __lhs_ > __rhs_ }
}

// 安定して速い
public
  struct __eager_compare_result: ThreeWayCompareResult
{
  @usableFromInline internal var __res_: Int
  @inlinable
  @inline(__always)
  internal init(_ __res_: Int) {
    self.__res_ = __res_
  }
  @inlinable
  @inline(__always)
  public func __less() -> Bool { __res_ < 0 }
  @inlinable
  @inline(__always)
  public func __greater() -> Bool { __res_ > 0 }
}

// 結局のところ最も速い
public typealias __int_compare_result = Int

extension Int: ThreeWayCompareResult {}

extension Int {
  @inlinable
  @inline(__always)
  public func __less() -> Bool { self < 0 }
  @inlinable
  @inline(__always)
  public func __greater() -> Bool { self > 0 }
}

// 期待したほどじゃなかった
public enum ___enum_compare_result: ThreeWayCompareResult {
  case less, greater, equal

  @inlinable @inline(__always)
  public func __less() -> Bool {
    self == .less
  }
  @inlinable @inline(__always)
  public func __greater() -> Bool {
    self == .greater
  }
}
