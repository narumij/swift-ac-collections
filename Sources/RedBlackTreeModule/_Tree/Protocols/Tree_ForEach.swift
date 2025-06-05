//
//  ___Tree+ForEach.swift
//  swift-ac-collections
//
//  Created by narumij on 2025/06/05.
//

public protocol Tree_ForEach {
  func ___for_each_(__p: _NodePtr, __l: _NodePtr, body: (_NodePtr) throws -> Void)
    rethrows
}
