//
//  TagSeal_.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/05.
//

public enum TagSeal_: Equatable {
  case end
  case tag(raw: _RawTrackingTag, seal: UnsafeNode.Seal)
}

#if DEBUG
  extension TagSeal_ {

    @usableFromInline
    internal var _rawTag: _RawTrackingTag {
      switch self {
      case .end: .end
      case .tag(raw: let rag, seal: _): rag
      }
    }
  }
#endif

extension TagSeal_ {

  @inlinable
  static func seal(raw: _RawTrackingTag, seal: UnsafeNode.Seal) -> Self {
    switch raw {
    case .end: return .end
    case 0...: return .tag(raw: raw, seal: seal)
    default:
      fatalError(.invalidIndex)
    }
  }
  
  @inlinable
  static func sealOrNil(raw: _RawTrackingTag, seal: UnsafeNode.Seal) -> Self? {
    switch raw {
    case 0...: return .tag(raw: raw, seal: seal)
    default: return nil
    }
  }
  
  @inlinable
  static func seal(_ p:  UnsafeMutablePointer<UnsafeNode>) -> Self {
    .seal(raw: p.pointee.___tracking_tag, seal: p.pointee.___recycle_count)
  }
  
  @inlinable
  static func sealOrNil(_ p: UnsafeMutablePointer<UnsafeNode>) -> Self? {
    .sealOrNil(raw: p.pointee.___tracking_tag, seal: p.pointee.___recycle_count)
  }
}

extension TagSeal_: RawRepresentable {

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

extension TagSeal_ {
  @usableFromInline
  var __is_null_or_end: Bool {
    switch self {
    case .end: true
    case .tag(raw: let r, seal: _): ___is_null_or_end(r)
    }
  }
  @usableFromInline
  var __is_null: Bool {
    switch self {
    case .end: true
    case .tag(raw: let r, seal: _): r == .nullptr
    }
  }
  @usableFromInline
  var __is_end: Bool {
    switch self {
    case .end: true
    case .tag(raw: let r, seal: _): r == .end
    }
  }
}
