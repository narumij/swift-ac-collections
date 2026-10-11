import CollectionsBenchmark
import CppBenchmarks

private final class CppPermutationSource {
  let pointer: UnsafeMutableRawPointer

  init(count: Int) {
    pointer = cpp_permutation_create(count)
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
