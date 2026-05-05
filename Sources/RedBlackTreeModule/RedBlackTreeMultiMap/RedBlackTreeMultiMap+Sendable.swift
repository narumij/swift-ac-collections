//
//  RedBlackTreeMultiMap+Sendable.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/05.
//

extension RedBlackTreeMultiMap: @unchecked Sendable where Key: Sendable, Value: Sendable {}
