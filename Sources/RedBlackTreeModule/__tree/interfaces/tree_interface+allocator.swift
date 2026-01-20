//
//  tree_interface+allocator.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/21.
//


@usableFromInline
protocol AllocatorInterface: _NodePtrType, _ValueType {
  /// ノードを構築する
  func __construct_node(_ k: _Value) -> _NodePtr
}

@usableFromInline
protocol DellocatorInterface: _NodePtrType {
  /// ノードを破棄する
  func destroy(_ p: _NodePtr)
}
