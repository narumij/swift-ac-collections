//
//  _TiedRawBufferProxy.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/11.
//

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
  package final class _TiedRawBufferProxy: ManagedBuffer<_TiedRawBuffer?, Void> {

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

  extension _TiedRawBufferProxy {

    @nonobjc
    @inlinable
    @inline(__always)
    internal static func create() -> _TiedRawBufferProxy {
      let storage = _TiedRawBufferProxy.create(minimumCapacity: 0) { managedBuffer in
        return nil
      }
      return unsafeDowncast(storage, to: _TiedRawBufferProxy.self)
    }
  }
#endif
