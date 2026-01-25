
// ノードの高さを数える
@inlinable
@inline(__always)
internal func ___ptr_height(_ __p: UnsafeMutablePointer<UnsafeNode>) -> Int {
  assert(!__p.___is_null, "Node shouldn't be null")
  var __h = 0
  var __p = __p
  while !__p.___is_root {
    __p = __p.__parent_
    __h += 1
  }
  return __h
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
