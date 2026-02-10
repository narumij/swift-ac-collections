//
//  UnsafeTreeBound.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/10.
//

//
// unchecked用のBoundExpressionの下地
// キー値比較だけで保証できる範囲を取り扱う
//
// つまり最速でループ処理が出来る処理パスを作りたい
//
public enum UnsafeTreeBoundExpression<_Key: Comparable> {
  case start
  case lower(_Key)
  case upper(_Key)
  case end
}

extension UnsafeTreeBoundExpression: Comparable {
  
  public static func < (lhs: UnsafeTreeBoundExpression<_Key>, rhs: UnsafeTreeBoundExpression<_Key>) -> Bool
  {
    switch (lhs, rhs) {
    case (start, _): true
    case (end, _): false
    case (lower(let l), lower(let r)): l < r
    case (lower(let l), upper(let r)): l <= r
    case (upper(let l), upper(let r)): l < r
    case (upper, _): false // 不明だが、false扱い
    default: false
    }
  }
}

public enum UnsafeTreeBoundRangeExpression<_Key: Comparable>: Equatable {
  
  public typealias Bound = UnsafeTreeBoundExpression<_Key>
  /// `a..<b` のこと
  case range(from: Bound, to: Bound)
  /// `a...b` のこと
  case closedRange(from: Bound, through: Bound)
  /// `..<b` のこと
  case partialRangeTo(Bound)
  /// `...b` のこと
  case partialRangeThrough(Bound)
  /// `a...` のこと
  case partialRangeFrom(Bound)
}

public func ..< <K>(lhs: UnsafeTreeBoundExpression<K>, rhs: UnsafeTreeBoundExpression<K>)
  -> UnsafeTreeBoundRangeExpression<K>
where K: Comparable
{
  .range(from: lhs, to: rhs)
}

public func ... <K>(lhs: UnsafeTreeBoundExpression<K>, rhs: UnsafeTreeBoundExpression<K>)
  -> UnsafeTreeBoundRangeExpression<K>
where K: Comparable
{
  .closedRange(from: lhs, through: rhs)
}

public prefix func ..< <K>(rhs: UnsafeTreeBoundExpression<K>)
  -> UnsafeTreeBoundRangeExpression<K>
where K: Comparable
{
  .partialRangeTo(rhs)
}

public prefix func ... <K>(rhs: UnsafeTreeBoundExpression<K>)
  -> UnsafeTreeBoundRangeExpression<K>
where K: Comparable
{
  .partialRangeThrough(rhs)
}

public postfix func ... <K>(lhs: UnsafeTreeBoundExpression<K>)
  -> UnsafeTreeBoundRangeExpression<K>
where K: Comparable
{
  .partialRangeFrom(lhs)
}
