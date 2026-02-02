//
//  unsafe_node+pointer+sealing.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/02.
//

@frozen
public struct _NodePtrSealing: Equatable {
  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
  @usableFromInline var pointer: _NodePtr
  @usableFromInline var gen: UnsafeNode.Seal
  @inlinable
  @inline(__always)
  init(_ p: _NodePtr) {
    pointer = p
    gen = p.pointee.___recycle_count
  }
  @inlinable
  @inline(__always)
  var isUnsealed: Bool {
    pointer.___is_garbaged || pointer.pointee.___recycle_count != gen
  }
  @inlinable
  var pointee: UnsafeNode {
    _read { yield pointer.pointee }
    _modify {
      guard !isUnsealed else {
        fatalError(.invalidIndex)
      }
      yield &pointer.pointee
    }
  }
  @inlinable
  @inline(__always)
  var trackingTag: Int {
    pointer.pointee.___tracking_tag
  }
  @inlinable
  @inline(__always)
  var ___is_null: Bool {
    pointer.___is_null
  }
  @inlinable
  @inline(__always)
  var ___is_null_or_end: Bool {
    pointer.___is_null_or_end
  }
  @inlinable
  @inline(__always)
  var ___is_end: Bool {
    pointer.___is_end
  }
  @inlinable
  @inline(__always)
  var ___is_garbaged: Bool {
    pointer.___is_garbaged
  }
}

