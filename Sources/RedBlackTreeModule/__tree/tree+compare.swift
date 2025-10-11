// Copyright 2024 narumij
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

@usableFromInline
protocol PointerCompareProtocol: ValueProtocol {
  func ___ptr_comp(_ l: _NodePtr, _ r: _NodePtr) -> Bool
}

@usableFromInline
protocol CompareBothProtocol: CompareUniqueProtocol, CompareMultiProtocol, NodeFlagProtocol {
  var isMulti: Bool { get }
  func ___ptr_comp_unique(_ l: _NodePtr, _ r: _NodePtr) -> Bool
  func ___ptr_comp_multi(_ __l: _NodePtr, _ __r: _NodePtr) -> Bool
}

extension CompareBothProtocol {
  @inlinable
  @inline(__always)
  func ___ptr_comp(_ l: _NodePtr, _ r: _NodePtr) -> Bool {
    assert(l == .end || __parent_(l) != .nullptr)
    assert(r == .end || __parent_(r) != .nullptr)
    
    guard
      l != r,
      r != .end,
      l != .end
    else {
      return l != .end && r == .end
    }

    if isMulti {
//      return ___ptr_comp_unique(l, r) || (!___ptr_comp_unique(r, l) && ___ptr_comp_multi(l, r))
      return ___ptr_comp_unique(l, r) || (!___ptr_comp_unique(r, l) && ___ptr_comp_bitmap(l, r))
    }
    return ___ptr_comp_unique(l, r)
  }
}

public protocol CompareTrait {
  static var isMulti: Bool { get }
}

public protocol CompareUniqueTrait: CompareTrait {}

extension CompareUniqueTrait {
  @inlinable @inline(__always)
  public static var isMulti: Bool { false }
}

public protocol CompareMultiTrait: CompareTrait {}

extension CompareMultiTrait {
  @inlinable @inline(__always)
  public static var isMulti: Bool { true }
}

@usableFromInline
protocol CompareUniqueProtocol: ValueProtocol {}

extension CompareUniqueProtocol {

  /// multisetでも、インデックス比較に関して不正な結果だが、レンジで使う限り落ちはしない
  @inlinable
  @inline(__always)
  func ___ptr_comp_unique(_ l: _NodePtr, _ r: _NodePtr) -> Bool {
    assert(l != .nullptr, "Node shouldn't be null")
    assert(l != .end, "Node shouldn't be end")
    assert(r != .nullptr, "Node shouldn't be null")
    assert(r != .end, "Node shouldn't be end")
    return value_comp(__get_value(l), __get_value(r))
  }
}

@usableFromInline
protocol CompareMultiProtocol: TreeNodeProtocol & RootProtocol & EndProtocol {}

extension CompareMultiProtocol {

  // ノードの高さを数える
  @inlinable
  @inline(__always)
  func ___ptr_height(_ __p: _NodePtr) -> Int {
    assert(__p != .nullptr, "Node shouldn't be null")
    var __h = 0
    var __p = __p
    while __p != __root(), __p != end() {
      __p = __parent_(__p)
      __h += 1
    }
    return __h
  }

  // ノードの大小を比較する
  @inlinable
  //  @inline(__always)
  func ___ptr_comp_multi(_ __l: _NodePtr, _ __r: _NodePtr) -> Bool {
    assert(__l != .nullptr, "Left node shouldn't be null")
    assert(__r != .nullptr, "Right node shouldn't be null")
    guard
      __l != end(),
      __r != end(),
      __l != __r
    else {
      return __l != end() && __r == end()
    }
    var (__l, __lh) = (__l, ___ptr_height(__l))
    var (__r, __rh) = (__r, ___ptr_height(__r))
    // __rの高さを詰める
    while __lh < __rh {
      // 共通祖先が__lだった場合
      if __parent_(__r) == __l {
        // __rが左でなければ（つまり右）、__lが小さい
        return !__tree_is_left_child(__r)
      }
      (__r, __rh) = (__parent_(__r), __rh - 1)
    }
    // __lの高さを詰める
    while __lh > __rh {
      // 共通祖先が__rだった場合
      if __parent_(__l) == __r {
        // __lが左であれば、__lが小さい
        return __tree_is_left_child(__l)
      }
      (__l, __lh) = (__parent_(__l), __lh - 1)
    }
    // 親が一致するまで、両方の高さを詰める
    while __parent_(__l) != __parent_(__r) {
      (__l, __r) = (__parent_(__l), __parent_(__r))
    }
    // 共通祖先が__lと__r以外だった場合
    // 共通祖先の左が__lであれば、__lが小さい
    return __tree_is_left_child(__l)
  }
}

@usableFromInline
protocol CompareProtocol: PointerCompareProtocol {}

extension CompareProtocol {

  @inlinable
  @inline(__always)
  func ___ptr_less_than(_ l: _NodePtr, _ r: _NodePtr) -> Bool {
    ___ptr_comp(l, r)
  }

  @inlinable
  @inline(__always)
  func ___ptr_less_than_or_equal(_ l: _NodePtr, _ r: _NodePtr) -> Bool {
    !___ptr_comp(r, l)
  }

  @inlinable
  @inline(__always)
  func ___ptr_greator_than(_ l: _NodePtr, _ r: _NodePtr) -> Bool {
    ___ptr_comp(r, l)
  }

  @inlinable
  @inline(__always)
  func ___ptr_greator_than_or_equal(_ l: _NodePtr, _ r: _NodePtr) -> Bool {
    !___ptr_comp(l, r)
  }

  @inlinable
  @inline(__always)
  func ___ptr_range_contains(_ l: _NodePtr, _ r: _NodePtr, _ p: _NodePtr) -> Bool {
    ___ptr_less_than_or_equal(l, p) && ___ptr_less_than(p, r)
  }

  @inlinable
  @inline(__always)
  func ___ptr_closed_range_contains(_ l: _NodePtr, _ r: _NodePtr, _ p: _NodePtr) -> Bool {
    ___ptr_less_than_or_equal(l, p) && ___ptr_less_than_or_equal(p, r)
  }
}

// TODO: 名前の変更
@usableFromInline
protocol NodeFlagProtocol: TreeNodeProtocol & RootProtocol & EndProtocol {}

extension NodeFlagProtocol {

  /// leftを0、rightを1、末端を1とし、ルートから左詰めした結果を返す
  ///
  /// 8bit幅で例えると、
  /// ルートは128 (0b10000000)
  /// ルートの左は64 (0b010000000)
  /// ルートの右は192となる  (0b110000000)
  /// (実際にはUIntで64bit幅)
  @inlinable
  @inline(__always)
  func ___ptr_bitmap(_ __p: _NodePtr) -> UInt {
    assert(__p != .nullptr, "Node shouldn't be null")
    assert(__p != .end, "Node shouldn't be end")
    var __f: UInt = 1  // 終端flag
    var __h = 1 // 終端flag分
    var __p = __p
    while __p != __root(), __p != .end {
      __f |= (__tree_is_left_child(__p) ? 0 : 1) &<< __h
      __p = __parent_(__p)
      __h &+= 1
    }
    __f &<<= UInt.bitWidth &- __h
    return __f
  }

  @inlinable
  @inline(__always)
  func ___ptr_comp_bitmap(_ __l: _NodePtr, _ __r: _NodePtr) -> Bool {
    ___ptr_bitmap(__l) < ___ptr_bitmap(__r)
  }
}
