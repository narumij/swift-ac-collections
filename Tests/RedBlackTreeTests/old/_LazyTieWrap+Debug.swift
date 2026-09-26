//
//  _LazyTieWrap.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/06/07.
//

#if DEBUG
  @testable import RedBlackTreeCollections

  extension Result where Success == _LazyTieWrap<_NodePtrSealing>, Failure == SealError {

    @inlinable
    package var value: _TrackingTag {
      (try? map(\.rawValue.pointer.trackingTag).get()) ?? .nullptr
    }
  }
#endif
