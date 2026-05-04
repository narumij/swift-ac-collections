//
//  RedBlackTreeMultiSet+Sendable.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/05.
//

// MARK: - Sendable

#if swift(>=5.5)
  extension RedBlackTreeMultiSet: @unchecked Sendable
  where Element: Sendable {}
#endif
