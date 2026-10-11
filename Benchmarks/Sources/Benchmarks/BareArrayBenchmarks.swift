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

import BareArrayModule
import CollectionsBenchmark

private func balancedBareArrayShape(for size: Int, dimensions: Int) -> [Int] {
  precondition(size > 0 && dimensions > 0)

  var factors: [Int] = []
  var remaining = size
  var divisor = 2
  while divisor <= remaining / divisor {
    while remaining.isMultiple(of: divisor) {
      factors.append(divisor)
      remaining /= divisor
    }
    divisor += 1
  }
  if remaining > 1 {
    factors.append(remaining)
  }

  var axes = [Int](repeating: 1, count: dimensions)
  for factor in factors.reversed() {
    let shortestAxis = axes.indices.min { axes[$0] < axes[$1] }!
    axes[shortestAxis] *= factor
  }
  axes.sort(by: >)
  return axes
}

private func bareArray2DShape(for size: Int) -> (width: Int, height: Int) {
  let axes = balancedBareArrayShape(for: size, dimensions: 2)
  return (axes[0], axes[1])
}

private func bareArray3DShape(for size: Int) -> (width: Int, height: Int, depth: Int) {
  let axes = balancedBareArrayShape(for: size, dimensions: 3)
  return (axes[0], axes[1], axes[2])
}

private func bareArrayExpectedChecksum(for size: Int) -> Int {
  size * (size - 1) / 2
}

extension Benchmark {
  public mutating func addBareArrayBenchmarks() {
    self.add(
      title: "BareArray2D<Int> sequential read checksum",
      input: Int.self
    ) { size in
      let shape = bareArray2DShape(for: size)
      var value = 0
      let array = BareArray2D<Int>(width: shape.width, height: shape.height) {
        defer { value += 1 }
        return value
      }

      return { timer in
        var checksum = 0
        timer.measure {
          for y in 0..<shape.height {
            for x in 0..<shape.width {
              checksum &+= array[y][x]
            }
          }
        }
        blackHole(checksum)
        precondition(checksum == bareArrayExpectedChecksum(for: size))
      }
    }

    self.add(
      title: "BareArray2D<Int> sequential write",
      input: Int.self
    ) { size in
      let shape = bareArray2DShape(for: size)
      var array = BareArray2D<Int>(repeating: 0, width: shape.width, height: shape.height)

      return { timer in
        timer.measure {
          var value = 0
          for y in 0..<shape.height {
            for x in 0..<shape.width {
              array[y][x] = value
              value += 1
            }
          }
        }

        var checksum = 0
        for y in 0..<shape.height {
          for x in 0..<shape.width {
            checksum &+= array[y][x]
          }
        }
        blackHole(checksum)
        precondition(checksum == bareArrayExpectedChecksum(for: size))
      }
    }

    self.add(
      title: "BareArray3D<Int> sequential read checksum",
      input: Int.self
    ) { size in
      let shape = bareArray3DShape(for: size)
      var value = 0
      let array = BareArray3D<Int>(
        width: shape.width, height: shape.height, depth: shape.depth
      ) {
        defer { value += 1 }
        return value
      }

      return { timer in
        var checksum = 0
        timer.measure {
          for z in 0..<shape.depth {
            for y in 0..<shape.height {
              for x in 0..<shape.width {
                checksum &+= array[z][y][x]
              }
            }
          }
        }
        blackHole(checksum)
        precondition(checksum == bareArrayExpectedChecksum(for: size))
      }
    }

    self.add(
      title: "BareArray3D<Int> sequential write",
      input: Int.self
    ) { size in
      let shape = bareArray3DShape(for: size)
      var array = BareArray3D<Int>(
        repeating: 0, width: shape.width, height: shape.height, depth: shape.depth)

      return { timer in
        timer.measure {
          var value = 0
          for z in 0..<shape.depth {
            for y in 0..<shape.height {
              for x in 0..<shape.width {
                array[z][y][x] = value
                value += 1
              }
            }
          }
        }

        var checksum = 0
        for z in 0..<shape.depth {
          for y in 0..<shape.height {
            for x in 0..<shape.width {
              checksum &+= array[z][y][x]
            }
          }
        }
        blackHole(checksum)
        precondition(checksum == bareArrayExpectedChecksum(for: size))
      }
    }
  }
}
