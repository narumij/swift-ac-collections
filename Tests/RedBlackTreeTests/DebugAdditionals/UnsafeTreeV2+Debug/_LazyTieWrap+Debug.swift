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
    package static func == (lhs: Self, rhs: Self) -> Bool {
      switch (lhs, rhs) {
      case (.success(let lhs), .success(let rhs)):
        return lhs == rhs
      case (.failure(let lhs), .failure(let rhs)):
        return lhs == rhs
      default:
        return false
      }
    }

    @inlinable
    package static func != (lhs: Self, rhs: Self) -> Bool {
      !(lhs == rhs)
    }
  }

  extension Result where Success == _LazyTieWrap<_NodePtrSealing>, Failure == SealError {

    @inlinable
    package var value: _TrackingTag {
      (try? map(\.rawValue.pointer.trackingTag).get()) ?? .nullptr
    }
  }

  extension _LazyTieWrap where RawValue == _NodePtrSealing {
    
    @inlinable
    package var value: _TrackingTag {
      rawValue.pointer.trackingTag
    }
  }
#endif
