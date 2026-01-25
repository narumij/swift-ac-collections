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

@usableFromInline
protocol PointerCompareInterface: _NodePtrType {
  func ___ptr_comp(_ l: _NodePtr, _ r: _NodePtr) -> Bool
}

public protocol IsMultiTraitInterface {
  var isMulti: Bool { get }
}

@usableFromInline
protocol CompareMultiInterface: _NodePtrType {
  func ___ptr_comp_multi(_ __l: _NodePtr, _ __r: _NodePtr) -> Bool
}

@usableFromInline
protocol NodeBitmapInterface: _NodePtrType {
  func ___ptr_comp_bitmap(_ __l: _NodePtr, _ __r: _NodePtr) -> Bool
}
