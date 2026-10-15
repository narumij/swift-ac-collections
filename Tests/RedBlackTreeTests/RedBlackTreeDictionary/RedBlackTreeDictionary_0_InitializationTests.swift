import XCTest
import RedBlackTreeCollections

// The numbered RedBlackTreeDictionary tests are the canonical Test as Spec suite.
// Keep public, current behavior here; implementation and stress tests may remain elsewhere.
final class RedBlackTreeDictionaryInitializationTests: RedBlackTreeTestCase {

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

  // 重複キーを含む`init(uniqueKeysWithValues:)`の停止は、子processで実行する
  // `RedBlackTreeDictionary_99_DeathTests.swift`の`duplicateKeysInUniqueKeysInitializer_terminateProcess`
  // が検査する。Death Testは`DEATH_TEST`定義時（macOSでは既定、Linuxでは`ENABLE_DEATH_TESTS` trait）
  // だけ実行され、通常modeと互換modeの両方でcompileされる（RBT-044 D6）。

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
  /// 重複統合closureのエラーはそのまま投げられ、投げた後はclosureを呼ばないこと。
  /// 途中まで作られた辞書が保持した参照値も、エラーの後に残らないこと（RBT-044 D2）
  func testInitUniquingKeysRethrowsCombineErrorAndReleasesPartialValues() {
    final class Box { let id: Int; init(_ id: Int) { self.id = id } }
    struct StopError: Error, Equatable {}
    final class WeakBox { weak var box: Box? }

    var observers: [WeakBox] = []
    do {
      let boxes = (0..<4).map(Box.init)
      observers = boxes.map { box in
        let observer = WeakBox()
        observer.box = box
        return observer
      }
      var combined: [(Int, Int)] = []
      XCTAssertThrowsError(
        try RedBlackTreeDictionary<Int, Box>(boxes.map { (1, $0) }) { current, new in
          combined.append((current.id, new.id))
          if combined.count == 2 { throw StopError() }
          return new
        }
      ) { error in
        XCTAssertEqual(error as? StopError, StopError())
      }
      XCTAssertEqual(combined.map(\.0), [0, 1])
      XCTAssertEqual(combined.map(\.1), [1, 2], "エラーの後に残りの要素を統合しないこと")
    }
    XCTAssertTrue(observers.allSatisfy { $0.box == nil }, "途中まで作られた辞書が参照値を保持していないこと")
  }

  /// grouping初期化のキー関数のエラーはそのまま投げられ、投げた後はキー関数を呼ばないこと。
  /// 途中まで作られたgroupが保持した要素も、エラーの後に残らないこと（RBT-044 D2）
  func testInitGroupingRethrowsKeyErrorAndReleasesPartialGroups() {
    final class Box { let id: Int; init(_ id: Int) { self.id = id } }
    struct StopError: Error, Equatable {}
    final class WeakBox { weak var box: Box? }

    var observers: [WeakBox] = []
    do {
      let boxes = (0..<4).map(Box.init)
      observers = boxes.map { box in
        let observer = WeakBox()
        observer.box = box
        return observer
      }
      var visited: [Int] = []
      XCTAssertThrowsError(
        try RedBlackTreeDictionary<Int, [Box]>(grouping: boxes) { box in
          visited.append(box.id)
          if box.id == 2 { throw StopError() }
          return box.id % 2
        }
      ) { error in
        XCTAssertEqual(error as? StopError, StopError())
      }
      XCTAssertEqual(visited, [0, 1, 2])
    }
    XCTAssertTrue(observers.allSatisfy { $0.box == nil }, "途中まで作られたgroupが要素を保持していないこと")
  }
}
