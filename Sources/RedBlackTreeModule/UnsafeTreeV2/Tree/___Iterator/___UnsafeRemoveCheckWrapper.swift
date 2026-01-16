//
//  ___UnsafeRemoveCheckWrapper.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/16.
//

@usableFromInline
struct ___UnsafeRemoveCheckWrapper<Source: IteratorProtocol>:
  UnsafeTreePointer,
  IteratorProtocol,
  Sequence
where
  Source.Element == UnsafeMutablePointer<UnsafeNode>
{
  var naive: Source
  internal init(iterator: Source) {
    self.naive = iterator
  }
  @usableFromInline
  mutating func next() -> _NodePtr? {
    let n = naive.next()
    guard let n else { return nil }
    guard n.pointee.isGarbaged != true else {
      fatalError(.invalidIndex)
    }
    return n
  }
}
