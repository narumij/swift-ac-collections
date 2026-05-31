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

  #if AC_COLLECTIONS_INTERNAL_CHECKS
    /// CoWの発火回数を観察するためのプロパティ
    package var copyCount: UInt {
      get { _buffer.header.copyCount }
      set {
        _buffer.withUnsafeMutablePointerToHeader {
          $0.pointee.copyCount = newValue
        }
      }
    }
  #endif
}

// MARK: -

extension UnsafeTreeV2 {

  #if DEBUG
    func dumpTree(label: String = "") {
      print("==== UnsafeTree \(label) ====")
      print(" count:", count)
      print(" freshPool:", _buffer.header.freshPoolActualCount, "/", capacity)
      print(" destroyCount:", _buffer.header.recycleCount)
      print(" root:", __root.pointee.___tracking_tag as Any)
      print(" begin:", __begin_node_.pointee.___tracking_tag as Any)

      var it = makeUsedNodeIterator()
      while let p = it.next() {
        print(
          p.pointee.dumpNode()
        )
      }
      print("============================")
    }
  #endif
}

// MARK: Refresh Pool Iterator

#if DEBUG
  extension UnsafeTreeV2 {

    @inlinable
    func makeUsedNodeIterator() -> _FreshPoolUsedIterator<_PayloadValue> {
      return _buffer.header.makeUsedNodeIterator()
    }
  }
#endif

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
