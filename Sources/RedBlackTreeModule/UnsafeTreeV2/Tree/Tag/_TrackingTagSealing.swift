//
//  TagSeal_.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/05.
//

// 一度削除したが、情報欠落でデグレになったので、復活

// タグをsalt付きに移行する場合、タグの生成は木だけが行うよう準備する必要がある
// 競プロ用としてはsaltなしでいい。一般用として必要かどうかの判断となっていく

public typealias _SealedTag = Result<_TrackingTagSealing, SealError>

/// トラッキング番号解決の補助データ構造
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
}

extension _TrackingTagSealing: CustomStringConvertible {
  
  public var description: String {
    switch self {
    case .end:
      "_TrackingTagSealing.end"
    case .tag(let raw, let seal):
      "_TrackingTagSealing.tag\((raw: raw, seal: seal))"
    }
  }
}

extension _TrackingTagSealing: CustomDebugStringConvertible {
  
  public var debugDescription: String { description }
}
