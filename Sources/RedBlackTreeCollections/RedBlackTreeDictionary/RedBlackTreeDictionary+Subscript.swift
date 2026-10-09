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

  /// Accesses the value associated with `key`.
  ///
  /// Assigning a non-`nil` value inserts or updates the key. Assigning `nil`
  /// removes the key if it exists and does nothing when the key is absent.
  ///
  /// - Parameter key: The key to find, insert, update, or remove.
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

  /// Accesses the value associated with `key`, returning a default when absent.
  ///
  /// Reading an absent key evaluates and returns `defaultValue` without inserting
  /// it. Mutating through the subscript inserts the default value before mutation.
  ///
  /// - Parameters:
  ///   - key: The key to find or insert.
  ///   - defaultValue: A value to use when `key` is absent.
  /// - Complexity: O(log *n*)
  @inlinable
  public subscript(
    key: Key, default defaultValue: @autoclosure () -> Value
  ) -> Value {

    @inline(__always) get {
      __tree_.lookup(key) ?? defaultValue()
    }

    //    @inline(__always) _modify {
    //      yield &__tree_[key, default: defaultValue]
    //    }

    @inline(__always)
    @_transparent
    unsafeMutableAddress {
      __tree_.mappedValuePtr(for: key, default: defaultValue)
    }
  }
}




  extension RedBlackTreeDictionary {

    /// Accesses the element at the specified position.
    ///
    /// - Complexity: O(1)
    @inlinable
    public subscript(position: Index) -> Element {
      @inline(__always)
      get {
        // unsafeAddress, _read、双方バグるので、基本のget
        __tree_._unsafeAddress(position).pointee.tuple
      }
    }
  }
