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

  // _NodePtrがIntだった頃の名残
  @nonobjc
  @inlinable
  internal subscript(_ pointer: _NodePtr) -> _PayloadValue {
    @inline(__always) _read {
      assert(pointer.isValid && !pointer.___is_end)
      yield pointer.__value_().pointee
    }
    @inline(__always) _modify {
      assert(pointer.isValid && !pointer.___is_end)
      yield &pointer.__value_().pointee
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

#if false
  extension UnsafeTreeV2 {

    @inlinable
    @inline(__always)
    func makeFreshBucketIterator() -> _UnsafeNodeFreshBucketIterator<_PayloadValue> {
      return _UnsafeNodeFreshBucketIterator<_PayloadValue>(bucket: _buffer.header.freshBucketHead)
    }
  }
#endif

// MARK: Index Resolver

extension UnsafeTreeV2 {

  @inlinable
  @inline(__always)
  package subscript(tag: _RawTrackingTag) -> _SealedPtr {
    switch tag {
    case .nullptr:
      return .failure(.null)
    case .end:
      return success(end)
    default:
      guard tag < capacity else {
        return .failure(.unknown)
      }
      let p = _buffer.header[tag]
      return p.___is_garbaged ? .failure(.garbaged) : success(p)
    }
  }

  @inlinable
  @inline(__always)
  package func resolve(raw: _RawTrackingTag, seal: UnsafeNode.Seal) -> _SealedPtr {
    switch raw {
    case .nullptr:
      return .failure(.null)
    case .end:
      return success(end)
    default:
      guard raw < capacity else {
        return .failure(.unknown)
      }
      let p = _buffer.header[raw]
      return p.___is_garbaged || p.pointee.___recycle_count != seal
        ? .failure(.unsealed)
        : success(p)
    }
  }

  @inlinable
  @inline(__always)
  package subscript(tag: RedBlackTreeTrackingTag) -> _SealedPtr {
    tag.map { resolve(raw: $0.rawValue.raw, seal: $0.rawValue.seal) } ?? .failure(.null)
  }
}

extension UnsafeTreeV2 {

  /// インデックスをポインタに解決する
  ///
  /// 木が同一の場合、インデックスが保持するポインタを返す。
  /// 木が異なる場合、インデックスが保持するノード番号に対応するポインタを返す。
  @inlinable
  @inline(__always)
  internal func _remap_to_safe_(_ index: Index) -> _SealedPtr
  where Index.Tree == UnsafeTreeV2, Index._NodePtr == _NodePtr {
    tied === index.tied ? index.rawValue.safe : self[index._rawTag]
  }

  #if COMPATIBLE_ATCODER_2025
    @inlinable
    @inline(__always)
    internal func _remap_to_safe_2(_ index: Index) -> Result<
      UnsafeMutablePointer<UnsafeNode>, SafePtrError
    >
    where Index.Tree == UnsafeTreeV2, Index._NodePtr == _NodePtr {
      // TODO: Sealedに移行
      tied === index.tied ? .success(index.rawValue) : self[index._rawTag].pointer
    }
  #endif
}
