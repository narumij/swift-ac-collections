//
//  unsafe_node+pointer+compare.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/06/01.
//

#if DEBUG
  @testable import RedBlackTreeCollections

// ノードの大小を比較する
@inlinable
internal func ___ptr_comp_multi_org(
  _ __l: UnsafeMutablePointer<UnsafeNode>,
  _ __r: UnsafeMutablePointer<UnsafeNode>
)
  -> Bool
{
  assert(!__l.___is_null, "Left node shouldn't be null")
  assert(!__r.___is_null, "Right node shouldn't be null")
  guard
    !__l.___is_end,
    !__r.___is_end,
    __l != __r
  else {
    return !__l.___is_end && __r.___is_end
  }
  var (__l, __lh) = (__l, ___ptr_height(__l))
  var (__r, __rh) = (__r, ___ptr_height(__r))
  // __rの高さを詰める
  while __lh < __rh {
    // 共通祖先が__lだった場合
    if __r.__parent_ == __l {
      // __rが左でなければ（つまり右）、__lが小さい
      return !__tree_is_left_child(__r)
    }
    (__r, __rh) = (__r.__parent_, __rh - 1)
  }
  // __lの高さを詰める
  while __lh > __rh {
    // 共通祖先が__rだった場合
    if __l.__parent_ == __r {
      // __lが左であれば、__lが小さい
      return __tree_is_left_child(__l)
    }
    (__l, __lh) = (__l.__parent_, __lh - 1)
  }
  // 親が一致するまで、両方の高さを詰める
  while __l.__parent_ != __r.__parent_ {
    (__l, __r) = (__l.__parent_, __r.__parent_)
  }
  // 共通祖先が__lと__r以外だった場合
  // 共通祖先の左が__lであれば、__lが小さい
  return __tree_is_left_child(__l)
}

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  /// ルートからノードまでのパスをビットでコード化した値を返す
  ///
  /// leftを0、rightを1、末端を1とし、ルートから左詰めした数値
  ///
  /// 8bit幅で例えると、
  /// ルートは128 (0b10000000)
  /// ルートの左は64 (0b010000000)
  /// ルートの右は192となる  (0b110000000)
  /// (実際にはUIntで64bit幅)
  @inlinable
  internal func ___ptr_bitmap_org() -> UInt {
    assert(!___is_null, "Node shouldn't be null")
    assert(!___is_end, "Node shouldn't be end")
    var __f: UInt = 1  // 終端flag
    var __h = 1  // 終端flag分
    var __p = self
    while !__p.___is_root {
      __f |= (__tree_is_left_child(__p) ? 0 : 1) &<< __h
      __p = __p.__parent_
      __h &+= 1
    }
    __f &<<= UInt.bitWidth &- __h
    return __f
  }
}
#endif
