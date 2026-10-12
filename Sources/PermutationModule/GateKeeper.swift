//===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ac-collections project.
//
// Copyright (c) 2024-2026 narumij.
// Licensed under the Apache License v2.0.
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

@usableFromInline
package final class GateKeeper: ManagedBuffer<UInt, Void> {

  @inlinable
  var generation: UInt {
    @inline(__always)
    unsafeAddress {
      unsafe UnsafePointer(withUnsafeMutablePointerToHeader { pointer in
        unsafe pointer
      })
    }
    @inline(__always)
    unsafeMutableAddress {
      unsafe withUnsafeMutablePointerToHeader { pointer in
        unsafe pointer
      }
    }
  }
}

extension GateKeeper {

  @usableFromInline
  @inline(never)
  internal func closeCurrentView() {
    unsafe withUnsafeMutablePointerToHeader { generation in
      precondition(unsafe generation.pointee != .max, "Permutation view generation exhausted")
      unsafe generation.pointee += 1
    }
  }

  @inlinable
  func isClosed(generation: UInt) -> Bool {
    self.generation != generation
  }

  @nonobjc
  @usableFromInline
  internal static func create() -> GateKeeper {
    let storage = GateKeeper.create(minimumCapacity: 0) { _ in
      0
    }
    return unsafe unsafeDowncast(storage, to: GateKeeper.self)
  }
}
