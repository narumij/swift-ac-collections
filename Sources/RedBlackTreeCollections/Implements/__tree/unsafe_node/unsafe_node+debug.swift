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

#if DEBUG
  extension UnsafeNode {

    @usableFromInline
    package func equiv(with tree: UnsafeNode) -> Bool {
      guard
        ___tracking_tag == tree.___tracking_tag,
        __left_.pointee.___tracking_tag == tree.__left_.pointee.___tracking_tag,
        __right_.pointee.___tracking_tag == tree.__right_.pointee.___tracking_tag,
        __parent_.pointee.___tracking_tag == tree.__parent_.pointee.___tracking_tag,
        __is_black_ == tree.__is_black_,
        ___has_payload_content == tree.___has_payload_content
      else {
        return false
      }
      return true
    }
  }

  extension UnsafeNode {

    @usableFromInline
    package func nullCheck() -> Bool {
      guard
        ___tracking_tag == .nullptr,
        __right_ == UnsafeNode.nullptr,
        __right_ == UnsafeNode.nullptr,
        __parent_ == UnsafeNode.nullptr,
        __is_black_ == false,
        ___has_payload_content == false
      else {
        return false
      }
      return true
    }

    @usableFromInline
    package func endCheck() -> Bool {
      guard
        ___tracking_tag == .end,
        __right_ == UnsafeNode.nullptr,
        __parent_ == UnsafeNode.nullptr,
        __is_black_ == false,
        ___has_payload_content == false
      else {
        return false
      }
      return true
    }
  }

  @usableFromInline nonisolated(unsafe) var nodeInitializedCount = 0
  @usableFromInline nonisolated(unsafe) var nodeDeinitializedCount = 0

  @usableFromInline nonisolated(unsafe) var payloadInitializedCount = 0
  @usableFromInline nonisolated(unsafe) var payloadDeinitializedCount = 0
#endif
