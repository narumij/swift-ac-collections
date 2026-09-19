//
//  unsafe_node+debug.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/06/01.
//
#if DEBUG
  @testable import RedBlackTreeCollections

  extension UnsafeMutablePointer where Pointee == UnsafeNode {
    package var index: _TrackingTag { trackingTag }
  }
#endif
