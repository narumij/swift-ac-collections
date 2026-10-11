import CollectionsBenchmark
import CppBenchmarks

private final class CppPermutationSource {
  let pointer: UnsafeMutableRawPointer

  init(count: Int) {
    pointer = cpp_permutation_create(count)
  }

  init(count: Int, selectedCount: Int) {
    pointer = cpp_permutation_create_binary(count, selectedCount)
  }

  deinit {
    cpp_permutation_destroy(pointer)
  }
}

extension Benchmark {
  mutating func _addCppPermutationBenchmarks() {
    self.add(
      title: "std::next_permutation end-to-end checksum",
      input: Int.self
    ) { size in
      precondition(1 <= size && size <= 10, "end-to-end size must be in 1...10")
      let source = CppPermutationSource(count: size)
      return { timer in
        var count = 0
        var checksum = 0
        timer.measure {
          cpp_permutation_end_to_end(source.pointer, &count, &checksum)
        }
        blackHole(checksum)
        validateCppPermutationEndToEnd(count: count, checksum: checksum, size: size)
      }
    }

    self.add(
      title: "std::next_permutation binary selection checksum",
      input: Int.self
    ) { size in
      let selectedCount = 7
      precondition(7 <= size && size <= 32, "binary selection size must be in 7...32")
      let source = CppPermutationSource(count: size, selectedCount: selectedCount)
      return { timer in
        var count = 0
        var checksum = 0
        timer.measure {
          cpp_permutation_end_to_end(source.pointer, &count, &checksum)
        }
        blackHole(checksum)
        validateCppBinarySelection(
          count: count,
          checksum: checksum,
          size: size,
          selectedCount: selectedCount)
      }
    }
  }
}

/// Every value appears at every position exactly (n-1)! times.
private func validateCppPermutationEndToEnd(count: Int, checksum: Int, size n: Int) {
  let factorialNMinus1 = (1..<max(1, n)).reduce(1, *)
  precondition(count == factorialNMinus1 * n, "unexpected permutation count")
  precondition(
    checksum == factorialNMinus1 * (n * (n - 1) / 2) * (n * (n + 1) / 2),
    "unexpected permutation checksum")
}

private func validateCppBinarySelection(
  count: Int,
  checksum: Int,
  size n: Int,
  selectedCount k: Int
) {
  precondition(count == cppBinomial(n, k), "unexpected binary permutation count")
  precondition(
    checksum == cppBinomial(n - 1, k - 1) * (n * (n + 1) / 2),
    "unexpected binary permutation checksum")
}

private func cppBinomial(_ n: Int, _ k: Int) -> Int {
  let k = min(k, n - k)
  return (1...k).reduce(1) { result, i in
    result * (n - k + i) / i
  }
}
