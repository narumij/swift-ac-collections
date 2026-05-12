//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project
//
// Copyright (c) 2024 - 2026 narumij.
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.
//
//===----------------------------------------------------------------------===//

// NOTE: 性能過敏なので修正する場合は必ず計測しながら行うこと
/// SetやMultiset用に特殊化されたハンドル
///
/// `_Key`の取得に関して特殊化済みとなっている。
///
@frozen
@usableFromInline
struct UnsafeTreeV2KeyOnlyHandle2<_Key: Comparable>: _UnsafeNodePtrType {

  @inlinable @inline(__always)
  internal init(
    header: UnsafeMutablePointer<UnsafeTreeV2BufferHeader>,
    isMulti: Bool
  ) {
    self.header = header
    self.nullptr = header.pointee.nullptr
    self.root_ref = header.pointee.root_ptr
    self.isMulti = isMulti
  }

  @usableFromInline typealias _Key = _Key
  @usableFromInline typealias _PayloadValue = _Key
  @usableFromInline typealias _Pointer = _NodePtr

  @usableFromInline let header: UnsafeMutablePointer<UnsafeTreeV2BufferHeader>
  @usableFromInline let nullptr: _NodePtr
  @usableFromInline let root_ref: _NodeRef
  @usableFromInline let isMulti: Bool
}

extension UnsafeTreeV2KeyOnlyHandle2 {

  @inlinable
  @inline(__always)
  func __key(_ __v: _PayloadValue) -> _Key {
    __v
  }

  @inlinable
  func value_comp(_ __l: _Key, _ __r: _Key) -> Bool {
    __l < __r
  }

  @_alwaysEmitIntoClient
  @_transparent
  func __comp(_ __lhs: _Key, _ __rhs: _Key) -> __int_compare_result {
#if false
  __default_three_way_comparator(__lhs, __rhs)
#else
  if __lhs < __rhs {
    -1
  } else if __lhs > __rhs {
    1
  } else {
    0
  }
#endif
  }
}

// MARK: - TreeNodeValueProtocol

extension UnsafeTreeV2KeyOnlyHandle2 {

  @_alwaysEmitIntoClient
  @_transparent
  func __get_value(_ p: _NodePtr) -> _Key {
    p.__value_(as: _PayloadValue.self).pointee
  }
}

extension UnsafeTreeV2KeyOnlyHandle2 {

  @inlinable
  @inline(__always)
  public func __construct_node(_ k: _PayloadValue) -> _NodePtr {
    let p = header.pointee.__construct_raw_node()
    // あえてのdefer
    defer {
      p.__value_().initialize(to: k)
      #if DEBUG
        payloadInitializedCount += 1
      #endif
    }
    return p
  }
}

extension UnsafeTreeV2KeyOnlyHandle2 {

  @inlinable
  var __begin_node_: _NodePtr {
    @inline(__always)
    @_transparent
    unsafeAddress {
      UnsafePointer(header.pointee.begin_ptr)
    }
    @inline(__always)
    @_transparent
    nonmutating unsafeMutableAddress {
      header.pointee.begin_ptr
    }
  }

  @_alwaysEmitIntoClient
  var __root: _NodePtr {
    @inline(__always)
    @_transparent
    unsafeAddress {
      UnsafePointer(root_ref)
    }
  }

  @_alwaysEmitIntoClient
  @_transparent
  func __root_ptr() -> _NodeRef {
    root_ref
  }

  @inlinable
  var end: _NodePtr {
    header.pointee.end_ptr
  }

  @inlinable
  var __end_node: _NodePtr {
    header.pointee.end_ptr
  }

  @inlinable
  func destroy(_ p: _NodePtr) {
    header.pointee.___pushRecycle(p)
  }

  @inlinable
  var __size_: Int {
    get { header.pointee.count }
    nonmutating set { /* NOP */  }
  }
}

extension UnsafeTreeV2KeyOnlyHandle2 {
  @usableFromInline
  typealias __compare_result = __int_compare_result
}

//extension UnsafeTreeV2KeyOnlyHandle2: BoundBothProtocol, BoundAlgorithmProtocol_ptr {}
//extension UnsafeTreeV2KeyOnlyHandle2: FindInteface, FindProtocol_ptr {}
//extension UnsafeTreeV2KeyOnlyHandle2: RemoveInteface, RemoveProtocol_ptr {}
//extension UnsafeTreeV2KeyOnlyHandle2: EraseProtocol {}
//extension UnsafeTreeV2KeyOnlyHandle2: EraseUniqueProtocol {}
//extension UnsafeTreeV2KeyOnlyHandle2: FindEqualInterface, FindEqualProtocol_ptr {}
//extension UnsafeTreeV2KeyOnlyHandle2: InsertNodeAtInterface, InsertNodeAtProtocol_ptr {}
//extension UnsafeTreeV2KeyOnlyHandle2: InsertUniqueInterface, InsertUniqueProtocol_ptr {}
//extension UnsafeTreeV2KeyOnlyHandle2: FindLeafProtocol_ptr, InsertMultiProtocol {}
//extension UnsafeTreeV2KeyOnlyHandle2: CountProtocol_ptr {}

//extension UnsafeTreeV2KeyOnlyHandle2: TreeAlgorithmBaseProtocol_ptr {}
//extension UnsafeTreeV2KeyOnlyHandle2: TreeAlgorithmProtocol_ptr {}

extension UnsafeTreeV2KeyOnlyHandle2 {
  
  @_alwaysEmitIntoClient
  @_transparent
  internal func
    __find_equal(_ __v: _Key) -> (__parent: _NodePtr, __child: _NodeRef)
  {
    var __nd = __root
    if __nd == nullptr {
      // return (__end_node, end.__left_ref)
      return (__end_node, __root_ptr())
    }
    var __nd_ptr = __root_ptr()
    // let __comp = __lazy_synth_three_way_comparator

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
}

extension UnsafeTreeV2KeyOnlyHandle2 {
  
  @_alwaysEmitIntoClient
  @_transparent
  internal func
    __insert_unique(_ x: _PayloadValue) -> (__r: _NodePtr, __inserted: Bool)
  {
    __emplace_unique_key_args(x)
  }

  @_alwaysEmitIntoClient
  @_transparent
  internal func
    __emplace_unique_key_args(_ __k: _PayloadValue)
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
}

extension UnsafeTreeV2KeyOnlyHandle2 {
  
  @_alwaysEmitIntoClient
  @_transparent
  internal func
    __insert_node_at(
      _ __parent: _NodePtr, _ __child: _NodeRef,
      _ __new_node: _NodePtr
    )
  {
    let __new_node = __new_node
    __new_node.__left_ = nullptr
    __new_node.__right_ = nullptr
    __new_node.__parent_ = __parent
    // __new_node->__is_black_ is initialized in __tree_balance_after_insert
    __child.pointee = __new_node
    // unsafe operation not allowed
    if __begin_node_.__left_ != nullptr {
      __begin_node_ = __begin_node_.__left_
    }
    //    _std__tree_balance_after_insert(__end_node.__left_, __child.pointee)
    _std__tree_balance_after_insert(__root, __child.pointee)
    __size_ += 1
  }
}
