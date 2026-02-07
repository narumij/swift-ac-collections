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

@frozen
public indirect enum RedBlackTreeBoundExpression<_Key> {
  /// - Complexity: O(1)
  /// ただし評価時の計算量
  case start
  /// - Complexity: O(log `count`)
  /// ただし評価時の計算量
  case lower(_Key)
  /// - Complexity: O(log `count`)
  /// ただし評価時の計算量
  case upper(_Key)
  /// - Complexity: O(log `count`)
  /// ただし評価時の計算量
  case find(_Key)
  /// - Complexity: O(1)
  /// ただし評価時の計算量
  case end
  /// - Complexity: O(`by`)
  /// ただし評価時の計算量
  case advanced(Self, by: Int, limit: Self? = nil)
  /// - Complexity: O(1)
  /// ただし評価時の計算量
  case before(Self)
  /// - Complexity: O(1)
  /// ただし評価時の計算量
  case after(Self)
  
  // TODO: last追加の検討
}

extension RedBlackTreeBoundExpression {
  /// - Complexity: O(1)
  /// ただし評価時の計算量
  public var after: Self { .after(self) }
  /// - Complexity: O(1)
  /// ただし評価時の計算量
  public var before: Self { .before(self) }
  /// - Complexity: O(`offset`)
  /// ただし評価時の計算量
  public func advanced(by offset: Int, limit: Self? = nil) -> Self {
    .advanced(self, by: offset, limit: limit)
  }
}

// TODO: 以下を公開にするかどうかは要再検討

/// - Complexity: O(1)
/// ただし評価時の計算量
public func start<K>() -> RedBlackTreeBoundExpression<K> {
  .start
}

/// - Complexity: O(1)
/// ただし評価時の計算量
public func end<K>() -> RedBlackTreeBoundExpression<K> {
  .end
}

/// - Complexity: O(log `count`)
/// ただし評価時の計算量
public func lowerBound<K>(_ k: K) -> RedBlackTreeBoundExpression<K> {
  .lower(k)
}

/// - Complexity: O(log `count`)
/// ただし評価時の計算量
public func upperBound<K>(_ k: K) -> RedBlackTreeBoundExpression<K> {
  .upper(k)
}

/// - Complexity: O(log `count`)
/// ただし評価時の計算量
public func find<K>(_ k: K) -> RedBlackTreeBoundExpression<K> {
  .find(k)
}
