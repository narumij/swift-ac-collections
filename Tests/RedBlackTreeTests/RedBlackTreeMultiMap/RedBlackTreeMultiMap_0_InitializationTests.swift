import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class RedBlackTreeMultiMapInitializationTests: XCTestCase {

  // MARK: - 「空なものは空である」と「空でないものは空ではない」のトートロジー

  /// 共通テストデータ
  let elements: [(String, Int)] = [
    ("cherry", 4),
    ("apple", 1),
    ("banana", 2),
    ("apple", 3),
  ]

  /// 空初期化テスト
  func testEmptyInitialization() {
    // 事前条件: 空のマルチマップを初期化
    let multiMap = RedBlackTreeMultiMap<String, Int>()
    
    XCTAssertTrue(multiMap.isEmpty, "空であること")
    XCTAssertEqual(multiMap.count, 0, "要素数0であること")
  }
  
  /// 最小容量指定初期化が成功し、空であること
  func test_minimumCapacityInitialization() {
    // 事前条件: 最小容量10で初期化
    let multiMap = RedBlackTreeMultiMap<String, Int>(minimumCapacity: 10)

    // 事後条件: 空であること、容量が最低10以上
    XCTAssertTrue(multiMap.isEmpty, "空であること")
    XCTAssertEqual(multiMap.count, 0, "要素数0であること")
    XCTAssertGreaterThanOrEqual(multiMap.capacity, 10, "指定したサイズ以上であること")
  }

  /// シーケンス初期化テスト（配列使用）
  func testSequenceInitialization() {
    let multiMap = RedBlackTreeMultiMap<String, Int>(multiKeysWithValues: elements)

    let expected = [
      ("apple", 1),
      ("apple", 3),
      ("banana", 2),
      ("cherry", 4),
    ]

    XCTAssertFalse(multiMap.isEmpty, "空ではないこと")
    XCTAssertEqual(multiMap.count, expected.count, "要素数が期待通りであること")
  }

  /// シーケンス初期化テスト（AnySequence使用）
  func testSequenceInitializationWithAnySequence() {
    let multiMap = RedBlackTreeMultiMap<String, Int>(multiKeysWithValues: AnySequence(elements))

    let expected = [
      ("apple", 1),
      ("apple", 3),
      ("banana", 2),
      ("cherry", 4),
    ]

    XCTAssertFalse(multiMap.isEmpty, "空ではないこと")
    XCTAssertEqual(multiMap.count, expected.count, "要素数が期待通りであること")
  }

  /// 最小容量指定で初期化
  func testInitWithMinimumCapacity() {
    let multiMap = RedBlackTreeMultiMap<String, Int>(minimumCapacity: 10)
    XCTAssertTrue(multiMap.isEmpty, "空であること")
    XCTAssertEqual(multiMap.count, 0, "要素数0であること")
    XCTAssertGreaterThanOrEqual(multiMap.capacity, 10, "指定したサイズ以上であること")
  }

  // MARK: - キャパシティは別腹

  /// reserveCapacityにより容量が指定値以上に増加すること
  func test_empty_reserveCapacity_shouldIncreaseCapacity() {
    // 事前条件: 空集合を生成
    var multiMap = RedBlackTreeMultiMap<String, Int>()

    // 実行: reserveCapacity(20)
    multiMap.reserveCapacity(20)

    // 事後条件:
    XCTAssertGreaterThanOrEqual(multiMap.capacity, 20, "指定したサイズ以上であること")
    XCTAssertTrue(multiMap.isEmpty, "空であること")
  }
  
  /// reserveCapacityにより容量が指定値以上に増加すること
  func test_reserveCapacity_shouldIncreaseCapacity2() {
    var multiset = RedBlackTreeMultiMap<String, Int>(multiKeysWithValues: [("a",1)])
    let initialCount = multiset.count

    // 事前条件:
    XCTAssertFalse(multiset.isEmpty, "空では無いこと")
    XCTAssertEqual(multiset.count, 1, "要素数3であること")
    XCTAssertEqual(multiset.count, initialCount)

    // 実行: reserveCapacity(20)
    multiset.reserveCapacity(20)

    // 事後条件:
    XCTAssertGreaterThanOrEqual(multiset.capacity, 20, "指定したサイズ以上であること")
    XCTAssertFalse(multiset.isEmpty, "空ではないまま変化しないこと")
    XCTAssertEqual(multiset.count, initialCount, "要素数3のまま変化しないこと")
  }
}
