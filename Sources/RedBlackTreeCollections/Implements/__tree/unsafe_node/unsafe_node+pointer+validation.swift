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

extension UnsafeMutablePointer where Pointee == UnsafeNode {

  @inlinable
  internal var ___is_null_or_end: Bool {
    pointee.___tracking_tag < 0
  }

  @inlinable
  internal var ___is_null: Bool {
    pointee.___tracking_tag == .nullptr
  }

  @inlinable
  internal var ___is_end: Bool {
    pointee.___tracking_tag == .end
  }

  #if false
    @inlinable
    internal var ___is_garbaged: Bool {
      !pointee.___has_payload_content
    }
  #endif

  @inlinable
  internal var ___is_root: Bool {
    __parent_.___is_end
  }
}
