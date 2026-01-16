//
//  UnsafeMutableRawPointer+Util.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/16.
//

#if false
  import _Unsafe
  extension UnsafeMutableRawPointer {
    static func _unsafe_malloc(byteCount: Int, alignment: Int) -> UnsafeMutableRawPointer {
      malloc(byteCount)
    }
    func _unsafe_free() {
      free(self)
    }
    @inlinable
    @inline(__always)
    static func _allocate(byteCount: Int, alignment: Int) -> UnsafeMutableRawPointer {
      malloc(byteCount)
    }
    @inlinable
    @inline(never)
    func _deallocate() {
      free(self)
    }
  }
#else
  extension UnsafeMutableRawPointer {
    @inlinable
    @inline(__always)
    static func _allocate(byteCount: Int, alignment: Int) -> UnsafeMutableRawPointer {
      .allocate(byteCount: byteCount, alignment: alignment)
    }
    @inlinable
    @inline(never)
    func _deallocate() {
      self.deallocate()
    }
  }
#endif
