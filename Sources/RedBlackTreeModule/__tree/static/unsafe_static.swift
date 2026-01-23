//
//  unsafe_static.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/22.
//

import Foundation

public protocol CompareStaticProtocol:
  _UnsafeNodePtrType & IsMultiTraitStaticInterface & CompareUniqueStaticInterface
{}

extension CompareStaticProtocol {

  @inlinable
  @inline(__always)
  public static func ___ptr_comp(_ l: _NodePtr, _ r: _NodePtr) -> Bool {
    assert(l.___is_end || !l.__parent_.___is_null)
    assert(r.___is_end || !r.__parent_.___is_null)

    guard
      l != r,
      !r.___is_end,
      !l.___is_end
    else {
      return !l.___is_end && r.___is_end
    }

    if isMulti {

      // TODO: ポインタ版になったので再度はかりなおすこと

      #if true
        //      name                         time             std         iterations
        //      --------------------------------------------------------------------
        //      index compare 1000        19416.000 ns ±  10.13 %       69751
        //      index compare 1000000 109517708.000 ns ±   2.03 %          13

        return ___ptr_comp_unique(l, r) || (!___ptr_comp_unique(r, l) && ___ptr_comp_multi(l, r))

      #else
        //      name                         time             std         iterations
        //      --------------------------------------------------------------------
        //      index compare 1000        11917.000 ns ±   8.25 %     114822
        //      index compare 1000000  54229021.000 ns ±   3.62 %         24

        return ___ptr_comp_unique(l, r) || (!___ptr_comp_unique(r, l) && ___ptr_comp_bitmap(l, r))

      #endif
    }
    return ___ptr_comp_unique(l, r)
  }
}

// 遅い
@inlinable
@inline(__always)
internal func
  ___dual_distance(
    _ __first: UnsafeMutablePointer<UnsafeNode>,
    _ __last: UnsafeMutablePointer<UnsafeNode>
  )
  -> Int
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
  __distance(
    _ __first: UnsafeMutablePointer<UnsafeNode>,
    _ __last: UnsafeMutablePointer<UnsafeNode>
  )
  -> Int
{
  var __first = __first
  var __r = 0
  while __first != __last {
    __first = __tree_next(__first)
    __r += 1
  }
  return __r
}

extension CompareStaticProtocol {

  @usableFromInline
  typealias difference_type = Int

  @usableFromInline
  typealias _InputIter = _NodePtr

  @inlinable
  @inline(__always)
  static func
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
