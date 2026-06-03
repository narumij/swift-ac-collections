//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project.
//
// Copyright (c) 2024-2026 narumij.
// Licensed under the Apache License v2.0.
//
// SPDX-License-Identifier: Apache-2.0
//
// This implementation includes code derived from LLVM libc++'s red-black tree
// implementation, originally distributed under the Apache License v2.0 with
// LLVM Exceptions.
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by
// narumij.
//
//===----------------------------------------------------------------------===//

@inlinable
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

// ノードの高さを数える
@inlinable
internal func ___ptr_height(_ __p: UnsafeMutablePointer<UnsafeNode>) -> Int {
  assert(!__p.___is_null, "Node shouldn't be null")
  var __h = 0
  var __p = __p
  while !__p.___is_root {
    __p = __p.__parent_
    __h += 1
  }
  return __h
}

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  #if USE_INT128
    // 128bit幅でかつ、必要なレジスタ数が削減されている
    /// ルートからノードまでのパスをビットでコード化した値を返す
    ///
    /// leftを0、rightを1、末端を1とし、ルートから左詰めした数値
    @inlinable
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
  #else

    // 64bit幅でかつ、必要なレジスタ数が削減されている
    /// ルートからノードまでのパスをビットでコード化した値を返す
    ///
    /// leftを0、rightを1、末端を1とし、ルートから左詰めした数値
    @inlinable
    internal func ___ptr_bitmap_64() -> UInt64 {
      assert(!___is_null, "Node shouldn't be null")
      assert(!___is_end, "Node shouldn't be end")
      var __f: UInt64 = 1 &<< (UInt64.bitWidth &- 1)
      var __p = self
      while !__p.___is_root {
        __f &>>= 1
        __f |= (__tree_is_left_child(__p) ? 0 : 1) &<< (UInt.bitWidth &- 1)
        __p = __p.__parent_
      }
      return __f
    }
  #endif

  #if USE_INT128
    /// ルートからノードまでのパスをビットでコード化した値を返す
    ///
    /// leftを0、rightを1、末端を1とし、ルートから左詰めした数値
    @inlinable
    internal func ___ptr_bitmap() -> UInt128 {
      ___ptr_bitmap_128()
    }
  #else
    /// ルートからノードまでのパスをビットでコード化した値を返す
    ///
    /// leftを0、rightを1、末端を1とし、ルートから左詰めした数値
    @inlinable
    internal func ___ptr_bitmap() -> UInt64 {
      ___ptr_bitmap_64()
    }
  #endif
}

#if USE_INT128
  // 128bit版では速度が負けていて、64bit版では未定義が心配なので、お役御免
  @inlinable
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
    //  return __l.___ptr_bitmap_org() < __r.___ptr_bitmap_org()
  }
#else
  @inlinable
  func ___ptr_comp_bitmap(
    _ __l: UnsafeMutablePointer<UnsafeNode>, _ __r: UnsafeMutablePointer<UnsafeNode>
  ) -> Bool {
    #if false
      return __l.___ptr_bitmap_64() < __r.___ptr_bitmap_64()
    #else
      return (__l.___is_end ? .max : __l.___ptr_bitmap_64())
        < (__r.___is_end ? .max : __r.___ptr_bitmap_64())
    #endif
  }
#endif
