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
public struct UnsafeTreeV2<Base: ___TreeBase> {

  @inlinable
  internal init(_buffer: ManagedBufferPointer<Header, Void>) {
    self._buffer = _buffer
  }

  @usableFromInline var _buffer: BufferPointer
}

extension UnsafeTreeV2 {
  public typealias Base = Base
  public typealias Tree = UnsafeTreeV2<Base>
  public typealias _Key = Base._Key
  public typealias _PayloadValue = Base._PayloadValue
  public typealias _NodePtr = UnsafeMutablePointer<UnsafeNode>
  public typealias _NodeRef = UnsafeMutablePointer<UnsafeMutablePointer<UnsafeNode>>
  @usableFromInline typealias Header = UnsafeTreeV2BufferHeader
  @usableFromInline typealias Buffer = ManagedBuffer<Header, Void>
  @usableFromInline typealias BufferPointer = ManagedBufferPointer<Header, Void>
}

extension UnsafeTreeV2 {

  @inlinable
  package var nullptr: _NodePtr {
    _read { yield withMutableHeader { $0.nullptr } }
  }

  @inlinable
  package var end: _NodePtr {
    withMutableHeader { $0.end_ptr }
  }

  @inlinable
  var isReadOnly: Bool {
    _buffer.buffer === _emptyTreeStorage
  }

  #if COMPATIBLE_ATCODER_2025
    /// 木に紐付いている生バッファ
    ///
    /// - WARNING: 触ると生成されてしまうため不用意に触らないこと
    @usableFromInline
    var tied: _TiedRawBuffer {
      withMutableHeader { $0.tiedRawBuffer }
    }
  #endif

  /// 木に紐付く生バッファを遅延処理するプロクシ
  ///
  /// - WARNING: 触ると生成されてしまうため不用意に触らないこと
  @inlinable
  var lazyDetach: _LazyTie {
    withMutableHeader { $0.lazyDetach }
  }
}

extension UnsafeTreeV2: CustomStringConvertible {
  public var description: String {
    "UnsafeTreeV2<\(Base._PayloadValue.self)>._Storage\(_buffer.header)"
  }
}

extension UnsafeTreeV2 {

  @inlinable
  var count: Int {
    @inline(__always)
    //    get { withMutableHeader { $0.count } }
    _read { yield _buffer.withUnsafeMutablePointerToHeader { $0.pointee.count } }
  }

  @inlinable
  var capacity: Int {
    @inline(__always)
    //    get { withMutableHeader { $0.freshPoolCapacity } }
    _read { yield _buffer.withUnsafeMutablePointerToHeader { $0.pointee.freshPoolCapacity } }
  }

  @inlinable
  var initializedCount: Int { withMutableHeader { $0.freshPoolUsedCount } }
}

extension UnsafeTreeV2 {

  @inlinable
  public var underestimatedCount: Int { count }

  @inlinable
  var freeCapacity: Int {
    withMutableHeader { $0.freshPoolCapacity - $0.count }
  }
}

extension UnsafeTreeV2 {

  @inlinable
  internal subscript(_unsafe_raw pointer: _NodePtr) -> _PayloadValue {
    @inline(__always)
    @_transparent
    unsafeAddress {
      UnsafePointer(pointer.__value_())
    }
    @inline(__always)
    @_transparent
    nonmutating unsafeMutableAddress {
      pointer.__value_()
    }
  }
}

#if COMPATIBLE_ATCODER_2025
  extension UnsafeTreeV2 {

    @inlinable
    internal subscript(_unsafe __safe_ptr_: _SafePtr) -> _PayloadValue {
      @inline(__always)
      @_transparent
      unsafeAddress {
        precondition(__safe_ptr_.___has_payload_content)
        return UnsafePointer(__safe_ptr_.pointer!.__value_())
      }
    }
  }

  extension UnsafeTreeV2 {

    @inlinable
    internal subscript(_unsafe sealed: _SealedPtr) -> _PayloadValue {
      @inline(__always)
      @_transparent
      unsafeAddress {
        let unsealed = sealed.accessible
        precondition(unsealed.error == nil)
        return UnsafePointer(unsealed.pointer!.__value_())
      }
    }
  }
#endif

extension UnsafeTreeV2 {

  // subscript helperなので、__always
  @inlinable
  @inline(__always)
  func _unsafeAddress(_ position: UnsafeIndexV3) -> UnsafePointer<_PayloadValue> {
    return UnsafePointer(_unsafeMutableAddress(position))
  }

  // subscript helperなので、__always
  @inlinable
  @inline(__always)
  func _unsafeMutableAddress(_ position: UnsafeIndexV3) -> UnsafeMutablePointer<_PayloadValue> {
    let sealed: _SealedPtr = __purified_(position)
    precondition(sealed.accessible.error == nil)
    return sealed.pointer!.__value_()
  }

  @inlinable
  internal subscript(_unsafe position: UnsafeIndexV3) -> _PayloadValue {

    @inline(__always)
    @_transparent
    unsafeAddress {
      _unsafeAddress(position)
    }
  }
}

extension UnsafeTreeV2 {

  @inlinable
  internal func deinitialize() {
    withMutableHeader { header in
      header.deinitialize()
    }
  }
}

// MARK: Refresh Pool Iterator

#if DEBUG
  extension UnsafeTreeV2 {

    @inlinable
    func makeUsedNodeIterator() -> _FreshPoolUsedIterator<_PayloadValue> {
      return _buffer.header.makeUsedNodeIterator()
    }
  }
#endif

// MARK: Index Resolver

extension UnsafeTreeV2 {

  @inlinable
  package func __retrieve_(_ tag: _TrackingTag) -> _SafePtr {
    switch tag {
    case .nullptr: .failure(.null)
    case .end: .success(end)
    default: tag < capacity ? .success(_buffer.header[tag]) : .failure(.unknown)
    }
  }

  @inlinable
  package func ___retrieve(tag: _TrackingTagSealing) -> _SealedPtr {
    switch tag {
    case .end:
      return end.uncheckedSeal
    case .tag(let raw, let seal):
      guard raw < capacity else {
        return .failure(.unknown)
      }
      return .success(.uncheckedSeal(_buffer.header[raw], seal))
    }
  }

  /// つながりをたぐりよせる
  ///
  /// 日本人的にはお祭りなどによくある千本引きのイメージ
  @inlinable
  package func __retrieve_(_ tag: _SealedTag) -> _SealedPtr {
    tag.flatMap { ___retrieve(tag: $0) }
  }
}

extension UnsafeTreeV2 {

  /// インデックスをポインタに解決する
  ///
  /// 木が同一の場合、インデックスが保持するポインタを返す。
  /// 木が異なる場合、インデックスが保持するノード番号に対応するポインタを返す。
  @inlinable
  package func __purified_(_ index: _LazyTieWrappedPtr) -> _SealedPtr {
    withMutableHeader { index.__isSameLazyDetach($0._lazyDetach) }
      // 木が同一のケース
      // 中身を取り出し、生存確認を行って返している
      ? index.sealed.purified
      // 木が異なるケース
      // 中身を取り出し、元の木に対して生存確認を行ってからタグを取得
      // タグで該当ポインタを取得
      // 該当ポインタの生存確認を行う（解放確認で十分なところ、実装サボりで生存確認になっていそう）
      // 要は、元の木と現在の木のどちらかで失効している場合、失効ポインタを返す動作
      : __retrieve_(index.sealed.purified.tag).deepPurified
  }

  @inlinable
  internal func __purified_safe_(_ index: _LazyTieWrappedPtr) -> _SafePtr {
    __purified_(index).map(\.pointer)
  }
}

extension UnsafeTreeV2 {

  @inlinable
  internal func __purified_safe_(_raw_range: _RawRange<UnsafeIndexV3>)
    -> _RawRange<_SafePtr>
  {
    .init(
      lowerBound: __purified_safe_(_raw_range.lowerBound),
      upperBound: __purified_safe_(_raw_range.upperBound))
  }

  @inlinable
  internal func __purified_safe_(_ range: UnsafeIndexV3Range)
    -> _RawRange<_SafePtr>
  {
    __purified_safe_(_raw_range: range.range)
  }
}

extension UnsafeTreeV2 {

  @inlinable
  internal func __purified_safe_(_raw_range_expression range: _RawRangeExpression<UnsafeIndexV3>)
    -> _RawRangeExpression<_SafePtr>
  {
    switch range {
    case .range(let from, let to):
      .range(from: __purified_safe_(from), to: __purified_safe_(to))
    case .closedRange(let from, let through):
      .closedRange(from: __purified_safe_(from), through: __purified_safe_(through))
    case .partialRangeTo(let bound):
      .partialRangeTo(__purified_safe_(bound))
    case .partialRangeThrough(let bound):
      .partialRangeThrough(__purified_safe_(bound))
    case .partialRangeFrom(let bound):
      .partialRangeFrom(__purified_safe_(bound))
    case .unboundedRange:
      .unboundedRange
    }
  }

  @inlinable
  internal func __purified_safe_(_ range: UnsafeIndexV3RangeExpression)
    -> _RawRangeExpression<_SafePtr>
  {
    __purified_safe_(_raw_range_expression: range.rangeExpression)
  }
}
