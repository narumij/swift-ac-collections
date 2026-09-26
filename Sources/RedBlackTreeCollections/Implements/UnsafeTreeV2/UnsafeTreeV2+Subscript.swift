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

extension UnsafeTreeV2 {

  // subscript helperなので、__always
  @inlinable
  @inline(__always)
  func _unsafeAddress(_ position: UnsafeIndexV3) -> UnsafePointer<_PayloadValue> {
    return UnsafePointer(_unsafeMutableAddress(position))
  }

  // subscript helperなので、__always
  @inlinable
  @inline(__always)
  func _unsafeMutableAddress(_ position: UnsafeIndexV3) -> UnsafeMutablePointer<_PayloadValue> {
    let sealed: _SealedPtr = __purified_(position)
    precondition(sealed.accessible.error == nil)
    return sealed.pointer!.__value_()
  }
}
