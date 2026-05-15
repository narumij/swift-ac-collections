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

/// equalRangeの結果オブジェクト
///
// 本当は作りたくなかったが、lowerBoundやupperBoundがオプショナルになるのもいまいちなので、しかたなく。
@frozen
public struct UnsafeIndexV3Range {

  @usableFromInline
  internal var range: _RawRange<UnsafeIndexV3>

  @inlinable
  @inline(__always)
  internal init(_ range: _RawRange<UnsafeIndexV3>) {
    self.range = range
  }
}

// 削除の悩みがつきまとうので、Sequence適合せず、ループはできないようにする
// 当然RangeExpressionなんかには適合しない
// CoW発生を極力抑えることが赤黒木を活かすカギなので、Copyが多発するような使い方への誘導を減らす方針

extension UnsafeIndexV3Range {

  public var lowerBound: UnsafeIndexV3 {
    range.lowerBound
  }

  public var upperBound: UnsafeIndexV3 {
    range.upperBound
  }
}
