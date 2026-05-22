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

internal class CppMap {
  var ptr: UnsafeMutableRawPointer?

  init(_ input: [Int]) {
    self.ptr = input.withUnsafeBufferPointer { buffer in
      cpp_map_create(buffer.baseAddress, buffer.count)
    }
  }

  deinit {
    destroy()
  }

  func destroy() {
    if let ptr = ptr {
      cpp_map_destroy(ptr)
    }
    ptr = nil
  }
}

extension Benchmark {
  internal mutating func _addCppMapBenchmarks() {
    self.addSimple(
      title: "std::map<intptr_t, intptr_t> insert from integer range",
      input: Int.self
    ) { count in
      cpp_map_from_int_range(count)
    }

    self.add(
      title: "std::map<intptr_t, intptr_t> sequential iteration",
      input: [Int].self
    ) { input in
      let map = CppMap(input)
      return { timer in
        cpp_map_iterate(map.ptr)
      }
    }

    self.addSimple(
      title: "std::map<intptr_t, intptr_t> insert",
      input: [Int].self
    ) { input in
      input.withUnsafeBufferPointer { buffer in
        cpp_map_insert_integers(buffer.baseAddress, buffer.count)
      }
    }

    self.addSimple(
      title: "std::map<intptr_t, intptr_t> insert, reserving capacity",
      input: [Int].self
    ) { input in
      input.withUnsafeBufferPointer { buffer in
        cpp_map_insert_integers(buffer.baseAddress, buffer.count)
      }
    }

    self.add(
      title: "std::map<intptr_t, intptr_t> successful find",
      input: ([Int], [Int]).self
    ) { input, lookups in
      let map = CppMap(input)
      return { timer in
        lookups.withUnsafeBufferPointer { buffer in
          cpp_map_lookups(map.ptr, buffer.baseAddress, buffer.count, true)
        }
      }
    }

    self.add(
      title: "std::map<intptr_t, intptr_t> unsuccessful find",
      input: ([Int], [Int]).self
    ) { input, lookups in
      let map = CppMap(input)
      let lookups = lookups.map { $0 + input.count }
      return { timer in
        lookups.withUnsafeBufferPointer { buffer in
          cpp_map_lookups(map.ptr, buffer.baseAddress, buffer.count, false)
        }
      }
    }

    self.add(
      title: "std::map<intptr_t, intptr_t> subscript, existing key",
      input: ([Int], [Int]).self
    ) { input, lookups in
      let map = CppMap(input)
      return { timer in
        lookups.withUnsafeBufferPointer { buffer in
          cpp_map_subscript(map.ptr, buffer.baseAddress, buffer.count)
        }
      }
    }

    self.add(
      title: "std::map<intptr_t, intptr_t> subscript, new key",
      input: ([Int], [Int]).self
    ) { input, lookups in
      let map = CppMap(input)
      let lookups = lookups.map { $0 + input.count }
      return { timer in
        lookups.withUnsafeBufferPointer { buffer in
          cpp_map_subscript(map.ptr, buffer.baseAddress, buffer.count)
        }
      }
    }

    self.add(
      title: "std::map<intptr_t, intptr_t> erase existing",
      input: ([Int], [Int]).self
    ) { input, removals in
      return { timer in
        let map = CppMap(input)
        timer.measure {
          removals.withUnsafeBufferPointer { buffer in
            cpp_map_removals(map.ptr, buffer.baseAddress, buffer.count)
          }
        }
        map.destroy()
      }
    }

    self.add(
      title: "std::map<intptr_t, intptr_t> erase missing",
      input: ([Int], [Int]).self
    ) { input, removals in
      return { timer in
        let map = CppMap(input.map { input.count + $0 })
        timer.measure {
          removals.withUnsafeBufferPointer { buffer in
            cpp_map_removals(map.ptr, buffer.baseAddress, buffer.count)
          }
        }
        map.destroy()
      }
    }
  }
}
