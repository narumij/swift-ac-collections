import XCTest
import RedBlackTreeModule

final class RedBlackTreeMultiSetInitializationTests: RedBlackTreeTestCase {

  // MARK: - 「空なものは空である」と「空でないものは空ではない」のトートロジー

  /// 空の初期化が成功し、プロパティが空を示していること
  func test_emptyInitialization() {
    // 事前条件: 空のマルチセットを初期化
    let multiset = RedBlackTreeMultiSet<Int>()

    // 事後条件: 空であること
    XCTAssertTrue(multiset.isEmpty, "空であること")
    XCTAssertEqual(multiset.count, 0, "要素数0であること")
  }

  /// 最小容量指定初期化が成功し、プロパティが空を示していること
  func test_minimumCapacityInitialization() {
    // 事前条件: 最小容量10で初期化
    let multiset = RedBlackTreeMultiSet<Int>(minimumCapacity: 10)

    // 事後条件: 空であること、容量が最低10以上
    XCTAssertTrue(multiset.isEmpty, "空であること")
    XCTAssertEqual(multiset.count, 0, "要素数0であること")
    XCTAssertGreaterThanOrEqual(multiset.capacity, 10, "指定したサイズ以上であること")
  }

  /// Sequenceからの初期化がそのままの要素数を、プロパティが示していること
  func test_sequenceInitialization() {
    // 事前条件: Sequence [3, 1, 2, 1, 3]
    let multiset = RedBlackTreeMultiSet<Int>([3, 1, 2, 1, 3])

    // 事後条件: 重複含めソート済み [1, 1, 2, 3, 3]
    let expected = [1, 1, 2, 3, 3]
    XCTAssertFalse(multiset.isEmpty, "空ではないこと")
    XCTAssertEqual(multiset.count, expected.count, "要素数が期待通りであること")
  }

  /// Rangeからの初期化が範囲通りの要素数を、プロパティが示していること
  func test_rangeInitialization() {
    // 事前条件: Range [1...3]
    let multiset = RedBlackTreeMultiSet<Int>(1...3)

    // 事後条件: ソート済み [1, 2, 3]
    let expected = [1, 2, 3]
    XCTAssertFalse(multiset.isEmpty, "空ではないこと")
    XCTAssertEqual(multiset.count, expected.count, "要素数が期待通りであること")
  }
  
  /// Rangeからの初期化が範囲通りの要素数を、プロパティが示していること
  func test_reverseRangeInitialization() {
    // 事前条件: Range [1...3]
    let multiset = RedBlackTreeMultiSet<Int>(stride(from: 3, through: 1, by: -1))

    // 事後条件: ソート済み [1, 2, 3]
    let expected = [1, 2, 3]
    XCTAssertFalse(multiset.isEmpty, "空ではないこと")
    XCTAssertEqual(multiset.count, expected.count, "要素数が期待通りであること")
  }
  
  // MARK: - キャパシティは別腹
  
  /// reserveCapacityにより容量が指定値以上に増加し、要素数を指すプロパティが変化しないこと
  func test_reserveCapacity_shouldIncreaseCapacity() {
    var multiset = RedBlackTreeMultiSet<Int>()
    let initialCount = multiset.count

    // 事前条件:
    XCTAssertTrue(multiset.isEmpty, "空であること")
    XCTAssertEqual(multiset.count, 0, "要素数0であること")
    XCTAssertEqual(multiset.count, initialCount)


    // 実行: reserveCapacity(20)
    multiset.reserveCapacity(20)

    // 事後条件:
    XCTAssertGreaterThanOrEqual(multiset.capacity, 20, "指定したサイズ以上であること")
    XCTAssertTrue(multiset.isEmpty, "容量予約後も空のまま変化しないこと")
    XCTAssertEqual(multiset.count, 0, "最小容量指定後も要素数0のまま変化しないこと")
  }
  
  /// reserveCapacityにより容量が指定値以上に増加し、要素数を指すプロパティが変化しないこと
  func test_reserveCapacity_shouldIncreaseCapacity2() {
    var multiset = RedBlackTreeMultiSet<Int>(1...3)
    let initialCount = multiset.count

    // 事前条件:
    XCTAssertFalse(multiset.isEmpty, "空では無いこと")
    XCTAssertEqual(multiset.count, 3, "要素数3であること")
    XCTAssertEqual(multiset.count, initialCount)

    // 実行: reserveCapacity(20)
    multiset.reserveCapacity(20)

    // 事後条件:
    XCTAssertGreaterThanOrEqual(multiset.capacity, 20, "指定したサイズ以上であること")
    XCTAssertFalse(multiset.isEmpty, "空ではないまま変化しないこと")
    XCTAssertEqual(multiset.count, initialCount, "要素数3のまま変化しないこと")
  }
}
