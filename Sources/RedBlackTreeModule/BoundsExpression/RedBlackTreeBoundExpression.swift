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

/// 要素の位置を表す内部DSL
///
/// 各API利用時に評価され、該当要素に置き換えられ、処理が行われる。
/// 末尾の次や失敗がどのように扱われるかは各APIによる。
///
/// ---
///
/// ## Cases
///
/// - `start` : 先頭の要素
/// - `last` : 末尾の要素
/// - `end` : 末尾の次の要素
/// - `lower(_:)` : 与えられた値以上の最初の要素
/// - `upper(_:)` : 与えられた値より大きい最初の要素
/// - `find(_:)` : 与えられた値と一致する要素
/// - `advanced(_:offset:limit:)` : 基準位置から `offset` 進めた要素
/// - `before(_:)` : 直前の要素
/// - `after(_:)` : 直後の要素
///
public indirect enum RedBlackTreeBoundExpression<_Key> {
  /// 先頭の要素を表す
  ///
  /// 該当する要素がない場合、末尾の次の要素で代替される
  ///
  /// - Complexity: O(1)
  /// ただし評価時の計算量
  case start
  /// 末尾の要素を表す
  ///
  /// 該当する要素がない場合、末尾の次の要素で代替される
  ///
  /// - Complexity: O(log `count`)
  /// ただし評価時の計算量
  case last
  /// 末尾の次の要素を表す
  ///
  /// - Complexity: O(1)
  /// ただし評価時の計算量
  case end
  /// 与えられた値より小さくない最初の要素を表す
  ///
  /// 該当する要素がない場合、末尾の次の要素で代替される
  ///
  /// - Complexity: O(log `count`)
  /// ただし評価時の計算量
  case lower(_Key)
  /// 与えられた値よりも大きい最初の要素を表す
  ///
  /// 該当する要素がない場合、末尾の次の要素で代替される
  ///
  /// - Complexity: O(log `count`)
  /// ただし評価時の計算量
  case upper(_Key)
  /// 与えられた値と一致する要素を表す
  ///
  /// 該当する要素がない場合、末尾の次の要素で代替される
  ///
  /// - Complexity: O(log `count`)
  /// ただし評価時の計算量
  case find(_Key)
  /// `offset`分進めた要素を表す
  ///
  /// 先頭及び末尾の次を越えた場合、失敗となる
  ///
  /// - Complexity: O(`by`)
  /// ただし評価時の計算量
  case advanced(Self, offset: Int, limit: Self? = nil)
  /// 直前の要素を表す
  ///
  /// 先頭及び末尾の次を越えた場合、失敗となる
  ///
  /// - Complexity: O(1)
  /// ただし評価時の計算量
  case before(Self)
  /// 直後の要素を表す
  ///
  /// 先頭及び末尾の次を越えた場合、失敗となる
  ///
  /// - Complexity: O(1)
  /// ただし評価時の計算量
  case after(Self)

  // TODO: greaterThen,lessThan,等の検討
  // こちらの実現は簡単そう
  // greaterThanとupperは同じ
  /// 与えられた値より小さい要素のうち最大のものを表す
  case lessThan(_Key)  // TODO: コーナーケース検討
  /// 与えられた値より大きい要素のうち最小のものを表す
  case greaterThan(_Key)

  // TODO: greaterThenOrEqual,lessThenOrEqual,等の検討
  // こちらはやや難しめ
  /// 与えられた値以下の要素のうち最大のものを表す
  case lessThanOrEqual(_Key)  // TODO: コーナーケース検討
  /// 与えられた値以上の要素のうち最小のものを表す
  case greaterThanOrEqual(_Key)

  #if DEBUG
    case debug(SealError)
  #endif
}

extension RedBlackTreeBoundExpression {
  /// 直前の要素を得る
  ///
  /// 先頭及び末尾の次を越えた場合、失敗となる
  ///
  /// - Complexity: O(1)
  /// ただし評価時の計算量
  public var before: Self { .before(self) }
  /// 直後の要素を得る
  ///
  /// 先頭及び末尾の次を越えた場合、失敗となる
  ///
  /// - Complexity: O(1)
  /// ただし評価時の計算量
  public var after: Self { .after(self) }
  /// `offset`分進めた要素を得る
  ///
  /// 先頭及び末尾の次を越えた場合、失敗となる
  ///
  /// - Complexity: O(`offset`)
  /// ただし評価時の計算量
  public func advanced(by offset: Int, limit: Self? = nil) -> Self {
    .advanced(self, offset: offset, limit: limit)
  }
}

// TODO: 以下を公開にするかどうかは要再検討

/// 先頭の要素を表す
///
/// 該当する要素がない場合、末尾の次の要素で代替される
///
/// - Complexity: O(1)
/// ただし評価時の計算量
public func start<K>() -> RedBlackTreeBoundExpression<K> {
  .start
}

/// 末尾の要素を表す
///
/// 該当する要素がない場合、末尾の次の要素で代替される
///
/// - Complexity: O(1)
/// ただし評価時の計算量
public func last<K>() -> RedBlackTreeBoundExpression<K> {
  .last
}

/// 末尾の次の要素を表す
///
/// - Complexity: O(1)
/// ただし評価時の計算量
public func end<K>() -> RedBlackTreeBoundExpression<K> {
  .end
}

/// 与えられた値より小さくない最初の要素を表す
///
/// 該当する要素がない場合、末尾の次の要素で代替される
///
/// - Complexity: O(log `count`)
/// ただし評価時の計算量
public func lowerBound<K>(_ k: K) -> RedBlackTreeBoundExpression<K> {
  .lower(k)
}

/// 与えられた値よりも大きい最初の要素を表す
///
/// 該当する要素がない場合、末尾の次の要素で代替される
///
/// - Complexity: O(log `count`)
/// ただし評価時の計算量
public func upperBound<K>(_ k: K) -> RedBlackTreeBoundExpression<K> {
  .upper(k)
}

/// 与えられた値と一致する要素を表す
///
/// 該当する要素がない場合、末尾の次の要素で代替される
///
/// - Complexity: O(log `count`)
/// ただし評価時の計算量
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
