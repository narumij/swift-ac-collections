#if COMPATIBLE_ATCODER_2025

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
#endif
