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

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap {

    /// - Complexity: O(log *n*)
    @inlinable
    public subscript(key: Key) -> View {
      @inline(__always) get {
        let (lower, upper) = __tree_.__equal_range_multi(key)
        return self[unchecked: .init(lowerBound: lower, upperBound: upper)]
      }
      @inline(__always) _modify {
        let (lower, upper) = __tree_.__equal_range_multi(key)
        yield &self[unchecked: .init(lowerBound: lower, upperBound: upper)]
      }
    }
  }
#endif

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap {

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
