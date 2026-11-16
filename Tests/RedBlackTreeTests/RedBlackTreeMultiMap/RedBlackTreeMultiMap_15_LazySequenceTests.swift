import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultiMapLazySequenceTests: RedBlackTreeTestCase {

  func test_lazyIteration_preservesSortedOrder() {
    let multimap: RedBlackTreeMultiMap = [5: "e", 2: "b", 4: "d", 1: "a", 3: "c", 2: "b2"]

    XCTAssertEqual(Array(multimap.lazy.map(\.key)), [1, 2, 2, 3, 4, 5])
  }

  func test_lazyMap_defersEvaluationUntilIteration() {
    let multimap: RedBlackTreeMultiMap = [5: "e", 2: "b", 4: "d", 1: "a", 3: "c"]
    var evaluationCount = 0
    let sequence = multimap.lazy.map {
      evaluationCount += 1
      return $0.key * 2
    }

    XCTAssertEqual(evaluationCount, 0)
    XCTAssertEqual(Array(sequence), [2, 4, 6, 8, 10])
    XCTAssertEqual(evaluationCount, 5)
  }

  func test_lazyFilter_defersEvaluationUntilIteration() {
    let multimap: RedBlackTreeMultiMap = [5: "e", 2: "b", 4: "d", 1: "a", 3: "c"]
    var evaluationCount = 0
    let sequence = multimap.lazy.filter {
      evaluationCount += 1
      return $0.key.isMultiple(of: 2)
    }

    XCTAssertEqual(evaluationCount, 0)
    XCTAssertEqual(Array(sequence).map(\.key), [2, 4])
    XCTAssertEqual(evaluationCount, 5)
  }

  func test_lazyOperations_canBeChained() {
    let multimap: RedBlackTreeMultiMap = [5: "e", 2: "b", 4: "d", 1: "a", 3: "c"]
    let sequence = multimap.lazy
      .filter { $0.key.isMultiple(of: 2) }
      .map { $0.key * 10 }

    XCTAssertEqual(Array(sequence), [20, 40])
    XCTAssertEqual(Array(multimap.lazy.prefix(3)).map(\.key), [1, 2, 3])
    XCTAssertEqual(Array(multimap.lazy.dropFirst(2)).map(\.key), [3, 4, 5])
  }

  func test_lazyOperations_handleEmptyAndSingleElementMultiMaps() {
    let empty = RedBlackTreeMultiMap<Int, String>()
    let single: RedBlackTreeMultiMap = [42: "z"]

    XCTAssertEqual(Array(empty.lazy).map(\.key), [])
    XCTAssertEqual(Array(empty.lazy.map { $0.key * 2 }), [])
    XCTAssertEqual(Array(empty.lazy.filter { _ in true }).map(\.key), [])
    XCTAssertEqual(Array(single.lazy.map { $0.key + 1 }), [43])
    XCTAssertEqual(Array(single.lazy.filter { $0.key == 42 }).map(\.key), [42])
  }

  func test_lazySequence_keepsOriginalValueAfterMultiMapMutation() {
    var multimap: RedBlackTreeMultiMap = [1: "a", 2: "b", 3: "c"]
    let sequence = multimap.lazy

    multimap.insert(key: 4, value: "d")

    XCTAssertEqual(Array(sequence).map(\.key), [1, 2, 3])
    XCTAssertEqual(Array(multimap).map(\.key), [1, 2, 3, 4])
  }

  func test_lazyEvaluation_stopsAtPrefix() {
    let multimap: RedBlackTreeMultiMap = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]
    var evaluationCount = 0
    let sequence = multimap.lazy.map {
      evaluationCount += 1
      return $0.key
    }.prefix(2)

    XCTAssertEqual(evaluationCount, 0)
    XCTAssertEqual(Array(sequence), [1, 2])
    XCTAssertEqual(evaluationCount, 2)
  }
}
