//
//  UnsafeIndexV3Range.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/15.
//

@frozen
public struct UnsafeIndexV3Range: _UnsafeNodePtrType {

  public var lowerBound: _TieWrappedPtr {
    range.lowerBound
  }

  public var upperBound: _TieWrappedPtr {
    range.upperBound
  }

  @inlinable
  @inline(__always)
  internal init(lowerBound: _TieWrappedPtr, upperBound: _TieWrappedPtr) {
    precondition(lowerBound.tied === upperBound.tied)
    self.range = .init(lowerBound: lowerBound, upperBound: upperBound)
  }

  @usableFromInline
  internal var range: _RawRange<_TieWrappedPtr>

  @inlinable
  @inline(__always)
  internal init(_ range: _RawRange<_TieWrappedPtr>) {
    self.range = range
  }
}
