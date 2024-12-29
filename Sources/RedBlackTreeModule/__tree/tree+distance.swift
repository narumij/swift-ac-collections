import Foundation

@usableFromInline
protocol DistanceProtocol: MemberProtocol & BeginNodeProtocol & EndNodeProtocol & ValueProtocol { }

extension DistanceProtocol {
  
  @usableFromInline
  typealias difference_type = Int
  
  @usableFromInline
  typealias _InputIter = Int
  
  @usableFromInline
  typealias _RandIter = Int
  
//  func __distance(_ __first: _InputIter,_ __last: _InputIter, input_iterator_tag) -> difference_type {
  @inlinable
  func __distance(__first: _InputIter,__last: _InputIter) -> difference_type {
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
  func ___signed_distance(__l: _NodePtr, __r: _NodePtr) -> Int {
    var __p = __begin_node
    var (l, r): (Int?, Int?) = (nil, nil)
    var __a = 0
    while __p != __end_node(), l == nil || r == nil {
      if __p == __l { l = __a }
      if __p == __r { r = __a }
      __p = __tree_next(__p)
      __a += 1
    }
    if __p == __l { l = __a }
    if __p == __r { r = __a }
    return r! - l!
  }

  @inlinable
  func ___signed_distance(_ __first: _InputIter,_ __last: _InputIter) -> difference_type {
//    return __distance(__first, __last, typename iterator_traits<_InputIter>::iterator_category());
//    return __distance(__first, __last);
#if false
    var (__first, __last) = (__first, __last)
    var swapped = false
    if __last != .end, !value_comp(__value_(__first), __value_(__last)) {
      swap(&__first, &__last)
      swapped = true
    }
    return (swapped ? -1 : 1) * __distance(__first: __first, __last: __last)
#else
    return ___signed_distance(__l: __first, __r: __last);
#endif
  }
}
