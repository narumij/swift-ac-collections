//
//  tree_interface+bounds.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/18.
//

/// 2025年のシンプル化で代表格となったもの
@usableFromInline
protocol BoundInteface: _NodePtrType & _KeyType {
  func lower_bound(_ __v: _Key) -> _NodePtr
  func upper_bound(_ __v: _Key) -> _NodePtr
}

/// 2025年の改善で増えたもの
@usableFromInline
protocol BoundBothInterface: _NodePtrType & _KeyType {
  func __lower_bound_unique(_ __v: _Key) -> _NodePtr
  func __upper_bound_unique(_ __v: _Key) -> _NodePtr
  func __lower_bound_multi(_ __v: _Key) -> _NodePtr
  func __upper_bound_multi(_ __v: _Key) -> _NodePtr
}

/// 昔からあるBoundインターフェースと同じシグネチャのもの
@usableFromInline
protocol BoundBasicInterface: _NodePtrType & _KeyType {
  func __lower_bound_multi(_ __v: _Key, _ __root: _NodePtr, _ __result: _NodePtr) -> _NodePtr
  func __upper_bound_multi(_ __v: _Key, _ __root: _NodePtr, _ __result: _NodePtr) -> _NodePtr
}
