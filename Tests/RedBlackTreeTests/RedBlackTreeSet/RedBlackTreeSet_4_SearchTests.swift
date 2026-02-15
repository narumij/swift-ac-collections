import RedBlackTreeModule
import XCTest

final class RedBlackTreeSetSearchTests: RedBlackTreeTestCase {

  /// contains(_:) が要素存在確認を正しく行うこと
  func test_contains_shouldReturnCorrectResult() {
    // 事前: 集合に [1, 3, 5, 7, 9]
    let set = RedBlackTreeSet([1, 3, 5, 7, 9])

    // 事後: 含まれる要素についてtrue、含まれない要素についてfalse
    XCTAssertTrue(set.contains(3))
    XCTAssertFalse(set.contains(4))
  }

  /// lowerBound(_:) が指定要素以上の最初の位置を返すこと
  func test_lowerBound_shouldReturnCorrectIndex() {
    let set = RedBlackTreeSet([2, 4, 6, 8, 10])

    let index = set.lowerBound(5)
    XCTAssertEqual(set[index], 6)

    let indexAtOrBelow = set.lowerBound(2)
    XCTAssertEqual(set[indexAtOrBelow], 2)

    let indexAtEnd = set.lowerBound(11)
    XCTAssertEqual(indexAtEnd, set.endIndex)
  }

  /// upperBound(_:) が指定要素より大きい最初の位置を返すこと
  func test_upperBound_shouldReturnCorrectIndex() {
    let set = RedBlackTreeSet([2, 4, 6, 8, 10])

    let index = set.upperBound(6)
    XCTAssertEqual(set[index], 8)

    let indexAtOrAbove = set.upperBound(10)
    XCTAssertEqual(indexAtOrAbove, set.endIndex)
  }

  /// equalRange(_:) が指定要素の範囲（下限と上限）を返すこと
  func test_equalRange_shouldReturnCorrectRange() {
    let set = RedBlackTreeSet([1, 2, 3, 4, 5])

    let r = set.equalRange(3)
    let (lower, upper) = (r.lowerBound, r.upperBound)
    XCTAssertEqual(set[lower], 3)
    XCTAssertEqual(upper, set.index(after: lower))
  }

  /// firstIndex(of:) が要素の最初の位置を返すこと
  func test_firstIndex_of_shouldReturnCorrectIndex() {
    let set = RedBlackTreeSet([1, 2, 3, 4, 5])

    let index = set.firstIndex(of: 4)
    XCTAssertNotNil(index)
    XCTAssertEqual(set[index!], 4)

    let notFoundIndex = set.firstIndex(of: 10)
    XCTAssertNil(notFoundIndex)
  }

  #if COMPATIBLE_ATCODER_2025
    /// firstIndex(where:) が条件を満たす最初の要素位置を返すこと
    func test_firstIndex_where_shouldReturnCorrectIndex() {
      let set = RedBlackTreeSet([1, 2, 3, 4, 5])

      let index = set.firstIndex { $0 % 2 == 0 }  // 偶数
      XCTAssertNotNil(index)
      XCTAssertEqual(set[index!], 2)

      let noMatchIndex = set.firstIndex { $0 > 10 }
      XCTAssertNil(noMatchIndex)
    }
  #endif

  /// first(where:) が条件を満たす最初の要素を返すこと
  func test_first_where_shouldReturnCorrectElement() {
    let set = RedBlackTreeSet([1, 2, 3, 4, 5])

    let element = set.first { $0 % 2 == 0 }
    XCTAssertEqual(element, 2)

    let noMatchElement = set.first { $0 > 10 }
    XCTAssertNil(noMatchElement)
  }

  /// min() と max() が集合の最小値と最大値を返すこと
  func test_min_max_shouldReturnCorrectValues() {
    let set = RedBlackTreeSet([10, 20, 30, 40, 50])

    XCTAssertEqual(set.min(), 10)
    XCTAssertEqual(set.max(), 50)

    let emptySet = RedBlackTreeSet<Int>()
    XCTAssertNil(emptySet.min())
    XCTAssertNil(emptySet.max())
  }
}

extension RedBlackTreeSetSearchTests {

  /// first が集合の最初の要素を返すこと
  func test_first_shouldReturnFirstElement() {
    let set = RedBlackTreeSet([3, 1, 4, 2])
    XCTAssertEqual(set.first, 1)

    let emptySet = RedBlackTreeSet<Int>()
    XCTAssertNil(emptySet.first)
  }

  /// last が集合の最後の要素を返すこと
  func test_last_shouldReturnLastElement() {
    let set = RedBlackTreeSet([3, 1, 4, 2])
    XCTAssertEqual(set.last, 4)

    let emptySet = RedBlackTreeSet<Int>()
    XCTAssertNil(emptySet.last)
  }
}

extension RedBlackTreeSetSearchTests {

  /// elements(in:) が指定範囲の要素を正しく返すこと (半開区間)
  func test_elementsInRange() {
    let set = RedBlackTreeSet([1, 2, 3, 4, 5, 6, 7])
    let sub = set.elements(in: 3..<6)
    XCTAssertEqual(sub + [], [3, 4, 5])
  }

  /// elements(in:) が指定範囲の要素を正しく返すこと (閉区間)
  func test_elementsInClosedRange() {
    let set = RedBlackTreeSet([1, 2, 3, 4, 5, 6, 7])
    let sub = set.elements(in: 3...6)
    XCTAssertEqual(sub + [], [3, 4, 5, 6])
  }

  /// deprecated subscript(range) が正しく動作すること
  func test_deprecatedSubscriptRange() {
    let set = RedBlackTreeSet([1, 2, 3, 4, 5, 6, 7])
    let sub = set[3..<6]
    XCTAssertEqual(sub + [], [3, 4, 5])
  }

  /// deprecated subscript(closedRange) が正しく動作すること
  func test_deprecatedSubscriptClosedRange() {
    let set = RedBlackTreeSet([1, 2, 3, 4, 5, 6, 7])
    let sub = set[3...6]
    XCTAssertEqual(sub + [], [3, 4, 5, 6])
  }
}
