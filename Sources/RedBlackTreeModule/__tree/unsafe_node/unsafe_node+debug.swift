// Copyright 2024-2026 narumij
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// This code is based on work originally distributed under the Apache License 2.0 with LLVM Exceptions:
//
// Copyright © 2003-2025 The LLVM Project.
// Licensed under the Apache License, Version 2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by narumij.

#if DEBUG
  extension UnsafeNode {

    @inlinable
    func debugDescription(resolve: (Pointer?) -> Int?) -> String {
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
    package var index: Int { trackingTag }
  }

  extension Optional where Wrapped == UnsafeMutablePointer<UnsafeNode> {
    package var index: Int { self?.trackingTag ?? .nullptr }
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
      assert(___has_payload_content == true)
      guard
        ___tracking_tag == .nullptr,
        __right_ == UnsafeNode.nullptr,
        __right_ == UnsafeNode.nullptr,
        __parent_ == UnsafeNode.nullptr,
        __is_black_ == false,
        // 判定を簡略化するための措置
        ___has_payload_content == true
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
      guard
        ___tracking_tag == .end,
        __right_ == UnsafeNode.nullptr,
        __parent_ == UnsafeNode.nullptr,
        __is_black_ == false,
        // 判定を簡略化するための措置
        ___has_payload_content == true
      else {
        return false
      }
      return true
    }
  }

@usableFromInline nonisolated(unsafe) var nodeInitializedCount = 0
@usableFromInline nonisolated(unsafe) var nodeDeinitializedCount = 0

#endif
