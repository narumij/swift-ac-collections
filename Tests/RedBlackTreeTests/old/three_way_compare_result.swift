//
//  three_way_compare_result.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/06/01.
//

// 期待したほどじゃなかった
public enum ___enum_compare_result: ThreeWayCompareResult {
  case less, greater, equal

  @inlinable
  public func __less() -> Bool {
    self == .less
  }
  @inlinable
  public func __greater() -> Bool {
    self == .greater
  }
}

// MARK: -

#if DEBUG
  @testable import RedBlackTreeCollections
  // 以下は資料的に残している。

  // 特殊なキーを使いたい場合に使える
  public
    struct __lazy_compare_result<Base: _BaseKey_LessThanInterface>: ThreeWayCompareResult
  {
    public typealias LHS = Base._Key
    public typealias RHS = Base._Key
    @usableFromInline internal var __lhs_: LHS
    @usableFromInline internal var __rhs_: RHS
    @inlinable
    internal init(_ __lhs_: LHS, _ __rhs_: RHS) {
      self.__lhs_ = __lhs_
      self.__rhs_ = __rhs_
    }
    @inlinable
    internal func __comp_(_ __lhs_: LHS, _ __rhs_: RHS) -> Bool {
      Base.value_comp(__lhs_, __rhs_)
    }
    @inlinable
    public func __less() -> Bool { __comp_(__lhs_, __rhs_) }
    @inlinable
    public func __greater() -> Bool { __comp_(__rhs_, __lhs_) }
  }

  // バグって速かった。直したら普通
  public
    struct __comparable_compare_result<T: Comparable>: ThreeWayCompareResult
  {
    @usableFromInline internal var __lhs_, __rhs_: T
    @inlinable
    internal init(_ __lhs_: T, _ __rhs_: T) {
      self.__lhs_ = __lhs_
      self.__rhs_ = __rhs_
    }
    @inlinable
    public func __less() -> Bool { __lhs_ < __rhs_ }
    @inlinable
    public func __greater() -> Bool { __lhs_ > __rhs_ }
  }
#endif
