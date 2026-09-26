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

@usableFromInline
protocol EraseInterface: _NodePtrType {
  @inlinable func erase(_ __p: _NodePtr) -> _NodePtr
  @inlinable func erase(_ __f: _NodePtr, _ __l: _NodePtr) -> _NodePtr
}

@usableFromInline
protocol EraseUniqueInteface: _KeyType {
  // llvmにも同じものがいるので、3本アンスコは間違い
  // こっちはまだ戻りが違うのでわかる
  @inlinable func ___erase_unique(_ __k: _Key) -> Bool
}

@usableFromInline
protocol EraseMultiInteface: _KeyType {
  // llvmにも同じものがいるので、3本アンスコは間違い
  // 特にこっち。なんで3本にしたのか謎
  @inlinable func ___erase_multi(_ __k: _Key) -> Int
}
