//
//  unsafe_tree.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/18.
//

public protocol UnsafeTreePointer: _TreePointer
where
  _NodePtr == UnsafeMutablePointer<UnsafeNode>,
  _NodeRef == UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>
{}
