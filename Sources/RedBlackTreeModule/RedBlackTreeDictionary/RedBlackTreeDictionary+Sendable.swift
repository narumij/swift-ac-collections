//
//  RedBlackTreeDictionary+Sendable.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/05.
//

// MARK: - Sendable

#if swift(>=5.5)
  extension RedBlackTreeDictionary: @unchecked Sendable
  where Key: Sendable, Value: Sendable {}
#endif
