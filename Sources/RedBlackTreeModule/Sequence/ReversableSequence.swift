//
//  ReversableSequence.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/05/30.
//

public protocol ReversableSequence {
  associatedtype ReversedIterator: IteratorProtocol
  func makeReversedIterator() -> ReversedIterator
}

