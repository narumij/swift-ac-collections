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
// プロトコルのthunk削減を意図し、なるべく隔離している
#if !compiler(<6.3)
  @frozen
  @usableFromInline
  struct _KeyOnly_FindEqual<_Key: Comparable> {

    @inlinable @inline(__always)
    internal init(header: UnsafeMutablePointer<UnsafeTreeV2BufferHeader>) {
      self.header = header
    }

    public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
    public typealias _NodeRef = UnsafeMutablePointer<_NodePtr>

    @usableFromInline let header: UnsafeMutablePointer<UnsafeTreeV2BufferHeader>
  }

  extension _KeyOnly_FindEqual {

    @specialized(where _Key == Int)
    @inlinable
    @inline(__always)
    func __comp(_ __lhs: _Key, _ __rhs: _Key) -> __int_compare_result {
      if __lhs < __rhs {
        -1
      } else if __lhs > __rhs {
        1
      } else {
        0
      }
    }
  }

  extension _KeyOnly_FindEqual {

    @specialized(where _Key == Int)
    @inlinable
    internal func
      __find_equal(_ __v: _Key) -> (__parent: _NodePtr, __child: _NodeRef)
    {
      let nullptr = header.pointee.nullptr
      let __root_ptr = header.pointee.root_ptr

      var __nd = __root_ptr.pointee

      if __nd == nullptr {
        return (header.pointee.end_ptr, __root_ptr)
      }

      var __nd_ptr = __root_ptr
      
      while true {

        let __comp_res = __comp(__v, __nd.__value_().pointee)

        if __comp_res < 0 {

          if __nd.__left_ == nullptr {
            return (__nd, __nd.__left_ref)
          }

          __nd_ptr = __nd.__left_ref
          __nd = __nd.__left_

        } else if __comp_res > 0 {

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
#endif
