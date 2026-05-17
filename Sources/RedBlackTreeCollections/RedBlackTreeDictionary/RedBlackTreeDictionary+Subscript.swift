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

extension RedBlackTreeDictionary {

  /// - Complexity: O(log *n*)
  @inlinable
  public subscript(key: Key) -> Value? {

    @inline(__always) _read {
      yield __tree_[key]
    }

    @inline(__always) _modify {
      yield &__tree_[key]
    }
  }

  /// - Complexity: O(log *n*)
  @inlinable
  public subscript(
    key: Key, default defaultValue: @autoclosure () -> Value
  ) -> Value {
    
    get {
      __tree_[key] ?? defaultValue()
    }
    
    @inline(__always)
    @_transparent
    unsafeMutableAddress {
      
      __tree_.ensureUnique()
      
      let (__parent, __child) = __tree_.__find_equal(key)
      
      if __child.pointee.___is_null {
        __tree_.ensureCapacity()
        assert(__tree_.capacity > __tree_.count)
        __tree_.update {
          let __h = $0.__construct_node(Base.__payload_((key, defaultValue())))
          $0.__insert_node_at(__parent, __child, __h)
        }
      }
      
      return Base.__mapped_value_ptr(__child)
    }
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionary {

    /// Accesses the element at the specified position.
    ///
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public subscript(position: Index) -> Element {
      Base.__element_(__tree_[_unsafe: position])
    }
  }
#endif
