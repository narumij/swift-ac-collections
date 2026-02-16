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

#if !COMPATIBLE_ATCODER_2025

  extension RedBlackTreeDictionary {
    public typealias Bound = RedBlackTreeBoundExpression<Key>
    public typealias BoundRange = RedBlackTreeBoundRangeExpression<Key>
  }

  extension RedBlackTreeDictionary {

    /// 該当する要素を取得可能かどうかの判定結果を返す
    @inlinable
    public func isValid(_ bound: Bound) -> Bool {

      let sealed = bound.evaluate(__tree_)
      return sealed.isValid && !sealed.___is_end!
    }
  }

  extension RedBlackTreeDictionary {

    @inlinable
    public subscript(bound: Bound) -> Element? {

      let p = bound.evaluate(__tree_)
      guard let p = p.pointer, !p.___is_end else { return nil }
      return Base.__element_(__tree_[_unsafe_raw: p])
    }
  }

  extension RedBlackTreeDictionary {

    @inlinable
    public mutating func erase(_ bound: Bound) -> Element? {

      __tree_.ensureUnique()
      let p = bound.evaluate(__tree_)
      guard let p = p.pointer, !p.___is_end else { return nil }
      return Base.__element_(__tree_._unchecked_remove(at: p).payload)
    }
  }

  // MARK: -

  extension RedBlackTreeDictionary {

    /// 該当する要素を取得可能かどうかの判定結果を返す
    ///
    /// これがfalseの場合でもBoundRange関連APIはクラッシュしない
    @inlinable
    public func isValid(_ bounds: BoundRange) -> Bool {
      let range = bounds._evaluate(__tree_).relative(to: __tree_)
      return __tree_.isValidSealedRange(range)
        && range.lowerBound.isValid
        && range.upperBound.isValid
    }
  }

  extension RedBlackTreeDictionary {

    @inlinable
    public subscript(bounds: BoundRange) -> View {

      @inline(__always) get {

        let range = __tree_.sanitizeSealedRange(
          bounds._evaluate(__tree_).relative(to: __tree_))

        return self[unchecked: range]
      }

      @inline(__always) _modify {

        let range = __tree_.sanitizeSealedRange(
          bounds._evaluate(__tree_).relative(to: __tree_))

        yield &self[unchecked: range]
      }
    }
  }

  extension RedBlackTreeDictionary {

    @inlinable
    public mutating func erase(_ bounds: BoundRange) {

      __tree_.ensureUnique()
      let range = __tree_.sanitizeSealedRange(
        bounds._evaluate(__tree_).relative(to: __tree_))
      __tree_.___erase(range.lowerBound.pointer!, range.upperBound.pointer!)
    }

    @inlinable
    public mutating func erase(
      _ bounds: BoundRange, where shouldBeRemoved: (Element) throws -> Bool
    ) rethrows {

      __tree_.ensureUnique()
      let range = __tree_.sanitizeSealedRange(
        bounds._evaluate(__tree_).relative(to: __tree_))
      try __tree_.___erase_if(range.lowerBound, range.upperBound) {
        try shouldBeRemoved($0.tuple)
      }
    }
  }
#endif
