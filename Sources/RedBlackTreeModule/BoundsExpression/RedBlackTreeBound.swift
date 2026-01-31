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

public enum BoundRelativeError: Error {
  /// nullptrに到達した
  ///
  /// 平衡木の下限を超えた操作を行ったことを表す
  case lowerOutOfBounds

  /// endを越えようとした
  ///
  /// 平衡木の上限を超えた操作を行ったことを表す
  case upperOutOfBounds
}

@frozen
public indirect enum RedBlackTreeBound<_Key> {
  case start
  case lower(_Key)
  case upper(_Key)
  case find(_Key)
  case end
  case advanced(Self, by: Int)
  case before(Self)
  case after(Self)
}

extension RedBlackTreeBound {
  public var after: Self { .after(self) }
  public var before: Self { .before(self) }
  public func advanced(by offset: Int) -> Self {
    .advanced(self, by: offset)
  }
}

// TODO: 以下を公開にするかどうかは要再検討

public func start<K>() -> RedBlackTreeBound<K> {
  .start
}

public func end<K>() -> RedBlackTreeBound<K> {
  .end
}

public func lowerBound<K>(_ k: K) -> RedBlackTreeBound<K> {
  .lower(k)
}

public func upperBound<K>(_ k: K) -> RedBlackTreeBound<K> {
  .upper(k)
}

public func find<K>(_ k: K) -> RedBlackTreeBound<K> {
  .find(k)
}
