import Foundation

@usableFromInline
protocol DistanceProtocol: MemberProtocol & BeginNodeProtocol & EndNodeProtocol & ValueProtocol & RootProtocol {}

extension DistanceProtocol {

  @usableFromInline
  typealias difference_type = Int

  @usableFromInline
  typealias _InputIter = Int

  @inlinable
  func __distance(_ __first: _InputIter, _ __last: _InputIter) -> difference_type {
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
  func ___pointer_comp(_ l: _NodePtr,_ r: _NodePtr) -> Bool {
#if false
    guard
      l != r,
      r != .end,
      l != .end
    else {
      return l != .end && r == .end
    }
    return value_comp(__value_(l), __value_(r))
#else
    return ___ptr_less_than(l, r)
#endif
  }

  @inlinable
  func ___signed_distance(_ __first: _InputIter, _ __last: _InputIter) -> difference_type {
    guard __first != __last else { return 0 }
    var (__first, __last) = (__first, __last)
    var sign = 1
    if ___pointer_comp(__last, __first) {
      swap(&__first, &__last)
      sign = -1
    }
    return sign * __distance(__first, __last)
  }
}

extension DistanceProtocol {
  
  @inlinable
  func ___ptr_height(_ __p: _NodePtr) -> Int {
    var height = 0
    var __p = __p
    while __p != __root(), __p != .end {
      __p = __parent_(__p)
      height += 1
    }
    return height
  }

  @inlinable
  @inline(__always)
  func ___ptr_less_than(_ l: _NodePtr,_ r: _NodePtr) -> Bool {
    guard
      l != .end,
      r != .end,
      l != r else {
      return l != .end && r == .end
    }
    var (l, lh) = (l, ___ptr_height(l))
    var (r, rh) = (r, ___ptr_height(r))
    while lh > rh {
      if __parent_(l) == r {
        return __tree_is_left_child(l)
      }
      (l, lh) = (__parent_(l), lh - 1)
    }
    while lh < rh {
      if __parent_(r) == l {
        return !__tree_is_left_child(r)
      }
      (r, rh) = (__parent_(r), rh - 1)
    }
    while __parent_(l) != __parent_(r) {
      (l, r) = (__parent_(l), __parent_(r))
    }
    return  __tree_is_left_child(l)
  }

  @inlinable
  @inline(__always)
  func ___ptr_less_than_or_equal(_ l: _NodePtr,_ r: _NodePtr) -> Bool {
    return l == r || ___ptr_less_than(l, r)
  }
  
  @inlinable
  @inline(__always)
  func ___ptr_greator_than(_ l: _NodePtr,_ r: _NodePtr) -> Bool {
    return l != r && !___ptr_less_than(l, r)
  }

  @inlinable
  @inline(__always)
  func ___ptr_greator_than_or_equal(_ l: _NodePtr,_ r: _NodePtr) -> Bool {
    return !___ptr_less_than(l, r)
  }

  @inlinable
  @inline(__always)
  func ___ptr_range_contains(_ l: _NodePtr,_ r: _NodePtr,_ p: _NodePtr) -> Bool {
    ___ptr_less_than_or_equal(l, p) && ___ptr_less_than(p, r)
  }

  @inlinable
  @inline(__always)
  func ___ptr_closed_range_contains(_ l: _NodePtr,_ r: _NodePtr,_ p: _NodePtr) -> Bool {
    ___ptr_less_than_or_equal(l, p) && ___ptr_less_than_or_equal(p, r)
  }
}
