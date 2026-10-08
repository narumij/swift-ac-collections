// Seeded input for the RedBlackTreeCollections / SortedCollections peer matrix.
//
// See `Maintanance/Archived/SORTED_COLLECTIONS_BENCHMARK_TASK.md` (Phase 2). The global
// `[Int]` generators of swift-collections-benchmark use `SystemRandomNumberGenerator`,
// so their inputs differ between cycles and runs. This input type is used only by the
// `peer` tasks and is fully determined by the size.

import CollectionsBenchmark

/// SplitMix64 (Steele, Lea, Flood 2014). Implemented here so that the sequence does not
/// depend on the standard library's random algorithms.
struct SortedPeerRNG {
  var state: UInt64

  mutating func next() -> UInt64 {
    state &+= 0x9E37_79B9_7F4A_7C15
    var z = state
    z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
    z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
    return z ^ (z >> 31)
  }

  /// A value in `0..<bound` by multiply-high (no rejection; the bias is below 2^-40 for
  /// the sizes used here and does not affect determinism).
  mutating func below(_ bound: Int) -> Int {
    Int(truncatingIfNeeded: next().multipliedFullWidth(by: UInt64(bound)).high)
  }
}

/// Deterministic peer-benchmark input of size `n`.
///
/// Stored keys are the even numbers `0, 2, ..., 2(n-1)`. Unsuccessful queries are the
/// odd numbers `1, 3, ..., 2n-1`, so a miss falls between stored keys and follows the
/// same kind of search path as a hit instead of always the rightmost path.
struct SortedPeerInput {
  static let seed: UInt64 = 0x5EED_5047_2026_1004

  let size: Int
  /// Stored keys in ascending order.
  let sortedKeys: [Int]
  /// Stored keys in insertion order (Fisher–Yates, stream 1).
  let insertionOrder: [Int]
  /// Stored keys in query order (stream 2).
  let hitQueries: [Int]
  /// Odd keys between stored keys in query order (stream 3).
  let missQueries: [Int]
  /// Stored keys in removal order (stream 4).
  let removalOrder: [Int]
  /// `(k, k + 1)` for `sortedKeys`, unlabeled tuples.
  let sortedPairs: [(Int, Int)]
  /// `(k, k + 1)` for `insertionOrder`, unlabeled tuples.
  let shuffledPairs: [(Int, Int)]

  init(size n: Int) {
    precondition(n > 0)
    size = n
    sortedKeys = (0..<n).map { 2 * $0 }
    insertionOrder = Self.shuffled(sortedKeys, size: n, stream: 1)
    hitQueries = Self.shuffled(sortedKeys, size: n, stream: 2)
    missQueries = Self.shuffled((0..<n).map { 2 * $0 + 1 }, size: n, stream: 3)
    removalOrder = Self.shuffled(sortedKeys, size: n, stream: 4)
    sortedPairs = sortedKeys.map { ($0, $0 + 1) }
    shuffledPairs = insertionOrder.map { ($0, $0 + 1) }
  }

  static func shuffled(_ source: [Int], size: Int, stream: UInt64) -> [Int] {
    var rng = SortedPeerRNG(
      state: seed ^ (UInt64(size) &* 0x100_0000_01B3) ^ (stream &* 0xD6E8_FEB8_6659_FD93))
    var a = source
    var i = a.count - 1
    while i > 0 {
      a.swapAt(i, rng.below(i + 1))
      i -= 1
    }
    return a
  }

  /// A key absent from the stored keys, used by the copy-then-insert tasks.
  var newKey: Int { missQueries[0] }
  /// A stored key, used by the copy-then-remove tasks.
  var existingKey: Int { hitQueries[0] }

  /// Reference result of a strict upper-bound query: the next stored key, or `nil`.
  func expectedUpperBound(_ q: Int) -> Int? {
    let next = q / 2 * 2 + 2
    return next <= 2 * (size - 1) ? next : nil
  }

  /// Reference `(sum of found successors, number of end results)` over `queries`.
  func expectedUpperBounds(_ queries: [Int]) -> (sum: Int, ends: Int) {
    var sum = 0
    var ends = 0
    for q in queries {
      if let n = expectedUpperBound(q) { sum &+= n } else { ends += 1 }
    }
    return (sum, ends)
  }

  /// Reference sum of the values stored for `sortedPairs`.
  var valueSum: Int { sortedKeys.reduce(0) { $0 &+ $1 &+ 1 } }
}

extension Benchmark {
  /// Registers the seeded input and every `peer` task of the Set/Dictionary matrix.
  public mutating func addSortedPeerBenchmarks() {
    registerInputGenerator(for: SortedPeerInput.self) { SortedPeerInput(size: $0) }
    addRedBlackTreeSetPeerBenchmarks()
    addSortedSetPeerBenchmarks()
    addRedBlackTreeDictionaryPeerBenchmarks()
    addSortedDictionaryPeerBenchmarks()
  }
}

/// Precondition used for the outside-the-timer correctness checks.
@inline(__always)
func peerCheck(
  _ condition: @autoclosure () -> Bool, _ task: StaticString, _ size: Int,
  file: StaticString = #fileID, line: UInt = #line
) {
  precondition(condition(), "peer check failed: \(task) at size \(size)", file: file, line: line)
}
