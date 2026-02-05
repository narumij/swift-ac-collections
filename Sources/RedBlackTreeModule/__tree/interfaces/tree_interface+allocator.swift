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
protocol AllocationInterface: _NodePtrType & _PayloadValueType {
  /// ノードを構築する
  func __construct_node(_ k: _PayloadValue) -> _NodePtr
}

@usableFromInline
protocol DellocationInterface: _NodePtrType {
  /// ノードを破壊する
  func destroy(_ p: _NodePtr)
}
