//
//  ___UnsafeNodePointerCollection.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/16.
//

@usableFromInline
struct ___UnsafeNaiveCollection:
  UnsafeTreePointer,
  Sequence,
  Collection
{
  @usableFromInline
  internal init(start: _NodePtr, end: _NodePtr) {
    self.startIndex = start
    self.endIndex = end
  }

  public typealias Index = _NodePtr

  @usableFromInline let startIndex: _NodePtr
  @usableFromInline let endIndex: _NodePtr

  @usableFromInline
  func index(after i: _NodePtr) -> _NodePtr {
    __tree_next(i)
  }

  @usableFromInline
  subscript(position: _NodePtr) -> _NodePtr {
    position
  }

  @usableFromInline
  func makeIterator() -> UnsafeIterator.Obverse {
    .init(
      __first: startIndex,
      __last: endIndex)
  }
}
