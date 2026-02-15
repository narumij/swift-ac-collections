//
//  UnsafeIndexV3Range.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/02/15.
//

/// equalRangeの結果オブジェクト
///
// 本当は作りたくなかったが、lowerBoundやupperBoundがオプショナルになるのもいまいちなので、しかたなく。
@frozen
public struct UnsafeIndexV3Range: _UnsafeNodePtrType {

  @inlinable
  @inline(__always)
  internal init(lowerBound: _TieWrappedPtr, upperBound: _TieWrappedPtr) {
    precondition(lowerBound.tied === upperBound.tied)
    self.range = .init(lowerBound: lowerBound, upperBound: upperBound)
  }

  @usableFromInline
  internal var range: _RawRange<_TieWrappedPtr>

  @inlinable
  @inline(__always)
  internal init(_ range: _RawRange<_TieWrappedPtr>) {
    self.range = range
  }
}

// 削除の悩みがつきまとうので、Sequence適合せず、ループはできないようにする
// 当然RangeExpressionなんかには適合しない

extension UnsafeIndexV3Range {

  public var lowerBound: _TieWrappedPtr {
    range.lowerBound
  }

  public var upperBound: _TieWrappedPtr {
    range.upperBound
  }
}

extension UnsafeIndexV3Range {

  package var lower: _TieWrappedPtr {
    range.lowerBound
  }

  package var upper: _TieWrappedPtr {
    range.upperBound
  }
}
