//
//  RedBlackTreeSetLazySequenceTests.swift
//  swift-ac-collections
//

import RedBlackTreeCollections
import XCTest

final class RedBlackTreeSetLazySequenceTests: RedBlackTreeTestCase {

  func testLazyIteration() {
    let set: RedBlackTreeSet = [5, 2, 4, 1, 3]

    XCTAssertEqual(
      Array(set.lazy),
      [1, 2, 3, 4, 5]
    )
  }

  func testLazyMap() {
    let set: RedBlackTreeSet = [5, 2, 4, 1, 3]

    let sequence = set.lazy.map { $0 * 2 }

    XCTAssertEqual(
      Array(sequence),
      [2, 4, 6, 8, 10]
    )
  }

  func testLazyMapIsLazy() {
    let set: RedBlackTreeSet = [5, 2, 4, 1, 3]

    var count = 0

    let sequence = set.lazy.map {
      count += 1
      return $0 * 2
    }

    XCTAssertEqual(count, 0)

    XCTAssertEqual(
      Array(sequence),
      [2, 4, 6, 8, 10]
    )

    XCTAssertEqual(count, 5)
  }

  func testLazyFilter() {
    let set: RedBlackTreeSet = [5, 2, 4, 1, 3]

    let sequence = set.lazy.filter { $0.isMultiple(of: 2) }

    XCTAssertEqual(
      Array(sequence),
      [2, 4]
    )
  }

  func testLazyFilterIsLazy() {
    let set: RedBlackTreeSet = [5, 2, 4, 1, 3]

    var count = 0

    let sequence = set.lazy.filter {
      count += 1
      return $0.isMultiple(of: 2)
    }
    
    print(type(of: set.lazy))
    print(type(of: sequence))

    XCTAssertEqual(count, 0)

    XCTAssertEqual(
      Array(sequence),
      [2, 4]
    )

    XCTAssertEqual(count, 5)
  }

  func testLazyMapFilter() {
    let set: RedBlackTreeSet = [5, 2, 4, 1, 3]

    let sequence =
      set.lazy
      .filter { $0.isMultiple(of: 2) }
      .map { $0 * 10 }

    XCTAssertEqual(
      Array(sequence),
      [20, 40]
    )
  }

  func testLazyPrefix() {
    let set: RedBlackTreeSet = [5, 2, 4, 1, 3]

    XCTAssertEqual(
      Array(set.lazy.prefix(3)),
      [1, 2, 3]
    )
  }

  func testLazyDropFirst() {
    let set: RedBlackTreeSet = [5, 2, 4, 1, 3]

    XCTAssertEqual(
      Array(set.lazy.dropFirst(2)),
      [3, 4, 5]
    )
  }

  func testLazyEmptySet() {
    let set = RedBlackTreeSet<Int>()

    XCTAssertEqual(
      Array(set.lazy),
      []
    )

    XCTAssertEqual(
      Array(set.lazy.map { $0 * 2 }),
      []
    )

    XCTAssertEqual(
      Array(set.lazy.filter { _ in true }),
      []
    )
  }

  func testLazySingleElement() {
    let set: RedBlackTreeSet = [42]

    XCTAssertEqual(Array(set.lazy), [42])
    XCTAssertEqual(Array(set.lazy.map { $0 + 1 }), [43])
    XCTAssertEqual(Array(set.lazy.filter { $0 == 42 }), [42])
    XCTAssertEqual(Array(set.lazy.filter { $0 != 42 }), [])
  }

  func testLazySequenceKeepsOriginalValue() {
    var set: RedBlackTreeSet = [1, 2, 3]

    let sequence = set.lazy

    set.insert(4)

    XCTAssertEqual(
      Array(sequence),
      [1, 2, 3]
    )

    XCTAssertEqual(
      Array(set),
      [1, 2, 3, 4]
    )
  }

  func testLazyEvaluationStopsAtPrefix() {
    let set: RedBlackTreeSet = [1, 2, 3, 4, 5]

    var count = 0

    let sequence =
      set.lazy
      .map {
        count += 1
        return $0
      }
      .prefix(2)

    XCTAssertEqual(count, 0)

    XCTAssertEqual(
      Array(sequence),
      [1, 2]
    )

    XCTAssertEqual(count, 2)
  }
}
