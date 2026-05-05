//
//  _RawRangeExpression.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/14.
//

public enum _RawRangeExpression<Bound> {
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
  /// `...` のこと
  case unboundedRange
}

extension _RawRangeExpression: Equatable where Bound: Equatable {}

extension _RawRangeExpression {

  @inlinable
  func _start<Base>(_ __tree_: UnsafeTreeV2<Base>) -> _SealedPtr {
    __tree_.__begin_node_.sealed
  }

  @inlinable
  func _end<Base>(_ __tree_: UnsafeTreeV2<Base>) -> _SealedPtr {
    __tree_.__end_node.sealed
  }

  @inlinable
  func _start<Base>(_ __tree_: UnsafeTreeV2<Base>) -> _TieWrappedPtr {
    _start(__tree_).band(__tree_.tied)
  }

  @inlinable
  func _end<Base>(_ __tree_: UnsafeTreeV2<Base>) -> _TieWrappedPtr {
    _end(__tree_).band(__tree_.tied)
  }
}

extension _RawRangeExpression where Bound == _SealedPtr {

  @usableFromInline
  func relative<Base>(to __tree_: UnsafeTreeV2<Base>)
    -> _RawRange<_SealedPtr>
  where
    Base: ___TreeBase
  {
    switch self {
    case .range(let lhs, let rhs):
      return .init(
        lowerBound: lhs,
        upperBound: rhs)
    case .closedRange(let lhs, let rhs):
      return .init(
        lowerBound: lhs,
        upperBound: rhs.flatMap { ___tree_next_iter($0.pointer) }.sealed)
    case .partialRangeTo(let rhs):
      return .init(
        lowerBound: _start(__tree_),
        upperBound: rhs)
    case .partialRangeThrough(let rhs):
      return .init(
        lowerBound: _start(__tree_),
        upperBound: rhs.flatMap { ___tree_next_iter($0.pointer) }.sealed)
    case .partialRangeFrom(let lhs):
      return .init(
        lowerBound: lhs,
        upperBound: _end(__tree_))
    case .unboundedRange:
      return .init(
        lowerBound: _start(__tree_),
        upperBound: _end(__tree_))
    }
  }
}

extension _RawRangeExpression where Bound == _TieWrappedPtr {

  @usableFromInline
  func relative<Base>(to __tree_: UnsafeTreeV2<Base>)
    -> _RawRange<_TieWrappedPtr>
  where
    Base: ___TreeBase
  {
    switch self {

    case .range(let lhs, let rhs):
      return .init(
        lowerBound: lhs,
        upperBound: rhs)

    case .closedRange(let lhs, let rhs):
      return .init(
        lowerBound: lhs,
        upperBound:
          rhs
          .flatMap {
            ___tree_next_iter($0.rawValue.pointer)
              .sealed
              .band($0.tied)
          }
      )

    case .partialRangeTo(let rhs):
      return .init(
        lowerBound: _start(__tree_),
        upperBound: rhs)

    case .partialRangeThrough(let rhs):
      return .init(
        lowerBound: _start(__tree_),
        upperBound:
          rhs
          .flatMap {
            ___tree_next_iter($0.rawValue.pointer)
              .sealed
              .band($0.tied)
          }
      )

    case .partialRangeFrom(let lhs):
      return .init(
        lowerBound: lhs,
        upperBound: _end(__tree_))

    case .unboundedRange:
      return .init(
        lowerBound: _start(__tree_),
        upperBound: _end(__tree_))
    }
  }
}

// MARK: - COMPATIBLE_ATCODER_2025用

extension _RawRangeExpression where Bound == _SealedPtr {

  func __start(_ tied: _TiedRawBuffer) -> _SealedPtr {
    tied.begin_ptr.map { $0.pointee.sealed } ?? .failure(.null)
  }

  func __end(_ tied: _TiedRawBuffer) -> _SealedPtr {
    tied.end_ptr.map { $0.sealed } ?? .failure(.null)
  }

  @usableFromInline
  func relative(to tied: _TiedRawBuffer) -> _RawRange<_SealedPtr> {
    guard tied.isValueAccessAllowed else {
      return .init(
        lowerBound: .failure(.notAllowed),
        upperBound: .failure(.notAllowed))
    }
    switch self {
    case .range(let lhs, let rhs):
      return .init(
        lowerBound: lhs,
        upperBound: rhs)
    case .closedRange(let lhs, let rhs):
      return .init(
        lowerBound: lhs,
        upperBound: rhs.flatMap { ___tree_next_iter($0.pointer) }.sealed)
    case .partialRangeTo(let rhs):
      return .init(
        lowerBound: __start(tied),
        upperBound: rhs)
    case .partialRangeThrough(let rhs):
      return .init(
        lowerBound: __start(tied),
        upperBound: rhs.flatMap { ___tree_next_iter($0.pointer) }.sealed)
    case .partialRangeFrom(let lhs):
      return .init(
        lowerBound: lhs,
        upperBound: __end(tied))
    case .unboundedRange:
      return .init(
        lowerBound: __start(tied),
        upperBound: __end(tied))
    }
  }
}
