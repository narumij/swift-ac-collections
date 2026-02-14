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

extension _RawRangeExpression where Bound == _SealedPtr {

  func _start<Base>(_ __tree_: UnsafeTreeV2<Base>) -> _SealedPtr {
    __tree_.__begin_node_.sealed
  }

  func _end<Base>(_ __tree_: UnsafeTreeV2<Base>) -> _SealedPtr {
    __tree_.__end_node.sealed
  }

  @usableFromInline
  func relative<Base>(to __tree_: UnsafeTreeV2<Base>)
    -> (_from: _SealedPtr, _to: _SealedPtr)
  where
    Base: ___TreeBase
  {
    switch self {
    case .range(let lhs, let rhs):
      return (lhs, rhs)
    case .closedRange(let lhs, let rhs):
      return (lhs, rhs.flatMap { ___tree_next_iter($0.pointer) }.sealed)
    case .partialRangeTo(let rhs):
      return (_start(__tree_), rhs)
    case .partialRangeThrough(let rhs):
      return (_start(__tree_), rhs.flatMap { ___tree_next_iter($0.pointer) }.sealed)
    case .partialRangeFrom(let lhs):
      return (lhs, _end(__tree_))
    case .unboundedRange:
      return (_start(__tree_), _end(__tree_))
    }
  }
}

extension _RawRangeExpression where Bound == _SealedPtr {

  func _start(_ tied: _TiedRawBuffer) -> _SealedPtr {
    tied.begin_ptr.map { $0.pointee.sealed } ?? .failure(.null)
  }

  func _end(_ tied: _TiedRawBuffer) -> _SealedPtr {
    tied.end_ptr.map { $0.sealed } ?? .failure(.null)
  }

  @usableFromInline
  func relative(to tied: _TiedRawBuffer) -> (_SealedPtr, _SealedPtr) {
    guard tied.isValueAccessAllowed else {
      return (.failure(.notAllowed), .failure(.notAllowed))
    }
    switch self {
    case .range(let lhs, let rhs):
      return (lhs, rhs)
    case .closedRange(let lhs, let rhs):
      return (lhs, rhs.flatMap { ___tree_next_iter($0.pointer) }.sealed)
    case .partialRangeTo(let rhs):
      return (_start(tied), rhs)
    case .partialRangeThrough(let rhs):
      return (_start(tied), rhs.flatMap { ___tree_next_iter($0.pointer) }.sealed)
    case .partialRangeFrom(let lhs):
      return (lhs, _end(tied))
    case .unboundedRange:
      return (_start(tied), _end(tied))
    }
  }
}
