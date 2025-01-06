import Foundation

@usableFromInline
protocol DistanceProtocol: MemberProtocol & BeginNodeProtocol & EndNodeProtocol & ValueProtocol {}

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
    guard
      l != r,
      r != .end,
      l != .end
    else {
      return l != .end && r == .end
    }
    return value_comp(__value_(l), __value_(r))
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
