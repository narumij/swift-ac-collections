//
//  unsafe_node+pointer+advance.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/29.
//

@inlinable
@inline(__always)
internal func
  ___tree_adv_iter(_ __x: UnsafeMutablePointer<UnsafeNode>, _ __n: Int)
  -> SafePtr
{
  var __x: SafePtr = .success(__x)

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
  ___tree_next_iter(_ __x: UnsafeMutablePointer<UnsafeNode>) -> SafePtr
{
  // endへの操作は失敗
  __x.___is_end ? .failure(.upperOutOfBounds) : .success(__tree_next_iter(__x))
}

/// Returns:  pointer to the previous in-order node before `__x`.
/// Note: `__x` may be the end node.
@inlinable
@inline(__always)
internal func
  ___tree_prev_iter(_ __x: UnsafeMutablePointer<UnsafeNode>) -> SafePtr
{
  let __x = __tree_prev_iter(__x)
  // nullptrの発生は失敗
  return __x.___is_null ? .failure(.lowerOutOfBounds) : .success(__x)
}

public enum SafePtrError: Error {
  case null
  case garbaged
  case unknown

  /// nullptrに到達した
  ///
  /// 平衡木の下限を超えた操作を行ったことを表す
  case lowerOutOfBounds

  /// endを越えようとした
  ///
  /// 平衡木の上限を超えた操作を行ったことを表す
  case upperOutOfBounds
}

public typealias SafePtr = Result<UnsafeMutablePointer<UnsafeNode>, SafePtrError>
