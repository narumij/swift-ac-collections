//
//  _RawRange.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/15.
//

@frozen
public struct _RawRange<Bound> {

  @usableFromInline
  internal var lowerBound: Bound

  @usableFromInline
  internal var upperBound: Bound

  @inlinable
  @inline(__always)
  internal init(lowerBound: Bound, upperBound: Bound) {
    self.lowerBound = lowerBound
    self.upperBound = upperBound
  }
}
