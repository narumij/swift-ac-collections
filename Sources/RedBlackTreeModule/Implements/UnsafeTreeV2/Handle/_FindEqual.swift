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
struct _FindEqual<_Key: Comparable> {

  @inlinable @inline(__always)
  internal init(
    header: UnsafeMutablePointer<UnsafeTreeV2BufferHeader>,
    _ __v: _Key
  ) {
    self.__root_ptr = header.pointee.root_ptr
    self.__end_node = header.pointee.end_ptr
    self.__v = __v
  }

  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
  public typealias _NodeRef = UnsafeMutablePointer<_NodePtr>

  @usableFromInline let __root_ptr: _NodeRef
  @usableFromInline let __end_node: _NodePtr
  @usableFromInline let __v: _Key
}

extension _FindEqual {

  #if false
    @inlinable
    @inline(__always)
    func __comp(_ __rhs: _Key) -> __int_compare_result {
      __default_three_way_comparator(__lhs, __rhs)
    }
  #else
    @specialized(where _Key == Int)
    @inlinable
    @inline(__always)
    func __comp(_ __rhs: _Key) -> __int_compare_result {
      if __v < __rhs {
        -1
        //  } else if __v > __rhs {
      } else if __rhs < __v {  // thunk Comparable.>を避けている
        1
      } else {
        0
      }
    }
  #endif
}

extension _FindEqual {

  @inlinable
  @inline(__always)
  internal func
    __find_equal() -> (__parent: _NodePtr, __child: _NodeRef)
  {
    var __nd = __root_ptr.pointee
    if __nd.___is_null {
      return (__end_node, __root_ptr)
    }
    var __nd_ptr = __root_ptr

    while true {

      let __comp_res = __comp(__nd.__value_().pointee)

      if __comp_res < 0 {
        
        if __nd.__left_.___is_null {
          return (__nd, __nd.__left_ref)
        }

        __nd_ptr = __nd.__left_ref
        __nd = __nd.__left_
        
      } else if __comp_res > 0 {
        
        if __nd.__right_.___is_null {
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
