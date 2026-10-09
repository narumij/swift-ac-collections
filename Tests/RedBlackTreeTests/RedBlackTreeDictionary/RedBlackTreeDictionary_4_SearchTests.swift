import RedBlackTreeCollections
import XCTest

final class RedBlackTreeDictionarySearchTests: RedBlackTreeTestCase {

  func test_containsKey_distinguishesPresentAndMissingKeys() {
    let dictionary: RedBlackTreeDictionary<String, Int> = ["a": 1, "b": 2]

    XCTAssertTrue(dictionary.contains(key: "a"))
    XCTAssertTrue(dictionary.contains(key: "b"))
    XCTAssertFalse(dictionary.contains(key: "c"))
  }

  /// キーはユニークなので、`count(forKey:)`は存在すれば1、存在しなければ0を返す。
  func test_countForKey_isOneWhenPresentAndZeroWhenMissing() {
    let dictionary: RedBlackTreeDictionary<String, Int> = ["a": 1, "b": 2]

    XCTAssertEqual(dictionary.count(forKey: "a"), 1)
    XCTAssertEqual(dictionary.count(forKey: "b"), 1)
    XCTAssertEqual(dictionary.count(forKey: "c"), 0)
  }

  func test_lowerAndUpperBound_findInsertionPositionsByKey() {
    let dictionary: RedBlackTreeDictionary<Int, String> = [1: "a", 3: "c", 5: "e"]

    XCTAssertEqual(dictionary.lowerBound(2), dictionary.firstIndex(of: 3))
    XCTAssertEqual(dictionary.lowerBound(3), dictionary.firstIndex(of: 3))
    XCTAssertEqual(dictionary.upperBound(3), dictionary.firstIndex(of: 5))
    XCTAssertEqual(dictionary.upperBound(5), dictionary.endIndex)
  }

  func test_firstIndex_findsEntryByKey() {
    let dictionary: RedBlackTreeDictionary<Int, String> = [1: "a", 3: "c", 5: "e"]

    let index = dictionary.firstIndex(of: 3)

    XCTAssertEqual(index.map { dictionary[$0].value }, "c")
    XCTAssertNil(dictionary.firstIndex(of: 4))
  }

  func test_firstAndLast_followKeyOrder() {
    let dictionary: RedBlackTreeDictionary<Int, String> = [3: "c", 1: "a", 2: "b"]

    XCTAssertEqual(dictionary.first?.key, 1)
    XCTAssertEqual(dictionary.first?.value, "a")
    XCTAssertEqual(dictionary.last?.key, 3)
    XCTAssertEqual(dictionary.last?.value, "c")
  }

  func test_minAndMax_areNilWhenEmptyAndFollowKeyOrderOtherwise() {
    let empty = RedBlackTreeDictionary<Int, String>()
    let dictionary: RedBlackTreeDictionary<Int, String> = [3: "c", 1: "a", 2: "b"]

    XCTAssertNil(empty.min())
    XCTAssertNil(empty.max())
    XCTAssertEqual(dictionary.min()?.key, 1)
    XCTAssertEqual(dictionary.max()?.key, 3)
  }
}

  import RedBlackTreeCollections
  import XCTest

  final class RedBlackTreeDictionaryFindTests: RedBlackTreeTestCase {

    /// `find(_:)`はキーの位置を返し、無ければ`endIndex`を返すこと。
    func testFindReturnsKeyIndexOrEndIndex() {
      let d: RedBlackTreeDictionary = [1: "a", 2: "b", 3: "c"]
      let i = d.find(2)
      XCTAssertEqual(d[i].key, 2)
      XCTAssertEqual(d[i].value, "b")
      XCTAssertEqual(d.find(9), d.endIndex)
    }
  }
