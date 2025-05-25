import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class RedBlackTreeSetInitializationTests: XCTestCase {

  /// 空集合は要素が存在せず、要素数は0であること
  func test_initialization_emptySet() {
    // 事前条件: 空集合を生成
    let set = RedBlackTreeSet<Int>()

    // 実行: 操作なし

    // 事後条件:
    // - isEmpty == true
    // - count == 0
    // - map { $0 } == []
    XCTAssertTrue(set.isEmpty)
    XCTAssertEqual(set.count, 0)
    XCTAssertEqual(set.map { $0 }, [])
  }

  /// 最小容量を指定した初期化では、要素は存在せず容量は指定値以上であること
  func test_initialization_withMinimumCapacity() {
    // 事前条件: 容量10指定で集合を生成
    let set = RedBlackTreeSet<Int>(minimumCapacity: 10)

    // 実行: 操作なし

    // 事後条件:
    // - isEmpty == true
    // - count == 0
    // - map { $0 } == []
    // - capacity >= 10
    XCTAssertTrue(set.isEmpty)
    XCTAssertEqual(set.count, 0)
    XCTAssertEqual(set.map { $0 }, [])
    XCTAssertGreaterThanOrEqual(set.capacity, 10)
  }

  /// シーケンス初期化では、要素は重複を除外し昇順に配置されること（順序保証仕様）
  func test_initialization_withSequence() {
    // 事前条件: [3,1,4,1,5,9] のシーケンスを与える
    let sequence = [3, 1, 4, 1, 5, 9]
    let set = RedBlackTreeSet(sequence)

    // 実行: 操作なし

    // 事後条件:
    // - count == Set(sequence).count
    // - 要素は昇順に並ぶ（順序保証仕様）
    let expected = Array(Set(sequence)).sorted()
    XCTAssertEqual(set.count, expected.count)
    XCTAssertEqual(set.map { $0 }, expected)
  }

  /// AnySequence初期化でも、要素は重複を除外し昇順に配置されること（順序保証仕様）
  func test_initialization_withAnySequence() {
    // 事前条件: AnySequence([3,1,4,1,5,9])を与える
    let sequence = [3, 1, 4, 1, 5, 9]
    let anySeq = AnySequence(sequence)
    let set = RedBlackTreeSet(anySeq)

    // 実行: 操作なし

    // 事後条件:
    // - count == Set(sequence).count
    // - 要素は昇順に並ぶ（順序保証仕様）
    let expected = Array(Set(sequence)).sorted()
    XCTAssertEqual(set.count, expected.count)
    XCTAssertEqual(set.map { $0 }, expected)
  }

  /// Range初期化では、範囲内の要素が昇順に配置されること（順序保証仕様）
  func test_initialization_withRange() {
    // 事前条件: 1..<5 の範囲を与える
    let range = 1..<5
    let set = RedBlackTreeSet(range)

    // 実行: 操作なし

    // 事後条件:
    // - count == range.count
    // - 要素は昇順に並ぶ（順序保証仕様）
    let expected = Array(range)
    XCTAssertEqual(set.count, expected.count)
    XCTAssertEqual(set.map { $0 }, expected)
  }

  /// ClosedRange初期化では、範囲内の要素が昇順に配置されること（順序保証仕様）
  func test_initialization_withClosedRange() {
    // 事前条件: 1...5 の範囲を与える
    let range = 1...5
    let set = RedBlackTreeSet(range)

    // 実行: 操作なし

    // 事後条件:
    // - count == range.count
    // - 要素は昇順に並ぶ（順序保証仕様）
    let expected = Array(range)
    XCTAssertEqual(set.count, expected.count)
    XCTAssertEqual(set.map { $0 }, expected)
  }

  /// 最小容量指定で初期化
  func testInitWithMinimumCapacity() {
    let set = RedBlackTreeSet<Int>(minimumCapacity: 10)
    XCTAssertGreaterThanOrEqual(set.capacity, 10, "指定したサイズ以上であること")
    XCTAssertTrue(set.isEmpty, "最小容量指定後も空であること")
  }

  /// reserveCapacityにより容量が指定値以上に増加すること
  func test_reserveCapacity_shouldIncreaseCapacity() {
    // 事前条件: 空集合を生成
    var set = RedBlackTreeSet<Int>()
    let initialCapacity = set.capacity

    // 実行: reserveCapacity(20)
    set.reserveCapacity(20)

    // 事後条件:
    XCTAssertGreaterThanOrEqual(set.capacity, 20, "指定したサイズ以上であること")
    XCTAssertGreaterThanOrEqual(set.capacity, initialCapacity, "初期サイズ以上であること")
    XCTAssertTrue(set.isEmpty, "容量予約後も要素は追加されないこと")
  }
}
