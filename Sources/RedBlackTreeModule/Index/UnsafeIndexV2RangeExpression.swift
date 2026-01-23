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
  guard lhs.tied === rhs.tied else { fatalError(.treeMissmatch) }
  return .init(rawValue: lhs.rawValue..<rhs.rawValue, tie: lhs.tied)
}

#if !COMPATIBLE_ATCODER_2025
  @inlinable
  @inline(__always)
  public func ... <Base>(lhs: UnsafeIndexV2<Base>, rhs: UnsafeIndexV2<Base>)
    -> UnsafeIndexV2RangeExpression<Base>
  {
    guard lhs.tied === rhs.tied else { fatalError(.treeMissmatch) }
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
    return .init(rawValue: ...rhs.rawValue, tie: rhs.tied)
  }

  @inlinable
  @inline(__always)
  public postfix func ... <Base>(lhs: UnsafeIndexV2<Base>) -> UnsafeIndexV2RangeExpression<Base> {
    return .init(rawValue: lhs.rawValue..., tie: lhs.tied)
  }
#endif

// MARK: -

