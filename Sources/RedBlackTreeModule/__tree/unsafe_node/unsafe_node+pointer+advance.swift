//
//  unsafe_node+pointer+advance.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/29.
//

/// NOTE:
/// The naming here intentionally leans toward a slightly poetic / fantasy-inspired style.
/// Apologies if it feels a bit overdone — it helps convey the intended semantics.
@frozen
public struct _NodePtrElementalSeal: Equatable {
  @usableFromInline var pointer: UnsafeMutablePointer<UnsafeNode>
  @usableFromInline var gen: UInt32
  @inlinable
  init(_ p: UnsafeMutablePointer<UnsafeNode>) {
    pointer = p
    gen = p.pointee.___recycle_count
  }
  @inlinable
  var isBlessing: Bool {
    pointer.pointee.___recycle_count == gen
  }
  @inlinable
  var ___is_end: Bool {
    pointer.___is_end
  }
  @inlinable
  var ___is_garbaged: Bool {
    pointer.___is_garbaged
  }
  @inlinable
  var trackingTag: Int {
    pointer.trackingTag
  }
}

public typealias SafePtr = Result<_NodePtrElementalSeal, SafePtrError>

@inlinable
func success(_ p: UnsafeMutablePointer<UnsafeNode>) -> SafePtr {
  .success(.init(p))
}

@inlinable
@inline(__always)
internal func
  ___tree_next_iter(_ __x: UnsafeMutablePointer<UnsafeNode>) -> SafePtr
{
  __x.___is_end
    // endへの操作は失敗
    ? .failure(.upperOutOfBounds)
    : success(__tree_next_iter(__x))
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
  return __x.___is_null
    ? .failure(.lowerOutOfBounds)
    : success(__x)
}

@inlinable
@inline(__always)
internal func
  ___tree_adv_iter(_ __x: UnsafeMutablePointer<UnsafeNode>, _ __n: Int)
  -> SafePtr
{
  var __x: SafePtr = success(__x)

  var __n = __n
  if __n < 0 {
    while __n != 0 {
      __x = __x.flatMap { ___tree_prev_iter($0.pointer) }
      __n += 1
    }
  } else {
    while __n != 0 {
      __x = __x.flatMap { ___tree_next_iter($0.pointer) }
      __n -= 1
    }
  }

  return __x
}

@inlinable
@inline(__always)
internal func
  ___tree_adv_iter(_ __x: UnsafeMutablePointer<UnsafeNode>, _ __n: Int, _ __l: SafePtr)
  -> SafePtr
{
  var __x: SafePtr = success(__x)

  var __n = __n
  if __n < 0 {
    while __n != 0 {
      guard __x != __l else { return .failure(.limit) }
      __x = __x.flatMap { ___tree_prev_iter($0.pointer) }
      __n += 1
    }
  } else {
    while __n != 0 {
      guard __x != __l else { return .failure(.limit) }
      __x = __x.flatMap { ___tree_next_iter($0.pointer) }
      __n -= 1
    }
  }

  return __x
}

public enum SafePtrError: Error {
  case null
  case garbaged
  case unknown
  case limit
  case notAllowed

  /// nullptrに到達した
  ///
  /// 平衡木の下限を超えた操作を行ったことを表す
  case lowerOutOfBounds

  /// endを越えようとした
  ///
  /// 平衡木の上限を超えた操作を行ったことを表す
  case upperOutOfBounds
}

extension Result
where
  Success == _NodePtrElementalSeal,
  Failure == SafePtrError
{
  var checked: Result {
    self.flatMap { _node_ptr in
      // validなpointerがendやnullに変化することはない
      _node_ptr.pointer.___is_garbaged
        ? .failure(.garbaged)
        : .success(_node_ptr)
    }
  }
}
