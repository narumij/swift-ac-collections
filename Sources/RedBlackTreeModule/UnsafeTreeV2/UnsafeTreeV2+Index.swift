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

extension UnsafeTreeV2 where Base: ___TreeIndex {

  public typealias Index = UnsafeIndexV2<Base>
  public typealias Pointee = Base.Element

  @inlinable
  @inline(__always)
  internal func makeIndex(sealed: _SealedPtr) -> Index {
    .init(sealed: sealed, tie: tied)
  }
}

extension UnsafeTreeV2 where Base: ___TreeIndex {

  public typealias Indices = UnsafeIndexV2Collection<Base>
}

extension UnsafeTreeV2 where Base: ___TreeIndex {

  public typealias _PayloadValues = RedBlackTreeIteratorV2.Values<Base>
}

extension UnsafeTreeV2 where Base: PairValueTrait & ___TreeIndex {

  public typealias _KeyValues = RedBlackTreeIteratorV2.KeyValues<Base>
}
