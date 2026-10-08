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

// The following top-level functions provide type-inferred endpoints for range expressions.

/// Represents the first element.
///
/// If no such element exists, it is substituted with the past-the-end element.
///
/// - Complexity: O(1)
///   (when evaluated)
public func start<Key>() -> RedBlackTreeBoundExpression<Key> {
  .start
}

/// Represents the last element.
///
/// If no such element exists, it is substituted with the past-the-end element.
///
/// - Complexity: O(log `count`)
///   (when evaluated)
public func last<Key>() -> RedBlackTreeBoundExpression<Key> {
  .last
}

/// Represents the past-the-end element.
///
/// - Complexity: O(1)
///   (when evaluated)
public func end<Key>() -> RedBlackTreeBoundExpression<Key> {
  .end
}

/// Represents the first element that is not less than the given value.
///
/// If no such element exists, it is substituted with the past-the-end element.
///
/// - Complexity: O(log `count`)
///   (when evaluated)
public func lowerBound<Key>(_ key: Key) -> RedBlackTreeBoundExpression<Key> {
  .lowerBound(key)
}

/// Represents the first element that is greater than the given value.
///
/// If no such element exists, it is substituted with the past-the-end element.
///
/// - Complexity: O(log `count`)
///   (when evaluated)
public func upperBound<Key>(_ key: Key) -> RedBlackTreeBoundExpression<Key> {
  .upperBound(key)
}

/// Represents the element equal to the given value.
///
/// If no such element exists, it is substituted with the past-the-end element.
///
/// - Complexity: O(log `count`)
///   (when evaluated)
public func find<Key>(_ key: Key) -> RedBlackTreeBoundExpression<Key> {
  .find(key)
}
