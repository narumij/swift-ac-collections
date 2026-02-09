//
//  TaggedSeal+debug.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/05.
//

#if DEBUG
  extension _TrackingTagSealing {

    @usableFromInline
    internal var raw: _TrackingTag {
      switch self {
      case .end: .end
      case .tag(raw: let rag, seal: _): rag
      }
    }
  }
#endif

#if DEBUG
  extension _TrackingTagSealing: RawRepresentable {

    @inlinable
    public init?(rawValue value: (raw: _TrackingTag, seal: UnsafeNode.Seal)) {
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
    public var rawValue: (raw: _TrackingTag, seal: UnsafeNode.Seal) {
      switch self {
      case .end:
        (.end, 0)
      case .tag(let _TrackingTag, let gen):
        (_TrackingTag, gen)
      }
    }
  }
#endif

#if DEBUG
  extension _TrackingTagSealing {

    @inlinable
    var __is_null_or_end: Bool? {
      switch self {
      case .end: nil
      case .tag(raw: let r, seal: _): ___is_null_or_end(r)
      }
    }

    @inlinable
    var __is_null: Bool? {
      switch self {
      case .end: nil
      case .tag(raw: let r, seal: _): r == .nullptr
      }
    }

    @inlinable
    var __is_end: Bool? {
      switch self {
      case .end: nil
      case .tag(raw: let r, seal: _): r == .end
      }
    }
  }
#endif
