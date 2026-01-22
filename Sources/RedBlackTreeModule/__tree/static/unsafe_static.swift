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

      #if false
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

@inlinable
@inline(__always)
internal func
  __distance(_ __first: UnsafeMutablePointer<UnsafeNode>, _ __last: UnsafeMutablePointer<UnsafeNode>) -> Int
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
  
  public static func advanced(_ __ptr_: _NodePtr, by n: Int) -> _NodePtr {
    if __ptr_.___is_offset_null {
      fatalError(.invalidIndex)
    }
    var n = n
    var __ptr_ = __ptr_
    while n != 0 {
      if n < 0 {
        // 後ろと区別したくてnullptrにしてたが、一周回るとendなのでendにしてみる
        // TODO: fatalErrorにするか検討
        if __tree_prev_iter(__ptr_).___is_null {
          return __ptr_.__slow_end()
        }
        __ptr_ = __tree_prev_iter(__ptr_)
        n += 1
      } else {
        // TODO: fatalErrorにするか検討
        if __ptr_.___is_end { return __ptr_ }
        __ptr_ = __tree_next_iter(__ptr_)
        n -= 1
      }
      if __ptr_ == .nullptr {
        break
      }
    }
    return __ptr_
  }
}
