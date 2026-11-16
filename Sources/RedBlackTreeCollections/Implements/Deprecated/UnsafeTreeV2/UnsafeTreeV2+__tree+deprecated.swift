//
//  UnsafeTreeV2+_tree+deprecated.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/11/16.
//

#if COMPATIBLE_ATCODER_2025
  extension UnsafeTreeV2: _PtrRangeCompBridge where Base: _BaseNode_PtrRangeCompInterface {}
#endif
