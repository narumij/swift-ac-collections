//
//  TrackingTagRangeExpression.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/29.
//

public enum TrackingTag: Equatable {
  case end
  case tag(_TrackingTag)
}

#if DEBUG
  extension TrackingTag: ExpressibleByIntegerLiteral {

    public init(integerLiteral value: _TrackingTag) {
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

  extension TrackingTag: RawRepresentable {

    public init?(rawValue value: _TrackingTag) {
      switch value {
      case .end:
        self = .end
      case 0...:
        self = .tag(value)
      default:
        break
      }
      return nil
    }

    public var rawValue: _TrackingTag {
      switch self {
      case .end:
        .end
      case .tag(let _TrackingTag):
        _TrackingTag
      }
    }
  }
#endif

func test() {

  func hoge(_: TrackingTag?) {
    fatalError()
  }

  func hoge(_: TrackingTagRangeExpression) {
    fatalError()
  }

  hoge(nil)
  
  #if DEBUG
    hoge(1..<(.end))
  #endif
}

// これはfor文では使えない
public enum TrackingTagRangeExpression: Equatable {
  public typealias Bound = TrackingTag
  /// `a..<b` のこと
  case range(from: TrackingTag, to: TrackingTag)
  /// `a...b` のこと
  case closedRange(from: TrackingTag, through: TrackingTag)
  /// `..<b` のこと
  case partialRangeTo(TrackingTag)
  /// `...b` のこと
  case partialRangeThrough(TrackingTag)
  /// `a...` のこと
  case partialRangeFrom(TrackingTag)
  /// `...` のこと
  case unboundedRange
}

// 標準Rangeと名前衝突する可能性が高いが、対策してもどこかに残りそう
public func ..< (lhs: TrackingTag, rhs: TrackingTag)
  -> TrackingTagRangeExpression
{
  .range(from: lhs, to: rhs)
}

public func ... (lhs: TrackingTag, rhs: TrackingTag)
  -> TrackingTagRangeExpression
{
  .closedRange(from: lhs, through: rhs)
}

public prefix func ..< (rhs: TrackingTag)
  -> TrackingTagRangeExpression
{
  .partialRangeTo(rhs)
}

public prefix func ... (rhs: TrackingTag)
  -> TrackingTagRangeExpression
{
  .partialRangeThrough(rhs)
}

public postfix func ... (lhs: TrackingTag)
  -> TrackingTagRangeExpression
{
  .partialRangeFrom(lhs)
}
