import RedBlackTreeModule
import XCTest

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
    let (lo, hi) = set.equalRange(3)
    XCTAssertEqual(set[lo], 3)
    XCTAssertEqual(set.distance(from: lo, to: hi), 1)
  }

  func testMultisetEqualRange() {
    let multi: RedBlackTreeMultiSet = [1, 2, 2, 2, 3, 4]
    let (lo, hi) = multi.equalRange(2)

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
    let multi: RedBlackTreeMultiSet = [1, 2, 3]
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

    let (lo, hi) = dict.equalRange("b")
    XCTAssertEqual(dict[lo].key, "b")
    XCTAssertEqual(dict.distance(from: lo, to: hi), 1)
  }

  #if !COMPATIBLE_ATCODER_2025
    func testMultiMapKeyValueCompAndEqualRange() {
      let dict: RedBlackTreeMultiMap = ["a": 1, "b": 2, "c": 3]

      let keyComp = dict.___key_comp
      let valueComp = dict.___value_comp

      XCTAssertTrue(keyComp("a", "b"))
      XCTAssertFalse(keyComp("c", "b"))

      XCTAssertTrue(valueComp(keyValue("a", 1), keyValue("b", 2)))
      XCTAssertFalse(valueComp(keyValue("c", 3), keyValue("b", 2)))

      let (lo, hi) = dict.equalRange("b")
      XCTAssertEqual(dict[lo].key, "b")
      XCTAssertEqual(dict.distance(from: lo, to: hi), 1)
    }
  #endif
}
