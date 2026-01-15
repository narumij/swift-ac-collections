//
//  ___UnsafeRemoveProofIterator.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/16.
//

@usableFromInline
struct ___UnsafeRemoveProofWrapper<Source: Sequence>:
  UnsafeTreePointer,
  IteratorProtocol,
  Sequence
where
  Source.Element == UnsafeMutablePointer<UnsafeNode>
{
  var naive: AnySequence<_NodePtr>.Iterator
  
  func isGarbaged(_ p: _NodePtr) -> Bool {
    p.pointee.___needs_deinitialize == false
  }
  
  internal init(sequence: Source) {
    // CoW強化で木を全部コピーするよりはマシなので、ポインタを全部コピーしている
    self.naive = AnySequence(sequence.map { $0 }).makeIterator()
  }
  
  @usableFromInline
  mutating func next() -> _NodePtr? {
    while let n = naive.next() {
      guard !isGarbaged(n) else { continue }
      return n
    }
    return nil
  }
}
