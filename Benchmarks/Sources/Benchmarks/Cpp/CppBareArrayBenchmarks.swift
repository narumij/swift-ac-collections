import CollectionsBenchmark
import CppBenchmarks

private final class CppNestedVector2D {
  let pointer: UnsafeMutableRawPointer

  init(width: Int, height: Int) {
    pointer = cpp_nested_vector_2d_create(width, height)
  }

  deinit {
    cpp_nested_vector_2d_destroy(pointer)
  }
}

private final class CppNestedVector3D {
  let pointer: UnsafeMutableRawPointer

  init(width: Int, height: Int, depth: Int) {
    pointer = cpp_nested_vector_3d_create(width, height, depth)
  }

  deinit {
    cpp_nested_vector_3d_destroy(pointer)
  }
}

private func balancedCppBareArrayShape(for size: Int, dimensions: Int) -> [Int] {
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

private func cppBareArrayExpectedChecksum(for size: Int) -> Int {
  size * (size - 1) / 2
}

extension Benchmark {
  mutating func _addCppBareArrayBenchmarks() {
    self.add(
      title: "std::vector<std::vector<intptr_t>> 2D sequential read checksum",
      input: Int.self
    ) { size in
      let axes = balancedCppBareArrayShape(for: size, dimensions: 2)
      let array = CppNestedVector2D(width: axes[0], height: axes[1])
      return { timer in
        var checksum = 0
        timer.measure {
          checksum = cpp_nested_vector_2d_checksum(array.pointer)
        }
        blackHole(checksum)
        precondition(checksum == cppBareArrayExpectedChecksum(for: size))
      }
    }

    self.add(
      title: "std::vector<std::vector<intptr_t>> 2D sequential write",
      input: Int.self
    ) { size in
      let axes = balancedCppBareArrayShape(for: size, dimensions: 2)
      let array = CppNestedVector2D(width: axes[0], height: axes[1])
      return { timer in
        timer.measure {
          cpp_nested_vector_2d_write(array.pointer)
        }
        let checksum = cpp_nested_vector_2d_checksum(array.pointer)
        blackHole(checksum)
        precondition(checksum == cppBareArrayExpectedChecksum(for: size))
      }
    }

    self.add(
      title: "std::vector<std::vector<std::vector<intptr_t>>> 3D sequential read checksum",
      input: Int.self
    ) { size in
      let axes = balancedCppBareArrayShape(for: size, dimensions: 3)
      let array = CppNestedVector3D(width: axes[0], height: axes[1], depth: axes[2])
      return { timer in
        var checksum = 0
        timer.measure {
          checksum = cpp_nested_vector_3d_checksum(array.pointer)
        }
        blackHole(checksum)
        precondition(checksum == cppBareArrayExpectedChecksum(for: size))
      }
    }

    self.add(
      title: "std::vector<std::vector<std::vector<intptr_t>>> 3D sequential write",
      input: Int.self
    ) { size in
      let axes = balancedCppBareArrayShape(for: size, dimensions: 3)
      let array = CppNestedVector3D(width: axes[0], height: axes[1], depth: axes[2])
      return { timer in
        timer.measure {
          cpp_nested_vector_3d_write(array.pointer)
        }
        let checksum = cpp_nested_vector_3d_checksum(array.pointer)
        blackHole(checksum)
        precondition(checksum == cppBareArrayExpectedChecksum(for: size))
      }
    }
  }
}
