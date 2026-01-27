//
//  unsafe_node+pointer+validation.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/27.
//

@inlinable
@inline(__always)
func ___is_null_or_end__(trackingTag: _TrackingTag) -> Bool {
  // 名前が衝突するしパッケージ名を書きたくないため中継している
  ___is_null_or_end(trackingTag)
}

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  @inlinable
  internal var ___is_garbaged: Bool {
    pointee.isGarbaged
  }

  @inlinable
  internal var ___is_null_or_end: Bool {
    ___is_null_or_end__(trackingTag: pointee.___tracking_tag)
  }

  @usableFromInline
  internal var ___is_slow_begin: Bool {
    __tree_min(__slow_end().__left_) == self
  }

  @usableFromInline
  internal var ___is_null: Bool {
    pointee.___tracking_tag == .nullptr
  }
  
  @usableFromInline
  internal var ___is_end: Bool {
    assert(__parent_ != .nullptr || pointee.___tracking_tag == .end)
    return pointee.___tracking_tag == .end
  }

  @usableFromInline
  internal var ___is_root: Bool {
    __parent_.___is_end
  }
  
  @inlinable
  internal var ___is_subscript_null: Bool {
    // 初期化済みチェックでnullptrとendは除外される
    //    return !___initialized_contains(p) || ___is_garbaged(p)
    // begin -> false
    // end -> true
    return ___is_null_or_end || ___is_garbaged
  }
  
  @inlinable
  internal var ___is_next_null: Bool {
    ___is_subscript_null
  }

  // 事後チェックへの移行という手もある
  internal var ___is_slow_prev_null: Bool {
    return self == .nullptr || ___is_slow_begin || ___is_garbaged
  }
  
  @inlinable
  internal var ___is_offset_null: Bool {
    return self == .nullptr || ___is_garbaged
  }
}
