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
    withMutableHeader { $0.nullptr }
  }

  @inlinable
  package var end: _NodePtr {
    withMutableHeader { $0.end_ptr }
  }

  @inlinable
  var isReadOnly: Bool {
    _buffer.buffer === _emptyTreeStorage
  }

  /// 木に紐付いている生バッファ
  ///
  /// - WARNING: 触ると生成されてしまうため不用意に触らないこと
  @usableFromInline
  var tied: _TiedRawBuffer {
    // コンパイラ最適化に頼らないためにベタ書き
    _buffer.buffer === _emptyTreeStorage
      ? _emptyRawBuffer : withMutableHeader { $0.tiedRawBuffer }
  }

  /// 木に紐付く生バッファを遅延処理するプロクシ
  ///
  /// - WARNING: 触ると生成されてしまうため不用意に触らないこと
  @usableFromInline
  var lazyDetach: _LazyDetach {
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

extension UnsafeTreeV2 {

  @inlinable
  internal subscript(_unsafe sealed: _SealedPtr) -> _PayloadValue {
    @inline(__always)
    @_transparent
    unsafeAddress {
      precondition(sealed.exists)
      return UnsafePointer(sealed.pointer!.__value_())
    }
  }
}

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
    precondition(sealed.exists)
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
      return end.sealed
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

  // _SealedPtrをpurifiedする処理は間違い。外部に晒さない用途なので。

  /// インデックスをポインタに解決する
  ///
  /// 木が同一の場合、インデックスが保持するポインタを返す。
  /// 木が異なる場合、インデックスが保持するノード番号に対応するポインタを返す。
  @inlinable
  internal func __purified_(_ index: _TieWrappedPtr) -> _SealedPtr {
    withMutableHeader { $0._tied === index.tied } // unsafeも試したが遅かった
      ? index.sealed.purified
      : __retrieve_(index.sealed.purified.tag).purified
  }

  @inlinable
  internal func __purified_(_ index: _LazyDetachPointer) -> _SealedPtr {
    withMutableHeader { $0._lazyDetach === index.unsafeLazyDetach }
      ? index.sealed.purified
      : __retrieve_(index.sealed.purified.tag).purified
  }
}

extension UnsafeTreeV2 {

  // _SealedPtrをpurifiedする処理は間違い。外部に晒さない用途なので。

  @inlinable
  internal func __purified_(_ range: _RawRange<UnsafeIndexV3>)
    -> _RawRange<_SealedPtr>
  {
    .init(
      lowerBound: __purified_(range.lowerBound),
      upperBound: __purified_(range.upperBound))
  }
}
