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

    @inlinable
    func debugDescription(resolve: (Pointer?) -> _TrackingTag?) -> String {
      let id = ___tracking_tag
      let l = resolve(__left_)
      let r = resolve(__right_)
      let p = resolve(__parent_)
      let color = __is_black_ ? "B" : "R"
      #if DEBUG || true
        let rc = ___recycle_count
      #else
        let rc = -1
      #endif

      return """
        - node[\(id)] \(color)
          L: \(l.map(String.init) ?? "nil")
          R: \(r.map(String.init) ?? "nil")
          P: \(p.map(String.init) ?? "nil")
          needsDeinit: \(___has_payload_content)
          recycleCount: \(rc)
        """
    }
  }

  extension UnsafeMutablePointer where Pointee == UnsafeNode {
    package var index: _TrackingTag { trackingTag }
  }

  extension UnsafeNode {

    @inlinable
    package func equiv(with tree: UnsafeNode) -> Bool {
      assert(___tracking_tag == tree.___tracking_tag)
      assert(__left_.pointee.___tracking_tag == tree.__left_.pointee.___tracking_tag)
      assert(__right_.pointee.___tracking_tag == tree.__right_.pointee.___tracking_tag)
      assert(__parent_.pointee.___tracking_tag == tree.__parent_.pointee.___tracking_tag)
      assert(__is_black_ == tree.__is_black_)
      assert(___has_payload_content == tree.___has_payload_content)
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

    @inlinable
    package func nullCheck() -> Bool {
      assert(___tracking_tag == .nullptr)
      assert(__left_ == UnsafeNode.nullptr)
      assert(__right_ == UnsafeNode.nullptr)
      assert(__parent_ == UnsafeNode.nullptr)
      assert(__is_black_ == false)
      assert(___has_payload_content == false)
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

    @inlinable
    package func endCheck() -> Bool {
      assert(___tracking_tag == .end)
      assert(__right_ == UnsafeNode.nullptr)
      assert(__parent_ == UnsafeNode.nullptr)
      assert(__is_black_ == false)
      assert(___has_payload_content == false)
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
