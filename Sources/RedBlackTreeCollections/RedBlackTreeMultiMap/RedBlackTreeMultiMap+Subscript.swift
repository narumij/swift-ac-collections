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

//    /// - Complexity: O(log *n*)
//    @inlinable
//    public subscript(key: Key) -> View {
//      @inline(__always) get {
//        let (lower, upper) = __tree_.__equal_range_multi(key)
//        return self[_safeRange: .success(.init(lowerBound: lower, upperBound: upper))]
//      }
//      @inline(__always) _modify {
//        let (lower, upper) = __tree_.__equal_range_multi(key)
//        yield &self[_safeRange: .success(.init(lowerBound: lower, upperBound: upper))]
//      }
//    }

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

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap {

    /// Accesses the element at the specified position.
    ///
    /// - Parameter position: A valid element index of this multimap.
    /// - Precondition: `position` identifies an element in this multimap and isn't `endIndex`.
    /// - Complexity: O(1)
    @inlinable
    public subscript(position: Index) -> Element {
      @inline(__always)
      get {
        // unsafeAddress, _read、双方バグるので、基本のget。しくしく
        // TODO: またいつか試す
        __tree_._unsafeAddress(position).pointee.tuple
      }
    }
  }
#endif
