//
//  UnsafeIndexV2RangeExpression.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/20.
//

@frozen
public struct UnsafeIndexV2RangeExpression<Base>: UnsafeTreeProtocol,
  UnsafeImmutableIndexingProtocol
where Base: ___TreeBase & ___TreeIndex {

  public typealias Tree = UnsafeTreeV2<Base>
  public typealias Pointee = Tree.Pointee

  @usableFromInline
  typealias _Value = Tree._Value

  @usableFromInline
  internal let __tree_: ImmutableTree

  @usableFromInline
  internal var rawValue: UnsafeTreeRangeExpression

  @usableFromInline
  internal var tied: _TiedRawBuffer

  // MARK: -

  @inlinable
  @inline(__always)
  internal init(tree: Tree, rawValue: UnsafeTreeRangeExpression) {
    self.rawValue = rawValue
    self.tied = tree.tied
    self.__tree_ = .init(__tree_: tree)
  }

  @inlinable
  @inline(__always)
  internal init(
    __tree_: ImmutableTree,
    rawValue: UnsafeTreeRangeExpression,
    tie: _TiedRawBuffer
  ) {
    self.__tree_ = __tree_
    self.rawValue = rawValue
    self.tied = tie
  }
}

extension UnsafeIndexV2RangeExpression: Sequence {

  public typealias Iterator = UnsafeIterator.IndexObverse<Base>

  public func makeIterator() -> Iterator {
    let (lower, upper) = tied.rawRange(rawValue)!
    return .init(__tree_: __tree_, start: lower, end: upper, tie: tied)
  }
}

// MARK: - Range Expression

@inlinable
@inline(__always)
public func ..< <Base>(lhs: UnsafeIndexV2<Base>, rhs: UnsafeIndexV2<Base>)
  -> UnsafeIndexV2RangeExpression<Base>
{
  guard lhs.__tree_.isTriviallyIdentical(to: rhs.__tree_) else {
    fatalError(.treeMissmatch)
  }

  return .init(
    __tree_: lhs.__tree_, rawValue: lhs.rawValue..<rhs.rawValue, tie: lhs.tied)
}

#if !COMPATIBLE_ATCODER_2025
  @inlinable
  @inline(__always)
  public func ... <Base>(lhs: UnsafeIndexV2<Base>, rhs: UnsafeIndexV2<Base>)
    -> UnsafeIndexV2RangeExpression<Base>
  {
    guard lhs.__tree_.isTriviallyIdentical(to: rhs.__tree_) else {
      fatalError(.treeMissmatch)
    }
    guard let rhs = rhs.next else {
      fatalError(.invalidIndex)
    }
    return .init(
      __tree_: lhs.__tree_, rawValue: lhs.rawValue...rhs.rawValue, tie: lhs.tied)
  }

  @inlinable
  @inline(__always)
  public prefix func ..< <Base>(rhs: UnsafeIndexV2<Base>) -> UnsafeIndexV2RangeExpression<Base> {
    return .init(
      __tree_: rhs.__tree_,
      rawValue: ..<rhs.rawValue,
      tie: rhs.tied)
  }

  @inlinable
  @inline(__always)
  public prefix func ... <Base>(rhs: UnsafeIndexV2<Base>) -> UnsafeIndexV2RangeExpression<Base> {
    guard let rhs = rhs.next else {
      fatalError(.invalidIndex)
    }
    return .init(
      __tree_: rhs.__tree_,
      rawValue: ...rhs.rawValue,
      tie: rhs.tied)
  }

  @inlinable
  @inline(__always)
  public postfix func ... <Base>(lhs: UnsafeIndexV2<Base>) -> UnsafeIndexV2RangeExpression<Base> {
    return .init(
      __tree_: lhs.__tree_,
      rawValue: lhs.rawValue...,
      tie: lhs.tied)
  }
#endif
