import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class RedBlackTreeSetProtocolConformanceTests: XCTestCase {}

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
