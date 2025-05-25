import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class RedBlackTreeMultiMapInitializationTests: XCTestCase {

  // MARK: - 「空は空である」と「空でないものは空ではない」のトートロジー

  /// 共通テストデータ
  let elements: [(String, Int)] = [
    ("cherry", 4),
    ("apple", 1),
    ("banana", 2),
    ("apple", 3),
  ]

  /// 空初期化テスト
  func testEmptyInitialization() {
    let multiMap = RedBlackTreeMultiMap<String, Int>()
    XCTAssertTrue(multiMap.isEmpty, "初期化直後は空であるべき")
    XCTAssertEqual(multiMap.count, 0, "要素数は0であるべき")
  }

  /// シーケンス初期化テスト（配列使用）
  func testSequenceInitialization() {
    let multiMap = RedBlackTreeMultiMap(keysWithValues: elements)

    let expected = [
      ("apple", 1),
      ("apple", 3),
      ("banana", 2),
      ("cherry", 4),
    ]

    XCTAssertEqual(multiMap.count, elements.count)
    XCTAssertEqual(multiMap.map { $0.key }, expected.map { $0.0 })
    XCTAssertEqual(multiMap.map { $0.value }, expected.map { $0.1 })
  }

  /// シーケンス初期化テスト（AnySequence使用）
  func testSequenceInitializationWithAnySequence() {
    let multiMap = RedBlackTreeMultiMap(keysWithValues: AnySequence(elements))

    let expected = [
      ("apple", 1),
      ("apple", 3),
      ("banana", 2),
      ("cherry", 4),
    ]

    XCTAssertEqual(multiMap.count, elements.count)
    XCTAssertEqual(multiMap.map { $0.key }, expected.map { $0.0 })
    XCTAssertEqual(multiMap.map { $0.value }, expected.map { $0.1 })
  }

  /// 最小容量指定で初期化
  func testInitWithMinimumCapacity() {
    let multiMap = RedBlackTreeMultiMap<String, Int>(minimumCapacity: 10)
    XCTAssertGreaterThanOrEqual(multiMap.capacity, 10, "指定したサイズ以上であること")
    XCTAssertTrue(multiMap.isEmpty, "最小容量指定後も空であるべき")
  }

  // MARK: - キャパシティは別腹

  /// reserveCapacityにより容量が指定値以上に増加すること
  func test_reserveCapacity_shouldIncreaseCapacity() {
    // 事前条件: 空集合を生成
    var multiMap = RedBlackTreeMultiMap<String, Int>()
    let initialCapacity = multiMap.capacity

    // 実行: reserveCapacity(20)
    multiMap.reserveCapacity(20)

    // 事後条件:
    XCTAssertGreaterThanOrEqual(multiMap.capacity, 20, "指定したサイズ以上であること")
    XCTAssertGreaterThanOrEqual(multiMap.capacity, initialCapacity, "初期サイズ以上であること")
    XCTAssertTrue(multiMap.isEmpty, "容量予約後も要素は追加されない")
  }
}
