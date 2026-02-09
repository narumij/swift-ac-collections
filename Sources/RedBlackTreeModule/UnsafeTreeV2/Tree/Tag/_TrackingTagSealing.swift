//
//  TagSeal_.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/05.
//

@frozen
public enum _TrackingTagSealing: Equatable {
  case end
  case tag(raw: _TrackingTag, seal: UnsafeNode.Seal)
}

extension _TrackingTagSealing {

  @inlinable
  static func seal(raw: _TrackingTag, seal: UnsafeNode.Seal) -> Self {
    switch raw {
    case .end: return .end
    case 0...: return .tag(raw: raw, seal: seal)
    default:
      fatalError(.invalidIndex)
    }
  }

  @inlinable
  static func sealOrNil(raw: _TrackingTag, seal: UnsafeNode.Seal) -> Self? {
    switch raw {
    case 0...: return .tag(raw: raw, seal: seal)
    default: return nil
    }
  }

  @inlinable
  static func seal(_ p: UnsafeMutablePointer<UnsafeNode>) -> Self {
    .seal(raw: p.pointee.___tracking_tag, seal: p.pointee.___recycle_count)
  }

  @inlinable
  static func sealOrNil(_ p: UnsafeMutablePointer<UnsafeNode>) -> Self? {
    .sealOrNil(raw: p.pointee.___tracking_tag, seal: p.pointee.___recycle_count)
  }
}

extension _TrackingTagSealing: CustomStringConvertible {
  public var description: String {
    switch self {
    case .end:
      "_TrackingTagSealing.end"
    case .tag(raw: let raw, seal: let seal):
      "_TrackingTagSealing.tag\((raw: raw, seal: seal))"
    }
  }
}

extension _TrackingTagSealing: CustomDebugStringConvertible {
  public var debugDescription: String { description }
}
