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

extension RedBlackTreeDictionary {

  /// - Complexity: O(log *n*)
  @inlinable
  public subscript(key: Key) -> Value? {

    @inline(__always) get {
      __tree_.lookup(key)
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
      __tree_.lookup(key) ?? defaultValue()
    }

    _modify {

      __tree_.ensureUnique()

      let (__parent, __child) = __tree_.__find_equal(key)

      if __child.pointee == __tree_.nullptr {
        __tree_.unsafeEnsureCapacity()
        assert(__tree_.capacity > __tree_.count)
        __tree_.update {
          let __h = $0.__construct_node(Base.__payload_((key, defaultValue())))
          $0.__insert_node_at(__parent, __child, __h)
        }
      }

      yield &Base.__payload_ptr(__child.pointee).pointee.tuple.value
    }
  }
}

#if false
  // 調査用
  extension RedBlackTreeDictionary {

    /// Accesses the element at the specified position.
    ///
    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public subscript(_pair position: Index) -> RedBlackTreePair<Key, Value> {
      __tree_._unsafeAddress(position).pointee
    }

    @inlinable
    @inline(__always)
    public subscript(_element position: Index) -> Element {
      __tree_._unsafeAddress(position).pointee.tuple
    }
  }
#endif

#if !COMPATIBLE_ATCODER_2025 && false
  // やっぱりTupleはバギー
  extension RedBlackTreeDictionary {

    /// Accesses the element at the specified position.
    ///
    /// - Complexity: O(1)
    @inlinable
    public subscript(position: Index) -> Element {
      @inline(__always)
      _read {
        yield __tree_._unsafeAddress(position).pointee.tuple
      }
    }
  }
#endif

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionary {

    /// Accesses the element at the specified position.
    ///
    /// - Complexity: O(1)
    @inlinable
    public subscript(position: Index) -> Element {
      @inline(__always)
      get {
        // unsafeAddress, _read、双方バグるので、基本のget。しくしく
        __tree_._unsafeAddress(position).pointee.tuple
      }
    }
  }
#endif
