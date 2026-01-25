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

// MARK: -

@usableFromInline
protocol _TreeNode_KeyProtocol:
  _TreeNode_KeyInterface
    & _TreeRawValue_KeyInterface
    & _TreeNode_RawValueInterface
{}

extension _TreeNode_KeyProtocol {

  #if true
    @inlinable
    @inline(__always)
    internal func __get_value(_ p: _NodePtr) -> _Key {
      __key(__value_(p))
    }
  #else
    @inlinable
    @inline(__always)
    internal func __get_value(_ p: _NodePtr) -> __node_value_type {
      __key(__value_(p))
    }
  #endif
}

@usableFromInline
protocol BeginProtocol: BeginNodeInterface {
  // __begin_node_が圧倒的に速いため
  @available(*, deprecated, renamed: "__begin_node_")
  /// 木の左端のノードを返す
  @inlinable func begin() -> _NodePtr
}

extension BeginProtocol {
  // __begin_node_が圧倒的に速いため
  @available(*, deprecated, renamed: "__begin_node_")
  @inlinable
  @inline(__always)
  /// 木の左端のノードを返す
  internal func begin() -> _NodePtr { __begin_node_ }
}
