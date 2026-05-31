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
    func dumpNode() -> String {
      let id = ___tracking_tag
      let l = __left_ == .nullptr ? nil : __left_.pointee.___tracking_tag
      let r = __right_ == .nullptr ? nil : __right_.pointee.___tracking_tag
      let p = __parent_ == .nullptr ? nil : __parent_.pointee.___tracking_tag
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
#endif
