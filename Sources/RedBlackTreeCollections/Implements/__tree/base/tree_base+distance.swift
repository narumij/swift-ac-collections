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

public protocol _BaseNode_SignedDistanceInterface: ~Copyable, _NodePtrType {
  static func ___signed_distance(_: _NodePtr, _: _NodePtr) -> Int
  static func ___signed_safe_distance(_: _NodePtr, _: _NodePtr) -> Result<Int, SealError>
  static func ___signed_stable_distance(_: _NodePtr, _: _NodePtr) -> Int
  static func ___signed_bitmap64_distance(_: _NodePtr, _: _NodePtr) -> Int
  static func ___signed_bitmap128_distance(_: _NodePtr, _: _NodePtr) -> Int
}

public protocol _BaseNode_SignedDistanceProtocol: ~Copyable,
  _UnsafeNodePtrType
    & _BaseNode_SignedDistanceInterface
    & _BaseNode_PtrCompInterface
where
  difference_type == Int,
  _InputIter == _NodePtr
{
  associatedtype difference_type
  associatedtype _InputIter
}

extension _BaseNode_SignedDistanceProtocol where Self: ~Copyable {

//  @available(*, deprecated, renamed: "___signed_safe_distance") // 調査用
  @inlinable
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
    return sign &* __distance(__first, __last)
  }
  
  @inlinable
  public static func
    ___signed_safe_distance(_ __first: _InputIter, _ __last: _InputIter)
    -> Result<difference_type, SealError>
  {
    guard __first != __last else { return .success(0) }
    var (__first, __last) = (__first, __last)
    var sign = 1
    if ___ptr_comp(__last, __first) {
      swap(&__first, &__last)
      sign = -1
    }
    return ___safe_distance(__first, __last).map { sign &* $0 }
  }
  
  @inlinable
  public static func
    ___signed_stable_distance(_ __first: _InputIter, _ __last: _InputIter)
    -> difference_type
  {
    guard __first != __last else { return 0 }
    var (__first, __last) = (__first, __last)
    var sign = 1
    if ___ptr_comp_multi(__last, __first) {
      swap(&__first, &__last)
      sign = -1
    }
    return __distance(__first, __last) &* sign
  }
  
  @inlinable
  public static func
    ___signed_bitmap64_distance(_ __first: _InputIter, _ __last: _InputIter)
    -> difference_type
  {
    guard __first != __last else { return 0 }
    var (__first, __last) = (__first, __last)
    var sign = 1
    if __last.___ptr_bitmap_64() < __first.___ptr_bitmap_64() {
      swap(&__first, &__last)
      sign = -1
    }
    return __distance(__first, __last) &* sign
  }
  
  @inlinable
  public static func
    ___signed_bitmap128_distance(_ __first: _InputIter, _ __last: _InputIter)
    -> difference_type
  {
    guard __first != __last else { return 0 }
    var (__first, __last) = (__first, __last)
    var sign = 1
    if __last.___ptr_bitmap_128() < __first.___ptr_bitmap_128() {
      swap(&__first, &__last)
      sign = -1
    }
    return __distance(__first, __last) &* sign
  }
}
