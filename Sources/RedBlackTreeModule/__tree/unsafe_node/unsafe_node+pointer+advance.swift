//
//  unsafe_node+pointer+advance.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/29.
//

@inlinable
@inline(__always)
internal func
  ___unchecked_tree_adv_iter(
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
    _ __n: Int
  )
  -> Result<
    UnsafeMutablePointer<UnsafeNode>,
    BoundRelativeError
  >
{
  typealias ResultType = Result<
    UnsafeMutablePointer<UnsafeNode>,
    BoundRelativeError
  >

  var __x: ResultType = .success(__x)

  var __n = __n
  if __n < 0 {
    while __n != 0 {
      __x = __x.flatMap { ___tree_prev_iter($0) }
      __n += 1
    }
  } else {
    while __n != 0 {
      __x = __x.flatMap { ___tree_next_iter($0) }
      __n -= 1
    }
  }

  return __x
}

@inlinable
@inline(__always)
internal func
  ___tree_next_iter(_ __x: UnsafeMutablePointer<UnsafeNode>)
  -> Result<
    UnsafeMutablePointer<UnsafeNode>,
    BoundRelativeError
  >
{
  // endへの操作は失敗
  __x.___is_end ? .failure(.upperOutOfBounds) : .success(__tree_next_iter(__x))
}

/// Returns:  pointer to the previous in-order node before `__x`.
/// Note: `__x` may be the end node.
@inlinable
@inline(__always)
internal func
  ___tree_prev_iter(_ __x: UnsafeMutablePointer<UnsafeNode>)
  -> Result<
    UnsafeMutablePointer<UnsafeNode>,
    BoundRelativeError
  >
{
  let __x = __tree_prev_iter(__x)
  // nullptrの発生は失敗
  return __x.___is_null ? .failure(.lowerOutOfBounds) : .success(__x)
}
