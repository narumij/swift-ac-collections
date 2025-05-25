import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class RedBlackTreeDictionaryInitializationTests: XCTestCase {

  let elements = [("apple", 1), ("banana", 2), ("cherry", 3)]

  /// 空の辞書を初期化したときの動作を確認
  func testInitEmptyDictionary() {
    let dict = RedBlackTreeDictionary<String, Int>()
    XCTAssertTrue(dict.isEmpty, "初期化直後は空であるべき")
    XCTAssertEqual(dict.count, 0, "要素数は0であるべき")
  }

  /// シーケンスで初期化（配列使用）
  func testInitWithUniqueKeysFromArray() {
    let dict = RedBlackTreeDictionary(uniqueKeysWithValues: elements)
    XCTAssertEqual(dict.count, elements.count)
    XCTAssertEqual(dict["apple"], 1)
    XCTAssertEqual(dict["banana"], 2)
    XCTAssertEqual(dict["cherry"], 3)
  }

  /// シーケンスで初期化（AnySequence使用）
  func testInitWithUniqueKeysFromAnySequence() {
    let dict = RedBlackTreeDictionary(uniqueKeysWithValues: AnySequence(elements))
    XCTAssertEqual(dict.count, elements.count)
    XCTAssertEqual(dict["apple"], 1)
    XCTAssertEqual(dict["banana"], 2)
    XCTAssertEqual(dict["cherry"], 3)
  }

  /// 重複キーあり（マージルール適用）配列使用
  func testInitWithDuplicateKeysMergingValues() throws {
    let dict = RedBlackTreeDictionary(elements, uniquingKeysWith: +)
    XCTAssertEqual(dict.count, 2)
    XCTAssertEqual(dict["apple"], 4)
    XCTAssertEqual(dict["banana"], 2)
  }

  /// 重複キーあり（マージルール適用）AnySequence使用
  func testInitWithDuplicateKeysMergingValuesAnySequence() throws {
    let dict = RedBlackTreeDictionary(AnySequence(elements), uniquingKeysWith: +)
    XCTAssertEqual(dict.count, 2)
    XCTAssertEqual(dict["apple"], 4)
    XCTAssertEqual(dict["banana"], 2)
  }

  /// グルーピング初期化（配列使用）
  func testInitGroupingValuesByFirstCharacter() throws {
    let items = ["apple", "banana", "apricot", "blueberry"]
    let dict = RedBlackTreeDictionary(grouping: items, by: { String($0.first!) })
    XCTAssertEqual(dict.count, 2)
    XCTAssertEqual(Set(dict["a"]!), Set(["apple", "apricot"]))
    XCTAssertEqual(Set(dict["b"]!), Set(["banana", "blueberry"]))
  }

  /// グルーピング初期化（AnySequence使用）
  func testInitGroupingValuesByFirstCharacterAnySequence() throws {
    let items = ["apple", "banana", "apricot", "blueberry"]
    let dict = RedBlackTreeDictionary(grouping: AnySequence(items), by: { String($0.first!) })
    XCTAssertEqual(dict.count, 2)
    XCTAssertEqual(Set(dict["a"]!), Set(["apple", "apricot"]))
    XCTAssertEqual(Set(dict["b"]!), Set(["banana", "blueberry"]))
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
    XCTAssertTrue(dict.isEmpty, "最小容量指定後も空であるべき")
  }

  /// 容量予約後の状態を確認
  func testReserveCapacityOnEmptyDictionary() {
    var dict = RedBlackTreeDictionary<String, Int>()
    dict.reserveCapacity(20)
    XCTAssertTrue(dict.isEmpty, "容量予約後も要素は追加されない")
  }
}
