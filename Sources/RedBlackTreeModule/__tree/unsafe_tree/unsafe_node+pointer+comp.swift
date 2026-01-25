//
//  unsafe_node+pointer+comp.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/25.
//

// ノードの大小を比較する
@inlinable
//  @inline(__always)
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

@inlinable
//  @inline(__always)
internal func ___ptr_comp_multi(
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
    // endが混じってる場合と、等しい場合
    // 右だけendの場合のみtrueで、それ以外はfalse
    return !__l.___is_end && __r.___is_end
  }
  var (__l, __lh) = (__l, ___ptr_height(__l))
  var (__r, __rh) = (__r, ___ptr_height(__r))
  // 親が一致するまで、高さを詰める
  while __l.__parent_ != __r.__parent_ {
    // 共通祖先が__rだった場合
    if __l.__parent_ == __r {
      // __lが左であれば、__lが小さい
      return __tree_is_left_child(__l)
    }
    // 共通祖先が__lだった場合
    if __r.__parent_ == __l {
      // __rが左でなければ（つまり右）、__lが小さい
      return !__tree_is_left_child(__r)
    }
    // ちょっとだけトリッキー
    // 片方ずつ更新に一見みえるが、同じ高さの場合、両方更新となる
    if __lh <= __rh {
      __r = __r.__parent_
      __rh -= 1
    }
    if __lh > __rh {
      __l = __l.__parent_
      __lh -= 1
    }
  }
  // 共通祖先が__lと__r以外だった場合
  // 共通祖先の左の子のほうが小さい。それが__lであれば真を返す。
  return __tree_is_left_child(__l)
}

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  /// leftを0、rightを1、末端を1とし、ルートから左詰めした結果を返す
  ///
  /// 8bit幅で例えると、
  /// ルートは128 (0b10000000)
  /// ルートの左は64 (0b010000000)
  /// ルートの右は192となる  (0b110000000)
  /// (実際にはUIntで64bit幅)
  @inlinable
  @inline(__always)
  internal func ___ptr_bitmap() -> UInt {
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

  // 128bit幅でかつ、必要なレジスタ数が削減されている
  @inlinable
  @inline(__always)
  internal func ___ptr_bitmap_128() -> UInt128 {
    assert(!___is_null, "Node shouldn't be null")
    assert(!___is_end, "Node shouldn't be end")
    var __f: UInt128 = 1 &<< (UInt128.bitWidth &- 1)
    var __p = self
    while !__p.___is_root {
      __f &>>= 1
      __f |= (__tree_is_left_child(__p) ? 0 : 1) &<< (UInt128.bitWidth &- 1)
      __p = __p.__parent_
    }
    return __f
  }

  // 64bit幅でかつ、必要なレジスタ数が削減されている

  @inlinable
  @inline(__always)
  internal func ___ptr_bitmap_64() -> UInt {
    assert(!___is_null, "Node shouldn't be null")
    assert(!___is_end, "Node shouldn't be end")
    var __f: UInt = 1 &<< (UInt.bitWidth &- 1)
    var __p = self
    while !__p.___is_root {
      __f &>>= 1
      __f |= (__tree_is_left_child(__p) ? 0 : 1) &<< (UInt.bitWidth &- 1)
      __p = __p.__parent_
    }
    return __f
  }
}

/// 128bit版では速度が負けていて、64bit版では未定義が心配なので、お役御免
@inlinable
@inline(__always)
func ___ptr_comp_bitmap(
  _ __l: UnsafeMutablePointer<UnsafeNode>, _ __r: UnsafeMutablePointer<UnsafeNode>
) -> Bool {
  assert(!__l.___is_null, "Left node shouldn't be null")
  assert(!__r.___is_null, "Right node shouldn't be null")
  assert(!__l.___is_end, "Left node shouldn't be end")
  assert(!__r.___is_end, "Right node shouldn't be end")

  assert(___ptr_comp_multi(__l, __r) == (__l.___ptr_bitmap_128() < __r.___ptr_bitmap_128()))

  // サイズの64bit幅で絶対に使い切れない128bit幅が安心なのでこれを採用
  return __l.___ptr_bitmap_128() < __r.___ptr_bitmap_128()
  //  return __l.___ptr_bitmap_64() < __r.___ptr_bitmap_64()
  //  return __l.___ptr_bitmap() < __r.___ptr_bitmap()
}
