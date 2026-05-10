//
//  UnsafeIndexV3Range+Testing.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/10.
//

#if DEBUG
  @testable import RedBlackTreeModule
  // 互換維持の為のコード。互換廃止の際に削ること

  import RedBlackTreeModule

  extension UnsafeIndexV3Range {

    package var lower: _TieWrappedPtr {
      range.lowerBound
    }

    package var upper: _TieWrappedPtr {
      range.upperBound
    }
  }
#endif
