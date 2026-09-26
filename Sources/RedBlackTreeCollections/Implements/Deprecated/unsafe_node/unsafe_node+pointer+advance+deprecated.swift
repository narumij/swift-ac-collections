//
//  unsafe_node+pointer+advance+deprecated.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/15.
//


#if COMPATIBLE_ATCODER_2025
  @inlinable
  internal func ___form_index(
    _ i: UnsafeMutablePointer<UnsafeNode>, offsetBy distance: Int, limitedBy limit: _SafePtr,
    _ body: (_SafePtr) -> Void
  )
    -> Bool
  {
    let advanced = ___tree_adv_iter(i, distance, limit)
    switch advanced {
    case .success:
      body(advanced)
      return true
    case .failure(.limit):
      body(limit)
      return false
    default:
      return false
    }
  }
#endif
