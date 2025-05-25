import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class RedBlackTreeMultiMapInitializationTests: XCTestCase {

  /// 共通テストデータ
  let elements: [(String, Int)] = [
    ("apple", 1), ("banana", 2),
    ("apple", 3), ("cherry", 4),
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

  /// 容量予約の動作を確認
  func testReserveCapacity() {
    var multiMap = RedBlackTreeMultiMap<String, Int>()
    multiMap.reserveCapacity(20)
    XCTAssertTrue(multiMap.isEmpty, "容量予約後も空であるべき")
  }
}
