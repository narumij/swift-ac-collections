import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultiSetBidirectionalCollectionTests: RedBlackTreeTestCase {

  func test_indicesTraverseDuplicatesInSortedOrder() {
    let multiset = RedBlackTreeMultiSet([3, 1, 2, 2])
    var index = multiset.startIndex
    var elements: [Int] = []

    while index != multiset.endIndex {
      elements.append(multiset[index])
      index = multiset.index(after: index)
    }

    XCTAssertEqual(elements, [1, 2, 2, 3])
  }

  func test_indexBefore_traversesDuplicatesInReverseOrder() {
    let multiset = RedBlackTreeMultiSet([3, 1, 2, 2])
    var index = multiset.endIndex
    var elements: [Int] = []

    while index != multiset.startIndex {
      index = multiset.index(before: index)
      elements.append(multiset[index])
    }

    XCTAssertEqual(elements, [3, 2, 2, 1])
  }

  func test_distanceAndOffsetIncludeDuplicatePositions() {
    let multiset = RedBlackTreeMultiSet([1, 2, 2, 3])

    XCTAssertEqual(multiset.distance(from: multiset.startIndex, to: multiset.endIndex), 4)
    XCTAssertEqual(multiset[multiset.index(multiset.startIndex, offsetBy: 2)], 2)
    XCTAssertEqual(multiset.index(multiset.endIndex, offsetBy: -4), multiset.startIndex)
  }

  func test_limitedOffset_stopsAtLimit() {
    let multiset = RedBlackTreeMultiSet([1, 2, 2, 3])

    XCTAssertEqual(
      multiset.index(multiset.startIndex, offsetBy: 4, limitedBy: multiset.endIndex),
      multiset.endIndex)
    XCTAssertNil(multiset.index(multiset.startIndex, offsetBy: 5, limitedBy: multiset.endIndex))
    XCTAssertNil(multiset.index(multiset.endIndex, offsetBy: -5, limitedBy: multiset.startIndex))
  }

  func test_formIndex_supportsForwardAndBackwardMovement() {
    let multiset = RedBlackTreeMultiSet([1, 2, 2, 3])
    var index = multiset.startIndex

    multiset.formIndex(after: &index)
    XCTAssertEqual(multiset[index], 2)
    multiset.formIndex(&index, offsetBy: 2)
    XCTAssertEqual(multiset[index], 3)
    multiset.formIndex(before: &index)
    XCTAssertEqual(multiset[index], 2)
  }
}

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSetBidirectionalCollectionTests {
    /// 移動量0はlimit上（空のendIndexを含む）でも成功し、limitを越える移動は失敗すること。
    func testIndexLimitedByZeroMovement() {
      func check<I: Equatable>(
        _ indices: [I],
        index offset: (I, Int, I) -> I?,
        formIndex: (inout I, Int, I) -> Bool
      ) {
        for index in indices {
          XCTAssertEqual(offset(index, 0, index), index)
          var current = index
          XCTAssertTrue(formIndex(&current, 0, index))
          XCTAssertEqual(current, index)
          XCTAssertNil(offset(index, 1, index))
          XCTAssertNil(offset(index, -1, index))
        }
      }
      for values in [[], [0, 1, 2]] {
        let c = RedBlackTreeMultiSet(values)
        check([c.startIndex, c.endIndex],
          index: c.index(_:offsetBy:limitedBy:),
          formIndex: c.formIndex(_:offsetBy:limitedBy:))
      }
    }
  }
#endif

#if !COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiSetBidirectionalCollectionTests {
    /// index(_:offsetBy:limitedBy:)に巨大な距離を渡しても、範囲の外に出たところで止まってnilを返すこと。
    func testIndexOffsetByHugeDistanceTerminates() {
      let c = RedBlackTreeMultiSet([0, 1, 2, 3])
      XCTAssertNil(c.index(c.startIndex, offsetBy: Int.max, limitedBy: c.endIndex))
      XCTAssertNil(c.index(c.endIndex, offsetBy: Int.min, limitedBy: c.startIndex))
    }

    /// `formIndex(_:offsetBy:limitedBy:)`が`String`と同じく、limit到達時は成功し、
    /// 超過時はlimitまで移動して失敗を返すこと。
    func testFormIndexLimitedByMatchesString() {
      let c = RedBlackTreeMultiSet([0, 1, 2, 3])
      let limit = c.index(after: c.startIndex)

      var exact = c.startIndex
      XCTAssertTrue(c.formIndex(&exact, offsetBy: 1, limitedBy: limit))
      XCTAssertEqual(exact, limit)

      var over = c.startIndex
      XCTAssertFalse(c.formIndex(&over, offsetBy: 2, limitedBy: limit))
      XCTAssertEqual(over, limit)
    }
  }
#endif
