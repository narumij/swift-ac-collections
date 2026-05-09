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

/// An internal DSL that represents an element position.
///
/// It is evaluated when each API is used, replaced with the corresponding element, and then the operation is performed.
/// How “past-the-end” and failures are handled depends on the API.
///
/// ---
///
/// ## Cases
///
/// - `start` : The first element
/// - `last` : The last element
/// - `end` : The past-the-end element
/// - `lowerBound(_:)` : The first element that is not less than the given value
/// - `upperBound(_:)` : The first element that is greater than the given value
/// - `find(_:)` : The element equal to the given value
/// - `advanced(_:offset:limit:)` : The element advanced by `offset` from a base position
/// - `before(_:)` : The previous element
/// - `after(_:)` : The next element
public indirect enum RedBlackTreeBoundExpression<_Key> {
    /// Represents the first element.
    ///
    /// If no such element exists, it is substituted with the past-the-end element.
    ///
    /// - Complexity: O(1)
    ///   (when evaluated)
    case start
    /// Represents the last element.
    ///
    /// If no such element exists, it is substituted with the past-the-end element.
    ///
    /// - Complexity: O(log `count`)
    ///   (when evaluated)
    case last
    /// Represents the past-the-end element.
    ///
    /// - Complexity: O(1)
    ///   (when evaluated)
    case end
    /// Represents the first element that is not less than the given value.
    ///
    /// If no such element exists, it is substituted with the past-the-end element.
    ///
    /// - Complexity: O(log `count`)
    ///   (when evaluated)
    case lowerBound(_Key)
    /// Represents the first element that is greater than the given value.
    ///
    /// If no such element exists, it is substituted with the past-the-end element.
    ///
    /// - Complexity: O(log `count`)
    ///   (when evaluated)
    case upperBound(_Key)
    /// Represents the element equal to the given value.
    ///
    /// If no such element exists, it is substituted with the past-the-end element.
    ///
    /// - Complexity: O(log `count`)
    ///   (when evaluated)
    case find(_Key)
    /// Represents the element advanced by `offset`.
    ///
    /// Fails if it goes past the start or past-the-end.
    ///
    /// - Complexity: O(`offset`)
    ///   (when evaluated)
    case advanced(Self, offset: Int, limit: Self? = nil)
    /// Represents the previous element.
    ///
    /// Fails if it goes past the start or past-the-end.
    ///
    /// - Complexity: O(1)
    ///   (when evaluated)
    case before(Self)
    /// Represents the next element.
    ///
    /// Fails if it goes past the start or past-the-end.
    ///
    /// - Complexity: O(1)
    ///   (when evaluated)
    case after(Self)

    // こちらの実現は簡単そう
    // greaterThanとupperは同じ
    /// Represents the greatest element that is less than the given value.
    case lessThan(_Key)
    /// Represents the smallest element that is greater than the given value.
    case greaterThan(_Key)

    // こちらはやや難しめ
    /// Represents the greatest element that is less than or equal to the given value.
    case lessThanOrEqual(_Key)
    /// Represents the smallest element that is greater than or equal to the given value.
    case greaterThanOrEqual(_Key)

    #if DEBUG
        case debug(SealError)
    #endif
}

extension RedBlackTreeBoundExpression {
    /// Returns the previous element.
    ///
    /// Fails if it goes past the start or past-the-end.
    ///
    /// - Complexity: O(1)
    ///   (when evaluated)
    public var before: Self { .before(self) }
    /// Returns the next element.
    ///
    /// Fails if it goes past the start or past-the-end.
    ///
    /// - Complexity: O(1)
    ///   (when evaluated)
    public var after: Self { .after(self) }
    /// Returns the element advanced by `offset`.
    ///
    /// Fails if it goes past the start or past-the-end.
    ///
    /// - Complexity: O(`offset`)
    ///   (when evaluated)
    public func advanced(by offset: Int, limit: Self? = nil) -> Self {
        .advanced(self, offset: offset, limit: limit)
    }
}

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
