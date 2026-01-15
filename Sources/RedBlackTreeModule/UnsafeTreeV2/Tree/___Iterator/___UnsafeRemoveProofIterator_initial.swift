//
//  ___UnsafeMultiRemoveAwareIterator.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/16.
//

// この方式は指定末尾を削除されると木の末尾まで突き抜けてしまう欠点がある
struct ___UnsafeRemoveProofIterator_initial<Base: ___TreeBase>: UnsafeTreeNodeProtocol,
  BoundAlgorithmProtocol_common, ValueComparator, IteratorProtocol, Sequence
{

  func value_util(_ p: _NodePtr) -> Base._Value {
    UnsafePair<Base._Value>.valuePointer(p).pointee
  }

  func __get_value(_ p: _NodePtr) -> Base._Key {
    Base.__key(value_util(p))
  }

  var __root: UnsafeMutablePointer<UnsafeNode> {
    __left_(__end_node)
  }

  typealias __node_value_type = Base._Key

  var end: UnsafeMutablePointer<UnsafeNode> {
    __end_node
  }

  typealias _Key = Base._Key

  @usableFromInline
  let nullptr: _NodePtr
  var __first: _NodePtr
  let __last: _NodePtr
  let __end_node: _NodePtr
  var __current: (_NodePtr, Base._Key)?

  @usableFromInline
  mutating func naiveNext() -> _NodePtr? {
    guard __first != __last else { return nil }
    let __r = __first
    __first = __tree_next_iter(__first)
    return __r
  }
  
  func isGarbaged(_ p: _NodePtr) -> Bool {
    p.pointee.___needs_deinitialize == false
  }

  mutating func recoverIfNeeds() {
    
    guard let __current, isGarbaged(__current.0) else { return }
    
    let ub = __upper_bound_multi(__current.1, __root, __end_node)
    self.__first = ub == __last || ub == __end_node ? __end_node : ub
    self.__current = __first == __end_node ? nil : (__first, __get_value(__first))
  }

  @usableFromInline
  mutating func next() -> _NodePtr? {
    recoverIfNeeds()
    guard let __current else { return nil }
    assert(__current.0.pointee.___needs_deinitialize)
    let __r = __current.0
    self.__current = naiveNext().map {
      assert($0.pointee.___needs_deinitialize)
      return ($0, __get_value($0))
    }
    return __r
  }

}
