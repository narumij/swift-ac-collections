//
//  ___UnsafeRemoveCheckWrapper.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/16.
//

#if false
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
#else
  @usableFromInline
  struct ___UnsafeRemoveCheckWrapper<Source: IteratorProtocol>:
    UnsafeTreePointer,
    IteratorProtocol,
    Sequence
  where
    Source.Element == UnsafeMutablePointer<UnsafeNode>
  {
    var __current: Source.Element?
    var naive: Source
    @usableFromInline
    internal init(iterator: Source) {
      var it = iterator
      self.__current = it.next()
      self.naive = it
    }
    @usableFromInline
    mutating func next() -> _NodePtr? {
      guard let __current else { return nil }
      guard !__current.pointee.isGarbaged else {
        fatalError(.invalidIndex)
      }
      self.__current = naive.next()
      return __current
    }
  }
#endif

#if swift(>=5.5)
  extension ___UnsafeRemoveCheckWrapper: @unchecked Sendable
  where Source: Sendable {}
#endif
