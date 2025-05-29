//
//  RedBlackTreeRawValue.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/05/29.
//

@usableFromInline
protocol RedBlackTreeRawValue {
  var rawValue: _NodePtr { get }
}

@usableFromInline
protocol RedBlackTreeMutableRawValue: RedBlackTreeRawValue {
  var rawValue: _NodePtr { get set }
}
