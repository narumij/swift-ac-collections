import XCTest

import RedBlackTreeModule

final class RedBlackTreeComparatorsTests: XCTestCase {

  func testSetKeyAndValueComp() {
    let set: RedBlackTreeSet = [3, 1, 4, 5]
    let keyComp = set.___key_comp
    let valueComp = set.___value_comp

    XCTAssertTrue(keyComp(1, 2))
    XCTAssertFalse(keyComp(2, 1))
    XCTAssertEqual(keyComp(3, 3), false)

    XCTAssertTrue(valueComp(1, 2))
    XCTAssertFalse(valueComp(2, 1))
  }

  func testSetEqualRange() {
    let set: RedBlackTreeSet = [1, 2, 3, 4, 5]
    let (lo, hi) = set.___equal_range(3)
    XCTAssertEqual(set[lo], 3)
    XCTAssertEqual(set.distance(from: lo, to: hi), 1)
  }

  func testMultisetEqualRange() {
    let multi: RedBlackTreeMultiset = [1, 2, 2, 2, 3, 4]
    let (lo, hi) = multi.___equal_range(2)

    var count = 0
    var idx = lo
    while idx != hi {
      XCTAssertEqual(multi[idx], 2)
      count += 1
      idx = multi.index(after: idx)
    }
    XCTAssertEqual(count, 3)
  }

  func testMultisetKeyAndValueComp() {
    let multi: RedBlackTreeMultiset = [1, 2, 3]
    let keyComp = multi.___key_comp
    let valueComp = multi.___value_comp

    XCTAssertTrue(keyComp(1, 2))
    XCTAssertFalse(keyComp(3, 2))

    XCTAssertTrue(valueComp(1, 2))
    XCTAssertFalse(valueComp(3, 2))
  }

  func testDictionaryKeyValueCompAndEqualRange() {
    let dict: RedBlackTreeDictionary = ["a": 1, "b": 2, "c": 3]

    let keyComp = dict.___key_comp
    let valueComp = dict.___value_comp

    XCTAssertTrue(keyComp("a", "b"))
    XCTAssertFalse(keyComp("c", "b"))

    XCTAssertTrue(valueComp(("a", 1), ("b", 2)))
    XCTAssertFalse(valueComp(("c", 3), ("b", 2)))

    let (lo, hi) = dict.___equal_range("b")
    XCTAssertEqual(dict[lo].key, "b")
    XCTAssertEqual(dict.distance(from: lo, to: hi), 1)
  }
}
