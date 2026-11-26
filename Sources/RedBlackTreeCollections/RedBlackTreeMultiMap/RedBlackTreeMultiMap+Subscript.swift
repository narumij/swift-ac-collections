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

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap {

    /// Accesses a mutable view of all mapped values associated with `key`.
    ///
    /// Values appear in their order within the equivalent-key group. Removing
    /// values through the view removes their corresponding key-value pairs.
    ///
    /// - Parameter key: The key whose mapped values to access.
    /// - Complexity: O(log *n*)
    @inlinable
    public subscript(key: Key) -> Values {
      @inline(__always) get {
        let (lower, upper) = __tree_.__equal_range_multi(key)
        return makeValuesView(range: .init(lowerBound: lower, upperBound: upper))
      }
      @inline(__always) _modify {
        let (lower, upper) = __tree_.__equal_range_multi(key)
        var view = makeValuesView(range: .init(lowerBound: lower, upperBound: upper))
        self = Self()
        defer { self = Self(__tree_: view.__tree_) }
        yield &view
      }
    }
  }
#endif

#if !COMPATIBLE_ATCODER_2025 && true
  extension RedBlackTreeMultiMap {

    /// Accesses the element at the specified position.
    ///
    /// - Parameter position: A valid element index of this multimap.
    /// - Precondition: `position` identifies an element in this multimap and isn't `endIndex`.
    ///
    /// - Complexity: O(1) when the index directly references the current storage;
    ///   O(b) when resolving the index by its tracking tag, where b is the number
    ///   of internal storage buckets.
    @inlinable
    public subscript(position: Index) -> Element {
      @inline(__always)
      unsafeAddress {
        Base.__element_ptr(__tree_._unsafeAddress(position))
      }
    }
  }
#endif
