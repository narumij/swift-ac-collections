//
//  RedBlackTreeSet+Sendable.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/04.
//

// MARK: - Sendable

#if swift(>=5.5)
  extension RedBlackTreeSet: @unchecked Sendable where Element: Sendable {}
#endif
