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

@inline(never)
private func bareArray1DElementChecksum(
  _ array: borrowing BareArray<Int>, count: Int
) -> Int {
  var checksum = 0
  for position in 0..<count {
    checksum &+= array.element(at: position)
  }
  return checksum
}

@inline(never)
@available(macOS 27.0, *)
private func bareArray1DReferenceChecksum(
  _ array: inout BareArray<Int>, count: Int
) -> Int {
  var checksum = 0
  for position in 0..<count {
    checksum &+= array.reference(at: position).value
  }
  return checksum
}

@inline(never)
private func bareArray1DSetElements(
  _ array: borrowing BareArray<Int>, count: Int
) {
  for position in 0..<count {
    array.setElement(position, at: position)
  }
}

@inline(never)
@available(macOS 27.0, *)
private func bareArray1DSetReferences(
  _ array: inout BareArray<Int>, count: Int
) {
  for position in 0..<count {
    var reference = array.reference(at: position)
    reference.value = position
  }
}

extension Benchmark {
  public mutating func addBareArrayBenchmarks() {
    self.add(
      title: "BareArray<Int> element(at:) sequential read checksum",
      input: Int.self
    ) { size in
      var value = 0
      let array = BareArray<Int>(count: size) {
        defer { value += 1 }
        return value
      }
      return { timer in
        var checksum = 0
        timer.measure {
          checksum = bareArray1DElementChecksum(array, count: size)
        }
        blackHole(checksum)
        precondition(checksum == bareArrayExpectedChecksum(for: size))
      }
    }

    if #available(macOS 27.0, *) {
      self.add(
        title: "BareArray<Int> Reference sequential read checksum",
        input: Int.self
      ) { size in
        var value = 0
        var array = BareArray<Int>(count: size) {
          defer { value += 1 }
          return value
        }
        return { timer in
          var checksum = 0
          timer.measure {
            checksum = bareArray1DReferenceChecksum(&array, count: size)
          }
          blackHole(checksum)
          precondition(checksum == bareArrayExpectedChecksum(for: size))
        }
      }
    }

    self.add(
      title: "BareArray<Int> setElement(_:at:) sequential write",
      input: Int.self
    ) { size in
      return { timer in
        let array = BareArray<Int>(repeating: 0, count: size)
        timer.measure {
          bareArray1DSetElements(array, count: size)
        }
        var checksum = 0
        for position in 0..<size {
          checksum &+= array.element(at: position)
        }
        blackHole(checksum)
        precondition(checksum == bareArrayExpectedChecksum(for: size))
      }
    }

    if #available(macOS 27.0, *) {
      self.add(
        title: "BareArray<Int> Reference sequential write",
        input: Int.self
      ) { size in
        return { timer in
          var array = BareArray<Int>(repeating: 0, count: size)
          timer.measure {
            bareArray1DSetReferences(&array, count: size)
          }
          var checksum = 0
          for position in 0..<size {
            checksum &+= array.reference(at: position).value
          }
          blackHole(checksum)
          precondition(checksum == bareArrayExpectedChecksum(for: size))
        }
      }
    }

    if #available(macOS 27.0, *) {
      self.add(
        title: "BareArray2D<Int> Reference sequential read checksum",
        input: Int.self
      ) { size in
        let shape = bareArray2DShape(for: size)
        var value = 0
        var array = BareArray2D<Int>(width: shape.width, height: shape.height) {
          defer { value += 1 }
          return value
        }

        return { timer in
          var checksum = 0
          timer.measure {
            for y in 0..<shape.height {
              for x in 0..<shape.width {
                checksum &+= array.reference(at: x, y).value
              }
            }
          }
          blackHole(checksum)
          precondition(checksum == bareArrayExpectedChecksum(for: size))
        }
      }
    }

    self.add(
      title: "BareArray2D<Int> element(at:) sequential read checksum",
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
              checksum &+= array.element(at: x, y)
            }
          }
        }
        blackHole(checksum)
        precondition(checksum == bareArrayExpectedChecksum(for: size))
      }
    }

    if #available(macOS 27.0, *) {
      self.add(
        title: "BareArray2D<Int> Reference sequential write",
        input: Int.self
      ) { size in
        let shape = bareArray2DShape(for: size)
        return { timer in
          var array = BareArray2D<Int>(
            repeating: 0, width: shape.width, height: shape.height)
          timer.measure {
            var value = 0
            for y in 0..<shape.height {
              for x in 0..<shape.width {
                var reference = array.reference(at: x, y)
                reference.value = value
                value += 1
              }
            }
          }
          var checksum = 0
          for y in 0..<shape.height {
            for x in 0..<shape.width {
              checksum &+= array.reference(at: x, y).value
            }
          }
          blackHole(checksum)
          precondition(checksum == bareArrayExpectedChecksum(for: size))
        }
      }
    }

    self.add(
      title: "BareArray2D<Int> setElement(_:at:) sequential write",
      input: Int.self
    ) { size in
      let shape = bareArray2DShape(for: size)
      return { timer in
        let array = BareArray2D<Int>(
          repeating: 0, width: shape.width, height: shape.height)
        timer.measure {
          var value = 0
          for y in 0..<shape.height {
            for x in 0..<shape.width {
              array.setElement(value, at: x, y)
              value += 1
            }
          }
        }
        var checksum = 0
        for y in 0..<shape.height {
          for x in 0..<shape.width {
            checksum &+= array.element(at: x, y)
          }
        }
        blackHole(checksum)
        precondition(checksum == bareArrayExpectedChecksum(for: size))
      }
    }

    if #available(macOS 27.0, *) {
      self.add(
        title: "BareArray3D<Int> Reference sequential read checksum",
        input: Int.self
      ) { size in
        let shape = bareArray3DShape(for: size)
        var value = 0
        var array = BareArray3D<Int>(
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
                  checksum &+= array.reference(at: x, y, z).value
                }
              }
            }
          }
          blackHole(checksum)
          precondition(checksum == bareArrayExpectedChecksum(for: size))
        }
      }
    }

    self.add(
      title: "BareArray3D<Int> element(at:) sequential read checksum",
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
                checksum &+= array.element(at: x, y, z)
              }
            }
          }
        }
        blackHole(checksum)
        precondition(checksum == bareArrayExpectedChecksum(for: size))
      }
    }

    if #available(macOS 27.0, *) {
      self.add(
        title: "BareArray3D<Int> Reference sequential write",
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
                  var reference = array.reference(at: x, y, z)
                  reference.value = value
                  value += 1
                }
              }
            }
          }
          var checksum = 0
          for z in 0..<shape.depth {
            for y in 0..<shape.height {
              for x in 0..<shape.width {
                checksum &+= array.reference(at: x, y, z).value
              }
            }
          }
          blackHole(checksum)
          precondition(checksum == bareArrayExpectedChecksum(for: size))
        }
      }
    }

    self.add(
      title: "BareArray3D<Int> setElement(_:at:) sequential write",
      input: Int.self
    ) { size in
      let shape = bareArray3DShape(for: size)
      let array = BareArray3D<Int>(
        repeating: 0, width: shape.width, height: shape.height, depth: shape.depth)
      return { timer in
        timer.measure {
          var value = 0
          for z in 0..<shape.depth {
            for y in 0..<shape.height {
              for x in 0..<shape.width {
                array.setElement(value, at: x, y, z)
                value += 1
              }
            }
          }
        }
        var checksum = 0
        for z in 0..<shape.depth {
          for y in 0..<shape.height {
            for x in 0..<shape.width {
              checksum &+= array.element(at: x, y, z)
            }
          }
        }
        blackHole(checksum)
        precondition(checksum == bareArrayExpectedChecksum(for: size))
      }
    }
  }
}
