import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultiMapIndexRangeTests: RedBlackTreeTestCase {

  #if !COMPATIBLE_ATCODER_2025
    func test_distanceCountsDuplicatePositionsInBothDirections() {
      let multimap: RedBlackTreeMultiMap = [(0, "a"), (1, "b"), (1, "c"), (2, "d")]

      XCTAssertEqual(
        multimap.distance(from: multimap.startIndex, to: multimap.endIndex),
        multimap.count
      )
      XCTAssertEqual(
        multimap.distance(from: multimap.endIndex, to: multimap.startIndex),
        -multimap.count
      )
    }

    func test_indexAndFormIndex_moveForwardAndBackwardSymmetrically() {
      let multimap: RedBlackTreeMultiMap<Int, Int> = [(1, 10), (2, 20), (3, 30), (4, 40), (5, 50)]

      var i = multimap.startIndex
      for _ in 0..<multimap.count {
        XCTAssertEqual(multimap.distance(from: i, to: multimap.index(after: i)), 1)
        i = multimap.index(after: i)
      }
      XCTAssertEqual(i, multimap.endIndex)

      for _ in 0..<multimap.count {
        XCTAssertEqual(multimap.distance(from: i, to: multimap.index(before: i)), -1)
        i = multimap.index(before: i)
      }
      XCTAssertEqual(i, multimap.startIndex)

      for _ in 0..<multimap.count {
        multimap.formIndex(after: &i)
      }
      XCTAssertEqual(i, multimap.endIndex)

      for _ in 0..<multimap.count {
        multimap.formIndex(before: &i)
      }
      XCTAssertEqual(i, multimap.startIndex)
    }

    func testIsElementAndIsEndDistinguishElementFromEnd() {
      let multimap: RedBlackTreeMultiMap = [(0, "a"), (1, "b"), (1, "c"), (2, "d")]

      XCTAssertTrue(multimap.isElement(at: multimap.startIndex))
      XCTAssertFalse(multimap.isEnd(multimap.startIndex))
      XCTAssertFalse(multimap.isElement(at: multimap.endIndex))
      XCTAssertTrue(multimap.isEnd(multimap.endIndex))
    }

    func testIsEndRecognizesEmptyMultiMapEndIndex() {
      let multimap = RedBlackTreeMultiMap<Int, String>()

      XCTAssertFalse(multimap.isElement(at: multimap.endIndex))
      XCTAssertTrue(multimap.isEnd(multimap.endIndex))
    }

    func testIsElementAndIsEndRejectStaleIndex() {
      var multimap: RedBlackTreeMultiMap = [(0, "a"), (1, "b"), (1, "c"), (2, "d")]
      let index = multimap.firstIndex(of: 1)!

      multimap.remove(at: index)
      XCTAssertFalse(multimap.isElement(at: index))
      XCTAssertFalse(multimap.isEnd(index))
    }

    #if ALLOW_CROSS_TREE_INDEX
      func testIsElementAndIsEndResolveIndicesInCopiedTree() {
        let source: RedBlackTreeMultiMap = [(0, "a"), (1, "b"), (1, "c"), (2, "d")]
        let copy = source

        XCTAssertTrue(copy.isElement(at: source.firstIndex(of: 1)!))
        XCTAssertTrue(copy.isEnd(source.endIndex))
      }
    #endif
  #endif

  /// index(_:offsetBy:) が指定距離のエントリを指すこと
  func test_index_offsetBy() {
    let multimap: RedBlackTreeMultiMap = [(10, "a"), (20, "b"), (30, "c"), (40, "d"), (50, "e")]
    let start = multimap.startIndex

    let idx = multimap.index(start, offsetBy: 2)

    XCTAssertEqual(multimap[idx].key, 30)
  }

  /// index(_:offsetBy:limitedBy:) が制限範囲内では移動し、超過した場合はnilを返すこと
  func test_index_offsetBy_limitedBy() {
    let multimap: RedBlackTreeMultiMap = [(1, "a"), (2, "b"), (3, "c")]
    let start = multimap.startIndex
    let limit = multimap.index(after: start)

    let limitedIndex = multimap.index(start, offsetBy: 2, limitedBy: limit)

    XCTAssertNil(limitedIndex)
  }

  /// formIndex(_:offsetBy:) が正しく指定距離のエントリ位置に移動できること
  func test_formIndex_offsetBy() {
    let multimap: RedBlackTreeMultiMap = [(10, "a"), (20, "b"), (30, "c"), (40, "d"), (50, "e")]
    var idx = multimap.startIndex

    multimap.formIndex(&idx, offsetBy: 3)

    XCTAssertEqual(multimap[idx].key, 40)
  }

  /// formIndex(_:offsetBy:limitedBy:) が制限範囲内では移動し、超過した場合は失敗すること
  func test_formIndex_offsetBy_limitedBy() {
    let multimap: RedBlackTreeMultiMap = [(1, "a"), (2, "b"), (3, "c")]
    let start = multimap.startIndex
    let limit = multimap.index(after: start)

    var idx = start
    let success = multimap.formIndex(&idx, offsetBy: 2, limitedBy: limit)

    XCTAssertFalse(success)
  }
}
