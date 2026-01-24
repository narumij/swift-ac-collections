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

import Foundation

@usableFromInline
protocol InsertNodeAtInterface: _NodePtrType {
  func __insert_node_at(
    _ __parent: _NodePtr,
    _ __child: _NodeRef,
    _ __new_node: _NodePtr
  )
}

@usableFromInline
protocol InsertUniqueInterface: _NodePtrType & _RawValueType {
  func __insert_unique(_ x: _RawValue) -> (__r: _NodePtr, __inserted: Bool)
  func __emplace_unique_key_args(_ __k: _RawValue) -> (__r: _NodePtr, __inserted: Bool)
}
