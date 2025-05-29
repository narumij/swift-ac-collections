//
//  RedBlackTreeIndex.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/05/29.
//

@usableFromInline
protocol RedBlackTreeIndex: Strideable & RedBlackTreeMutableRawValue where Stride == Int {
  associatedtype Tree
  associatedtype Element // クリーンビルド時に一度失敗するケースの回避
  init(__tree: Tree, rawValue: _NodePtr)
}
