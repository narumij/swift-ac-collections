//
//  ReverseSequence.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/05/30.
//

public
struct ReversedSequence<Base: ReversableSequence>: Sequence {
  
  @usableFromInline
  let _base: Base

  @inlinable
  @inline(__always)
  internal init(base: Base) {
    _base = base
  }

  @inlinable
  public func makeIterator() -> Base.ReversedIterator {
    _base.makeReversedIterator()
  }
}
