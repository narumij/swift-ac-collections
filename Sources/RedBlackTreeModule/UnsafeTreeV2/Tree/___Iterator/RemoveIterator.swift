//
//  RemoveIterator.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/19.
//

public struct RemoveIterator:
  _UnsafeNodePtrType,
  RemoveProtocol_ptr,
  EraseProtocol,
  IteratorProtocol,
  Sequence
{
  @usableFromInline
  func destroy(_ p: UnsafeMutablePointer<UnsafeNode>) {
    fatalError()
  }
  
  @usableFromInline
  var __begin_node_: UnsafeMutablePointer<UnsafeNode> {
    get { _begin_node_.pointee }
    nonmutating set { _begin_node_.pointee = newValue }
  }

  @usableFromInline
  var __size_: Int {
    get { _size_.pointee }
    nonmutating set { /* NOP */  }
  }

  @usableFromInline
  var __root: _NodePtr

  let _begin_node_: UnsafeMutablePointer<_NodePtr>
  @usableFromInline
  let __end_node: _NodePtr
  let _size_: UnsafeMutablePointer<Int>
  let _root: UnsafeMutablePointer<_NodePtr>

  @usableFromInline
  internal init(__first: _NodePtr, __last: _NodePtr) {
    self.__first = __first
    self.__current = __first
    self.__last = __last
    fatalError()
  }

  public mutating func next() -> _NodePtr? {
    guard __current != __last else { return nil }
    let __r = __current
    __current = __tree_next_iter(__current)
    return __r
  }

  @usableFromInline
  let __first: _NodePtr
  @usableFromInline
  var __current: _NodePtr
  @usableFromInline
  let __last: _NodePtr
}
