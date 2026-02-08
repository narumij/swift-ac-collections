import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class RedBlackTreeComparatorsTests: RedBlackTreeTestCase {

  #if DEBUG
    func testSetKeyAndValueComp() {
      let set: RedBlackTreeSet = [3, 1, 4, 5]
      typealias SUT = RedBlackTreeSet<Int>
      let keyComp = SUT.value_comp
      let valueComp = { SUT.value_comp(SUT.__key($0), SUT.__key($1))}

      XCTAssertTrue(keyComp(1, 2))
      XCTAssertFalse(keyComp(2, 1))
      XCTAssertEqual(keyComp(3, 3), false)

      XCTAssertTrue(valueComp(1, 2))
      XCTAssertFalse(valueComp(2, 1))
    }
  #endif

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

  #if DEBUG
    func testMultisetKeyAndValueComp() {
      let multi: RedBlackTreeMultiSet = [1, 2, 3]
      typealias SUT = RedBlackTreeMultiSet<Int>
      let keyComp = SUT.value_comp
      let valueComp = { SUT.value_comp(SUT.__key($0), SUT.__key($1))}

      XCTAssertTrue(keyComp(1, 2))
      XCTAssertFalse(keyComp(3, 2))

      XCTAssertTrue(valueComp(1, 2))
      XCTAssertFalse(valueComp(3, 2))
    }

    func testDictionaryKeyValueCompAndEqualRange() {
      let dict: RedBlackTreeDictionary = ["a": 1, "b": 2, "c": 3]
      typealias SUT = RedBlackTreeDictionary<String,Int>
      let keyComp = SUT.value_comp
      let valueComp = { SUT.value_comp(SUT.__key($0), SUT.__key($1))}

      XCTAssertTrue(keyComp("a", "b"))
      XCTAssertFalse(keyComp("c", "b"))

      XCTAssertTrue(valueComp(_value("a", 1), _value("b", 2)))
      XCTAssertFalse(valueComp(_value("c", 3), _value("b", 2)))

      let (lo, hi) = dict.equalRange("b")
      XCTAssertEqual(dict[lo].key, "b")
      XCTAssertEqual(dict.distance(from: lo, to: hi), 1)
    }

    func testMultiMapKeyValueCompAndEqualRange() {
      let dict: RedBlackTreeMultiMap = ["a": 1, "b": 2, "c": 3]
      typealias SUT = RedBlackTreeMultiMap<String,Int>
      let keyComp = SUT.value_comp
      let valueComp = { SUT.value_comp(SUT.__key($0), SUT.__key($1))}

      XCTAssertTrue(keyComp("a", "b"))
      XCTAssertFalse(keyComp("c", "b"))

      XCTAssertTrue(valueComp(_value("a", 1), _value("b", 2)))
      XCTAssertFalse(valueComp(_value("c", 3), _value("b", 2)))

      let (lo, hi) = dict.equalRange("b")
      XCTAssertEqual(dict[lo].key, "b")
      XCTAssertEqual(dict.distance(from: lo, to: hi), 1)
    }
  #endif
}
