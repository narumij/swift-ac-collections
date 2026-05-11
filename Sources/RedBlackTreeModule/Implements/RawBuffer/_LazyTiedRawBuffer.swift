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

// そもそもバッファの寿命園著自体がもう不要な気がした

// TODO: implement this
#if false
  @usableFromInline
  final package class _TiedRawBufferProxy {

    @nonobjc
    @inlinable
    @inline(__always)
    init() {}

    @usableFromInline
    var buffer: _TiedRawBuffer?
    
    @inlinable
    @inline(__always)
    static func create() -> Self { .init() }
  }
#else
  @usableFromInline
  package final class _LazyTiedRawBuffer: ManagedBuffer<_TiedRawBuffer?, Void> {

    @inlinable
    var buffer: _TiedRawBuffer? {
      @inline(__always)
      unsafeAddress {
        UnsafePointer(withUnsafeMutablePointerToHeader { $0 })
      }
      @inline(__always)
      unsafeMutableAddress {
        withUnsafeMutablePointerToHeader { $0 }
      }
    }
  }

  extension _LazyTiedRawBuffer {

    @nonobjc
    @inlinable
    @inline(__always)
    internal static func create() -> _LazyTiedRawBuffer {
      let storage = _LazyTiedRawBuffer.create(minimumCapacity: 0) { managedBuffer in
        return nil
      }
      return unsafeDowncast(storage, to: _LazyTiedRawBuffer.self)
    }
  }
#endif

/// The type-punned empty singleton storage instance.
@usableFromInline
nonisolated(unsafe) package let _emptyLazyTie =
_LazyTiedRawBuffer.create()
