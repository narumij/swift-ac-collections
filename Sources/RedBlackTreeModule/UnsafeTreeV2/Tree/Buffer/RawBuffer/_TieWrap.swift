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

/// 結束バンド
@frozen
public struct _TieWrap<RawValue> {

  @usableFromInline let rawValue: RawValue

  @usableFromInline let tied: _TiedRawBuffer

  @inlinable @inline(__always)
  init(rawValue: RawValue, tie: _TiedRawBuffer) {
    self.rawValue = rawValue
    self.tied = tie
  }
}

extension _TieWrap: Equatable where RawValue: Equatable {
  
  public static func == (lhs: _TieWrap<RawValue>, rhs: _TieWrap<RawValue>) -> Bool {
    lhs.rawValue == rhs.rawValue && lhs.tied.end_ptr == rhs.tied.end_ptr
  }
}

extension _TieWrap where RawValue == _NodePtrSealing {

  @inlinable @inline(__always)
  var purified: Result<Self, SealError> {
    rawValue.isUnsealed ? .failure(.unsealed) : .success(self)
  }
}

extension _NodePtrSealing {

  // 某バンドオマージュ
  
  @inlinable
  func band(_ tie: _TiedRawBuffer) -> _TiedPtr {
    isUnsealed ? .failure(.unsealed) : .success(.init(rawValue: self, tie: tie))
  }
}

//extension Result where Success == UnsafeMutablePointer<UnsafeNode>, Failure == SealError {
//
//  // 某バンドオマージュ
//
//  @inlinable
//  func band(_ tie: _TiedRawBuffer) -> _TiedPtr {
//    sealed.flatMap { $0.band(tie) }
//  }
//}

extension Result where Success == _NodePtrSealing, Failure == SealError {

  // 某バンドオマージュ

  @inlinable
  func band(_ tie: _TiedRawBuffer) -> _TiedPtr {
    flatMap { $0.band(tie) }
  }
}

extension Result where Success == _TieWrap<_NodePtrSealing>, Failure == SealError {

  @inlinable
  var tied: _TiedRawBuffer! {
    try? map(\.tied).get()
  }
}
