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

// MARK: - ExpressibleByArrayLiteral

extension RedBlackTreeDictionary: ExpressibleByArrayLiteral {

  /// Creates a dictionary from a literal in the form `[("key", value), ...]`.
  ///
  /// - Important: If duplicate keys are present,
  ///   a **runtime error** occurs, just like `Dictionary(uniqueKeysWithValues:)`.
  ///   (If you want to allow duplicates and merge them, use `merge` / `merging`.)
  ///
  /// Example:
  /// ```swift
  /// let d: RedBlackTreeDictionary = [("a", 1), ("b", 2)]
  /// ```
  @inlinable
  public init(arrayLiteral elements: (Key, Value)...) {
    self.init(uniqueKeysWithValues: elements)
  }
}
