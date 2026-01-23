// Copyright 2024-2025 narumij
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2024 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

import Foundation

// クラスメソッドに移管できると、Indexの軽量化のめどが立つ

@usableFromInline
protocol CompareBothProtocol_ptr:
  _UnsafeNodePtrType
    & PointerCompareInterface
    & CompareUniqueProtocol
    & IsMultiTraitInterface
{
  func ___ptr_comp_unique(_ l: _NodePtr, _ r: _NodePtr) -> Bool
}

extension CompareBothProtocol_ptr {
  @inlinable
  @inline(__always)
  internal func ___ptr_comp(_ l: _NodePtr, _ r: _NodePtr) -> Bool {
    assert(l == end || l.__parent_ != nullptr)
    assert(r == end || r.__parent_ != nullptr)

    guard
      l != r,
      r != end,
      l != end
    else {
      return l != end && r == end
    }

    if isMulti {

      // TODO: ポインタ版になったので再度はかりなおすこと

      #if true
        //      name                         time             std         iterations
        //      --------------------------------------------------------------------
        //      index compare 1000        19416.000 ns ±  10.13 %       69751
        //      index compare 1000000 109517708.000 ns ±   2.03 %          13

        return ___ptr_comp_unique(l, r) || (!___ptr_comp_unique(r, l) && ___ptr_comp_multi(l, r))

      #else
        //      name                         time             std         iterations
        //      --------------------------------------------------------------------
        //      index compare 1000        11917.000 ns ±   8.25 %     114822
        //      index compare 1000000  54229021.000 ns ±   3.62 %         24

        return ___ptr_comp_unique(l, r) || (!___ptr_comp_unique(r, l) && ___ptr_comp_bitmap(l, r))

      #endif
    }
    return ___ptr_comp_unique(l, r)
  }
}

extension UnsafeMutablePointer where Pointee == UnsafeNode {


}

// ノードの高さを数える
@inlinable
@inline(__always)
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

// ノードの大小を比較する
@inlinable
//  @inline(__always)
internal func ___ptr_comp_multi_org(
  _ __l: UnsafeMutablePointer<UnsafeNode>,
  _ __r: UnsafeMutablePointer<UnsafeNode>)
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
  _ __r: UnsafeMutablePointer<UnsafeNode>)
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
  // 共通祖先の左が__lであれば、__lが小さい
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
