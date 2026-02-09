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

  @inlinable @inline(__always)
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

  @inlinable @inline(__always)
  package var nullptr: _NodePtr {
    withMutableHeader { $0.nullptr }
  }

  @inlinable @inline(__always)
  package var end: _NodePtr {
    withMutableHeader { $0.end_ptr }
  }

  @inlinable @inline(__always)
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
      ? _emptyDeallocator : withMutableHeader { $0.tiedRawBuffer }
  }
}

extension UnsafeTreeV2: CustomStringConvertible {
  public var description: String {
    "UnsafeTreeV2<\(Base._PayloadValue.self)>._Storage\(_buffer.header)"
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  var count: Int { withMutableHeader { $0.count } }

  @inlinable
  @inline(__always)
  var capacity: Int { withMutableHeader { $0.freshPoolCapacity } }

  @inlinable
  @inline(__always)
  var initializedCount: Int { withMutableHeader { $0.freshPoolUsedCount } }
}

extension UnsafeTreeV2 {

  @nonobjc
  @inlinable
  internal subscript(_unsafe_raw pointer: _NodePtr) -> _PayloadValue {
    @inline(__always) _read {
      yield pointer.__value_().pointee
    }
    @inline(__always) _modify {
      yield &pointer.__value_().pointee
    }
  }
}

extension UnsafeTreeV2 {

  @nonobjc
  @inlinable
  internal subscript(_unsafe pointer: _SealedPtr) -> _PayloadValue {
    @inline(__always) _read {
      yield self[_unsafe_raw: try! pointer.get().pointer]
    }
    @inline(__always) _modify {
      yield &self[_unsafe_raw: try! pointer.get().pointer]
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
    @inline(__always)
    func makeUsedNodeIterator() -> _FreshPoolUsedIterator<_PayloadValue> {
      return _buffer.header.makeUsedNodeIterator()
    }
  }
#endif

// MARK: Index Resolver

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  package subscript(__retrieve_ tag: _RawTrackingTag) -> _SafePtr {
    switch tag {
    case .nullptr: .failure(.null)
    case .end: .success(end)
    default: tag < capacity ? .success(_buffer.header[tag]) : .failure(.unknown)
    }
  }
}

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  package func ___retrieve(tag: TagSeal_) -> _SealedPtr {
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
  @inline(__always)
  package func __retrieve_(_ tag: TaggedSeal) -> _SealedPtr {
    tag.flatMap { ___retrieve(tag: $0) }
  }
}

extension UnsafeTreeV2 {

  /// インデックスをポインタに解決する
  ///
  /// 木が同一の場合、インデックスが保持するポインタを返す。
  /// 木が異なる場合、インデックスが保持するノード番号に対応するポインタを返す。
  @inlinable
  @inline(__always)
  internal func __purified_(_ index: Index) -> _SealedPtr
  where Index.Tree == UnsafeTreeV2, Index._NodePtr == _NodePtr {
    tied === index.tied
      ? index.sealed.purified
      : __retrieve_(index.sealed.purified.trackingTag).purified
  }

  @inlinable
  @inline(__always)
  internal func __purified_(_ trackingTag: TaggedSeal) -> _SealedPtr {
    __retrieve_(trackingTag).purified
  }
}
