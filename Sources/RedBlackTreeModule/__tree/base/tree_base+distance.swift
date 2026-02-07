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

// TODO: 別のプロトコルにする
// 手抜きをしてしまって、微妙に違うプロトコルにぶら下がっている

public protocol _BaseNode_SignedDistanceInterface: _NodePtrType {
  static func ___signed_distance(_: _NodePtr, _: _NodePtr) -> Int
}

public protocol _BaseNode_SignedDistanceProtocol:
  _UnsafeNodePtrType
    & _BaseNode_SignedDistanceInterface
    & _BaseNode_PtrCompInterface
{}

extension _BaseNode_SignedDistanceProtocol {

  public typealias difference_type = Int

  public typealias _InputIter = _NodePtr

  @inlinable
  @inline(__always)
  public static func
    ___signed_distance(_ __first: _InputIter, _ __last: _InputIter)
    -> difference_type
  {
    guard __first != __last else { return 0 }
    var (__first, __last) = (__first, __last)
    var sign = 1
    if ___ptr_comp(__last, __first) {
      swap(&__first, &__last)
      sign = -1
    }
    return sign * __distance(__first, __last)
  }
}
