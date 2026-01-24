//
//  unsafe_tree+distance.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/19.
//

@usableFromInline
protocol DistanceProtocol_ptr: _UnsafeNodePtrType & PointerCompareInterface {}

extension DistanceProtocol_ptr {

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
    ___dual_distance(_ __first: _InputIter, _ __last: _InputIter) -> difference_type
  {
    var __next = __first
    var __prev = __first
    var __r = 0
    while __next != __last, __prev != __last {
      __next = __next.___is_null ? __next : __tree_next(__next)
      __prev = __prev.___is_null ? __prev : __tree_prev_iter(__prev)
      __r += 1
    }
    return __next == __last ? __r : -__r
  }

  @inlinable
  @inline(__always)
  internal func
    ___comp_distance(_ __first: _InputIter, _ __last: _InputIter) -> difference_type
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

  @inlinable
  @inline(__always)
  internal func
    ___signed_distance(_ __first: _InputIter, _ __last: _InputIter) -> difference_type
  {
    #if false
      return ___comp_distance(__first, __last)
    #else
      return ___dual_distance(__first, __last)
    #endif
  }
}

extension RedBlackTreeSet {

  public func ___comp_distance(start: Index, end: Index) -> Int {
    __tree_.___comp_distance(__tree_.rawValue(start), __tree_.rawValue(end))
  }

  public func ___dual_distance(start: Index, end: Index) -> Int {
    __tree_.___dual_distance(__tree_.rawValue(start), __tree_.rawValue(end))
  }
  
  public func ___comp_mult(start: Index, end: Index) -> Bool {
    ___ptr_comp_multi_org(__tree_.rawValue(start), __tree_.rawValue(end))
  }
  
  public func ___comp_mult2(start: Index, end: Index) -> Bool {
    ___ptr_comp_multi(__tree_.rawValue(start), __tree_.rawValue(end))
  }

  public func ___comp_bitmap(start: Index, end: Index) -> Bool {
    ___ptr_comp_bitmap(__tree_.rawValue(start), __tree_.rawValue(end))
  }
}
