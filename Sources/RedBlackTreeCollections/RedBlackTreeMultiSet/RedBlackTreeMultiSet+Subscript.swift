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

#if !COMPATIBLE_ATCODER_2025 && false
  // 追加するか検討
  extension RedBlackTreeMultiSet {

    /// - Complexity: O(log *n*)
    @inlinable
    @inline(__always)
    public subscript(element: Element) -> View {
      @inline(__always) get {
        let (lower, upper) = ___equal_range(element)
        return self[unchecked: .init(lowerBound: lower.sealed, upperBound: upper.sealed)]
      }
      @inline(__always) _modify {
        let (lower, upper) = ___equal_range(element)
        yield &self[unchecked: .init(lowerBound: lower.sealed, upperBound: upper.sealed)]
      }
    }
  }
#endif

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    /// Accesses the element at the specified position.
    ///
    /// - Complexity: O(1)
    @inlinable
    public subscript(position: Index) -> Element {
      @inline(__always)
      @_transparent
      unsafeAddress { __tree_._unsafeAddress(position) }
    }
  }
#endif
