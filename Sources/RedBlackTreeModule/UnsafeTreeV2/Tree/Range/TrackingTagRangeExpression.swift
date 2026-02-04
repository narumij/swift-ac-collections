//
//  TrackingTagRangeExpression.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/29.
//

public enum TagSeal_: Equatable {
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

  extension TagSeal_ {

    @usableFromInline
    internal var _rawTag: _RawTrackingTag {
      switch self {
      case .end: .end
      case .tag(raw: let rag, seal: _): rag
      }
    }
    
    @usableFromInline
    var check: Bool {
      switch self {
      case .end: true
      case .tag(raw: let r, seal: _): !___is_null_or_end(r)
      }
    }
  }
#endif

extension TagSeal_: RawRepresentable {
  
  @inlinable
  static func create(raw: _RawTrackingTag, seal: UnsafeNode.Seal) -> Self {
    switch raw {
    case .end: return .end
    case 0...: return .tag(raw: raw, seal: seal)
    default:
      fatalError(.invalidIndex)
    }
  }

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

public typealias TaggedSeal = Result<TagSeal_, SafePtrError>

extension Result where Success == TagSeal_, Failure == SafePtrError {
  // タグをsalt付きに移行する場合、タグの生成は木だけが行うよう準備する必要がある
  // 競プロ用としてはsaltなしでいい。一般用として必要かどうかの判断となっていく

  /// 失敗とendを除外する
  @inlinable
  static func create_as_optional(_ t: UnsafeMutablePointer<UnsafeNode>?) -> Result? {
    t.flatMap { TagSeal_(rawValue: ($0.trackingTag, $0.pointee.___recycle_count)) }
      .flatMap {
        switch $0 {
        case .end:
          return nil
        case .tag:
          return .success($0)
        }
      }
  }

  @inlinable
  static func create(_ t: UnsafeMutablePointer<UnsafeNode>?) -> Result {
    t.flatMap { TagSeal_(rawValue: ($0.trackingTag, $0.pointee.___recycle_count)) }
      .map { .success($0) }
      ?? .failure(.null)
  }

  @inlinable
  static func create(_ t: _NodePtrSealing?) -> Result {
    t.flatMap { TagSeal_(rawValue: ($0.pointer.trackingTag, $0.seal)) }
      .map { .success($0) }
      ?? .failure(.null)
  }

  @inlinable @inline(__always)
  func relative<Base>(to __tree_: UnsafeTreeV2<Base>) -> _SealedPtr
  where Base: ___TreeBase {
    __tree_.resolve(self)
  }
}

#if DEBUG
  extension Result where Success == TagSeal_, Failure == SafePtrError {
    
    public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

    @usableFromInline
    internal var _rawTag: _RawTrackingTag {
      guard let tag = try? get() else {
        return .nullptr
      }
      return tag._rawTag
    }

    @usableFromInline
    package var rawValue: (raw: _RawTrackingTag, seal: UnsafeNode.Seal)? {
      guard let tag = try? get() else {
        return nil
      }
      return tag.rawValue
    }

    internal static func unsafe<Base>(tree: UnsafeTreeV2<Base>, rawTag: _RawTrackingTag) -> Self {
      if rawTag == .nullptr {
        return .failure(.null)
      }
      if rawTag == .end {
        return .success(.end)
      }
      return .success(.tag(raw: rawTag, seal: 0))
    }
    
    @usableFromInline
    var check: Bool {
      switch self {
      case .failure: true
      case .success(let t): t.check
      }
    }

  }
#endif

// これはfor文では使えない
public enum TrackingTagRangeExpression: Equatable {
  public typealias Bound = TaggedSeal
  /// `a..<b` のこと
  case range(from: TaggedSeal, to: TaggedSeal)
  /// `a...b` のこと
  case closedRange(from: TaggedSeal, through: TaggedSeal)
  /// `..<b` のこと
  case partialRangeTo(TaggedSeal)
  /// `...b` のこと
  case partialRangeThrough(TaggedSeal)
  /// `a...` のこと
  case partialRangeFrom(TaggedSeal)
  /// `...` のこと
  case unboundedRange
}

public func ..< (lhs: TaggedSeal, rhs: TaggedSeal)
  -> TrackingTagRangeExpression
{
  .range(from: lhs, to: rhs)
}

public func ... (lhs: TaggedSeal, rhs: TaggedSeal)
  -> TrackingTagRangeExpression
{
  .closedRange(from: lhs, through: rhs)
}

public prefix func ..< (rhs: TaggedSeal)
  -> TrackingTagRangeExpression
{
  .partialRangeTo(rhs)
}

public prefix func ... (rhs: TaggedSeal)
  -> TrackingTagRangeExpression
{
  .partialRangeThrough(rhs)
}

public postfix func ... (lhs: TaggedSeal)
  -> TrackingTagRangeExpression
{
  .partialRangeFrom(lhs)
}

extension TrackingTagRangeExpression {

  @inlinable @inline(__always)
  func relative<Base>(to __tree_: UnsafeTreeV2<Base>)
    -> UnsafeTreeSealedRangeExpression
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
  
  @usableFromInline
  func __relative<Base>(to __tree_: UnsafeTreeV2<Base>)
    -> (_SealedPtr, _SealedPtr)
  where
    Base: ___TreeBase
  {
      relative(to: __tree_)
        .relative(to: __tree_)
  }

}
