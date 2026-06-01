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

#if AC_COLLECTIONS_INTERNAL_CHECKS
extension UnsafeTreeV2 {

    /// CoWの発火回数を観察するためのプロパティ
    package var copyCount: UInt {
      get { _buffer.header.copyCount }
      set {
        _buffer.withUnsafeMutablePointerToHeader {
          $0.pointee.copyCount = newValue
        }
      }
    }
}
#endif

// MARK: Refresh Pool Iterator


#if DEBUG
  extension UnsafeTreeV2 {
    /// 木に紐付く生バッファを遅延処理するプロクシ
    ///
    /// - WARNING: 触ると生成されてしまうため不用意に触らないこと
    @inlinable
    var lazyDetach: _LazyTie {
      withMutableHeader { $0.lazyDetach }
    }
  }
#endif
