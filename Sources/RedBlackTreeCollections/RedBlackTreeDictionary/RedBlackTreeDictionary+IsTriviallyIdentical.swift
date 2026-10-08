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

// MARK: - Is Identical To

extension RedBlackTreeDictionary {

  /// Returns a Boolean value indicating whether this dictionary is identical to
  /// `other`.
  ///
  /// Two dictionary values are identical if there is no way to distinguish between
  /// them.
  ///
  /// For any values `a`, `b`, and `c`:
  ///
  /// - `a.isTriviallyIdentical(to: a)` is always `true`. (Reflexivity)
  /// - `a.isTriviallyIdentical(to: b)` implies `b.isTriviallyIdentical(to: a)`. (Symmetry)
  /// - If `a.isTriviallyIdentical(to: b)` and `b.isTriviallyIdentical(to: c)` are both `true`,
  ///   then `a.isTriviallyIdentical(to: c)` is also `true`. (Transitivity)
  /// - `a.isTriviallyIdentical(to: b)` implies `a == b`.
  ///   The reverse implication doesn't necessarily hold.
  ///
  /// Values produced by copying the same value, with no intervening mutations,
  /// will compare identical:
  ///
  /// ```swift
  /// let d = c
  /// print(c.isTriviallyIdentical(to: d))
  /// // Prints true
  /// ```
  ///
  /// Comparing dictionaries this way includes comparing (normally) hidden
  /// implementation details such as the memory location of any underlying dictionary
  /// storage object. Therefore, identical dictionaries are guaranteed to compare equal
  /// with `==`, but not all equal dictionaries are considered identical.
  ///
  /// - Parameter other: The dictionary to compare with this dictionary.
  /// - Returns: `true` if both values share the same underlying storage;
  ///   otherwise, `false`.
  /// - Performance: O(1)
  @inlinable
  public func isTriviallyIdentical(to other: Self) -> Bool {
    __tree_.isIdentical(to: other.__tree_)
  }
}
