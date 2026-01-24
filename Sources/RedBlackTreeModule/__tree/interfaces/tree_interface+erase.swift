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

import Foundation

@usableFromInline
protocol EraseInterface: _NodePtrType {
  func erase(_ __p: _NodePtr) -> _NodePtr
  func erase(_ __f: _NodePtr, _ __l: _NodePtr) -> _NodePtr
}

@usableFromInline
protocol EraseUniqueInteface: _KeyType {
  func ___erase_unique(_ __k: _Key) -> Bool
}

@usableFromInline
protocol EraseMultiInteface: _KeyType {
  func ___erase_multi(_ __k: _Key) -> Int
}
