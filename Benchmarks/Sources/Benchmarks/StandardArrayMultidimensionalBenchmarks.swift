import CollectionsBenchmark

private func balancedStandardArrayShape(for size: Int, dimensions: Int) -> [Int] {
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

private func standardArrayExpectedChecksum(for size: Int) -> Int {
  size * (size - 1) / 2
}

extension Benchmark {
  public mutating func addStandardArrayMultidimensionalBenchmarks() {
    addStandardArrayBareComparisons()
    addStandardArrayOptionalComparisons()
  }

  private mutating func addStandardArrayBareComparisons() {
    self.add(
      title: "Array<Array<Int>> 2D sequential read checksum",
      input: Int.self
    ) { size in
      let axes = balancedStandardArrayShape(for: size, dimensions: 2)
      var value = 0
      let array = (0..<axes[1]).map { _ in
        (0..<axes[0]).map { _ in
          defer { value += 1 }
          return value
        }
      }
      return { timer in
        var checksum = 0
        timer.measure {
          for y in 0..<axes[1] {
            for x in 0..<axes[0] {
              checksum &+= array[y][x]
            }
          }
        }
        blackHole(checksum)
        precondition(checksum == standardArrayExpectedChecksum(for: size))
      }
    }

    self.add(
      title: "Array<Array<Int>> 2D sequential write",
      input: Int.self
    ) { size in
      let axes = balancedStandardArrayShape(for: size, dimensions: 2)
      var array = (0..<axes[1]).map { _ in
        [Int](repeating: 0, count: axes[0])
      }
      return { timer in
        timer.measure {
          var value = 0
          for y in 0..<axes[1] {
            for x in 0..<axes[0] {
              array[y][x] = value
              value += 1
            }
          }
        }
        var checksum = 0
        for y in 0..<axes[1] {
          for x in 0..<axes[0] {
            checksum &+= array[y][x]
          }
        }
        blackHole(checksum)
        precondition(checksum == standardArrayExpectedChecksum(for: size))
      }
    }

    self.add(
      title: "Array<Array<Array<Int>>> 3D sequential read checksum",
      input: Int.self
    ) { size in
      let axes = balancedStandardArrayShape(for: size, dimensions: 3)
      var value = 0
      let array = (0..<axes[2]).map { _ in
        (0..<axes[1]).map { _ in
          (0..<axes[0]).map { _ in
            defer { value += 1 }
            return value
          }
        }
      }
      return { timer in
        var checksum = 0
        timer.measure {
          for z in 0..<axes[2] {
            for y in 0..<axes[1] {
              for x in 0..<axes[0] {
                checksum &+= array[z][y][x]
              }
            }
          }
        }
        blackHole(checksum)
        precondition(checksum == standardArrayExpectedChecksum(for: size))
      }
    }

    self.add(
      title: "Array<Array<Array<Int>>> 3D sequential write",
      input: Int.self
    ) { size in
      let axes = balancedStandardArrayShape(for: size, dimensions: 3)
      var array = (0..<axes[2]).map { _ in
        (0..<axes[1]).map { _ in
          [Int](repeating: 0, count: axes[0])
        }
      }
      return { timer in
        timer.measure {
          var value = 0
          for z in 0..<axes[2] {
            for y in 0..<axes[1] {
              for x in 0..<axes[0] {
                array[z][y][x] = value
                value += 1
              }
            }
          }
        }
        var checksum = 0
        for z in 0..<axes[2] {
          for y in 0..<axes[1] {
            for x in 0..<axes[0] {
              checksum &+= array[z][y][x]
            }
          }
        }
        blackHole(checksum)
        precondition(checksum == standardArrayExpectedChecksum(for: size))
      }
    }
  }

  private mutating func addStandardArrayOptionalComparisons() {
    self.add(
      title: "Array sentinel 2D initialization",
      input: Int.self
    ) { size in
      let axes = balancedStandardArrayShape(for: size, dimensions: 2)
      return { timer in
        var initialized = false
        timer.measure {
          let array = (0..<axes[1]).map { _ in
            [Int](repeating: -1, count: axes[0])
          }
          initialized = array[0][0] == -1
        }
        blackHole(initialized)
        precondition(initialized)
      }
    }

    self.add(
      title: "Array<Array<Int?>> 2D initialization",
      input: Int.self
    ) { size in
      let axes = balancedStandardArrayShape(for: size, dimensions: 2)
      return { timer in
        var initialized = false
        timer.measure {
          let array = (0..<axes[1]).map { _ in
            [Int?](repeating: nil, count: axes[0])
          }
          initialized = array[0][0] == nil
        }
        blackHole(initialized)
        precondition(initialized)
      }
    }

    self.add(
      title: "Array sentinel 1D cold memoization checksum",
      input: Int.self
    ) { size in
      var array = [Int](repeating: -1, count: size)
      return { timer in
        array.withUnsafeMutableBufferPointer { $0.update(repeating: -1) }
        var checksum = 0
        timer.measure {
          for i in 0..<size {
            if array[i] == -1 {
              array[i] = i
            }
            checksum &+= array[i]
          }
        }
        blackHole(checksum)
        precondition(checksum == standardArrayExpectedChecksum(for: size))
      }
    }

    self.add(
      title: "Array sentinel 1D warm memoization checksum",
      input: Int.self
    ) { size in
      let array = Array(0..<size)
      return { timer in
        var checksum = 0
        timer.measure {
          for i in 0..<size where array[i] != -1 {
            checksum &+= array[i]
          }
        }
        blackHole(checksum)
        precondition(checksum == standardArrayExpectedChecksum(for: size))
      }
    }

    self.add(
      title: "Array<Int?> 1D cold memoization checksum",
      input: Int.self
    ) { size in
      var array = [Int?](repeating: nil, count: size)
      return { timer in
        array.withUnsafeMutableBufferPointer { $0.update(repeating: nil) }
        var checksum = 0
        timer.measure {
          for i in 0..<size {
            if let cached = array[i] {
              checksum &+= cached
            } else {
              array[i] = i
              checksum &+= array[i]!
            }
          }
        }
        blackHole(checksum)
        precondition(checksum == standardArrayExpectedChecksum(for: size))
      }
    }

    self.add(
      title: "Array<Int?> 1D warm memoization checksum",
      input: Int.self
    ) { size in
      let array: [Int?] = (0..<size).map { $0 }
      return { timer in
        var checksum = 0
        timer.measure {
          for i in 0..<size {
            if let cached = array[i] {
              checksum &+= cached
            }
          }
        }
        blackHole(checksum)
        precondition(checksum == standardArrayExpectedChecksum(for: size))
      }
    }

    self.add(
      title: "Array sentinel 2D cold memoization checksum",
      input: Int.self
    ) { size in
      let axes = balancedStandardArrayShape(for: size, dimensions: 2)
      var array = [[Int]](
        repeating: [Int](repeating: -1, count: axes[0]),
        count: axes[1])
      return { timer in
        for y in 0..<axes[1] {
          for x in 0..<axes[0] {
            array[y][x] = -1
          }
        }
        var checksum = 0
        timer.measure {
          var value = 0
          for y in 0..<axes[1] {
            for x in 0..<axes[0] {
              if array[y][x] == -1 {
                array[y][x] = value
              }
              checksum &+= array[y][x]
              value += 1
            }
          }
        }
        blackHole(checksum)
        precondition(checksum == standardArrayExpectedChecksum(for: size))
      }
    }

    self.add(
      title: "Array sentinel 2D warm memoization checksum",
      input: Int.self
    ) { size in
      let axes = balancedStandardArrayShape(for: size, dimensions: 2)
      var value = 0
      let array = (0..<axes[1]).map { _ in
        (0..<axes[0]).map { _ in
          defer { value += 1 }
          return value
        }
      }
      return { timer in
        var checksum = 0
        timer.measure {
          for y in 0..<axes[1] {
            for x in 0..<axes[0] {
              if array[y][x] != -1 {
                checksum &+= array[y][x]
              }
            }
          }
        }
        blackHole(checksum)
        precondition(checksum == standardArrayExpectedChecksum(for: size))
      }
    }

    self.add(
      title: "Array sentinel 3D cold memoization checksum",
      input: Int.self
    ) { size in
      let axes = balancedStandardArrayShape(for: size, dimensions: 3)
      var array = [[[Int]]](
        repeating: [[Int]](
          repeating: [Int](repeating: -1, count: axes[0]),
          count: axes[1]),
        count: axes[2])
      return { timer in
        for z in 0..<axes[2] {
          for y in 0..<axes[1] {
            for x in 0..<axes[0] {
              array[z][y][x] = -1
            }
          }
        }
        var checksum = 0
        timer.measure {
          var value = 0
          for z in 0..<axes[2] {
            for y in 0..<axes[1] {
              for x in 0..<axes[0] {
                if array[z][y][x] == -1 {
                  array[z][y][x] = value
                }
                checksum &+= array[z][y][x]
                value += 1
              }
            }
          }
        }
        blackHole(checksum)
        precondition(checksum == standardArrayExpectedChecksum(for: size))
      }
    }

    self.add(
      title: "Array sentinel 3D warm memoization checksum",
      input: Int.self
    ) { size in
      let axes = balancedStandardArrayShape(for: size, dimensions: 3)
      var value = 0
      let array = (0..<axes[2]).map { _ in
        (0..<axes[1]).map { _ in
          (0..<axes[0]).map { _ in
            defer { value += 1 }
            return value
          }
        }
      }
      return { timer in
        var checksum = 0
        timer.measure {
          for z in 0..<axes[2] {
            for y in 0..<axes[1] {
              for x in 0..<axes[0] {
                if array[z][y][x] != -1 {
                  checksum &+= array[z][y][x]
                }
              }
            }
          }
        }
        blackHole(checksum)
        precondition(checksum == standardArrayExpectedChecksum(for: size))
      }
    }

    self.add(
      title: "Array<Array<Int?>> 2D cold memoization checksum",
      input: Int.self
    ) { size in
      let axes = balancedStandardArrayShape(for: size, dimensions: 2)
      var array = [[Int?]](
        repeating: [Int?](repeating: nil, count: axes[0]),
        count: axes[1])
      return { timer in
        for y in 0..<axes[1] {
          for x in 0..<axes[0] {
            array[y][x] = nil
          }
        }
        var checksum = 0
        timer.measure {
          var value = 0
          for y in 0..<axes[1] {
            for x in 0..<axes[0] {
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
        precondition(checksum == standardArrayExpectedChecksum(for: size))
      }
    }

    self.add(
      title: "Array<Array<Int?>> 2D warm memoization checksum",
      input: Int.self
    ) { size in
      let axes = balancedStandardArrayShape(for: size, dimensions: 2)
      var value = 0
      let array: [[Int?]] = (0..<axes[1]).map { _ in
        (0..<axes[0]).map { _ in
          defer { value += 1 }
          return value
        }
      }
      return { timer in
        var checksum = 0
        timer.measure {
          for y in 0..<axes[1] {
            for x in 0..<axes[0] {
              if let cached = array[y][x] {
                checksum &+= cached
              }
            }
          }
        }
        blackHole(checksum)
        precondition(checksum == standardArrayExpectedChecksum(for: size))
      }
    }

    self.add(
      title: "Array<Array<Array<Int?>>> 3D cold memoization checksum",
      input: Int.self
    ) { size in
      let axes = balancedStandardArrayShape(for: size, dimensions: 3)
      var array = [[[Int?]]](
        repeating: [[Int?]](
          repeating: [Int?](repeating: nil, count: axes[0]),
          count: axes[1]),
        count: axes[2])
      return { timer in
        for z in 0..<axes[2] {
          for y in 0..<axes[1] {
            for x in 0..<axes[0] {
              array[z][y][x] = nil
            }
          }
        }
        var checksum = 0
        timer.measure {
          var value = 0
          for z in 0..<axes[2] {
            for y in 0..<axes[1] {
              for x in 0..<axes[0] {
                if let cached = array[z][y][x] {
                  checksum &+= cached
                } else {
                  array[z][y][x] = value
                  checksum &+= array[z][y][x]!
                }
                value += 1
              }
            }
          }
        }
        blackHole(checksum)
        precondition(checksum == standardArrayExpectedChecksum(for: size))
      }
    }

    self.add(
      title: "Array<Array<Array<Int?>>> 3D warm memoization checksum",
      input: Int.self
    ) { size in
      let axes = balancedStandardArrayShape(for: size, dimensions: 3)
      var value = 0
      let array: [[[Int?]]] = (0..<axes[2]).map { _ in
        (0..<axes[1]).map { _ in
          (0..<axes[0]).map { _ in
            defer { value += 1 }
            return value
          }
        }
      }
      return { timer in
        var checksum = 0
        timer.measure {
          for z in 0..<axes[2] {
            for y in 0..<axes[1] {
              for x in 0..<axes[0] {
                if let cached = array[z][y][x] {
                  checksum &+= cached
                }
              }
            }
          }
        }
        blackHole(checksum)
        precondition(checksum == standardArrayExpectedChecksum(for: size))
      }
    }
  }
}
