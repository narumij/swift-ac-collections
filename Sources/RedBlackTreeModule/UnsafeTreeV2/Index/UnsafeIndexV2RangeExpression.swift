//
//  UnsafeIndexV2RangeExpression.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/20.
//

@frozen
public struct UnsafeIndexV2RangeExpression<Base>: UnsafeTreeProtocol,
  UnsafeIndexingProtocol
where Base: ___TreeBase & ___TreeIndex {

  public typealias Tree = UnsafeTreeV2<Base>
  public typealias Pointee = Tree.Pointee

  @usableFromInline
  typealias _Value = Tree._Value

  @usableFromInline
  internal var rawRange: UnsafeTreeRangeExpression

  @usableFromInline
  internal var tied: _TiedRawBuffer

  // MARK: -

  @inlinable
  @inline(__always)
  internal init(rawValue: UnsafeTreeRangeExpression, tie: _TiedRawBuffer) {
    self.rawRange = rawValue
    self.tied = tie
  }
}

extension UnsafeIndexV2RangeExpression: Sequence {

  public typealias Iterator = UnsafeIterator.IndexObverse<Base>

  public func makeIterator() -> Iterator {
    let (lower, upper) = tied.rawRange(rawRange)!
    return .init(start: lower, end: upper, tie: tied)
  }
}

extension UnsafeIndexV2RangeExpression {

  @inlinable
  @inline(__always)
  public func isTriviallyIdentical(to other: Self) -> Bool {
    tied === other.tied && rawRange == other.rawRange
  }
}

// MARK: - Range Expression

@inlinable
@inline(__always)
public func ..< <Base>(lhs: UnsafeIndexV2<Base>, rhs: UnsafeIndexV2<Base>)
  -> UnsafeIndexV2RangeExpression<Base>
{
  guard lhs.tied === rhs.tied else {
    fatalError(.treeMissmatch)
  }

  return .init(rawValue: lhs.rawValue..<rhs.rawValue, tie: lhs.tied)
}

#if !COMPATIBLE_ATCODER_2025
  @inlinable
  @inline(__always)
  public func ... <Base>(lhs: UnsafeIndexV2<Base>, rhs: UnsafeIndexV2<Base>)
    -> UnsafeIndexV2RangeExpression<Base>
  {
    guard lhs.tied === rhs.tied else {
      fatalError(.treeMissmatch)
    }
    guard !rhs.isEnd else {
      fatalError(.invalidIndex)
    }
    return .init(rawValue: lhs.rawValue...rhs.rawValue, tie: lhs.tied)
  }

  @inlinable
  @inline(__always)
  public prefix func ..< <Base>(rhs: UnsafeIndexV2<Base>) -> UnsafeIndexV2RangeExpression<Base> {
    return .init(rawValue: ..<rhs.rawValue, tie: rhs.tied)
  }

  @inlinable
  @inline(__always)
  public prefix func ... <Base>(rhs: UnsafeIndexV2<Base>) -> UnsafeIndexV2RangeExpression<Base> {
    guard !rhs.isEnd else {
      fatalError(.invalidIndex)
    }
    return .init(rawValue: ...rhs.rawValue, tie: rhs.tied)
  }

  @inlinable
  @inline(__always)
  public postfix func ... <Base>(lhs: UnsafeIndexV2<Base>) -> UnsafeIndexV2RangeExpression<Base> {
    return .init(rawValue: lhs.rawValue..., tie: lhs.tied)
  }
#endif

// MARK: -

#if !COMPATIBLE_ATCODER_2025
extension RedBlackTreeSet {
  
  @inlinable
  public func isValid(_ bounds: UnboundedRange) -> Bool {
    _isValid(.unboundedRange) // 常にtrueな気がする
  }
  
  @inlinable
  public func isValid(_ bounds: UnsafeIndexV2RangeExpression<Self>) -> Bool {
    _isValid(bounds.rawRange)
  }
  
  @inlinable
  public subscript(bounds: UnboundedRange) -> SubSequence {
    ___subscript(.unboundedRange)
  }
  
  @inlinable
  public subscript(bounds: UnsafeIndexV2RangeExpression<Self>) -> SubSequence {
    ___subscript(bounds.rawRange)
  }
  
  @inlinable
  public mutating func removeSubrange(_ bounds: UnboundedRange) {
    __tree_._ensureUnique()
    ___remove(.unboundedRange)
  }
  
  @inlinable
  public mutating func removeSubrange(_ bounds: UnsafeIndexV2RangeExpression<Self>) {
    __tree_._ensureUnique()
    ___remove(bounds.rawRange)
  }
}
#endif

extension RedBlackTreeSet {
  
  @inlinable
  public func ___subscript(_ rawRange: UnsafeTreeRangeExpression) -> SubSequence {
    let (l, u) = __tree_.rawRange(rawRange)
    return .init(tree: __tree_, start: l, end: u)
  }
}

extension UnsafeTreeV2 {
  
  @inlinable
  func rawRange(_ range: UnsafeTreeRangeExpression) -> (lower: _NodePtr, upper: _NodePtr) {
    range.rawRange(_begin: __begin_node_, _end: __end_node)
  }
}
