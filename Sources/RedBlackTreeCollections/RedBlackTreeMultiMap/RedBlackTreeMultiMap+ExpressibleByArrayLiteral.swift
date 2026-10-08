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

// MARK: - ExpressibleByArrayLiteral

extension RedBlackTreeMultiMap: ExpressibleByArrayLiteral {

  #if COMPATIBLE_ATCODER_2025
    /// Creates a multimap from an array literal, retaining pairs with duplicate keys.
    ///
    /// - Parameter elements: The key-value pairs of the literal.
    /// - Complexity: O(*n* log *n*), where *n* is the number of literal pairs.
    @inlinable
    public init(arrayLiteral elements: (Key, Value)...) {
      self.init(multiKeysWithValues: elements)
    }
  #else
    /// Creates a multimap from an array literal, retaining pairs with duplicate keys.
    ///
    /// - Parameter elements: The key-value pairs of the literal.
    /// - Complexity: O(*n* log *n*), where *n* is the number of literal pairs.
    @inlinable
    public init(arrayLiteral elements: (Key, Value)...) {
      self.init(keysWithValues: elements)
    }
  #endif
}
