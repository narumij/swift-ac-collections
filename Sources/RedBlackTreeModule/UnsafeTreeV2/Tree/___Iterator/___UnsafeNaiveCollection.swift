//
//  ___UnsafeNodePointerCollection.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/16.
//

@usableFromInline
struct ___UnsafeNaiveCollection:
  UnsafeTreeNodeProtocol,
  Sequence,
  Collection
{
  @usableFromInline
  internal init(nullptr: _NodePtr, start: _NodePtr, end: _NodePtr) {
    self.nullptr = nullptr
    self.startIndex = start
    self.endIndex = end
  }
  
  public typealias Index = _NodePtr
  
  @usableFromInline let nullptr: _NodePtr
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
  func makeIterator() -> ___UnsafeNaiveIterator {
    .init(nullptr: nullptr,
          __first: startIndex,
          __last: endIndex)
  }
}
