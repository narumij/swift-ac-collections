//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Collections open source project
//
// Copyright (c) 2021 - 2026 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
//
//===----------------------------------------------------------------------===//

// modified by narumij

import CollectionsBenchmark
import CppBenchmarks

internal class CppSet {
  var ptr: UnsafeMutableRawPointer?

  init(_ input: [Int]) {
    self.ptr = input.withUnsafeBufferPointer { buffer in
      cpp_set_create(buffer.baseAddress, buffer.count)
    }
  }

  deinit {
    destroy()
  }

  func destroy() {
    if let ptr = ptr {
      cpp_set_destroy(ptr)
    }
    ptr = nil
  }
}

extension Benchmark {
  internal mutating func _addCppSetBenchmarks() {
    self.addSimple(
      title: "std::set<intptr_t> insert from integer range",
      input: Int.self
    ) { count in
      cpp_set_from_int_range(count)
    }

    self.addSimple(
      title: "std::set<intptr_t> constructor from buffer",
      input: [Int].self
    ) { input in
      input.withUnsafeBufferPointer { buffer in
        cpp_set_from_int_buffer(buffer.baseAddress, buffer.count)
      }
    }

    self.add(
      title: "std::set<intptr_t> sequential iteration",
      input: [Int].self
    ) { input in
      let set = CppSet(input)
      return { timer in
        cpp_set_iterate(set.ptr)
      }
    }

    self.add(
      title: "std::set<intptr_t> successful find",
      input: ([Int], [Int]).self
    ) { input, lookups in
      let set = CppSet(input)
      return { timer in
        lookups.withUnsafeBufferPointer { buffer in
          cpp_set_lookups(set.ptr, buffer.baseAddress, buffer.count, true)
        }
      }
    }

    self.add(
      title: "std::set<intptr_t> unsuccessful find",
      input: ([Int], [Int]).self
    ) { input, lookups in
      let set = CppSet(input)
      let lookups = lookups.map { $0 + input.count }
      return { timer in
        lookups.withUnsafeBufferPointer { buffer in
          cpp_set_lookups(set.ptr, buffer.baseAddress, buffer.count, false)
        }
      }
    }

    self.addSimple(
      title: "std::set<intptr_t> insert",
      input: [Int].self
    ) { input in
      input.withUnsafeBufferPointer { buffer in
        cpp_set_insert_integers(buffer.baseAddress, buffer.count, false)
      }
    }

    self.addSimple(
      title: "std::set<intptr_t> insert, reserving capacity",
      input: [Int].self
    ) { input in
      input.withUnsafeBufferPointer { buffer in
        cpp_set_insert_integers(buffer.baseAddress, buffer.count, true)
      }
    }

    self.add(
      title: "std::set<intptr_t> erase",
      input: ([Int], [Int]).self
    ) { input, removals in
      return { timer in
        let set = CppSet(input)
        timer.measure {
          removals.withUnsafeBufferPointer { buffer in
            cpp_set_removals(set.ptr, buffer.baseAddress, buffer.count)
          }
        }
        set.destroy()
      }
    }
  }
}
