// Copyright 2024-2026 narumij
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
// Copyright © 2003-2025 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
  public typealias _NodeRef = UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>

  @inlinable @inline(__always)
  static var nullptr: _NodePtr {
    UnsafeNode.nullptr
  }

  @inlinable
  var __left_: _NodePtr {
    _read { yield pointee.__left_ }
    _modify { yield &pointee.__left_ }
  }

  @inlinable
  var __right_: _NodePtr {
    _read { yield pointee.__right_ }
    _modify { yield &pointee.__right_ }
  }

  @inlinable
  var __parent_: _NodePtr {
    _read { yield pointee.__parent_ }
    _modify { yield &pointee.__parent_ }
  }

  @inlinable
  var __parent_unsafe: _NodePtr {
    _read { yield pointee.__parent_ }
    _modify { yield &pointee.__parent_ }
  }

  @inlinable
  var __set_parent: _NodePtr {
    _read { yield pointee.__parent_ }
    _modify { yield &pointee.__parent_ }
  }

  @inlinable
  var __is_black_: Bool {
    _read { yield pointee.__is_black_ }
    _modify { yield &pointee.__is_black_ }
  }

  @inlinable
  @inline(__always)
  var __left_ref: _NodeRef {
    _ref(to: &pointee.__left_)
  }

  @inlinable
  @inline(__always)
  var __right_ref: _NodeRef {
    _ref(to: &pointee.__right_)
  }
}

//extension UnsafeMutablePointer where Pointee == UnsafeNode {
//  @inlinable @inline(__always)
//  var isGarbaged: Bool { pointee.isGarbaged }
//}

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  func __slow_end() -> _NodePtr {
    var __r = self
    while __r.__parent_ != .nullptr {
      __r = __r.__parent_
    }
    return __r
  }
}

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  @inlinable
  @inline(__always)
  var __raw_value_: UnsafeMutableRawPointer {
    UnsafeMutableRawPointer(advanced(by: 1))
  }

  @inlinable
  @inline(__always)
  func __value_<_Value>() -> UnsafeMutablePointer<_Value> {
    UnsafeMutableRawPointer(advanced(by: 1))
      .assumingMemoryBound(to: _Value.self)
  }

  @inlinable
  @inline(__always)
  package func __value_<_Value>(as t: _Value.Type) -> UnsafeMutablePointer<_Value> {
    UnsafeMutableRawPointer(advanced(by: 1))
      .assumingMemoryBound(to: _Value.self)
  }

  @inlinable
  @inline(__always)
  func __key_ptr<Base: _ScalarValueType>(with t: Base.Type)
    -> UnsafeMutablePointer<Base._Key>
  {
    __value_()
  }

  @inlinable
  @inline(__always)
  func __key_ptr<Base: _KeyValuePairType>(with t: Base.Type)
    -> UnsafeMutablePointer<Base._Key>
  {
    _ref(to: &__value_(as: Base.Pair.self).pointee.key)
  }

  @inlinable
  @inline(__always)
  func __mapped_value_ptr<Base: _KeyValuePairType>(with t: Base.Type)
    -> UnsafeMutablePointer<Base._MappedValue>
  {
    _ref(to: &__value_(as: Base.Pair.self).pointee.value)
  }
}

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  @inlinable
  @inline(__always)
  func _advanced(raw bytes: Int) -> UnsafeMutablePointer {
    UnsafeMutableRawPointer(self)
      .advanced(by: bytes)
      .assumingMemoryBound(to: UnsafeNode.self)
  }

  @inlinable
  @inline(__always)
  func _advanced(with stride: Int, count: Int) -> UnsafeMutablePointer {
    _advanced(raw: (MemoryLayout<UnsafeNode>.stride + stride) * count)
  }

  @inlinable
  @inline(__always)
  func _advanced<_Value>(with t: _Value.Type, count: Int) -> UnsafeMutablePointer {
    _advanced(raw: (MemoryLayout<UnsafeNode>.stride + MemoryLayout<_Value>.stride) * count)
  }
}

@inlinable @inline(__always)
package func _ref<T>(to a: inout T) -> UnsafeMutablePointer<T> {
  withUnsafeMutablePointer(to: &a) { $0 }
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
    while !__p.___is_root, __p.___is_end { // endチェックは余計な気がする
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
    while !__p.___is_root, __p.___is_end { // endチェックは余計な気がする
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
    while !__p.___is_root, __p.___is_end { // endチェックは余計な気がする
      __f &>>= 1
      __f |= (__tree_is_left_child(__p) ? 0 : 1) &<< (UInt.bitWidth &- 1)
      __p = __p.__parent_
    }
    return __f
  }
}

@inlinable
@inline(__always)
func ___ptr_comp_bitmap(_ __l: UnsafeMutablePointer<UnsafeNode>, _ __r: UnsafeMutablePointer<UnsafeNode>) -> Bool {
  // サイズの64bit幅で絶対に使い切れない128bit幅が安心なのでこれを採用
  __l.___ptr_bitmap_128() < __r.___ptr_bitmap_128()
}

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  // ノードの高さを数える
  @inlinable
  @inline(__always)
  internal func ___ptr_height() -> Int {
    assert(!___is_null, "Node shouldn't be null")
    var __h = 0
    var __p = self
    while !__p.___is_root, __p.___is_end { // endチェックは余計な気がする
      __p = __p.__parent_
      __h += 1
    }
    return __h
  }
}

// ノードの大小を比較する
@inlinable
//  @inline(__always)
internal func ___ptr_comp_multi(_ __l: UnsafeMutablePointer<UnsafeNode>, _ __r: UnsafeMutablePointer<UnsafeNode>) -> Bool {
  assert(!__l.___is_null, "Left node shouldn't be null")
  assert(!__r.___is_null, "Right node shouldn't be null")
  guard
    !__l.___is_end,
    !__r.___is_end,
    __l != __r
  else {
    return !__l.___is_end && __r.___is_end
  }
  var (__l, __lh) = (__l, __l.___ptr_height())
  var (__r, __rh) = (__r, __r.___ptr_height())
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
