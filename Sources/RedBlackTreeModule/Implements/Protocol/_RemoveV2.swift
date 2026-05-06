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
protocol _RemoveV2: UnsafeMutableTreeRangeBaseInterfaceV2, _PayloadValueBride {}

extension _RemoveV2 {

  @discardableResult
  @inlinable @inline(__always)
  package mutating func ___remove_first() -> (__r: _NodePtr, payload: _PayloadValue)? {
    guard _start != _end else { return nil }
    return __tree_._unchecked_remove(at: _start)
  }

  @discardableResult
  @inlinable @inline(__always)
  package mutating func ___remove_last() -> (__r: _NodePtr, payload: _PayloadValue)? {
    guard _start != _end else { return nil }
    return __tree_._unchecked_remove(at: __tree_.__tree_prev_iter(_end))
  }
}
