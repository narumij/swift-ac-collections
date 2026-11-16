// Tests-only experiment for PERM-059. This adapter is not product API.

#if !COMPATIBLE_ATCODER_2025
import NextPermutationModule
import Testing
import XCTest

private struct RuntimeCheckedPermutationSequence<Value: Comparable>: Sequence {
  typealias Element = NextPermutations<Value>.Permutation

  fileprivate final class Storage {
    var permutations: NextPermutations<Value>

    init(_ source: [Value]) {
      permutations = source.nextPermutations()
    }
  }

  struct Iterator: IteratorProtocol {
    fileprivate let storage: Storage

    mutating func next() -> Element? {
      storage.permutations.next()
    }
  }

  private let source: [Value]

  init<C: Collection>(_ source: C) where C.Element == Value {
    self.source = Array(source)
  }

  func makeIterator() -> Iterator {
    Iterator(storage: Storage(source))
  }
}

final class NextPermutationsSequenceExperimentTests: XCTestCase {
  private func checksum<S: Sequence>(_ permutations: S) -> (count: Int, checksum: Int)
  where S.Element: Collection, S.Element.Element == Int {
    var count = 0
    var checksum = 0
    for permutation in permutations {
      count += 1
      for (offset, element) in permutation.enumerated() {
        checksum &+= (offset + 1) &* element
      }
    }
    return (count, checksum)
  }

  private func manuallyGeneratedChecksum(_ source: [Int]) -> (count: Int, checksum: Int) {
    var permutations = source.nextPermutations()
    var count = 0
    var checksum = 0
    while let permutation = permutations.next() {
      count += 1
      for (offset, element) in permutation.enumerated() {
        checksum &+= (offset + 1) &* element
      }
    }
    return (count, checksum)
  }

  func testImmediateMapConsumptionPreservesEnumeration() {
    let sequence = RuntimeCheckedPermutationSequence([1, 2, 3])

    XCTAssertEqual(
      sequence.map(Array.init),
      [[1, 2, 3], [1, 3, 2], [2, 1, 3], [2, 3, 1], [3, 1, 2], [3, 2, 1]])
  }

  func testForInCanConsumeEachViewBeforeAdvancing() {
    let sequence = RuntimeCheckedPermutationSequence([0, 0, 1])
    var orders: [[Int]] = []

    for permutation in sequence {
      orders.append(Array(permutation))
    }

    XCTAssertEqual(orders, [[0, 0, 1], [0, 1, 0], [1, 0, 0]])
  }

  func testSeparateIteratorsOwnIndependentPermutationState() {
    let sequence = RuntimeCheckedPermutationSequence([1, 2, 3])
    var left = sequence.makeIterator()
    var right = sequence.makeIterator()

    XCTAssertEqual(left.next().map(Array.init), [1, 2, 3])
    XCTAssertEqual(left.next().map(Array.init), [1, 3, 2])
    XCTAssertEqual(right.next().map(Array.init), [1, 2, 3])
  }

  func testCopiedIteratorSharesPermutationState() {
    let sequence = RuntimeCheckedPermutationSequence([1, 2, 3])
    var left = sequence.makeIterator()
    var right = left

    XCTAssertEqual(left.next().map(Array.init), [1, 2, 3])
    XCTAssertEqual(right.next().map(Array.init), [1, 3, 2])
    XCTAssertEqual(left.next().map(Array.init), [2, 1, 3])
  }

  func testAdapterSnapshotsItsInput() {
    var source = [1, 2, 3]
    let sequence = RuntimeCheckedPermutationSequence(source)
    source[0] = 9
    var iterator = sequence.makeIterator()

    XCTAssertEqual(iterator.next().map(Array.init), [1, 2, 3])
    XCTAssertEqual(source, [9, 2, 3])
  }

  /// Discovery-only timing observation. There is deliberately no performance threshold here.
  /// The quality-assessment benchmark remains the authority for product performance claims.
  func testProvisionalPerformanceObservation() {
    let source = Array(repeating: 0, count: 8) + Array(repeating: 1, count: 8)
    let clock = ContinuousClock()
    var manualResult = (count: 0, checksum: 0)
    var sequenceResult = (count: 0, checksum: 0)

    let manualDuration = clock.measure {
      for _ in 0..<10 {
        manualResult = manuallyGeneratedChecksum(source)
      }
    }
    let sequenceDuration = clock.measure {
      for _ in 0..<10 {
        sequenceResult = checksum(RuntimeCheckedPermutationSequence(source))
      }
    }

    XCTAssertEqual(manualResult.count, 12_870)
    XCTAssertEqual(sequenceResult.count, manualResult.count)
    XCTAssertEqual(sequenceResult.checksum, manualResult.checksum)
    print("PERM-059 manual=\(manualDuration) sequence-adapter=\(sequenceDuration)")
  }
}

#if DEATH_TEST
struct NextPermutationsSequenceExperimentDeathTests {
  @Test func collectingViewsThenReadingAnEarlierViewTraps() async {
    await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
      let sequence = RuntimeCheckedPermutationSequence([1, 2, 3])
      let collected = Array(sequence)
      _ = collected[0].startIndex
    }
  }

  @Test func copiedIteratorInvalidatesTheOtherCopiesCurrentView() async {
    await #expect(processExitsWith: .signal(expectedSwiftTrapSignal)) {
      let sequence = RuntimeCheckedPermutationSequence([1, 2, 3])
      var left = sequence.makeIterator()
      var right = left
      let first = left.next()!
      _ = right.next()!
      _ = first.startIndex
    }
  }
}
#endif
#endif
