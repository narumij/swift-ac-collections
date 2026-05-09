//
//  _CompareV2+deprecated.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/10.
//

#if COMPATIBLE_ATCODER_2025
  // TODO: デッドコードになってないかチェックすること
  extension _CompareV2 where Base: CompareUniqueTrait {

    ///（重複なし）
    @inlinable @inline(__always)
    internal func ___equal_range(_ k: _Key) -> (lower: _NodePtr, upper: _NodePtr) {
      __tree_.__equal_range_unique(k)
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
  // TODO: デッドコードになってないかチェックすること
  extension _CompareV2 where Base: CompareUniqueTrait, Self: UnsafeIndexProviderProtocolV2 {

    ///（重複なし）
    @inlinable @inline(__always)
    internal func ___index_equal_range(_ k: _Key) -> (lower: Index, upper: Index) {
      let (lo, hi) = ___equal_range(k)
      return (___index(lo.sealed), ___index(hi.sealed))
    }
  }

  extension _CompareV2 where Base: CompareMultiTrait, Self: UnsafeIndexProviderProtocolV2 {

    /// （重複あり）
    @inlinable @inline(__always)
    internal func ___index_equal_range(_ k: _Key) -> (lower: Index, upper: Index) {
      let (lo, hi) = ___equal_range(k)
      return (___index(lo.sealed), ___index(hi.sealed))
    }
  }
#endif
