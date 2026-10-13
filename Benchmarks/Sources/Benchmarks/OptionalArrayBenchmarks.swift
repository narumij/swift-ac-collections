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

import CollectionsBenchmark
import BasicContainers
import OptionalArrayModule

private func balancedOptionalArrayShape(for size: Int, dimensions: Int) -> [Int] {
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

private func optionalArray2DShape(for size: Int) -> (width: Int, height: Int) {
  let axes = balancedOptionalArrayShape(for: size, dimensions: 2)
  return (axes[0], axes[1])
}

private func optionalArray3DShape(for size: Int) -> (width: Int, height: Int, depth: Int) {
  let axes = balancedOptionalArrayShape(for: size, dimensions: 3)
  return (axes[0], axes[1], axes[2])
}

private func optionalArrayExpectedChecksum(for size: Int) -> Int {
  size * (size - 1) / 2
}

extension Benchmark {
  public mutating func addOptionalArrayBenchmarks() {
    self.add(
      title: "OptionalElementBuffer2D<Int> initialization",
      input: Int.self
    ) { size in
      let shape = optionalArray2DShape(for: size)
      return { timer in
        var initialized = false
        timer.measure {
          let array = OptionalElementBuffer2D<Int>(width: shape.width, height: shape.height)
          initialized = array.element(at: 0, 0) == nil
        }
        blackHole(initialized)
        precondition(initialized)
      }
    }

    self.add(
      title: "RigidArray<OptionalElementBuffer<Int>> 2D initialization",
      input: Int.self
    ) { size in
      let shape = optionalArray2DShape(for: size)
      return { timer in
        var initialized = false
        timer.measure {
          var array = RigidArray<OptionalElementBuffer<Int>>(capacity: shape.height)
          for _ in 0..<shape.height {
            array.append(OptionalElementBuffer<Int>(capacity: shape.width))
          }
          initialized = array[0].element(at: 0) == nil
        }
        blackHole(initialized)
        precondition(initialized)
      }
    }

    self.add(
      title: "RigidArray<RigidArray<Int?>> 2D initialization",
      input: Int.self
    ) { size in
      let shape = optionalArray2DShape(for: size)
      return { timer in
        var initialized = false
        timer.measure {
          var array = RigidArray<RigidArray<Int?>>(capacity: shape.height)
          for _ in 0..<shape.height {
            var row = RigidArray<Int?>(capacity: shape.width)
            for _ in 0..<shape.width {
              row.append(nil)
            }
            array.append(row)
          }
          initialized = array[0][0] == nil
        }
        blackHole(initialized)
        precondition(initialized)
      }
    }

    self.add(
      title: "RigidArray<OptionalElementBuffer<Int>> 2D cold memoization checksum",
      input: Int.self
    ) { size in
      let shape = optionalArray2DShape(for: size)
      return { timer in
        var array = RigidArray<OptionalElementBuffer<Int>>(capacity: shape.height)
        for _ in 0..<shape.height {
          array.append(OptionalElementBuffer<Int>(capacity: shape.width))
        }
        var checksum = 0
        timer.measure {
          var value = 0
          for y in 0..<shape.height {
            for x in 0..<shape.width {
              if let cached = array[y].element(at: x) {
                checksum &+= cached
              } else {
                array[y].setElement(value, at: x)
                checksum &+= array[y].element(at: x)!
              }
              value += 1
            }
          }
        }
        blackHole(checksum)
        precondition(checksum == optionalArrayExpectedChecksum(for: size))
      }
    }

    self.add(
      title: "RigidArray<OptionalElementBuffer<Int>> 2D warm memoization checksum",
      input: Int.self
    ) { size in
      let shape = optionalArray2DShape(for: size)
      return { timer in
        var array = RigidArray<OptionalElementBuffer<Int>>(capacity: shape.height)
        for _ in 0..<shape.height {
          array.append(OptionalElementBuffer<Int>(capacity: shape.width))
        }
        var value = 0
        for y in 0..<shape.height {
          for x in 0..<shape.width {
            array[y].setElement(value, at: x)
            value += 1
          }
        }
        var checksum = 0
        timer.measure {
          for y in 0..<shape.height {
            for x in 0..<shape.width {
              if let cached = array[y].element(at: x) {
                checksum &+= cached
              }
            }
          }
        }
        blackHole(checksum)
        precondition(checksum == optionalArrayExpectedChecksum(for: size))
      }
    }

    self.add(
      title: "RigidArray<RigidArray<Int?>> 2D cold memoization checksum",
      input: Int.self
    ) { size in
      let shape = optionalArray2DShape(for: size)
      return { timer in
        var array = RigidArray<RigidArray<Int?>>(capacity: shape.height)
        for _ in 0..<shape.height {
          var row = RigidArray<Int?>(capacity: shape.width)
          for _ in 0..<shape.width {
            row.append(nil)
          }
          array.append(row)
        }
        var checksum = 0
        timer.measure {
          var value = 0
          for y in 0..<shape.height {
            for x in 0..<shape.width {
              if let cached = array[y][x] {
                checksum &+= cached
              } else {
                array[y][x] = value
                checksum &+= array[y][x]!
              }
              value += 1
            }
          }
        }
        blackHole(checksum)
        precondition(checksum == optionalArrayExpectedChecksum(for: size))
      }
    }

    self.add(
      title: "RigidArray<RigidArray<Int?>> 2D warm memoization checksum",
      input: Int.self
    ) { size in
      let shape = optionalArray2DShape(for: size)
      return { timer in
        var value = 0
        var array = RigidArray<RigidArray<Int?>>(capacity: shape.height)
        for _ in 0..<shape.height {
          var row = RigidArray<Int?>(capacity: shape.width)
          for _ in 0..<shape.width {
            row.append(value)
            value += 1
          }
          array.append(row)
        }
        var checksum = 0
        timer.measure {
          for y in 0..<shape.height {
            for x in 0..<shape.width {
              if let cached = array[y][x] {
                checksum &+= cached
              }
            }
          }
        }
        blackHole(checksum)
        precondition(checksum == optionalArrayExpectedChecksum(for: size))
      }
    }

    self.add(
      title: "OptionalElementBuffer<Int> direct methods cold memoization checksum",
      input: Int.self
    ) { size in
      var array = OptionalElementBuffer<Int>(capacity: size)
      return { timer in
        array.removeAll()
        var checksum = 0
        timer.measure {
          for i in 0..<size {
            if let cached = array.element(at: i) {
              checksum &+= cached
            } else {
              array.setElement(i, at: i)
              checksum &+= array.element(at: i)!
            }
          }
        }
        blackHole(checksum)
        precondition(checksum == optionalArrayExpectedChecksum(for: size))
      }
    }

    self.add(
      title: "OptionalElementBuffer<Int> direct methods warm memoization checksum",
      input: Int.self
    ) { size in
      var array = OptionalElementBuffer<Int>(capacity: size)
      for i in 0..<size {
        array.setElement(i, at: i)
      }
      return { timer in
        var checksum = 0
        timer.measure {
          for i in 0..<size {
            if let cached = array.element(at: i) {
              checksum &+= cached
            }
          }
        }
        blackHole(checksum)
        precondition(checksum == optionalArrayExpectedChecksum(for: size))
      }
    }

    self.add(
      title: "OptionalElementBuffer2D<Int> direct methods cold memoization checksum",
      input: Int.self
    ) { size in
      let shape = optionalArray2DShape(for: size)
      var array = OptionalElementBuffer2D<Int>(width: shape.width, height: shape.height)

      return { timer in
        array.removeAll()
        var checksum = 0
        timer.measure {
          var value = 0
          for y in 0..<shape.height {
            for x in 0..<shape.width {
              if let cached = array.element(at: x, y) {
                checksum &+= cached
              } else {
                array.setElement(value, at: x, y)
                checksum &+= array.element(at: x, y)!
              }
              value += 1
            }
          }
        }
        blackHole(checksum)
        precondition(checksum == optionalArrayExpectedChecksum(for: size))
      }
    }

    self.add(
      title: "OptionalElementBuffer2D<Int> direct methods warm memoization checksum",
      input: Int.self
    ) { size in
      let shape = optionalArray2DShape(for: size)
      var array = OptionalElementBuffer2D<Int>(width: shape.width, height: shape.height)
      var value = 0
      for y in 0..<shape.height {
        for x in 0..<shape.width {
          array.setElement(value, at: x, y)
          value += 1
        }
      }

      return { timer in
        var checksum = 0
        timer.measure {
          for y in 0..<shape.height {
            for x in 0..<shape.width {
              if let cached = array.element(at: x, y) {
                checksum &+= cached
              }
            }
          }
        }
        blackHole(checksum)
        precondition(checksum == optionalArrayExpectedChecksum(for: size))
      }
    }

    self.add(
      title: "OptionalElementBuffer3D<Int> direct methods cold memoization checksum",
      input: Int.self
    ) { size in
      let shape = optionalArray3DShape(for: size)
      var array = OptionalElementBuffer3D<Int>(
        width: shape.width, height: shape.height, depth: shape.depth)

      return { timer in
        array.removeAll()
        var checksum = 0
        timer.measure {
          var value = 0
          for z in 0..<shape.depth {
            for y in 0..<shape.height {
              for x in 0..<shape.width {
                if let cached = array.element(at: x, y, z) {
                  checksum &+= cached
                } else {
                  array.setElement(value, at: x, y, z)
                  checksum &+= array.element(at: x, y, z)!
                }
                value += 1
              }
            }
          }
        }
        blackHole(checksum)
        precondition(checksum == optionalArrayExpectedChecksum(for: size))
      }
    }

    self.add(
      title: "OptionalElementBuffer3D<Int> direct methods warm memoization checksum",
      input: Int.self
    ) { size in
      let shape = optionalArray3DShape(for: size)
      var array = OptionalElementBuffer3D<Int>(
        width: shape.width, height: shape.height, depth: shape.depth)
      var value = 0
      for z in 0..<shape.depth {
        for y in 0..<shape.height {
          for x in 0..<shape.width {
            array.setElement(value, at: x, y, z)
            value += 1
          }
        }
      }

      return { timer in
        var checksum = 0
        timer.measure {
          for z in 0..<shape.depth {
            for y in 0..<shape.height {
              for x in 0..<shape.width {
                if let cached = array.element(at: x, y, z) {
                  checksum &+= cached
                }
              }
            }
          }
        }
        blackHole(checksum)
        precondition(checksum == optionalArrayExpectedChecksum(for: size))
      }
    }
  }
}
