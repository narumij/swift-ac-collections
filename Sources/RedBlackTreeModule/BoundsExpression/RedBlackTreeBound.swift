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

@frozen
public indirect enum RedBlackTreeBound<_Key> {
  case start
  case lower(_Key)
  case upper(_Key)
  case end
  case advanced(Self, by: Int)
  case prev(Self)
  case next(Self)
}

extension RedBlackTreeBound {
  public var next: Self { .next(self) }
  public var prev: Self { .prev(self) }
  public func advanced(by offset: Int) -> Self {
    .advanced(self, by: offset)
  }
}

// TODO: 以下を公開にするかどうかは要再検討

public func end<K>() -> RedBlackTreeBound<K> {
  .end
}

public func lowerBound<K>(_ k: K) -> RedBlackTreeBound<K> {
  .lower(k)
}

public func upperBound<K>(_ k: K) -> RedBlackTreeBound<K> {
  .upper(k)
}

public func start<K>() -> RedBlackTreeBound<K> {
  .start
}

public func next<K>(_ b: RedBlackTreeBound<K>) -> RedBlackTreeBound<K> {
  .next(b)
}

public func prev<K>(_ b: RedBlackTreeBound<K>) -> RedBlackTreeBound<K> {
  .prev(b)
}

public func advanced<K>(_ b: RedBlackTreeBound<K>, by offset: Int) -> RedBlackTreeBound<K> {
  .advanced(b, by: offset)
}
