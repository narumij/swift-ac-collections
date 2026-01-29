//
//  TrackingTagRangeExpression.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/29.
//

public enum TrackingTag_: Equatable {
  case end
  case tag(_RawTrackingTag)
}

#if DEBUG
  extension TrackingTag_: ExpressibleByIntegerLiteral {

    public init(integerLiteral value: _RawTrackingTag) {
      switch value {
      case .end:
        self = .end
      case 0...:
        self = .tag(value)
      default:
        fatalError(.invalidIndex)
      }
    }
  }
#endif

extension TrackingTag_: RawRepresentable {

  public init?(rawValue value: _RawTrackingTag) {
    switch value {
    case .end:
      self = .end
    case 0...:
      self = .tag(value)
    default:
      return nil
    }
  }

  public var rawValue: _RawTrackingTag {
    switch self {
    case .end:
      .end
    case .tag(let _TrackingTag):
      _TrackingTag
    }
  }
}

public typealias RedBlackTreeTrackingTag = Optional<TrackingTag_>

extension Optional where Wrapped == TrackingTag_ {
  
  @usableFromInline
  static func create(_ t: _RawTrackingTag) -> Self {
    TrackingTag_(rawValue: t)
  }

  @usableFromInline
  static func create(_ t: UnsafeMutablePointer<UnsafeNode>?) -> Self {
    (t?.trackingTag).flatMap { TrackingTag_(rawValue: $0) }
  }
  
  @inlinable @inline(__always)
  func relative<Base>(to __tree_: UnsafeTreeV2<Base>) -> UnsafeMutablePointer<UnsafeNode>
  where Base: ___TreeBase {
    switch self {
    case .none:
      return __tree_.nullptr
    case .some(.end):
      return __tree_.__end_node
    case .some(.tag(let raw)):
      return __tree_[_raw: raw]
    }
  }
}

// これはfor文では使えない
public enum TrackingTagRangeExpression: Equatable {
  public typealias Bound = RedBlackTreeTrackingTag
  /// `a..<b` のこと
  case range(from: RedBlackTreeTrackingTag, to: RedBlackTreeTrackingTag)
  /// `a...b` のこと
  case closedRange(from: RedBlackTreeTrackingTag, through: RedBlackTreeTrackingTag)
  /// `..<b` のこと
  case partialRangeTo(RedBlackTreeTrackingTag)
  /// `...b` のこと
  case partialRangeThrough(RedBlackTreeTrackingTag)
  /// `a...` のこと
  case partialRangeFrom(RedBlackTreeTrackingTag)
  /// `...` のこと
  case unboundedRange
}

public func ..< (lhs: RedBlackTreeTrackingTag, rhs: RedBlackTreeTrackingTag)
  -> TrackingTagRangeExpression
{
  .range(from: lhs, to: rhs)
}

public func ... (lhs: RedBlackTreeTrackingTag, rhs: RedBlackTreeTrackingTag)
  -> TrackingTagRangeExpression
{
  .closedRange(from: lhs, through: rhs)
}

public prefix func ..< (rhs: RedBlackTreeTrackingTag)
  -> TrackingTagRangeExpression
{
  .partialRangeTo(rhs)
}

public prefix func ... (rhs: RedBlackTreeTrackingTag)
  -> TrackingTagRangeExpression
{
  .partialRangeThrough(rhs)
}

public postfix func ... (lhs: RedBlackTreeTrackingTag)
  -> TrackingTagRangeExpression
{
  .partialRangeFrom(lhs)
}
