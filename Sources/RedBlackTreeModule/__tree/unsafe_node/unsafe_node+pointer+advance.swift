//
//  unsafe_node+pointer+advance.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/29.
//

@inlinable
@inline(__always)
internal func
  ___tree_adv_iter(
    _ __x: UnsafeMutablePointer<UnsafeNode>,
    _ __n: Int
  )
  -> UnsafeMutablePointer<UnsafeNode>
{
  var __x = __x
  var __n = __n
  while __n != 0 {
    if __n < 0 {
      let _prev = __tree_prev_iter(__x)
      // nullの場合更新せずにループ終了
      guard !_prev.___is_null else { break }
      __x = _prev
      __n += 1
    } else {
      // endの場合次への操作をせずにループ終了
      guard !__x.___is_end else { break }
      __x = __tree_next_iter(__x)
      __n -= 1
    }
  }
  return __x
}

@inlinable
@inline(__always)
internal func
  ___tree_adv_iter(
    _ __x: UnsafeMutablePointer<UnsafeNode>,
    _ __n: Int,
    _ __l: UnsafeMutablePointer<UnsafeNode>
  )
  -> UnsafeMutablePointer<UnsafeNode>
{
  var __x = __x
  var __n = __n
  while __n != 0, __x != __l {
    if __n < 0 {
      let _prev = __tree_prev_iter(__x)
      // nullの場合更新せずにループ終了
      guard !_prev.___is_null else { break }
      __x = _prev
      __n += 1
    } else {
      // endの場合次への操作をせずにループ終了
      guard !__x.___is_end else { break }
      __x = __tree_next_iter(__x)
      __n -= 1
    }
  }
  return __x
}
