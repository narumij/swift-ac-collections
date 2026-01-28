//
//  UnsafeMutableRawPointer+Util.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/16.
//

#if USE_C_MALLOC
  import _malloc_free
  extension UnsafeMutableRawPointer {
    @inlinable
    @inline(__always)
    static var MALLOC_ALIGN_MASK: Int {
      Int.bitWidth == 64 ? 15 : 7
    }
    static func _unsafe_malloc(byteCount: Int, alignment: Int) -> UnsafeMutableRawPointer {
      guard alignment <= MALLOC_ALIGN_MASK else {
        fatalError(.alignnment)
      }
      return malloc(byteCount)
    }
    func _unsafe_free() {
      free(self)
    }
    @inlinable
    @inline(__always)
    static func _allocate(byteCount: Int, alignment: Int) -> UnsafeMutableRawPointer {
      guard alignment <= MALLOC_ALIGN_MASK else {
        fatalError(.alignnment)
      }
      return malloc(byteCount)
    }
    @inlinable
    @inline(__always)
    func _deallocate() {
      free(self)
    }
  }
#else
  extension UnsafeMutableRawPointer {
    @inlinable
    @inline(__always)
    static func _allocate(byteCount: Int, alignment: Int) -> UnsafeMutableRawPointer {
      #if DEBUG
      allocatedCount += 1
      #endif
      return self.allocate(byteCount: byteCount, alignment: alignment)
    }
    @inlinable
    @inline(__always)
    func _deallocate() {
      #if DEBUG
      deallocatedCount += 1
      #endif
      self.deallocate()
    }
  }
#endif

#if DEBUG
@usableFromInline nonisolated(unsafe) var allocatedCount = 0
@usableFromInline nonisolated(unsafe) var deallocatedCount = 0
#endif
