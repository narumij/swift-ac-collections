//
//  unsafe_node+pointer+validation.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/27.
//

@inlinable
@inline(__always)
func ___is_null_or_end__(rawIndex: Int) -> Bool {
  // 名前が衝突するしパッケージ名を書きたくないため中継している
  ___is_null_or_end(rawIndex)
}

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  @inlinable
  internal var ___is_garbaged: Bool {
    pointee.isGarbaged
  }

  @inlinable
  internal var ___is_null_or_end: Bool {
    ___is_null_or_end__(rawIndex: pointee.___raw_index)
  }

  @usableFromInline
  internal var ___is_slow_begin: Bool {
    __tree_min(__slow_end().__left_) == self
  }

  @usableFromInline
  internal var ___is_null: Bool {
//    assert(__parent_ != .nullptr || pointee.___raw_index == .end)
    return self == .nullptr
  }
  
  @usableFromInline
  internal var ___is_end: Bool {
    assert(__parent_ != .nullptr || pointee.___raw_index == .end)
    return __parent_ == .nullptr
  }

  @usableFromInline
  internal var ___is_root: Bool {
    __parent_.___is_end
  }
  
  // そもそもチェックとして厳密ではない。garbagedの厳密さが十分ならチェック用かも
  internal func ___initialized_contains(_ initializedCount: Int) -> Bool {
    0..<initializedCount ~= pointee.___raw_index
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
