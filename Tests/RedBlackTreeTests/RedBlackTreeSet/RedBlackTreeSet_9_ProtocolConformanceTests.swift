import RedBlackTreeCollections
import XCTest

final class RedBlackTreeSetProtocolConformanceTests: RedBlackTreeTestCase {}

// MARK: - Equatable
extension RedBlackTreeSetProtocolConformanceTests {

  func test_equatable_setsAreEqual() {
    let a: RedBlackTreeSet = [1, 2, 3]
    let b: RedBlackTreeSet = [3, 1, 2]
    XCTAssertEqual(a, b, "同じ要素を持つ集合は等しいこと")
  }

  func test_equatable_setsAreNotEqual() {
    let a: RedBlackTreeSet = [1, 2, 3]
    let b: RedBlackTreeSet = [4, 5, 6]
    XCTAssertNotEqual(a, b, "異なる要素を持つ集合は等しくないこと")
  }
}

// MARK: - CustomStringConvertible
extension RedBlackTreeSetProtocolConformanceTests {

  func test_customStringConvertible_description() {
    let set: RedBlackTreeSet = [1, 2, 3]
    let description = set.description
    XCTAssertTrue(
      description.contains("1") && description.contains("2") && description.contains("3"),
      "descriptionが要素を含む文字列を返すこと")
  }
}

// MARK: - CustomDebugStringConvertible
extension RedBlackTreeSetProtocolConformanceTests {

  func test_customDebugStringConvertible_debugDescription() {
    let set: RedBlackTreeSet = [1, 2, 3]
    let debugDescription = set.debugDescription
    XCTAssertTrue(
      debugDescription.contains(set.description),
      "debugDescriptionがdescriptionを含む形式であること")
  }
}

// MARK: - ExpressibleByArrayLiteral
extension RedBlackTreeSetProtocolConformanceTests {

  func test_expressibleByArrayLiteral() {
    let set: RedBlackTreeSet = [10, 20, 30]
    XCTAssertTrue(
      set.contains(10) && set.contains(20) && set.contains(30),
      "配列リテラル初期化が正しく要素を格納すること")
  }
}

// MARK: - Index: Equatable, Comparable, Hashable
extension RedBlackTreeSetProtocolConformanceTests {

  func test_index_equatable() {
    let set = RedBlackTreeSet<Int>(0..<10)
    XCTAssertEqual(set.startIndex, set.startIndex)
    XCTAssertNotEqual(set.startIndex, set.endIndex)
  }

  #if DEBUG
    func test_index_comparable() {
      let set = RedBlackTreeSet<Int>(0..<10)
      XCTAssertLessThan(set.startIndex, set.endIndex)
    }
  #endif

    func test_index_hashable() {
      let set = RedBlackTreeSet<Int>(0..<10)
      var hasher = Hasher()
      set.startIndex.hash(into: &hasher)
      _ = hasher.finalize()
    }
}

// MARK: - elementsEqual / lexicographicallyPrecedes
extension RedBlackTreeSetProtocolConformanceTests {

  func test_elementsEqual_trueForSameElementsInOrder() {
    let set: RedBlackTreeSet = [1, 2, 3]
    XCTAssertTrue(set.elementsEqual([1, 2, 3]))
  }

  func test_elementsEqual_falseForDifferentElements() {
    let set: RedBlackTreeSet = [1, 2, 3]
    XCTAssertFalse(set.elementsEqual([1, 2, 4]))
  }

  func test_lexicographicallyPrecedes_trueWhenSmallerAtFirstDifference() {
    let set: RedBlackTreeSet = [1, 2, 3]
    XCTAssertTrue(set.lexicographicallyPrecedes([1, 2, 4]))
  }

  func test_lexicographicallyPrecedes_falseWhenEqualOrGreater() {
    let set: RedBlackTreeSet = [1, 2, 3]
    XCTAssertFalse(set.lexicographicallyPrecedes([1, 2, 3]))
    XCTAssertFalse(set.lexicographicallyPrecedes([1, 2, 2]))
  }

  func test_lexicographicallyPrecedes_comparesLengthAfterCommonPrefix() {
    let shorter: RedBlackTreeSet = [1, 2]
    let longer: RedBlackTreeSet = [1, 2, 3]
    XCTAssertTrue(shorter.lexicographicallyPrecedes(longer))
    XCTAssertFalse(longer.lexicographicallyPrecedes(shorter))
  }
}
