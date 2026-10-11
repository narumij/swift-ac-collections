import CollectionsBenchmark
import CppBenchmarks

private final class CppSentinelVector2D {
  let pointer: UnsafeMutableRawPointer

  init(width: Int, height: Int) {
    pointer = cpp_sentinel_vector_2d_create(width, height)
  }

  deinit {
    cpp_sentinel_vector_2d_destroy(pointer)
  }
}

private final class CppSentinelVector3D {
  let pointer: UnsafeMutableRawPointer

  init(width: Int, height: Int, depth: Int) {
    pointer = cpp_sentinel_vector_3d_create(width, height, depth)
  }

  deinit {
    cpp_sentinel_vector_3d_destroy(pointer)
  }
}

private func balancedCppOptionalArrayShape(for size: Int, dimensions: Int) -> [Int] {
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

private func cppOptionalArrayExpectedChecksum(for size: Int) -> Int {
  size * (size - 1) / 2
}

extension Benchmark {
  mutating func _addCppOptionalArrayBenchmarks() {
    self.add(
      title: "std::vector sentinel 2D cold memoization checksum",
      input: Int.self
    ) { size in
      let axes = balancedCppOptionalArrayShape(for: size, dimensions: 2)
      let array = CppSentinelVector2D(width: axes[0], height: axes[1])
      return { timer in
        cpp_sentinel_vector_2d_reset(array.pointer)
        var checksum = 0
        timer.measure {
          checksum = cpp_sentinel_vector_2d_memoization_checksum(array.pointer)
        }
        blackHole(checksum)
        precondition(checksum == cppOptionalArrayExpectedChecksum(for: size))
      }
    }

    self.add(
      title: "std::vector sentinel 2D warm memoization checksum",
      input: Int.self
    ) { size in
      let axes = balancedCppOptionalArrayShape(for: size, dimensions: 2)
      let array = CppSentinelVector2D(width: axes[0], height: axes[1])
      cpp_sentinel_vector_2d_prepare_warm(array.pointer)
      return { timer in
        var checksum = 0
        timer.measure {
          checksum = cpp_sentinel_vector_2d_memoization_checksum(array.pointer)
        }
        blackHole(checksum)
        precondition(checksum == cppOptionalArrayExpectedChecksum(for: size))
      }
    }

    self.add(
      title: "std::vector sentinel 3D cold memoization checksum",
      input: Int.self
    ) { size in
      let axes = balancedCppOptionalArrayShape(for: size, dimensions: 3)
      let array = CppSentinelVector3D(width: axes[0], height: axes[1], depth: axes[2])
      return { timer in
        cpp_sentinel_vector_3d_reset(array.pointer)
        var checksum = 0
        timer.measure {
          checksum = cpp_sentinel_vector_3d_memoization_checksum(array.pointer)
        }
        blackHole(checksum)
        precondition(checksum == cppOptionalArrayExpectedChecksum(for: size))
      }
    }

    self.add(
      title: "std::vector sentinel 3D warm memoization checksum",
      input: Int.self
    ) { size in
      let axes = balancedCppOptionalArrayShape(for: size, dimensions: 3)
      let array = CppSentinelVector3D(width: axes[0], height: axes[1], depth: axes[2])
      cpp_sentinel_vector_3d_prepare_warm(array.pointer)
      return { timer in
        var checksum = 0
        timer.measure {
          checksum = cpp_sentinel_vector_3d_memoization_checksum(array.pointer)
        }
        blackHole(checksum)
        precondition(checksum == cppOptionalArrayExpectedChecksum(for: size))
      }
    }
  }
}
