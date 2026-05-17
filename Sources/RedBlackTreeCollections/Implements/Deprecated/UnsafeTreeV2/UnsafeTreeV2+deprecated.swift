//
//  UnsafeTreeV2+deprecated.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/10.
//


// MARK: - COMPATIBLE_ATCODER_2025用

#if COMPATIBLE_ATCODER_2025
  extension UnsafeTreeV2 {

    @inlinable
    internal func __purified_(_ index: UnsafeIndexV2<Base>) -> _SealedPtr
    where Index.Tree == UnsafeTreeV2, Index._NodePtr == _NodePtr {
      tied === index.tied
        ? index.sealed.purified
        : __retrieve_(index.sealed.purified.tag).purified
    }
  }
#endif
