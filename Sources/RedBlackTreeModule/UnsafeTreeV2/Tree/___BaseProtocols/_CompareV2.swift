//
//  ___CompareV2.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/07.
//

@usableFromInline
protocol _CompareV2: UnsafeTreeHost & _KeyBride {}

extension _CompareV2 where Base: CompareUniqueTrait {
  
  ///（重複なし）
  @inlinable
  @inline(__always)
  internal func ___equal_range(_ k: _Key) -> (lower: _NodePtr, upper: _NodePtr) {
    __tree_.__equal_range_unique(k)
  }
}

extension _CompareV2 where Base: CompareMultiTrait {
  
  /// （重複あり）
  @inlinable
  @inline(__always)
  internal func ___equal_range(_ k: _Key) -> (lower: _NodePtr, upper: _NodePtr) {
    __tree_.__equal_range_multi(k)
  }
}

extension _CompareV2 where Base: CompareUniqueTrait, Self: UnsafeIndexProviderProtocol {

  ///（重複なし）
  @inlinable
  @inline(__always)
  internal func ___index_equal_range(_ k: _Key) -> (lower: Index, upper: Index) {
    let (lo, hi) = ___equal_range(k)
    return (___index(lo.sealed), ___index(hi.sealed))
  }
}

extension _CompareV2 where Base: CompareMultiTrait, Self: UnsafeIndexProviderProtocol {

  /// （重複あり）
  @inlinable
  @inline(__always)
  internal func ___index_equal_range(_ k: _Key) -> (lower: Index, upper: Index) {
    let (lo, hi) = ___equal_range(k)
    return (___index(lo.sealed), ___index(hi.sealed))
  }
}
