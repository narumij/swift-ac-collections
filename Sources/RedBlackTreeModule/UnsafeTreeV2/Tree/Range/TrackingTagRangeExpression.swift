//
//  TrackingTagRangeExpression.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/29.
//

public enum TrackingTag_: Equatable {
  case end
  case tag(raw: _RawTrackingTag, seal: UnsafeNode.Seal)
}

#if DEBUG
  //  extension TrackingTag_: ExpressibleByIntegerLiteral {
  //
  //    public init(integerLiteral value: _RawTrackingTag) {
  //      switch value {
  //      case .end:
  //        self = .end
  //      case 0...:
  //        self = .tag(value)
  //      default:
  //        fatalError(.invalidIndex)
  //      }
  //    }
  //  }

  extension TrackingTag_ {

    @usableFromInline
    package var trackingTag: RedBlackTreeTrackingTag {
      self
    }
  }
#endif

extension TrackingTag_: RawRepresentable {

  @inlinable
  public init?(rawValue value: (raw: _RawTrackingTag, seal: UnsafeNode.Seal)) {
    switch value {
    case (.end, _):
      self = .end
    case (0..., _):
      self = .tag(raw: value.raw, seal: value.seal)
    default:
      return nil
    }
  }

  @inlinable
  public var rawValue: (raw: _RawTrackingTag, seal: UnsafeNode.Seal) {
    switch self {
    case .end:
      (.end, 0)
    case .tag(let _TrackingTag, let gen):
      (_TrackingTag, gen)
    }
  }
}

public typealias RedBlackTreeTrackingTag = TrackingTag_?

extension Optional where Wrapped == TrackingTag_ {

  @available(*, deprecated, renamed: "create", message: "封印不全になるので、deprecated")
  @inlinable
  static func create(_ t: _RawTrackingTag) -> Self {
    fatalError("DEPRECATED")
  }

  // タグをsalt付きに移行する場合、タグの生成は木だけが行うよう準備する必要がある
  
  @inlinable
  static func create(_ t: UnsafeMutablePointer<UnsafeNode>?) -> Self {
    t.flatMap { TrackingTag_(rawValue: ($0.trackingTag, $0.pointee.___recycle_count)) }
  }

  @inlinable
  static func create(_ t: _NodePtrSealing?) -> Self {
    t.flatMap { TrackingTag_(rawValue: ($0.trackingTag, $0.gen)) }
  }

  @inlinable @inline(__always)
  func relative<Base>(to __tree_: UnsafeTreeV2<Base>) -> SafePtr
  where Base: ___TreeBase {
    __tree_[self]
  }
}

#if DEBUG
  extension Optional where Wrapped == TrackingTag_ {

    public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

    @usableFromInline
    internal var trackingTag: RedBlackTreeTrackingTag {
      self
    }

    internal static func unsafe<Base>(tree: UnsafeTreeV2<Base>, rawTag: _RawTrackingTag) -> Self {
      if rawTag == .nullptr {
        return nil
      }
      if rawTag == .end {
        return .end
      }
      return .create((try! tree[rawTag].get()))
    }
  }
#endif

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

extension TrackingTagRangeExpression {

  @inlinable @inline(__always)
  func relative<Base>(to __tree_: UnsafeTreeV2<Base>)
    -> UnsafeTreeSafeRangeExpression
  where
    Base: ___TreeBase
  {
    switch self {

    case .range(let from, let to):
      return .range(
        from: from.relative(to: __tree_),
        to: to.relative(to: __tree_))

    case .closedRange(let from, let through):
      return .closedRange(
        from: from.relative(to: __tree_),
        through: through.relative(to: __tree_))

    case .partialRangeTo(let to):
      return .partialRangeTo(to.relative(to: __tree_))

    case .partialRangeThrough(let through):
      return .partialRangeThrough(through.relative(to: __tree_))

    case .partialRangeFrom(let from):
      return .partialRangeFrom(from.relative(to: __tree_))

    case .unboundedRange:
      return .unboundedRange
    }
  }

  @usableFromInline
  func relative<Base>(to __tree_: UnsafeTreeV2<Base>)
    -> (
      UnsafeMutablePointer<UnsafeNode>,
      UnsafeMutablePointer<UnsafeNode>
    )
  where
    Base: ___TreeBase
  {
    unwrapLowerUpper(
      relative(to: __tree_)
        .relative(to: __tree_))
      ?? (__tree_.__end_node, __tree_.__end_node)
  }
}
