import BasicContainers
import CollectionsBenchmark

private func balancedRigidArrayShape(for size: Int, dimensions: Int) -> [Int] {
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
  if remaining > 1 { factors.append(remaining) }
  var axes = [Int](repeating: 1, count: dimensions)
  for factor in factors.reversed() {
    let shortest = axes.indices.min { axes[$0] < axes[$1] }!
    axes[shortest] *= factor
  }
  axes.sort(by: >)
  return axes
}

private func rigidArrayExpectedChecksum(for size: Int) -> Int {
  size * (size - 1) / 2
}

private func makeRigidArray1D(count: Int) -> RigidArray<Int> {
  var result = RigidArray<Int>(capacity: count)
  for value in 0..<count { result.append(value) }
  return result
}

private func makeRigidArray2D(width: Int, height: Int) -> RigidArray<RigidArray<Int>> {
  var result = RigidArray<RigidArray<Int>>(capacity: height)
  var value = 0
  for _ in 0..<height {
    var row = RigidArray<Int>(capacity: width)
    for _ in 0..<width {
      row.append(value)
      value += 1
    }
    result.append(row)
  }
  return result
}

private func makeRigidArray3D(
  width: Int, height: Int, depth: Int
) -> RigidArray<RigidArray<RigidArray<Int>>> {
  var result = RigidArray<RigidArray<RigidArray<Int>>>(capacity: depth)
  var value = 0
  for _ in 0..<depth {
    var plane = RigidArray<RigidArray<Int>>(capacity: height)
    for _ in 0..<height {
      var row = RigidArray<Int>(capacity: width)
      for _ in 0..<width {
        row.append(value)
        value += 1
      }
      plane.append(row)
    }
    result.append(plane)
  }
  return result
}

@inline(never)
private func rigidArray1DChecksum(_ array: borrowing RigidArray<Int>) -> Int {
  var checksum = 0
  for i in array.indices { checksum &+= array[i] }
  return checksum
}

@inline(never)
private func rigidArray1DWrite(_ array: inout RigidArray<Int>) {
  for i in array.indices { array[i] = i }
}

@inline(never)
private func rigidArray2DChecksum(
  _ array: borrowing RigidArray<RigidArray<Int>>
) -> Int {
  var checksum = 0
  for y in array.indices {
    for x in array[y].indices { checksum &+= array[y][x] }
  }
  return checksum
}

@inline(never)
private func rigidArray2DWrite(_ array: inout RigidArray<RigidArray<Int>>) {
  var value = 0
  for y in array.indices {
    for x in array[y].indices {
      array[y][x] = value
      value += 1
    }
  }
}

@inline(never)
private func rigidArray3DChecksum(
  _ array: borrowing RigidArray<RigidArray<RigidArray<Int>>>
) -> Int {
  var checksum = 0
  for z in array.indices {
    for y in array[z].indices {
      for x in array[z][y].indices { checksum &+= array[z][y][x] }
    }
  }
  return checksum
}

@inline(never)
private func rigidArray3DWrite(
  _ array: inout RigidArray<RigidArray<RigidArray<Int>>>
) {
  var value = 0
  for z in array.indices {
    for y in array[z].indices {
      for x in array[z][y].indices {
        array[z][y][x] = value
        value += 1
      }
    }
  }
}

extension Benchmark {
  public mutating func addRigidArrayOptimizationBenchmarks() {
    addRigidArray1DOptimizationBenchmarks()
    addRigidArray2DOptimizationBenchmarks()
    addRigidArray3DOptimizationBenchmarks()
  }

  private mutating func addRigidArray1DOptimizationBenchmarks() {
    self.add(title: "RigidArray<Int> direct subscript sequential read checksum", input: Int.self) { size in
      let array = makeRigidArray1D(count: size)
      return { timer in
        var checksum = 0
        timer.measure {
          for i in array.indices { checksum &+= array[i] }
        }
        blackHole(checksum)
        precondition(checksum == rigidArrayExpectedChecksum(for: size))
      }
    }
    self.add(title: "RigidArray<Int> isolated subscript sequential read checksum", input: Int.self) { size in
      let array = makeRigidArray1D(count: size)
      return { timer in
        var checksum = 0
        timer.measure { checksum = rigidArray1DChecksum(array) }
        blackHole(checksum)
        precondition(checksum == rigidArrayExpectedChecksum(for: size))
      }
    }
    self.add(title: "RigidArray<Int> direct subscript sequential write", input: Int.self) { size in
      var array = RigidArray<Int>(repeating: 0, count: size)
      return { timer in
        timer.measure {
          for i in array.indices { array[i] = i }
        }
        let checksum = rigidArray1DChecksum(array)
        blackHole(checksum)
        precondition(checksum == rigidArrayExpectedChecksum(for: size))
      }
    }
    self.add(title: "RigidArray<Int> isolated subscript sequential write", input: Int.self) { size in
      var array = RigidArray<Int>(repeating: 0, count: size)
      return { timer in
        timer.measure { rigidArray1DWrite(&array) }
        let checksum = rigidArray1DChecksum(array)
        blackHole(checksum)
        precondition(checksum == rigidArrayExpectedChecksum(for: size))
      }
    }
  }

  private mutating func addRigidArray2DOptimizationBenchmarks() {
    self.add(title: "RigidArray<RigidArray<Int>> direct subscript sequential read checksum", input: Int.self) { size in
      let axes = balancedRigidArrayShape(for: size, dimensions: 2)
      let array = makeRigidArray2D(width: axes[0], height: axes[1])
      return { timer in
        var checksum = 0
        timer.measure {
          for y in array.indices {
            for x in array[y].indices { checksum &+= array[y][x] }
          }
        }
        blackHole(checksum)
        precondition(checksum == rigidArrayExpectedChecksum(for: size))
      }
    }
    self.add(title: "RigidArray<RigidArray<Int>> isolated subscript sequential read checksum", input: Int.self) { size in
      let axes = balancedRigidArrayShape(for: size, dimensions: 2)
      let array = makeRigidArray2D(width: axes[0], height: axes[1])
      return { timer in
        var checksum = 0
        timer.measure { checksum = rigidArray2DChecksum(array) }
        blackHole(checksum)
        precondition(checksum == rigidArrayExpectedChecksum(for: size))
      }
    }
    self.add(title: "RigidArray<RigidArray<Int>> direct subscript sequential write", input: Int.self) { size in
      let axes = balancedRigidArrayShape(for: size, dimensions: 2)
      var array = makeRigidArray2D(width: axes[0], height: axes[1])
      return { timer in
        timer.measure {
          var value = 0
          for y in array.indices {
            for x in array[y].indices {
              array[y][x] = value
              value += 1
            }
          }
        }
        let checksum = rigidArray2DChecksum(array)
        blackHole(checksum)
        precondition(checksum == rigidArrayExpectedChecksum(for: size))
      }
    }
    self.add(title: "RigidArray<RigidArray<Int>> isolated subscript sequential write", input: Int.self) { size in
      let axes = balancedRigidArrayShape(for: size, dimensions: 2)
      var array = makeRigidArray2D(width: axes[0], height: axes[1])
      return { timer in
        timer.measure { rigidArray2DWrite(&array) }
        let checksum = rigidArray2DChecksum(array)
        blackHole(checksum)
        precondition(checksum == rigidArrayExpectedChecksum(for: size))
      }
    }
  }

  private mutating func addRigidArray3DOptimizationBenchmarks() {
    self.add(title: "RigidArray<RigidArray<RigidArray<Int>>> direct subscript sequential read checksum", input: Int.self) { size in
      let axes = balancedRigidArrayShape(for: size, dimensions: 3)
      let array = makeRigidArray3D(width: axes[0], height: axes[1], depth: axes[2])
      return { timer in
        var checksum = 0
        timer.measure {
          for z in array.indices {
            for y in array[z].indices {
              for x in array[z][y].indices { checksum &+= array[z][y][x] }
            }
          }
        }
        blackHole(checksum)
        precondition(checksum == rigidArrayExpectedChecksum(for: size))
      }
    }
    self.add(title: "RigidArray<RigidArray<RigidArray<Int>>> isolated subscript sequential read checksum", input: Int.self) { size in
      let axes = balancedRigidArrayShape(for: size, dimensions: 3)
      let array = makeRigidArray3D(width: axes[0], height: axes[1], depth: axes[2])
      return { timer in
        var checksum = 0
        timer.measure { checksum = rigidArray3DChecksum(array) }
        blackHole(checksum)
        precondition(checksum == rigidArrayExpectedChecksum(for: size))
      }
    }
    self.add(title: "RigidArray<RigidArray<RigidArray<Int>>> direct subscript sequential write", input: Int.self) { size in
      let axes = balancedRigidArrayShape(for: size, dimensions: 3)
      var array = makeRigidArray3D(width: axes[0], height: axes[1], depth: axes[2])
      return { timer in
        timer.measure {
          var value = 0
          for z in array.indices {
            for y in array[z].indices {
              for x in array[z][y].indices {
                array[z][y][x] = value
                value += 1
              }
            }
          }
        }
        let checksum = rigidArray3DChecksum(array)
        blackHole(checksum)
        precondition(checksum == rigidArrayExpectedChecksum(for: size))
      }
    }
    self.add(title: "RigidArray<RigidArray<RigidArray<Int>>> isolated subscript sequential write", input: Int.self) { size in
      let axes = balancedRigidArrayShape(for: size, dimensions: 3)
      var array = makeRigidArray3D(width: axes[0], height: axes[1], depth: axes[2])
      return { timer in
        timer.measure { rigidArray3DWrite(&array) }
        let checksum = rigidArray3DChecksum(array)
        blackHole(checksum)
        precondition(checksum == rigidArrayExpectedChecksum(for: size))
      }
    }
  }
}
