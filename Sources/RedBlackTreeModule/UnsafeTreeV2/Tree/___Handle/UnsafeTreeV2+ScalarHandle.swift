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

/// SetやMultiset用に特殊化されたハンドル
///
/// `_Key`の取得に関して特殊化済みとなっている。
///
/// その他に比較演算の強制キャストによる特殊化も盛り込まれている。
///
@frozen
@usableFromInline
struct UnsafeTreeV2ScalarHandle<_Key: Comparable> {
  @inlinable
  internal init(
    header: UnsafeMutablePointer<UnsafeTreeV2BufferHeader<_Value>>,
    origin: UnsafeMutablePointer<UnsafeTreeV2Origin>,
    specializeMode: SpecializeMode? = nil
  ) {
    self.header = header
    self.origin = origin
    self.isMulti = false
    // 性能上とても重要だが、コンパイラ挙動に合わせての採用でとても場当たり的
    self.specializeMode = specializeMode ?? SpecializeModeHoge<_Key>().specializeMode
  }
  @usableFromInline typealias _Key = _Key
  @usableFromInline typealias _Value = _Key
  @usableFromInline typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
  @usableFromInline typealias _Pointer = _NodePtr
  @usableFromInline typealias _NodeRef = UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>
  @usableFromInline let header: UnsafeMutablePointer<UnsafeTreeV2BufferHeader<_Value>>
  @usableFromInline let origin: UnsafeMutablePointer<UnsafeTreeV2Origin>
  @usableFromInline var isMulti: Bool
  @usableFromInline var specializeMode: SpecializeMode
}

extension UnsafeTreeV2 where _Key == _Value, _Key: Comparable {

  @usableFromInline
  typealias Handle = UnsafeTreeV2ScalarHandle<UnsafeTreeV2<Base>._Value>

  @inlinable
  @inline(__always)
  internal func read<R>(_ body: (Handle) throws -> R) rethrows -> R {
    try _buffer.withUnsafeMutablePointers { header, elements in
      let handle = Handle(header: header, origin: elements)
      return try body(handle)
    }
  }

  @inlinable
  @inline(__always)
  internal func update<R>(_ body: (Handle) throws -> R) rethrows -> R {
    try _buffer.withUnsafeMutablePointers { header, elements in
      let handle = Handle(header: header, origin: elements)
      return try body(handle)
    }
  }
}

extension UnsafeTreeV2ScalarHandle {

  @inlinable
  @inline(__always)
  func __key(_ __v: _Value) -> _Key { __v }

  @inlinable
  @inline(__always)
  func value_comp(_ __l: _Key, _ __r: _Key) -> Bool {
    specializeMode.value_comp(__l, __r)
  }

  @inlinable
  @inline(__always)
  func value_equiv(_ __l: _Key, _ __r: _Key) -> Bool {
    specializeMode.value_equiv(__l, __r)
  }

  @inlinable
  @inline(__always)
  func __lazy_synth_three_way_comparator(_ __lhs: _Key, _ __rhs: _Key) -> __int_compare_result {
    specializeMode.synth_three_way(__lhs, __rhs)
  }

  @inlinable
  @inline(__always)
  func __comp(_ __lhs: _Key, _ __rhs: _Key) -> __int_compare_result {
    specializeMode.synth_three_way(__lhs, __rhs)
  }
}

// MARK: - TreeNodeValueProtocol

extension UnsafeTreeV2ScalarHandle {

  @inlinable
  @inline(__always)
  func __get_value(_ p: _NodePtr) -> _Key {
    p.__value_().pointee
  }
}

extension UnsafeTreeV2ScalarHandle: UnsafeTreeHandleBase {}

extension UnsafeTreeV2ScalarHandle: BoundProtocol, BoundAlgorithmProtocol {}
extension UnsafeTreeV2ScalarHandle: FindProtocol {}
extension UnsafeTreeV2ScalarHandle: FindEqualProtocol {}
//extension UnsafeTreeV2ScalarHandle: FindEqualProtocol {}
extension UnsafeTreeV2ScalarHandle: InsertNodeAtProtocol {

  @inlinable
  @inline(__always)
  internal func
    __insert_node_at(
      _ __parent: _NodePtr, _ __child: _NodeRef,
      _ __new_node: _NodePtr
    )
  {
    var __new_node = __new_node
    __new_node.__left_ = nullptr
    __new_node.__right_ = nullptr
    __new_node.__parent_ = __parent
    // __new_node->__is_black_ is initialized in __tree_balance_after_insert
    __child.pointee = __new_node
    // unsafe operation not allowed
    if __begin_node_.__left_ != nullptr {
      __begin_node_ = __begin_node_.__left_
    }
    _std__tree_balance_after_insert(__end_node.__left_, __child.pointee)
    assert(__tree_invariant(__root), "The tree invariants should hold")
    __size_ += 1
  }
}
extension UnsafeTreeV2ScalarHandle: InsertUniqueProtocol {}
extension UnsafeTreeV2ScalarHandle: RemoveProtocol {}
extension UnsafeTreeV2ScalarHandle: EraseProtocol {}
extension UnsafeTreeV2ScalarHandle: EraseUniqueProtocol {}

#if false
  extension UnsafeTreeV2ScalarHandle: FindEqualProtocol_std {}
#else
  extension UnsafeTreeV2ScalarHandle {

    @inlinable
    internal func
      __find_equal(_ __v: _Key) -> (__parent: _NodePtr, __child: _NodeRef)
    {
      switch specializeMode {
      case .asInt:
        _i__find_equal(__v as! Int)
      case .generic:
        _g__find_equal(__v)
      }
    }
    
    /*
     @usableFromInlineにすると、以下となる

     ; UnsafeTreeV2ScalarHandle._i__find_equal(_:)
     +0x00  ldr                 x1, [x2, #0x10]
     +0x04  ldr                 x10, [x1]
     +0x08  ldr                 x9, [x2]
     +0x0c  cmp                 x10, x9
     +0x10  b.ne                "UnsafeTreeV2ScalarHandle._i__find_equal(_:)+0x2c"
     +0x14  mov                 x0, x1
     +0x18  ret
     +0x1c  ldr                 x10, [x8]
     +0x20  mov                 x1, x8
     +0x24  cmp                 x10, x9
     +0x28  b.eq                "UnsafeTreeV2ScalarHandle._i__find_equal(_:)+0x50"
     +0x2c  mov                 x8, x10
     +0x30  ldr                 x10, [x10, #0x28]
     +0x34  cmp                 x10, x0
     +0x38  b.gt                "UnsafeTreeV2ScalarHandle._i__find_equal(_:)+0x1c"
     +0x3c  b.ge                "UnsafeTreeV2ScalarHandle._i__find_equal(_:)+0x50"
     +0x40  mov                 x1, x8
     +0x44  ldr                 x10, [x1, #0x8]!
     +0x48  cmp                 x10, x9
     +0x4c  b.ne                "UnsafeTreeV2ScalarHandle._i__find_equal(_:)+0x2c"
     +0x50  mov                 x0, x8
     +0x54  ret
     */
    @inlinable
    internal func
      _i__find_equal(_ __v: Int) -> (__parent: _NodePtr, __child: _NodeRef)
    {
      var __nd = __root
      if __nd == nullptr {
        return (__end_node, end.__left_ref)
      }
      var __nd_ptr = __root_ptr()
      let __comp = __default_three_way_comparator as (Int,Int) -> __int_compare_result

      while true {

        let __comp_res = __comp(__v, __nd.__value_(as: Int.self).pointee)

        if __comp_res.__less() {
          if __nd.__left_ == nullptr {
            return (__nd, __nd.__left_ref)
          }

          __nd_ptr = __nd.__left_ref
          __nd = __nd.__left_
        } else if __comp_res.__greater() {
          if __nd.__right_ == nullptr {
            return (__nd, __nd.__right_ref)
          }

          __nd_ptr = __nd.__right_ref
          __nd = __nd.__right_
        } else {
          return (__nd, __nd_ptr)
        }
      }
    }
    
    @inlinable
    internal func
      _g__find_equal(_ __v: _Key) -> (__parent: _NodePtr, __child: _NodeRef)
    {
      var __nd = __root
      if __nd == nullptr {
        return (__end_node, end.__left_ref)
      }
      var __nd_ptr = __root_ptr()
      let __comp = __lazy_synth_three_way_comparator

      while true {

        let __comp_res = __comp(__v, __get_value(__nd))

        if __comp_res.__less() {
          if __nd.__left_ == nullptr {
            return (__nd, __nd.__left_ref)
          }

          __nd_ptr = __nd.__left_ref
          __nd = __nd.__left_
        } else if __comp_res.__greater() {
          if __nd.__right_ == nullptr {
            return (__nd, __nd.__right_ref)
          }

          __nd_ptr = __nd.__right_ref
          __nd = __nd.__right_
        } else {
          return (__nd, __nd_ptr)
        }
      }
    }
    
    @inlinable
//    @inline(__always)
    internal func
      __insert_unique(_ x: _Value) -> (__r: _NodePtr, __inserted: Bool)
    {
      __emplace_unique_key_args(x)
    }

    #if true
      @inlinable
//      @inline(__always)
//    @usableFromInline
      internal func
        __emplace_unique_key_args(_ __k: _Value)
        -> (__r: _NodePtr, __inserted: Bool)
      {
        let (__parent, __child) = __find_equal(__key(__k))
        let __r = __child
        if __child.pointee == nullptr {
          let __h = __construct_node(__k)
          __insert_node_at(__parent, __child, __h)
          return (__h, true)
        } else {
          // __insert_node_atで挿入した場合、__rが破損する
          // 既存コードの後続で使用しているのが実質Ptrなので、そちらを返すよう一旦修正
          // 今回初めて破損したrefを使用したようで既存コードでの破損ref使用は大丈夫そう
          return (__r.pointee, false)
        }
      }
    #else
      @inlinable
      internal func
        __emplace_unique_key_args(_ __k: _Value)
        -> (__r: _NodeRef, __inserted: Bool)
      {
        var __parent = _NodePtr.nullptr
        let __child = __find_equal(&__parent, __key(__k))
        let __r = __child
        var __inserted = false
        if __ref_(__child) == .nullptr {
          let __h = __construct_node(__k)
          __insert_node_at(__parent, __child, __h)
          __inserted = true
        }
        return (__r, __inserted)
      }
    #endif
  }
#endif
