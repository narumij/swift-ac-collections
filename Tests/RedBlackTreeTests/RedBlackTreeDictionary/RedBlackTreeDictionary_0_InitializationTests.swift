import XCTest
import RedBlackTreeModule

final class RedBlackTreeDictionaryInitializationTests: XCTestCase {

  // MARK: - 「空なものは空である」と「空でないものは空ではない」のトートロジー

  let elements = [("apple", 1), ("cherry", 3), ("banana", 2)]
  let duplicate = [("apple", 1), ("banana", 2), ("apple", 3)]
  let items = ["banana", "apple", "blueberry", "apricot"]

  /// 空の辞書を初期化したときの動作を確認
  func testInitEmptyDictionary() {
    let dict = RedBlackTreeDictionary<String, Int>()
    XCTAssertTrue(dict.isEmpty, "初期化直後は空であるべき")
    XCTAssertEqual(dict.count, 0, "要素数は0であるべき")
  }

  /// シーケンスで初期化（配列使用）
  func testInitWithUniqueKeysFromArray() {
    let dict = RedBlackTreeDictionary<String, Int>(uniqueKeysWithValues: elements)
    
    let expected = [("apple", 1), ("banana", 2), ("cherry", 3)]

    XCTAssertEqual(dict.count, elements.count)
    XCTAssertEqual(dict.map { $0.key }, expected.map { $0.0 })
    XCTAssertEqual(dict.map { $0.value }, expected.map { $0.1 })
  }

  /// シーケンスで初期化（AnySequence使用）
  func testInitWithUniqueKeysFromAnySequence() {
    let dict = RedBlackTreeDictionary<String, Int>(uniqueKeysWithValues: AnySequence(elements))
    
    let expected = [("apple", 1), ("banana", 2), ("cherry", 3)]

    XCTAssertEqual(dict.count, elements.count)
    XCTAssertEqual(dict.map { $0.key }, expected.map { $0.0 })
    XCTAssertEqual(dict.map { $0.value }, expected.map { $0.1 })
  }

  /// 重複キーあり（マージルール適用）配列使用
  func testInitWithDuplicateKeysMergingValues() throws {
    let dict = RedBlackTreeDictionary<String, Int>(duplicate, uniquingKeysWith: +)

    let expect = [("apple", 4), ("banana", 2)]

    XCTAssertEqual(dict.count, 2)
    XCTAssertEqual(dict.map { $0.key }, expect.map { $0.0 })
    XCTAssertEqual(dict.map { $0.value }, expect.map { $0.1 })
  }

  /// 重複キーあり（マージルール適用）AnySequence使用
  func testInitWithDuplicateKeysMergingValuesAnySequence() throws {
    let dict = RedBlackTreeDictionary<String, Int>(AnySequence(duplicate), uniquingKeysWith: +)

    let expect = [("apple", 4), ("banana", 2)]

    XCTAssertEqual(dict.count, 2)
    XCTAssertEqual(dict.map { $0.key }, expect.map { $0.0 })
    XCTAssertEqual(dict.map { $0.value }, expect.map { $0.1 })
  }

  /// グルーピング初期化（配列使用）
  func testInitGroupingValuesByFirstCharacter() throws {
    let dict = RedBlackTreeDictionary<String, [String]>(grouping: items, by: { String($0.first!) })

    let expect = [("a", ["apple", "apricot"]), ("b", ["banana", "blueberry"])]

    XCTAssertEqual(dict.count, 2)
    XCTAssertEqual(dict.map { $0.key }, expect.map { $0.0 })
    XCTAssertEqual(dict.map { $0.value }, expect.map { $0.1 })
  }

  /// グルーピング初期化（AnySequence使用）
  func testInitGroupingValuesByFirstCharacterAnySequence() throws {
    let dict = RedBlackTreeDictionary<String, [String]>(grouping: AnySequence(items), by: { String($0.first!) })

    let expect = [("a", ["apple", "apricot"]), ("b", ["banana", "blueberry"])]

    XCTAssertEqual(dict.count, 2)
    XCTAssertEqual(dict.map { $0.key }, expect.map { $0.0 })
    XCTAssertEqual(dict.map { $0.value }, expect.map { $0.1 })
  }

  /// 重複キー初期化（fatalErrorなので実テスト不可）
  func testInitWithDuplicateKeysShouldCauseFatalError() {
    // 実行するとクラッシュするためコメントアウト（本来の挙動確認用に残している）
    // let elements = [("apple", 1), ("banana", 2), ("apple", 3)]
    // _ = RedBlackTreeDictionary(uniqueKeysWithValues: elements)
  }

  /// 最小容量指定で初期化
  func testInitWithMinimumCapacity() {
    let dict = RedBlackTreeDictionary<String, Int>(minimumCapacity: 10)
    XCTAssertGreaterThanOrEqual(dict.capacity, 10, "指定したサイズ以上であること")
    XCTAssertTrue(dict.isEmpty, "最小容量指定後も空であること")
  }

  // MARK: - キャパシティは別腹

  /// reserveCapacityにより容量が指定値以上に増加すること
  func test_reserveCapacity_shouldIncreaseCapacity() {
    // 事前条件: 空集合を生成
    var dict = RedBlackTreeDictionary<String, Int>()
    let initialCapacity = dict.capacity

    // 実行: reserveCapacity(20)
    dict.reserveCapacity(20)

    // 事後条件:
    XCTAssertGreaterThanOrEqual(dict.capacity, 20, "指定したサイズ以上であること")
    XCTAssertGreaterThanOrEqual(dict.capacity, initialCapacity, "初期サイズ以上であること")
    XCTAssertTrue(dict.isEmpty, "容量予約後も要素は追加されない")
  }
}
