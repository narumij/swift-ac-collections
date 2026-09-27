import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

final class RedBlackTreeComparatorsTests: RedBlackTreeTestCase {

  #if DEBUG
    func testNodePathBitmapEndSortsAfterEveryPath() {
      XCTAssertLessThan(_NodePathBitmap.path(.min), .end)
      XCTAssertLessThan(_NodePathBitmap.path(0), .end)
      XCTAssertLessThan(_NodePathBitmap.path(.max), .end)
    }

    func testNodePathBitmapPathsUseBitmapValueOrder() {
      let lower: _NodePathBitmap.NodePathBitmap = 1
      let middle: _NodePathBitmap.NodePathBitmap = 2
      let upper: _NodePathBitmap.NodePathBitmap = .max

      XCTAssertLessThan(_NodePathBitmap.path(lower), .path(middle))
      XCTAssertLessThan(_NodePathBitmap.path(middle), .path(upper))
      XCTAssertFalse(_NodePathBitmap.path(middle) < .path(lower))
    }

    func testNodeKeyEndSortsAfterEveryKey() {
      typealias SUT = _NodeKey<RedBlackTreeSet<Int>.Base>

      XCTAssertLessThan(SUT.key(.min), .end)
      XCTAssertLessThan(SUT.key(0), .end)
      XCTAssertLessThan(SUT.key(.max), .end)
    }

    func testNodeKeysUseKeyValueOrder() {
      typealias SUT = _NodeKey<RedBlackTreeSet<Int>.Base>

      XCTAssertLessThan(SUT.key(1), .key(2))
      XCTAssertLessThan(SUT.key(2), .key(.max))
      XCTAssertFalse(SUT.key(2) < .key(1))
    }

    func testLessThanGeneratesMissingNodePathBitmaps() {
      let set: RedBlackTreeSet = [0, 1]
      let lhs = set.__tree_.__purified_(set.startIndex).accessible.pointer!
      let rhsIndex = set.index(after: set.startIndex)
      let rhs = set.__tree_.__purified_(rhsIndex).accessible.pointer!

      let result = _NodePathBitmap.lessThan(
        lhs: (node: lhs, bitmap: nil),
        rhs: (node: rhs, bitmap: nil)
      )

      XCTAssertEqual(result.result, _NodePathBitmap(lhs) < _NodePathBitmap(rhs))
      XCTAssertEqual(result.lhsBitmap, _NodePathBitmap(lhs))
      XCTAssertEqual(result.rhsBitmap, _NodePathBitmap(rhs))
    }

    func testLessThanReusesProvidedNodePathBitmaps() {
      let set: RedBlackTreeSet = [0, 1]
      let lhs = set.__tree_.__purified_(set.startIndex).accessible.pointer!
      let rhsIndex = set.index(after: set.startIndex)
      let rhs = set.__tree_.__purified_(rhsIndex).accessible.pointer!
      let lhsBitmap = _NodePathBitmap.path(.max)
      let rhsBitmap = _NodePathBitmap.path(.min)

      let result = _NodePathBitmap.lessThan(
        lhs: (node: lhs, bitmap: lhsBitmap),
        rhs: (node: rhs, bitmap: rhsBitmap)
      )

      XCTAssertFalse(result.result)
      XCTAssertEqual(result.lhsBitmap, lhsBitmap)
      XCTAssertEqual(result.rhsBitmap, rhsBitmap)
    }

    func testNodeKeyLessThanTreatsIdenticalPointersAsEqual() {
      typealias SUT = _NodeKey<RedBlackTreeSet<Int>.Base>
      let set: RedBlackTreeSet = [0]
      let node = set.__tree_.__purified_(set.startIndex).accessible.pointer!

      let result = SUT.lessThan(
        lhs: (node: node, bitmap: nil),
        rhs: (node: node, bitmap: nil)
      )

      XCTAssertFalse(result.result)
      XCTAssertNil(result.lhsBitmap)
      XCTAssertNil(result.rhsBitmap)
    }
  #endif

  #if DEBUG
    func testSetKeyAndValueComp() {
      let set: RedBlackTreeSet = [3, 1, 4, 5]
      typealias SUT = RedBlackTreeSet<Int>.Base
      let keyComp = SUT.value_comp
      let valueComp = { SUT.value_comp(SUT.__key($0), SUT.__key($1)) }

      XCTAssertTrue(keyComp(1, 2))
      XCTAssertFalse(keyComp(2, 1))
      XCTAssertEqual(keyComp(3, 3), false)

      XCTAssertTrue(valueComp(1, 2))
      XCTAssertFalse(valueComp(2, 1))
    }
  #endif

  #if DEBUG
    func testSetEqualRange() {
      let set: RedBlackTreeSet = [1, 2, 3, 4, 5]
      let r = set.equalRange(3)
      let (lo, hi) = (r.lower, r.upper)
      XCTAssertEqual(set[lo], 3)
      XCTAssertEqual(set.distance(from: lo, to: hi), 1)
    }

    func testMultisetEqualRange() {
      let multi: RedBlackTreeMultiSet = [1, 2, 2, 2, 3, 4]
      let r = multi.equalRange(2)
      let (lo, hi) = (r.lower, r.upper)

      var count = 0
      var idx = lo
      while idx != hi {
        XCTAssertEqual(multi[idx], 2)
        count += 1
        idx = multi.index(after: idx)
      }
      XCTAssertEqual(count, 3)
    }
  #endif

  #if DEBUG
    func testMultisetKeyAndValueComp() {
      let multi: RedBlackTreeMultiSet = [1, 2, 3]
      typealias SUT = RedBlackTreeMultiSet<Int>.Base
      let keyComp = SUT.value_comp
      let valueComp = { SUT.value_comp(SUT.__key($0), SUT.__key($1)) }

      XCTAssertTrue(keyComp(1, 2))
      XCTAssertFalse(keyComp(3, 2))

      XCTAssertTrue(valueComp(1, 2))
      XCTAssertFalse(valueComp(3, 2))
    }

    func testDictionaryKeyValueCompAndEqualRange() {
      let dict: RedBlackTreeDictionary = ["a": 1, "b": 2, "c": 3]
      typealias SUT = RedBlackTreeDictionary<String, Int>.Base
      let keyComp = SUT.value_comp
      let valueComp = { SUT.value_comp(SUT.__key($0), SUT.__key($1)) }

      XCTAssertTrue(keyComp("a", "b"))
      XCTAssertFalse(keyComp("c", "b"))

      XCTAssertTrue(valueComp(_value("a", 1), _value("b", 2)))
      XCTAssertFalse(valueComp(_value("c", 3), _value("b", 2)))

      let r = dict.equalRange("b")
      let (lo, hi) = (r.lower, r.upper)
      XCTAssertEqual(dict[lo].key, "b")
      XCTAssertEqual(dict.distance(from: lo, to: hi), 1)
    }

    func testMultiMapKeyValueCompAndEqualRange() {
      let dict: RedBlackTreeMultiMap = ["a": 1, "b": 2, "c": 3]
      typealias SUT = RedBlackTreeMultiMap<String, Int>.Base
      let keyComp = SUT.value_comp
      let valueComp = { SUT.value_comp(SUT.__key($0), SUT.__key($1)) }

      XCTAssertTrue(keyComp("a", "b"))
      XCTAssertFalse(keyComp("c", "b"))

      XCTAssertTrue(valueComp(_value("a", 1), _value("b", 2)))
      XCTAssertFalse(valueComp(_value("c", 3), _value("b", 2)))

      let r = dict.equalRange("b")
      let (lo, hi) = (r.lower, r.upper)
      XCTAssertEqual(dict[lo].key, "b")
      XCTAssertEqual(dict.distance(from: lo, to: hi), 1)
    }
  #endif
}
