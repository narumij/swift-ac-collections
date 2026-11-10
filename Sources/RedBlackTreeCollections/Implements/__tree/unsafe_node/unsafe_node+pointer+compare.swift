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
package func ___ptr_comp_multi(
  _ __l: UnsafeMutablePointer<UnsafeNode>,
  _ __r: UnsafeMutablePointer<UnsafeNode>
)
  -> Bool
{
  _TREE_ASSERT_INTERNAL(!__l.___is_null, "Left node shouldn't be null")
  _TREE_ASSERT_INTERNAL(!__r.___is_null, "Right node shouldn't be null")
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
  if __lh > __rh {
    while __lh > __rh &+ 1 {
      __l = __l.__parent_
      __lh &-= 1
    }
    if __l.__parent_ == __r {
      return __tree_is_left_child(__l)
    }
    __l = __l.__parent_
  } else if __rh > __lh {
    while __rh > __lh &+ 1 {
      __r = __r.__parent_
      __rh &-= 1
    }
    if __r.__parent_ == __l {
      return !__tree_is_left_child(__r)
    }
    __r = __r.__parent_
  }
  while __l.__parent_ != __r.__parent_ {
    __l = __l.__parent_
    __r = __r.__parent_
  }
  return __tree_is_left_child(__l)
}

// ノードの高さを数える
@inlinable
package func ___ptr_height(_ __p: UnsafeMutablePointer<UnsafeNode>) -> Int {
  _TREE_ASSERT_INTERNAL(!__p.___is_null, "Node shouldn't be null")
  var __h = 0
  var __p = __p
  while !__p.___is_root {
    __p = __p.__parent_
    __h &+= 1
  }
  return __h
}

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  // TODO: bitmapをpath_bitmapにリネームする

  // 128bit幅でかつ、必要なレジスタ数が削減されている
  // ルートからノードまでのパスをビットでコード化した値を返す
  //
  // leftを0、rightを1、末端を1とし、ルートから左詰めした数値
  @available(macOS 15.0, *)
  @inlinable
  package func ___ptr_bitmap_128() -> UInt128 {
    _TREE_ASSERT_INTERNAL(!___is_null, "Node shouldn't be null")
    _TREE_ASSERT_INTERNAL(!___is_end, "Node shouldn't be end")
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
  // ルートからノードまでのパスをビットでコード化した値を返す
  //
  // leftを0、rightを1、末端を1とし、ルートから左詰めした数値
  @inlinable
  internal func ___ptr_bitmap_64() -> UInt64 {
    _TREE_ASSERT_INTERNAL(!___is_null, "Node shouldn't be null")
    _TREE_ASSERT_INTERNAL(!___is_end, "Node shouldn't be end")
    var __f: UInt64 = 1 &<< (UInt64.bitWidth &- 1)
    var __p = self
    while !__p.___is_root {
      __f &>>= 1
      __f |= (__tree_is_left_child(__p) ? 0 : 1) &<< (UInt64.bitWidth &- 1)
      __p = __p.__parent_
    }
    return __f
  }
}

@inlinable
package func ___ptr_comp_bitmap(
  _ __l: UnsafeMutablePointer<UnsafeNode>,
  _ __r: UnsafeMutablePointer<UnsafeNode>
) -> Bool {
  _TREE_ASSERT_INTERNAL(!__l.___is_null, "Left node shouldn't be null")
  _TREE_ASSERT_INTERNAL(!__r.___is_null, "Right node shouldn't be null")

  #if USE_INT128
    return (__l.___is_end ? .max : __l.___ptr_bitmap_128())
      < (__r.___is_end ? .max : __r.___ptr_bitmap_128())
  #endif

  return (__l.___is_end ? .max : __l.___ptr_bitmap_64())
    < (__r.___is_end ? .max : __r.___ptr_bitmap_64())
}

//@inlinable
//func lessThan(
//  lhs: (node: UnsafeMutablePointer<UnsafeNode>, bitmap: _NodePathBitmap?),
//  rhs: (node: UnsafeMutablePointer<UnsafeNode>, bitmap: _NodePathBitmap?)
//)
//  -> (
//    result: Bool,
//    lhsBitmap: _NodePathBitmap?,
//    rhsBitmap: _NodePathBitmap?
//  )
//{
//  let lhsBitmap = lhs.bitmap ?? _NodePathBitmap(lhs.node)
//  let rhsBitmap = rhs.bitmap ?? _NodePathBitmap(rhs.node)
//  return (lhsBitmap < rhsBitmap, lhsBitmap, rhsBitmap)
//}
