import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class RedBlackTreeMultiMapInitializationTests: XCTestCase {

  let elements: [(String, Int)] = [
    ("apple", 1),
    ("banana", 2),
    ("apple", 3),
    ("cherry", 4),
  ]

  func testEmptyInitialization() {
    let multiMap = RedBlackTreeMultiMap<String, Int>()
    XCTAssertTrue(multiMap.isEmpty)
    XCTAssertEqual(multiMap.count, 0)
  }

  func testSequenceInitialization() {
    let multiMap = RedBlackTreeMultiMap(keysWithValues: elements)

    XCTAssertEqual(multiMap.count, elements.count)
    XCTAssertEqual(Set(multiMap.values(forKey: "apple")), Set([1, 3]))
    XCTAssertEqual(Set(multiMap.values(forKey: "banana")), Set([2]))
    XCTAssertEqual(Set(multiMap.values(forKey: "cherry")), Set([4]))
  }

  func testSequenceInitialization2() {
    let multiMap = RedBlackTreeMultiMap(keysWithValues: AnySequence(elements))

    XCTAssertEqual(multiMap.count, elements.count)
    XCTAssertEqual(Set(multiMap.values(forKey: "apple")), Set([1, 3]))
    XCTAssertEqual(Set(multiMap.values(forKey: "banana")), Set([2]))
    XCTAssertEqual(Set(multiMap.values(forKey: "cherry")), Set([4]))
  }

  /// 容量予約後の状態を確認
  func testReserveCapacityOnEmptyDictionary() {
    var dict = RedBlackTreeMultiMap<String, Int>()
    dict.reserveCapacity(20)
    XCTAssertTrue(dict.isEmpty, "容量予約後も要素は追加されない")
  }
}
