//
//  ___UnsafeMultiRemoveAwareIterator.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/16.
//

// この方式は指定末尾を削除されると木の末尾まで突き抜けてしまう欠点がある
// 削除を検知してboundで回復し続ける方法がとれそう

// ポインタは解放チェック用
// 値は回復操作用
enum Bound<_NodePtr, _Value> {
  // 範囲の左側。回復方法はupper_bound
  // multで連続する値の中間や右側を消すと、値が異なる右を指すことになる。いまいち
  case lower(_NodePtr, _Value)
  // 範囲の右側。回復方法はlower_bound
  // multで連続する値の中間や右側を消すと、値が異なる左を指すことになる。いまいち
  case upper(_NodePtr, _Value)
}

enum ___WrappedKey<_Key: Comparable> {
  // 値Tをもつ
  case value(_Key)
  // endなため値を持たない
  case end
}

extension ___WrappedKey: Comparable {
  static func < (__l: ___WrappedKey<_Key>, __r: ___WrappedKey<_Key>) -> Bool {
    switch (__l, __r) {
    // endのほうが大きい
    case (.end, _): false
    // endのほうが大きい
    case (_, .end): true
    // どちらでもない場合、値で決まる
    case (.value(let _l), .value(let _r)): _l < _r
    }
  }
}

// ___WrappedKeyのアイデアは面白いが、ここまでケアするほうが異常な気がした。
// 不正なポインタによるメモリ破壊やメモリエラーだけはしっかりとトラップすることに主眼を置いた方がいいのでは？

// TODO: 解放チェックと回復を検討する

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
    p.pointee.isGarbaged
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
    assert(!isGarbaged(__current.0))
    let __r = __current.0
    self.__current = naiveNext().map {
      assert($0.pointee.___needs_deinitialize)
      return ($0, __get_value($0))
    }
    return __r
  }

}
