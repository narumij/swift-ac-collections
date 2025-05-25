import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class RedBlackTreeMultiSetInitializationTests: XCTestCase {

  /// 空の初期化が成功し、isEmptyがtrueであること
  func test_emptyInitialization() {
    // 事前条件: 空のマルチセットを初期化
    let multiset = RedBlackTreeMultiSet<Int>()

    // 事後条件: 空であること
    XCTAssertTrue(multiset.isEmpty)
    XCTAssertEqual(multiset.count, 0)
  }

  /// 最小容量指定初期化が成功し、空であること
  func test_minimumCapacityInitialization() {
    // 事前条件: 最小容量10で初期化
    let multiset = RedBlackTreeMultiSet<Int>(minimumCapacity: 10)

    // 事後条件: 空であること、容量が最低10以上
    XCTAssertTrue(multiset.isEmpty)
    XCTAssertGreaterThanOrEqual(multiset.capacity, 10)
  }

  /// Sequenceからの初期化が重複を含め順序通りの要素を正しく保持すること
  func test_sequenceInitialization() {
    // 事前条件: Sequence [3, 1, 2, 1, 3]
    let multiset = RedBlackTreeMultiSet([3, 1, 2, 1, 3])

    // 事後条件: 重複含めソート済み [1, 1, 2, 3, 3]
    let expected = [1, 1, 2, 3, 3]
    XCTAssertEqual(Array(multiset), expected)
  }

  /// Rangeからの初期化が範囲通りの要素を正しく保持すること
  func test_rangeInitialization() {
    // 事前条件: Range [1...3]
    let multiset = RedBlackTreeMultiSet(1...3)

    // 事後条件: ソート済み [1, 2, 3]
    XCTAssertEqual(Array(multiset), [1, 2, 3])
  }
}
