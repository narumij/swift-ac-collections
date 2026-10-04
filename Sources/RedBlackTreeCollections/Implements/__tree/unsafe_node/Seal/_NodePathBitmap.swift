//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project.
//
// Copyright (c) 2024-2026 narumij.
// Licensed under the Apache License v2.0.
//
// SPDX-License-Identifier: Apache-2.0
//
// This implementation includes code derived from LLVM libc++'s red-black tree
// implementation, originally distributed under the Apache License v2.0 with
// LLVM Exceptions.
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by
// narumij.
//
//===----------------------------------------------------------------------===//

// 同一木のノードの比較であることが不変条件
// ノードさえ生きてれば比較自体は可能だが未定義動作
@usableFromInline
package enum _NodePathBitmap {

  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>

  #if USE_INT128
    public typealias NodePathBitmap = UInt128
  #else
    public typealias NodePathBitmap = UInt64
  #endif

  case path(NodePathBitmap)
  case end

  @inlinable
  package init(_ p: _NodePtr) {
    self = p.___is_end ? .end : .path(p.___ptr_bitmap())
  }
}

extension _NodePathBitmap: Comparable {}

extension _NodePathBitmap {
  
  @inlinable
  package static func lessThan(
    lhs: (node: UnsafeMutablePointer<UnsafeNode>, bitmap: _NodePathBitmap?),
    rhs: (node: UnsafeMutablePointer<UnsafeNode>, bitmap: _NodePathBitmap?)
  )
    -> (
      result: Bool,
      lhsBitmap: _NodePathBitmap?,
      rhsBitmap: _NodePathBitmap?
    )
  {
    let lhsBitmap = lhs.bitmap ?? _NodePathBitmap(lhs.node)
    let rhsBitmap = rhs.bitmap ?? _NodePathBitmap(rhs.node)
    return (lhsBitmap < rhsBitmap, lhsBitmap, rhsBitmap)
  }
}

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  #if USE_INT128
    @available(macOS 15.0, *)
    @inlinable
    internal func ___ptr_bitmap() -> UInt128 {
      ___ptr_bitmap_128()
    }
  #else
    @inlinable
    internal func ___ptr_bitmap() -> UInt64 {
      ___ptr_bitmap_64()
    }
  #endif
}
