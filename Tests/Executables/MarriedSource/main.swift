import AcFoundation
import IOUtil



import Foundation

public protocol TreePointer {
  associatedtype _NodePtr: Equatable
  associatedtype _Pointer where _NodePtr == _Pointer
  associatedtype _NodeRef
  var nullptr: _NodePtr { get }
  var end: _NodePtr { get }
}

@usableFromInline
protocol TreeEndNodeProtocol: TreePointer {
  @inlinable func __left_(_: pointer) -> pointer
  @inlinable func __left_unsafe(_ p: pointer) -> pointer
  @inlinable func __left_(_ lhs: pointer, _ rhs: pointer)
}

extension TreeEndNodeProtocol {
  @usableFromInline
  typealias pointer = _Pointer
}

@usableFromInline
protocol TreeNodeProtocol: TreeEndNodeProtocol {
  @inlinable func __right_(_: pointer) -> pointer
  @inlinable func __right_(_ lhs: pointer, _ rhs: pointer)
  @inlinable func __is_black_(_: pointer) -> Bool
  @inlinable func __is_black_(_ lhs: pointer, _ rhs: Bool)
  @inlinable func __parent_(_: pointer) -> pointer
  @inlinable func __parent_(_ lhs: pointer, _ rhs: pointer)
  @inlinable func __parent_unsafe(_: pointer) -> __parent_pointer
}

extension TreeNodeProtocol {
  @usableFromInline
  typealias __parent_pointer = _Pointer
}

@usableFromInline
protocol TreeNodeRefProtocol: TreePointer {
  @inlinable func __left_ref(_: _NodePtr) -> _NodeRef
  @inlinable func __right_ref(_: _NodePtr) -> _NodeRef
  @inlinable func __ptr_(_ rhs: _NodeRef) -> _NodePtr
  @inlinable func __ptr_(_ lhs: _NodeRef, _ rhs: _NodePtr)
}

@usableFromInline
protocol TreeNodeValueProtocol: TreePointer where _Key == __node_value_type {
  associatedtype _Key
  associatedtype __node_value_type
  @inlinable func __get_value(_: _NodePtr) -> __node_value_type
}

@usableFromInline
protocol TreeValueProtocol: TreePointer where _Value == __value_type {
  associatedtype _Value
  associatedtype __value_type
  @inlinable func __value_(_ p: _NodePtr) -> __value_type
}

@usableFromInline
protocol KeyProtocol: TreeNodeValueProtocol, TreeValueProtocol {
  @inlinable func __key(_ e: _Value) -> _Key
}

extension KeyProtocol {

  @inlinable
  @inline(__always)
  internal func __get_value(_ p: _NodePtr) -> __node_value_type {
    __key(__value_(p))
  }
}

@usableFromInline
protocol ValueProtocol: TreeNodeProtocol, TreeNodeValueProtocol {
  @inlinable func value_comp(_: __node_value_type, _: __node_value_type) -> Bool
}

@usableFromInline
protocol BeginNodeProtocol: TreePointer {
  @inlinable var __begin_node_: _NodePtr { get nonmutating set }
}

@usableFromInline
protocol BeginProtocol: BeginNodeProtocol {
  @available(*, deprecated, renamed: "__begin_node_")
  @inlinable func begin() -> _NodePtr
}

extension BeginProtocol {
  @available(*, deprecated, renamed: "__begin_node_")
  @inlinable
  @inline(__always)
  internal func begin() -> _NodePtr { __begin_node_ }
}

@usableFromInline
protocol EndNodeProtocol: TreePointer {
  var __end_node: _NodePtr { get }
}

extension EndNodeProtocol where _NodePtr == Int {
  @inlinable
  @inline(__always)
  internal var __end_node: _NodePtr { .end }
}

@usableFromInline
protocol EndProtocol: EndNodeProtocol {
  @inlinable var end: _NodePtr { get }
}

extension EndProtocol where _NodePtr == Int {
  @inlinable
  @inline(__always)
  internal var end: _NodePtr { .end }
}

@usableFromInline
protocol RootProtocol: TreePointer {
  @inlinable var __root: _NodePtr { get }
}

protocol ___RootProtocol: TreeNodeProtocol & EndProtocol {}

extension ___RootProtocol where _NodePtr == Int {
  @available(*, deprecated, message: "Kept only for the purpose of preventing loss of knowledge")
  internal var __root: _NodePtr { __left_(__end_node) }
}

@usableFromInline
protocol RootPtrProtocol: TreeNodeProtocol & TreeNodeRefProtocol & RootProtocol & EndProtocol {
  @inlinable func __root_ptr() -> _NodeRef
}

extension RootPtrProtocol where _NodePtr == Int {
  @inlinable
  @inline(__always)
  internal func __root_ptr() -> _NodeRef { __left_ref(__end_node) }
}

@usableFromInline
protocol SizeProtocol {
  var __size_: Int { get nonmutating set }
}


@usableFromInline
protocol AllocatorProtocol: TreePointer {
  associatedtype _Value
  func __construct_node(_ k: _Value) -> _NodePtr
  func destroy(_ p: _NodePtr)
}


public protocol ValueComparer {
  associatedtype _Key
  associatedtype _Value
  @inlinable static func __key(_: _Value) -> _Key
  @inlinable static func value_comp(_: _Key, _: _Key) -> Bool

  @inlinable static func value_equiv(_ lhs: _Key, _ rhs: _Key) -> Bool
}

extension ValueComparer {

  @inlinable
  @inline(__always)
  public static func value_equiv(_ lhs: _Key, _ rhs: _Key) -> Bool {
    !value_comp(lhs, rhs) && !value_comp(rhs, lhs)
  }
}

extension ValueComparer where _Key: Comparable {

  @inlinable
  @inline(__always)
  public static func value_comp(_ a: _Key, _ b: _Key) -> Bool {
    a < b
  }
}

extension ValueComparer where _Key: Equatable {

  @inlinable
  @inline(__always)
  public static func value_equiv(_ lhs: _Key, _ rhs: _Key) -> Bool {
    lhs == rhs
  }
}

public protocol ValueComparator {
  associatedtype Base: ValueComparer
  @inlinable static func __key(_ e: Base._Value) -> Base._Key
  @inlinable static func value_comp(_ a: Base._Key, _ b: Base._Key) -> Bool
  @inlinable static func value_equiv(_ lhs: Base._Key, _ rhs: Base._Key) -> Bool
  @inlinable func __key(_ e: Base._Value) -> Base._Key
  @inlinable func value_comp(_ a: Base._Key, _ b: Base._Key) -> Bool
}

extension ValueComparator {

  @inlinable
  @inline(__always)
  public static func __key(_ e: Base._Value) -> Base._Key {
    Base.__key(e)
  }

  @inlinable
  @inline(__always)
  public static func value_comp(_ a: Base._Key, _ b: Base._Key) -> Bool {
    Base.value_comp(a, b)
  }

  @inlinable
  @inline(__always)
  public static func value_equiv(_ lhs: Base._Key, _ rhs: Base._Key) -> Bool {
    Base.value_equiv(lhs, rhs)
  }

  @inlinable
  @inline(__always)
  public func __key(_ e: Base._Value) -> Base._Key {
    Base.__key(e)
  }

  @inlinable
  @inline(__always)
  public func value_comp(_ a: Base._Key, _ b: Base._Key) -> Bool {
    Base.value_comp(a, b)
  }
}

extension ValueComparator {

  @inlinable
  @inline(__always)
  internal static func with_value_equiv<T>(_ f: ((Base._Key, Base._Key) -> Bool) -> T) -> T {
    f(value_equiv)
  }

  @inlinable
  @inline(__always)
  internal static func with_value_comp<T>(_ f: ((Base._Key, Base._Key) -> Bool) -> T) -> T {
    f(value_comp)
  }
}

extension ValueComparator where Base: ThreeWayComparator {

  @inlinable
  @inline(__always)
  internal func
    __lazy_synth_three_way_comparator(_ __lhs: Base._Key, _ __rhs: Base._Key)
    -> Base.__compare_result
  {
    Base.__lazy_synth_three_way_comparator(__lhs, __rhs)
  }
}

import Foundation

extension TreeNodeProtocol {

  @inlinable
  @inline(__always)
  internal func
    __tree_left_rotate(_ __x: _NodePtr)
  {
    assert(__x != nullptr, "node shouldn't be null")
    assert(__right_(__x) != nullptr, "node should have a right child")
    let __y = __right_(__x)
    __right_(__x, __left_unsafe(__y))
    if __right_(__x) != nullptr {
      __parent_(__right_(__x), __x)
    }
    __parent_(__y, __parent_(__x))
    if __tree_is_left_child(__x) {
      __left_(__parent_(__x), __y)
    } else {
      __right_(__parent_(__x), __y)
    }
    __left_(__y, __x)
    __parent_(__x, __y)
  }

  @inlinable
  @inline(__always)
  internal func
    __tree_right_rotate(_ __x: _NodePtr)
  {
    assert(__x != nullptr, "node shouldn't be null")
    assert(__left_(__x) != nullptr, "node should have a left child")
    let __y = __left_unsafe(__x)
    __left_(__x, __right_(__y))
    if __left_unsafe(__x) != nullptr {
      __parent_(__left_unsafe(__x), __x)
    }
    __parent_(__y, __parent_(__x))
    if __tree_is_left_child(__x) {
      __left_(__parent_(__x), __y)
    } else {
      __right_(__parent_(__x), __y)
    }
    __right_(__y, __x)
    __parent_(__x, __y)
  }

  @inlinable
  @inline(__always)
  internal func
    __tree_balance_after_insert(_ __root: _NodePtr, _ __x: _NodePtr)
  {
    assert(__root != nullptr, "Root of the tree shouldn't be null")
    assert(__x != nullptr, "Can't attach null node to a leaf")
    var __x = __x
    __is_black_(__x, __x == __root)
    while __x != __root, !__is_black_(__parent_unsafe(__x)) {
      if __tree_is_left_child(__parent_unsafe(__x)) {
        let __y = __right_(__parent_unsafe(__parent_unsafe(__x)))
        if __y != nullptr, !__is_black_(__y) {
          __x = __parent_unsafe(__x)
          __is_black_(__x, true)
          __x = __parent_unsafe(__x)
          __is_black_(__x, __x == __root)
          __is_black_(__y, true)
        } else {
          if !__tree_is_left_child(__x) {
            __x = __parent_unsafe(__x)
            __tree_left_rotate(__x)
          }
          __x = __parent_unsafe(__x)
          __is_black_(__x, true)
          __x = __parent_unsafe(__x)
          __is_black_(__x, false)
          __tree_right_rotate(__x)
          break
        }
      } else {
        let __y = __left_unsafe(__parent_(__parent_unsafe(__x)))
        if __y != nullptr, !__is_black_(__y) {
          __x = __parent_unsafe(__x)
          __is_black_(__x, true)
          __x = __parent_unsafe(__x)
          __is_black_(__x, __x == __root)
          __is_black_(__y, true)
        } else {
          if __tree_is_left_child(__x) {
            __x = __parent_unsafe(__x)
            __tree_right_rotate(__x)
          }
          __x = __parent_unsafe(__x)
          __is_black_(__x, true)
          __x = __parent_unsafe(__x)
          __is_black_(__x, false)
          __tree_left_rotate(__x)
          break
        }
      }
    }
  }

  @inlinable
  @inline(__always)
  internal func
    __tree_remove(_ __root: _NodePtr, _ __z: _NodePtr)
  {
    assert(__root != nullptr, "Root node should not be null")
    assert(__z != nullptr, "The node to remove should not be null")
    assert(__tree_invariant(__root), "The tree invariants should hold")
    var __root = __root
    let __y = (__left_unsafe(__z) == nullptr || __right_(__z) == nullptr) ? __z : __tree_next(__z)
    var __x = __left_unsafe(__y) != nullptr ? __left_unsafe(__y) : __right_(__y)
    var __w: _NodePtr = nullptr
    if __x != nullptr {
      __parent_(__x, __parent_(__y))
    }
    if __tree_is_left_child(__y) {
      __left_(__parent_(__y), __x)
      if __y != __root {
        __w = __right_(__parent_(__y))
      } else {
        __root = __x
      }  // __w == nullptr
    } else {
      __right_(__parent_(__y), __x)
      __w = __left_unsafe(__parent_(__y))
    }
    let __removed_black = __is_black_(__y)
    if __y != __z {
      __parent_(__y, __parent_(__z))
      if __tree_is_left_child(__z) {
        __left_(__parent_(__y), __y)
      } else {
        __right_(__parent_(__y), __y)
      }
      __left_(__y, __left_unsafe(__z))
      __parent_(__left_unsafe(__y), __y)
      __right_(__y, __right_(__z))
      if __right_(__y) != nullptr {
        __parent_(__right_(__y), __y)
      }
      __is_black_(__y, __is_black_(__z))
      if __root == __z {
        __root = __y
      }
    }
    if __removed_black && __root != nullptr {
      if __x != nullptr {
        __is_black_(__x, true)
      } else {
        while true {
          if !__tree_is_left_child(__w)  // if x is left child
          {
            if !__is_black_(__w) {
              __is_black_(__w, true)
              __is_black_(__parent_(__w), false)
              __tree_left_rotate(__parent_(__w))
              if __root == __left_unsafe(__w) {
                __root = __w
              }
              __w = __right_(__left_unsafe(__w))
            }
            if (__left_unsafe(__w) == nullptr || __is_black_(__left_unsafe(__w)))
              && (__right_(__w) == nullptr || __is_black_(__right_(__w)))
            {
              __is_black_(__w, false)
              __x = __parent_(__w)
              if __x == __root || !__is_black_(__x) {
                __is_black_(__x, true)
                break
              }
              __w =
                __tree_is_left_child(__x) ? __right_(__parent_(__x)) : __left_unsafe(__parent_(__x))
            } else  // __w has a red child
            {
              if __right_(__w) == nullptr || __is_black_(__right_(__w)) {
                __is_black_(__left_unsafe(__w), true)
                __is_black_(__w, false)
                __tree_right_rotate(__w)
                __w = __parent_(__w)
              }
              __is_black_(__w, __is_black_(__parent_(__w)))
              __is_black_(__parent_(__w), true)
              __is_black_(__right_(__w), true)
              __tree_left_rotate(__parent_(__w))
              break
            }
          } else {
            if !__is_black_(__w) {
              __is_black_(__w, true)
              __is_black_(__parent_(__w), false)
              __tree_right_rotate(__parent_(__w))
              if __root == __right_(__w) {
                __root = __w
              }
              __w = __left_unsafe(__right_(__w))
            }
            if (__left_unsafe(__w) == nullptr || __is_black_(__left_unsafe(__w)))
              && (__right_(__w) == nullptr || __is_black_(__right_(__w)))
            {
              __is_black_(__w, false)
              __x = __parent_(__w)
              if !__is_black_(__x) || __x == __root {
                __is_black_(__x, true)
                break
              }
              __w =
                __tree_is_left_child(__x) ? __right_(__parent_(__x)) : __left_unsafe(__parent_(__x))
            } else  // __w has a red child
            {
              if __left_unsafe(__w) == nullptr || __is_black_(__left_unsafe(__w)) {
                __is_black_(__right_(__w), true)
                __is_black_(__w, false)
                __tree_left_rotate(__w)
                __w = __parent_(__w)
              }
              __is_black_(__w, __is_black_(__parent_(__w)))
              __is_black_(__parent_(__w), true)
              __is_black_(__left_unsafe(__w), true)
              __tree_right_rotate(__parent_(__w))
              break
            }
          }
        }
      }
    }
  }
}

import Foundation

extension TreeNodeProtocol {

  @inlinable
  @inline(__always)
  internal func
    __tree_is_left_child(_ __x: _NodePtr) -> Bool
  {
    return __x == __left_(__parent_(__x))
  }

  #if TREE_INVARIANT_CHECKS
    @usableFromInline
    internal func
      __tree_sub_invariant(_ __x: _NodePtr) -> UInt
    {
      if __x == nullptr {
        return 1
      }
      if __left_(__x) != nullptr && __parent_(__left_(__x)) != __x {
        return 0
      }
      if __right_(__x) != nullptr && __parent_(__right_(__x)) != __x {
        return 0
      }
      if __left_(__x) == __right_(__x) && __left_(__x) != nullptr {
        return 0
      }
      if !__is_black_(__x) {
        if __left_(__x) != nullptr && !__is_black_(__left_(__x)) {
          return 0
        }
        if __right_(__x) != nullptr && !__is_black_(__right_(__x)) {
          return 0
        }
      }
      let __h = __tree_sub_invariant(__left_(__x))
      if __h == 0 {
        return 0
      }  // invalid left subtree
      if __h != __tree_sub_invariant(__right_(__x)) {
        return 0
      }  // invalid or different height right subtree
      return __h + (__is_black_(__x) ? 1 : 0)  // return black height of this node
    }

    @usableFromInline
    internal func
      __tree_invariant(_ __root: _NodePtr) -> Bool
    {
      if __root == nullptr {
        return true
      }
      if __parent_(__root) == nullptr {
        return false
      }
      if !__tree_is_left_child(__root) {
        return false
      }
      if !__is_black_(__root) {
        return false
      }
      return __tree_sub_invariant(__root) != 0
    }
  #else
    @inlinable
    @inline(__always)
    internal func __tree_invariant(_ __root: _NodePtr) -> Bool { true }
  #endif

  @inlinable
  @inline(__always)
  internal func
    __tree_min(_ __x: _NodePtr) -> _NodePtr
  {
    assert(__x != nullptr, "Root node shouldn't be null")
    var __x = __x
    while __left_unsafe(__x) != nullptr {
      __x = __left_unsafe(__x)
    }
    return __x
  }

  @inlinable
  @inline(__always)
  internal func
    __tree_max(_ __x: _NodePtr) -> _NodePtr
  {
    assert(__x != nullptr, "Root node shouldn't be null")
    var __x = __x
    while __right_(__x) != nullptr {
      __x = __right_(__x)
    }
    return __x
  }

  @inlinable
  @inline(__always)
  internal func
    __tree_next(_ __x: _NodePtr) -> _NodePtr
  {
    assert(__x != nullptr, "node shouldn't be null")
    var __x = __x
    if __right_(__x) != nullptr {
      return __tree_min(__right_(__x))
    }
    while !__tree_is_left_child(__x) {
      __x = __parent_unsafe(__x)
    }
    return __parent_unsafe(__x)
  }

  @inlinable
  @inline(__always)
  internal func
    __tree_next_iter(_ __x: _NodePtr) -> _NodePtr
  {
    assert(__x != nullptr, "node shouldn't be null")
    var __x = __x
    if __right_(__x) != nullptr {
      return __tree_min(__right_(__x))
    }
    while !__tree_is_left_child(__x) {
      __x = __parent_unsafe(__x)
    }
    return __parent_(__x)
  }

  @inlinable
  @inline(__always)
  internal func
    __tree_prev_iter(_ __x: _NodePtr) -> _NodePtr
  {
    assert(__x != nullptr, "node shouldn't be null")
    if __left_(__x) != nullptr {
      return __tree_max(__left_(__x))
    }
    var __xx = __x
    while __tree_is_left_child(__xx) {
      __xx = __parent_unsafe(__xx)
    }
    return __parent_unsafe(__xx)
  }

  @inlinable
  @inline(__always)
  internal func
    __tree_leaf(_ __x: _NodePtr) -> _NodePtr
  {
    assert(__x != nullptr, "node shouldn't be null")
    var __x = __x
    while true {
      if __left_(__x) != nullptr {
        __x = __left_(__x)
        continue
      }
      if __right_(__x) != nullptr {
        __x = __right_(__x)
        continue
      }
      break
    }
    return __x
  }
}

import Foundation

@usableFromInline
protocol BoundProtocol: BoundAlgorithmProtocol & CompareTrait {}

extension BoundProtocol {

  @inlinable
  @inline(__always)
  internal func lower_bound(_ __v: _Key) -> _NodePtr {
    Self.isMulti ? __lower_bound_multi(__v) : __lower_bound_unique(__v)
  }

  @inlinable
  @inline(__always)
  internal func upper_bound(_ __v: _Key) -> _NodePtr {
    Self.isMulti ? __upper_bound_multi(__v) : __upper_bound_unique(__v)
  }
}

@usableFromInline
protocol BoundAlgorithmProtocol: ValueProtocol & RootProtocol & EndNodeProtocol
    & ThreeWayComparatorProtocol
{}

extension BoundAlgorithmProtocol {

  @inlinable
  @inline(__always)
  internal func
    __lower_upper_bound_unique_impl(_LowerBound: Bool, _ __v: _Key) -> _NodePtr
  {
    var __rt = __root
    var __result = __end_node
    let __comp = __lazy_synth_three_way_comparator
    while __rt != nullptr {
      let __comp_res = __comp(__v, __get_value(__rt))
      if __comp_res.__less() {
        __result = __rt
        __rt = __left_unsafe(__rt)
      } else if __comp_res.__greater() {
        __rt = __right_(__rt)
      } else if _LowerBound {
        return __rt
      } else {
        return __right_(__rt) != nullptr ? __tree_min(__right_(__rt)) : __result
      }
    }
    return __result
  }

  @inlinable
  @inline(__always)
  internal func __lower_bound_unique(_ __v: _Key) -> _NodePtr {
    #if true
      __lower_upper_bound_unique_impl(_LowerBound: true, __v)
    #else
      __lower_bound_multi(__v, __root, __end_node)
    #endif
  }

  @inlinable
  @inline(__always)
  internal func __upper_bound_unique(_ __v: _Key) -> _NodePtr {
    #if true
      __lower_upper_bound_unique_impl(_LowerBound: false, __v)
    #else
      __upper_bound_multi(__v, __root, __end_node)
    #endif
  }

  @inlinable
  @inline(__always)
  internal func __lower_bound_multi(_ __v: _Key) -> _NodePtr {
    __lower_bound_multi(__v, __root, __end_node)
  }

  @inlinable
  @inline(__always)
  internal func __upper_bound_multi(_ __v: _Key) -> _NodePtr {
    __upper_bound_multi(__v, __root, __end_node)
  }

  @inlinable
  @inline(__always)
  internal func
    __lower_bound_multi(_ __v: _Key, _ __root: _NodePtr, _ __result: _NodePtr) -> _NodePtr
  {
    var (__root, __result) = (__root, __result)

    while __root != nullptr {
      if !value_comp(__get_value(__root), __v) {
        __result = __root
        __root = __left_unsafe(__root)
      } else {
        __root = __right_(__root)
      }
    }
    return __result
  }

  @inlinable
  @inline(__always)
  internal func
    __upper_bound_multi(_ __v: _Key, _ __root: _NodePtr, _ __result: _NodePtr) -> _NodePtr
  {
    var (__root, __result) = (__root, __result)

    while __root != nullptr {
      if value_comp(__v, __get_value(__root)) {
        __result = __root
        __root = __left_unsafe(__root)
      } else {
        __root = __right_(__root)
      }
    }
    return __result
  }
}

import Foundation

@usableFromInline
protocol PointerCompareProtocol: ValueProtocol {
  func ___ptr_comp(_ l: _NodePtr, _ r: _NodePtr) -> Bool
}

@usableFromInline
protocol CompareBothProtocol: CompareUniqueProtocol, CompareMultiProtocol, NodeBitmapProtocol {
  var isMulti: Bool { get }
  func ___ptr_comp_unique(_ l: _NodePtr, _ r: _NodePtr) -> Bool
  func ___ptr_comp_multi(_ __l: _NodePtr, _ __r: _NodePtr) -> Bool
}

extension CompareBothProtocol {
  @inlinable
  @inline(__always)
  internal func ___ptr_comp(_ l: _NodePtr, _ r: _NodePtr) -> Bool {
    assert(l == end || __parent_(l) != nullptr)
    assert(r == end || __parent_(r) != nullptr)

    guard
      l != r,
      r != end,
      l != end
    else {
      return l != end && r == end
    }

    if isMulti {




      return ___ptr_comp_unique(l, r) || (!___ptr_comp_unique(r, l) && ___ptr_comp_bitmap(l, r))
    }
    return ___ptr_comp_unique(l, r)
  }
}

public protocol CompareTrait {
  static var isMulti: Bool { get }
}

public protocol CompareUniqueTrait: CompareTrait {}

extension CompareUniqueTrait {
  @inlinable @inline(__always)
  public static var isMulti: Bool { false }
}

public protocol CompareMultiTrait: CompareTrait {}

extension CompareMultiTrait {
  @inlinable @inline(__always)
  public static var isMulti: Bool { true }
}

@usableFromInline
protocol CompareUniqueProtocol: ValueProtocol {}

extension CompareUniqueProtocol {

  @inlinable
  @inline(__always)
  internal func ___ptr_comp_unique(_ l: _NodePtr, _ r: _NodePtr) -> Bool {
    assert(l != nullptr, "Node shouldn't be null")
    assert(l != end, "Node shouldn't be end")
    assert(r != nullptr, "Node shouldn't be null")
    assert(r != end, "Node shouldn't be end")
    return value_comp(__get_value(l), __get_value(r))
  }
}

@usableFromInline
protocol CompareMultiProtocol: TreeNodeProtocol & RootProtocol & EndProtocol {}

extension CompareMultiProtocol {

  @inlinable
  @inline(__always)
  internal func ___ptr_height(_ __p: _NodePtr) -> Int {
    assert(__p != nullptr, "Node shouldn't be null")
    var __h = 0
    var __p = __p
    while __p != __root, __p != end {
      __p = __parent_(__p)
      __h += 1
    }
    return __h
  }

  @inlinable
  internal func ___ptr_comp_multi(_ __l: _NodePtr, _ __r: _NodePtr) -> Bool {
    assert(__l != nullptr, "Left node shouldn't be null")
    assert(__r != nullptr, "Right node shouldn't be null")
    guard
      __l != end,
      __r != end,
      __l != __r
    else {
      return __l != end && __r == end
    }
    var (__l, __lh) = (__l, ___ptr_height(__l))
    var (__r, __rh) = (__r, ___ptr_height(__r))
    while __lh < __rh {
      if __parent_(__r) == __l {
        return !__tree_is_left_child(__r)
      }
      (__r, __rh) = (__parent_(__r), __rh - 1)
    }
    while __lh > __rh {
      if __parent_(__l) == __r {
        return __tree_is_left_child(__l)
      }
      (__l, __lh) = (__parent_(__l), __lh - 1)
    }
    while __parent_(__l) != __parent_(__r) {
      (__l, __r) = (__parent_(__l), __parent_(__r))
    }
    return __tree_is_left_child(__l)
  }
}

@usableFromInline
protocol CompareProtocol: PointerCompareProtocol {}

extension CompareProtocol {

  @inlinable
  @inline(__always)
  internal func
    ___ptr_less_than(_ l: _NodePtr, _ r: _NodePtr) -> Bool
  {
    ___ptr_comp(l, r)
  }

  @inlinable
  @inline(__always)
  internal func
    ___ptr_less_than_or_equal(_ l: _NodePtr, _ r: _NodePtr) -> Bool
  {
    !___ptr_comp(r, l)
  }

  @inlinable
  @inline(__always)
  internal func
    ___ptr_greator_than(_ l: _NodePtr, _ r: _NodePtr) -> Bool
  {
    ___ptr_comp(r, l)
  }

  @inlinable
  @inline(__always)
  internal func
    ___ptr_greator_than_or_equal(_ l: _NodePtr, _ r: _NodePtr) -> Bool
  {
    !___ptr_comp(l, r)
  }

  @inlinable
  @inline(__always)
  internal func
    ___ptr_range_contains(_ l: _NodePtr, _ r: _NodePtr, _ p: _NodePtr) -> Bool
  {
    ___ptr_less_than_or_equal(l, p) && ___ptr_less_than(p, r)
  }

  @inlinable
  @inline(__always)
  internal func
    ___ptr_closed_range_contains(_ l: _NodePtr, _ r: _NodePtr, _ p: _NodePtr) -> Bool
  {
    ___ptr_less_than_or_equal(l, p) && ___ptr_less_than_or_equal(p, r)
  }
}

@usableFromInline
protocol NodeBitmapProtocol: TreeNodeProtocol & RootProtocol & EndProtocol {}

extension NodeBitmapProtocol {

  @inlinable
  @inline(__always)
  internal func ___ptr_bitmap(_ __p: _NodePtr) -> UInt {
    assert(__p != nullptr, "Node shouldn't be null")
    assert(__p != end, "Node shouldn't be end")
    var __f: UInt = 1  // 終端flag
    var __h = 1  // 終端flag分
    var __p = __p
    while __p != __root, __p != end {
      __f |= (__tree_is_left_child(__p) ? 0 : 1) &<< __h
      __p = __parent_(__p)
      __h &+= 1
    }
    __f &<<= UInt.bitWidth &- __h
    return __f
  }

  @inlinable
  @inline(__always)
  internal func ___ptr_bitmap_128(_ __p: _NodePtr) -> UInt128 {
    assert(__p != nullptr, "Node shouldn't be null")
    assert(__p != end, "Node shouldn't be end")
    var __f: UInt128 = 1 &<< (UInt128.bitWidth &- 1)
    var __p = __p
    while __p != __root, __p != end {
      __f &>>= 1
      __f |= (__tree_is_left_child(__p) ? 0 : 1) &<< (UInt128.bitWidth &- 1)
      __p = __parent_(__p)
    }
    return __f
  }

  @inlinable
  @inline(__always)
  internal func ___ptr_bitmap_64(_ __p: _NodePtr) -> UInt {
    assert(__p != nullptr, "Node shouldn't be null")
    assert(__p != end, "Node shouldn't be end")
    var __f: UInt = 1 &<< (UInt.bitWidth &- 1)
    var __p = __p
    while __p != __root, __p != end {
      __f &>>= 1
      __f |= (__tree_is_left_child(__p) ? 0 : 1) &<< (UInt.bitWidth &- 1)
      __p = __parent_(__p)
    }
    return __f
  }

  @inlinable
  @inline(__always)
  internal func ___ptr_comp_bitmap(_ __l: _NodePtr, _ __r: _NodePtr) -> Bool {
    ___ptr_bitmap_128(__l) < ___ptr_bitmap_128(__r)
  }
}

import Foundation

@usableFromInline
protocol CountProtocol: BoundAlgorithmProtocol & DistanceProtocol {}

extension CountProtocol {

  @usableFromInline
  typealias size_type = Int

  @usableFromInline
  typealias __node_pointer = _NodePtr

  @usableFromInline
  typealias __iter_pointer = _NodePtr

  @inlinable
  @inline(__always)
  internal func __count_unique(_ __k: _Key) -> size_type {
    var __rt: __node_pointer = __root
    let __comp = __lazy_synth_three_way_comparator
    while __rt != nullptr {
      let __comp_res = __comp(__k, __get_value(__rt))
      if __comp_res.__less() {
        __rt = __left_unsafe(__rt)
      } else if __comp_res.__greater() {
        __rt = __right_(__rt)
      } else {
        return 1
      }
    }
    return 0
  }

  @inlinable
  @inline(__always)
  internal func __count_multi(_ __k: _Key) -> size_type {
    var __result: __iter_pointer = __end_node
    var __rt: __node_pointer = __root
    let __comp = __lazy_synth_three_way_comparator
    while __rt != nullptr {
      let __comp_res = __comp(__k, __get_value(__rt))
      if __comp_res.__less() {
        __result = __rt
        __rt = __left_unsafe(__rt)
      } else if __comp_res.__greater() {
        __rt = __right_(__rt)
      } else {
        return __distance(
          __lower_bound_multi(__k, __left_unsafe(__rt), __rt),
          __upper_bound_multi(__k, __right_(__rt), __result))
      }
    }
    return 0
  }
}

import Foundation

@usableFromInline
protocol DistanceProtocol: TreeNodeProtocol & PointerCompareProtocol {}

extension DistanceProtocol {

  @usableFromInline
  typealias difference_type = Int

  @usableFromInline
  typealias _InputIter = _NodePtr

  @inlinable
  @inline(__always)
  internal func
    __distance(_ __first: _InputIter, _ __last: _InputIter) -> difference_type
  {
    var __first = __first
    var __r = 0
    while __first != __last {
      __first = __tree_next(__first)
      __r += 1
    }
    return __r
  }

  @inlinable
  @inline(__always)
  internal func
    ___signed_distance(_ __first: _InputIter, _ __last: _InputIter) -> difference_type
  {
    guard __first != __last else { return 0 }
    var (__first, __last) = (__first, __last)
    var sign = 1
    if ___ptr_comp(__last, __first) {
      swap(&__first, &__last)
      sign = -1
    }
    return sign * __distance(__first, __last)
  }
}

import Foundation

@usableFromInline
protocol EqualProtocol: BoundAlgorithmProtocol {}

extension EqualProtocol {

  @inlinable
  @inline(__always)
  internal func
    __equal_range_unique(_ __k: _Key) -> (_NodePtr, _NodePtr)
  {
    var __result = __end_node
    var __rt = __root
    let __comp = __lazy_synth_three_way_comparator
    while __rt != nullptr {
      let __comp_res = __comp(__k, __get_value(__rt))
      if __comp_res.__less() {
        __result = __rt
        __rt = __left_unsafe(__rt)
      } else if __comp_res.__greater() {
        __rt = __right_(__rt)
      } else {
        return (
          __rt,
          __right_(__rt) != nullptr
            ? __tree_min(__right_(__rt))
            : __result
        )
      }
    }
    return (__result, __result)
  }

  @inlinable
  @inline(__always)
  internal func
    __equal_range_multi(_ __k: _Key) -> (_NodePtr, _NodePtr)
  {
    var __result = __end_node
    var __rt = __root
    let __comp = __lazy_synth_three_way_comparator
    while __rt != nullptr {
      let __comp_res = __comp(__k, __get_value(__rt))
      if __comp_res.__less() {
        __result = __rt
        __rt = __left_unsafe(__rt)
      } else if __comp_res.__greater() {
        __rt = __right_(__rt)
      } else {
        return (
          __lower_bound_multi(
            __k,
            __left_unsafe(__rt),
            __rt),
          __upper_bound_multi(
            __k,
            __right_(__rt),
            __result)
        )
      }
    }
    return (__result, __result)
  }
}

import Foundation

@usableFromInline
protocol EraseProtocol: TreePointer {
  func destroy(_ p: _NodePtr)
  func __remove_node_pointer(_ __ptr: _NodePtr) -> _NodePtr
}

extension EraseProtocol {

  @inlinable
  @inline(__always)
  internal func
    erase(_ __p: _NodePtr) -> _NodePtr
  {
    let __r = __remove_node_pointer(__p)
    destroy(__p)
    return __r
  }

  @inlinable
  @inline(__always)
  internal func
    erase(_ __f: _NodePtr, _ __l: _NodePtr) -> _NodePtr
  {
    var __f = __f
    while __f != __l {
      __f = erase(__f)
    }
    return __l
  }
}

@usableFromInline
protocol EraseUniqueProtocol: FindProtocol, EraseProtocol { }

extension EraseUniqueProtocol {
  
  @inlinable
  @inline(__always)
  internal func ___erase_unique(_ __k: _Key) -> Bool {
    let __i = find(__k)
    if __i == end {
      return false
    }
    _ = erase(__i)
    return true
  }
}

@usableFromInline
protocol EraseMultiProtocol: EqualProtocol, EraseProtocol { }

extension EraseMultiProtocol {
  
  @inlinable
  @inline(__always)
  internal func ___erase_multi(_ __k: _Key) -> Int {
    var __p = __equal_range_multi(__k)
    var __r = 0
    while __p.0 != __p.1 {
      defer { __r += 1 }
      __p.0 = erase(__p.0)
    }
    return __r
  }
}

import Foundation

@usableFromInline
protocol FindLeafProtocol: ValueProtocol, TreeNodeRefProtocol, RootProtocol, EndNodeProtocol {}

extension FindLeafProtocol {

  @inlinable
  @inline(__always)
  internal func
    __find_leaf_low(_ __parent: inout _NodePtr, _ __v: _Key) -> _NodeRef
  {
    var __nd: _NodePtr = __root
    if __nd != nullptr {
      while true {
        if value_comp(__get_value(__nd), __v) {
          if __right_(__nd) != nullptr {
            __nd = __right_(__nd)
          } else {
            __parent = __nd
            return __right_ref(__nd)
          }
        } else {
          if __left_unsafe(__nd) != nullptr {
            __nd = __left_unsafe(__nd)
          } else {
            __parent = __nd
            return __left_ref(__parent)
          }
        }
      }
    }
    __parent = __end_node
    return __left_ref(__parent)
  }

  @inlinable
  @inline(__always)
  internal func
    __find_leaf_high(_ __parent: inout _NodePtr, _ __v: _Key) -> _NodeRef
  {
    var __nd: _NodePtr = __root
    if __nd != nullptr {
      while true {
        if value_comp(__v, __get_value(__nd)) {
          if __left_unsafe(__nd) != nullptr {
            __nd = __left_unsafe(__nd)
          } else {
            __parent = __nd
            return __left_ref(__parent)
          }
        } else {
          if __right_(__nd) != nullptr {
            __nd = __right_(__nd)
          } else {
            __parent = __nd
            return __right_ref(__nd)
          }
        }
      }
    }
    __parent = __end_node
    return __left_ref(__parent)
  }
}

@usableFromInline
protocol FindEqualProtocol: ValueProtocol, TreeNodeRefProtocol, RootProtocol, RootPtrProtocol,
  ThreeWayComparatorProtocol
{}

extension FindEqualProtocol {

  @inlinable
  @inline(__always)
  internal func
    __find_equal(_ __v: _Key) -> (__parent: _NodePtr, __child: _NodeRef)
  {
    var __nd = __root
    if __nd == nullptr {
      return (__end_node, __left_ref(end))
    }
    var __nd_ptr = __root_ptr()
    let __comp = __lazy_synth_three_way_comparator

    while true {

      let __comp_res = __comp(__v, __get_value(__nd))

      if __comp_res.__less() {
        if __left_unsafe(__nd) == nullptr {
          return (__nd, __left_ref(__nd))
        }

        __nd_ptr = __left_ref(__nd)
        __nd = __left_unsafe(__nd)
      } else if __comp_res.__greater() {
        if __right_(__nd) == nullptr {
          return (__nd, __right_ref(__nd))
        }

        __nd_ptr = __right_ref(__nd)
        __nd = __right_(__nd)
      } else {
        return (__nd, __nd_ptr)
      }
    }
  }
}

@usableFromInline
protocol FindProtocol: BoundProtocol & EndProtocol & FindEqualProtocol {}

extension FindProtocol {

  @inlinable
  @inline(__always)
  internal func find(_ __v: _Key) -> _NodePtr {
    #if USE_OLD_FIND
      let __p = lower_bound(__v)
      if __p != end, !value_comp(__v, __get_value(__p)) {
        return __p
      }
      return end
    #else
      let (_, __match) = __find_equal(__v)
      if __ptr_(__match) == nullptr {
        return end
      }
      return __ptr_(__match)
    #endif
  }
}

import Foundation

@usableFromInline
protocol InsertNodeAtProtocol:
  TreeNodeProtocol & TreeNodeRefProtocol & SizeProtocol & BeginNodeProtocol & EndNodeProtocol
{}

extension InsertNodeAtProtocol {

  @inlinable
  @inline(__always)
  internal func
    __insert_node_at(
      _ __parent: _NodePtr, _ __child: _NodeRef,
      _ __new_node: _NodePtr
    )
  {
    __left_(__new_node, nullptr)
    __right_(__new_node, nullptr)
    __parent_(__new_node, __parent)
    __ptr_(__child, __new_node)
    if __left_(__begin_node_) != nullptr {
      __begin_node_ = __left_(__begin_node_)
    }
    __tree_balance_after_insert(__left_(__end_node), __ptr_(__child))
    __size_ += 1
  }
}

@usableFromInline
protocol InsertUniqueProtocol:
  AllocatorProtocol & KeyProtocol & TreeNodeRefProtocol
{
  func __find_equal(_ __v: _Key) -> (__parent: _NodePtr, __child: _NodeRef)

  func
    __insert_node_at(
      _ __parent: _NodePtr, _ __child: _NodeRef,
      _ __new_node: _NodePtr)
}

extension InsertUniqueProtocol {

  @inlinable
  @inline(__always)
  internal func
    __insert_unique(_ x: _Value) -> (__r: _NodePtr, __inserted: Bool)
  {
    __emplace_unique_key_args(x)
  }

  #if true
    @inlinable
    @inline(__always)
    internal func
      __emplace_unique_key_args(_ __k: _Value)
      -> (__r: _NodePtr, __inserted: Bool)
    {
      let (__parent, __child) = __find_equal(__key(__k))
      let __r = __child
      if __ptr_(__child) == nullptr {
        let __h = __construct_node(__k)
        __insert_node_at(__parent, __child, __h)
        return (__h, true)
      } else {
        return (__ptr_(__r), false)
      }
    }
  #else
    @inlinable
    internal func
      __emplace_unique_key_args(_ __k: _Value)
      -> (__r: _NodeRef, __inserted: Bool)
    {
      var __parent = _NodePtr.nullptr
      let __child = __find_equal(&__parent, __key(__k))
      let __r = __child
      var __inserted = false
      if __ref_(__child) == .nullptr {
        let __h = __construct_node(__k)
        __insert_node_at(__parent, __child, __h)
        __inserted = true
      }
      return (__r, __inserted)
    }
  #endif
}

@usableFromInline
protocol InsertMultiProtocol:
  AllocatorProtocol & KeyProtocol
{

  func
    __find_leaf_high(_ __parent: inout _NodePtr, _ __v: _Key) -> _NodeRef

  func
    __insert_node_at(
      _ __parent: _NodePtr, _ __child: _NodeRef,
      _ __new_node: _NodePtr)
}

extension InsertMultiProtocol {

  @inlinable
  @inline(__always)
  internal func __insert_multi(_ x: _Value) -> _NodePtr {
    __emplace_multi(x)
  }

  @inlinable
  @inline(__always)
  internal func
    __emplace_multi(_ __k: _Value) -> _NodePtr
  {
    let __h = __construct_node(__k)
    var __parent = nullptr
    let __child = __find_leaf_high(&__parent, __key(__k))
    __insert_node_at(__parent, __child, __h)
    return __h
  }
}

@usableFromInline
protocol InsertLastProtocol:
  InsertNodeAtProtocol & AllocatorProtocol & RootProtocol & EndNodeProtocol
{}

extension InsertLastProtocol {

  @inlinable
  @inline(__always)
  internal func ___max_ref() -> (__parent: _NodePtr, __child: _NodeRef) {
    if __root == nullptr {
      return (__end_node, __left_ref(__end_node))
    }
    let __parent = __tree_max(__root)
    return (__parent, __right_ref(__parent))
  }

  @inlinable
  @inline(__always)
  internal func
    ___emplace_hint_right(_ __parent: _NodePtr, _ __child: _NodeRef, _ __k: _Value)
    -> (__parent: _NodePtr, __child: _NodeRef)
  {
    let __p = __construct_node(__k)
    __insert_node_at(__parent, __child, __p)
    return (__p, __right_ref(__p))
  }

  @inlinable
  @inline(__always)
  internal func ___emplace_hint_right(_ __p: _NodePtr, _ __k: _Value) -> _NodePtr {
    let __child = __p == end ? __left_ref(__end_node) : __right_ref(__p)
    let __h = __construct_node(__k)
    __insert_node_at(__p, __child, __h)
    return __h
  }

  @inlinable
  @inline(__always)
  internal func ___emplace_hint_left(_ __p: _NodePtr, _ __k: _Value) -> _NodePtr {
    let __child = __left_ref(__p)
    let __h = __construct_node(__k)
    __insert_node_at(__p, __child, __h)
    return __h
  }
}

import Foundation

public typealias _PointerIndex = Int

extension _PointerIndex {

  @inlinable
  package static var nullptr: Self {
    -2
  }

  @inlinable
  package static var end: Self {
    -1
  }

  @inlinable
  package static var debug: Self {
    -999
  }

  @inlinable
  @inline(__always)
  package static func node(_ p: Int) -> Self { p }
}

@inlinable
@inline(__always)
package func ___is_null_or_end(_ ptr: _PointerIndex) -> Bool {
  ptr < 0
}

public
  enum _PointerIndexRef: Equatable
{
  case __right_(_PointerIndex)
  case __left_(_PointerIndex)
}

extension TreeNodeProtocol where _NodePtr == Int, _NodeRef == _PointerIndexRef {

  @inlinable
  @inline(__always)
  internal func __ptr_(_ rhs: _NodeRef) -> _NodePtr {
    switch rhs {
    case .__right_(let basePtr):
      return __right_(basePtr)
    case .__left_(let basePtr):
      return __left_(basePtr)
    }
  }

  @inlinable
  @inline(__always)
  internal func __left_ref(_ p: _NodePtr) -> _NodeRef {
    assert(p != .nullptr)
    return .__left_(p)
  }

  @inlinable
  @inline(__always)
  internal func __right_ref(_ p: _NodePtr) -> _NodeRef {
    assert(p != .nullptr)
    return .__right_(p)
  }
}

extension TreeNodeProtocol where _NodePtr == Int, _NodeRef == _PointerIndexRef {

  @inlinable
  @inline(__always)
  internal func __ptr_(_ lhs: _NodeRef, _ rhs: _NodePtr) {
    switch lhs {
    case .__right_(let basePtr):
      return __right_(basePtr, rhs)
    case .__left_(let basePtr):
      return __left_(basePtr, rhs)
    }
  }
}

import Foundation

public protocol KeyValueComparer: ValueComparer & HasDefaultThreeWayComparator {
  associatedtype _MappedValue
  static func ___mapped_value(_ element: _Value) -> _MappedValue
  static func ___with_mapped_value<T>(_ element: inout _Value, _: (inout _MappedValue) throws -> T)
    rethrows -> T
}

import Foundation

@usableFromInline
protocol RemoveProtocol: TreeNodeProtocol
    & BeginNodeProtocol
    & EndNodeProtocol
    & SizeProtocol
{}

extension RemoveProtocol {

  @inlinable
  @inline(__always)
  internal func __remove_node_pointer(_ __ptr: _NodePtr) -> _NodePtr {
    var __r = __ptr
    __r = __tree_next_iter(__r)
    if __begin_node_ == __ptr {
      __begin_node_ = __r
    }
    __size_ -= 1
    __tree_remove(__left_(__end_node), __ptr)
    return __r
  }
}

import Foundation

public protocol ScalarValueComparer: ValueComparer & HasDefaultThreeWayComparator where _Key == _Value {}

extension ScalarValueComparer {

  @inlinable
  @inline(__always)
  public static func __key(_ e: _Value) -> _Key { e }
}

import Foundation

public
  protocol ThreeWayCompareResult
{
  @inlinable func __less() -> Bool
  @inlinable func __greater() -> Bool
}

public
  protocol ThreeWayComparator
{
  associatedtype __compare_result: ThreeWayCompareResult
  associatedtype _Key
  @inlinable
  static func
    __lazy_synth_three_way_comparator(_ __lhs: _Key, _ __rhs: _Key)
    -> __compare_result
}

@usableFromInline
protocol ThreeWayComparatorProtocol {
  associatedtype __compare_result: ThreeWayCompareResult
  associatedtype _Key
  @inlinable
  func __lazy_synth_three_way_comparator(_ __lhs: _Key, _ __rhs: _Key)
    -> __compare_result
}

@inlinable
@inline(__always)
package func __default_three_way_comparator<T: Comparable>(_ __lhs: T, _ __rhs: T) -> Int {
  if __lhs < __rhs {
    -1
  } else if __lhs > __rhs {
    1
  } else {
    0
  }
}

public
  struct __lazy_compare_result<Base: ValueComparer>: ThreeWayCompareResult
{
  public typealias LHS = Base._Key
  public typealias RHS = Base._Key
  @usableFromInline internal var __lhs_: LHS
  @usableFromInline internal var __rhs_: RHS
  @inlinable
  @inline(__always)
  internal init(_ __lhs_: LHS, _ __rhs_: RHS) {
    self.__lhs_ = __lhs_
    self.__rhs_ = __rhs_
  }
  @inlinable
  @inline(__always)
  internal func __comp_(_ __lhs_: LHS, _ __rhs_: RHS) -> Bool {
    Base.value_comp(__lhs_, __rhs_)
  }
  @inlinable
  @inline(__always)
  public func __less() -> Bool { __comp_(__lhs_, __rhs_) }
  @inlinable
  @inline(__always)
  public func __greater() -> Bool { __comp_(__rhs_, __lhs_) }
}

public
  struct __comparable_compare_result<T: Comparable>: ThreeWayCompareResult
{
  @usableFromInline internal var __lhs_, __rhs_: T
  @inlinable
  @inline(__always)
  internal init(_ __lhs_: T, _ __rhs_: T) {
    self.__lhs_ = __lhs_
    self.__rhs_ = __rhs_
  }
  @inlinable
  @inline(__always)
  public func __less() -> Bool { __lhs_ < __rhs_ }
  @inlinable
  @inline(__always)
  public func __greater() -> Bool { __lhs_ > __rhs_ }
}

public
  struct __eager_compare_result: ThreeWayCompareResult
{
  @usableFromInline internal var __res_: Int
  @inlinable
  @inline(__always)
  internal init(_ __res_: Int) {
    self.__res_ = __res_
  }
  @inlinable
  @inline(__always)
  public func __less() -> Bool { __res_ < 0 }
  @inlinable
  @inline(__always)
  public func __greater() -> Bool { __res_ > 0 }
}

public protocol LazySynthThreeWayComparator: ThreeWayComparator
where Self: ValueComparer {}

extension LazySynthThreeWayComparator {

  @inlinable
  @inline(__always)
  public static func
    __lazy_synth_three_way_comparator(_ __lhs: _Key, _ __rhs: _Key)
    -> __lazy_compare_result<Self>
  {
    __lazy_compare_result(__lhs, __rhs)
  }
}

public protocol ComparableThreeWayComparator: ThreeWayComparator
where _Key: Comparable {}

extension ComparableThreeWayComparator {

  @inlinable
  @inline(__always)
  public static func
    __lazy_synth_three_way_comparator(_ __lhs: _Key, _ __rhs: _Key)
    -> __comparable_compare_result<
      _Key
    >
  {
    __comparable_compare_result(__lhs, __rhs)
  }
}

public protocol HasDefaultThreeWayComparator: ThreeWayComparator {}

extension HasDefaultThreeWayComparator where _Key: Comparable {

  @inlinable
  @inline(__always)
  public static func
    __lazy_synth_three_way_comparator(_ __lhs: _Key, _ __rhs: _Key)
    -> __eager_compare_result
  {
    __eager_compare_result(__default_three_way_comparator(__lhs, __rhs))
  }
}
#if COMPATIBLE_ATCODER_2025

  extension RedBlackTreeDictionary {
    @available(*, deprecated)
    public subscript(_unsafe bounds: Range<Index>) -> SubSequence {
      .init(
        tree: __tree_,
        start: bounds.lowerBound.rawValue(__tree_),
        end: bounds.upperBound.rawValue(__tree_))
    }
  }

  extension RedBlackTreeDictionary {
    @available(*, deprecated)
    public subscript(_unsafe position: Index) -> (key: Key, value: Value) {
      @inline(__always) get { self[_unchecked: position] }
    }
  }

  extension RedBlackTreeDictionary {
    @inlinable
    @inline(__always)
    public func keys() -> Keys {
      _keys()
    }

    @inlinable
    @inline(__always)
    public func values() -> Values {
      _values()
    }
  }

  extension RedBlackTreeDictionary {

    @available(*, deprecated)
    public subscript(bounds: Range<Key>) -> SubSequence {
      elements(in: bounds)
    }

    @available(*, deprecated)
    public subscript(bounds: ClosedRange<Key>) -> SubSequence {
      elements(in: bounds)
    }
  }

  extension RedBlackTreeDictionary {
    @available(*, deprecated)
    public func elements(in range: Range<Key>) -> SubSequence {
      .init(
        tree: __tree_,
        start: ___lower_bound(range.lowerBound),
        end: ___lower_bound(range.upperBound))
    }

    @available(*, deprecated)
    public func elements(in range: ClosedRange<Key>) -> SubSequence {
      .init(
        tree: __tree_,
        start: ___lower_bound(range.lowerBound),
        end: ___upper_bound(range.upperBound))
    }
  }

  extension RedBlackTreeDictionary {

    @inlinable
    @inline(__always)
    public mutating func remove(contentsOf keyRange: Range<Key>) {
      _strongEnsureUnique()
      let lower = ___lower_bound(keyRange.lowerBound)
      let upper = ___lower_bound(keyRange.upperBound)
      ___remove(from: lower, to: upper)
    }

    @inlinable
    @inline(__always)
    public mutating func remove(contentsOf keyRange: ClosedRange<Key>) {
      _strongEnsureUnique()
      let lower = ___lower_bound(keyRange.lowerBound)
      let upper = ___upper_bound(keyRange.upperBound)
      ___remove(from: lower, to: upper)
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionary where Value: Equatable {

    @inlinable
    @inline(__always)
    public func elementsEqual<OtherSequence>(_ other: OtherSequence) -> Bool
    where OtherSequence: Sequence, Element == OtherSequence.Element {
      elementsEqual(other, by: ==)
    }
  }

  extension RedBlackTreeDictionary where Value: Comparable {

    @inlinable
    @inline(__always)
    public func lexicographicallyPrecedes<OtherSequence>(_ other: OtherSequence) -> Bool
    where OtherSequence: Sequence, Element == OtherSequence.Element {
      lexicographicallyPrecedes(other, by: <)
    }
  }
#endif
#if COMPATIBLE_ATCODER_2025

  extension RedBlackTreeMultiMap {
    @available(*, deprecated)
    public subscript(_unsafe bounds: Range<Index>) -> SubSequence {
      .init(
        tree: __tree_,
        start: bounds.lowerBound.rawValue(__tree_),
        end: bounds.upperBound.rawValue(__tree_))
    }
  }

  extension RedBlackTreeMultiMap {
    @available(*, deprecated)
    public subscript(_unsafe position: Index) -> (key: Key, value: Value) {
      @inline(__always) get { self[_unchecked: position] }
    }
  }

  extension RedBlackTreeMultiMap {
    @inlinable
    @inline(__always)
    public func keys() -> Keys {
      _keys()
    }

    @inlinable
    @inline(__always)
    public func values() -> Values {
      .init(tree: __tree_, start: __tree_.__begin_node_, end: __tree_.__end_node)
    }
  }

  extension RedBlackTreeMultiMap {

    @available(*, deprecated)
    public subscript(bounds: Range<Key>) -> SubSequence {
      elements(in: bounds)
    }

    @available(*, deprecated)
    public subscript(bounds: ClosedRange<Key>) -> SubSequence {
      elements(in: bounds)
    }
  }

  extension RedBlackTreeMultiMap {
    @available(*, deprecated)
    public func elements(in range: Range<Key>) -> SubSequence {
      .init(
        tree: __tree_,
        start: ___lower_bound(range.lowerBound),
        end: ___lower_bound(range.upperBound))
    }

    @available(*, deprecated)
    public func elements(in range: ClosedRange<Key>) -> SubSequence {
      .init(
        tree: __tree_,
        start: ___lower_bound(range.lowerBound),
        end: ___upper_bound(range.upperBound))
    }
  }

  extension RedBlackTreeMultiMap {

    @inlinable
    @inline(__always)
    public mutating func remove(contentsOf keyRange: Range<Key>) {
      _strongEnsureUnique()
      let lower = ___lower_bound(keyRange.lowerBound)
      let upper = ___lower_bound(keyRange.upperBound)
      ___remove(from: lower, to: upper)
    }

    @inlinable
    @inline(__always)
    public mutating func remove(contentsOf keyRange: ClosedRange<Key>) {
      _strongEnsureUnique()
      let lower = ___lower_bound(keyRange.lowerBound)
      let upper = ___upper_bound(keyRange.upperBound)
      ___remove(from: lower, to: upper)
    }
  }
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap where Value: Equatable {

    @inlinable
    @inline(__always)
    public func elementsEqual<OtherSequence>(_ other: OtherSequence) -> Bool
    where OtherSequence: Sequence, Element == OtherSequence.Element {
      elementsEqual(other, by: ==)
    }
  }

  extension RedBlackTreeMultiMap where Value: Comparable {

    @inlinable
    @inline(__always)
    public func lexicographicallyPrecedes<OtherSequence>(_ other: OtherSequence) -> Bool
    where OtherSequence: Sequence, Element == OtherSequence.Element {
      lexicographicallyPrecedes(other, by: <)
    }
  }
#endif
#if COMPATIBLE_ATCODER_2025

  extension RedBlackTreeMultiSet {
    @available(*, deprecated)
    public subscript(_unsafe bounds: Range<Index>) -> SubSequence {
      .init(
        tree: __tree_,
        start: bounds.lowerBound.rawValue(__tree_),
        end: bounds.upperBound.rawValue(__tree_))
    }
  }

  extension RedBlackTreeMultiSet {
    @available(*, deprecated)
    public subscript(_unsafe position: Index) -> Element {
      @inline(__always) _read { yield self[_unchecked: position] }
    }
  }

  extension RedBlackTreeMultiSet {

    @available(*, deprecated)
    public subscript(bounds: Range<Element>) -> SubSequence {
      elements(in: bounds)
    }

    @available(*, deprecated)
    public subscript(bounds: ClosedRange<Element>) -> SubSequence {
      elements(in: bounds)
    }
  }

  extension RedBlackTreeMultiSet {
    @available(*, deprecated)
    public func elements(in range: Range<Element>) -> SubSequence {
      .init(
        tree: __tree_,
        start: ___lower_bound(range.lowerBound),
        end: ___lower_bound(range.upperBound))
    }

    @available(*, deprecated)
    public func elements(in range: ClosedRange<Element>) -> SubSequence {
      .init(
        tree: __tree_,
        start: ___lower_bound(range.lowerBound),
        end: ___upper_bound(range.upperBound))
    }
  }

  extension RedBlackTreeMultiSet {

    @inlinable
    public mutating func remove(contentsOf elementRange: Range<Element>) {
      _strongEnsureUnique()
      let lower = ___lower_bound(elementRange.lowerBound)
      let upper = ___lower_bound(elementRange.upperBound)
      ___remove(from: lower, to: upper)
    }

    @inlinable
    public mutating func remove(contentsOf elementRange: ClosedRange<Element>) {
      _strongEnsureUnique()
      let lower = ___lower_bound(elementRange.lowerBound)
      let upper = ___upper_bound(elementRange.upperBound)
      ___remove(from: lower, to: upper)
    }
  }

  extension RedBlackTreeMultiSet {
    @inlinable
    @discardableResult
    public mutating func removeAll(_unsafe member: Element) -> Element? {
      _ensureUnique()
      return __tree_.___erase_multi(member) != 0 ? member : nil
    }
  }
#endif
#if COMPATIBLE_ATCODER_2025

  extension RedBlackTreeSet {
    @available(*, deprecated)
    public subscript(_unsafe bounds: Range<Index>) -> SubSequence {
      .init(
        tree: __tree_,
        start: bounds.lowerBound.rawValue(__tree_),
        end: bounds.upperBound.rawValue(__tree_))
    }
  }

  extension RedBlackTreeSet {
    @available(*, deprecated)
    public subscript(_unsafe position: Index) -> Element {
      @inline(__always) _read { yield self[_unchecked: position] }
    }
  }

  extension RedBlackTreeSet {

    @available(*, deprecated)
    public subscript(bounds: Range<Element>) -> SubSequence {
      elements(in: bounds)
    }

    @available(*, deprecated)
    public subscript(bounds: ClosedRange<Element>) -> SubSequence {
      elements(in: bounds)
    }
  }

  extension RedBlackTreeSet {
    @available(*, deprecated)
    public func elements(in range: Range<Element>) -> SubSequence {
      .init(
        tree: __tree_,
        start: ___lower_bound(range.lowerBound),
        end: ___lower_bound(range.upperBound))
    }

    @available(*, deprecated)
    public func elements(in range: ClosedRange<Element>) -> SubSequence {
      .init(
        tree: __tree_,
        start: ___lower_bound(range.lowerBound),
        end: ___upper_bound(range.upperBound))
    }
  }

  extension RedBlackTreeSet {

    @inlinable
    @inline(__always)
    public mutating func remove(contentsOf elementRange: Range<Element>) {
      _strongEnsureUnique()
      let lower = ___lower_bound(elementRange.lowerBound)
      let upper = ___lower_bound(elementRange.upperBound)
      ___remove(from: lower, to: upper)
    }

    @inlinable
    @inline(__always)
    public mutating func remove(contentsOf elementRange: ClosedRange<Element>) {
      _strongEnsureUnique()
      let lower = ___lower_bound(elementRange.lowerBound)
      let upper = ___upper_bound(elementRange.upperBound)
      ___remove(from: lower, to: upper)
    }
  }
#endif
#if COMPATIBLE_ATCODER_2025

  extension RedBlackTreeSlice {
    @available(*, deprecated)
    public subscript(_unsafe position: Index) -> Element {
      @inline(__always) _read {
        yield self[_unchecked: position]
      }
    }

    @available(*, deprecated)
    public subscript(_unsafe bounds: Range<Index>) -> SubSequence {
      .init(
        tree: __tree_,
        start: bounds.lowerBound.rawValue(__tree_),
        end: bounds.upperBound.rawValue(__tree_))
    }
  }

  extension RedBlackTreeSliceV2.KeyValue {

    @available(*, deprecated)
    public subscript(_unsafe position: Index) -> (key: _Key, value: _MappedValue) {
      @inline(__always) get { self[_unchecked: position] }
    }

    @available(*, deprecated)
    public subscript(_unsafe bounds: Range<Index>) -> SubSequence {
      .init(
        tree: __tree_,
        start: bounds.lowerBound.rawValue(__tree_),
        end: bounds.upperBound.rawValue(__tree_))
    }
  }

  extension RedBlackTreeSliceV2.KeyValue {

    @inlinable
    @inline(__always)
    public func keys() -> Keys {
      _keys()
    }

    @inlinable
    @inline(__always)
    public func values() -> Values {
      _values()
    }
  }
#endif

import Foundation

public struct _LinkingPair<Key, Value> {
  @inlinable
  @inline(__always)
  public init(_ key: Key, _ prev: _NodePtr, _ next: _NodePtr, _ value: Value) {
    self.key = key
    self.prev = prev
    self.next = next
    self.value = value
  }
  public var key: Key
  public var prev: _NodePtr
  public var next: _NodePtr
  public var value: Value
  
  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
}

extension KeyValueComparer where _Value == _LinkingPair<_Key, _MappedValue> {

  @inlinable @inline(__always)
  public static func __key(_ element: _Value) -> _Key { element.key }

  @inlinable @inline(__always)
  public static func __value(_ element: _Value) -> _MappedValue { element.value }
}

@usableFromInline
protocol ___LRULinkList: KeyValueComparer & CompareTrait & ThreeWayComparator
where _Value == _LinkingPair<_Key, _MappedValue> {
  associatedtype Value
  var __tree_: Tree { get set }
  var _rankHighest: _NodePtr { get set }
  var _rankLowest: _NodePtr { get set }
}

extension ___LRULinkList {

  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

  public typealias Tree = UnsafeTreeV2<Self>

  @inlinable
  @inline(__always)
  mutating func ___prepend(_ __p: _NodePtr) {
    if _rankHighest == __tree_.nullptr {
      __tree_[__p].next = __tree_.nullptr
      __tree_[__p].prev = __tree_.nullptr
      _rankLowest = __p
      _rankHighest = __p
    } else {
      __tree_[_rankHighest].prev = __p
      __tree_[__p].next = _rankHighest
      __tree_[__p].prev = __tree_.nullptr
      _rankHighest = __p
    }
  }

  @inlinable
  @inline(__always)
  mutating func ___pop(_ __p: _NodePtr) -> _NodePtr {

    assert(
      __p == _rankHighest || __tree_[__p].next != __tree_.nullptr || __tree_[__p].prev != __tree_.nullptr,
      "did not contain \(__p) ptr.")

    defer {
      let prev = __tree_[__p].prev
      let next = __tree_[__p].next
      if prev != __tree_.nullptr {
        __tree_[prev].next = next
      } else {
        _rankHighest = next
      }
      if next != __tree_.nullptr {
        __tree_[next].prev = prev
      } else {
        _rankLowest = prev
      }
    }

    return __p
  }

  @inlinable
  @inline(__always)
  mutating func ___popRankLowest() -> _NodePtr {

    defer {
      if _rankLowest != __tree_.nullptr {
        _rankLowest = __tree_[_rankLowest].prev
      }
      if _rankLowest != __tree_.nullptr {
        __tree_[_rankLowest].next = __tree_.nullptr
      } else {
        _rankHighest = __tree_.nullptr
      }
    }

    return _rankLowest
  }
}

extension ___LRULinkList {

  @inlinable
  @inline(__always)
  internal func ___node_ptr(_ index: Int) -> _NodePtr {
    switch index {
    case .nullptr:
      return __tree_.nullptr
    case .end:
      return __tree_.end
    default:
      return __tree_._buffer.header[index]
    }
  }
}

import Foundation

@frozen
public struct ___LRUMemoizeStorage<Parameters, Value>
where Parameters: Comparable {

  public
    typealias Key = Parameters

  public
    typealias Value = Value

  public
    typealias KeyValue = _LinkingPair<_Key, _MappedValue>

  public
    typealias _Value = KeyValue

  public
    typealias _Key = Key

  public
    typealias _MappedValue = Value

  public let maxCount: Int

  @usableFromInline
  var _rankHighest: _NodePtr

  @usableFromInline
  var _rankLowest: _NodePtr
  
  @usableFromInline
  var referenceCounter: ReferenceCounter

  @usableFromInline
  var __tree_: Tree {
    didSet { referenceCounter = .create() }
  }
}

extension ___LRUMemoizeStorage {

  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

  @inlinable
  @inline(__always)
  public init(minimumCapacity: Int = 0, maxCount: Int = Int.max) {
    __tree_ = .___create(minimumCapacity: minimumCapacity, nullptr: UnsafeNode.nullptr)
    self.maxCount = maxCount
    (_rankHighest, _rankLowest) = (__tree_.nullptr, __tree_.nullptr)
    
    referenceCounter = .create()
  }

  @inlinable
  public subscript(key: Key) -> Value? {
    @inline(__always)
    mutating get {
      let __ptr = __tree_.find(key)
      if __tree_.___is_null_or_end(__ptr) {
        return nil
      }
      ___prepend(___pop(__ptr))
      return __tree_[__ptr].value
    }
    @inline(__always)
    set {
      if let newValue {
        if __tree_.count < maxCount {
          _ensureCapacity(limit: maxCount)
        }
        if __tree_.count == maxCount {
          _ = __tree_.erase(___popRankLowest())
        }
#if !USE_UNSAFE_TREE
        assert(__tree_.count < __tree_.capacity)
        #endif
        let (__parent, __child) = __tree_.__find_equal(key)
        if __tree_.__ptr_(__child) == __tree_.nullptr {
          let __h = __tree_.__construct_node(.init(key, __tree_.nullptr, __tree_.nullptr, newValue))
          __tree_.__insert_node_at(__parent, __child, __h)
          ___prepend(__h)
        }
      }
    }
  }
}

extension ___LRUMemoizeStorage: ___LRULinkList & ___UnsafeCopyOnWriteV2 & ___UnsafeStorageProtocolV2 {
  
  public typealias Base = Self
}
extension ___LRUMemoizeStorage: CompareUniqueTrait {}
extension ___LRUMemoizeStorage: KeyValueComparer {

  @inlinable
  @inline(__always)
  public static func ___mapped_value(_ element: _Value) -> _MappedValue {
    element.value
  }

  @inlinable
  @inline(__always)
  public static func ___with_mapped_value<T>(
    _ element: inout _Value, _ f: (inout _MappedValue) throws -> T
  ) rethrows -> T {
    try f(&element.value)
  }
}

extension ___LRUMemoizeStorage {

  @inlinable
  @inline(__always)
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    ___removeAll(keepingCapacity: keepCapacity)
  }
}

extension ___LRUMemoizeStorage {

  @inlinable
  public var count: Int { ___count }

  @inlinable
  public var capacity: Int { ___capacity }
}

#if AC_COLLECTIONS_INTERNAL_CHECKS
  extension ___LRUMemoizeStorage {

    package var _copyCount: UInt {
      get { __tree_.copyCount }
      set { __tree_.copyCount = newValue }
    }
  }
#endif
extension RedBlackTreeDictionary {

  @inlinable
  @inline(__always)
  package func ___tree_invariant() -> Bool {
    #if !WITHOUT_SIZECHECK
      __tree_.count == __tree_.___signed_distance(__tree_.__begin_node_, __tree_.end)
        && __tree_.__tree_invariant(__tree_.__root)
    #else
      __tree_.__tree_invariant(__tree_.__root)
    #endif
  }
}

extension RedBlackTreeDictionary {

  @inlinable
  @inline(__always)
  package func ___is_garbaged(_ index: Index) -> Bool {
    __tree_.___is_garbaged(index.rawValue(__tree_))
  }
}

#if AC_COLLECTIONS_INTERNAL_CHECKS
  extension RedBlackTreeDictionary {

    package var _copyCount: UInt {
      get { __tree_.copyCount }
      set { __tree_.copyCount = newValue }
    }
  }

  extension RedBlackTreeDictionary {
    package mutating func _checkUnique() -> Bool {
      _isKnownUniquelyReferenced_LV2()
    }
  }
#endif

extension RedBlackTreeDictionary {

  package func ___node_positions() -> ___SafePointersUnsafeV2<Base> {
    .init(tree: __tree_, start: _start, end: _end)
  }
}
extension RedBlackTreeMultiMap {

  @inlinable
  @inline(__always)
  package func ___tree_invariant() -> Bool {
    #if !WITHOUT_SIZECHECK
      __tree_.count == __tree_.___signed_distance(__tree_.__begin_node_, __tree_.end)
        && __tree_.__tree_invariant(__tree_.__root)
    #else
      __tree_.__tree_invariant(__tree_.__root)
    #endif
  }
}

extension RedBlackTreeMultiMap {

  @inlinable
  @inline(__always)
  package func ___is_garbaged(_ index: Index) -> Bool {
    __tree_.___is_garbaged(index.rawValue(__tree_))
  }
}

#if AC_COLLECTIONS_INTERNAL_CHECKS
  extension RedBlackTreeMultiMap {

    package var _copyCount: UInt {
      get { __tree_.copyCount }
      set { __tree_.copyCount = newValue }
    }
  }

  extension RedBlackTreeMultiMap {
    package mutating func _checkUnique() -> Bool {
      _isKnownUniquelyReferenced_LV2()
    }
  }
#endif

extension RedBlackTreeMultiMap {

  package func ___node_positions() -> ___SafePointersUnsafeV2<Base> {
    .init(tree: __tree_, start: _start, end: _end)
  }
}
extension RedBlackTreeMultiSet {

  @inlinable
  @inline(__always)
  package func ___tree_invariant() -> Bool {
    #if !WITHOUT_SIZECHECK
      __tree_.count == __tree_.___signed_distance(__tree_.__begin_node_, __tree_.end)
        && __tree_.__tree_invariant(__tree_.__root)
    #else
      __tree_.__tree_invariant(__tree_.__root)
    #endif
  }
}

extension RedBlackTreeMultiSet {

  @inlinable
  @inline(__always)
  package func ___is_garbaged(_ index: Index) -> Bool {
    __tree_.___is_garbaged(index.rawValue(__tree_))
  }
}

#if AC_COLLECTIONS_INTERNAL_CHECKS
  extension RedBlackTreeMultiSet {

    package var _copyCount: UInt {
      get { __tree_.copyCount }
      set { __tree_.copyCount = newValue }
    }
  }

  extension RedBlackTreeMultiSet {
    package mutating func _checkUnique() -> Bool {
      _isKnownUniquelyReferenced_LV2()
    }
  }
#endif

extension RedBlackTreeMultiSet {

  package func ___node_positions() -> ___SafePointersUnsafeV2<Base> {
    .init(tree: __tree_, start: _start, end: _end)
  }
}
extension RedBlackTreeSet {

  @inlinable
  @inline(__always)
  package func ___tree_invariant() -> Bool {
    #if !WITHOUT_SIZECHECK
      __tree_.count == __tree_.___signed_distance(__tree_.__begin_node_, __tree_.end)
        && __tree_.__tree_invariant(__tree_.__root)
    #else
      __tree_.__tree_invariant(__tree_.__root)
    #endif
  }
}

extension RedBlackTreeSet {

  @inlinable
  @inline(__always)
  package func ___is_garbaged(_ index: Index) -> Bool {
    __tree_.___is_garbaged(index.rawValue(__tree_))
  }
}

#if AC_COLLECTIONS_INTERNAL_CHECKS
  extension RedBlackTreeSet {
    package var _copyCount: UInt {
      get { __tree_.copyCount }
      set { __tree_.copyCount = newValue }
    }
  }

  extension RedBlackTreeSet {
    package mutating func _checkUnique() -> Bool {
      _isKnownUniquelyReferenced_LV2()
    }
  }
#endif

extension RedBlackTreeSet {

  package func ___node_positions() -> ___SafePointersUnsafeV2<Base> {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension RedBlackTreeSliceV2 {

  package func ___node_positions() -> ___SafePointersUnsafeV2<Base> {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension RedBlackTreeSliceV2.KeyValue {

    package func ___node_positions() -> ___SafePointersUnsafeV2<Base> {
      .init(tree: __tree_, start: _start, end: _end)
    }
}

import Foundation

@frozen
public struct RedBlackTreeDictionary<Key: Comparable, Value> {

  public
    typealias Index = Tree.Index

  public
    typealias KeyValue = (key: Key, value: Value)

  public
    typealias Element = (key: Key, value: Value)

  public
    typealias Keys = RedBlackTreeIteratorV2<Self>.Keys

  public
    typealias Values = RedBlackTreeIteratorV2<Self>.MappedValues

  public
    typealias _Key = Key

  public
    typealias _MappedValue = Value

  public
    typealias _Value = RedBlackTreePair<Key, Value>

#if !USE_SIMPLE_COPY_ON_WRITE || COMPATIBLE_ATCODER_2025
  @usableFromInline
  var referenceCounter: ReferenceCounter
#endif
  
#if !USE_SIMPLE_COPY_ON_WRITE || COMPATIBLE_ATCODER_2025
  @usableFromInline
  var __tree_: Tree {
    didSet { referenceCounter = .create() }
  }
#else
  @usableFromInline
  var __tree_: Tree
#endif

  @inlinable @inline(__always)
  internal init(__tree_: Tree) {
    self.__tree_ = __tree_
#if !USE_SIMPLE_COPY_ON_WRITE || COMPATIBLE_ATCODER_2025
    referenceCounter = .create()
#endif
  }
}

extension RedBlackTreeDictionary {
  public typealias Base = Self
}

extension RedBlackTreeDictionary: ___RedBlackTreeKeyValuesBase {}
extension RedBlackTreeDictionary: CompareUniqueTrait {}
extension RedBlackTreeDictionary: KeyValueComparer {}


extension RedBlackTreeDictionary {

  @inlinable
  @inline(__always)
  public init() {
    self.init(__tree_: .create(minimumCapacity: 0))
  }

  @inlinable
  @inline(__always)
  public init(minimumCapacity: Int) {
    self.init(__tree_: .create(minimumCapacity: minimumCapacity))
  }
}

extension RedBlackTreeDictionary {

  @inlinable
  public init<S>(uniqueKeysWithValues keysAndValues: __owned S)
  where S: Sequence, S.Element == (Key, Value) {

    self.init(__tree_: .create_unique(
        sorted: keysAndValues.sorted { $0.0 < $1.0 },
        transform: Self.___tree_value
      ))
  }
}

extension RedBlackTreeDictionary {

  @inlinable
  public init<S>(
    _ keysAndValues: __owned S,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows where S: Sequence, S.Element == (Key, Value) {

    self.init(__tree_: try .create_unique(
        sorted: keysAndValues.sorted { $0.0 < $1.0 },
        uniquingKeysWith: combine,
        transform: Self.___tree_value
      ))
  }
}

extension RedBlackTreeDictionary {

  @inlinable
  public init<S: Sequence>(
    grouping values: __owned S,
    by keyForValue: (S.Element) throws -> Key
  ) rethrows where Value == [S.Element] {

    self.init(__tree_: try .create_unique(
        sorted: try values.sorted {
          try keyForValue($0) < keyForValue($1)
        },
        by: keyForValue
      ))
  }
}


extension RedBlackTreeDictionary {

  @inlinable
  @inline(__always)
  public var isEmpty: Bool {
    ___is_empty
  }

  @inlinable
  @inline(__always)
  public var capacity: Int {
    ___capacity
  }

  @inlinable
  @inline(__always)
  public var count: Int {
    ___count
  }
}

extension RedBlackTreeDictionary {

  @inlinable
  public func count(forKey key: Key) -> Int {
    __tree_.__count_unique(key)
  }
}


extension RedBlackTreeDictionary {

  @inlinable
  public func contains(key: Key) -> Bool {
    ___contains(key)
  }
}


extension RedBlackTreeDictionary {

  @inlinable
  @inline(__always)
  public var first: Element? {
    ___first
  }

  @inlinable
  public var last: Element? {
    ___last
  }
}

extension RedBlackTreeDictionary {

  @frozen
  @usableFromInline
  struct ___ModifyHelper {
    @inlinable
    @inline(__always)
    init(pointer: UnsafeMutablePointer<Value>) {
      self.pointer = pointer
    }
    @usableFromInline
    var isNil: Bool = false
    @usableFromInline
    var pointer: UnsafeMutablePointer<Value>
    @inlinable
    var value: Value? {
      @inline(__always) _read {
        yield isNil ? nil : pointer.pointee
      }
      @inline(__always) _modify {
        var value: Value? = pointer.move()
        defer {
          if let value {
            isNil = false
            pointer.initialize(to: value)
          } else {
            isNil = true
          }
        }
        yield &value
      }
    }
  }

  @inlinable
  public subscript(key: Key) -> Value? {
    @inline(__always) _read {
      yield ___value_for(key)?.value
    }
    @inline(__always) _modify {
      _ensureUniqueAndCapacity()
      let (__parent, __child, __ptr) = _prepareForKeyingModify(key)
      if __ptr == __tree_.nullptr {
        var value: Value?
        defer {
          if let value {
            let __h = __tree_.__construct_node(Self.___tree_value((key, value)))
            __tree_.__insert_node_at(__parent, __child, __h)
          }
        }
        yield &value
      } else {
        var helper = ___ModifyHelper(pointer: &__tree_[__ptr].value)
        defer {
          if helper.isNil {
            _ = __tree_.erase(__ptr)
          }
        }
        yield &helper.value
      }
    }
  }

  @inlinable
  public subscript(
    key: Key, default defaultValue: @autoclosure () -> Value
  ) -> Value {
    @inline(__always) _read {
      yield ___value_for(key)?.value ?? defaultValue()
    }
    @inline(__always) _modify {
      defer { _fixLifetime(self) }
      _ensureUniqueAndCapacity()
      var (__parent, __child, __ptr) = _prepareForKeyingModify(key)
      if __ptr == __tree_.nullptr {
        assert(__tree_.capacity > __tree_.count)
        __ptr = __tree_.__construct_node(Self.___tree_value((key, defaultValue())))
        __tree_.__insert_node_at(__parent, __child, __ptr)
      } else {
        _ensureUnique()
      }
      yield &__tree_[__ptr].value
    }
  }

  @inlinable
  @inline(__always)
  internal func _prepareForKeyingModify(
    _ key: Key
  ) -> (__parent: Tree._NodePtr, __child: Tree._NodeRef, __ptr: Tree._NodePtr) {
    let (__parent, __child) = __tree_.__find_equal(key)
    let __ptr = __tree_.__ptr_(__child)
    return (__parent, __child, __ptr)
  }
}


extension RedBlackTreeDictionary {

  @inlinable
  @inline(__always)
  public subscript(bounds: Range<Index>) -> SubSequence {
    __tree_.___ensureValid(
      begin: bounds.lowerBound.rawValue(__tree_),
      end: bounds.upperBound.rawValue(__tree_))

    return .init(
      tree: __tree_,
      start: bounds.lowerBound.rawValue(__tree_),
      end: bounds.upperBound.rawValue(__tree_))
  }

  #if !COMPATIBLE_ATCODER_2025
    @inlinable
    @inline(__always)
    public subscript<R>(bounds: R) -> SubSequence where R: RangeExpression, R.Bound == Index {
      let bounds: Range<Index> = bounds.relative(to: self)

      __tree_.___ensureValid(
        begin: bounds.lowerBound.rawValue(__tree_),
        end: bounds.upperBound.rawValue(__tree_))

      return .init(
        tree: __tree_,
        start: bounds.lowerBound.rawValue(__tree_),
        end: bounds.upperBound.rawValue(__tree_))
    }

    @inlinable
    @inline(__always)
    public subscript(unchecked bounds: Range<Index>) -> SubSequence {
      .init(
        tree: __tree_,
        start: bounds.lowerBound.rawValue(__tree_),
        end: bounds.upperBound.rawValue(__tree_))
    }

    @inlinable
    @inline(__always)
    public subscript<R>(unchecked bounds: R) -> SubSequence
    where R: RangeExpression, R.Bound == Index {
      let bounds: Range<Index> = bounds.relative(to: self)
      return .init(
        tree: __tree_,
        start: bounds.lowerBound.rawValue(__tree_),
        end: bounds.upperBound.rawValue(__tree_))
    }
  #endif
}


extension RedBlackTreeDictionary {

  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func insert(key: Key, value: Value) -> (
    inserted: Bool, memberAfterInsert: Element
  ) {
    insert((key, value))
  }

  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func insert(_ newMember: Element) -> (
    inserted: Bool, memberAfterInsert: Element
  ) {
    _ensureUniqueAndCapacity()
    let (__r, __inserted) = __tree_.__insert_unique(Self.___tree_value(newMember))
    return (__inserted, __inserted ? newMember : ___element(__tree_[__r]))
  }
}

extension RedBlackTreeDictionary {

  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func updateValue(
    _ value: Value,
    forKey key: Key
  ) -> Value? {
    _ensureUniqueAndCapacity()
    let (__r, __inserted) = __tree_.__insert_unique(Self.___tree_value((key, value)))
    guard !__inserted else { return nil }
    let oldMember = __tree_[__r]
    __tree_[__r] = Self.___tree_value((key, value))
    return oldMember.value
  }
}

extension RedBlackTreeDictionary {

  @inlinable
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    _ensureUniqueAndCapacity(to: minimumCapacity)
  }
}


extension RedBlackTreeDictionary {

  @inlinable
  public mutating func merge(
    _ other: RedBlackTreeDictionary<Key, Value>,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows {

    try _ensureUnique { __tree_ in
      try .___insert_range_unique(
        tree: __tree_,
        other: other.__tree_,
        other.__tree_.__begin_node_,
        other.__tree_.__end_node,
        uniquingKeysWith: combine)
    }
  }

  @inlinable
  public mutating func merge<S>(
    _ other: __owned S,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows where S: Sequence, S.Element == (Key, Value) {

    try _ensureUnique { __tree_ in
      try .___insert_range_unique(
        tree: __tree_,
        other,
        uniquingKeysWith: combine
      ) { Self.___tree_value($0) }
    }
  }

  @inlinable
  public func merging(
    _ other: RedBlackTreeDictionary<Key, Value>,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows -> Self {
    var result = self
    try result.merge(other, uniquingKeysWith: combine)
    return result
  }

  @inlinable
  public func merging<S>(
    _ other: __owned S,
    uniquingKeysWith combine: (Value, Value) throws -> Value
  ) rethrows -> Self where S: Sequence, S.Element == (Key, Value) {
    var result = self
    try result.merge(other, uniquingKeysWith: combine)
    return result
  }
}


extension RedBlackTreeDictionary {

  @inlinable
  @inline(__always)
  public mutating func popFirst() -> KeyValue? {
    guard !isEmpty else { return nil }
    return remove(at: startIndex)
  }
}

extension RedBlackTreeDictionary {

  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func removeValue(forKey __k: Key) -> Value? {
    let __i = __tree_.find(__k)
    if __i == __tree_.end {
      return nil
    }
    let value = __tree_.__value_(__i).value
    _ensureUnique()
    _ = __tree_.erase(__i)
    return value
  }

  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func removeFirst() -> Element {
    guard !isEmpty else {
      preconditionFailure(.emptyFirst)
    }
    return remove(at: startIndex)
  }

  @inlinable
  @discardableResult
  public mutating func removeLast() -> Element {
    guard !isEmpty else {
      preconditionFailure(.emptyLast)
    }
    return remove(at: index(before: endIndex))
  }

  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func remove(at index: Index) -> Element {
    _ensureUnique()
    guard let element = ___remove(at: index.rawValue(__tree_)) else {
      fatalError(.invalidIndex)
    }
    return ___element(element)
  }

  @inlinable
  public mutating func removeSubrange<R: RangeExpression>(
    _ bounds: R
  ) where R.Bound == Index {

    let bounds = bounds.relative(to: self)
    _ensureUnique()
    ___remove(
      from: bounds.lowerBound.rawValue(__tree_),
      to: bounds.upperBound.rawValue(__tree_))
  }
}

extension RedBlackTreeDictionary {

  @inlinable
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    _ensureUnique()
    ___removeAll(keepingCapacity: keepCapacity)
  }
}


extension RedBlackTreeDictionary {

  @inlinable
  public func lowerBound(_ p: Key) -> Index {
    ___index_lower_bound(p)
  }

  @inlinable
  public func upperBound(_ p: Key) -> Index {
    ___index_upper_bound(p)
  }
}

extension RedBlackTreeDictionary {

  @inlinable
  public func equalRange(_ key: Key) -> (lower: Index, upper: Index) {
    ___index_equal_range(key)
  }
}

extension RedBlackTreeDictionary {

  @inlinable
  public func min() -> Element? {
    ___min()
  }

  @inlinable
  public func max() -> Element? {
    ___max()
  }
}

extension RedBlackTreeDictionary {

  @inlinable
  public func first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
    try ___first(where: predicate)
  }
}

extension RedBlackTreeDictionary {

  @inlinable
  public func firstIndex(of key: Key) -> Index? {
    ___first_index(of: key)
  }

  @inlinable
  public func firstIndex(where predicate: (Element) throws -> Bool) rethrows -> Index? {
    try ___first_index(where: predicate)
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionary {
    @inlinable
    public func sequence(from start: Key, to end: Key) -> SubSequence {
      .init(tree: __tree_, start: ___lower_bound(start), end: ___lower_bound(end))
    }

    @inlinable
    public func sequence(from start: Key, through end: Key) -> SubSequence {
      .init(tree: __tree_, start: ___lower_bound(start), end: ___upper_bound(end))
    }
  }
#endif


extension RedBlackTreeDictionary {

  @inlinable
  public func filter(
    _ isIncluded: (Element) throws -> Bool
  ) rethrows -> Self {
    .init(__tree_: try __tree_.___filter(_start, _end) {
          try isIncluded(___element($0))
        })
  }
}

extension RedBlackTreeDictionary {

  @inlinable
  public func mapValues<T>(_ transform: (Value) throws -> T) rethrows
    -> RedBlackTreeDictionary<Key, T>
  {
    .init(__tree_:  try __tree_.___mapValues(_start, _end, transform))
  }

  @inlinable
  public func compactMapValues<T>(_ transform: (Value) throws -> T?)
    rethrows -> RedBlackTreeDictionary<Key, T>
  {
    .init(__tree_: try __tree_.___compactMapValues(_start, _end, transform))
  }
}



extension RedBlackTreeDictionary: Sequence, Collection, BidirectionalCollection {

  @inlinable
  @inline(__always)
  public func makeIterator() -> Tree._KeyValues {
    _makeIterator()
  }

  @inlinable
  @inline(__always)
  public func forEach(_ body: (Element) throws -> Void) rethrows {
    try _forEach(body)
  }

  @inlinable
  @inline(__always)
  public func forEach(_ body: (Index, Element) throws -> Void) rethrows {
    try _forEach(body)
  }

  #if !COMPATIBLE_ATCODER_2025
    @inlinable
    @inline(__always)
    public func sorted() -> [Element] {
      _sorted()
    }
  #endif

  @inlinable
  @inline(__always)
  public var startIndex: Index { _startIndex }

  @inlinable
  @inline(__always)
  public var endIndex: Index { _endIndex }

  @inlinable
  public func distance(from start: Index, to end: Index) -> Int {
    _distance(from: start, to: end)
  }

  @inlinable
  @inline(__always)
  public func index(after i: Index) -> Index {
    _index(after: i)
  }

  @inlinable
  @inline(__always)
  public func formIndex(after i: inout Index) {
    _formIndex(after: &i)
  }

  @inlinable
  @inline(__always)
  public func index(before i: Index) -> Index {
    _index(before: i)
  }

  @inlinable
  @inline(__always)
  public func formIndex(before i: inout Index) {
    _formIndex(before: &i)
  }

  @inlinable
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    _index(i, offsetBy: distance)
  }

  @inlinable
  public func formIndex(_ i: inout Index, offsetBy distance: Int) {
    _formIndex(&i, offsetBy: distance)
  }

  @inlinable
  public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
    _index(i, offsetBy: distance, limitedBy: limit)
  }

  @inlinable
  public func formIndex(_ i: inout Index, offsetBy distance: Int, limitedBy limit: Index)
    -> Bool
  {
    _formIndex(&i, offsetBy: distance, limitedBy: limit)
  }

  /*
   しばらく苦しめられていたテストコードのコンパイルエラーについて。
  
   typecheckでクラッシュしてることはクラッシュログから読み取れる。
   推論に失敗するバグを踏んでいると想定し、型をちゃんと書くことで様子を見ることにした。
  
   型推論のバグなんて直せる気がまったくせず、ごくごく一部の天才のミラクルムーブ期待なので、
   これでクラッシュが落ち着くようならElementを返すメンバー全てで型をちゃんと書くのが安全かもしれない
  
   type packは型を書けないケースなので、この迂回策が使えず、バグ修正を待つばかり
   */

  @inlinable
  public subscript(position: Index) -> (key: Key, value: Value) {
    @inline(__always) get { self[_checked: position] }
  }

  #if !COMPATIBLE_ATCODER_2025
    @inlinable
    public subscript(unchecked position: Index) -> (key: Key, value: Value) {
      @inline(__always) get { self[_unchecked: position] }
    }
  #endif

  @inlinable
  @inline(__always)
  public func isValid(index: Index) -> Bool {
    _isValid(index: index)
  }

  @inlinable
  @inline(__always)
  public func isValid<R: RangeExpression>(_ bounds: R) -> Bool
  where R.Bound == Index {
    _isValid(bounds)
  }

  @inlinable
  @inline(__always)
  public func reversed() -> Tree._KeyValues.Reversed {
    _reversed()
  }

  @inlinable
  @inline(__always)
  public var indices: Indices {
    _indices
  }
}


extension RedBlackTreeDictionary {

  #if !COMPATIBLE_ATCODER_2025
    @inlinable
    @inline(__always)
    public var keys: Keys {
      _keys()
    }

    @inlinable
    @inline(__always)
    public var values: Values {
      _values()
    }
  #endif
}


extension RedBlackTreeDictionary {

  public typealias SubSequence = RedBlackTreeSliceV2<Self>.KeyValue
}


extension RedBlackTreeDictionary {

  public typealias Indices = Tree.Indices
}


extension RedBlackTreeDictionary: ExpressibleByDictionaryLiteral {

  @inlinable
  @inline(__always)
  public init(dictionaryLiteral elements: (Key, Value)...) {
    self.init(uniqueKeysWithValues: elements)
  }
}


extension RedBlackTreeDictionary: ExpressibleByArrayLiteral {

  @inlinable
  @inline(__always)
  public init(arrayLiteral elements: (Key, Value)...) {
    self.init(uniqueKeysWithValues: elements)
  }
}


extension RedBlackTreeDictionary: CustomStringConvertible {

  @inlinable
  public var description: String {
    _dictionaryDescription(for: self)
  }
}


extension RedBlackTreeDictionary: CustomDebugStringConvertible {

  public var debugDescription: String {
    description
  }
}


extension RedBlackTreeDictionary: CustomReflectable {
  public var customMirror: Mirror {
    Mirror(self, unlabeledChildren: self, displayStyle: .dictionary)
  }
}


extension RedBlackTreeDictionary {

  @inlinable
  @inline(__always)
  public func isIdentical(to other: Self) -> Bool {
    _isIdentical(to: other)
  }
}


extension RedBlackTreeDictionary: Equatable where Value: Equatable {

  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.__tree_ == rhs.__tree_
  }
}


extension RedBlackTreeDictionary: Comparable where Value: Comparable {

  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.__tree_ < rhs.__tree_
  }
}


extension RedBlackTreeDictionary: Hashable where Key: Hashable, Value: Hashable {

  @inlinable
  @inline(__always)
  public func hash(into hasher: inout Hasher) {
    hasher.combine(__tree_)
  }
}


#if swift(>=5.5)
  extension RedBlackTreeDictionary: @unchecked Sendable
  where Key: Sendable, Value: Sendable {}
#endif


#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionary: Encodable where Key: Encodable, Value: Encodable {

    @inlinable
    public func encode(to encoder: Encoder) throws {
      var container = encoder.unkeyedContainer()
      for element in __tree_.unsafeValues(__tree_.__begin_node_, __tree_.__end_node) {
        try container.encode(element)
      }
    }
  }

  extension RedBlackTreeDictionary: Decodable where Key: Decodable, Value: Decodable {

    @inlinable
    public init(from decoder: Decoder) throws {
      self.init(__tree_: try .create(from: decoder))
    }
  }
#endif


#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeDictionary {

    @inlinable
    public init<Source>(naive sequence: __owned Source)
    where Element == Source.Element, Source: Sequence {
      self.init(__tree_: .create_unique(naive: sequence, transform: Self.___tree_value))
    }
  }
#endif

import Foundation

@frozen
public struct RedBlackTreeMultiMap<Key: Comparable, Value> {

  public
    typealias Index = Tree.Index

  #if COMPATIBLE_ATCODER_2025
    public
      typealias KeyValue = (key: Key, value: Value)
  #endif

  public
    typealias Element = (key: Key, value: Value)

  public
    typealias Keys = RedBlackTreeIteratorV2<Self>.Keys

  public
    typealias Values = RedBlackTreeIteratorV2<Self>.MappedValues

  public
    typealias _Key = Key

  public
    typealias _MappedValue = Value

  public
    typealias _Value = RedBlackTreePair<Key, Value>

#if !USE_SIMPLE_COPY_ON_WRITE || COMPATIBLE_ATCODER_2025
  @usableFromInline
  var referenceCounter: ReferenceCounter
#endif
  
#if !USE_SIMPLE_COPY_ON_WRITE || COMPATIBLE_ATCODER_2025
  @usableFromInline
  var __tree_: Tree {
    didSet { referenceCounter = .create() }
  }
#else
  @usableFromInline
  var __tree_: Tree
#endif

  @inlinable @inline(__always)
  internal init(__tree_: Tree) {
    self.__tree_ = __tree_
#if !USE_SIMPLE_COPY_ON_WRITE || COMPATIBLE_ATCODER_2025
    referenceCounter = .create()
#endif
  }
}

extension RedBlackTreeMultiMap {
  public typealias Base = Self
}

extension RedBlackTreeMultiMap: ___RedBlackTreeKeyValuesBase {}
extension RedBlackTreeMultiMap: CompareMultiTrait {}
extension RedBlackTreeMultiMap: KeyValueComparer {}


extension RedBlackTreeMultiMap {

  @inlinable @inline(__always)
  public init() {
    self.init(__tree_: .create(minimumCapacity: 0))
  }

  @inlinable @inline(__always)
  public init(minimumCapacity: Int) {
    self.init(__tree_: .create(minimumCapacity: minimumCapacity))
  }
}

extension RedBlackTreeMultiMap {

  @inlinable
  public init<S>(multiKeysWithValues keysAndValues: __owned S)
  where S: Sequence, S.Element == (Key, Value) {
    self.init(__tree_:
        .create_multi(sorted: keysAndValues.sorted { $0.0 < $1.0 }) {
          Self.___tree_value($0)
        })
  }
}

extension RedBlackTreeMultiMap {

  @inlinable
  public init<S: Sequence>(
    grouping values: __owned S,
    by keyForValue: (S.Element) throws -> Key
  ) rethrows where Value == S.Element {
    self.init(__tree_: try .create_multi(
        sorted: try values.sorted {
          try keyForValue($0) < keyForValue($1)
        },
        by: keyForValue
      ))
  }
}


extension RedBlackTreeMultiMap {

  @inlinable
  @inline(__always)
  public var isEmpty: Bool {
    ___is_empty
  }

  @inlinable
  @inline(__always)
  public var capacity: Int {
    ___capacity
  }

  @inlinable
  @inline(__always)
  public var count: Int {
    ___count
  }
}

extension RedBlackTreeMultiMap {

  @inlinable
  public func count(forKey key: Key) -> Int {
    __tree_.__count_multi(key)
  }
}


extension RedBlackTreeMultiMap {

  @inlinable
  public func contains(key: Key) -> Bool {
    ___contains(key)
  }
}


extension RedBlackTreeMultiMap {

  @inlinable
  @inline(__always)
  public var first: Element? {
    ___first
  }

  @inlinable
  @inline(__always)
  public var last: Element? {
    ___last
  }
}

extension RedBlackTreeMultiMap {

  @inlinable
  public func values(forKey key: Key) -> Values {
    let (lo, hi) = __tree_.__equal_range_multi(key)
    return .init(tree: __tree_, start: lo, end: hi)
  }
}


extension RedBlackTreeMultiMap {

  @inlinable
  @inline(__always)
  public subscript(bounds: Range<Index>) -> SubSequence {
    __tree_.___ensureValid(
      begin: bounds.lowerBound.rawValue(__tree_),
      end: bounds.upperBound.rawValue(__tree_))

    return .init(
      tree: __tree_,
      start: bounds.lowerBound.rawValue(__tree_),
      end: bounds.upperBound.rawValue(__tree_))
  }

  #if !COMPATIBLE_ATCODER_2025
    @inlinable
    @inline(__always)
    public subscript<R>(bounds: R) -> SubSequence where R: RangeExpression, R.Bound == Index {
      let bounds: Range<Index> = bounds.relative(to: self)

      __tree_.___ensureValid(
        begin: bounds.lowerBound.rawValue(__tree_),
        end: bounds.upperBound.rawValue(__tree_))

      return .init(
        tree: __tree_,
        start: bounds.lowerBound.rawValue(__tree_),
        end: bounds.upperBound.rawValue(__tree_))
    }

    @inlinable
    @inline(__always)
    public subscript(unchecked bounds: Range<Index>) -> SubSequence {
      .init(
        tree: __tree_,
        start: bounds.lowerBound.rawValue(__tree_),
        end: bounds.upperBound.rawValue(__tree_))
    }

    @inlinable
    @inline(__always)
    public subscript<R>(unchecked bounds: R) -> SubSequence
    where R: RangeExpression, R.Bound == Index {
      let bounds: Range<Index> = bounds.relative(to: self)
      return .init(
        tree: __tree_,
        start: bounds.lowerBound.rawValue(__tree_),
        end: bounds.upperBound.rawValue(__tree_))
    }
  #endif
}


extension RedBlackTreeMultiMap {

  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func insert(key: Key, value: Value) -> (
    inserted: Bool, memberAfterInsert: Element
  ) {
    insert((key, value))
  }

  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func insert(_ newMember: Element) -> (
    inserted: Bool, memberAfterInsert: Element
  ) {
    _ensureUniqueAndCapacity()
    _ = __tree_.__insert_multi(Self.___tree_value(newMember))
    return (true, newMember)
  }
}

extension RedBlackTreeMultiMap {

  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func updateValue(_ newValue: Value, at ptr: Index) -> Element? {
    guard !__tree_.___is_subscript_null(ptr.rawValue(__tree_)) else {
      return nil
    }
    _ensureUnique()
    let old = __tree_[ptr.rawValue(__tree_)]
    __tree_[ptr.rawValue(__tree_)].value = newValue
    return ___element(old)
  }
}

extension RedBlackTreeMultiMap {

  @inlinable
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    _ensureUniqueAndCapacity(to: minimumCapacity)
  }
}


extension RedBlackTreeMultiMap {

  @inlinable
  public mutating func insert(contentsOf other: RedBlackTreeMultiMap<Key, Value>) {
    _ensureUnique { __tree_ in
      .___insert_range_multi(
        tree: __tree_,
        other: other.__tree_,
        other.__tree_.__begin_node_,
        other.__tree_.__end_node)
    }
  }

  @inlinable
  public mutating func insert<S>(contentsOf other: S) where S: Sequence, S.Element == (Key, Value) {
    _ensureUnique { __tree_ in
      .___insert_range_multi(tree: __tree_, other.map { Self.___tree_value($0) })
    }
  }

  @inlinable
  public func inserting(contentsOf other: RedBlackTreeMultiMap<Key, Value>) -> Self {
    var result = self
    result.insert(contentsOf: other)
    return result
  }

  @inlinable
  public func inserting<S>(contentsOf other: __owned S) -> Self
  where S: Sequence, S.Element == (Key, Value) {
    var result = self
    result.insert(contentsOf: other)
    return result
  }
}

extension RedBlackTreeMultiMap {

  @inlinable
  @inline(__always)
  public mutating func meld(_ other: __owned RedBlackTreeMultiMap<Key, Value>) {
    __tree_ = __tree_.___meld_multi(other.__tree_)
  }

  @inlinable
  @inline(__always)
  public func melding(_ other: __owned RedBlackTreeMultiMap<Key, Value>)
    -> RedBlackTreeMultiMap<Key, Value>
  {
    var result = self
    result.meld(other)
    return result
  }
}

extension RedBlackTreeMultiMap {

  @inlinable
  @inline(__always)
  public static func + (lhs: Self, rhs: Self) -> Self {
    lhs.inserting(contentsOf: rhs)
  }

  @inlinable
  @inline(__always)
  public static func += (lhs: inout Self, rhs: Self) {
    lhs.insert(contentsOf: rhs)
  }
}


extension RedBlackTreeMultiMap {
  @inlinable
  @inline(__always)
  public mutating func popFirst() -> Element? {
    guard !isEmpty else { return nil }
    return remove(at: startIndex)
  }
}

extension RedBlackTreeMultiMap {

  @inlinable
  @discardableResult
  public mutating func removeFirst(forKey key: Key) -> Bool {
    _strongEnsureUnique()
    return __tree_.___erase_unique(key)
  }

  @inlinable
  @discardableResult
  public mutating func removeFirst(_unsafeForKey key: Key) -> Bool {
    _ensureUnique()
    return __tree_.___erase_unique(key)
  }

  @inlinable
  @discardableResult
  public mutating func removeAll(forKey key: Key) -> Int {
    _strongEnsureUnique()
    return __tree_.___erase_multi(key)
  }

  @inlinable
  @discardableResult
  public mutating func removeAll(_unsafeForKey key: Key) -> Int {
    _ensureUnique()
    return __tree_.___erase_multi(key)
  }
}

extension RedBlackTreeMultiMap {

  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func removeFirst() -> Element {
    guard !isEmpty else {
      preconditionFailure(.emptyFirst)
    }
    return remove(at: startIndex)
  }

  @inlinable
  @discardableResult
  public mutating func removeLast() -> Element {
    guard !isEmpty else {
      preconditionFailure(.emptyLast)
    }
    return remove(at: index(before: endIndex))
  }

  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func remove(at index: Index) -> Element {
    _ensureUnique()
    guard let element = ___remove(at: index.rawValue(__tree_)) else {
      fatalError(.invalidIndex)
    }
    return ___element(element)
  }

  @inlinable
  public mutating func removeSubrange<R: RangeExpression>(
    _ bounds: R
  ) where R.Bound == Index {

    let bounds = bounds.relative(to: self)
    _ensureUnique()
    ___remove(
      from: bounds.lowerBound.rawValue(__tree_),
      to: bounds.upperBound.rawValue(__tree_))
  }
}

extension RedBlackTreeMultiMap {

  @inlinable
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    _ensureUnique()
    ___removeAll(keepingCapacity: keepCapacity)
  }
}


extension RedBlackTreeMultiMap {

  @inlinable
  public func lowerBound(_ p: Key) -> Index {
    ___index_lower_bound(p)
  }

  @inlinable
  public func upperBound(_ p: Key) -> Index {
    ___index_upper_bound(p)
  }
}

extension RedBlackTreeMultiMap {

  @inlinable
  public func equalRange(_ key: Key) -> (lower: Index, upper: Index) {
    ___index_equal_range(key)
  }
}

extension RedBlackTreeMultiMap {

  @inlinable
  public func min() -> Element? {
    ___min()
  }

  @inlinable
  public func max() -> Element? {
    ___max()
  }
}

extension RedBlackTreeMultiMap {

  @inlinable
  public func first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
    try ___first(where: predicate)
  }
}

extension RedBlackTreeMultiMap {

  @inlinable
  public func firstIndex(of key: Key) -> Index? {
    ___first_index(of: key)
  }

  @inlinable
  public func firstIndex(where predicate: (Element) throws -> Bool) rethrows -> Index? {
    try ___first_index(where: predicate)
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap {
    @inlinable
    public func sequence(from start: Key, to end: Key) -> SubSequence {
      .init(tree: __tree_, start: ___lower_bound(start), end: ___lower_bound(end))
    }

    @inlinable
    public func sequence(from start: Key, through end: Key) -> SubSequence {
      .init(tree: __tree_, start: ___lower_bound(start), end: ___upper_bound(end))
    }
  }
#endif


extension RedBlackTreeMultiMap {

  @inlinable
  public func filter(
    _ isIncluded: (Element) throws -> Bool
  ) rethrows -> Self {
    .init(__tree_: try __tree_.___filter(_start, _end) {
          try isIncluded(___element($0))
        }
      )
  }
}

extension RedBlackTreeMultiMap {

  @inlinable
  public func mapValues<T>(_ transform: (Value) throws -> T) rethrows
    -> RedBlackTreeMultiMap<Key, T>
  {
    .init(__tree_: try __tree_.___mapValues(_start, _end, transform))
  }

  @inlinable
  public func compactMapValues<T>(_ transform: (Value) throws -> T?)
    rethrows -> RedBlackTreeMultiMap<Key, T>
  {
    .init(__tree_: try __tree_.___compactMapValues(_start, _end, transform))
  }
}


extension RedBlackTreeMultiMap: Sequence, Collection, BidirectionalCollection {

  @inlinable
  @inline(__always)
  public func makeIterator() -> Tree._KeyValues {
    _makeIterator()
  }

  @inlinable
  @inline(__always)
  public func forEach(_ body: (Element) throws -> Void) rethrows {
    try _forEach(body)
  }

  @inlinable
  @inline(__always)
  public func forEach(_ body: (Index, Element) throws -> Void) rethrows {
    try _forEach(body)
  }

  #if !COMPATIBLE_ATCODER_2025
    @inlinable
    @inline(__always)
    public func sorted() -> [Element] {
      _sorted()
    }
  #endif

  @inlinable
  @inline(__always)
  public var startIndex: Index { _startIndex }

  @inlinable
  @inline(__always)
  public var endIndex: Index { _endIndex }

  @inlinable
  public func distance(from start: Index, to end: Index) -> Int {
    _distance(from: start, to: end)
  }

  @inlinable
  @inline(__always)
  public func index(after i: Index) -> Index {
    _index(after: i)
  }

  @inlinable
  @inline(__always)
  public func formIndex(after i: inout Index) {
    _formIndex(after: &i)
  }

  @inlinable
  @inline(__always)
  public func index(before i: Index) -> Index {
    _index(before: i)
  }

  @inlinable
  @inline(__always)
  public func formIndex(before i: inout Index) {
    _formIndex(before: &i)
  }

  @inlinable
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    _index(i, offsetBy: distance)
  }

  @inlinable
  public func formIndex(_ i: inout Index, offsetBy distance: Int) {
    _formIndex(&i, offsetBy: distance)
  }

  @inlinable
  public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
    _index(i, offsetBy: distance, limitedBy: limit)
  }

  @inlinable
  public func formIndex(_ i: inout Index, offsetBy distance: Int, limitedBy limit: Index)
    -> Bool
  {
    _formIndex(&i, offsetBy: distance, limitedBy: limit)
  }

  /*
   コメントアウトの多さはテストコードのコンパイラクラッシュに由来する。
   */

  @inlinable
  public subscript(position: Index) -> (key: Key, value: Value) {
    @inline(__always) get { self[_checked: position] }
  }

  #if !COMPATIBLE_ATCODER_2025
    @inlinable
    public subscript(unchecked position: Index) -> (key: Key, value: Value) {
      @inline(__always) get { self[_unchecked: position] }
    }
  #endif

  @inlinable
  @inline(__always)
  public func isValid(index: Index) -> Bool {
    _isValid(index: index)
  }

  @inlinable
  @inline(__always)
  public func isValid<R: RangeExpression>(_ bounds: R) -> Bool
  where R.Bound == Index {
    _isValid(bounds)
  }

  @inlinable
  @inline(__always)
  public func reversed() -> Tree._KeyValues.Reversed {
    _reversed()
  }

  @inlinable
  @inline(__always)
  public var indices: Indices {
    _indices
  }
}


extension RedBlackTreeMultiMap {

  #if !COMPATIBLE_ATCODER_2025
    @inlinable
    @inline(__always)
    public var keys: Keys {
      .init(tree: __tree_, start: __tree_.__begin_node_, end: __tree_.__end_node)
    }

    @inlinable
    @inline(__always)
    public var values: Values {
      .init(tree: __tree_, start: __tree_.__begin_node_, end: __tree_.__end_node)
    }
  #endif
}


extension RedBlackTreeMultiMap {

  #if COMPATIBLE_ATCODER_2025
    @inlinable
    @inline(__always)
    public subscript(key: Key) -> SubSequence {
      let (lo, hi): (_NodePtr, _NodePtr) = self.___equal_range(key)
      return .init(tree: __tree_, start: lo, end: hi)
    }
  #else
    @inlinable
    @inline(__always)
    public subscript(key: Key) -> Values {
      let (lo, hi): (_NodePtr, _NodePtr) = self.___equal_range(key)
      return .init(tree: __tree_, start: lo, end: hi)
    }
  #endif
}

extension RedBlackTreeMultiMap {

  public typealias SubSequence = RedBlackTreeSliceV2<Self>.KeyValue
}


extension RedBlackTreeMultiMap {

  public typealias Indices = Tree.Indices
}


extension RedBlackTreeMultiMap: ExpressibleByDictionaryLiteral {

  @inlinable
  @inline(__always)
  public init(dictionaryLiteral elements: (Key, Value)...) {
    self.init(multiKeysWithValues: elements)
  }
}


extension RedBlackTreeMultiMap: ExpressibleByArrayLiteral {

  @inlinable
  @inline(__always)
  public init(arrayLiteral elements: (Key, Value)...) {
    self.init(multiKeysWithValues: elements)
  }
}


extension RedBlackTreeMultiMap: CustomStringConvertible {

  @inlinable
  public var description: String {
    _dictionaryDescription(for: self)
  }
}


extension RedBlackTreeMultiMap: CustomDebugStringConvertible {

  public var debugDescription: String {
    description
  }
}


extension RedBlackTreeMultiMap: CustomReflectable {
  public var customMirror: Mirror {
    Mirror(self, unlabeledChildren: self, displayStyle: .dictionary)
  }
}


extension RedBlackTreeMultiMap {

  @inlinable
  @inline(__always)
  public func isIdentical(to other: Self) -> Bool {
    _isIdentical(to: other)
  }
}


extension RedBlackTreeMultiMap: Equatable where Value: Equatable {

  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.__tree_ == rhs.__tree_
  }
}


extension RedBlackTreeMultiMap: Comparable where Value: Comparable {

  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.__tree_ < rhs.__tree_
  }
}


extension RedBlackTreeMultiMap: Hashable where Key: Hashable, Value: Hashable {

  @inlinable
  @inline(__always)
  public func hash(into hasher: inout Hasher) {
    hasher.combine(__tree_)
  }
}


#if swift(>=5.5)
  extension RedBlackTreeMultiMap: @unchecked Sendable
  where Key: Sendable, Value: Sendable {}
#endif


#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMap: Encodable where Key: Encodable, Value: Encodable {

    @inlinable
    public func encode(to encoder: Encoder) throws {
      var container = encoder.unkeyedContainer()
      for element in __tree_.unsafeValues(__tree_.__begin_node_, __tree_.__end_node) {
        try container.encode(element)
      }
    }
  }

  extension RedBlackTreeMultiMap: Decodable where Key: Decodable, Value: Decodable {

    @inlinable
    public init(from decoder: Decoder) throws {
      self.init(__tree_: try .create(from: decoder))
    }
  }
#endif


extension RedBlackTreeMultiMap {

  @inlinable
  public init<Source>(naive sequence: __owned Source)
  where Element == Source.Element, Source: Sequence {
    self.init(__tree_: .create_multi(naive: sequence, transform: Self.___tree_value))
  }
}

import Foundation

@frozen
public struct RedBlackTreeMultiSet<Element: Comparable> {

  public
    typealias Element = Element

  public
    typealias Index = Tree.Index

  public
    typealias _Key = Element

  public
    typealias _Value = Element

#if !USE_SIMPLE_COPY_ON_WRITE || COMPATIBLE_ATCODER_2025
  @usableFromInline
  var referenceCounter: ReferenceCounter
#endif
  
#if !USE_SIMPLE_COPY_ON_WRITE || COMPATIBLE_ATCODER_2025
  @usableFromInline
  var __tree_: Tree {
    didSet { referenceCounter = .create() }
  }
#else
  @usableFromInline
  var __tree_: Tree
#endif

  @inlinable @inline(__always)
  internal init(__tree_: Tree) {
    self.__tree_ = __tree_
#if !USE_SIMPLE_COPY_ON_WRITE || COMPATIBLE_ATCODER_2025
    referenceCounter = .create()
#endif
  }
}

extension RedBlackTreeMultiSet {
  public typealias Base = Self
}

extension RedBlackTreeMultiSet: ___RedBlackTreeKeyOnlyBase {}
extension RedBlackTreeMultiSet: CompareMultiTrait {}
extension RedBlackTreeMultiSet: ScalarValueComparer {}


extension RedBlackTreeMultiSet {

  @inlinable @inline(__always)
  public init() {
    self.init(__tree_: .create(minimumCapacity: 0))
  }

  @inlinable @inline(__always)
  public init(minimumCapacity: Int) {
    self.init(__tree_: .create(minimumCapacity: minimumCapacity))
  }
}

extension RedBlackTreeMultiSet {

  @inlinable
  public init<Source>(_ sequence: __owned Source)
  where Element == Source.Element, Source: Sequence {
    self.init(__tree_: .create_multi(sorted: sequence.sorted()))
  }
}

extension RedBlackTreeMultiSet {

  @inlinable
  public init<R>(_ range: __owned R)
  where R: RangeExpression, R: Collection, R.Element == Element {
    precondition(range is Range<Element> || range is ClosedRange<Element>)
    self.init(__tree_: .create(range: range))
  }
}


extension RedBlackTreeMultiSet {

  @inlinable
  @inline(__always)
  public var isEmpty: Bool {
    ___is_empty
  }

  @inlinable
  @inline(__always)
  public var capacity: Int {
    ___capacity
  }

  @inlinable
  @inline(__always)
  public var count: Int {
    ___count
  }
}

extension RedBlackTreeMultiSet {

  @inlinable
  public func count(of element: Element) -> Int {
    __tree_.__count_multi(element)
  }
}


extension RedBlackTreeMultiSet {

  @inlinable
  public func contains(_ member: Element) -> Bool {
    ___contains(member)
  }
}


extension RedBlackTreeMultiSet {

  @inlinable
  @inline(__always)
  public var first: Element? {
    ___first
  }

  @inlinable
  public var last: Element? {
    ___last
  }
}


extension RedBlackTreeMultiSet {

  @inlinable
  @inline(__always)
  public subscript(bounds: Range<Index>) -> SubSequence {
    __tree_.___ensureValid(
      begin: bounds.lowerBound.rawValue(__tree_),
      end: bounds.upperBound.rawValue(__tree_))

    return .init(
      tree: __tree_,
      start: bounds.lowerBound.rawValue(__tree_),
      end: bounds.upperBound.rawValue(__tree_))
  }

  #if !COMPATIBLE_ATCODER_2025
    @inlinable
    @inline(__always)
    public subscript<R>(bounds: R) -> SubSequence where R: RangeExpression, R.Bound == Index {
      let bounds: Range<Index> = bounds.relative(to: self)

      __tree_.___ensureValid(
        begin: bounds.lowerBound.rawValue(__tree_),
        end: bounds.upperBound.rawValue(__tree_))

      return .init(
        tree: __tree_,
        start: bounds.lowerBound.rawValue(__tree_),
        end: bounds.upperBound.rawValue(__tree_))
    }

    @inlinable
    @inline(__always)
    public subscript(unchecked bounds: Range<Index>) -> SubSequence {
      .init(
        tree: __tree_,
        start: bounds.lowerBound.rawValue(__tree_),
        end: bounds.upperBound.rawValue(__tree_))
    }

    @inlinable
    @inline(__always)
    public subscript<R>(unchecked bounds: R) -> SubSequence
    where R: RangeExpression, R.Bound == Index {
      let bounds: Range<Index> = bounds.relative(to: self)
      return .init(
        tree: __tree_,
        start: bounds.lowerBound.rawValue(__tree_),
        end: bounds.upperBound.rawValue(__tree_))
    }
  #endif
}


extension RedBlackTreeMultiSet {

  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func insert(_ newMember: Element) -> (
    inserted: Bool, memberAfterInsert: Element
  ) {
    _ensureUniqueAndCapacity()
    _ = __tree_.__insert_multi(newMember)
    return (true, newMember)
  }
}

extension RedBlackTreeMultiSet {

  @inlinable
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    _ensureUniqueAndCapacity(to: minimumCapacity)
  }
}


extension RedBlackTreeMultiSet {

  @inlinable
  public mutating func insert(contentsOf other: RedBlackTreeSet<Element>) {
    _ensureUnique { __tree_ in
      .___insert_range_multi(
        tree: __tree_,
        other: other.__tree_,
        other.__tree_.__begin_node_,
        other.__tree_.__end_node)
    }
  }

  @inlinable
  public mutating func insert(contentsOf other: RedBlackTreeMultiSet<Element>) {
    _ensureUnique { __tree_ in
      .___insert_range_multi(
        tree: __tree_,
        other: other.__tree_,
        other.__tree_.__begin_node_,
        other.__tree_.__end_node)
    }
  }

  @inlinable
  public mutating func insert<S>(contentsOf other: S) where S: Sequence, S.Element == Element {
    _ensureUnique { __tree_ in
      .___insert_range_multi(tree: __tree_, other)
    }
  }

  @inlinable
  public func inserting(contentsOf other: RedBlackTreeSet<Element>) -> Self {
    var result = self
    result.insert(contentsOf: other)
    return result
  }

  @inlinable
  public func inserting(contentsOf other: RedBlackTreeMultiSet<Element>) -> Self {
    var result = self
    result.insert(contentsOf: other)
    return result
  }

  @inlinable
  public func inserting<S>(contentsOf other: __owned S) -> Self
  where S: Sequence, S.Element == Element {
    var result = self
    result.insert(contentsOf: other)
    return result
  }
}

extension RedBlackTreeMultiSet {

  @inlinable
  @inline(__always)
  public mutating func meld(_ other: __owned RedBlackTreeMultiSet<Element>) {
    __tree_ = __tree_.___meld_multi(other.__tree_)
  }

  @inlinable
  @inline(__always)
  public func melding(_ other: __owned RedBlackTreeMultiSet<Element>)
    -> RedBlackTreeMultiSet<Element>
  {
    var result = self
    result.meld(other)
    return result
  }
}

extension RedBlackTreeMultiSet {

  @inlinable
  public static func + (lhs: Self, rhs: Self) -> Self {
    lhs.inserting(contentsOf: rhs)
  }

  @inlinable
  public static func += (lhs: inout Self, rhs: Self) {
    lhs.insert(contentsOf: rhs)
  }
}


extension RedBlackTreeMultiSet {

  @inlinable
  @inline(__always)
  public mutating func popFirst() -> Element? {
    guard !isEmpty else { return nil }
    return remove(at: startIndex)
  }
}

extension RedBlackTreeMultiSet {

  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func remove(_ member: Element) -> Element? {
    _strongEnsureUnique()
    return __tree_.___erase_unique(member) ? member : nil
  }

  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func remove(at index: Index) -> Element {
    _ensureUnique()
    guard let element = ___remove(at: index.rawValue(__tree_)) else {
      fatalError(.invalidIndex)
    }
    return element
  }

  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func removeFirst() -> Element {
    guard !isEmpty else {
      preconditionFailure(.emptyFirst)
    }
    return remove(at: startIndex)
  }

  @inlinable
  @discardableResult
  public mutating func removeLast() -> Element {
    guard !isEmpty else {
      preconditionFailure(.emptyLast)
    }
    return remove(at: index(before: endIndex))
  }

  @inlinable
  public mutating func removeSubrange<R: RangeExpression>(
    _ bounds: R
  ) where R.Bound == Index {

    let bounds = bounds.relative(to: self)
    _ensureUnique()
    ___remove(
      from: bounds.lowerBound.rawValue(__tree_),
      to: bounds.upperBound.rawValue(__tree_))
  }

  @inlinable
  @discardableResult
  public mutating func removeAll(_ member: Element) -> Element? {
    _strongEnsureUnique()
    return __tree_.___erase_multi(member) != 0 ? member : nil
  }
}

extension RedBlackTreeMultiSet {

  @inlinable
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    _ensureUnique()
    ___removeAll(keepingCapacity: keepCapacity)
  }
}


extension RedBlackTreeMultiSet {

  @inlinable
  public func lowerBound(_ member: Element) -> Index {
    ___index_lower_bound(member)
  }

  @inlinable
  public func upperBound(_ member: Element) -> Index {
    ___index_upper_bound(member)
  }
}

extension RedBlackTreeMultiSet {

  @inlinable
  public func equalRange(_ element: Element) -> (lower: Index, upper: Index) {
    ___index_equal_range(element)
  }
}

extension RedBlackTreeMultiSet {

  @inlinable
  public func min() -> Element? {
    ___min()
  }

  @inlinable
  public func max() -> Element? {
    ___max()
  }
}

extension RedBlackTreeMultiSet {

  @inlinable
  public func first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
    try ___first(where: predicate)
  }
}

extension RedBlackTreeMultiSet {

  @inlinable
  public func firstIndex(of member: Element) -> Index? {
    ___first_index(of: member)
  }

  @inlinable
  public func firstIndex(where predicate: (Element) throws -> Bool) rethrows -> Index? {
    try ___first_index(where: predicate)
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {
    @inlinable
    public func sequence(from start: Element, to end: Element) -> SubSequence {
      .init(tree: __tree_, start: ___lower_bound(start), end: ___lower_bound(end))
    }

    @inlinable
    public func sequence(from start: Element, through end: Element) -> SubSequence {
      .init(tree: __tree_, start: ___lower_bound(start), end: ___upper_bound(end))
    }
  }
#endif


#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet {

    @inlinable
    public func filter(
      _ isIncluded: (Element) throws -> Bool
    ) rethrows -> Self {
      .init(__tree_: try __tree_.___filter(_start, _end, isIncluded))
    }
  }
#endif



extension RedBlackTreeMultiSet: Sequence, Collection, BidirectionalCollection {

  @inlinable
  @inline(__always)
  public func makeIterator() -> Tree._Values {
    _makeIterator()
  }

  @inlinable
  @inline(__always)
  public func forEach(_ body: (_Value) throws -> Void) rethrows {
    try _forEach(body)
  }

  @inlinable
  @inline(__always)
  public func forEach(_ body: (Index, _Value) throws -> Void) rethrows {
    try _forEach(body)
  }

  #if !COMPATIBLE_ATCODER_2025
    @inlinable
    @inline(__always)
    public func sorted() -> [Element] {
      _sorted()
    }
  #endif

  @inlinable
  @inline(__always)
  public var startIndex: Index { _startIndex }

  @inlinable
  @inline(__always)
  public var endIndex: Index { _endIndex }

  @inlinable
  public func distance(from start: Index, to end: Index) -> Int {
    _distance(from: start, to: end)
  }

  @inlinable
  @inline(__always)
  public func index(after i: Index) -> Index {
    _index(after: i)
  }

  @inlinable
  @inline(__always)
  public func formIndex(after i: inout Index) {
    _formIndex(after: &i)
  }

  @inlinable
  @inline(__always)
  public func index(before i: Index) -> Index {
    _index(before: i)
  }

  @inlinable
  @inline(__always)
  public func formIndex(before i: inout Index) {
    _formIndex(before: &i)
  }

  @inlinable
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    _index(i, offsetBy: distance)
  }

  @inlinable
  public func formIndex(_ i: inout Index, offsetBy distance: Int) {
    _formIndex(&i, offsetBy: distance)
  }

  @inlinable
  public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
    _index(i, offsetBy: distance, limitedBy: limit)
  }

  @inlinable
  public func formIndex(_ i: inout Index, offsetBy distance: Int, limitedBy limit: Index)
    -> Bool
  {
    _formIndex(&i, offsetBy: distance, limitedBy: limit)
  }

  @inlinable
  public subscript(position: Index) -> _Value {
    @inline(__always) _read { yield self[_checked: position] }
  }

  #if !COMPATIBLE_ATCODER_2025
    @inlinable
    public subscript(unchecked position: Index) -> _Value {
      @inline(__always) _read { yield self[_unchecked: position] }
    }
  #endif

  @inlinable
  @inline(__always)
  public func isValid(index: Index) -> Bool {
    _isValid(index: index)
  }

  @inlinable
  @inline(__always)
  public func isValid<R: RangeExpression>(_ bounds: R) -> Bool
  where R.Bound == Index {
    _isValid(bounds)
  }

  @inlinable
  @inline(__always)
  public func reversed() -> Tree._Values.Reversed {
    _reversed()
  }

  @inlinable
  @inline(__always)
  public var indices: Indices {
    _indices
  }

  @inlinable
  @inline(__always)
  public func elementsEqual<OtherSequence>(
    _ other: OtherSequence, by areEquivalent: (_Value, OtherSequence.Element) throws -> Bool
  ) rethrows -> Bool where OtherSequence: Sequence {
    try _elementsEqual(other, by: areEquivalent)
  }

  @inlinable
  @inline(__always)
  public func lexicographicallyPrecedes<OtherSequence>(
    _ other: OtherSequence, by areInIncreasingOrder: (_Value, _Value) throws -> Bool
  ) rethrows -> Bool where OtherSequence: Sequence, _Value == OtherSequence.Element {
    try _lexicographicallyPrecedes(other, by: areInIncreasingOrder)
  }
}

extension RedBlackTreeMultiSet {

  @inlinable
  @inline(__always)
  public func elementsEqual<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence: Sequence, Element == OtherSequence.Element {
    _elementsEqual(other, by: ==)
  }

  @inlinable
  @inline(__always)
  public func lexicographicallyPrecedes<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence: Sequence, Element == OtherSequence.Element {
    _lexicographicallyPrecedes(other, by: <)
  }
}


extension RedBlackTreeMultiSet {

  public typealias SubSequence = RedBlackTreeSliceV2<Self>
}


extension RedBlackTreeMultiSet {

  public typealias Indices = Tree.Indices
}



extension RedBlackTreeMultiSet: ExpressibleByArrayLiteral {

  @inlinable
  @inline(__always)
  public init(arrayLiteral elements: Element...) {
    self.init(elements)
  }
}


extension RedBlackTreeMultiSet: CustomStringConvertible {

  @inlinable
  public var description: String {
    _arrayDescription(for: self)
  }
}


extension RedBlackTreeMultiSet: CustomDebugStringConvertible {

  public var debugDescription: String {
    description
  }
}


extension RedBlackTreeMultiSet: CustomReflectable {
  public var customMirror: Mirror {
    Mirror(self, unlabeledChildren: self, displayStyle: .set)
  }
}


extension RedBlackTreeMultiSet {

  @inlinable
  @inline(__always)
  public func isIdentical(to other: Self) -> Bool {
    _isIdentical(to: other)
  }
}


extension RedBlackTreeMultiSet: Equatable {

  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.__tree_ == rhs.__tree_
  }
}


extension RedBlackTreeMultiSet: Comparable {

  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.__tree_ < rhs.__tree_
  }
}


extension RedBlackTreeMultiSet: Hashable where Element: Hashable {

  @inlinable
  @inline(__always)
  public func hash(into hasher: inout Hasher) {
    hasher.combine(__tree_)
  }
}


#if swift(>=5.5)
  extension RedBlackTreeMultiSet: @unchecked Sendable
  where Element: Sendable {}
#endif


#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSet: Encodable where Element: Encodable {

    @inlinable
    public func encode(to encoder: Encoder) throws {
      var container = encoder.unkeyedContainer()
      for element in self {
        try container.encode(element)
      }
    }
  }

  extension RedBlackTreeMultiSet: Decodable where Element: Decodable {

    @inlinable
    public init(from decoder: Decoder) throws {
      self.init(__tree_: try .create(from: decoder))
    }
  }
#endif


extension RedBlackTreeMultiSet {

  @inlinable
  public init<Source>(naive sequence: __owned Source)
  where Element == Source.Element, Source: Sequence {
    self.init(__tree_: .create_multi(naive: sequence))
  }
}

/*
  __algorithm/set_union.h
  __algorithm/set_difference.h
  __algorithm/set_intersect.h
  __algorithm/set_symmetric_difference.h
  に準じた動作となっている。
  SwiftのSetAlgebraプロトコルがmulti_setを想定しているか不明なので、プロトコル適合はしていない。
*/

extension RedBlackTreeMultiSet {
  
  @inlinable
  @inline(__always)
  public func union(_ other: __owned RedBlackTreeMultiSet<Element>)
    -> RedBlackTreeMultiSet<Element>
  {
    var result = self
    result.formUnion(other)
    return result
  }

  @inlinable
  public mutating func formUnion(_ other: __owned RedBlackTreeMultiSet<Element>) {
    __tree_ = __tree_.___meld_multi(other.__tree_)
  }
}

extension RedBlackTreeMultiSet {
  
  @inlinable
  @inline(__always)
  public func symmetricDifference(_ other: __owned RedBlackTreeMultiSet<Element>)
    -> RedBlackTreeMultiSet<Element>
  {
    var result = self
    result.formSymmetricDifference(other)
    return result
  }

  @inlinable
  public mutating func formSymmetricDifference(_ other: __owned RedBlackTreeMultiSet<Element>) {
    __tree_ = __tree_.___symmetric_difference(other.__tree_)
  }
}

extension RedBlackTreeMultiSet {
  
  @inlinable
  @inline(__always)
  public func intersection(_ other: RedBlackTreeMultiSet<Element>)
    -> RedBlackTreeMultiSet<Element>
  {
    var result = self
    result.formIntersection(other)
    return result
  }

  @inlinable
  public mutating func formIntersection(_ other: RedBlackTreeMultiSet<Element>) {
    __tree_ = __tree_.___intersection(other.__tree_)
  }
}

extension RedBlackTreeMultiSet {
  
  @inlinable
  @inline(__always)
  public func difference(_ other: __owned RedBlackTreeMultiSet<Element>)
    -> RedBlackTreeMultiSet<Element>
  {
    var result = self
    result.formDifference(other)
    return result
  }

  @inlinable
  public mutating func formDifference(_ other: __owned RedBlackTreeMultiSet<Element>) {
    __tree_ = __tree_.___difference(other.__tree_)
  }
}

import Foundation

@frozen
public struct RedBlackTreeSet<Element: Comparable> {

  public
    typealias Element = Element

  public
    typealias Index = Tree.Index

  public
    typealias _Key = Element

  public
    typealias _Value = Element

  public
    typealias Base = Self
  
#if !USE_SIMPLE_COPY_ON_WRITE || COMPATIBLE_ATCODER_2025
  @usableFromInline
  var referenceCounter: ReferenceCounter
#endif
  
#if !USE_SIMPLE_COPY_ON_WRITE || COMPATIBLE_ATCODER_2025
  @usableFromInline
  var __tree_: Tree {
    didSet { referenceCounter = .create() }
  }
#else
  @usableFromInline
  var __tree_: Tree
#endif

  @inlinable @inline(__always)
  internal init(__tree_: Tree) {
    self.__tree_ = __tree_
#if !USE_SIMPLE_COPY_ON_WRITE || COMPATIBLE_ATCODER_2025
    referenceCounter = .create()
#endif
  }
}

extension RedBlackTreeSet: ___RedBlackTreeKeyOnlyBase {}
extension RedBlackTreeSet: CompareUniqueTrait {}
extension RedBlackTreeSet: ScalarValueComparer {}


extension RedBlackTreeSet {

  @inlinable
  @inline(__always)
  public init() {
    self.init(__tree_: .create(minimumCapacity: 0))
  }

  @inlinable
  @inline(__always)
  public init(minimumCapacity: Int) {
    self.init(__tree_: .create(minimumCapacity: minimumCapacity))
  }
}

extension RedBlackTreeSet {

  @inlinable
  public init<Source>(_ sequence: __owned Source)
  where Element == Source.Element, Source: Sequence {
    self.init(__tree_: .create_unique(sorted: sequence.sorted()))
  }
}

extension RedBlackTreeSet {

  @inlinable
  public init<R>(_ range: __owned R)
  where R: RangeExpression, R: Collection, R.Element == Element {
    precondition(range is Range<Element> || range is ClosedRange<Element>)
    self.init(__tree_: .create(range: range))
  }
}


extension RedBlackTreeSet {

  @inlinable
  @inline(__always)
  public var isEmpty: Bool {
    ___is_empty
  }

  @inlinable
  @inline(__always)
  public var capacity: Int {
    ___capacity
  }

  @inlinable
  @inline(__always)
  public var count: Int {
    ___count
  }
}

extension RedBlackTreeSet {

  @inlinable
  public func count(of element: Element) -> Int {
    __tree_.__count_unique(element)
  }
}


extension RedBlackTreeSet {

  @inlinable
  public func contains(_ member: Element) -> Bool {
    ___contains(member)
  }
}


extension RedBlackTreeSet {

  @inlinable
  @inline(__always)
  public var first: Element? {
    ___first
  }

  @inlinable
  public var last: Element? {
    ___last
  }
}


extension RedBlackTreeSet {

  @inlinable
  @inline(__always)
  public subscript(bounds: Range<Index>) -> SubSequence {
    __tree_.___ensureValid(
      begin: bounds.lowerBound.rawValue(__tree_),
      end: bounds.upperBound.rawValue(__tree_))

    return .init(
      tree: __tree_,
      start: bounds.lowerBound.rawValue(__tree_),
      end: bounds.upperBound.rawValue(__tree_))
  }

  #if !COMPATIBLE_ATCODER_2025
    @inlinable
    @inline(__always)
    public subscript<R>(bounds: R) -> SubSequence where R: RangeExpression, R.Bound == Index {
      let bounds: Range<Index> = bounds.relative(to: self)

      __tree_.___ensureValid(
        begin: bounds.lowerBound.rawValue(__tree_),
        end: bounds.upperBound.rawValue(__tree_))

      return .init(
        tree: __tree_,
        start: bounds.lowerBound.rawValue(__tree_),
        end: bounds.upperBound.rawValue(__tree_))
    }

    @inlinable
    @inline(__always)
    public subscript(unchecked bounds: Range<Index>) -> SubSequence {
      .init(
        tree: __tree_,
        start: bounds.lowerBound.rawValue(__tree_),
        end: bounds.upperBound.rawValue(__tree_))
    }

    @inlinable
    @inline(__always)
    public subscript<R>(unchecked bounds: R) -> SubSequence
    where R: RangeExpression, R.Bound == Index {
      let bounds: Range<Index> = bounds.relative(to: self)
      return .init(
        tree: __tree_,
        start: bounds.lowerBound.rawValue(__tree_),
        end: bounds.upperBound.rawValue(__tree_))
    }
  #endif
}


extension RedBlackTreeSet {

  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func insert(_ newMember: Element) -> (
    inserted: Bool, memberAfterInsert: Element
  ) {
    _ensureUniqueAndCapacity()
    let (__r, __inserted) = __tree_.__insert_unique(newMember)
    return (__inserted, __inserted ? newMember : __tree_[__r])
  }

  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func update(with newMember: Element) -> Element? {
    _ensureUniqueAndCapacity()
    let (__r, __inserted) = __tree_.__insert_unique(newMember)
    guard !__inserted else { return nil }
    let oldMember = __tree_[__r]
    __tree_[__r] = newMember
    return oldMember
  }
}

extension RedBlackTreeSet {

  @inlinable
  public mutating func reserveCapacity(_ minimumCapacity: Int) {
    _ensureUniqueAndCapacity(to: minimumCapacity)
  }
}


extension RedBlackTreeSet {

  @inlinable
  public mutating func merge(_ other: RedBlackTreeSet<Element>) {
    _ensureUnique { __tree_ in
      .___insert_range_unique(
        tree: __tree_,
        other: other.__tree_,
        other.__tree_.__begin_node_,
        other.__tree_.__end_node)
    }
  }

  @inlinable
  public mutating func merge(_ other: RedBlackTreeMultiSet<Element>) {
    _ensureUnique { __tree_ in
      .___insert_range_unique(
        tree: __tree_,
        other: other.__tree_,
        other.__tree_.__begin_node_,
        other.__tree_.__end_node)
    }
  }

  @inlinable
  public mutating func merge<S>(_ other: S) where S: Sequence, S.Element == Element {
    _ensureUnique { __tree_ in
      .___insert_range_unique(tree: __tree_, other)
    }
  }

  @inlinable
  public func merging(_ other: RedBlackTreeSet<Element>) -> Self {
    var result: Self = self
    result.merge(other)
    return result
  }

  @inlinable
  public func merging(_ other: RedBlackTreeMultiSet<Element>) -> Self {
    var result = self
    result.merge(other)
    return result
  }

  @inlinable
  public func merging<S>(_ other: __owned S) -> Self where S: Sequence, S.Element == Element {
    var result = self
    result.merge(other)
    return result
  }
}


extension RedBlackTreeSet {

  @inlinable
  @inline(__always)
  public mutating func popFirst() -> Element? {
    guard !isEmpty else { return nil }
    return remove(at: startIndex)
  }
}

extension RedBlackTreeSet {

  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func remove(_ member: Element) -> Element? {
    _ensureUnique()
    return __tree_.___erase_unique(member) ? member : nil
  }

  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func remove(at index: Index) -> Element {
    _ensureUnique()
    guard let element = ___remove(at: index.rawValue(__tree_)) else {
      fatalError(.invalidIndex)
    }
    return element
  }

  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func removeFirst() -> Element {
    guard !isEmpty else {
      preconditionFailure(.emptyFirst)
    }
    return remove(at: startIndex)
  }

  @inlinable
  @discardableResult
  public mutating func removeLast() -> Element {
    guard !isEmpty else {
      preconditionFailure(.emptyLast)
    }
    return remove(at: index(before: endIndex))
  }

  @inlinable
  public mutating func removeSubrange<R: RangeExpression>(
    _ bounds: R
  ) where R.Bound == Index {

    let bounds = bounds.relative(to: self)
    _ensureUnique()
    ___remove(
      from: bounds.lowerBound.rawValue(__tree_),
      to: bounds.upperBound.rawValue(__tree_))
  }
}

extension RedBlackTreeSet {

  @inlinable
  public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
    _ensureUnique()
    ___removeAll(keepingCapacity: keepCapacity)
  }
}


extension RedBlackTreeSet {

  @inlinable
  public func lowerBound(_ member: Element) -> Index {
    ___index_lower_bound(member)
  }

  @inlinable
  public func upperBound(_ member: Element) -> Index {
    ___index_upper_bound(member)
  }
}

extension RedBlackTreeSet {

  @inlinable
  public func equalRange(_ element: Element) -> (lower: Index, upper: Index) {
    ___index_equal_range(element)
  }
}

extension RedBlackTreeSet {

  @inlinable
  public func min() -> Element? {
    ___min()
  }

  @inlinable
  public func max() -> Element? {
    ___max()
  }
}

extension RedBlackTreeSet {

  @inlinable
  public func first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
    try ___first(where: predicate)
  }
}

extension RedBlackTreeSet {

  @inlinable
  public func firstIndex(of member: Element) -> Index? {
    ___first_index(of: member)
  }

  @inlinable
  public func firstIndex(where predicate: (Element) throws -> Bool) rethrows -> Index? {
    try ___first_index(where: predicate)
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {
    @inlinable
    public func sequence(from start: Element, to end: Element) -> SubSequence {
      .init(tree: __tree_, start: ___lower_bound(start), end: ___lower_bound(end))
    }

    @inlinable
    public func sequence(from start: Element, through end: Element) -> SubSequence {
      .init(tree: __tree_, start: ___lower_bound(start), end: ___upper_bound(end))
    }
  }
#endif

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet {

    @inlinable
    public func filter(
      _ isIncluded: (Element) throws -> Bool
    ) rethrows -> Self {
      .init(__tree_: try __tree_.___filter(_start, _end, isIncluded))
    }
  }
#endif


extension RedBlackTreeSet: Sequence, Collection, BidirectionalCollection {

  @inlinable
  @inline(__always)
  public func makeIterator() -> Tree._Values {
    _makeIterator()
  }

  @inlinable
  @inline(__always)
  public func forEach(_ body: (Element) throws -> Void) rethrows {
    try _forEach(body)
  }

  @inlinable
  @inline(__always)
  public func forEach(_ body: (Index, Element) throws -> Void) rethrows {
    try _forEach(body)
  }

  #if !COMPATIBLE_ATCODER_2025
    @inlinable
    @inline(__always)
    public func sorted() -> [Element] {
      _sorted()
    }
  #endif

  @inlinable
  @inline(__always)
  public var startIndex: Index { _startIndex }

  @inlinable
  @inline(__always)
  public var endIndex: Index { _endIndex }

  @inlinable
  public func distance(from start: Index, to end: Index) -> Int {
    _distance(from: start, to: end)
  }

  @inlinable
  @inline(__always)
  public func index(after i: Index) -> Index {
    _index(after: i)
  }

  @inlinable
  @inline(__always)
  public func formIndex(after i: inout Index) {
    _formIndex(after: &i)
  }

  @inlinable
  @inline(__always)
  public func index(before i: Index) -> Index {
    _index(before: i)
  }

  @inlinable
  @inline(__always)
  public func formIndex(before i: inout Index) {
    _formIndex(before: &i)
  }

  @inlinable
  public func index(_ i: Index, offsetBy distance: Int) -> Index {
    _index(i, offsetBy: distance)
  }

  @inlinable
  public func formIndex(_ i: inout Index, offsetBy distance: Int) {
    _formIndex(&i, offsetBy: distance)
  }

  @inlinable
  public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
    _index(i, offsetBy: distance, limitedBy: limit)
  }

  @inlinable
  public func formIndex(_ i: inout Index, offsetBy distance: Int, limitedBy limit: Index)
    -> Bool
  {
    _formIndex(&i, offsetBy: distance, limitedBy: limit)
  }

  @inlinable
  public subscript(position: Index) -> Element {
    @inline(__always) _read { yield self[_checked: position] }
  }

  #if !COMPATIBLE_ATCODER_2025
    @inlinable
    public subscript(unchecked position: Index) -> _Value {
      @inline(__always) _read { yield self[_unchecked: position] }
    }
  #endif

  @inlinable
  @inline(__always)
  public func isValid(index: Index) -> Bool {
    _isValid(index: index)
  }

  @inlinable
  @inline(__always)
  public func isValid<R: RangeExpression>(_ bounds: R) -> Bool
  where R.Bound == Index {
    _isValid(bounds)
  }

  @inlinable
  @inline(__always)
  public func reversed() -> Tree._Values.Reversed {
    _reversed()
  }

  @inlinable
  @inline(__always)
  public var indices: Indices {
    _indices
  }

  @inlinable
  @inline(__always)
  public func elementsEqual<OtherSequence>(
    _ other: OtherSequence, by areEquivalent: (Element, OtherSequence.Element) throws -> Bool
  ) rethrows -> Bool where OtherSequence: Sequence {
    try _elementsEqual(other, by: areEquivalent)
  }

  @inlinable
  @inline(__always)
  public func lexicographicallyPrecedes<OtherSequence>(
    _ other: OtherSequence, by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> Bool where OtherSequence: Sequence, Element == OtherSequence.Element {
    try _lexicographicallyPrecedes(other, by: areInIncreasingOrder)
  }
}

extension RedBlackTreeSet {

  @inlinable
  @inline(__always)
  public func elementsEqual<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence: Sequence, Element == OtherSequence.Element {
    _elementsEqual(other, by: ==)
  }

  @inlinable
  @inline(__always)
  public func lexicographicallyPrecedes<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence: Sequence, Element == OtherSequence.Element {
    _lexicographicallyPrecedes(other, by: <)
  }
}


extension RedBlackTreeSet {

  public typealias SubSequence = RedBlackTreeSliceV2<Base>
}


extension RedBlackTreeSet {

  public typealias Indices = Tree.Indices
}



extension RedBlackTreeSet: ExpressibleByArrayLiteral {

  @inlinable
  @inline(__always)
  public init(arrayLiteral elements: Element...) {
    self.init(elements)
  }
}


extension RedBlackTreeSet: CustomStringConvertible {

  @inlinable
  public var description: String {
    _arrayDescription(for: self)
  }
}


extension RedBlackTreeSet: CustomDebugStringConvertible {

  public var debugDescription: String {
    description
  }
}


extension RedBlackTreeSet: CustomReflectable {
  public var customMirror: Mirror {
    Mirror(self, unlabeledChildren: self, displayStyle: .set)
  }
}


extension RedBlackTreeSet {

  @inlinable
  @inline(__always)
  public func isIdentical(to other: Self) -> Bool {
    _isIdentical(to: other)
  }
}


extension RedBlackTreeSet: Equatable {

  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.__tree_ == rhs.__tree_
  }
}


extension RedBlackTreeSet: Comparable {

  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.__tree_ < rhs.__tree_
  }
}


extension RedBlackTreeSet: Hashable where Element: Hashable {

  @inlinable
  @inline(__always)
  public func hash(into hasher: inout Hasher) {
    hasher.combine(__tree_)
  }
}


#if swift(>=5.5)
  extension RedBlackTreeSet: @unchecked Sendable
  where Element: Sendable {}
#endif


#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeSet: Encodable where Element: Encodable {

    @inlinable
    public func encode(to encoder: Encoder) throws {
      var container = encoder.unkeyedContainer()
      for element in self {
        try container.encode(element)
      }
    }
  }

  extension RedBlackTreeSet: Decodable where Element: Decodable {

    @inlinable
    public init(from decoder: Decoder) throws {
      self.init(__tree_: try .create(from: decoder))
    }
  }
#endif


extension RedBlackTreeSet {

  @inlinable
  public init<Source>(naive sequence: __owned Source)
  where Element == Source.Element, Source: Sequence {
    self.init(__tree_: .create_unique(naive: sequence))
  }
}

import Foundation

extension RedBlackTreeSet: SetAlgebra {

  @inlinable
  @inline(__always)
  public func union(_ other: __owned RedBlackTreeSet<Element>)
    -> RedBlackTreeSet<Element>
  {
    var result = self
    result.formUnion(other)
    return result
  }

  @inlinable
  @inline(__always)
  public func intersection(_ other: RedBlackTreeSet<Element>)
    -> RedBlackTreeSet<Element>
  {
    var result = self
    result.formIntersection(other)
    return result
  }

  @inlinable
  @inline(__always)
  public func symmetricDifference(_ other: __owned RedBlackTreeSet<Element>)
    -> RedBlackTreeSet<Element>
  {
    var result = self
    result.formSymmetricDifference(other)
    return result
  }

  @inlinable
  public mutating func formUnion(_ other: __owned RedBlackTreeSet<Element>) {
    __tree_ = __tree_.___meld_unique(other.__tree_)
  }

  @inlinable
  public mutating func formIntersection(_ other: RedBlackTreeSet<Element>) {
    __tree_ = __tree_.___intersection(other.__tree_)
  }

  @inlinable
  public mutating func formSymmetricDifference(_ other: __owned RedBlackTreeSet<Element>) {
    __tree_ = __tree_.___symmetric_difference(other.__tree_)
  }
}

/*
  __algorithm/set_difference.h に準じた動作となっている。
*/
extension RedBlackTreeSet {
  
  @inlinable
  @inline(__always)
  public func difference(_ other: __owned RedBlackTreeSet<Element>)
    -> RedBlackTreeSet<Element>
  {
    var result = self
    result.formDifference(other)
    return result
  }

  @inlinable
  public mutating func formDifference(_ other: __owned RedBlackTreeSet<Element>) {
    __tree_ = __tree_.___difference(other.__tree_)
  }
}

import Foundation

@frozen
public struct UnsafeIndexV2<Base> where Base: ___TreeBase & ___TreeIndex {

  public typealias Tree = UnsafeTreeV2<Base>
  public typealias Pointee = Tree.Pointee
  public typealias _NodePtr = Tree._NodePtr

  @usableFromInline
  typealias _Value = Tree._Value

  @usableFromInline
  internal let __tree_: Tree

  @usableFromInline
  internal var ___node_id_: Int

  @usableFromInline
  internal var rawValue: _NodePtr


  @inlinable
  @inline(__always)
  internal init(tree: Tree, rawValue: _NodePtr) {
    assert(rawValue != tree.nullptr)
    self.__tree_ = tree
    self.rawValue = rawValue
    self.___node_id_ = rawValue.pointee.___node_id_
  }

  /*
   invalidなポインタでの削除は、だんまりがいいように思う
   */

}

extension UnsafeIndexV2: Comparable {

  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.rawValue == rhs.rawValue
  }

  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {

    let __tree_ = lhs.__tree_

    guard !__tree_.___is_garbaged(lhs.rawValue),
      !__tree_.___is_garbaged(rhs.rawValue)
    else {
      preconditionFailure(.garbagedIndex)
    }

    return lhs.__tree_.___ptr_comp(lhs.rawValue, rhs.rawValue)
  }
}

extension UnsafeIndexV2 {

  @inlinable
  public func distance(to other: Self) -> Int {
    guard !__tree_.___is_garbaged(rawValue),
      !__tree_.___is_garbaged(other.rawValue)
    else {
      preconditionFailure(.garbagedIndex)
    }
    return __tree_.___signed_distance(rawValue, other.rawValue)
  }

  @inlinable
  public func advanced(by n: Int) -> Self {
    return .init(tree: __tree_, rawValue: __tree_.___tree_adv_iter(rawValue, by: n))
  }
}

extension UnsafeIndexV2 {

  @inlinable
  @inline(__always)
  public var next: Self? {
    guard !__tree_.___is_next_null(rawValue) else {
      return nil
    }
    var next = self
    next.___unchecked_next()
    return next
  }

  @inlinable
  @inline(__always)
  public var previous: Self? {
    guard !__tree_.___is_prev_null(rawValue) else {
      return nil
    }
    var prev = self
    prev.___unchecked_prev()
    return prev
  }

  @inlinable
  @inline(__always)
  internal mutating func ___unchecked_next() {
    assert(!__tree_.___is_garbaged(rawValue))
    assert(!__tree_.___is_end(rawValue))
    rawValue = __tree_.__tree_next_iter(rawValue)
  }

  @inlinable
  @inline(__always)
  internal mutating func ___unchecked_prev() {
    assert(!__tree_.___is_garbaged(rawValue))
    assert(!__tree_.___is_begin(rawValue))
    rawValue = __tree_.__tree_prev_iter(rawValue)
  }
}

extension UnsafeIndexV2 {

  @inlinable
  @inline(__always)
  public var isStart: Bool {
    __tree_.___is_begin(rawValue)
  }

  @inlinable
  @inline(__always)
  public var isEnd: Bool {
    __tree_.___is_end(rawValue)
  }

  @inlinable
  @inline(__always)
  public var isRoot: Bool {
    __tree_.___is_root(rawValue)
  }
}

extension UnsafeIndexV2 {

  @inlinable
  public var pointee: Pointee? {
    __tree_.___is_subscript_null(rawValue)
      ? nil : Base.___pointee(UnsafePair<_Value>.valuePointer(rawValue)!.pointee)
  }
}

#if DEBUG
  extension UnsafeIndexV2 {
    fileprivate init(_unsafe_tree: UnsafeTreeV2<Base>, rawValue: _NodePtr, node_id: Int) {
      self.__tree_ = _unsafe_tree
      self.rawValue = rawValue
      self.___node_id_ = node_id
    }
  }

  extension UnsafeIndexV2 {
    internal static func unsafe(tree: UnsafeTreeV2<Base>, rawValue: _NodePtr) -> Self {
      .init(_unsafe_tree: tree, rawValue: rawValue, node_id: rawValue.pointee.___node_id_)
    }
    internal static func unsafe(tree: UnsafeTreeV2<Base>, rawValue: Int) -> Self {
      if rawValue == .nullptr {
        return .init(_unsafe_tree: tree, rawValue: tree.nullptr, node_id: .nullptr)
      }
      if rawValue == .end {
        return .init(_unsafe_tree: tree, rawValue: tree.end, node_id: .end)
      }
      return .init(
        _unsafe_tree: tree, rawValue: tree._buffer.header[rawValue],
        node_id: tree._buffer.header[rawValue].pointee.___node_id_)
    }
  }
#endif

#if swift(>=5.5)
  extension UnsafeIndexV2: @unchecked Sendable
  where _Value: Sendable {}
#endif

extension UnsafeIndexV2 {
  @inlinable
  @inline(__always)
  internal var ___indices: UnsafeIndicesV2<Base> {
    .init(tree: __tree_, start: __tree_.__begin_node_, end: __tree_.__end_node)
  }
}


@inlinable
@inline(__always)
public func ..< <Base>(lhs: UnsafeIndexV2<Base>, rhs: UnsafeIndexV2<Base>)
  -> UnsafeTreeV2<Base>.Indices
{
  let indices = lhs.___indices
  let bounds = (lhs..<rhs).relative(to: indices)
  return indices[bounds.lowerBound..<bounds.upperBound]
}

#if !COMPATIBLE_ATCODER_2025
  @inlinable
  @inline(__always)
  public func ... <Base>(lhs: UnsafeIndexV2<Base>, rhs: UnsafeIndexV2<Base>)
    -> UnsafeTreeV2<Base>.Indices
  {
    let indices = lhs.___indices
    let bounds = (lhs...rhs).relative(to: indices)
    return indices[bounds.lowerBound..<bounds.upperBound]
  }

  @inlinable
  @inline(__always)
  public prefix func ..< <Base>(rhs: UnsafeIndexV2<Base>) -> UnsafeTreeV2<Base>.Indices {
    let indices = rhs.___indices
    let bounds = (..<rhs).relative(to: indices)
    return indices[bounds.lowerBound..<bounds.upperBound]
  }

  @inlinable
  @inline(__always)
  public prefix func ... <Base>(rhs: UnsafeIndexV2<Base>) -> UnsafeTreeV2<Base>.Indices {
    let indices = rhs.___indices
    let bounds = (...rhs).relative(to: indices)
    return indices[bounds.lowerBound..<bounds.upperBound]
  }

  @inlinable
  @inline(__always)
  public postfix func ... <Base>(lhs: UnsafeIndexV2<Base>) -> UnsafeTreeV2<Base>.Indices {
    let indices = lhs.___indices
    let bounds = (lhs...).relative(to: indices)
    return indices[bounds.lowerBound..<bounds.upperBound]
  }
#endif


@inlinable
@inline(__always)
public func + <Base>(lhs: UnsafeIndexV2<Base>, rhs: Int) -> UnsafeIndexV2<Base> {
  lhs.advanced(by: rhs)
}

@inlinable
@inline(__always)
public func - <Base>(lhs: UnsafeIndexV2<Base>, rhs: Int) -> UnsafeIndexV2<Base> {
  lhs.advanced(by: -rhs)
}

@inlinable
@inline(__always)
public func - <Base>(lhs: UnsafeIndexV2<Base>, rhs: UnsafeIndexV2<Base>) -> Int {
  rhs.distance(to: lhs)
}


#if !COMPATIBLE_ATCODER_2025
  extension UnsafeIndexV2 {

    public func some() -> Self? { .some(self) }
  }
#endif

extension UnsafeIndexV2 {

  @inlinable
  @inline(__always)
  package func rawValue(_ tree: Tree) -> _NodePtr {
    tree.___node_ptr(self)
  }

  @inlinable
  @inline(__always)
  package var _rawValue: Int {
    rawValue.pointee.___node_id_
  }
}

import Foundation


@frozen
public struct UnsafeIndicesV2<Base>: ___UnsafeIndexBaseV2 where Base: ___TreeBase & ___TreeIndex {

  public typealias Tree = UnsafeTreeV2<Base>
  public typealias _Value = Tree._Value
  public typealias _NodePtr = Tree._NodePtr

  @usableFromInline
  internal let __tree_: Tree

  @usableFromInline
  internal var _start, _end: _NodePtr

  public typealias Index = Tree.Index

  @inlinable
  @inline(__always)
  internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
    __tree_ = tree
    _start = start
    _end = end
  }
}

extension UnsafeIndicesV2 {

  @frozen
  public struct Iterator: IteratorProtocol, ___UnsafeIndexBaseV2 {

    @usableFromInline
    internal let __tree_: Tree

    @usableFromInline
    internal var _current, _next, _end: _NodePtr

    @inlinable
    @inline(__always)
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      self.__tree_ = tree
      self._current = start
      self._end = end
      self._next = start == tree.end ? tree.end : tree.__tree_next(start)
    }

    @inlinable
    @inline(__always)
    public mutating func next() -> Index? {
      guard _current != _end else { return nil }
      defer {
        _current = _next
        _next = _next == _end ? _end : __tree_.__tree_next(_next)
      }
      return ___index(_current)
    }
  }
}

extension UnsafeIndicesV2 {

  @frozen
  public struct Reversed: Sequence, IteratorProtocol, ___UnsafeIndexBaseV2 {

    @usableFromInline
    internal let __tree_: Tree

    @usableFromInline
    internal var _current, _next, _start, _begin: _NodePtr

    @inlinable
    @inline(__always)
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      self.__tree_ = tree
      self._current = end
      self._next = end == start ? end : __tree_.__tree_prev_iter(end)
      self._start = start
      self._begin = __tree_.__begin_node_
    }

    @inlinable
    @inline(__always)
    public mutating func next() -> Index? {
      guard _current != _start else { return nil }
      _current = _next
      _next = _current != _begin ? __tree_.__tree_prev_iter(_current) : __tree_.nullptr
      return ___index(_current)
    }
  }
}

extension UnsafeIndicesV2: Collection, BidirectionalCollection {

  @inlinable
  @inline(__always)
  public __consuming func makeIterator() -> Iterator {
    .init(tree: __tree_, start: _start, end: _end)
  }

  @inlinable
  @inline(__always)
  public func reversed() -> Reversed {
    .init(tree: __tree_, start: _start, end: _end)
  }

  @inlinable
  @inline(__always)
  public func index(after i: Index) -> Index {
    ___index(__tree_.___index(after: i.rawValue(__tree_)))
  }

  @inlinable
  @inline(__always)
  public func index(before i: Index) -> Index {
    ___index(__tree_.___index(before: i.rawValue(__tree_)))
  }

  @inlinable
  @inline(__always)
  public subscript(position: Index) -> Index {
    position
  }

  @inlinable
  @inline(__always)
  public var startIndex: Index {
    ___index(_start)
  }

  @inlinable
  @inline(__always)
  public var endIndex: Index {
    ___index(_end)
  }

  public typealias SubSequence = Self

  @inlinable
  @inline(__always)
  public subscript(bounds: Range<Index>) -> SubSequence {
    .init(
      tree: __tree_,
      start: bounds.lowerBound.rawValue(__tree_),
      end: bounds.upperBound.rawValue(__tree_))
  }

  #if !COMPATIBLE_ATCODER_2025
    @inlinable
    @inline(__always)
    public subscript<R>(bounds: R) -> SubSequence where R: RangeExpression, R.Bound == Index {
      let bounds: Range<Index> = bounds.relative(to: self)
      return .init(
        tree: __tree_,
        start: bounds.lowerBound.rawValue(__tree_),
        end: bounds.upperBound.rawValue(__tree_))
    }
  #endif
}

#if swift(>=5.5)
  extension UnsafeIndicesV2: @unchecked Sendable
  where _Value: Sendable {}
#endif


extension UnsafeIndicesV2: ___UnsafeIsIdenticalToV2 {}

import Foundation

@frozen
public enum RedBlackTreeIteratorV2<Base> where Base: ___TreeBase & ___TreeIndex {

  @frozen
  public struct Values: Sequence, IteratorProtocol {

    public typealias Tree = UnsafeTreeV2<Base>
    public typealias _Value = Tree._Value
    public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

    @usableFromInline
    internal let __tree_: Tree

    @usableFromInline
    internal var _start, _end, _current, _next: _NodePtr

    @inlinable
    @inline(__always)
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      self.__tree_ = tree
      self._current = start
      self._start = start
      self._end = end
      self._next = start == tree.end ? tree.end : tree.__tree_next_iter(start)
    }

    @inlinable
    @inline(__always)
    public mutating func next() -> Tree._Value? {
      guard _current != _end else { return nil }
      defer {
        _current = _next
        _next = _next == _end ? _end : __tree_.__tree_next_iter(_next)
      }
      return __tree_.__value_(_current)
    }
  }
}

extension RedBlackTreeIteratorV2.Values: Equatable where Tree._Value: Equatable {

  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.isIdentical(to: rhs) || lhs.elementsEqual(rhs)
  }
}

extension RedBlackTreeIteratorV2.Values: Comparable where Tree._Value: Comparable {

  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    !lhs.isIdentical(to: rhs) && lhs.lexicographicallyPrecedes(rhs)
  }
}

#if swift(>=5.5)
  extension RedBlackTreeIteratorV2.Values: @unchecked Sendable
  where Tree._Value: Sendable {}
#endif


extension RedBlackTreeIteratorV2.Values: ___UnsafeIsIdenticalToV2 {}

import Foundation

extension RedBlackTreeIteratorV2 {

  @frozen
  public struct Keys: Sequence, IteratorProtocol {

    public typealias Tree = UnsafeTreeV2<Base>
    public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

    @usableFromInline
    internal let __tree_: Tree

    @usableFromInline
    internal var _start, _end, _current, _next: _NodePtr

    @inlinable
    @inline(__always)
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      self.__tree_ = tree
      self._current = start
      self._start = start
      self._end = end
      self._next = start == tree.end ? tree.end : tree.__tree_next_iter(start)
    }

    @inlinable
    @inline(__always)
    public mutating func next() -> Base._Key? {
      guard _current != _end else { return nil }
      defer {
        _current = _next
        _next = _next == _end ? _end : __tree_.__tree_next_iter(_next)
      }
      return __tree_.__get_value(_current)
    }

    @inlinable
    @inline(__always)
    public func reversed() -> Reversed {
      .init(tree: __tree_, start: _start, end: _end)
    }
  }
}

extension RedBlackTreeIteratorV2.Keys: Equatable {

  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.isIdentical(to: rhs) || Tree.with_value_equiv{ lhs.elementsEqual(rhs, by: $0) }
  }
}

extension RedBlackTreeIteratorV2.Keys: Comparable {

  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    !lhs.isIdentical(to: rhs) && Tree.with_value_equiv{ lhs.lexicographicallyPrecedes(rhs, by: $0) }
  }
}

#if swift(>=5.5)
  extension RedBlackTreeIteratorV2.Keys: @unchecked Sendable
  where Tree._Value: Sendable {}
#endif


extension RedBlackTreeIteratorV2.Keys: ___UnsafeIsIdenticalToV2 {}

extension RedBlackTreeIteratorV2 {

  @frozen
  public struct KeyValues: Sequence, IteratorProtocol
  where Base: KeyValueComparer {

    public typealias Tree = UnsafeTreeV2<Base>
    public typealias _NodePtr = Tree._NodePtr

    @usableFromInline
    internal let __tree_: Tree

    @usableFromInline
    internal var _start, _end, _current, _next: _NodePtr

    @inlinable
    @inline(__always)
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      self.__tree_ = tree
      self._current = start
      self._start = start
      self._end = end
      self._next = start == tree.end ? tree.end : tree.__tree_next_iter(start)
    }

    @inlinable
    @inline(__always)
    public mutating func next() -> (key: Base._Key, value: Base._MappedValue)? {
      guard _current != _end else { return nil }
      defer {
        _current = _next
        _next = _next == _end ? _end : __tree_.__tree_next_iter(_next)
      }
      return (__tree_.__get_value(_current), __tree_.___mapped_value(_current))
    }
  }
}

extension RedBlackTreeIteratorV2.KeyValues where Base: KeyValueComparer {

  #if COMPATIBLE_ATCODER_2025
    @inlinable
    @inline(__always)
    public func keys() -> RedBlackTreeIteratorV2<Base>.Keys {
      .init(tree: __tree_, start: _start, end: _end)
    }

    @inlinable
    @inline(__always)
    public func values() -> RedBlackTreeIteratorV2<Base>.MappedValues {
      .init(tree: __tree_, start: _start, end: _end)
    }
  #else
    @inlinable
    @inline(__always)
    public var keys: RedBlackTreeIteratorV2<Base>.Keys {
      .init(tree: __tree_, start: _start, end: _end)
    }

    @inlinable
    @inline(__always)
    public var values: RedBlackTreeIteratorV2<Base>.MappedValues {
      .init(tree: __tree_, start: _start, end: _end)
    }
  #endif
}

extension RedBlackTreeIteratorV2.KeyValues: Equatable
where Base._Key: Equatable, Base._MappedValue: Equatable {

  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.isIdentical(to: rhs) || lhs.elementsEqual(rhs, by: ==)
  }
}

extension RedBlackTreeIteratorV2.KeyValues: Comparable
where Base._Key: Comparable, Base._MappedValue: Comparable {

  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    !lhs.isIdentical(to: rhs) && lhs.lexicographicallyPrecedes(rhs, by: <)
  }
}

#if swift(>=5.5)
  extension RedBlackTreeIteratorV2.KeyValues: @unchecked Sendable
  where Tree._Value: Sendable {}
#endif


extension RedBlackTreeIteratorV2.KeyValues: ___UnsafeIsIdenticalToV2 {}

import Foundation

extension RedBlackTreeIteratorV2 {
  
  @frozen
  public struct MappedValues: Sequence, IteratorProtocol
  where Base: KeyValueComparer
  {
    public typealias Tree = UnsafeTreeV2<Base>
    public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

    @usableFromInline
    internal let __tree_: Tree
    
    @usableFromInline
    internal var _start, _end, _current, _next: _NodePtr
    
    @inlinable
    @inline(__always)
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      self.__tree_ = tree
      self._current = start
      self._start = start
      self._end = end
      self._next = start == tree.end ? tree.end : tree.__tree_next_iter(start)
    }
    
    @inlinable
    @inline(__always)
    public mutating func next() -> Base._MappedValue? {
      guard _current != _end else { return nil }
      defer {
        _current = _next
        _next = _next == _end ? _end : __tree_.__tree_next_iter(_next)
      }
      return __tree_.___mapped_value(_current)
    }
    
    @inlinable
    @inline(__always)
    public func reversed() -> Reversed {
      .init(tree: __tree_, start: _start, end: _end)
    }
  }
}

extension RedBlackTreeIteratorV2.MappedValues: Equatable where Base._MappedValue: Equatable {

  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.isIdentical(to: rhs) || lhs.elementsEqual(rhs)
  }
}

extension RedBlackTreeIteratorV2.MappedValues: Comparable where Base._MappedValue: Comparable {

  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    !lhs.isIdentical(to: rhs) && lhs.lexicographicallyPrecedes(rhs)
  }
}

#if swift(>=5.5)
  extension RedBlackTreeIteratorV2.MappedValues: @unchecked Sendable
  where Tree._Value: Sendable {}
#endif


extension RedBlackTreeIteratorV2.MappedValues: ___UnsafeIsIdenticalToV2 {}

import Foundation

extension RedBlackTreeIteratorV2.Values {

  @frozen
  public struct Reversed: Sequence, IteratorProtocol {
    public typealias Tree = UnsafeTreeV2<Base>
    public typealias _Value = Tree._Value

    @usableFromInline
    internal let __tree_: Tree

    @usableFromInline
    internal var _start, _end, _begin, _current, _next: _NodePtr

    @inlinable
    @inline(__always)
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      self.__tree_ = tree
      self._current = end
      self._next = end == start ? end : __tree_.__tree_prev_iter(end)
      self._start = start
      self._end = end
      self._begin = __tree_.__begin_node_
    }

    @inlinable
    @inline(__always)
    public mutating func next() -> Tree._Value? {
      guard _current != _start else { return nil }
      _current = _next
      _next = _current != _begin ? __tree_.__tree_prev_iter(_current) : __tree_.nullptr
      return __tree_.__value_(_current)
    }
  }
}

extension RedBlackTreeIteratorV2.Values.Reversed {
  
  @inlinable
  @inline(__always)
  public func forEach(_ body: (Tree.Index, Tree._Value) throws -> Void) rethrows {
    try __tree_.___rev_for_each_(__p: _start, __l: _end) {
      try body(__tree_.makeIndex(rawValue: $0), __tree_.__value_($0))
    }
  }
}

extension RedBlackTreeIteratorV2.Values.Reversed {

  @inlinable
  @inline(__always)
  public var indices: UnsafeIndicesV2<Base>.Reversed {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension RedBlackTreeIteratorV2.Values.Reversed {

  @inlinable
  @inline(__always)
  package func ___node_positions() -> ___SafePointersUnsafeV2<Base>.Reversed {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension RedBlackTreeIteratorV2.Values.Reversed: Equatable where Element: Equatable {

  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.isIdentical(to: rhs) || lhs.elementsEqual(rhs)
  }
}

extension RedBlackTreeIteratorV2.Values.Reversed: Comparable where Element: Comparable {

  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    !lhs.isIdentical(to: rhs) && lhs.lexicographicallyPrecedes(rhs)
  }
}

#if swift(>=5.5)
  extension RedBlackTreeIteratorV2.Values.Reversed: @unchecked Sendable
  where Tree._Value: Sendable {}
#endif


extension RedBlackTreeIteratorV2.Values.Reversed: ___UnsafeIsIdenticalToV2 {}

import Foundation

extension RedBlackTreeIteratorV2.Keys {
  
  @frozen
  public struct Reversed: Sequence, IteratorProtocol {
    
    public typealias Tree = UnsafeTreeV2<Base>
    public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

    @usableFromInline
    internal let __tree_: Tree
    
    @usableFromInline
    internal var _start, _end, _begin, _current, _next: _NodePtr
    
    @inlinable
    @inline(__always)
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      self.__tree_ = tree
      self._current = end
      self._next = end == start ? end : __tree_.__tree_prev_iter(end)
      self._start = start
      self._end = end
      self._begin = __tree_.__begin_node_
    }
    
    @inlinable
    @inline(__always)
    public mutating func next() -> Base._Key? {
      guard _current != _start else { return nil }
      _current = _next
      _next = _current != _begin ? __tree_.__tree_prev_iter(_current) : __tree_.nullptr
      return __tree_.__get_value(_current)
    }
  }
}

extension RedBlackTreeIteratorV2.Keys.Reversed: Equatable {

  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.isIdentical(to: rhs) || Tree.with_value_equiv{ lhs.elementsEqual(rhs, by: $0) }
  }
}

extension RedBlackTreeIteratorV2.Keys.Reversed: Comparable {

  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    !lhs.isIdentical(to: rhs) && Tree.with_value_comp{ lhs.lexicographicallyPrecedes(rhs, by: $0) }
  }
}

#if swift(>=5.5)
  extension RedBlackTreeIteratorV2.Keys.Reversed: @unchecked Sendable
  where Tree._Value: Sendable {}
#endif


extension RedBlackTreeIteratorV2.Keys.Reversed: ___UnsafeIsIdenticalToV2 {}

import Foundation

extension RedBlackTreeIteratorV2.KeyValues {

  @frozen
  public struct Reversed: Sequence, IteratorProtocol {
    public typealias Tree = UnsafeTreeV2<Base>
    public typealias _Value = Tree._Value
    public typealias _NodePtr = Tree._NodePtr

    @usableFromInline
    internal let __tree_: Tree

    @usableFromInline
    internal var _start, _end, _begin, _current, _next: _NodePtr

    @inlinable
    @inline(__always)
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      self.__tree_ = tree
      self._current = end
      self._next = end == start ? end : __tree_.__tree_prev_iter(end)
      self._start = start
      self._end = end
      self._begin = __tree_.__begin_node_
    }

    @inlinable
    @inline(__always)
    public mutating func next() -> (key: Base._Key, value: Base._MappedValue)? {
      guard _current != _start else { return nil }
      _current = _next
      _next = _current != _begin ? __tree_.__tree_prev_iter(_current) : __tree_.nullptr
      return (__tree_.__get_value(_current), __tree_.___mapped_value(_current))
    }
  }
}

extension RedBlackTreeIteratorV2.KeyValues.Reversed {
  
  @inlinable
  @inline(__always)
  public func forEach(_ body: (Tree.Index, Tree._Value) throws -> Void) rethrows {
    try __tree_.___rev_for_each_(__p: _start, __l: _end) {
      try body(__tree_.makeIndex(rawValue: $0), __tree_[$0])
    }
  }
}

extension RedBlackTreeIteratorV2.KeyValues.Reversed {

  @inlinable
  @inline(__always)
  public var indices: UnsafeIndicesV2<Base>.Reversed {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension RedBlackTreeIteratorV2.KeyValues.Reversed where Base: KeyValueComparer {

  #if COMPATIBLE_ATCODER_2025
    @inlinable
    @inline(__always)
    public func keys() -> RedBlackTreeIteratorV2<Base>.Keys.Reversed {
      .init(tree: __tree_, start: _start, end: _end)
    }

    @inlinable
    @inline(__always)
    public func values() -> RedBlackTreeIteratorV2<Base>.MappedValues.Reversed {
      .init(tree: __tree_, start: _start, end: _end)
    }
  #else
    @inlinable
    @inline(__always)
    public var keys: RedBlackTreeIteratorV2<Base>.Keys.Reversed {
      .init(tree: __tree_, start: _start, end: _end)
    }

    @inlinable
    @inline(__always)
    public var values: RedBlackTreeIteratorV2<Base>.MappedValues.Reversed {
      .init(tree: __tree_, start: _start, end: _end)
    }
  #endif
}

extension RedBlackTreeIteratorV2.KeyValues.Reversed {

  @inlinable
  @inline(__always)
  package func ___node_positions() -> ___SafePointersUnsafeV2<Base>.Reversed {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension RedBlackTreeIteratorV2.KeyValues.Reversed: Equatable
where Base._Key: Equatable, Base._MappedValue: Equatable {

  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.isIdentical(to: rhs) || lhs.elementsEqual(rhs, by: ==)
  }
}

extension RedBlackTreeIteratorV2.KeyValues.Reversed: Comparable
where Base._Key: Comparable, Base._MappedValue: Comparable {

  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    !lhs.isIdentical(to: rhs) && lhs.lexicographicallyPrecedes(rhs, by: <)
  }
}

#if swift(>=5.5)
  extension RedBlackTreeIteratorV2.KeyValues.Reversed: @unchecked Sendable
  where Tree._Value: Sendable {}
#endif


extension RedBlackTreeIteratorV2.KeyValues.Reversed: ___UnsafeIsIdenticalToV2 {}

import Foundation

extension RedBlackTreeIteratorV2.MappedValues {
  
  @frozen
  public struct Reversed: Sequence, IteratorProtocol
  where Base: KeyValueComparer
  {
    public typealias Tree = UnsafeTreeV2<Base>
    
    @usableFromInline
    internal let __tree_: Tree
    
    @usableFromInline
    internal var _start, _end, _begin, _current, _next: _NodePtr
    
    @inlinable
    @inline(__always)
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      self.__tree_ = tree
      self._current = end
      self._next = end == start ? end : __tree_.__tree_prev_iter(end)
      self._start = start
      self._end = end
      self._begin = __tree_.__begin_node_
    }
    
    @inlinable
    @inline(__always)
    public mutating func next() -> Base._MappedValue? {
      guard _current != _start else { return nil }
      _current = _next
      _next = _current != _begin ? __tree_.__tree_prev_iter(_current) : __tree_.nullptr
      return __tree_.___mapped_value(_current)
    }
  }
}

extension RedBlackTreeIteratorV2.MappedValues.Reversed: Equatable where Base._MappedValue: Equatable {

  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.isIdentical(to: rhs) || lhs.elementsEqual(rhs)
  }
}

extension RedBlackTreeIteratorV2.MappedValues.Reversed: Comparable where Base._MappedValue: Comparable {

  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    !lhs.isIdentical(to: rhs) && lhs.lexicographicallyPrecedes(rhs)
  }
}

#if swift(>=5.5)
  extension RedBlackTreeIteratorV2.MappedValues.Reversed: @unchecked Sendable
  where Tree._Value: Sendable {}
#endif


extension RedBlackTreeIteratorV2.MappedValues.Reversed: ___UnsafeIsIdenticalToV2 {}

public protocol ___TreeIndex {
  associatedtype _Value
  associatedtype Pointee
  static func ___pointee(_ __value: _Value) -> Pointee
}
@inlinable
package func _arrayDescription<C: Collection>(
  for elements: C
) -> String {
  var result = "["
  var first = true
  for item in elements {
    if first {
      first = false
    } else {
      result += ", "
    }
    debugPrint(item, terminator: "", to: &result)
  }
  result += "]"
  return result
}

@inlinable
package func _dictionaryDescription<Key, Value, C: Collection>(
  for elements: C
) -> String where C.Element == (key: Key, value: Value) {
  guard !elements.isEmpty else { return "[:]" }
  var result = "["
  var first = true
  for (key, value) in elements {
    if first {
      first = false
    } else {
      result += ", "
    }
    debugPrint(key, terminator: "", to: &result)
    result += ": "
    debugPrint(value, terminator: "", to: &result)
  }
  result += "]"
  return result
}

extension KeyValueComparer where _Value == RedBlackTreePair<_Key, _MappedValue> {

  @inlinable
  @inline(__always)
  public static func __key(_ element: _Value) -> _Key { element.key }

  @inlinable
  @inline(__always)
  public static func ___mapped_value(_ element: _Value) -> _MappedValue { element.value }

  @inlinable
  @inline(__always)
  public static func ___with_mapped_value<T>(
    _ element: inout _Value, _ f: (inout _MappedValue) throws -> T
  ) rethrows -> T {
    try f(&element.value)
  }
}

import Foundation

extension String {
  
  @usableFromInline
  internal static var garbagedIndex: String {
    "A dangling node reference was used. Consider using a valid range or slice."
  }

  @usableFromInline
  internal static var invalidIndex: String {
    "Attempting to access RedBlackTree elements using an invalid index"
  }

  @usableFromInline
  internal static var outOfBounds: String {
    "RedBlackTree index is out of Bound."
  }

  @usableFromInline
  internal static var outOfRange: String {
    "RedBlackTree index is out of range."
  }
  
  @usableFromInline
  internal static var emptyFirst: String {
    "Can't removeFirst from an empty RedBlackTree"
  }

  @usableFromInline
  internal static var emptyLast: String {
    "Can't removeLast from an empty RedBlackTree"
  }
  
  @usableFromInline
  internal static func duplicateValue<Key>(for key: Key) -> String {
    "Dupricate values for key: '\(key)'"
  }
}

@frozen
public struct RedBlackTreePair<Key, Value> {

  @inlinable
  @inline(__always)
  internal init(key: Key, value: Value) {
    self.key = key
    self.value = value
  }

  @inlinable
  @inline(__always)
  package init(_ key: Key, _ value: Value) {
    self.key = key
    self.value = value
  }

  @inlinable
  @inline(__always)
  package init(_ tuple: (Key, Value)) {
    self.key = tuple.0
    self.value = tuple.1
  }

  public var key: Key
  public var value: Value
  public var tuple: (Key, Value) { (key, value) }

  @inlinable
  @inline(__always)
  public var first: Key { key }

  @inlinable
  @inline(__always)
  public var second: Value { value }
}

#if swift(>=5.5)
  extension RedBlackTreePair: Sendable where Key: Sendable, Value: Sendable {}
#endif

extension RedBlackTreePair: Hashable where Key: Hashable, Value: Hashable {}
extension RedBlackTreePair: Equatable where Key: Equatable, Value: Equatable {}
extension RedBlackTreePair: Comparable where Key: Comparable, Value: Comparable {
  public static func < (lhs: RedBlackTreePair<Key, Value>, rhs: RedBlackTreePair<Key, Value>)
    -> Bool
  {
    (lhs.key, lhs.value) < (rhs.key, rhs.value)
  }
}
extension RedBlackTreePair: Encodable where Key: Encodable, Value: Encodable {}
extension RedBlackTreePair: Decodable where Key: Decodable, Value: Decodable {}

import Foundation

@frozen
public struct RedBlackTreeSliceV2<Base>: ___UnsafeCommonV2 & ___UnsafeSubSequenceV2 & ___UnsafeIndexV2 &  ___UnsafeKeyOnlySequenceV2 where Base: ___TreeBase & ___TreeIndex {

  public typealias Tree = UnsafeTreeV2<Base>
  public typealias _NodePtr = Tree._NodePtr
  public typealias _Value = Tree._Value
  public typealias Element = Tree._Value
  public typealias Index = Tree.Index
  public typealias Indices = Tree.Indices
  public typealias SubSequence = Self

  @usableFromInline
  internal let __tree_: Tree

  @usableFromInline
  internal var _start, _end: _NodePtr

  @inlinable
  @inline(__always)
  internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
    __tree_ = tree
    _start = start
    _end = end
  }
}

extension RedBlackTreeSliceV2: Sequence & Collection & BidirectionalCollection {}

extension RedBlackTreeSliceV2 {

  @inlinable
  @inline(__always)
  public __consuming func makeIterator() -> Tree._Values {
    _makeIterator()
  }
}

extension RedBlackTreeSliceV2 {

#if !COMPATIBLE_ATCODER_2025
  @inlinable
  @inline(__always)
  public func forEach(_ body: (Element) throws -> Void) rethrows {
    try _forEach(body)
  }
#endif
}

extension RedBlackTreeSliceV2 {

  @inlinable
  @inline(__always)
  public func forEach(_ body: (Index, Element) throws -> Void) rethrows {
    try _forEach(body)
  }
}

extension RedBlackTreeSliceV2 {

  @inlinable
  @inline(__always)
  public var count: Int { _count }
}

extension RedBlackTreeSliceV2 {

  @inlinable
  @inline(__always)
  public var startIndex: Index { _startIndex }

  @inlinable
  @inline(__always)
  public var endIndex: Index { _endIndex }
}

extension RedBlackTreeSliceV2 {

  @inlinable
  public subscript(position: Index) -> Element {
    @inline(__always) _read {
      yield self[_checked: position]
    }
  }
}

extension RedBlackTreeSliceV2 {

  #if !COMPATIBLE_ATCODER_2025
    @inlinable
    public subscript(unchecked position: Index) -> Element {
      @inline(__always) _read {
        yield self[_unchecked: position]
      }
    }
  #endif
}

extension RedBlackTreeSliceV2 {

  @inlinable
  @inline(__always)
  public subscript(bounds: Range<Index>) -> SubSequence {
    __tree_.___ensureValid(
      begin: bounds.lowerBound.rawValue(__tree_),
      end: bounds.upperBound.rawValue(__tree_))
    return .init(
      tree: __tree_,
      start: bounds.lowerBound.rawValue(__tree_),
      end: bounds.upperBound.rawValue(__tree_))
  }

  #if !COMPATIBLE_ATCODER_2025
    @inlinable
    @inline(__always)
    public subscript<R>(bounds: R) -> SubSequence where R: RangeExpression, R.Bound == Index {
      let bounds: Range<Index> = bounds.relative(to: self)
      __tree_.___ensureValid(
        begin: bounds.lowerBound.rawValue(__tree_),
        end: bounds.upperBound.rawValue(__tree_))
      return .init(
        tree: __tree_,
        start: bounds.lowerBound.rawValue(__tree_),
        end: bounds.upperBound.rawValue(__tree_))
    }

    @inlinable
    @inline(__always)
    public subscript(unchecked bounds: Range<Index>) -> SubSequence {
      .init(
        tree: __tree_,
        start: bounds.lowerBound.rawValue,
        end: bounds.upperBound.rawValue)
    }

    @inlinable
    @inline(__always)
    public subscript<R>(unchecked bounds: R) -> SubSequence
    where R: RangeExpression, R.Bound == Index {
      let bounds: Range<Index> = bounds.relative(to: self)
      return .init(
        tree: __tree_,
        start: bounds.lowerBound.rawValue,
        end: bounds.upperBound.rawValue)
    }
  #endif
}

extension RedBlackTreeSliceV2 {

  @inlinable
  @inline(__always)
  public func distance(from start: Index, to end: Index) -> Int {
    _distance(from: start, to: end)
  }
}

extension RedBlackTreeSliceV2 {

  @inlinable
  @inline(__always)
  public func index(before i: Index) -> Index {
    _index(before: i)
  }

  @inlinable
  @inline(__always)
  public func index(after i: Index) -> Index {
    _index(after: i)
  }

  @inlinable
  public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
    _index(i, offsetBy: distance, limitedBy: limit)
  }
}

extension RedBlackTreeSliceV2 {

  @inlinable
  @inline(__always)
  public func formIndex(after i: inout Index) {
    _formIndex(after: &i)
  }

  @inlinable
  @inline(__always)
  public func formIndex(before i: inout Index) {
    _formIndex(before: &i)
  }

  @inlinable
  public func formIndex(_ i: inout Index, offsetBy distance: Int) {
    _formIndex(&i, offsetBy: distance)
  }

  @inlinable
  @inline(__always)  // コールスタック無駄があるのでalways
  public func formIndex(_ i: inout Index, offsetBy distance: Int, limitedBy limit: Index)
    -> Bool
  {
    _formIndex(&i, offsetBy: distance, limitedBy: limit)
  }
}


extension RedBlackTreeSliceV2 {

  @inlinable
  @inline(__always)
  public func isValid(index i: Index) -> Bool {
    ___contains(i.rawValue(__tree_))
  }
}

extension RedBlackTreeSliceV2 {

  @inlinable
  @inline(__always)
  public func isValid<R: RangeExpression>(
    _ bounds: R
  ) -> Bool where R.Bound == Index {
    let bounds = bounds.relative(to: self)
    return ___contains(bounds)
  }
}

extension RedBlackTreeSliceV2 {

  @inlinable
  @inline(__always)
  public func reversed() -> Tree._Values.Reversed {
    _reversed()
  }
}

extension RedBlackTreeSliceV2 {

  @inlinable
  @inline(__always)
  public var indices: Indices {
    _indices
  }
}

extension RedBlackTreeSliceV2 {

  @inlinable
  @inline(__always)
  public func sorted() -> [Element] {
    _sorted()
  }
}

extension RedBlackTreeSliceV2 {

  @inlinable
  @inline(__always)
  public func elementsEqual<OtherSequence>(
    _ other: OtherSequence, by areEquivalent: (Element, OtherSequence.Element) throws -> Bool
  ) rethrows -> Bool where OtherSequence: Sequence {
    try _elementsEqual(other, by: areEquivalent)
  }

  @inlinable
  @inline(__always)
  public func lexicographicallyPrecedes<OtherSequence>(
    _ other: OtherSequence, by areInIncreasingOrder: (Element, Element) throws -> Bool
  ) rethrows -> Bool where OtherSequence: Sequence, Element == OtherSequence.Element {
    try _lexicographicallyPrecedes(other, by: areInIncreasingOrder)
  }
}

extension RedBlackTreeSliceV2 where _Value: Equatable {

  @inlinable
  @inline(__always)
  public func elementsEqual<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence: Sequence, Element == OtherSequence.Element {
    _elementsEqual(other, by: ==)
  }
}

extension RedBlackTreeSliceV2 where _Value: Comparable {

  @inlinable
  @inline(__always)
  public func lexicographicallyPrecedes<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence: Sequence, Element == OtherSequence.Element {
    _lexicographicallyPrecedes(other, by: <)
  }
}

extension RedBlackTreeSliceV2: Equatable where _Value: Equatable {

  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.isIdentical(to: rhs) || lhs.elementsEqual(rhs)
  }
}

extension RedBlackTreeSliceV2: Comparable where _Value: Comparable {

  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    !lhs.isIdentical(to: rhs) && lhs.lexicographicallyPrecedes(rhs)
  }
}

#if swift(>=5.5)
  extension RedBlackTreeSliceV2: @unchecked Sendable
  where Element: Sendable {}
#endif


extension RedBlackTreeSliceV2: ___UnsafeIsIdenticalToV2 {}

import Foundation

extension RedBlackTreeSliceV2 {

  @frozen
  public struct KeyValue: ___UnsafeCommonV2 & ___UnsafeSubSequenceV2 & ___UnsafeIndexV2 & ___UnsafeKeyValueSequenceV2
  where
    Base: KeyValueComparer,
    _Value == RedBlackTreePair<Base._Key, Base._MappedValue>
  {

    public typealias Tree = UnsafeTreeV2<Base>
    public typealias _Key = Base._Key
    public typealias _Value = Tree._Value
    public typealias _MappedValue = Base._MappedValue
    public typealias Element = (key: _Key, value: _MappedValue)
    public typealias Index = Tree.Index
    public typealias Indices = Tree.Indices
    public typealias SubSequence = Self

    @usableFromInline
    internal let __tree_: Tree

    @usableFromInline
    internal var _start, _end: _NodePtr

    @inlinable
    @inline(__always)
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      __tree_ = tree
      _start = start
      _end = end
    }
  }
}

extension RedBlackTreeSliceV2.KeyValue: Sequence & Collection & BidirectionalCollection {}

extension RedBlackTreeSliceV2.KeyValue {

  @inlinable
  @inline(__always)
  public __consuming func makeIterator() -> Tree._KeyValues {
    _makeIterator()
  }
}

extension RedBlackTreeSliceV2.KeyValue {

  #if !COMPATIBLE_ATCODER_2025
    @inlinable
    @inline(__always)
    public func forEach(_ body: (Element) throws -> Void) rethrows {
      try _forEach(body)
    }
  #endif
}

extension RedBlackTreeSliceV2.KeyValue {

  @inlinable
  @inline(__always)
  public func forEach(_ body: (Index, Element) throws -> Void) rethrows {
    try _forEach(body)
  }
}

extension RedBlackTreeSliceV2.KeyValue {

  @inlinable
  @inline(__always)
  public var count: Int { _count }
}

extension RedBlackTreeSliceV2.KeyValue {

  @inlinable
  @inline(__always)
  public var startIndex: Index { _startIndex }

  @inlinable
  @inline(__always)
  public var endIndex: Index { _endIndex }
}

/*
 コメントアウトの多さはテストコードのコンパイラクラッシュに由来する。
 */

extension RedBlackTreeSliceV2.KeyValue {

  @inlinable
  public subscript(position: Index) -> (key: _Key, value: _MappedValue) {
    @inline(__always) get { self[_checked: position] }
  }
}

extension RedBlackTreeSliceV2.KeyValue {

  #if !COMPATIBLE_ATCODER_2025
    @inlinable
    public subscript(unchecked position: Index) -> (key: _Key, value: _MappedValue) {
      @inline(__always) get { self[_unchecked: position] }
    }
  #endif
}

extension RedBlackTreeSliceV2.KeyValue {

  @inlinable
  @inline(__always)
  public subscript(bounds: Range<Index>) -> SubSequence {
    __tree_.___ensureValid(
      begin: bounds.lowerBound.rawValue(__tree_),
      end: bounds.upperBound.rawValue(__tree_))
    return .init(
      tree: __tree_,
      start: bounds.lowerBound.rawValue(__tree_),
      end: bounds.upperBound.rawValue(__tree_))
  }

  #if !COMPATIBLE_ATCODER_2025
    @inlinable
    @inline(__always)
    public subscript<R>(bounds: R) -> SubSequence where R: RangeExpression, R.Bound == Index {
      let bounds: Range<Index> = bounds.relative(to: self)
      __tree_.___ensureValid(
        begin: bounds.lowerBound.rawValue(__tree_),
        end: bounds.upperBound.rawValue(__tree_))
      return .init(
        tree: __tree_,
        start: bounds.lowerBound.rawValue(__tree_),
        end: bounds.upperBound.rawValue(__tree_))
    }

    @inlinable
    @inline(__always)
    public subscript(unchecked bounds: Range<Index>) -> SubSequence {
      .init(
        tree: __tree_,
        start: bounds.lowerBound.rawValue(__tree_),
        end: bounds.upperBound.rawValue(__tree_))
    }

    @inlinable
    @inline(__always)
    public subscript<R>(unchecked bounds: R) -> SubSequence
    where R: RangeExpression, R.Bound == Index {
      let bounds: Range<Index> = bounds.relative(to: self)
      return .init(
        tree: __tree_,
        start: bounds.lowerBound.rawValue(__tree_),
        end: bounds.upperBound.rawValue(__tree_))
    }
  #endif
}

extension RedBlackTreeSliceV2.KeyValue {

  @inlinable
  @inline(__always)
  public func distance(from start: Index, to end: Index) -> Int {
    _distance(from: start, to: end)
  }
}

extension RedBlackTreeSliceV2.KeyValue {

  @inlinable
  @inline(__always)
  public func index(before i: Index) -> Index {
    _index(before: i)
  }

  @inlinable
  @inline(__always)
  public func index(after i: Index) -> Index {
    _index(after: i)
  }

  @inlinable
  public func index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
    _index(i, offsetBy: distance, limitedBy: limit)
  }
}

extension RedBlackTreeSliceV2.KeyValue {

  @inlinable
  @inline(__always)
  public func formIndex(after i: inout Index) {
    _formIndex(after: &i)
  }

  @inlinable
  @inline(__always)
  public func formIndex(before i: inout Index) {
    _formIndex(before: &i)
  }

  @inlinable
  public func formIndex(_ i: inout Index, offsetBy distance: Int) {
    _formIndex(&i, offsetBy: distance)
  }

  @inlinable
  @inline(__always)  // コールスタック無駄があるのでalways
  public func formIndex(_ i: inout Index, offsetBy distance: Int, limitedBy limit: Index)
    -> Bool
  {
    _formIndex(&i, offsetBy: distance, limitedBy: limit)
  }
}


extension RedBlackTreeSliceV2.KeyValue {

  @inlinable
  @inline(__always)
  public func isValid(index i: Index) -> Bool {
    ___contains(i.rawValue(__tree_))
  }
}

extension RedBlackTreeSliceV2.KeyValue {

  @inlinable
  @inline(__always)
  public func isValid<R: RangeExpression>(
    _ bounds: R
  ) -> Bool where R.Bound == Index {
    let bounds = bounds.relative(to: self)
    return ___contains(bounds)
  }
}

extension RedBlackTreeSliceV2.KeyValue {

  @inlinable
  @inline(__always)
  public func reversed() -> Tree._KeyValues.Reversed {
    _reversed()
  }
}

extension RedBlackTreeSliceV2.KeyValue {

  @inlinable
  @inline(__always)
  public var indices: Indices {
    _indices
  }
}

extension RedBlackTreeSliceV2.KeyValue {

  public typealias Keys = RedBlackTreeIteratorV2<Base>.Keys
  public typealias Values = RedBlackTreeIteratorV2<Base>.MappedValues

  #if !COMPATIBLE_ATCODER_2025
    @inlinable
    @inline(__always)
    public var keys: Keys {
      _keys()
    }

    @inlinable
    @inline(__always)
    public var values: Values {
      _values()
    }
  #endif
}

extension RedBlackTreeSliceV2.KeyValue {

  @inlinable
  @inline(__always)
  public func sorted() -> [Element] {
    _sorted()
  }
}

extension RedBlackTreeSliceV2.KeyValue where _Key: Equatable, _MappedValue: Equatable {

  @inlinable
  @inline(__always)
  public func elementsEqual<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence: Sequence, Element == OtherSequence.Element {
    elementsEqual(other, by: ==)
  }
}

extension RedBlackTreeSliceV2.KeyValue where _Key: Comparable, _MappedValue: Comparable {

  @inlinable
  @inline(__always)
  public func lexicographicallyPrecedes<OtherSequence>(_ other: OtherSequence) -> Bool
  where OtherSequence: Sequence, Element == OtherSequence.Element {
    lexicographicallyPrecedes(other, by: <)
  }
}

extension RedBlackTreeSliceV2.KeyValue: Equatable where _Key: Equatable, _MappedValue: Equatable {

  @inlinable
  @inline(__always)
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.isIdentical(to: rhs) || lhs.elementsEqual(rhs, by: ==)
  }
}

extension RedBlackTreeSliceV2.KeyValue: Comparable where _Key: Comparable, _MappedValue: Comparable {

  @inlinable
  @inline(__always)
  public static func < (lhs: Self, rhs: Self) -> Bool {
    !lhs.isIdentical(to: rhs) && lhs.lexicographicallyPrecedes(rhs, by: <)
  }
}

#if swift(>=5.5)
  extension RedBlackTreeSliceV2.KeyValue: @unchecked Sendable
  where Element: Sendable {}
#endif


extension RedBlackTreeSliceV2.KeyValue: ___UnsafeIsIdenticalToV2 {}

public typealias ___TreeBase = ValueComparer & CompareTrait & ThreeWayComparator

public protocol ___Root {
  associatedtype Base
  associatedtype Tree
}

@usableFromInline
protocol ___UnsafeIndexBaseV2: ___Root
where
  Base: ___TreeBase & ___TreeIndex,
  Tree == UnsafeTreeV2<Base>,
  Index == Tree.Index,
  _NodePtr == Tree._NodePtr
{
  associatedtype Index
  associatedtype _NodePtr
  var __tree_: Tree { get }
}

extension ___UnsafeIndexBaseV2 {

  @inlinable
  @inline(__always)
  internal func ___index(_ p: _NodePtr) -> Index {
    __tree_.makeIndex(rawValue: p)
  }

  @inlinable
  @inline(__always)
  internal func ___index_or_nil(_ p: _NodePtr) -> Index? {
    p == __tree_.nullptr ? nil : ___index(p)
  }

  @inlinable
  @inline(__always)
  internal func ___index_or_nil(_ p: _NodePtr?) -> Index? {
    p.map { ___index($0) }
  }
}

@usableFromInline
protocol ___UnsafeBaseV2: ___UnsafeIndexBaseV2
where
  Base: ___TreeBase & ___TreeIndex,
  Tree == UnsafeTreeV2<Base>,
  Index == Tree.Index,
  Indices == Tree.Indices,
  _Key == Tree._Key,
  _Value == Tree._Value
{
  associatedtype Index
  associatedtype Indices
  associatedtype _Key
  associatedtype _Value
  associatedtype Element
  var __tree_: Tree { get }
  var _start: _NodePtr { get }
  var _end: _NodePtr { get }
}


public typealias RedBlackTreeIndex = UnsafeIndexV2
public typealias RedBlackTreeIndices = UnsafeIndicesV2
public typealias RedBlackTreeIterator = RedBlackTreeIteratorV2
public typealias RedBlackTreeSlice = RedBlackTreeSliceV2

@usableFromInline
protocol ___RedBlackTreeKeyOnlyBase:
  ___UnsafeStorageProtocolV2 & ___UnsafeCopyOnWriteV2 & ___UnsafeCommonV2 & ___UnsafeIndexV2 & ___UnsafeBaseSequenceV2
    & ___UnsafeKeyOnlySequenceV2
{}
@usableFromInline
protocol ___RedBlackTreeKeyValuesBase:
  ___UnsafeStorageProtocolV2 & ___UnsafeCopyOnWriteV2 & ___UnsafeCommonV2 & ___UnsafeIndexV2 & ___UnsafeBaseSequenceV2
    & ___UnsafeKeyValueSequenceV2
{}

@usableFromInline
protocol ___UnsafeCommonV2: ___UnsafeBaseV2 {}

extension ___UnsafeCommonV2 {

  @inlinable
  @inline(__always)
  internal var ___is_empty: Bool {
    __tree_.___is_empty || _start == _end
  }

  @inlinable
  @inline(__always)
  internal var ___first: _Value? {
    ___is_empty ? nil : __tree_[_start]
  }

  @inlinable
  @inline(__always)
  internal var ___last: _Value? {
    ___is_empty ? nil : __tree_[__tree_.__tree_prev_iter(_end)]
  }
}

extension ___UnsafeCommonV2 {

  @inlinable
  @inline(__always)
  internal func _distance(from start: Index, to end: Index) -> Int {
    __tree_.___distance(from: start.rawValue(__tree_), to: end.rawValue(__tree_))
  }
}

extension ___UnsafeCommonV2 {

  @inlinable
  @inline(__always)
  internal func ___is_valid(_ index: _NodePtr) -> Bool {
    !__tree_.___is_subscript_null(index)
  }

  @inlinable
  @inline(__always)
  internal func ___is_valid_range(_ p: _NodePtr, _ l: _NodePtr) -> Bool {
    !__tree_.___is_range_null(p, l)
  }
}

extension ___UnsafeCommonV2 {

  @inlinable
  @inline(__always)
  internal var ___key_comp: (_Key, _Key) -> Bool {
    __tree_.value_comp
  }

  @inlinable
  @inline(__always)
  internal var ___value_comp: (_Value, _Value) -> Bool {
    { __tree_.value_comp(Base.__key($0), Base.__key($1)) }
  }
}

extension ___UnsafeCommonV2 {

  @inlinable
  @inline(__always)
  internal func _isIdentical(to other: Self) -> Bool {
    __tree_.isIdentical(to: other.__tree_) && _start == other._start && _end == other._end
  }
}

extension ___UnsafeCommonV2 {
  @inlinable
  @inline(__always)
  internal var _indices: Indices {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

@usableFromInline
typealias ReferenceCounter = ManagedBuffer<Void, Void>

extension ManagedBuffer where Header == Void, Element == Void {

  @inlinable
  @inline(__always)
  static func create() -> ManagedBuffer {
    ManagedBuffer<Void, Void>.create(minimumCapacity: 0) { _ in }
  }
}

@usableFromInline
protocol ___UnsafeCopyOnWriteV2 {
  associatedtype Base: ___TreeBase
  #if !USE_SIMPLE_COPY_ON_WRITE || COMPATIBLE_ATCODER_2025
    var referenceCounter: ReferenceCounter { get set }
  #endif
  var __tree_: UnsafeTreeV2<Base> { get set }
}

extension ___UnsafeCopyOnWriteV2 {

  @inlinable
  @inline(__always)
  internal mutating func _isKnownUniquelyReferenced_LV1() -> Bool {
    #if !DISABLE_COPY_ON_WRITE
      #if !USE_SIMPLE_COPY_ON_WRITE || COMPATIBLE_ATCODER_2025
        !__tree_.isReadOnly && isKnownUniquelyReferenced(&referenceCounter)
      #else
        __tree_._buffer.isUniqueReference()
      #endif
    #else
      true
    #endif
  }

  @inlinable
  @inline(__always)
  internal mutating func _isKnownUniquelyReferenced_LV2() -> Bool {
    #if !DISABLE_COPY_ON_WRITE
      if !_isKnownUniquelyReferenced_LV1() {
        return false
      }
      if !__tree_._buffer.isUniqueReference() {
        return false
      }
    #endif
    return true
  }

  @inlinable
  @inline(__always)
  internal mutating func _ensureUnique() {
    if !_isKnownUniquelyReferenced_LV1() {
      __tree_ = __tree_.copy()
    }
  }

  @inlinable
  @inline(__always)
  internal mutating func _strongEnsureUnique() {
    if !_isKnownUniquelyReferenced_LV2() {
      __tree_ = __tree_.copy()
    }
  }

  @inlinable
  @inline(__always)
  internal mutating func _ensureUnique(
    transform: (UnsafeTreeV2<Base>) throws -> UnsafeTreeV2<Base>
  )
    rethrows
  {
    _ensureUnique()
    __tree_ = try transform(__tree_)
  }

  @inlinable
  @inline(__always)
  internal mutating func _ensureUniqueAndCapacity() {
    _ensureUniqueAndCapacity(to: __tree_.count + 1)
    assert(__tree_.capacity > 0)
    assert(__tree_.capacity > __tree_.count)
  }

  @inlinable
  @inline(__always)
  internal mutating func _ensureUniqueAndCapacity(to minimumCapacity: Int) {
    let shouldExpand = __tree_.capacity < minimumCapacity
    if !_isKnownUniquelyReferenced_LV1() {
      __tree_ = __tree_.copy(growthCapacityTo: minimumCapacity, linearly: false)
    } else if shouldExpand {
      __tree_.growthCapacity(to: minimumCapacity, linearly: false)
    }
    assert(__tree_.initializedCount <= __tree_.capacity)
  }

  @inlinable
  @inline(__always)
  internal mutating func _ensureUniqueAndCapacity(limit: Int, linearly: Bool = false) {
    _ensureUniqueAndCapacity(to: __tree_.count + 1, limit: limit, linearly: linearly)
    assert(__tree_.capacity > 0)
  }

  @inlinable
  @inline(__always)
  internal mutating func _ensureUniqueAndCapacity(
    to minimumCapacity: Int, limit: Int, linearly: Bool
  ) {
    let shouldExpand = __tree_.capacity < minimumCapacity
    if !_isKnownUniquelyReferenced_LV1() {
      __tree_ = __tree_.copy(
        growthCapacityTo: minimumCapacity,
        limit: limit,
        linearly: false)
    } else if shouldExpand {
      __tree_.growthCapacity(to: minimumCapacity, limit: limit, linearly: false)
    }
    assert(__tree_.capacity >= minimumCapacity)
    assert(__tree_.initializedCount <= __tree_.capacity)
  }

  @inlinable
  @inline(__always)
  internal mutating func _ensureCapacity() {
    _ensureCapacity(amount: 1)
  }

  @inlinable
  @inline(__always)
  internal mutating func _ensureCapacity(amount: Int) {
    let minimumCapacity = __tree_.count + amount
    if __tree_.capacity < minimumCapacity {
      __tree_.growthCapacity(to: minimumCapacity, linearly: false)
    }
    assert(__tree_.capacity >= minimumCapacity)
    assert(__tree_.initializedCount <= __tree_.capacity)
  }

  @inlinable
  @inline(__always)
  internal mutating func _ensureCapacity(limit: Int, linearly: Bool = false) {
    _ensureCapacity(to: __tree_.count + 1, limit: limit, linearly: linearly)
  }

  @inlinable
  @inline(__always)
  internal mutating func _ensureCapacity(to minimumCapacity: Int, limit: Int, linearly: Bool) {
    if __tree_.capacity < min(limit, minimumCapacity) {
      __tree_.growthCapacity(to: min(limit, minimumCapacity), limit: limit, linearly: false)
    }
    //#if USE_FRESH_POOL_V1
    #if !USE_FRESH_POOL_V2
    assert(__tree_.initializedCount <= __tree_.capacity)
#else
    assert(__tree_.initializedCount <= __tree_._buffer.header.freshPool.capacity)
#endif
  }
}

@usableFromInline
protocol ___UnsafeIndexV2: ___UnsafeBaseV2 {}

extension ___UnsafeIndexV2 {

  @inlinable
  @inline(__always)
  internal var _startIndex: Index {
    ___index(_start)
  }

  @inlinable
  @inline(__always)
  internal var _endIndex: Index {
    ___index(_end)
  }

  @inlinable
  @inline(__always)
  internal func _index(after i: Index) -> Index {
    ___index(__tree_.___index(after: i.rawValue(__tree_)))
  }

  @inlinable
  @inline(__always)
  internal func _formIndex(after i: inout Index) {
    __tree_.___formIndex(after: &i.rawValue)
  }

  @inlinable
  @inline(__always)
  internal func _index(before i: Index) -> Index {
    ___index(__tree_.___index(before: i.rawValue(__tree_)))
  }

  @inlinable
  @inline(__always)
  internal func _formIndex(before i: inout Index) {
    __tree_.___formIndex(before: &i.rawValue)
  }

  @inlinable
  @inline(__always)
  internal func _index(_ i: Index, offsetBy distance: Int) -> Index {
    ___index(__tree_.___index(i.rawValue(__tree_), offsetBy: distance))
  }

  @inlinable
  @inline(__always)
  internal func _formIndex(_ i: inout Index, offsetBy distance: Int) {
    __tree_.___formIndex(&i.rawValue, offsetBy: distance)
  }

  @inlinable
  @inline(__always)
  internal func _index(_ i: Index, offsetBy distance: Int, limitedBy limit: Index) -> Index? {
    ___index_or_nil(__tree_.___index(i.rawValue(__tree_), offsetBy: distance, limitedBy: limit.rawValue(__tree_)))
  }

  @inlinable
  @inline(__always)
  internal func _formIndex(_ i: inout Index, offsetBy distance: Int, limitedBy limit: Index)
    -> Bool
  {
    __tree_.___formIndex(&i.rawValue, offsetBy: distance, limitedBy: limit.rawValue)
  }
}

extension ___UnsafeIndexV2 {

  @inlinable
  @inline(__always)
  internal func ___first_index(where predicate: (_Value) throws -> Bool) rethrows -> Index? {
    var result: Index?
    try __tree_.___for_each(__p: _start, __l: _end) { __p, cont in
      if try predicate(__tree_[__p]) {
        result = ___index(__p)
        cont = false
      }
    }
    return result
  }
}

extension ___UnsafeIndexV2 {

  @inlinable
  @inline(__always)
  internal func ___first(where predicate: (_Value) throws -> Bool) rethrows -> _Value? {
    var result: _Value?
    try __tree_.___for_each(__p: _start, __l: _end) { __p, cont in
      if try predicate(__tree_[__p]) {
        result = __tree_[__p]
        cont = false
      }
    }
    return result
  }
}

extension ___UnsafeIndexV2 {

  @inlinable
  @inline(__always)
  internal func _isValid(index: Index) -> Bool {
    !__tree_.___is_subscript_null(index.rawValue(__tree_))
  }
}

extension ___UnsafeIndexV2 where Self: Collection {

  @inlinable
  @inline(__always)
  internal func _isValid<R: RangeExpression>(
    _ bounds: R
  ) -> Bool where R.Bound == Index {

    let bounds = bounds.relative(to: self)
    return !__tree_.___is_range_null(
      bounds.lowerBound.rawValue(__tree_),
      bounds.upperBound.rawValue(__tree_))
  }
}

extension ___UnsafeIndexV2 where Base: CompareUniqueTrait {

  @inlinable
  @inline(__always)
  internal func ___equal_range(_ k: Tree._Key) -> (lower: _NodePtr, upper: _NodePtr) {
    __tree_.__equal_range_unique(k)
  }

  @inlinable
  @inline(__always)
  internal func ___index_equal_range(_ k: Tree._Key) -> (lower: Index, upper: Index) {
    let (lo, hi) = ___equal_range(k)
    return (___index(lo), ___index(hi))
  }
}

extension ___UnsafeIndexV2 where Base: CompareMultiTrait {

  @inlinable
  @inline(__always)
  internal func ___equal_range(_ k: Tree._Key) -> (lower: _NodePtr, upper: _NodePtr) {
    __tree_.__equal_range_multi(k)
  }

  @inlinable
  @inline(__always)
  internal func ___index_equal_range(_ k: Tree._Key) -> (lower: Index, upper: Index) {
    let (lo, hi) = ___equal_range(k)
    return (___index(lo), ___index(hi))
  }
}

extension ___UnsafeIndexV2 {

  @inlinable
  @inline(__always)
  @discardableResult
  public mutating func ___erase(_ ptr: Index) -> Index {
    ___index(__tree_.erase(ptr.rawValue(__tree_)))
  }
}

@usableFromInline
protocol ___UnsafeIsIdenticalToV2 {
  associatedtype Base: ___TreeBase
  var __tree_: UnsafeTreeV2<Base> { get }
  var _start: UnsafeTreeV2<Base>._NodePtr { get }
  var _end: UnsafeTreeV2<Base>._NodePtr { get }
}


extension ___UnsafeIsIdenticalToV2 {

  @inlinable
  @inline(__always)
  public func isIdentical(to other: Self) -> Bool {
    __tree_.isIdentical(to: other.__tree_) && _start == other._start && _end == other._end
  }
}

@usableFromInline
protocol ___UnsafeKeyOnlySequenceV2: ___UnsafeBaseV2, ___TreeIndex where _Value == Element {}

extension ___UnsafeKeyOnlySequenceV2 {
  
  @inlinable
  @inline(__always)
  public static func ___pointee(_ __value: _Value) -> Element { __value }
}

extension ___UnsafeKeyOnlySequenceV2 {

  @inlinable
  @inline(__always)
  internal func _makeIterator() -> Tree._Values {
    .init(tree: __tree_, start: _start, end: _end)
  }

  @inlinable
  @inline(__always)
  internal func _reversed() -> Tree._Values.Reversed {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension ___UnsafeKeyOnlySequenceV2 {

  @inlinable
  @inline(__always)
  internal func _forEach(_ body: (_Value) throws -> Void) rethrows {
    try __tree_.___for_each_(__p: _start, __l: _end) {
      try body(__tree_[$0])
    }
  }
}

extension ___UnsafeKeyOnlySequenceV2 {

  @inlinable
  @inline(__always)
  internal func _forEach(_ body: (Index, _Value) throws -> Void) rethrows {
    try __tree_.___for_each_(__p: _start, __l: _end) {
      try body(___index($0), __tree_[$0])
    }
  }
}

extension ___UnsafeKeyOnlySequenceV2 {

  @inlinable
  @inline(__always)
  internal func _sorted() -> [_Value] {
    __tree_.___copy_to_array(_start, _end)
  }
}

extension ___UnsafeKeyOnlySequenceV2 {

  @inlinable
  internal subscript(_checked position: Index) -> _Value {
    @inline(__always) _read {
      __tree_.___ensureValid(subscript: position.rawValue(__tree_))
      yield __tree_[position.rawValue(__tree_)]
    }
  }

  @inlinable
  internal subscript(_unchecked position: Index) -> _Value {
    @inline(__always) _read {
      yield __tree_[position.rawValue(__tree_)]
    }
  }
}

extension ___UnsafeKeyOnlySequenceV2 {

  @inlinable
  @inline(__always)
  internal func _elementsEqual<OtherSequence>(
    _ other: OtherSequence, by areEquivalent: (_Value, OtherSequence.Element) throws -> Bool
  ) rethrows -> Bool where OtherSequence: Sequence {
    try __tree_.elementsEqual(_start, _end, other, by: areEquivalent)
  }

  @inlinable
  @inline(__always)
  internal func _lexicographicallyPrecedes<OtherSequence>(
    _ other: OtherSequence, by areInIncreasingOrder: (_Value, _Value) throws -> Bool
  ) rethrows -> Bool where OtherSequence: Sequence, _Value == OtherSequence.Element {
    try __tree_.lexicographicallyPrecedes(_start, _end, other, by: areInIncreasingOrder)
  }
}

extension ___UnsafeKeyOnlySequenceV2 {

  @inlinable
  @inline(__always)
  public mutating func ___element(at ptr: _NodePtr) -> _Value? {
    guard !__tree_.___is_subscript_null(ptr) else {
      return nil
    }
    return __tree_[ptr]
  }
}

@usableFromInline
protocol ___UnsafeKeyValueSequenceV2: ___UnsafeBaseV2, ___TreeIndex
where
  Base: KeyValueComparer,
  Element == (key: _Key, value: _MappedValue),
  _Value == RedBlackTreePair<_Key, _MappedValue>
{
  associatedtype _MappedValue
}

extension ___UnsafeKeyValueSequenceV2 {

  @inlinable
  @inline(__always)
  internal static func ___element(_ __value: _Value) -> Element {
    (__value.key, __value.value)
  }

  @inlinable
  @inline(__always)
  internal static func ___tree_value(_ __element: Element) -> _Value {
    RedBlackTreePair(__element.key, __element.value)
  }

  @inlinable
  @inline(__always)
  public static func ___pointee(_ __value: _Value) -> Element {
    Self.___element(__value)
  }
}

extension ___UnsafeKeyValueSequenceV2 {

  @inlinable
  @inline(__always)
  internal func ___element(_ __value: _Value) -> Element {
    Self.___element(__value)
  }
}

extension ___UnsafeKeyValueSequenceV2 where Self: ___UnsafeCommonV2 {

  @inlinable
  @inline(__always)
  internal var ___first: Element? {
    ___first.map(___element)
  }

  @inlinable
  @inline(__always)
  internal var ___last: Element? {
    ___last.map(___element)
  }
}

extension ___UnsafeKeyValueSequenceV2 where Self: ___UnsafeBaseSequenceV2 {

  @inlinable
  internal func ___min() -> Element? {
    ___min().map(___element)
  }

  @inlinable
  internal func ___max() -> Element? {
    ___max().map(___element)
  }
}

extension ___UnsafeKeyValueSequenceV2 where Self: ___UnsafeIndexV2 {

  @inlinable
  internal func ___first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
    try ___first { try predicate(___element($0)) }.map(___element)
  }

  @inlinable
  internal func ___first_index(where predicate: (Element) throws -> Bool) rethrows -> Index? {
    try ___first_index { try predicate(___element($0)) }
  }
}

extension ___UnsafeKeyValueSequenceV2 {

  @inlinable
  @inline(__always)
  internal func ___value_for(_ __k: _Key) -> _Value? {
    let __ptr = __tree_.find(__k)
    return __tree_.___is_null_or_end(__ptr) ? nil : __tree_[__ptr]
  }
}

extension ___UnsafeKeyValueSequenceV2 {

  @inlinable
  @inline(__always)
  internal func _makeIterator() -> Tree._KeyValues {
    .init(tree: __tree_, start: _start, end: _end)
  }

  @inlinable
  @inline(__always)
  internal func _reversed() -> Tree._KeyValues.Reversed {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension ___UnsafeKeyValueSequenceV2 {

  public typealias Keys = RedBlackTreeIteratorV2<Base>.Keys
  public typealias Values = RedBlackTreeIteratorV2<Base>.MappedValues

  @inlinable
  @inline(__always)
  internal func _keys() -> Keys {
    .init(tree: __tree_, start: _start, end: _end)
  }

  @inlinable
  @inline(__always)
  internal func _values() -> Values {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension ___UnsafeKeyValueSequenceV2 {

  @inlinable
  @inline(__always)
  internal func _forEach(_ body: (Element) throws -> Void) rethrows {
    try __tree_.___for_each_(__p: _start, __l: _end) {
      try body(Self.___element(__tree_[$0]))
    }
  }
}

extension ___UnsafeKeyValueSequenceV2 {

  @inlinable
  @inline(__always)
  internal func _forEach(_ body: (Index, Element) throws -> Void) rethrows {
    try __tree_.___for_each_(__p: _start, __l: _end) {
      try body(___index($0), Self.___element(__tree_[$0]))
    }
  }
}

extension ___UnsafeKeyValueSequenceV2 {

  @inlinable
  @inline(__always)
  internal func _sorted() -> [Element] {
    __tree_.___copy_to_array(_start, _end, transform: Self.___element)
  }
}

extension ___UnsafeKeyValueSequenceV2 {


  @inlinable
  internal subscript(_checked position: Index) -> (key: _Key, value: _MappedValue) {
    @inline(__always) get {
      __tree_.___ensureValid(subscript: position.rawValue(__tree_))
      return ___element(__tree_[position.rawValue(__tree_)])
    }
  }

  @inlinable
  internal subscript(_unchecked position: Index) -> (key: _Key, value: _MappedValue) {
    @inline(__always) get {
      return ___element(__tree_[position.rawValue(__tree_)])
    }
  }
}

extension ___UnsafeKeyValueSequenceV2 {

  @inlinable
  @inline(__always)
  public mutating func ___element(at ptr: _NodePtr) -> _Value? {
    guard !__tree_.___is_subscript_null(ptr) else {
      return nil
    }
    return __tree_[ptr]
  }
}

@usableFromInline
protocol ___UnsafeStorageProtocolV2: ___Root
where
  Base: ___TreeBase,
  Tree == UnsafeTreeV2<Base>,
  _Value == Tree._Value,
  _NodePtr == Tree._NodePtr
{
  associatedtype _Value
  associatedtype _NodePtr
  var __tree_: Tree { get set }
}

extension ___UnsafeStorageProtocolV2 {
  
  @inlinable
  @inline(__always)
  internal var _start: _NodePtr {
    __tree_.__begin_node_
  }

  @inlinable
  @inline(__always)
  internal var _end: _NodePtr {
    __tree_.__end_node
  }

  @inlinable
  @inline(__always)
  internal var ___count: Int {
    __tree_.count
  }

  @inlinable
  @inline(__always)
  internal var ___capacity: Int {
    __tree_.capacity
  }
}


extension ___UnsafeStorageProtocolV2 {

  @inlinable
  @inline(__always)
  @discardableResult
  internal mutating func ___remove(at ptr: _NodePtr) -> _Value? {
    guard !__tree_.___is_subscript_null(ptr) else {
      return nil
    }
    let e = __tree_[ptr]
    _ = __tree_.erase(ptr)
    return e
  }

  @inlinable
  @inline(__always)
  @discardableResult
  internal mutating func ___remove(from: _NodePtr, to: _NodePtr) -> _NodePtr {
    guard !__tree_.___is_end(from) else {
      return __tree_.end
    }
    __tree_.___ensureValid(begin: from, end: to)
    return __tree_.erase(from, to)
  }
}

extension ___UnsafeStorageProtocolV2 {

  @inlinable
  @inline(__always)
  internal mutating func ___removeAll(keepingCapacity keepCapacity: Bool = false) {

    if keepCapacity {
      __tree_.__eraseAll()
    } else {
      __tree_ = .create(minimumCapacity: 0)
    }
  }
}


@frozen
@usableFromInline
package struct ___SafePointersUnsafeV2<Base>: Sequence, IteratorProtocol
where Base: ___TreeBase {

  @usableFromInline
  package typealias Tree = UnsafeTreeV2<Base>

  @usableFromInline
  package typealias _NodePtr = Tree._NodePtr

  @usableFromInline
  package let __tree_: Tree

  @usableFromInline
  package var _start, _end, _current, _next: _NodePtr

  @inlinable
  @inline(__always)
  package init(tree: Tree, start: _NodePtr, end: _NodePtr) {
    self.__tree_ = tree
    self._current = start
    self._start = start
    self._end = end
    self._next = start == tree.end ? tree.end : tree.__tree_next_iter(start)
  }

  @inlinable
  @inline(__always)
  package mutating func next() -> _NodePtr? {
    guard _current != _end else { return nil }
    defer {
      _current = _next
      _next = _next == _end ? _end : __tree_.__tree_next_iter(_next)
    }
    return _current
  }

  @inlinable
  @inline(__always)
  internal func reversed() -> Reversed {
    .init(tree: __tree_, start: _start, end: _end)
  }
}

extension ___SafePointersUnsafeV2 {

  @frozen
  @usableFromInline
  package struct Reversed: Sequence, IteratorProtocol
  where Base: ___TreeBase {

    @usableFromInline
    internal typealias Tree = UnsafeTreeV2<Base>

    @usableFromInline
    internal let __tree_: Tree

    @usableFromInline
    internal var _start, _begin, _current, _next: _NodePtr

    @inlinable
    @inline(__always)
    internal init(tree: Tree, start: _NodePtr, end: _NodePtr) {
      self.__tree_ = tree
      self._current = end
      self._next = end == start ? end : __tree_.__tree_prev_iter(end)
      self._start = start
      self._begin = __tree_.__begin_node_
    }

    @inlinable
    @inline(__always)
    package mutating func next() -> _NodePtr? {
      guard _current != _start else { return nil }
      _current = _next
      _next = _current != _begin ? __tree_.__tree_prev_iter(_current) : __tree_.nullptr
      return _current
    }
  }
}

@frozen
@usableFromInline
struct ___UnsafePointersUnsafeV2<Base>: Sequence, IteratorProtocol
where Base: ___TreeBase {

  @usableFromInline
  internal typealias Tree = UnsafeTreeV2<Base>

  public typealias _NodePtr = Tree._NodePtr

  @usableFromInline
  internal let __tree_: Tree

  @usableFromInline
  internal var __first, __last: _NodePtr

  @inlinable
  @inline(__always)
  internal init(tree: Tree, __first: _NodePtr, __last: _NodePtr) {
    self.__tree_ = tree
    self.__first = __first
    self.__last = __last
  }

  @inlinable
  @inline(__always)
  internal mutating func next() -> _NodePtr? {
    guard __first != __last else { return nil }
    defer { __first = __tree_.__tree_next_iter(__first) }
    return __first
  }
}

@frozen
@usableFromInline
struct ___UnsafeValuesUnsafeV2<Base>: Sequence, IteratorProtocol
where Base: ___TreeBase {

  @usableFromInline
  internal typealias Tree = UnsafeTreeV2<Base>

  public typealias _NodePtr = Tree._NodePtr

  @usableFromInline
  internal let __tree_: Tree

  @usableFromInline
  internal var __first, __last: _NodePtr

  @inlinable
  @inline(__always)
  internal init(tree: Tree, __first: _NodePtr, __last: _NodePtr) {
    self.__tree_ = tree
    self.__first = __first
    self.__last = __last
  }

  @inlinable
  @inline(__always)
  internal mutating func next() -> Tree._Value? {
    guard __first != __last else { return nil }
    defer { __first = __tree_.__tree_next_iter(__first) }
    return UnsafePair<Tree._Value>.valuePointer(__first)!.pointee
  }
}

@usableFromInline
protocol ___UnsafeBaseSequenceV2: ___UnsafeBaseV2 {
  func ___index_or_nil(_ p: _NodePtr) -> Index?
}

extension ___UnsafeBaseSequenceV2 {

  @inlinable
  @inline(__always)
  internal func ___contains(_ __k: _Key) -> Bool {
    __tree_.__count_unique(__k) != 0
  }
}

extension ___UnsafeBaseSequenceV2 {

  @inlinable
  @inline(__always)
  internal func ___min() -> _Value? {
    __tree_.__root == __tree_.nullptr ? nil : __tree_[__tree_.__tree_min(__tree_.__root)]
  }

  @inlinable
  @inline(__always)
  internal func ___max() -> _Value? {
    __tree_.__root == __tree_.nullptr ? nil : __tree_[__tree_.__tree_max(__tree_.__root)]
  }
}

extension ___UnsafeBaseSequenceV2 {

  @inlinable
  @inline(__always)
  internal func ___lower_bound(_ __k: _Key) -> _NodePtr {
    __tree_.lower_bound(__k)
  }

  @inlinable
  @inline(__always)
  internal func ___upper_bound(_ __k: _Key) -> _NodePtr {
    __tree_.upper_bound(__k)
  }

  @inlinable
  @inline(__always)
  internal func ___index_lower_bound(_ __k: _Key) -> Index {
    ___index(___lower_bound(__k))
  }

  @inlinable
  @inline(__always)
  internal func ___index_upper_bound(_ __k: _Key) -> Index {
    ___index(___upper_bound(__k))
  }
}

extension ___UnsafeBaseSequenceV2 {

  @inlinable
  @inline(__always)
  internal func ___first_index(of member: _Key) -> Index? {
    let ptr = __tree_.__ptr_(__tree_.__find_equal(member).__child)
    return ___index_or_nil(ptr)
  }
}

@usableFromInline
protocol ___UnsafeSubSequenceV2: ___UnsafeBaseV2 {}

extension ___UnsafeSubSequenceV2 {

  @inlinable
  @inline(__always)
  internal var _count: Int {
    __tree_.___distance(from: _start, to: _end)
  }
  
  @inlinable
  @inline(__always)
  internal func ___contains(_ i: _NodePtr) -> Bool {
    !__tree_.___is_subscript_null(i) && __tree_.___ptr_closed_range_contains(_start, _end, i)
  }

  @inlinable
  @inline(__always)
  internal func ___contains(_ bounds: Range<Index>) -> Bool {
    !__tree_.___is_offset_null(bounds.lowerBound.rawValue(__tree_))
      && !__tree_.___is_offset_null(bounds.upperBound.rawValue(__tree_))
      && __tree_.___ptr_range_contains(_start, _end, bounds.lowerBound.rawValue(__tree_))
      && __tree_.___ptr_range_contains(_start, _end, bounds.upperBound.rawValue(__tree_))
  }
}

public struct UnsafeNode {

  public typealias Pointer = UnsafeMutablePointer<UnsafeNode>


  @inlinable
  @inline(__always)
  public init(
    ___node_id_: Int,
    __left_: Pointer,
    __right_: Pointer,
    __parent_: Pointer,
    __is_black_: Bool = false,
    ___needs_deinitialize: Bool = true
  ) {
    self.___node_id_ = ___node_id_
    self.__left_ = __left_
    self.__right_ = __right_
    self.__parent_ = __parent_
    self.__is_black_ = __is_black_
    self.___needs_deinitialize = ___needs_deinitialize
  }

  public var __left_: Pointer

  public var __right_: Pointer

  public var __parent_: Pointer
  public var __is_black_: Bool = false
  public var ___needs_deinitialize: Bool
  public var ___node_id_: Int

  #if DEBUG
    public var ___recycle_count: Int = 0
  #endif

  @usableFromInline
  nonisolated(unsafe) static let null: UnsafeNode.Null = .init()

  @usableFromInline
  nonisolated(unsafe) static let nullptr: UnsafeMutablePointer<UnsafeNode> = null.nullptr
}

extension UnsafeNode {

  @usableFromInline
  final class Null {
    fileprivate let nullptr: UnsafeMutablePointer<UnsafeNode>
    fileprivate init() {
      nullptr = UnsafeMutablePointer<UnsafeNode>.allocate(capacity: 1)
      nullptr.initialize(
        to:
          .init(
            ___node_id_: .nullptr,
            __left_: nullptr,
            __right_: nullptr,
            __parent_: nullptr))
    }
    deinit {
      nullptr.deinitialize(count: 1)
      nullptr.deallocate()
    }
  }
}

extension Optional where Wrapped == UnsafeMutablePointer<UnsafeNode> {
  
  @inlinable
  var pointerIndex: Int {
    switch self {
    case .none:
      return .nullptr
    case .some(let wrapped):
      return wrapped.pointee.___node_id_
    }
  }
}

extension UnsafeMutablePointer where Pointee == UnsafeNode {
  
  @inlinable
  var pointerIndex: Int {
    pointee.___node_id_
  }
  
  @inlinable
  @inline(__always)
  func create(id: Int) -> UnsafeNode {
    .init(___node_id_: id,
          __left_: self,
          __right_: self,
          __parent_: self)
  }
}

extension UnsafeNode {

  @inlinable
  @inline(__always)
  static func valuePointer<_Value>(_ pointer: UnsafeMutablePointer<Self>?) -> UnsafeMutablePointer<
    _Value
  >? {
    guard let pointer else { return nil }
    return UnsafeMutableRawPointer(pointer.advanced(by: 1))
      .assumingMemoryBound(to: _Value.self)
  }

  @inlinable
  @inline(__always)
  static func valuePointer<_Value>(_ pointer: UnsafeMutablePointer<Self>) -> UnsafeMutablePointer<
    _Value
  > {
    UnsafeMutableRawPointer(pointer.advanced(by: 1))
      .assumingMemoryBound(to: _Value.self)
  }

  @inlinable
  @inline(__always)
  static func value<_Value>(_ pointer: UnsafeMutablePointer<Self>) -> _Value {
    UnsafeMutableRawPointer(pointer.advanced(by: 1))
      .assumingMemoryBound(to: _Value.self)
      .pointee
  }
}

extension UnsafeNode {

  @inlinable
  @inline(__always)
  static func initializeValue<_Value>(_ p: UnsafeMutablePointer<UnsafeNode>, to: _Value) {
    p.pointee.___needs_deinitialize = true
    
    
    UnsafeMutableRawPointer(p.advanced(by: 1))
      .bindMemory(to: _Value.self, capacity: 1)
      .initialize(to: to)

  }

  @inlinable
  @inline(__always)
  static func deinitialize<_Value>(_ t: _Value.Type, _ p: UnsafeMutablePointer<UnsafeNode>) {
    if p.pointee.___needs_deinitialize {
      UnsafeMutableRawPointer(p.advanced(by: 1))
        .assumingMemoryBound(to: _Value.self)
        .deinitialize(count: 1)
    }
    p.deinitialize(count: 1)
  }
}

extension UnsafeNode {

  #if DEBUG
    @inlinable
    func debugDescription(resolve: (Pointer?) -> Int?) -> String {
      let id = ___node_id_
      let l = resolve(__left_)
      let r = resolve(__right_)
      let p = resolve(__parent_)
      let color = __is_black_ ? "B" : "R"
      #if DEBUG
        let rc = ___recycle_count
      #else
        let rc = -1
      #endif

      return """
        - node[\(id)] \(color)
          L: \(l.map(String.init) ?? "nil")
          R: \(r.map(String.init) ?? "nil")
          P: \(p.map(String.init) ?? "nil")
          needsDeinit: \(___needs_deinitialize)
          recycleCount: \(rc)
        """
    }
  #endif
}

@frozen
@usableFromInline
package struct UnsafeNodeFreshBucket {

  public typealias Header = UnsafeNodeFreshBucket
  public typealias HeaderPointer = UnsafeMutablePointer<Header>
  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

  @inlinable
  @inline(__always)
  internal init(
    start: _NodePtr,
    capacity: Int,
    strice: Int,
    alignment: Int
  ) {
    self.start = start
    self.capacity = capacity
    self.stride = strice
    self.alignment = alignment
  }

  public var count: Int = 0
  public let capacity: Int
  public let start: _NodePtr
  public let stride: Int
  public let alignment: Int
  public var next: HeaderPointer? = nil

  @inlinable
  @inline(__always)
  func advance(_ p: _NodePtr, offset n: Int = 1) -> _NodePtr {
    UnsafeMutableRawPointer(p)
      .advanced(by: stride * n)
      .assumingMemoryBound(to: UnsafeNode.self)
  }

  @inlinable
  @inline(__always)
  subscript(index: Int) -> _NodePtr {
    advance(start, offset: index)
  }

  @inlinable
  @inline(__always)
  mutating func pop() -> _NodePtr? {
    guard count < capacity else { return nil }
    let p = advance(start, offset: count)
    count += 1
    return p
  }

  @inlinable
  @inline(__always)
  func _clear<T>(_ t: T.Type) {
    var i = 0
    let count = count
    var p = start
    while i < count {
      let c = p
      p = advance(p)
      if c.pointee.___needs_deinitialize {
        UnsafeMutableRawPointer(
          UnsafeMutablePointer<UnsafeNode>(c)
            .advanced(by: 1)
        )
        .assumingMemoryBound(to: t.self)
        .deinitialize(count: 1)
      }
      c.deinitialize(count: 1)
      i += 1
    }
    #if DEBUG
      do {
        var c = 0
        var p = start
        while c < capacity {
          p.pointee.___node_id_ = .debug
          p = advance(p)
          c += 1
        }
      }
    #endif
  }

  @inlinable
  @inline(__always)
  mutating func clear<T>(_ t: T.Type) {
    _clear(t.self)
    count = 0
  }
}

#if DEBUG
  extension UnsafeNodeFreshBucket {

    func dump(label: String = "") {
      print("---- FreshBucket \(label) ----")
      print(" capacity:", capacity)
      print(" count:", count)

      var i = 0
      var p = start
      while i < capacity {
        let isUsed = i < count
        let marker =
          (count == i) ? "<- current" : isUsed ? "[used]" : "[free]"

        print(
          String(
            format: " [%02lld] ptr=%p id=%lld %@",
            i,
            p,
            p.pointee.___node_id_,
            marker
          )
        )

        p = advance(p)
        i += 1
      }
      print("-----------------------------")
    }
  }
#endif

@usableFromInline
struct UnsafeNodeFreshBucketIterator<_Value>: IteratorProtocol, Sequence {

  @usableFromInline
  typealias Bucket = UnsafeNodeFreshBucket

  @usableFromInline
  typealias BucketPointer = UnsafeMutablePointer<Bucket>

  @inlinable
  @inline(__always)
  internal init(bucket: BucketPointer?) {
    self.bucket = bucket
  }

  @usableFromInline
  var bucket: BucketPointer?

  @inlinable
  @inline(__always)
  mutating func next() -> BucketPointer? {
    defer { bucket = bucket?.pointee.next }
    return bucket
  }
}

@usableFromInline
protocol UnsafeNodeFreshPool where _NodePtr == UnsafeMutablePointer<UnsafeNode> {
  
  /*
   Design invariant:
   - FreshPool may consist of multiple buckets in general.
   - Immediately after CoW, the pool must be constrained to a single bucket
   because index-based access is performed.
   */
  
  associatedtype _Value
  associatedtype _NodePtr
  var freshBucketHead: ReserverHeaderPointer? { get set }
  var freshBucketCurrent: ReserverHeaderPointer? { get set }
  var freshBucketLast: ReserverHeaderPointer? { get set }
  var freshPoolCapacity: Int { get set }
  var freshPoolUsedCount: Int { get set }
  var count: Int { get set }
  var nullptr: _NodePtr { get }
#if DEBUG
  var freshBucketCount: Int { get set }
#endif
}

extension UnsafeNodeFreshPool {
  public typealias ReserverHeader = UnsafeNodeFreshBucket
  public typealias ReserverHeaderPointer = UnsafeMutablePointer<ReserverHeader>
}

//#if USE_FRESH_POOL_V1
#if !USE_FRESH_POOL_V2
extension UnsafeNodeFreshPool {

  /*
   NOTE:
   Normally, FreshPool may grow by adding multiple buckets.
   However, immediately after CoW, callers MUST ensure that
   only a single bucket exists to support index-based access.
   */
  @usableFromInline
  mutating func pushFreshBucket(capacity: Int) {
    assert(capacity != 0)
    let (pointer, capacity) = Self.createBucket(capacity: capacity)
    if freshBucketHead == nil {
      freshBucketHead = pointer
    }
    if freshBucketCurrent == nil {
      freshBucketCurrent = pointer
    }
    if let freshBucketLast {
      freshBucketLast.pointee.next = pointer
    }
    freshBucketLast = pointer
    self.freshPoolCapacity += capacity
#if DEBUG
    freshBucketCount += 1
#endif
  }

  @inlinable
  @inline(__always)
  mutating func popFresh() -> _NodePtr? {
    if let p = freshBucketCurrent?.pointee.pop() {
      return p
    }
    nextBucket()
    return freshBucketCurrent?.pointee.pop()
  }

  @inlinable
  @inline(__always)
  mutating func nextBucket() {
    freshBucketCurrent = freshBucketCurrent?.pointee.next
  }

  @inlinable
  @inline(__always)
  mutating func ___cleanFreshPool() {
    var reserverHead = freshBucketHead
    while let h = reserverHead {
      h.pointee.clear(_Value.self)
      reserverHead = h.pointee.next
    }
    freshPoolUsedCount = 0
    count = 0
  }

  @inlinable
  @inline(__always)
  mutating func ___flushFreshPool() {
    ___deinitFreshPool()
  }
  
  @inlinable
  @inline(__always)
  mutating func ___deinitFreshPool() {
    var reserverHead = freshBucketHead
    while let h = reserverHead {
      reserverHead = h.pointee.next
      Self.deinitializeNodes(h)
      h.deinitialize(count: 1)
      h.deallocate()
    }
    freshBucketHead = nil
    freshBucketCurrent = nil
    freshBucketLast = nil
#if DEBUG
    freshBucketCount = 0
#endif
    freshPoolCapacity = 0
    freshPoolUsedCount = 0
  }
}

extension UnsafeNodeFreshPool {

  @inlinable
  @inline(__always)
  func makeFreshPoolIterator() -> UnsafeNodeFreshPoolIterator<_Value> {
    return UnsafeNodeFreshPoolIterator<_Value>(bucket: freshBucketHead)
  }
}

extension UnsafeNodeFreshPool {

  @inlinable
  @inline(__always)
  func makeFreshBucketIterator() -> UnsafeNodeFreshBucketIterator<_Value> {
    return UnsafeNodeFreshBucketIterator<_Value>(bucket: freshBucketHead)
  }
}

extension UnsafeNodeFreshPool {

  /*
   IMPORTANT:
   After a Copy-on-Write operation, node access is performed via index-based
   lookup. To guarantee O(1) address resolution and avoid bucket traversal,
   the FreshPool must contain exactly ONE bucket at this point.
  
   Invariant:
     - During and immediately after CoW, `reserverBucketCount == 1`
     - Index-based access relies on a single contiguous bucket
  
   Violating this invariant may cause excessive traversal or undefined behavior.
  */
  @inlinable
  @inline(__always)
  subscript(___node_id_: Int) -> _NodePtr {
    assert(___node_id_ >= 0)
    var remaining = ___node_id_
    var p = freshBucketHead
    while let h = p {
      let cap = h.pointee.capacity
      if remaining < cap {
        return h.pointee[remaining]
      }
      remaining -= cap
      p = h.pointee.next
    }
    return nullptr
  }
}


extension UnsafeNodeFreshPool {

  @inlinable
  @inline(__always)
  mutating public
    func ___popFresh() -> _NodePtr
  {
    guard let p = popFresh() else {
      return nullptr
    }
    assert(p.pointee.___node_id_ == .nullptr)
    p.initialize(to: nullptr.create(id: freshPoolUsedCount))
    freshPoolUsedCount += 1
    count += 1
    return p
  }
}

extension UnsafeNodeFreshPool {

  @inlinable
  @inline(__always)
  var freshPoolActualCount: Int {
    var count = 0
    var p = freshBucketHead
    while let h = p {
      count += h.pointee.count
      p = h.pointee.next
    }
    return count
  }
  
  @inlinable
  @inline(__always)
  var freshPoolNumBytes: Int {
    var bytes = 0
    var p = freshBucketHead
    while let h = p {
      bytes += h.pointee.count * (MemoryLayout<UnsafeNode>.stride + MemoryLayout<_Value>.stride)
      p = h.pointee.next
    }
    return bytes
  }
}

extension UnsafeNodeFreshPool {
  
  @inlinable
  @inline(__always)
  static func deinitializeNodes(_ p: ReserverHeaderPointer) {
    let bucket = p.pointee
    var i = 0
    let count = bucket.count
    var p = bucket.start
    while i < count {
      let c = p
      p = UnsafePair<_Value>.advance(p)
      if c.pointee.___needs_deinitialize {
        UnsafeNode.deinitialize(_Value.self, c)
      }
      c.deinitialize(count: 1)
      i += 1
    }
#if DEBUG
    do {
      var c = 0
      var p = bucket.start
      while c < bucket.capacity {
        p.pointee.___node_id_ = .nullptr
        p = UnsafePair<_Value>.advance(p)
        c += 1
      }
    }
#endif
  }
  
  @inlinable
  @inline(__always)
  static func createBucket(capacity: Int) -> (ReserverHeaderPointer, capacity: Int) {
    
    assert(capacity != 0)
    
    let (capacity, bytes, stride, alignment) = pagedCapacity(capacity: capacity)
    
    let header_storage = UnsafeMutableRawPointer.allocate(
      byteCount: bytes,
      alignment: alignment)
    
    let header = UnsafeMutableRawPointer(header_storage)
      .assumingMemoryBound(to: UnsafeNodeFreshBucket.self)
    
    let storage = UnsafeMutableRawPointer(header.advanced(by: 1))
    
    header.initialize(
      to:
          .init(
            start: UnsafePair<_Value>.pointer(from: storage),
            capacity: capacity,
            strice: stride,
            alignment: alignment))
    
#if DEBUG
    do {
      var c = 0
      var p = header.pointee.start
      while c < capacity {
        p.pointee.___node_id_ = .nullptr
        p = UnsafePair<_Value>.advance(p)
        c += 1
      }
    }
#endif
    
    return (header, capacity)
  }
}

extension UnsafeNodeFreshPool {
  
  @inlinable
  @inline(__always)
  static func pagedCapacity(capacity: Int) -> (capacity: Int, bytes: Int, stride: Int, alignment: Int) {
    
    let s0 = MemoryLayout<UnsafeNode>.stride
    let a0 = MemoryLayout<UnsafeNode>.alignment
    let s1 = MemoryLayout<_Value>.stride
    let a1 = MemoryLayout<_Value>.alignment
    let s2 = MemoryLayout<UnsafeNodeFreshBucket>.stride
    let s01 = s0 + s1
    let offset01 = max(0, a1 - a0)
    let size = s2 + (capacity == 0 ? 0 : s01 * capacity + offset01)
    let alignment = max(a0,a1)
    
    /*
     512B未満はスルーに
     中間は要研究
     4KB以上は分割確保に
     */
    
#if false
    if size <= 1024 {
      return (capacity, size, s01, alignment)
    }
#endif
    
#if false
    let pagedSize = (size + 4095) & ~4095
    let lz = Int.bitWidth - s01.leadingZeroBitCount
    let mask = 1 << (lz - 1) - 1
    let offset = (s01 & mask == 0) ? -1 : 0
    let extra = (pagedSize - size) >> (lz + offset)
    
    assert(abs(size / 4096 - pagedSize / 4096) <= 1)
    return (
      capacity + extra,
      pagedSize,
      s01,
      alignment)
#elseif false
    let pagedSize = (size + 4095) & ~4095
    assert(abs(size / 4096 - pagedSize / 4096) <= 1)
    return (
      capacity + (pagedSize - size) / (s01),
      pagedSize,
      s01,
      alignment)
#else
    return (capacity, size, s01, alignment)
#endif
  }
}


extension UnsafeNodeFreshPool {

  @inlinable
  @inline(__always)
  static func allocationSize(capacity: Int) -> (size: Int, alignment: Int) {
    let (bufferSize, bufferAlignment) = UnsafePair<_Value>.allocationSize(capacity: capacity)
    return (bufferSize + MemoryLayout<ReserverHeader>.stride, bufferAlignment)
  }

  @inlinable
  @inline(__always)
  static func allocationSize() -> (size: Int, alignment: Int) {
    return (
      MemoryLayout<ReserverHeader>.stride,
      MemoryLayout<ReserverHeader>.alignment
    )
  }
}

extension UnsafeNodeFreshPool {
  
  @inlinable
  @inline(__always)
  static func _allocationSize2(capacity: Int) -> (size: Int, alignment: Int) {
    let a0 = MemoryLayout<UnsafeNode>.alignment
    let a1 = MemoryLayout<_Value>.alignment
    let s0 = MemoryLayout<UnsafeNode>.stride
    let s1 = MemoryLayout<_Value>.stride
    let s01 = s0 + s1
    let offset01 = max(0, a1 - a0)
    return (capacity == 0 ? 0 : s01 * capacity + offset01, max(a0, a1))
  }
  
  @inlinable
  @inline(__always)
  static func allocationSize2(capacity: Int) -> (size: Int, alignment: Int) {
    let s0 = MemoryLayout<UnsafeNode>.stride
    let a0 = MemoryLayout<UnsafeNode>.alignment
    let s1 = MemoryLayout<_Value>.stride
    let a1 = MemoryLayout<_Value>.alignment
    let s2 = MemoryLayout<UnsafeNodeFreshBucket>.stride
    let a2 = MemoryLayout<UnsafeNodeFreshBucket>.alignment
    let s01 = s0 + s1
    let offset01 = max(0, a1 - a0)
    return (s2 + (capacity == 0 ? 0 : s01 * capacity + offset01), max(a0, a1))
  }
}


#if DEBUG
  extension UnsafeNodeFreshPool {

    func dumpFreshPool(label: String = "") {
      print("==== FreshPool \(label) ====")
      print(" bucketCount:", freshBucketCount)
      print(" capacity:", freshPoolCapacity)
      print(" usedCount:", freshPoolActualCount)

      var i = 0
      var p = freshBucketHead
      while let h = p {
        h.pointee.dump(label: "bucket[\(i)]")
        p = h.pointee.next
        i += 1
      }
      print("===========================")
    }
  }
#endif
#endif

@usableFromInline
struct UnsafeNodeFreshPoolIterator<_Value>: IteratorProtocol, Sequence {

  @usableFromInline
  typealias Bucket = UnsafeNodeFreshBucket

  @usableFromInline
  typealias BucketPointer = UnsafeMutablePointer<Bucket>

  @usableFromInline
  typealias ElementPointer = UnsafeMutablePointer<UnsafeNode>

  @inlinable
  @inline(__always)
  internal init(bucket: BucketPointer?) {
    self.bucket = bucket
  }

  @usableFromInline
  var bucket: BucketPointer?

  @usableFromInline
  var nodeOffset: Int = 0

  @inlinable
  @inline(__always)
  mutating func next() -> ElementPointer? {

    while let bucket, nodeOffset == bucket.pointee.count {
      self.bucket = bucket.pointee.next
      nodeOffset = 0
    }

    guard let h = bucket else {
      return nil
    }

    defer { nodeOffset += 1 }

    return UnsafePair<_Value>.advance(h.pointee.start, nodeOffset)
  }
}

/*
 V2は、ベンチではV1には速度が今一歩及ばない。
 及ばない理由はアロケーションが多いから。
 そのアロケーションで新規ノード作成がO(1)になり挿入時やCoW時の安定性が増す。
 このため、どちらか決めずにしばらく併存でいく。
 */

@usableFromInline
protocol UnsafeNodeFreshPoolV2 where _NodePtr == UnsafeMutablePointer<UnsafeNode> {

  associatedtype _Value
  associatedtype _NodePtr
  var freshPool: FreshPool<_Value> { get set }
  var count: Int { get set }
  var nullptr: _NodePtr { get }
}

extension UnsafeNodeFreshPoolV2 {
  
  @inlinable
  var freshPoolCapacity: Int {
    @inline(__always)
    get { freshPool.capacity }
    set { fatalError() }
  }

  @inlinable
  var freshPoolUsedCount: Int {
    @inline(__always)
    get { freshPool.used }
    set {
      #if DEBUG
        freshPool.used = newValue
      #endif
    }
  }

  @usableFromInline
  var freshPoolActualCount: Int {
    freshPool.used
  }

  #if DEBUG
    @usableFromInline
    var freshBucketCount: Int { -1 }
  #endif

  @inlinable
  @inline(__always)
  subscript(___node_id_: Int) -> _NodePtr {
    return freshPool[___node_id_]
  }

  @inlinable
  @inline(__always)
  mutating func pushFreshBucket(capacity: Int) {
    assert(capacity > 0)
    freshPool.reserveCapacity(minimumCapacity: freshPool.capacity + capacity)
  }

  @inlinable
  @inline(__always)
  mutating func popFresh() -> _NodePtr? {
    freshPool._popFresh(nullptr: nullptr)
  }

  @inlinable
  @inline(__always)
  mutating func ___popFresh() -> _NodePtr {
    let p = freshPool._popFresh(nullptr: nullptr)
    count += 1
    return p
  }

  @inlinable
  @inline(__always)
  mutating func ___deinitFreshPool() {
    freshPool.dispose()
  }

  @inlinable
  @inline(__always)
  mutating func ___cleanFreshPool() {
    freshPool.clear()
  }
}

extension UnsafeNodeFreshPoolV2 {

  @inlinable
  @inline(__always)
  func makeFreshPoolIterator() -> UnsafeNodeFreshPoolV2Iterator<_Value> {
    freshPool.makeFreshPoolIterator()
  }
}

@frozen
@usableFromInline
struct FreshStorage {

  @inlinable
  @inline(__always)
  internal init(pointer: UnsafeMutablePointer<FreshStorage>?) {
    self.pointer = pointer
  }

  @usableFromInline let pointer: UnsafeMutablePointer<FreshStorage>?
}

@frozen
@usableFromInline
struct FreshPool<_Value> {

  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

  @usableFromInline
  internal init(
    storage: UnsafeMutablePointer<FreshStorage>? = nil,
    array: UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>? = nil
  ) {
    self.storage = storage
    self.pointers = array
  }

  @usableFromInline var used: Int = 0
  @usableFromInline var capacity: Int = 0
  @usableFromInline var pointers: UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>?
  @usableFromInline var pointerCount: Int = 0
  @usableFromInline var storage: UnsafeMutablePointer<FreshStorage>?
}

extension FreshPool {

  @inlinable
  @inline(__always)
  mutating func reserveCapacity(minimumCapacity newCapacity: Int) {
    assert(capacity < newCapacity)
    assert(used <= capacity)
    assert(used < newCapacity)
    guard capacity < newCapacity else { return }
    let oldCapacity = capacity
    let size = newCapacity - oldCapacity
    _resizePointersIfNeeds(minimumCapacity: newCapacity)
    var p = _pushStorage(size: size)
    var i = oldCapacity
    while i < newCapacity {
      (pointers! + i).initialize(to: p)
      p = UnsafeMutableRawPointer(p)
        .advanced(by: MemoryLayout<UnsafeNode>.stride + MemoryLayout<_Value>.stride)
        .assumingMemoryBound(to: UnsafeNode.self)
      i += 1
    }
    assert(used < capacity)
  }

  @inlinable
  func growthPointerCount(minimumCount: Int) -> Int {
    let base = 16
    if pointerCount == 0, minimumCount > base {
      return minimumCount
    }
    return max(base, minimumCount * 5 / 4)
  }

  @inlinable
  @inline(__always)
  mutating func _resizePointersIfNeeds(minimumCapacity newCapacity: Int) {
    let newRank = growthPointerCount(minimumCount: newCapacity)
    guard pointerCount != newRank || pointers == nil else { return }
    let newArray = UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>
      .allocate(capacity: newRank)
    if let pointers {
      newArray.moveInitialize(from: pointers, count: capacity)
      pointers.deallocate()
    }
    pointers = newArray
    pointerCount = newRank
  }

  @inlinable
  @inline(__always)
  mutating func _pushStorage(size: Int) -> UnsafeMutablePointer<UnsafeNode> {
    assert(used <= capacity)
    let (newStorage, buffer, size) = _createBucket(capacity: size)
    storage = newStorage
    capacity += size
    assert(used < capacity)
    return UnsafePair<_Value>.pointer(from: buffer)
  }

  @inlinable
  @inline(__always)
  func _allocationSize(capacity: Int) -> (size: Int, alignment: Int) {
    let s0 = MemoryLayout<UnsafeNode>.stride
    let a0 = MemoryLayout<UnsafeNode>.alignment
    let s1 = MemoryLayout<_Value>.stride
    let a1 = MemoryLayout<_Value>.alignment
    let s2 = MemoryLayout<FreshStorage>.stride
    let s01 = s0 + s1
    let offset01 = max(0, a1 - a0)
    return (s2 + (capacity == 0 ? 0 : s01 * capacity + offset01), max(a0, a1))
  }

  @inlinable
  @inline(__always)
  func _createBucket(capacity: Int) -> (
    head: UnsafeMutablePointer<FreshStorage>,
    first: UnsafeMutableRawPointer,
    capacity: Int
  ) {

    assert(capacity != 0)

    let (bytes, alignment) = _allocationSize(capacity: capacity)

    let header_storage = UnsafeMutableRawPointer.allocate(
      byteCount: bytes,
      alignment: alignment)

    header_storage.bindMemory(to: FreshStorage.self, capacity: 1)

    let header = UnsafeMutableRawPointer(header_storage)
      .assumingMemoryBound(to: FreshStorage.self)

    let elements = UnsafeMutableRawPointer(header.advanced(by: 1))

    header.initialize(to: .init(pointer: self.storage))

    #if DEBUG
      do {
        var c = 0
        var p = elements
        while c < capacity {

          p.assumingMemoryBound(to: UnsafeNode.self)
            .pointee
            .___node_id_ = .nullptr

          p = UnsafeMutableRawPointer(
            UnsafePair<_Value>
              .advance(p.assumingMemoryBound(to: UnsafeNode.self)))

          c += 1
        }
      }
    #endif

    return (header, elements, capacity)
  }

  @inlinable
  @inline(__always)
  var _buffer: UnsafeMutableBufferPointer<UnsafeMutablePointer<UnsafeNode>> {
    guard let pointers else { fatalError() }
    return UnsafeMutableBufferPointer(
      start: UnsafeMutableRawPointer(pointers)
        .assumingMemoryBound(to: UnsafeMutablePointer<UnsafeNode>.self),
      count: capacity
    )
  }

  @inlinable
  @inline(__always)
  subscript(___node_id_: Int) -> UnsafeMutablePointer<UnsafeNode> {
    assert(0 <= ___node_id_)
    assert(___node_id_ < capacity)
    return pointers!.advanced(by: ___node_id_).pointee
  }

  @inlinable
  @inline(__always)
  mutating func _popFresh(nullptr: _NodePtr) -> _NodePtr {
    let p = self[used]
    assert(p.pointee.___node_id_ == .debug)
    p.initialize(to: nullptr.create(id: used))
    used += 1
    return p
  }

  @usableFromInline
  mutating func clear() {
    for i in 0..<used {
      let c = self[i]
      if c.pointee.___needs_deinitialize {
        UnsafeNode.deinitialize(_Value.self, c)
      }
    }
    used = 0
  }

  @inlinable
  @inline(__always)
  mutating func dispose() {
    if let pointers {
      var i = 0
      let used = used
      while i < used {
        let c = (pointers + i).pointee
#if true
        UnsafeNode.deinitialize(_Value.self, c)
#else
        if c.pointee.___needs_deinitialize {
          UnsafeMutableRawPointer(
            UnsafeMutablePointer<UnsafeNode>(c)
              .advanced(by: 1)
          )
          .assumingMemoryBound(to: _Value.self)
          .deinitialize(count: 1)
        }
#endif
        c.deinitialize(count: 1)
        i += 1
      }
      pointers.deinitialize(count: capacity)
      pointers.deallocate()
    }
    while let storage {
      self.storage = storage.pointee.pointer
      storage.deinitialize(count: 1)
      storage.deallocate()
    }
  }
}

extension FreshPool {

  @inlinable
  @inline(__always)
  func makeFreshPoolIterator() -> UnsafeNodeFreshPoolV2Iterator<_Value> {
    return UnsafeNodeFreshPoolV2Iterator<_Value>(
      elements: pointers, count: used)
  }
}

@usableFromInline
struct UnsafeNodeFreshPoolV2Iterator<_Value>: IteratorProtocol, Sequence {

  @usableFromInline
  typealias ElementPointer = UnsafeMutablePointer<UnsafeNode>

  @inlinable
  @inline(__always)
  internal init(elements it: UnsafeMutablePointer<ElementPointer>?, count: Int) {
    self.it = it
    self.end = it.map { $0 + count }
  }

  @usableFromInline
  var it, end: UnsafeMutablePointer<ElementPointer>?

  @inlinable
  @inline(__always)
  mutating func next() -> ElementPointer? {
    guard it != end, let it else { return nil }
    let p = it
    self.it = it + 1
    return p.pointee
  }
}

@usableFromInline
protocol UnsafeNodeRecyclePool
where _NodePtr == UnsafeMutablePointer<UnsafeNode> {
  associatedtype _Value
  associatedtype _NodePtr
  var recycleHead: _NodePtr { get set }
  var count: Int { get set }
  var freshPoolUsedCount: Int { get set }
  var nullptr: _NodePtr { get }
}

extension UnsafeNodeRecyclePool {

  @inlinable
  @inline(__always)
  mutating func ___pushRecycle(_ p: _NodePtr) {
    assert(p.pointee.___node_id_ > .end)
    assert(recycleHead != p)
    #if DEBUG
      p.pointee.___recycle_count += 1
    #endif
    UnsafePair<_Value>.valuePointer(p)?.deinitialize(count: 1)
    p.pointee.___needs_deinitialize = false
    p.pointee.__left_ = recycleHead
    #if GRAPHVIZ_DEBUG
      p!.pointee.__right_ = nil
      p!.pointee.__parent_ = nil
    #endif
    recycleHead = p
    count -= 1
  }

  @inlinable
  @inline(__always)
  mutating func ___popRecycle() -> _NodePtr {
    let p = recycleHead
    recycleHead = p.pointee.__left_
    count += 1
    p.pointee.___needs_deinitialize = true
    return p
  }

  @inlinable
  @inline(__always)
  mutating func ___flushRecyclePool() {
    recycleHead = nullptr
    count = 0
  }

  #if DEBUG
    @inlinable
    @inline(__always)
    var recycleCount: Int {
      freshPoolUsedCount - count
    }
  #endif
}

extension UnsafeNodeRecyclePool {
  #if DEBUG
    @inlinable
    @inline(__always)
    internal var ___recycleNodes: [Int] {
      var nodes: [Int] = []
      var last = recycleHead
      while last != nullptr {
        nodes.append(last.pointee.___node_id_)
        last = last.pointee.__left_
      }
      return nodes
    }
  #endif
}

public enum UnsafePair<_Value> {

  public typealias Pointer = UnsafePointer<UnsafeNode>
  public typealias MutablePointer = UnsafeMutablePointer<UnsafeNode>
  
  @inlinable
  @inline(__always)
  static var stride: Int {
    MemoryLayout<UnsafeNode>.stride + MemoryLayout<_Value>.stride
  }

  @inlinable
  @inline(__always)
  static func _allocationSize() -> (size: Int, alignment: Int) {
    let numBytes = MemoryLayout<UnsafeNode>.stride + MemoryLayout<_Value>.stride

    let nodeAlignment = MemoryLayout<UnsafeNode>.alignment
    let valueAlignment = MemoryLayout<_Value>.alignment

    if valueAlignment <= nodeAlignment {
      return (numBytes, MemoryLayout<UnsafeNode>.alignment)
    }

    return (
      numBytes + valueAlignment - nodeAlignment,
      MemoryLayout<_Value>.alignment
    )
  }

  @inlinable
  @inline(__always)
  package static func allocationSize(capacity: Int) -> (size: Int, alignment: Int) {
    let numBytes = MemoryLayout<UnsafeNode>.stride + MemoryLayout<_Value>.stride

    let nodeAlignment = MemoryLayout<UnsafeNode>.alignment
    let valueAlignment = MemoryLayout<_Value>.alignment
    
    if capacity == 0 {
      return (0, max(nodeAlignment, valueAlignment))
    }

    if valueAlignment <= nodeAlignment {
      return (numBytes * capacity, MemoryLayout<UnsafeNode>.alignment)
    }

    return (
      numBytes * capacity + valueAlignment - nodeAlignment,
      MemoryLayout<_Value>.alignment
    )
  }

  @inlinable
  @inline(__always)
  static func pointer(from storage: UnsafeMutableRawPointer) -> MutablePointer {
    let headerAlignment = MemoryLayout<UnsafeNode>.alignment
    let elementAlignment = MemoryLayout<_Value>.alignment

    if elementAlignment <= headerAlignment {
      return storage.assumingMemoryBound(to: UnsafeNode.self)
    }

    return storage.advanced(by: MemoryLayout<UnsafeNode>.stride)
      .alignedUp(for: _Value.self)
      .advanced(by: -MemoryLayout<UnsafeNode>.stride)
      .assumingMemoryBound(to: UnsafeNode.self)
  }

  @inlinable
  @inline(__always)
  static func advance(_ p: MutablePointer, _ n: Int = 1) -> MutablePointer {
    UnsafeMutableRawPointer(p)
      .advanced(by: (MemoryLayout<UnsafeNode>.stride + MemoryLayout<_Value>.stride) * n)
      .assumingMemoryBound(to: UnsafeNode.self)
  }
  
  @inlinable
  @inline(__always)
  static func advance(_ p: UnsafeMutableRawPointer, _ n: Int = 1) -> MutablePointer {
    p
      .advanced(by: (MemoryLayout<UnsafeNode>.stride + MemoryLayout<_Value>.stride) * n)
      .assumingMemoryBound(to: UnsafeNode.self)
  }

  @inlinable
  @inline(__always)
  static func valuePointer(_ p: MutablePointer?) -> UnsafeMutablePointer<_Value>? {
    guard let p else { return nil }
    return valuePointer(p)
  }

  @inlinable
  @inline(__always)
  static func valuePointer(_ p: MutablePointer) -> UnsafeMutablePointer<_Value> {
    UnsafeMutableRawPointer(p.advanced(by: 1))
      .assumingMemoryBound(to: _Value.self)
  }
}

public struct UnsafeTreeV2Origin {
  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
  @usableFromInline let nullptr: _NodePtr
  @usableFromInline var begin_ptr: _NodePtr
  @usableFromInline let end_ptr: _NodePtr
  @usableFromInline var end_node: UnsafeNode
  @inlinable
  init(base: UnsafeMutablePointer<UnsafeTreeV2Origin>, nullptr: _NodePtr) {
    self.nullptr = nullptr
    end_node = nullptr.create(id: .end)
    let e = withUnsafeMutablePointer(to: &base.pointee.end_node) { $0 }
    end_ptr = e
    begin_ptr = e
  }
  @inlinable
  mutating func clear() {
    begin_ptr = end_ptr
    end_node.__left_ = nullptr
    end_node.__right_ = nullptr
    end_node.__parent_ = nullptr
  }
}

public struct UnsafeTreeV2<Base: ___TreeBase> {

  @inlinable
  internal init(
    _buffer: ManagedBufferPointer<Header, UnsafeTreeV2Origin>,
    isReadOnly: Bool = false
  ) {
    self._buffer = _buffer
    self.isReadOnly = isReadOnly
    self.end = _buffer.withUnsafeMutablePointerToElements { $0[0].end_ptr }
  }

  public typealias Base = Base
  public typealias Tree = UnsafeTreeV2<Base>
  public typealias Header = UnsafeTreeV2Buffer<Base._Value>.Header
  public typealias Buffer = ManagedBuffer<Header, UnsafeTreeV2Origin>
  public typealias BufferPointer = ManagedBufferPointer<Header, UnsafeTreeV2Origin>
  public typealias _Key = Base._Key
  public typealias _Value = Base._Value
  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
  public typealias _NodeRef = UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>

  @usableFromInline
  var _buffer: BufferPointer

  public let end: _NodePtr

  @usableFromInline
  let isReadOnly: Bool
}

extension UnsafeTreeV2 {

  @inlinable
  public var count: Int { _buffer.header.count }

  #if !DEBUG
    @inlinable
    public var capacity: Int { _buffer.header.freshPoolCapacity }

    @inlinable
    public var initializedCount: Int { _buffer.header.freshPoolUsedCount }
  #else
    @inlinable
    public var capacity: Int {
      get { _buffer.header.freshPoolCapacity }
      set {
        _buffer.withUnsafeMutablePointerToHeader {
          $0.pointee.freshPoolCapacity = newValue
        }
      }
    }

    @inlinable
    public var initializedCount: Int {
      get { _buffer.header.freshPoolUsedCount }
      set {
        _buffer.withUnsafeMutablePointerToHeader {
          $0.pointee.freshPoolUsedCount = newValue
        }
      }
    }
  #endif
}


extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal static func create(
    minimumCapacity nodeCapacity: Int
  ) -> UnsafeTreeV2 {
    nodeCapacity == 0
      ? ___create()
      : ___create(minimumCapacity: nodeCapacity, nullptr: UnsafeNode.nullptr)
  }

  @inlinable
  @inline(__always)
  internal static func ___create() -> UnsafeTreeV2 {
    assert(_emptyTreeStorage.header.freshPoolCapacity == 0)
    return UnsafeTreeV2(
      _buffer:
        BufferPointer(
          unsafeBufferObject: _emptyTreeStorage),
      isReadOnly: true)
  }

  @inlinable
  @inline(__always)
  internal static func ___create(
    minimumCapacity nodeCapacity: Int,
    nullptr: _NodePtr
  ) -> UnsafeTreeV2 {
    create(
      unsafeBufferObject:
        UnsafeTreeV2Buffer<Base._Value>
        .create(
          minimumCapacity: nodeCapacity,
          nullptr: nullptr))
  }

  @inlinable
  @inline(__always)
  internal static func create(unsafeBufferObject buffer: AnyObject)
    -> UnsafeTreeV2
  {
    return UnsafeTreeV2(
      _buffer:
        BufferPointer(
          unsafeBufferObject: buffer))
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal func copy(minimumCapacity: Int? = nil) -> UnsafeTreeV2 {
    assert(check())
    let newCapacity = max(minimumCapacity ?? 0, initializedCount)
    let tree = UnsafeTreeV2.___create(minimumCapacity: newCapacity, nullptr: nullptr)
    #if DEBUG
      assert(tree._buffer.header.freshBucketCount <= 1)
    #endif

    _buffer.withUnsafeMutablePointers { source_header, source_end in

      let source_begin = withUnsafeMutablePointer(to: &source_end.pointee.begin_ptr) { $0 }
      let source_end = source_end.pointee.end_ptr

      tree._buffer.withUnsafeMutablePointers { _header_ptr, _end_ptr in

        let _begin_ptr = withUnsafeMutablePointer(to: &_end_ptr.pointee.begin_ptr) { $0 }
        let _end_ptr = _end_ptr.pointee.end_ptr

        @inline(__always)
        func __ptr_(_ ptr: _NodePtr) -> _NodePtr {
          let index = ptr.pointee.___node_id_
          return switch index {
          case .nullptr:
            nullptr
          case .end:
            _end_ptr
          default:
            _header_ptr.pointee[index]
          }
        }

        @inline(__always)
        func node(_ s: UnsafeNode) -> UnsafeNode {
          return .init(
            ___node_id_: s.___node_id_,
            __left_: __ptr_(s.__left_),
            __right_: __ptr_(s.__right_),
            __parent_: __ptr_(s.__parent_),
            __is_black_: s.__is_black_,
            ___needs_deinitialize: s.___needs_deinitialize)
        }

        var source_nodes = source_header.pointee.makeFreshPoolIterator()

        while let s = source_nodes.next(), let d = _header_ptr.pointee.popFresh() {
          d.initialize(to: node(s.pointee))
          if s.pointee.___needs_deinitialize {
            UnsafeNode.initializeValue(d, to: UnsafeNode.value(s) as _Value)
          }
        }

        _end_ptr.pointee.__left_ = __ptr_(source_end.pointee.__left_)

        _begin_ptr.pointee = __ptr_(source_begin.pointee)

        //#if USE_FRESH_POOL_V1
        #if !USE_FRESH_POOL_V2
          _header_ptr.pointee.freshPoolUsedCount = source_header.pointee.freshPoolUsedCount
        #endif
        _header_ptr.pointee.count = source_header.pointee.count
        _header_ptr.pointee.recycleHead = __ptr_(source_header.pointee.recycleHead)

        #if AC_COLLECTIONS_INTERNAL_CHECKS
          _header_ptr.pointee.copyCount = source_header.pointee.copyCount &+ 1
        #endif
      }
    }

    assert(equiv(with: tree))
    assert(tree.check())

    return tree
  }
}

extension UnsafeTreeV2 {

  @nonobjc
  @inlinable
  internal subscript(_ pointer: _NodePtr) -> _Value {
    @inline(__always) _read {
      assert(___initialized_contains(pointer))
      yield UnsafeNode.valuePointer(pointer).pointee
    }
    @inline(__always) _modify {
      assert(___initialized_contains(pointer))
      yield &UnsafeNode.valuePointer(pointer).pointee
    }
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  public func ensureCapacity(_ newCapacity: Int) {
    guard capacity < newCapacity else { return }
    _buffer.withUnsafeMutablePointerToHeader {
      $0.pointee.pushFreshBucket(capacity: newCapacity - capacity)
    }
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  func clear() {
    end.pointee.__left_ = nullptr
    _buffer.withUnsafeMutablePointerToHeader {
      $0.pointee.clear(_end_ptr: __end_node)
    }
    _buffer.withUnsafeMutablePointerToElements {
      $0.pointee.clear()
    }
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal func __eraseAll() {
    clear()
    _buffer.withUnsafeMutablePointerToHeader {
      $0.pointee.___flushRecyclePool()
      $0.pointee.count = 0
    }
  }
}


extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal func ___is_garbaged(_ p: _NodePtr) -> Bool {
    p.pointee.___needs_deinitialize != true
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal var ___is_empty: Bool {
    count == 0
  }
}


//#if USE_FRESH_POOL_V1
#if !USE_FRESH_POOL_V2
  extension UnsafeTreeV2 {

    @inlinable
    @inline(__always)
    func makeFreshPoolIterator() -> UnsafeNodeFreshPoolIterator<_Value> {
      return _buffer.header.makeFreshPoolIterator()
    }
  }

  extension UnsafeTreeV2 {

    @inlinable
    @inline(__always)
    func makeFreshBucketIterator() -> UnsafeNodeFreshBucketIterator<_Value> {
      return UnsafeNodeFreshBucketIterator<_Value>(bucket: _buffer.header.freshBucketHead)
    }
  }
#else
  extension UnsafeTreeV2 {

    @inlinable
    @inline(__always)
    func makeFreshPoolIterator() -> UnsafeNodeFreshPoolV2Iterator<_Value> {
      return _buffer.header.makeFreshPoolIterator()
    }
  }
#endif


extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal func ___node_ptr(_ index: Index) -> _NodePtr
  where Index.Tree == UnsafeTreeV2, Index._NodePtr == _NodePtr {
    #if true
      @inline(__always)
      func ___NodePtr(_ p: Int) -> _NodePtr {
        switch p {
        case .nullptr:
          return nullptr
        case .end:
          return end
        default:
          return _buffer.header[p]
        }
      }
      return self.isIdentical(to: index.__tree_) ? index.rawValue : ___NodePtr(index.___node_id_)
    #else
      self === index.__tree_ ? index.rawValue : (_header[index.___node_id_])
    #endif
  }
}

extension UnsafeTreeV2 {

  #if AC_COLLECTIONS_INTERNAL_CHECKS
    @usableFromInline
    internal var copyCount: UInt {
      get { _buffer.header.copyCount }
      set {
        _buffer.withUnsafeMutablePointerToHeader {
          $0.pointee.copyCount = newValue
        }
      }
    }
  #endif
}


extension UnsafeTreeV2 {

  #if DEBUG
    @inlinable
    func _nodeID(_ p: _NodePtr) -> Int? {
      return p.pointee.___node_id_
    }
  #endif
}

extension UnsafeTreeV2 {

  #if DEBUG
    func dumpTree(label: String = "") {
      print("==== UnsafeTree \(label) ====")
      print(" count:", count)
      print(" freshPool:", _buffer.header.freshPoolActualCount, "/", capacity)
      print(" destroyCount:", _buffer.header.recycleCount)
      print(" root:", __root.pointee.___node_id_ as Any)
      print(" begin:", __begin_node_.pointee.___node_id_ as Any)

      var it = makeFreshPoolIterator()
      while let p = it.next() {
        print(
          p.pointee.debugDescription { self._nodeID($0!) }
        )
      }
      print("============================")
    }
  #endif
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  public var nullptr: UnsafeMutablePointer<UnsafeNode> {
    _buffer.withUnsafeMutablePointerToElements { $0.pointee.nullptr }
  }

}


extension UnsafeTreeV2: TreeEndNodeProtocol {

  @inlinable
  @inline(__always)
  func __left_(_ p: _NodePtr) -> _NodePtr {
    return p.pointee.__left_
  }

  @inlinable
  @inline(__always)
  func __left_unsafe(_ p: _NodePtr) -> _NodePtr {
    return p.pointee.__left_
  }

  @inlinable
  @inline(__always)
  func __left_(_ lhs: _NodePtr, _ rhs: _NodePtr) {
    assert(rhs != nil)
    lhs.pointee.__left_ = rhs
  }
}


extension UnsafeTreeV2: TreeNodeProtocol {

  @inlinable
  @inline(__always)
  func __right_(_ p: _NodePtr) -> _NodePtr {
    return p.pointee.__right_
  }

  @inlinable
  @inline(__always)
  func __right_(_ lhs: _NodePtr, _ rhs: _NodePtr) {
    assert(rhs != nil)
    lhs.pointee.__right_ = rhs
  }

  @inlinable
  @inline(__always)
  func __is_black_(_ p: _NodePtr) -> Bool {
    return p.pointee.__is_black_
  }

  @inlinable
  @inline(__always)
  func __is_black_(_ lhs: _NodePtr, _ rhs: Bool) {
    lhs.pointee.__is_black_ = rhs
  }

  @inlinable
  @inline(__always)
  func __parent_(_ p: _NodePtr) -> _NodePtr {
    return p.pointee.__parent_
  }

  @inlinable
  @inline(__always)
  func __parent_(_ lhs: _NodePtr, _ rhs: _NodePtr) {
    assert(rhs != nil)
    lhs.pointee.__parent_ = rhs
  }

  @inlinable
  @inline(__always)
  func __parent_unsafe(_ p: _NodePtr) -> _NodePtr {
    return p.pointee.__parent_
  }
}


extension UnsafeTreeV2: TreeNodeRefProtocol {

  @inlinable
  @inline(__always)
  func __left_ref(_ p: _NodePtr) -> _NodeRef {
    return withUnsafeMutablePointer(to: &p.pointee.__left_) { $0 }
  }

  @inlinable
  @inline(__always)
  func __right_ref(_ p: _NodePtr) -> _NodeRef {
    return withUnsafeMutablePointer(to: &p.pointee.__right_) { $0 }
  }

  @inlinable
  @inline(__always)
  public func __ptr_(_ rhs: _NodeRef) -> _NodePtr {
    rhs.pointee
  }

  @inlinable
  @inline(__always)
  func __ptr_(_ lhs: _NodeRef, _ rhs: _NodePtr) {
    lhs.pointee = rhs
  }
}


extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  func __get_value(_ p: _NodePtr) -> _Key {
    Base.__key(UnsafePair<_Value>.valuePointer(p)!.pointee)
  }
}


extension UnsafeTreeV2 {

  @inlinable
  public var __begin_node_: _NodePtr {

    @inline(__always) get {
      _buffer.withUnsafeMutablePointerToElements { $0.pointee.begin_ptr }
    }

    @inline(__always)
    nonmutating set {
      _buffer.withUnsafeMutablePointerToElements { $0.pointee.begin_ptr = newValue }
    }
  }
}


extension UnsafeTreeV2 {

  @inlinable
  var __end_node: _NodePtr {
    end
  }
}


extension UnsafeTreeV2 {

  #if !DEBUG
    @nonobjc
    @inlinable
    @inline(__always)
    internal var __root: _NodePtr {
      _buffer.withUnsafeMutablePointerToElements { $0.pointee.end_node.__left_ }
    }
  #else
    @inlinable
    @inline(__always)
    internal var __root: _NodePtr {
      get { end.pointee.__left_ }
      set { end.pointee.__left_ = newValue }
    }
  #endif


  @inlinable
  @inline(__always)
  internal func __root_ptr() -> _NodeRef {
    _buffer.withUnsafeMutablePointerToElements {
      withUnsafeMutablePointer(to: &$0.pointee.end_node.__left_) { $0 }
    }
  }
}


extension UnsafeTreeV2 {

  @inlinable
  var __size_: Int {
    @inline(__always) get {
      _buffer.withUnsafeMutablePointerToHeader { $0.pointee.count }
    }
    nonmutating set {
      /* NOP */
    }
  }
}


extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  public func __construct_node(_ k: _Value) -> _NodePtr {
    _buffer.withUnsafeMutablePointerToHeader { header in
      header.pointee.__construct_node(k)
    }
  }

  @inlinable
  @inline(__always)
  internal func destroy(_ p: _NodePtr) {
    _buffer.withUnsafeMutablePointerToHeader {
      $0.pointee.___pushRecycle(p)
    }
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal func __value_(_ p: _NodePtr) -> _Value {
    UnsafePair<Tree._Value>.valuePointer(p)!.pointee
  }

  @inlinable
  @inline(__always)
  internal func ___element(_ p: _NodePtr, _ __v: _Value) {
    UnsafePair<Tree._Value>.valuePointer(p)!.pointee = __v
  }
}

extension UnsafeTreeV2: ValueComparator {}
extension UnsafeTreeV2: BoundProtocol {

  @inlinable
  @inline(__always)
  public static var isMulti: Bool {
    Base.isMulti
  }

  @inlinable
  @inline(__always)
  var isMulti: Bool {
    Base.isMulti
  }
}

extension UnsafeTreeV2: FindProtocol {}
extension UnsafeTreeV2: FindEqualProtocol {}
extension UnsafeTreeV2: FindLeafProtocol {}
extension UnsafeTreeV2: InsertNodeAtProtocol {}
extension UnsafeTreeV2: InsertUniqueProtocol {}
extension UnsafeTreeV2: InsertMultiProtocol {}
extension UnsafeTreeV2: EqualProtocol {}
extension UnsafeTreeV2: RemoveProtocol {}
extension UnsafeTreeV2: EraseProtocol {}
extension UnsafeTreeV2: EraseUniqueProtocol {}
extension UnsafeTreeV2: EraseMultiProtocol {}
extension UnsafeTreeV2: CompareBothProtocol {}
extension UnsafeTreeV2: CountProtocol {}
extension UnsafeTreeV2: InsertLastProtocol {}
extension UnsafeTreeV2: CompareProtocol {}

@usableFromInline
protocol UnsafeTreeAllocationHeader {
#if DEBUG
  var freshBucketCount: Int { get }
#endif
}

@usableFromInline
protocol UnsafeTreeAllcationBodyV2 {
  associatedtype Header: UnsafeTreeAllocationHeader
  associatedtype _Value
  var _buffer: ManagedBufferPointer<Header, UnsafeTreeV2Origin> { get }
  var capacity: Int { get }
  var count: Int { get }
  var initializedCount: Int { get }
}

extension UnsafeTreeV2: UnsafeTreeAllcationBodyV2 {}
extension UnsafeTreeV2Buffer.Header: UnsafeTreeAllocationHeader {}


#if ALLOCATION_DRILL
  extension UnsafeTreeV2 {
    @inlinable
    @inline(__always)
    internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {
      fatalError()
    }
  }
  extension RedBlackTreeSet {
    @inlinable
    public static func allocationDrill() -> RedBlackTreeSet {
      .init(__tree_: .___create(minimumCapacity: 0))
    }
  }
#else
extension UnsafeTreeV2: UnsafeTreeAllcation6_9 {}
#endif

#if ALLOCATION_DRILL
  extension RedBlackTreeSet {
    public mutating func pushFreshBucket(capacity: Int) {
      __tree_._buffer.header.pushFreshBucket(capacity: capacity)
    }
  }
#endif

@usableFromInline
protocol UnsafeTreeAllcation7: UnsafeTreeAllcationBodyV2 {
  var capacity: Int { get }
}

extension UnsafeTreeAllcation7 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        capacity,
        minimumCapacity)
    }
    
    if minimumCapacity <= 2 {
      return Swift.max(minimumCapacity, 2)
    }
    
    if minimumCapacity <= 4 {
      return Swift.max(minimumCapacity, 4)
    }
    
    let limit1024 = (1024 - MemoryLayout<UnsafeNodeFreshBucket>.stride) / (MemoryLayout<UnsafeNode>.stride + MemoryLayout<_Value>.stride)
    
    if minimumCapacity <= limit1024 {
       return Swift.max(minimumCapacity, Swift.min(capacity + Swift.max(2, capacity / 8), limit1024))
    }
    
    let limit32k = (1024 * 32 - 4096) / (MemoryLayout<UnsafeNode>.stride + MemoryLayout<_Value>.stride)

    if minimumCapacity <= limit32k {
      return Swift.max(minimumCapacity, Swift.min(capacity + capacity / 8, limit32k))
    }

    let limit512k = (1024 * 512 - 4096) / (MemoryLayout<UnsafeNode>.stride + MemoryLayout<_Value>.stride)

    if minimumCapacity <= limit512k {
      return Swift.max(minimumCapacity, Swift.min(capacity + capacity / 8, limit512k))
    }
    
    return Swift.max(minimumCapacity, capacity + max(capacity / 8, 1))
  }
}

@usableFromInline
protocol UnsafeTreeAllcation6_10 {
  var capacity: Int { get }
}

extension UnsafeTreeAllcation6_10 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        capacity,
        minimumCapacity)
    }

    return Swift.max(minimumCapacity, capacity + max(capacity * 3 / 16, 2))
  }
}

@usableFromInline
protocol UnsafeTreeAllcation6_9 {
  var capacity: Int { get }
}

extension UnsafeTreeAllcation6_9 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        capacity,
        minimumCapacity)
    }

    return Swift.max(minimumCapacity, capacity + max(capacity / 4, 2))
  }
}

@usableFromInline
protocol UnsafeTreeAllcation6_8 {
  var capacity: Int { get }
}

extension UnsafeTreeAllcation6_8 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        capacity,
        minimumCapacity)
    }

    return Swift.max(minimumCapacity, capacity + max(capacity / 16, 2))
  }
}

@usableFromInline
protocol UnsafeTreeAllcation6_7 {
  var capacity: Int { get }
}

extension UnsafeTreeAllcation6_7 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        capacity,
        minimumCapacity)
    }

    return Swift.max(minimumCapacity, capacity + max(capacity / 8, 2))
  }
}

@usableFromInline
protocol UnsafeTreeAllcation6_6 {
  var capacity: Int { get }
}

extension UnsafeTreeAllcation6_6 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        capacity,
        minimumCapacity)
    }

    return Swift.max(minimumCapacity, capacity + max(capacity * 4, 2))
  }
}

@usableFromInline
protocol UnsafeTreeAllcation6_5 {
  var capacity: Int { get }
}

extension UnsafeTreeAllcation6_5 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        capacity,
        minimumCapacity)
    }

    return Swift.max(minimumCapacity, capacity + max(capacity * 3, 2))
  }
}

@usableFromInline
protocol UnsafeTreeAllcation6_4 {
  var capacity: Int { get }
}

extension UnsafeTreeAllcation6_4 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        capacity,
        minimumCapacity)
    }

    return Swift.max(minimumCapacity, capacity + max(capacity * 2, 2))
  }
}

@usableFromInline
protocol UnsafeTreeAllcation6_3 {
  var capacity: Int { get }
}

extension UnsafeTreeAllcation6_3 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        capacity,
        minimumCapacity)
    }

    return Swift.max(minimumCapacity, capacity + max(capacity, 2))
  }
}

@usableFromInline
protocol UnsafeTreeAllcation6_2 {
  var capacity: Int { get }
}

extension UnsafeTreeAllcation6_2 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        capacity,
        minimumCapacity)
    }

    return Swift.max(minimumCapacity, capacity + max(capacity * 3 / 4, 2))
  }
}

@usableFromInline
protocol UnsafeTreeAllcation6 {
  var capacity: Int { get }
}

extension UnsafeTreeAllcation6 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        capacity,
        minimumCapacity)
    }

    return Swift.max(minimumCapacity, capacity + max(capacity / 2, 1))
  }
}

@usableFromInline
protocol UnsafeTreeAllcation5 {
  var capacity: Int { get }
}

extension UnsafeTreeAllcation5 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        capacity,
        minimumCapacity)
    }

    let recommendCapacity = 1 << (Int.bitWidth - capacity.leadingZeroBitCount)
    return Swift.max(minimumCapacity, recommendCapacity)
  }
}

@usableFromInline
protocol UnsafeTreeAllcation4 {
  var capacity: Int { get }
}

extension UnsafeTreeAllcation4 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        capacity,
        minimumCapacity)
    }

    if minimumCapacity <= 256 {
      let recommendCapacity = 1 << (Int.bitWidth - capacity.leadingZeroBitCount)
      return Swift.max(minimumCapacity, recommendCapacity)
    }


    let increaseCapacity =
      (1 << (Int.bitWidth - capacity.leadingZeroBitCount - 2))
      | (1 << (Int.bitWidth - capacity.leadingZeroBitCount - 3))
    let recommendCapacity = capacity + increaseCapacity
    return Swift.max(minimumCapacity, recommendCapacity)
  }
}

@usableFromInline
protocol UnsafeTreeAllcation3: UnsafeTreeAllcationBodyV2 {}

extension UnsafeTreeAllcation3 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        initializedCount,
        minimumCapacity)
    }

    if minimumCapacity <= 6 {
      return Swift.max(minimumCapacity, count + count)
    }

    if minimumCapacity <= 8192 {
      return Swift.max(minimumCapacity, count + Swift.min(count / 2, 14))
    }

    return Swift.max(minimumCapacity, count + Swift.min(count / 2, 510))
  }
}

@usableFromInline
protocol UnsafeTreeAllcation2: UnsafeTreeAllcationBodyV2 {}

extension UnsafeTreeAllcation2 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        initializedCount,
        minimumCapacity)
    }

    let s0 = MemoryLayout<UnsafeNode>.stride
    let s1 = MemoryLayout<_Value>.stride
    let s2 = MemoryLayout<UnsafeNodeFreshBucket>.stride
    let a2 = 0  // MemoryLayout<UnsafeNodeFreshBucket<_Value>>.alignment

    if minimumCapacity <= 2 {
      return 3
    }

    if minimumCapacity <= 64 {
      return Swift.max(minimumCapacity, count + ((16 - 1) * (s0 + s1) - s2 - a2) / (s0 + s1))
    }

    if minimumCapacity < 4096 {
      return Swift.max(minimumCapacity, count + ((32 - 1) * (s0 + s1) - s2 - a2) / (s0 + s1))
    }

    if minimumCapacity <= 8192 {
      return Swift.max(minimumCapacity, count + ((16 - 1) * (s0 + s1) - s2 - a2) / (s0 + s1))
    }

    if minimumCapacity <= 100000 {
      return Swift.max(minimumCapacity, count + ((512 - 1) * (s0 + s1) - s2 - a2) / (s0 + s1))
    }

    return Swift.max(minimumCapacity, count + ((1024 * 2 - 1) * (s0 + s1) - s2 - a2) / (s0 + s1))
  }
}


@usableFromInline
protocol UnsafeTreeAllcation1: UnsafeTreeAllcationBodyV2 {}

extension UnsafeTreeAllcation1 {

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        initializedCount,
        minimumCapacity)
    }

    if minimumCapacity <= 2 {
      return 3
    }

    let s0 = MemoryLayout<UnsafeNode>.stride
    let s1 = MemoryLayout<_Value>.stride
    let s2 = MemoryLayout<UnsafeNodeFreshBucket>.stride
    let a2 = MemoryLayout<UnsafeNodeFreshBucket>.alignment

    let (small, large) = initializedCount < 2048 ? (31, 31) : (15, 15)

#if DEBUG
    if _buffer.header.freshBucketCount & 1 == 1 {
      return Swift.max(minimumCapacity, count + (small * (s0 + s1) - s2 - a2) / (s0 + s1))
    }
#endif

    return Swift.max(minimumCapacity, count + (large * (s0 + s1) - s2 - a2) / (s0 + s1))
  }
}

@usableFromInline
protocol UnsafeTreeAllcation0: UnsafeTreeAllcationBodyV2 {}

extension UnsafeTreeAllcation0 {

  @inlinable
  @inline(__always)
  internal func bitCeil(_ n: Int) -> Int {
    n <= 1 ? 1 : 1 << (Int.bitWidth - (n - 1).leadingZeroBitCount)
  }

  @inlinable
  @inline(__always)
  internal func growthFormula(count: Int) -> Int {
    #if true
      let rawSize = bitCeil(MemoryLayout<UnsafeNode>.stride * count)
      return rawSize / MemoryLayout<UnsafeNode>.stride
    #else
      return Self.capacity(forScale: Self.scale(forCapacity: count))
    #endif
  }

  @inlinable
  @inline(__always)
  internal func growCapacity(to minimumCapacity: Int, linearly: Bool) -> Int {

    if linearly {
      return Swift.max(
        initializedCount,
        minimumCapacity)
    }

    if minimumCapacity <= 4 {
      return Swift.max(
        initializedCount,
        minimumCapacity
      )
    }

    if minimumCapacity <= 12 {
      return Swift.max(
        initializedCount,
        capacity + (minimumCapacity - capacity) * 2
      )
    }



    return Swift.max(
      initializedCount,
      growthFormula(count: minimumCapacity))
  }
}


#if UNSAFE_TREE_PROJECT
  extension FixedWidthInteger {

    @inlinable
    internal func _binaryLogarithm() -> Int {
      return Self.bitWidth &- (leadingZeroBitCount &+ 1)
    }
  }
#endif


extension UnsafeTreeAllcation0 {

  @inlinable
  internal static var maxLoadFactor: Double {
    return 3 / 4
  }

  @inlinable
  internal static func capacity(forScale scale: Int8) -> Int {
    let bucketCount = (1 as Int) &<< scale
    return Int(Double(bucketCount) * maxLoadFactor)
  }

  @inlinable
  internal static func scale(forCapacity capacity: Int) -> Int8 {
    let capacity = Swift.max(capacity, 1)
    let minimumEntries = Swift.max(
      Int((Double(capacity) / maxLoadFactor).rounded(.up)),
      capacity + 1)
    let exponent = (Swift.max(minimumEntries, 2) - 1)._binaryLogarithm() + 1
    let scale = Int8(truncatingIfNeeded: exponent)
    return scale
  }
}

import Foundation

@_fixed_layout
public final class UnsafeTreeV2Buffer<_Value>:
  ManagedBuffer<UnsafeTreeV2Buffer<_Value>.Header, UnsafeTreeV2Origin>
{
  @inlinable
  @inline(__always)
  deinit {
    withUnsafeMutablePointers { header, tree in
      header.pointee.___deinitFreshPool()
      tree.deinitialize(count: 1)
    }
  }
}


extension UnsafeTreeV2Buffer {

  @nonobjc
  @inlinable
  @inline(__always)
  internal static func create(
    minimumCapacity nodeCapacity: Int,
    nullptr: UnsafeMutablePointer<UnsafeNode>
  ) -> UnsafeTreeV2Buffer {


    let storage = UnsafeTreeV2Buffer.create(minimumCapacity: 1) { managedBuffer in
      return managedBuffer.withUnsafeMutablePointerToElements { tree in

        tree.initialize(to: UnsafeTreeV2Origin(base: tree, nullptr: nullptr))
        var header = Header(nullptr: nullptr)
        if nodeCapacity > 0 {
          header.pushFreshBucket(capacity: nodeCapacity)
          assert(header.freshPoolCapacity >= nodeCapacity)
        }
        assert(tree.pointee.end_ptr.pointee.___needs_deinitialize == true)
        return header
      }
    }

    assert(nodeCapacity <= storage.header.freshPoolCapacity)
    return unsafeDowncast(storage, to: UnsafeTreeV2Buffer.self)
  }
}


extension UnsafeTreeV2Buffer {

  @frozen
  public struct Header: UnsafeNodeRecyclePool {
    public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

    @inlinable
    @inline(__always)
    internal init(nullptr: _NodePtr) {
      self.nullptr = nullptr
      self.recycleHead = nullptr
    }

    //#if USE_FRESH_POOL_V1
    #if !USE_FRESH_POOL_V2
      @usableFromInline let nullptr: _NodePtr
      @usableFromInline var freshBucketCurrent: ReserverHeaderPointer?
      @usableFromInline var freshPoolCapacity: Int = 0
      @usableFromInline var freshPoolUsedCount: Int = 0
      @usableFromInline var recycleHead: _NodePtr
      @usableFromInline var freshBucketHead: ReserverHeaderPointer?
      @usableFromInline var freshBucketLast: ReserverHeaderPointer?
      @usableFromInline var count: Int = 0
      #if DEBUG
        @usableFromInline var freshBucketCount: Int = 0
      #endif
    #else
      @usableFromInline var recycleHead: _NodePtr
      @usableFromInline let nullptr: _NodePtr
      @usableFromInline var freshPool: FreshPool<_Value> = .init()
      @usableFromInline var count: Int = 0
    #endif

    #if AC_COLLECTIONS_INTERNAL_CHECKS
      @usableFromInline internal var copyCount: UInt = 0
    #endif

    @inlinable
    @inline(__always)
    internal mutating func clear(_end_ptr: _NodePtr) {
      ___cleanFreshPool()
      ___flushRecyclePool()
    }
  }
}

//#if USE_FRESH_POOL_V1
#if !USE_FRESH_POOL_V2
  extension UnsafeTreeV2Buffer.Header: UnsafeNodeFreshPool {}
#else
  extension UnsafeTreeV2Buffer.Header: UnsafeNodeFreshPoolV2 {}
#endif

extension UnsafeTreeV2Buffer.Header {

  @inlinable
  @inline(__always)
  public mutating func __construct_node(_ k: _Value) -> _NodePtr {
    assert(_Value.self != Void.self)
    #if DEBUG
      assert(recycleCount >= 0)
    #endif
    let p = recycleHead.pointerIndex == .nullptr ? ___popFresh() : ___popRecycle()
    UnsafeNode.initializeValue(p, to: k)
    assert(p.pointee.___node_id_ >= 0)
    return p
  }
}

extension UnsafeTreeV2Buffer: CustomStringConvertible {
  public var description: String {
    unsafe withUnsafeMutablePointerToHeader {
      "UnsafeTreeBuffer<\(_Value.self)>\(unsafe $0.pointee)"
    }
  }
}

@usableFromInline
nonisolated(unsafe) package let _emptyTreeStorage = UnsafeTreeV2Buffer<Void>.create(
  minimumCapacity: 0, nullptr: UnsafeNode.nullptr)


extension UnsafeTreeV2Buffer.Header {
  @inlinable
  mutating func tearDown() {
    //#if USE_FRESH_POOL_V1
    #if !USE_FRESH_POOL_V2
      ___flushFreshPool()
      count = 0
    #else
      freshPool.dispose()
      freshPool = .init()
      count = 0
    #endif
    ___flushRecyclePool()
  }
}

@inlinable
package func tearDown<T>(treeBuffer buffer: UnsafeTreeV2Buffer<T>) {
  buffer.withUnsafeMutablePointers { h, e in
    h.pointee.tearDown()
    e.pointee.clear()
  }
}

import Foundation

extension UnsafeTreeV2 {


  @inlinable
  @inline(__always)
  internal func copy() -> UnsafeTreeV2 {
    copy(minimumCapacity: capacity)
  }

  @inlinable
  @inline(__always)
  internal func copy(growthCapacityTo capacity: Int, linearly: Bool) -> UnsafeTreeV2 {
    copy(
      minimumCapacity:
        growCapacity(to: capacity, linearly: linearly))
  }

  @inlinable
  @inline(__always)
  internal func copy(growthCapacityTo capacity: Int, limit: Int, linearly: Bool) -> UnsafeTreeV2 {
    copy(
      minimumCapacity:
        Swift.min(
          growCapacity(to: capacity, linearly: linearly),
          limit))
  }
  
  @inlinable
  @inline(__always)
  internal func growthCapacity(to capacity: Int, linearly: Bool) {
    ensureCapacity(growCapacity(to: capacity, linearly: linearly))
  }

  @inlinable
  @inline(__always)
  internal func growthCapacity(to capacity: Int, limit: Int, linearly: Bool) {
    ensureCapacity(Swift.min(growCapacity(to: capacity, linearly: linearly), limit))
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal static func _isKnownUniquelyReferenced(tree: inout UnsafeTreeV2) -> Bool {
    #if !DISABLE_COPY_ON_WRITE
    !tree.isReadOnly && tree._buffer.isUniqueReference()
    #else
      true
    #endif
  }

  @inlinable
  @inline(__always)
  internal static func ensureUniqueAndCapacity(tree: inout UnsafeTreeV2) {
    ensureUniqueAndCapacity(tree: &tree, minimumCapacity: tree.count + 1)
  }

  @inlinable
  @inline(__always)
  internal static func ensureUniqueAndCapacity(tree: inout UnsafeTreeV2, minimumCapacity: Int) {
    let shouldExpand = tree.capacity < minimumCapacity
    if !_isKnownUniquelyReferenced(tree: &tree) {
      tree = tree.copy(growthCapacityTo: minimumCapacity, linearly: false)
    } else if shouldExpand {
      _ = tree.growCapacity(to: minimumCapacity, linearly: false)
    }
  }

  @inlinable
  @inline(__always)
  internal static func ensureCapacity(tree: inout UnsafeTreeV2) {
    ensureCapacity(tree: &tree, minimumCapacity: tree.count + 1)
  }

  @inlinable
  @inline(__always)
  internal static func ensureCapacity(tree: inout UnsafeTreeV2, minimumCapacity: Int) {
    if tree.capacity < minimumCapacity {
      tree.growthCapacity(to: minimumCapacity, linearly: false)
    }
  }
}

import Foundation

extension UnsafeTreeV2 where Base._Key == Base._Value {

  @inlinable
  internal static func
    create_unique(sorted elements: __owned [Base._Value]) -> UnsafeTreeV2
  where Base._Key: Comparable {

    let count = elements.count
    let tree: Tree = .create(minimumCapacity: count)
    var (__parent, __child) = tree.___max_ref()
    for __k in elements {
      if __parent == tree.end || __key(tree.__value_(__parent)) != __key(__k) {
        (__parent, __child) = tree.___emplace_hint_right(__parent, __child, __k)
      }
    }
    assert(tree.__tree_invariant(tree.__root))
    return tree
  }
}

extension UnsafeTreeV2 where Base: KeyValueComparer {

  @inlinable
  internal static func create_unique<Element>(
    sorted elements: __owned [Element],
    transform: (Element) -> Base._Value
  ) -> UnsafeTreeV2
  where Base._Key: Comparable {

    let count = elements.count
    let tree: Tree = .create(minimumCapacity: count)
    var (__parent, __child) = tree.___max_ref()
    for __k in elements {
      let __v = transform(__k)
      if __parent == tree.end || __key(tree.__value_(__parent)) != __key(__v) {
        (__parent, __child) = tree.___emplace_hint_right(__parent, __child, __v)
      } else {
        fatalError(.duplicateValue(for: Base.__key(__v)))
      }
    }
    assert(tree.__tree_invariant(tree.__root))
    return tree
  }

  @inlinable
  internal static func create_unique<Element>(
    sorted elements: __owned [Element],
    uniquingKeysWith combine: (Base._MappedValue, Base._MappedValue) throws -> Base._MappedValue,
    transform: (Element) -> Base._Value
  ) rethrows -> UnsafeTreeV2
  where Base._Key: Comparable {

    let count = elements.count
    let tree: Tree = .create(minimumCapacity: count)
    var (__parent, __child) = tree.___max_ref()
    for __k in elements {
      let __v = transform(__k)
      if __parent == tree.end || Base.__key(tree.__value_(__parent)) != Base.__key(__v) {
        (__parent, __child) = tree.___emplace_hint_right(__parent, __child, __v)
      } else {
        try tree.___with_mapped_value(__parent) { __mappedValue in
          __mappedValue = try combine(__mappedValue, Base.___mapped_value(__v))
        }
      }
    }
    assert(tree.__tree_invariant(tree.__root))
    return tree
  }
}

extension UnsafeTreeV2 where Base: KeyValueComparer & ___UnsafeKeyValueSequenceV2 {

  @inlinable
  internal static func create_unique<Element>(
    sorted elements: __owned [Element],
    by keyForValue: (Element) throws -> Base._Key
  ) rethrows -> UnsafeTreeV2
  where Base._Key: Comparable, Base._MappedValue == [Element] {

    let count = elements.count
    let tree: Tree = .create(minimumCapacity: count)
    var (__parent, __child) = tree.___max_ref()
    for __v in elements {
      let __k = try keyForValue(__v)
      if __parent == tree.end || Base.__key(tree.__value_(__parent)) != __k {
        (__parent, __child) = tree.___emplace_hint_right(
          __parent, __child, Base.___tree_value((__k, [__v])))
      } else {
        tree.___with_mapped_value(__parent) {
          $0.append(__v)
        }
      }
    }
    assert(tree.__tree_invariant(tree.__root))
    return tree
  }

  @inlinable
  internal static func create_multi<Element>(
    sorted elements: __owned [Element],
    by keyForValue: (Element) throws -> Base._Key
  ) rethrows -> UnsafeTreeV2
  where Base._Key: Comparable, Base._MappedValue == Element {

    let count = elements.count
    let tree: Tree = .create(minimumCapacity: count)
    var (__parent, __child) = tree.___max_ref()
    for __v in elements {
      let __k = try keyForValue(__v)
      (__parent, __child) = tree.___emplace_hint_right(
        __parent, __child, Base.___tree_value((__k, __v)))
    }
    assert(tree.__tree_invariant(tree.__root))
    return tree
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal static func
    create_multi(sorted elements: __owned [Base._Value]) -> UnsafeTreeV2
  where Base._Key: Comparable {

    create_multi(sorted: elements) { $0 }
  }

  @inlinable
  internal static func create_multi<Element>(
    sorted elements: __owned [Element],
    transform: (Element) -> Base._Value
  ) -> UnsafeTreeV2
  where Base._Key: Comparable {

    let count = elements.count
    let tree: Tree = .create(minimumCapacity: count)
    var (__parent, __child) = tree.___max_ref()
    for __k in elements {
      let __v = transform(__k)
      (__parent, __child) = tree.___emplace_hint_right(__parent, __child, __v)
    }
    assert(tree.__tree_invariant(tree.__root))
    return tree
  }
}

extension UnsafeTreeV2 {

  @inlinable
  internal static func create<R>(range: __owned R) -> UnsafeTreeV2
  where R: RangeExpression, R: Collection, R.Element == Base._Value {

    let tree: Tree = .create(minimumCapacity: range.count)
    var (__parent, __child) = tree.___max_ref()
    for __k in range {
      (__parent, __child) = tree.___emplace_hint_right(__parent, __child, __k)
    }
    assert(tree.__tree_invariant(tree.__root))
    return tree
  }
}

extension UnsafeTreeV2 {

  @inlinable
  internal static func create_unique<S>(naive sequence: __owned S) -> UnsafeTreeV2
  where Base._Value == S.Element, S: Sequence {

    .___insert_range_unique(tree: .create(minimumCapacity: 0), sequence)
  }

  @inlinable
  internal static func create_unique<S>(
    naive sequence: __owned S, transform: (S.Element) -> Base._Value
  ) -> UnsafeTreeV2
  where S: Sequence {

    .___insert_range_unique(tree: .create(minimumCapacity: 0), sequence, transform: transform)
  }

  @inlinable
  internal static func create_multi<S>(naive sequence: __owned S) -> UnsafeTreeV2
  where Base._Value == S.Element, S: Sequence {

    .___insert_range_multi(tree: .create(minimumCapacity: 0), sequence)
  }

  @inlinable
  internal static func create_multi<S>(
    naive sequence: __owned S, transform: (S.Element) -> Base._Value
  )
    -> UnsafeTreeV2
  where S: Sequence {

    .___insert_range_multi(tree: .create(minimumCapacity: 0), sequence, transform: transform)
  }
}


#if false
  extension UnsafeTreeV2 {


    @inlinable
    internal static func __create_unique<S>(sequence: __owned S) -> UnsafeTreeV2
    where Base._Value == S.Element, S: Sequence {

      let count = (sequence as? (any Collection))?.count
      var tree: Tree = .create(minimumCapacity: count ?? 0)
      for __v in sequence {
        if count == nil {
          Tree.ensureCapacity(tree: &tree)
        }
        let (__parent, __child) = tree.__find_equal(Base.__key(__v))
        if tree.__ptr_(__child) == .nullptr {
          let __h = tree.__construct_node(__v)
          tree.__insert_node_at(__parent, __child, __h)
        }
      }

      return tree
    }

    @inlinable
    internal static func __create_multi<S>(sequence: __owned S) -> UnsafeTreeV2
    where Base._Value == S.Element, S: Sequence {

      let count = (sequence as? (any Collection))?.count
      var tree: Tree = .create(minimumCapacity: count ?? 0)
      for __v in sequence {
        if count == nil {
          Tree.ensureCapacity(tree: &tree)
        }
        var __parent = _NodePtr.nullptr
        let __child = tree.__find_leaf_high(&__parent, Base.__key(__v))
        if tree.__ptr_(__child) == .nullptr {
          let __h = tree.__construct_node(__v)
          tree.__insert_node_at(__parent, __child, __h)
        }
      }

      return tree
    }
  }
#endif


extension UnsafeTreeV2 where _Value: Decodable {

  @inlinable
  internal static func create(from decoder: Decoder) throws -> UnsafeTreeV2 {

    var container = try decoder.unkeyedContainer()
    var tree: Tree = .create(minimumCapacity: 0)
    if let count = container.count {
      Tree.ensureCapacity(tree: &tree, minimumCapacity: count)
    }

    var (__parent, __child) = tree.___max_ref()
    while !container.isAtEnd {
      let __k = try container.decode(_Value.self)
      (__parent, __child) = tree.___emplace_hint_right(__parent, __child, __k)
    }

    assert(tree.__tree_invariant(tree.__root))
    return tree
  }
}

import Foundation


#if GRAPHVIZ_DEBUG
  extension UnsafeTreeV2 {

    public func ___graphviz() -> Graphviz.Digraph {
      buildGraphviz()
    }
  }

#if false
  extension ___RedBlackTreeBase {

    public func ___graphviz() -> Graphviz.Digraph {
      __tree_.___graphviz()
    }
  }
#endif

#endif

#if GRAPHVIZ_DEBUG
  public enum Graphviz {}

  extension Graphviz {

    public struct Digraph {
      var options: [Option] = []
      var nodes: [Node] = []
      var edges: [Edge] = []
    }

    typealias Node = ([NodeProperty], [String])

    enum Shape: String {
      case circle
      case note
    }

    enum Style: String {
      case filled
    }

    enum Color: String {
      case white
      case black
      case red
      case blue
      case lightYellow
    }

    enum LabelJust: String {
      case l
      case r
    }

    enum Port: String {
      case n
      case nw
      case w
      case sw
      case s
      case se
      case e
      case ne
      case none
    }

    enum Spline: String {
      case line
    }

    enum Option {
      case splines(Spline)
    }

    enum NodeProperty {
      case shape(Shape)
      case style(Style)
      case fillColor(Color)
      case fontColor(Color)
      case label(String)
      case labelJust(LabelJust)
    }

    struct Edge {
      var from: (String, Port)
      var to: (String, Port)
      var properties: [EdgeProperty]
    }

    enum EdgeProperty {
      case label(String)
      case labelAngle(Double)
    }
  }

  extension Array where Element == Graphviz.NodeProperty {
    static var red: [Graphviz.NodeProperty] {
      [.shape(.circle), .style(.filled), .fillColor(.red)]
    }
    static var black: Self {
      [.shape(.circle), .style(.filled), .fillColor(.black), .fontColor(.white)]
    }
    static var blue: Self {
      [.shape(.circle), .style(.filled), .fillColor(.blue), .fontColor(.white)]
    }
    var description: String {
      "[\(map(\.description).joined(separator: " "))]"
    }
  }

  extension Array where Element == Graphviz.EdgeProperty {
    static var left: [Graphviz.EdgeProperty] {
      [.label("left"),.labelAngle(45)]
    }
    static var right: [Graphviz.EdgeProperty] {
      [.label("right"),.labelAngle(-45)]
    }
  }

  extension Graphviz.NodeProperty {
    var description: String {
      switch self {
      case .shape(let shape):
        return "shape = \(shape.rawValue)"
      case .style(let style):
        return "style = \(style.rawValue)"
      case .fillColor(let color):
        return "fillcolor = \(color.rawValue)"
      case .fontColor(let color):
        return "fontcolor = \(color.rawValue)"
      case .label(let s):
        return "label = \"\(s)\""
      case .labelJust(let l):
        return "labeljust = \(l)"
      }
    }
  }

  extension Graphviz.EdgeProperty {
    var description: String {
      switch self {
      case .label(let label):
        return "label = \"\(label)\""
      case .labelAngle(let angle):
        return "labelangle = \(angle)"
      }
    }
  }

  extension Graphviz.Option {
    var description: String {
      switch self {
      case .splines(let s):
        return "splines = \(s)"
      }
    }
  }

  extension Graphviz.Edge {

    func node(_ p: (String, Graphviz.Port)) -> String {
      if p.1 == .none {
        return p.0
      }
      return "\(p.0):\(p.1)"
    }

    var description: String {
      "\(node(from)) -> \(node(to)) [\(properties.map(\.description).joined(separator: " "))]"
    }
  }

  extension Graphviz.Digraph: CustomStringConvertible {
    public var description: String {
      func description(_ properties: [Graphviz.NodeProperty], _ nodes: [String]) -> String {
        "node \(properties.description); \(nodes.joined(separator: " "))"
      }
      return
        """
        digraph {
        \(options.map(\.description).joined(separator: ";\n"))
        \(nodes.map(description).joined(separator: "\n"))
        \(edges.map(\.description).joined(separator: "\n"))
        }
        """
    }
  }

  extension UnsafeTree {

    func buildGraphviz() -> Graphviz.Digraph {
      func isRed(_ i: _NodePtr) -> Bool {
        !__is_black_(i)
      }
      func isBlack(_ i: _NodePtr) -> Bool {
        __is_black_(i)
      }
      func hasLeft(_ i: _NodePtr) -> Bool {
        __left_(i) != nullptr
      }
      func hasRight(_ i: _NodePtr) -> Bool {
        __right_(i) != nullptr
      }
      func offset(_ i: _NodePtr) -> Int? {
        switch i {
        case end:
          return nil
        case nullptr:
          return nil
        default:
          return i?.pointee.index
        }
      }
      func leftPair(_ i: _NodePtr) -> (_NodePtr, Int) {
        (i, offset(__left_(i)) ?? .end)
      }
      func rightPair(_ i: _NodePtr) -> (_NodePtr, Int) {
        (i, offset(__right_(i)) ?? .end)
      }
      func node(_ i: _NodePtr) -> String {
        switch i {
        case end:
          return "end"
        default:
          return "\(i?.pointee.index ?? .nullptr)"
        }
      }
      func nodeN(_ i: _NodePtr) -> String {
        switch i {
        case nullptr:
          return "-"
        case end:
          return "end"
        default:
          return "#\(i?.pointee.index ?? .nullptr)"
        }
      }
      func nodeV(_ i: _NodePtr) -> String {
        if i == end {
          return "end"
        } else {
          let c = String("\(i!.pointee.__value_)".flatMap { $0 == "\n" ? ["\n", "n"] : [$0] })
          let l: String = "\(c)\\n\\n#\(i?.pointee.index ?? .nullptr)"
          return "\(i?.pointee.index ?? .nullptr) [label = \"\(l)\"];"
        }
      }
      func headerNote() -> [Graphviz.NodeProperty] {
        var ll: [String] = []
        ll.append(contentsOf: [
          "[Header]",
          "capacity: \(capacity)",
          "__left_: \(nodeN(__left_))",
          "__begin_node: \(nodeN(__begin_node_))",
          "initializedCount: \(initializedCount)",
          "destroyCount: \(destroyCount)",
          "destroyNode: \(nodeN(destroyNode))",
          "[etc]",
          "__tree_invariant: \(__tree_invariant(__root()))",
        ])
        #if AC_COLLECTIONS_INTERNAL_CHECKS
          ll.append("- copyCount: \(_header.copyCount)")
        #endif

        let l = ll.joined(separator: "\\n")
        return [
          .shape(.note),
          .label(l),
          .labelJust(.l),
          .style(.filled),
          .fillColor(.lightYellow),
          .fontColor(.black),
        ]
      }
      let reds = (0..<initializedCount).filter(isRed).map(nodeV)
      let blacks = (0..<initializedCount).filter(isBlack).map(nodeV)
      let lefts: [(Int, Int)] = (0..<initializedCount).filter(hasLeft).map(leftPair)
      let rights: [(Int, Int)] = (0..<initializedCount).filter(hasRight).map(rightPair)
      var digraph = Graphviz.Digraph()
      digraph.options.append(.splines(.line))
      digraph.nodes.append((.red, reds))
      digraph.nodes.append((.blue, ["begin", "stack", "end"]))
      digraph.nodes.append((.black, blacks))
      digraph.nodes.append((headerNote(), ["header"]))
      if __root() != nullptr {
        digraph.edges.append(
          .init(from: (node(end), .sw), to: (node(__root()), .n), properties: .left))
      }
      if __begin_node_ != nullptr {
        digraph.edges.append(
          .init(from: ("begin", .s), to: (node(__begin_node_), .n), properties: .left))
      }
      if destroyNode != nullptr {
        digraph.edges.append(
          .init(from: ("stack", .s), to: (node(destroyNode), .n), properties: .left))
      }
      digraph.edges.append(
        contentsOf: lefts.map {
          .init(from: (node($0), .sw), to: (node($1), .n), properties: .left)
        })
      digraph.edges.append(
        contentsOf: rights.map {
          .init(from: (node($0), .se), to: (node($1), .n), properties: .right)
        })
      return digraph
    }
  }
#endif

extension UnsafeTreeV2: Hashable where _Value: Hashable {

  @inlinable
  public func hash(into hasher: inout Hasher) {
    for __v in unsafeValues(__begin_node_, end) {
      hasher.combine(__v)
    }
  }
}

extension UnsafeTreeV2 where Base: ___TreeIndex {

  public typealias Index = UnsafeIndexV2<Base>
  public typealias Pointee = Base.Pointee

  @inlinable
  @inline(__always)
  internal func makeIndex(rawValue: _NodePtr) -> Index {
    .init(tree: self, rawValue: rawValue)
  }
}

extension UnsafeTreeV2 where Base: ___TreeIndex {

  public typealias Indices = UnsafeIndicesV2<Base>
}

extension UnsafeTreeV2 where Base: ___TreeIndex {

  public typealias _Values = RedBlackTreeIteratorV2<Base>.Values
}

extension UnsafeTreeV2 where Base: KeyValueComparer & ___TreeIndex {

  public typealias _KeyValues = RedBlackTreeIteratorV2<Base>.KeyValues
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal func
    ___distance(from start: _NodePtr, to end: _NodePtr) -> Int
  {
    guard
      !___is_offset_null(start),
      !___is_offset_null(end)
    else {
      fatalError(.invalidIndex)
    }
    return ___signed_distance(start, end)
  }

  @inlinable
  @inline(__always)
  internal func ___index(after i: _NodePtr) -> _NodePtr {
    ___ensureValid(after: i)
    return __tree_next(i)
  }

  @inlinable
  @inline(__always)
  internal func ___formIndex(after i: inout _NodePtr) {
    i = ___index(after: i)
  }

  @inlinable
  @inline(__always)
  internal func ___index(before i: _NodePtr) -> _NodePtr {
    ___ensureValid(before: i)
    return __tree_prev_iter(i)
  }

  @inlinable
  @inline(__always)
  internal func ___formIndex(before i: inout _NodePtr) {
    i = ___index(before: i)
  }

  @inlinable
  @inline(__always)
  internal func ___index(_ i: _NodePtr, offsetBy distance: Int) -> _NodePtr {
    ___ensureValid(offset: i)
    var distance = distance
    var i = i
    while distance != 0 {
      if 0 < distance {
        guard i != __end_node else {
          fatalError(.outOfBounds)
        }
        i = ___index(after: i)
        distance -= 1
      } else {
        guard i != __begin_node_ else {
          fatalError(.outOfBounds)
        }
        i = ___index(before: i)
        distance += 1
      }
    }
    return i
  }

  @inlinable
  @inline(__always)
  internal func ___formIndex(_ i: inout _NodePtr, offsetBy distance: Int) {
    i = ___index(i, offsetBy: distance)
  }

  @inlinable
  @inline(__always)
  internal func
    ___index(_ i: _NodePtr, offsetBy distance: Int, limitedBy limit: _NodePtr)
    -> _NodePtr?
  {
    ___ensureValid(offset: i)
    var distance = distance
    var i = i
    while distance != 0 {
      if i == limit {
        return nil
      }
      if 0 < distance {
        guard i != __end_node else {
          fatalError(.outOfBounds)
        }
        i = ___index(after: i)
        distance -= 1
      } else {
        guard i != __begin_node_ else {
          fatalError(.outOfBounds)
        }
        i = ___index(before: i)
        distance += 1
      }
    }
    return i
  }

  @inlinable
  @inline(__always)
  internal func
    ___formIndex(
      _ i: inout _NodePtr, offsetBy distance: Int, limitedBy limit: _NodePtr
    )
    -> Bool
  {
    if let ii = ___index(i, offsetBy: distance, limitedBy: limit) {
      i = ii
      return true
    }
    return false
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal func
    ___tree_adv_iter(_ i: _NodePtr, by distance: Int) -> _NodePtr
  {
    ___ensureValid(offset: i)
    var distance = distance
    var result: _NodePtr = i
    while distance != 0 {
      if 0 < distance {
        if result == __end_node { return result }
        result = __tree_next_iter(result)
        distance -= 1
      } else {
        if result == __begin_node_ {
          result = end
          return result
        }
        result = __tree_prev_iter(result)
        distance += 1
      }
    }
    return result
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal static func ___insert_range_unique<Other>(
    tree __tree_: UnsafeTreeV2,
    other __source: UnsafeTreeV2<Other>,
    _ __first: _NodePtr,
    _ __last: _NodePtr
  ) -> UnsafeTreeV2
  where
    UnsafeTreeV2<Other>._Key == _Key,
    UnsafeTreeV2<Other>._Value == _Value
  {
    if __first == __last {
      return __tree_
    }

    var __tree_ = __tree_

    var __first = __first

    if __tree_.__root == __tree_.nullptr, __first != __last {
      Tree.ensureCapacity(tree: &__tree_)
      __tree_.__insert_node_at(
        __tree_.end, __tree_.__left_ref(__tree_.end),
        __tree_.__construct_node(__source.__value_(__first)))
      __first = __source.__tree_next_iter(__first)
    }

    var __max_node = __tree_.__tree_max(__tree_.__root)

    while __first != __last {
      Tree.ensureCapacity(tree: &__tree_)
      let __nd = __tree_.__construct_node(__source.__value_(__first))
      __first = __source.__tree_next_iter(__first)

      if __tree_.value_comp(__tree_.__get_value(__max_node), __tree_.__get_value(__nd)) {  // __node > __max_node
        __tree_.__insert_node_at(__max_node, __tree_.__right_ref(__max_node), __nd)
        __max_node = __nd
      } else {
        let (__parent, __child) = __tree_.__find_equal(__tree_.__get_value(__nd))
        if __tree_.__ptr_(__child) == __tree_.nullptr {
          __tree_.__insert_node_at(__parent, __child, __nd)
        } else {
          __tree_.destroy(__nd)
        }
      }
    }

    return __tree_
  }
}

extension UnsafeTreeV2 where Base: KeyValueComparer {

  @inlinable
  @inline(__always)
  internal static func ___insert_range_unique<Other>(
    tree __tree_: UnsafeTreeV2,
    other __source: UnsafeTreeV2<Other>,
    _ __first: _NodePtr,
    _ __last: _NodePtr,
    uniquingKeysWith combine: (Base._MappedValue, Base._MappedValue) throws -> Base._MappedValue
  ) rethrows -> UnsafeTreeV2
  where
    UnsafeTreeV2<Other>._Key == _Key,
    UnsafeTreeV2<Other>._Value == _Value
  {
    if __first == __last {
      return __tree_
    }

    var __tree_ = __tree_

    var __i = __first

    if __tree_.__root == __tree_.nullptr, __i != __last {  // Make sure we always have a root node
      Tree.ensureCapacity(tree: &__tree_)
      __tree_.__insert_node_at(
        __tree_.end, __tree_.__left_ref(__tree_.end),
        __tree_.__construct_node(__source.__value_(__i)))
      __i = __source.__tree_next_iter(__i)
    }

    var __max_node = __tree_.__tree_max(__tree_.__root)

    while __i != __last {
      Tree.ensureCapacity(tree: &__tree_)
      let __nd = __tree_.__construct_node(__source.__value_(__i))
      __i = __source.__tree_next_iter(__i)

      if __tree_.value_comp(__tree_.__get_value(__max_node), __tree_.__get_value(__nd)) {  // __node > __max_node
        __tree_.__insert_node_at(__max_node, __tree_.__right_ref(__max_node), __nd)
        __max_node = __nd
      } else {
        let (__parent, __child) = __tree_.__find_equal(__tree_.__get_value(__nd))
        if __tree_.__ptr_(__child) == __tree_.nullptr {
          __tree_.__insert_node_at(__parent, __child, __nd)
        } else {
          try __tree_.___with_mapped_value(__tree_.__ptr_(__child)) { __mappedValue in
            __mappedValue = try combine(__mappedValue, Base.___mapped_value(__tree_.__value_(__nd)))
          }
          __tree_.destroy(__nd)
        }
      }
    }

    return __tree_
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal static func ___insert_range_multi<Other>(
    tree __tree_: UnsafeTreeV2,
    other __source: UnsafeTreeV2<Other>,
    _ __first: _NodePtr,
    _ __last: _NodePtr
  ) -> UnsafeTreeV2
  where
    UnsafeTreeV2<Other>._Key == _Key,
    UnsafeTreeV2<Other>._Value == _Value
  {
    if __first == __last {
      return __tree_
    }

    var __tree_ = __tree_

    Tree.ensureCapacity(tree: &__tree_, minimumCapacity: __tree_.__size_ + __source.__size_)

    var __first = __first

    if __tree_.__root == __tree_.nullptr, __first != __last {
      __tree_.__insert_node_at(
        __tree_.end, __tree_.__left_ref(__tree_.end), __tree_.__construct_node(__source.__value_(__first)))
      __first = __source.__tree_next_iter(__first)
    }

    var __max_node = __tree_.__tree_max(__tree_.__root)

    while __first != __last {
      let __nd = __tree_.__construct_node(__source.__value_(__first))
      __first = __source.__tree_next_iter(__first)

      if !__tree_.value_comp(__tree_.__get_value(__nd), __tree_.__get_value(__max_node)) {  // __node >= __max_val
        __tree_.__insert_node_at(__max_node, __tree_.__right_ref(__max_node), __nd)
        __max_node = __nd
      } else {
        var __parent: _NodePtr = __tree_.nullptr
        let __child = __tree_.__find_leaf_high(&__parent, __tree_.__get_value(__nd))
        __tree_.__insert_node_at(__parent, __child, __nd)
      }
    }

    return __tree_
  }
}

extension UnsafeTreeV2 {

  @inlinable
  internal static func ___insert_range_unique<S>(tree __tree_: UnsafeTreeV2, _ __source: __owned S)
    -> UnsafeTreeV2
  where Base._Value == S.Element, S: Sequence {
    return ___insert_range_unique(tree: __tree_, __source) { $0 }
  }

  @inlinable
  internal static func ___insert_range_unique<S>(
    tree __tree_: UnsafeTreeV2,
    _ __source: __owned S,
    transform: (S.Element) -> Base._Value
  ) -> UnsafeTreeV2
  where S: Sequence {
    var __tree_ = __tree_

    var it = __source.makeIterator()

    if __tree_.__root == __tree_.nullptr, let __element = it.next() {  // Make sure we always have a root node
      Tree.ensureCapacity(tree: &__tree_)
      __tree_.__insert_node_at(
        __tree_.end, __tree_.__left_ref(__tree_.end), __tree_.__construct_node(transform(__element)))
    }

    if __tree_.__root == __tree_.nullptr { return __tree_ }

    var __max_node = __tree_.__tree_max(__tree_.__root)

    while let __element = it.next() {
      Tree.ensureCapacity(tree: &__tree_)
      let __nd = __tree_.__construct_node(transform(__element))
      if __tree_.value_comp(__tree_.__get_value(__max_node), __tree_.__get_value(__nd)) {  // __node > __max_node
        __tree_.__insert_node_at(__max_node, __tree_.__right_ref(__max_node), __nd)
        __max_node = __nd
      } else {
        let (__parent, __child) = __tree_.__find_equal(__tree_.__get_value(__nd))
        if __tree_.__ptr_(__child) == __tree_.nullptr {
          __tree_.__insert_node_at(__parent, __child, __nd)
        } else {
          __tree_.destroy(__nd)
        }
      }
    }

    return __tree_
  }
}

extension UnsafeTreeV2 where Base: KeyValueComparer {

  @inlinable
  @inline(__always)
  internal static func ___insert_range_unique<S>(
    tree __tree_: UnsafeTreeV2,
    _ __source: S,
    uniquingKeysWith combine: (Base._MappedValue, Base._MappedValue) throws -> Base._MappedValue,
    transform __t_: (S.Element) -> Base._Value
  )
    rethrows -> UnsafeTreeV2
  where
    S: Sequence
  {
    var __tree_ = __tree_

    var it = __source.makeIterator()

    if __tree_.__root == __tree_.nullptr, let __element = it.next().map(__t_) {  // Make sure we always have a root node
      Tree.ensureCapacity(tree: &__tree_)
      __tree_.__insert_node_at(
        __tree_.end, __tree_.__left_ref(__tree_.end), __tree_.__construct_node(__element))
    }

    if __tree_.__root == __tree_.nullptr { return __tree_ }

    var __max_node = __tree_.__tree_max(__tree_.__root)

    while let __element = it.next().map(__t_) {
      Tree.ensureCapacity(tree: &__tree_)
      let __nd = __tree_.__construct_node(__element)
      if __tree_.value_comp(__tree_.__get_value(__max_node), __tree_.__get_value(__nd)) {  // __node > __max_node
        __tree_.__insert_node_at(__max_node, __tree_.__right_ref(__max_node), __nd)
        __max_node = __nd
      } else {
        let (__parent, __child) = __tree_.__find_equal(__tree_.__get_value(__nd))
        if __tree_.__ptr_(__child) == __tree_.nullptr {
          __tree_.__insert_node_at(__parent, __child, __nd)
        } else {
          try __tree_.___with_mapped_value(__tree_.__ptr_(__child)) { __mappedValue in
            __mappedValue = try combine(__mappedValue, Base.___mapped_value(__tree_.__value_(__nd)))
          }
          __tree_.destroy(__nd)
        }
      }
    }

    return __tree_
  }
}

extension UnsafeTreeV2 {

  @inlinable
  internal static func
    ___insert_range_multi<S>(tree __tree_: UnsafeTreeV2, _ __source: __owned S) -> UnsafeTreeV2
  where Base._Value == S.Element, S: Sequence {
    ___insert_range_multi(tree: __tree_, __source) { $0 }
  }

  @inlinable
  internal static func
    ___insert_range_multi<S>(
      tree __tree_: UnsafeTreeV2,
      _ __source: __owned S,
      transform: (S.Element) -> Base._Value
    )
    -> UnsafeTreeV2
  where S: Sequence {
    var __tree_ = __tree_

    var it = __source.makeIterator()

    if __tree_.__root == __tree_.nullptr, let __element = it.next() {  // Make sure we always have a root node
      Tree.ensureCapacity(tree: &__tree_)
      __tree_.__insert_node_at(
        __tree_.end, __tree_.__left_ref(__tree_.end), __tree_.__construct_node(transform(__element)))
    }

    if __tree_.__root == __tree_.nullptr { return __tree_ }

    var __max_node = __tree_.__tree_max(__tree_.__root)

    while let __element = it.next() {
      Tree.ensureCapacity(tree: &__tree_)
      let __nd = __tree_.__construct_node(transform(__element))
      if !__tree_.value_comp(__tree_.__get_value(__nd), __tree_.__get_value(__max_node)) {  // __node >= __max_val
        __tree_.__insert_node_at(__max_node, __tree_.__right_ref(__max_node), __nd)
        __max_node = __nd
      } else {
        var __parent: _NodePtr = __tree_.nullptr
        let __child = __tree_.__find_leaf_high(&__parent, __tree_.__get_value(__nd))
        __tree_.__insert_node_at(__parent, __child, __nd)
      }
    }

    return __tree_
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal func isIdentical(to other: UnsafeTreeV2) -> Bool {
    self._buffer.buffer === other._buffer.buffer
  }
}

extension UnsafeTreeV2 where Base: KeyValueComparer {

  @inlinable
  @inline(__always)
  internal func ___mapped_value(_ __p: _NodePtr) -> Base._MappedValue {
    Base.___mapped_value(UnsafePair<_Value>.valuePointer(__p)!.pointee)
  }

  @inlinable
  @inline(__always)
  internal func ___with_mapped_value<T>(
    _ __p: _NodePtr, _ f: (inout Base._MappedValue) throws -> T
  )
    rethrows -> T
  {
    try Base.___with_mapped_value(&UnsafePair<_Value>.valuePointer(__p)!.pointee, f)
  }
}

extension UnsafeTreeV2 where Base: KeyValueComparer {

  @inlinable
  @inline(__always)
  internal func ___mapValues<Other>(
    _ __first: _NodePtr,
    _ __last: _NodePtr,
    _ transform: (Base._MappedValue) throws -> Other._MappedValue
  )
    rethrows -> UnsafeTreeV2<Other>
  where
    Other: KeyValueComparer & ___UnsafeKeyValueSequenceV2,
    Other._Key == Base._Key
  {
    let other = UnsafeTreeV2<Other>.create(minimumCapacity: count)
    var (__parent, __child) = other.___max_ref()
    for __p in unsafeSequence(__first, __last) {
      let __mapped_value = try transform(___mapped_value(__p))
      (__parent, __child) = other.___emplace_hint_right(
        __parent, __child, Other.___tree_value((__get_value(__p), __mapped_value)))
      assert(other.__tree_invariant(other.__root))
    }
    return other
  }

  @inlinable
  @inline(__always)
  internal func ___compactMapValues<Other>(
    _ __first: _NodePtr,
    _ __last: _NodePtr,
    _ transform: (Base._MappedValue) throws -> Other._MappedValue?
  )
    rethrows -> UnsafeTreeV2<Other>
  where
    Other: KeyValueComparer & ___UnsafeKeyValueSequenceV2,
    Other._Key == Base._Key
  {
    var other = UnsafeTreeV2<Other>.create(minimumCapacity: count)
    var (__parent, __child) = other.___max_ref()
    for __p in unsafeSequence(__first, __last) {
      guard let __mv = try transform(___mapped_value(__p)) else { continue }
      UnsafeTreeV2<Other>.ensureCapacity(tree: &other)
      (__parent, __child) = other.___emplace_hint_right(
        __parent, __child, Other.___tree_value((__get_value(__p), __mv)))
      assert(other.__tree_invariant(other.__root))
    }
    return other
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal func
    ___for_each_(__p: _NodePtr, __l: _NodePtr, body: (_NodePtr) throws -> Void)
    rethrows
  {
    for __c in sequence(__p, __l) {
      try body(__c)
    }
  }

  @inlinable
  @inline(__always)
  internal func ___rev_for_each_(
    __p: _NodePtr, __l: _NodePtr, body: (_NodePtr) throws -> Void
  )
    rethrows
  {
    for __c in sequence(__p, __l).reversed() {
      try body(__c)
    }
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal func ___for_each(
    __p: _NodePtr, __l: _NodePtr, body: (_NodePtr, inout Bool) throws -> Void
  )
    rethrows
  {
    for __c in sequence(__p, __l) {
      var cont = true
      try body(__c, &cont)
      if !cont {
        break
      }
    }
  }
}

extension UnsafeTreeV2 {

  @inlinable
  internal func elementsEqual<OtherSequence>(
    _ __first: _NodePtr, _ __last: _NodePtr, _ other: OtherSequence,
    by areEquivalent: (_Value, OtherSequence.Element) throws -> Bool
  ) rethrows -> Bool where OtherSequence: Sequence {
    try unsafeValues(__first, __last).elementsEqual(other, by: areEquivalent)
  }
}

extension UnsafeTreeV2 {

  @inlinable
  internal func lexicographicallyPrecedes<OtherSequence>(
    _ __first: _NodePtr, _ __last: _NodePtr, _ other: OtherSequence,
    by areInIncreasingOrder: (_Value, _Value) throws -> Bool
  ) rethrows -> Bool where OtherSequence: Sequence, _Value == OtherSequence.Element {
    try unsafeValues(__first, __last).lexicographicallyPrecedes(other, by: areInIncreasingOrder)
  }
}

extension UnsafeTreeV2 {

  @inlinable
  internal func
    ___copy_to_array(_ __first: _NodePtr, _ __last: _NodePtr) -> [_Value]
  {
    let count = __distance(__first, __last)
    return .init(unsafeUninitializedCapacity: count) { buffer, initializedCount in
      initializedCount = count
      var buffer = buffer.baseAddress!
      var __first = __first
      while __first != __last {
        buffer.initialize(to: self[__first])
        buffer = buffer + 1
        __first = __tree_next_iter(__first)
      }
    }
  }

  @inlinable
  internal func
    ___copy_to_array<T>(_ __first: _NodePtr, _ __last: _NodePtr, transform: (_Value) -> T)
    -> [T]
  {
    let count = __distance(__first, __last)
    return .init(unsafeUninitializedCapacity: count) { buffer, initializedCount in
      initializedCount = count
      var buffer = buffer.baseAddress!
      var __first = __first
      while __first != __last {
        buffer.initialize(to: transform(self[__first]))
        buffer = buffer + 1
        __first = __tree_next_iter(__first)
      }
    }
  }
}

extension UnsafeTreeV2: Equatable where _Value: Equatable {

  @inlinable
  @inline(__always)
  public static func == (lhs: UnsafeTreeV2<Base>, rhs: UnsafeTreeV2<Base>) -> Bool {

    if lhs.count != rhs.count {
      return false
    }

    if lhs.count == 0 || lhs.isIdentical(to: rhs) {
      return true
    }

    return lhs.elementsEqual(
      lhs.__begin_node_,
      lhs.__end_node,
      rhs.unsafeValues(rhs.__begin_node_, rhs.__end_node),
      by: ==)
  }
}

extension UnsafeTreeV2: Comparable where _Value: Comparable {

  @inlinable
  @inline(__always)
  public static func < (lhs: UnsafeTreeV2<Base>, rhs: UnsafeTreeV2<Base>) -> Bool {
    !lhs.isIdentical(to: rhs)
      && lhs.lexicographicallyPrecedes(
        lhs.__begin_node_,
        lhs.__end_node,
        rhs.unsafeValues(rhs.__begin_node_, rhs.__end_node),
        by: <)
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal func ___filter(
    _ __first: _NodePtr,
    _ __last: _NodePtr,
    _ isIncluded: (_Value) throws -> Bool
  )
    rethrows -> UnsafeTreeV2
  {
    var tree: Tree = .create(minimumCapacity: 0)
    var (__parent, __child) = tree.___max_ref()
    for __p in unsafeSequence(__first, __last)
    where try isIncluded(__value_(__p)) {
      Tree.ensureCapacity(tree: &tree)
      (__parent, __child) = tree.___emplace_hint_right(__parent, __child, __value_(__p))
      assert(tree.__tree_invariant(tree.__root))
    }
    return tree
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal func
    sequence(_ __first: _NodePtr, _ __last: _NodePtr) -> ___SafePointersUnsafeV2<Base>
  {
    .init(tree: self, start: __first, end: __last)
  }

  @inlinable
  @inline(__always)
  internal func
    unsafeSequence(_ __first: _NodePtr, _ __last: _NodePtr)
    -> ___UnsafePointersUnsafeV2<Base>
  {
    .init(tree: self, __first: __first, __last: __last)
  }

  @inlinable
  @inline(__always)
  internal func
    unsafeValues(_ __first: _NodePtr, _ __last: _NodePtr)
    -> ___UnsafeValuesUnsafeV2<Base>
  {
    .init(tree: self, __first: __first, __last: __last)
  }
}


extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal func ___copy_range(_ f: inout _NodePtr, _ l: _NodePtr, to r: inout Tree) {
    var (__parent, __child) = r.___max_ref()
    while f != l {
      Tree.ensureCapacity(tree: &r)
      (__parent, __child) = r.___emplace_hint_right(__parent, __child, self[f])
      f = __tree_next_iter(f)
    }
  }

  @inlinable
  @inline(__always)
  internal func ___meld_unique(_ other: UnsafeTreeV2) -> UnsafeTreeV2 {

    var __result_: UnsafeTreeV2 = .___create(minimumCapacity: 0, nullptr: nullptr)

    var (__parent, __child) = __result_.___max_ref()
    var (__first1, __last1) = (__begin_node_, __end_node)
    var (__first2, __last2) = (other.__begin_node_, other.__end_node)

    while __first1 != __last1 {
      if __first2 == __last2 {
        ___copy_range(&__first1, __last1, to: &__result_)
        return __result_
      }

      if value_comp(
        other.__get_value(__first2),
        self.__get_value(__first1))
      {

        Tree.ensureCapacity(tree: &__result_)
        (__parent, __child) = __result_.___emplace_hint_right(__parent, __child, other[__first2])
        __first2 = other.__tree_next_iter(__first2)
      } else {
        if !value_comp(
          self.__get_value(__first1),
          other.__get_value(__first2))
        {
          __first2 = other.__tree_next_iter(__first2)
        }

        Tree.ensureCapacity(tree: &__result_)
        (__parent, __child) = __result_.___emplace_hint_right(__parent, __child, self[__first1])
        __first1 = __tree_next_iter(__first1)
      }
    }

    other.___copy_range(&__first2, __last2, to: &__result_)
    return __result_
  }

  @inlinable
  @inline(__always)
  internal func ___meld_multi(_ other: UnsafeTreeV2) -> UnsafeTreeV2 {

    var __result_: UnsafeTreeV2 = .___create(minimumCapacity: 0, nullptr: nullptr)

    var (__parent, __child) = __result_.___max_ref()
    var (__first1, __last1) = (__begin_node_, __end_node)
    var (__first2, __last2) = (other.__begin_node_, other.__end_node)

    while __first1 != __last1 {

      if __first2 == __last2 {
        ___copy_range(&__first1, __last1, to: &__result_)
        return __result_
      }

      if value_comp(
        self.__get_value(__first1),
        other.__get_value(__first2))
      {

        Tree.ensureCapacity(tree: &__result_)
        (__parent, __child) = __result_.___emplace_hint_right(__parent, __child, self[__first1])
        __first1 = __tree_next_iter(__first1)
      } else if value_comp(
        other.__get_value(__first2),
        self.__get_value(__first1))
      {

        Tree.ensureCapacity(tree: &__result_)
        (__parent, __child) = __result_.___emplace_hint_right(__parent, __child, other[__first2])
        __first2 = other.__tree_next_iter(__first2)
      } else {
        Tree.ensureCapacity(tree: &__result_)
        (__parent, __child) = __result_.___emplace_hint_right(__parent, __child, self[__first1])
        __first1 = __tree_next_iter(__first1)

        Tree.ensureCapacity(tree: &__result_)
        (__parent, __child) = __result_.___emplace_hint_right(__parent, __child, other[__first2])
        __first2 = other.__tree_next_iter(__first2)
      }
    }

    other.___copy_range(&__first2, __last2, to: &__result_)
    return __result_
  }

  @inlinable
  @inline(__always)
  internal func ___intersection(_ other: UnsafeTreeV2) -> UnsafeTreeV2 {
    var __result_: UnsafeTreeV2 = .___create(minimumCapacity: 0, nullptr: nullptr)
    var (__parent, __child) = __result_.___max_ref()
    var (__first1, __last1) = (__begin_node_, __end_node)
    var (__first2, __last2) = (other.__begin_node_, other.__end_node)
    while __first1 != __last1, __first2 != __last2 {
      if value_comp(self.__get_value(__first1), other.__get_value(__first2)) {
        __first1 = __tree_next_iter(__first1)
      } else {
        if !value_comp(other.__get_value(__first2), self.__get_value(__first1)) {
          Tree.ensureCapacity(tree: &__result_)
          (__parent, __child) = __result_.___emplace_hint_right(__parent, __child, self[__first1])
          __first1 = __tree_next_iter(__first1)
        }
        __first2 = other.__tree_next_iter(__first2)
      }
    }
    return __result_
  }

  @inlinable
  @inline(__always)
  internal func ___symmetric_difference(_ other: UnsafeTreeV2) -> UnsafeTreeV2 {
    var __result_: UnsafeTreeV2 = .___create(minimumCapacity: 0, nullptr: nullptr)
    var (__parent, __child) = __result_.___max_ref()
    var (__first1, __last1) = (__begin_node_, __end_node)
    var (__first2, __last2) = (other.__begin_node_, other.__end_node)
    while __first1 != __last1 {
      if __first2 == __last2 {
        ___copy_range(&__first1, __last1, to: &__result_)
        return __result_
      }
      if value_comp(self.__get_value(__first1), other.__get_value(__first2)) {
        Tree.ensureCapacity(tree: &__result_)
        (__parent, __child) = __result_.___emplace_hint_right(__parent, __child, self[__first1])
        __first1 = __tree_next_iter(__first1)
      } else {
        if value_comp(other.__get_value(__first2), self.__get_value(__first1)) {
          Tree.ensureCapacity(tree: &__result_)
          (__parent, __child) = __result_.___emplace_hint_right(__parent, __child, other[__first2])
        } else {
          __first1 = __tree_next_iter(__first1)
        }
        __first2 = other.__tree_next_iter(__first2)
      }
    }
    other.___copy_range(&__first2, __last2, to: &__result_)
    return __result_
  }

  @inlinable
  @inline(__always)
  internal func ___difference(_ other: UnsafeTreeV2) -> UnsafeTreeV2 {
    var __result_: UnsafeTreeV2 = .___create(minimumCapacity: 0, nullptr: nullptr)
    var (__parent, __child) = __result_.___max_ref()
    var (__first1, __last1) = (__begin_node_, __end_node)
    var (__first2, __last2) = (other.__begin_node_, other.__end_node)
    while __first1 != __last1, __first2 != __last2 {
      if value_comp(self.__get_value(__first1), other.__get_value(__first2)) {
        Tree.ensureCapacity(tree: &__result_)
        (__parent, __child) = __result_.___emplace_hint_right(__parent, __child, self[__first1])
        __first1 = __tree_next_iter(__first1)
      } else if value_comp(other.__get_value(__first2), self.__get_value(__first1)) {
        __first2 = other.__tree_next_iter(__first2)
      } else {
        __first1 = __tree_next_iter(__first1)
        __first2 = other.__tree_next_iter(__first2)
      }
    }
    return __result_
  }
}
#if DEBUG
  extension UnsafeTreeV2 {

    package func ___NodePtr(_ p: Int) -> _NodePtr {
      switch p {
      case .nullptr:
        return nullptr
      case .end:
        return end
      default:
        return _buffer.header[p]
      }
    }
  }

  extension UnsafeTreeV2 {

    package func ___ptr_(_ p: _NodePtr) -> Int {
      p.pointee.___node_id_
    }

    package func __left_(_ p: Int) -> Int {
      __left_(___NodePtr(p)).pointee.___node_id_
    }

    package func __left_(_ p: Int, _ l: Int) {
      __left_(___NodePtr(p), ___NodePtr(l))
    }

    package func __right_(_ p: Int) -> Int {
      __right_(___NodePtr(p)).pointee.___node_id_
    }

    package func __right_(_ p: Int, _ l: Int) {
      __right_(___NodePtr(p), ___NodePtr(l))
    }

    package func __parent_(_ p: Int) -> Int {
      __parent_(___NodePtr(p)).pointee.___node_id_
    }

    package func __parent_(_ p: Int, _ l: Int) {
      __parent_(___NodePtr(p), ___NodePtr(l))
    }

    package func __is_black_(_ p: Int) -> Bool {
      __is_black_(___NodePtr(p))
    }

    package func __is_black_(_ p: Int, _ b: Bool) {
      __is_black_(___NodePtr(p), b)
    }

    package func __value_(_ p: Int) -> _Value {
      __value_(___NodePtr(p))
    }

    package func ___element(_ p: Int, _ __v: _Value) {
      ___element(___NodePtr(p), __v)
    }
  }

  extension UnsafeTreeV2 {

    package func destroy(_ p: Int) {
      _buffer.withUnsafeMutablePointerToHeader { header in
        header.pointee.___pushRecycle(_buffer.header[p])
      }
    }
  }

  extension UnsafeMutablePointer where Pointee == UnsafeNode {
    package var index: Int { pointee.___node_id_ }
  }

  extension Optional where Wrapped == UnsafeMutablePointer<UnsafeNode> {
    package var index: Int { self?.pointee.___node_id_ ?? .nullptr }
  }
#endif


#if DEBUG
  extension UnsafeNode {

    @inlinable
    package func equiv(with tree: UnsafeNode) -> Bool {
      assert(___node_id_ == tree.___node_id_)
      assert(__left_.pointee.___node_id_ == tree.__left_.pointee.___node_id_)
      assert(__right_.pointee.___node_id_ == tree.__right_.pointee.___node_id_)
      assert(__parent_.pointee.___node_id_ == tree.__parent_.pointee.___node_id_)
      assert(__is_black_ == tree.__is_black_)
      assert(___needs_deinitialize == tree.___needs_deinitialize)
      guard
        ___node_id_ == tree.___node_id_,
        __left_.pointee.___node_id_ == tree.__left_.pointee.___node_id_,
        __right_.pointee.___node_id_ == tree.__right_.pointee.___node_id_,
        __parent_.pointee.___node_id_ == tree.__parent_.pointee.___node_id_,
        __is_black_ == tree.__is_black_,
        ___needs_deinitialize == tree.___needs_deinitialize
      else {
        return false
      }
      return true
    }
  }

  extension UnsafeTreeV2Buffer.Header {

    @inlinable
    package func equiv(with other: UnsafeTreeV2Buffer.Header) -> Bool {
      assert(recycleCount == other.recycleCount)
      guard
        freshPoolUsedCount == other.freshPoolUsedCount,
        freshPoolActualCount == other.freshPoolActualCount,
        recycleCount == other.recycleCount,
        ___recycleNodes == other.___recycleNodes
      else {
        return false
      }
      return true
    }
  }

  extension UnsafeTreeV2 {

    @inlinable
    package func equiv(with tree: UnsafeTreeV2) -> Bool {
      assert(__end_node.pointee.equiv(with: tree.__end_node.pointee))
      assert(
        makeFreshPoolIterator()
          .elementsEqual(
            tree.makeFreshPoolIterator(),
            by: {
              assert($0.pointee.equiv(with: $1.pointee))
              return $0.pointee.equiv(with: $1.pointee)
            }))

      assert(__begin_node_.pointee.___node_id_ == tree.__begin_node_.pointee.___node_id_)
      assert(_buffer.header.equiv(with: tree._buffer.header))
      guard

        __end_node.pointee
          .equiv(with: tree.__end_node.pointee),

        makeFreshPoolIterator()
          .elementsEqual(
            tree.makeFreshPoolIterator(),
            by: {
              $0.pointee.equiv(with: $1.pointee)
            }),

        __begin_node_.pointee.___node_id_
          == tree.__begin_node_.pointee.___node_id_,

        _buffer.header.equiv(with: tree._buffer.header)

      else {
        return false
      }
      return true
    }
  }

  extension UnsafeNode {

    @inlinable
    package func nullCheck() -> Bool {
      assert(___node_id_ == .nullptr)
      assert(__left_ == UnsafeNode.nullptr)
      assert(__right_ == UnsafeNode.nullptr)
      assert(__parent_ == UnsafeNode.nullptr)
      assert(__is_black_ == false)
      assert(___needs_deinitialize == true)
      guard
        ___node_id_ == .nullptr,
        __right_ == UnsafeNode.nullptr,
        __right_ == UnsafeNode.nullptr,
        __parent_ == UnsafeNode.nullptr,
        __is_black_ == false,
        ___needs_deinitialize == true
      else {
        return false
      }
      return true
    }

    @inlinable
    package func endCheck() -> Bool {
      assert(___node_id_ == .end)
      assert(__right_ == UnsafeNode.nullptr)
      assert(__parent_ == UnsafeNode.nullptr)
      assert(__is_black_ == false)
      guard
        ___node_id_ == .end,
        __right_ == UnsafeNode.nullptr,
        __parent_ == UnsafeNode.nullptr,
        __is_black_ == false,
        ___needs_deinitialize == true
      else {
        return false
      }
      return true
    }
  }

  extension UnsafeTreeV2 {

    @inlinable
    package func emptyCheck() -> Bool {
      assert(__tree_invariant(__root))
      assert(count == 0)
      assert(count <= initializedCount)
      assert(count <= capacity)
      assert(initializedCount <= capacity)
      assert(isReadOnly ? count == 0 : true)
      guard
        __tree_invariant(__root),
        end.pointee.__left_ == UnsafeNode.nullptr,
        __begin_node_ == end,
        end.pointee.___needs_deinitialize == true,
        count == 0,
        count <= initializedCount,
        count <= capacity,
        initializedCount <= capacity,
        isReadOnly ? count == 0 : true
      else {
        return false
      }
      return true
    }

    @inlinable
    package func check() -> Bool {
      assert(UnsafeNode.nullptr.pointee.nullCheck())
      assert(end.pointee.endCheck())
      assert(count >= 0)
      assert(count <= initializedCount)
      assert(count <= capacity)
      assert(initializedCount <= capacity)
      assert(isReadOnly ? count == 0 : true)
      assert(try! ___tree_invariant(__root))
      guard
        UnsafeNode.nullptr.pointee.nullCheck(),
        end.pointee.endCheck(),
        count == 0 ? emptyCheck() : true,
        (try? ___tree_invariant(__root)) == true,
        count >= 0,
        count <= initializedCount,
        count <= capacity,
        initializedCount <= capacity,
        isReadOnly ? count == 0 : true,
        true
      else {
        return false
      }
      return true
    }
  }
#else
  extension UnsafeTreeV2 {
    @inlinable
    package func equiv(with tree: UnsafeTreeV2) -> Bool {
      return true
    }
    @inlinable
    package func check() -> Bool {
      return true
    }
  }
#endif

extension UnsafeTreeV2 {

  enum UnsafeTreeError: Swift.Error {
    case message(String)
  }

  @usableFromInline
  internal func
    ___tree_sub_invariant(_ __x: _NodePtr) throws -> UInt
  {
    if __x == nullptr {
      return 1
    }
    if __left_(__x) != nullptr && __parent_(__left_(__x)) != __x {
      throw UnsafeTreeError.message(
        """
        parent consistency checked by caller
        check __x->__left_ consistency
        """)
    }
    if __right_(__x) != nullptr && __parent_(__right_(__x)) != __x {
      throw UnsafeTreeError.message(
        """
        check __x->__right_ consistency
        """)
    }
    if __left_(__x) == __right_(__x) && __left_(__x) != nullptr {
      throw UnsafeTreeError.message(
        """
        check __x->__left_ != __x->__right_ unless both are nullptr
        """)
    }
    if !__is_black_(__x) {
      if __left_(__x) != nullptr && !__is_black_(__left_(__x)) {
        throw UnsafeTreeError.message(
          """
          If this is red, neither child can be red
          """)
      }
      if __right_(__x) != nullptr && !__is_black_(__right_(__x)) {
        throw UnsafeTreeError.message(
          """
          If this is red, neither child can be red
          """)
      }
    }
    let __h = try ___tree_sub_invariant(__left_(__x))
    if __h == 0 {
      throw UnsafeTreeError.message(
        """
        invalid left subtree
        """)
    }  // invalid left subtree
    if try __h != ___tree_sub_invariant(__right_(__x)) {
      throw UnsafeTreeError.message(
        """
        invalid or different height right subtree
        """)
    }  // invalid or different height right subtree
    return __h + (__is_black_(__x) ? 1 : 0)  // return black height of this node
  }

  @usableFromInline
  internal func
    ___tree_invariant(_ __root: _NodePtr) throws -> Bool
  {
    if __root == nullptr {
      return true
    }
    if __parent_(__root) == nullptr {
      throw UnsafeTreeError.message("check __x->__parent_ consistency")
    }
    if !__tree_is_left_child(__root) {
      throw UnsafeTreeError.message("check left child of __root")
    }
    if !__is_black_(__root) {
      throw UnsafeTreeError.message("root must be black")
    }
    return try ___tree_sub_invariant(__root) != 0
  }
}

@inlinable
@inline(__always)
func ___is_null_or_end__(pointerIndex: Int) -> Bool {
  ___is_null_or_end(pointerIndex)
}

extension UnsafeTreeV2 {
  
  @inlinable
  @inline(__always)
  internal func ___is_null_or_end(_ ptr: _NodePtr) -> Bool {
    ___is_null_or_end__(pointerIndex: ptr.pointee.___node_id_)
  }

  @inlinable
  @inline(__always)
  internal func ___is_begin(_ p: _NodePtr) -> Bool {
    p == __begin_node_
  }

  @inlinable
  @inline(__always)
  internal func ___is_end(_ p: _NodePtr) -> Bool {
    p == end
  }

  @inlinable
  @inline(__always)
  internal func ___is_root(_ p: _NodePtr) -> Bool {
    p == __root
  }

  @inlinable
  @inline(__always)
  internal func ___initialized_contains(_ p: _NodePtr) -> Bool {
    0..<initializedCount ~= p.pointee.___node_id_
  }

  @inlinable
  @inline(__always)
  internal func ___is_subscript_null(_ p: _NodePtr) -> Bool {

    return ___is_null_or_end(p) || initializedCount <= p.pointee.___node_id_ || ___is_garbaged(p)
  }

  @inlinable
  @inline(__always)
  internal func ___is_next_null(_ p: _NodePtr) -> Bool {
    ___is_subscript_null(p)
  }

  @inlinable
  @inline(__always)
  internal func ___is_prev_null(_ p: _NodePtr) -> Bool {

    return p == nullptr || initializedCount <= p.pointee.___node_id_ || ___is_begin(p) || ___is_garbaged(p)
  }

  @inlinable
  @inline(__always)
  internal func ___is_offset_null(_ p: _NodePtr) -> Bool {
    return p == nullptr || initializedCount <= p.pointee.___node_id_ || ___is_garbaged(p)
  }

  @inlinable
  @inline(__always)
  internal func ___is_range_null(_ p: _NodePtr, _ l: _NodePtr) -> Bool {
    ___is_offset_null(p) || ___is_offset_null(l)
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  internal func ___ensureValid(after i: _NodePtr) {
    if ___is_next_null(i) {
      fatalError(.invalidIndex)
    }
  }

  @inlinable
  @inline(__always)
  internal func ___ensureValid(before i: _NodePtr) {
    if ___is_prev_null(i) {
      fatalError(.invalidIndex)
    }
  }

  @inlinable
  @inline(__always)
  internal func ___ensureValid(offset i: _NodePtr) {
    if ___is_offset_null(i) {
      fatalError(.invalidIndex)
    }
  }

  @inlinable
  @inline(__always)
  internal func ___ensureValid(subscript i: _NodePtr) {
    if ___is_subscript_null(i) {
      fatalError(.invalidIndex)
    }
  }

  @inlinable
  @inline(__always)
  internal func ___ensureValid(begin i: _NodePtr, end j: _NodePtr) {
    if ___is_range_null(i, j) {
      fatalError(.invalidIndex)
    }
  }
}



// ----


var (N, m): (Int,Int) = stdin()
var p_rev = (0..<N) + []
var p = (0..<N).map { [$0] }
var e: [RedBlackTreeSet<Int>] = .init(repeating: .init(), count: N)
var u: [Int] = []
var v: [Int] = []
for _ in 0..<m {
  let (_u,_v) = (Int.stdin - 1, Int.stdin - 1)
  u.append(_u)
  v.append(_v)
  e[_u].insert(_v)
  e[_v].insert(_u)
}
let Q = Int.stdin
for _ in 0..<Q {
  let x = Int.stdin - 1
  var vx = p_rev[u[x]]
  var vy = p_rev[v[x]]
  if vx != vy {
    let valx = (e[vx].count) + (p[vx].count)
    let valy = (e[vy].count) + (p[vy].count)
    if valx > valy { swap(&vx, &vy) }
    let sz = p[vx].count
    for j in 0..<sz {
      p[vy].append(p[vx][j])
      p_rev[p[vx][j]] = vy
    }
    p[vx].removeAll()
    for vz in e[vx] {
      if vz == vy {
        m -= 1
        e[vy].remove(vx)
      } else {
        if e[vy].contains(vz) {
          m -= 1
        } else {
          e[vy].insert(vz)
          e[vz].insert(vy)
        }
        e[vz].remove(vx)
      }
    }
    e[vx].removeAll()
  }
  fastPrint(m)
}
