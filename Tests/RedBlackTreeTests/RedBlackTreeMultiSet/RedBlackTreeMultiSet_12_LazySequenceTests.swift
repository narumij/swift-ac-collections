import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultiSetLazySequenceTests: RedBlackTreeTestCase {

  func test_lazyIteration_preservesSortedOrder() {
    let set: RedBlackTreeMultiSet = [5, 2, 4, 1, 3, 2]

    XCTAssertEqual(Array(set.lazy), [1, 2, 2, 3, 4, 5])
  }

  func test_lazyMap_defersEvaluationUntilIteration() {
    let set: RedBlackTreeMultiSet = [5, 2, 4, 1, 3]
    var evaluationCount = 0
    let sequence = set.lazy.map {
      evaluationCount += 1
      return $0 * 2
    }

    XCTAssertEqual(evaluationCount, 0)
    XCTAssertEqual(Array(sequence), [2, 4, 6, 8, 10])
    XCTAssertEqual(evaluationCount, 5)
  }

  func test_lazyFilter_defersEvaluationUntilIteration() {
    let set: RedBlackTreeMultiSet = [5, 2, 4, 1, 3]
    var evaluationCount = 0
    let sequence = set.lazy.filter {
      evaluationCount += 1
      return $0.isMultiple(of: 2)
    }

    XCTAssertEqual(evaluationCount, 0)
    XCTAssertEqual(Array(sequence), [2, 4])
    XCTAssertEqual(evaluationCount, 5)
  }

  func test_lazyOperations_canBeChained() {
    let set: RedBlackTreeMultiSet = [5, 2, 4, 1, 3]
    let sequence = set.lazy
      .filter { $0.isMultiple(of: 2) }
      .map { $0 * 10 }

    XCTAssertEqual(Array(sequence), [20, 40])
    XCTAssertEqual(Array(set.lazy.prefix(3)), [1, 2, 3])
    XCTAssertEqual(Array(set.lazy.dropFirst(2)), [3, 4, 5])
  }

  func test_lazyOperations_handleEmptyAndSingleElementSets() {
    let empty = RedBlackTreeMultiSet<Int>()
    let single: RedBlackTreeMultiSet = [42]

    XCTAssertEqual(Array(empty.lazy), [])
    XCTAssertEqual(Array(empty.lazy.map { $0 * 2 }), [])
    XCTAssertEqual(Array(empty.lazy.filter { _ in true }), [])
    XCTAssertEqual(Array(single.lazy.map { $0 + 1 }), [43])
    XCTAssertEqual(Array(single.lazy.filter { $0 == 42 }), [42])
  }

  func test_lazySequence_keepsOriginalValueAfterSetMutation() {
    var set: RedBlackTreeMultiSet = [1, 2, 3]
    let sequence = set.lazy

    set.insert(4)

    XCTAssertEqual(Array(sequence), [1, 2, 3])
    XCTAssertEqual(Array(set), [1, 2, 3, 4])
  }

  func test_lazyEvaluation_stopsAtPrefix() {
    let set: RedBlackTreeMultiSet = [1, 2, 3, 4, 5]
    var evaluationCount = 0
    let sequence = set.lazy.map {
      evaluationCount += 1
      return $0
    }.prefix(2)

    XCTAssertEqual(evaluationCount, 0)
    XCTAssertEqual(Array(sequence), [1, 2])
    XCTAssertEqual(evaluationCount, 2)
  }
}
