//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project
//
// Copyright (c) 2024 - 2026 narumij.
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.
//
//===----------------------------------------------------------------------===//

@usableFromInline
package protocol TreeAlgorithmBaseInterface: _NodePtrType {
  func __tree_is_left_child(_ __x: _NodePtr) -> Bool
//  func __tree_sub_invariant(_ __x: _NodePtr) -> UInt
  func __tree_invariant(_ __root: _NodePtr) -> Bool
  func __tree_min(_ __x: _NodePtr) -> _NodePtr
  func __tree_max(_ __x: _NodePtr) -> _NodePtr
  func __tree_next(_ __x: _NodePtr) -> _NodePtr
  func __tree_next_iter(_ __x: _NodePtr) -> _NodePtr
  func __tree_prev_iter(_ __x: _NodePtr) -> _NodePtr
  func __tree_leaf(_ __x: _NodePtr) -> _NodePtr
}

@usableFromInline
protocol TreeAlgorithmInterface: _NodePtrType {
  func __tree_left_rotate(_ __x: _NodePtr)
  func __tree_right_rotate(_ __x: _NodePtr)
  func __tree_balance_after_insert(_ __root: _NodePtr, _ __x: _NodePtr)
  func __tree_remove(_ __root: _NodePtr, _ __z: _NodePtr)
}
