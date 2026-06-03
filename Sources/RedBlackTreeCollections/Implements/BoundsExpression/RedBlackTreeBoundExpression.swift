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

public typealias RedBlackTreeBoundExpression = RedBlackTreeBoundExpressionV2

// TODO: 以下を公開にするかどうかは要再検討

/// Represents the first element.
///
/// If no such element exists, it is substituted with the past-the-end element.
///
/// - Complexity: O(1)
///   (when evaluated)
public func start<K>() -> RedBlackTreeBoundExpression<K> {
  .start
}

/// Represents the last element.
///
/// If no such element exists, it is substituted with the past-the-end element.
///
/// - Complexity: O(1)
///   (when evaluated)
public func last<K>() -> RedBlackTreeBoundExpression<K> {
  .last
}

/// Represents the past-the-end element.
///
/// - Complexity: O(1)
///   (when evaluated)
public func end<K>() -> RedBlackTreeBoundExpression<K> {
  .end
}

/// Represents the first element that is not less than the given value.
///
/// If no such element exists, it is substituted with the past-the-end element.
///
/// - Complexity: O(log `count`)
///   (when evaluated)
public func lowerBound<K>(_ k: K) -> RedBlackTreeBoundExpression<K> {
  .lowerBound(k)
}

/// Represents the first element that is greater than the given value.
///
/// If no such element exists, it is substituted with the past-the-end element.
///
/// - Complexity: O(log `count`)
///   (when evaluated)
public func upperBound<K>(_ k: K) -> RedBlackTreeBoundExpression<K> {
  .upperBound(k)
}

/// Represents the element equal to the given value.
///
/// If no such element exists, it is substituted with the past-the-end element.
///
/// - Complexity: O(log `count`)
///   (when evaluated)
public func find<K>(_ k: K) -> RedBlackTreeBoundExpression<K> {
  .find(k)
}

// 一時的にオマージュ

public func lt<K>(_ k: K) -> RedBlackTreeBoundExpression<K> {
  .lessThan(k)
}

public func gt<K>(_ k: K) -> RedBlackTreeBoundExpression<K> {
  .greaterThan(k)
}

public func le<K>(_ k: K) -> RedBlackTreeBoundExpression<K> {
  .lessThanOrEqual(k)
}

public func ge<K>(_ k: K) -> RedBlackTreeBoundExpression<K> {
  .greaterThanOrEqual(k)
}
