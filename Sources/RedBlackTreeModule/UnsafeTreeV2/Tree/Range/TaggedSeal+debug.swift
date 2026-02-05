//
//  TaggedSeal+debug.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/05.
//

#if DEBUG
  extension Result where Success == TagSeal_, Failure == SealError {

    public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

    @usableFromInline
    package var _rawTag: _RawTrackingTag {
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

    package static func unsafe<Base>(tree: UnsafeTreeV2<Base>, rawTag: _RawTrackingTag) -> Self {
      if rawTag == .nullptr {
        return .failure(.null)
      }
      if rawTag == .end {
        return .success(.end)
      }
      return .success(.tag(raw: rawTag, seal: 0))
    }

  }
#endif
