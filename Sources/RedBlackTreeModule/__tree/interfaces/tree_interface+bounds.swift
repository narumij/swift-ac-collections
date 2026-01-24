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

/// 2025年のシンプル化で代表格となったもの
@usableFromInline
protocol BoundInteface: _NodePtrType & _KeyType {
  func lower_bound(_ __v: _Key) -> _NodePtr
  func upper_bound(_ __v: _Key) -> _NodePtr
}

/// 2025年の改善で増えたもの
@usableFromInline
protocol BoundBothInterface: _NodePtrType & _KeyType {
  func __lower_bound_unique(_ __v: _Key) -> _NodePtr
  func __upper_bound_unique(_ __v: _Key) -> _NodePtr
  func __lower_bound_multi(_ __v: _Key) -> _NodePtr
  func __upper_bound_multi(_ __v: _Key) -> _NodePtr
}

/// 昔からあるBoundインターフェースと同じシグネチャのもの
@usableFromInline
protocol BoundBasicInterface: _NodePtrType & _KeyType {
  func __lower_bound_multi(_ __v: _Key, _ __root: _NodePtr, _ __result: _NodePtr) -> _NodePtr
  func __upper_bound_multi(_ __v: _Key, _ __root: _NodePtr, _ __result: _NodePtr) -> _NodePtr
}
