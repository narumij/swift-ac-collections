//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project.
//
// Copyright (c) 2024-2026 narumij.
// Licensed under the Apache License v2.0.
//
// SPDX-License-Identifier: Apache-2.0
//
// This implementation includes code derived from LLVM libc++'s red-black tree
// implementation, originally distributed under the Apache License v2.0 with
// LLVM Exceptions.
//
// Copyright © 2003-2026 The LLVM Project.
// Licensed under the Apache License v2.0 with LLVM Exceptions.
// The original license can be found at https://llvm.org/LICENSE.txt
//
// This Swift implementation includes modifications and adaptations made by
// narumij.
//
//===----------------------------------------------------------------------===//

@frozen
@_documentation(visibility: internal)
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
    // 木に紐付いている生バッファ
    //
    // - WARNING: 触ると生成されてしまうため不用意に触らないこと
    @usableFromInline
    var tied: _TiedRawBuffer {
      withMutableHeader { $0.tiedRawBuffer }
    }
  #endif
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
  internal func deinitialize() {
    withMutableHeader { header in
      header.deinitialize()
    }
  }
}

// MARK: Index Resolver

extension UnsafeTreeV2 {

  @inlinable
  package func __retrieve_(_ tag: _TrackingTag) -> _SafePtr {
    switch tag {
    case .nullptr: .failure(.null)
    case .end: .success(end)
    // capacityでは未初期化範囲を含む
    // 少なからずノードが初期化されているのはinitializedCount
    default: tag < initializedCount ? .success(_buffer.header[tag]) : .failure(.unknown)
    }
  }

  @inlinable
  package func ___retrieve(tag: _TrackingTagSealing) -> _SealedPtr {
    switch tag {
    case .end:
      return end.uncheckedSeal
    case .tag(let raw, let seal):
      // capacityでは未初期化範囲を含む
      // 少なからずノードが初期化されているのはinitializedCount
      guard raw < initializedCount else {
        return .failure(.unknown)
      }
      return .success(.uncheckedSeal(_buffer.header[raw], seal))
    }
  }

  // つながりをたぐりよせる
  //
  // 日本人的にはお祭りなどによくある千本引きのイメージ
  @inlinable
  package func __retrieve_(_ tag: _SealedTag) -> _SealedPtr {
    tag.flatMap { ___retrieve(tag: $0) }
  }
}

extension UnsafeTreeV2 {

  #if ALLOW_CROSS_TREE_INDEX
    @inlinable
    package func __purified_(_ index: _LazyTiedPtr) -> _SealedPtr {
      #if USE_LAZY_DETACH
        withMutableHeader { index.__isSameLazyDetach($0._lazyDetach) }
          ? index.sealed.purified
          : __retrieve_(index.sealed.purified.tag).deepPurified
      #else
        withMutableHeader { index.__isSameLazyDetach($0._lazyDetach) }
          ? index.sealed.purified
          : __retrieve_(index.tag).deepPurified
      #endif
    }
  #else
    @inlinable
    package func __purified_(_ index: _LazyTiedPtr) -> _SealedPtr {
      withMutableHeader { index.__isSameLazyDetach($0._lazyDetach) }
        ? index.sealed.purified
        : .failure(.crossTree)
    }
  #endif

  @inlinable
  internal func __purified_safe_(_ index: _LazyTiedPtr) -> _SafePtr {
    __purified_(index).map(\.pointer)
  }
}

extension UnsafeTreeV2 {

  @inlinable
  internal func __purified_safe_(
    _ range: _RawRange<UnsafeIndexV3>
  ) -> _SafeRange {
    traverse(range) {
      __purified_safe_($0)
    }
  }

  @inlinable
  internal func __purified_safe_(
    _ range: UnsafeIndexV3Range
  ) -> _SafeRange {
    __purified_safe_(range.range)
  }
}

extension UnsafeTreeV2 {

  @inlinable
  internal func __purified_safe_(
    _ range: _RawRangeExpression<UnsafeIndexV3>
  ) -> _SafeRangeExpression {
    traverse(range) { __purified_safe_($0) }
  }

  @inlinable
  internal func __purified_safe_(
    _ range: UnsafeIndexV3RangeExpression
  ) -> _SafeRangeExpression {
    __purified_safe_(range.rangeExpression)
  }
}
