//
//  unsafe_tree.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/18.
//

/// ポインタベースの木の基本型定義
public protocol _UnsafeNodePtrType: _NodePtrType
where
  _NodePtr == UnsafeMutablePointer<UnsafeNode>,
  _NodeRef == UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>
{}
