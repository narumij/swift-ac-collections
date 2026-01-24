//
//  tree_interface+allocator.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/21.
//

@usableFromInline
protocol AllocationInterface: _NodePtrType & _RawValueType {
  /// ノードを構築する
  func __construct_node(_ k: _Value) -> _NodePtr
}

@usableFromInline
protocol DellocationInterface: _NodePtrType {
  /// ノードを破壊する
  func destroy(_ p: _NodePtr)
}
