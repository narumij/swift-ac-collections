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
protocol FindEqualInterface: _NodePtrType & _KeyType {
  func __find_equal(_ __v: _Key) -> (__parent: _NodePtr, __child: _NodeRef)
}

@usableFromInline
protocol FindInteface: _NodePtrType & _KeyType {
  func find(_ __v: _Key) -> _NodePtr
}
