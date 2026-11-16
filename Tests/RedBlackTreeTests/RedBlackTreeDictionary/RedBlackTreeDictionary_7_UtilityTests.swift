import RedBlackTreeCollections
import XCTest

final class RedBlackTreeDictionaryUtilityTests: RedBlackTreeTestCase {

  func test_keysAndValues_followKeyOrder() {
    let dictionary: RedBlackTreeDictionary = [3: "c", 1: "a", 2: "b"]

    #if !COMPATIBLE_ATCODER_2025
      XCTAssertEqual(Array(dictionary.keys), [1, 2, 3])
      XCTAssertEqual(Array(dictionary.values), ["a", "b", "c"])
    #endif
  }

  func test_mapValues_transformsValuesAndPreservesKeys() {
    let dictionary: RedBlackTreeDictionary = [1: 10, 2: 20]

    let result = dictionary.mapValues { "value=\($0)" }

    XCTAssertEqual(result[1], "value=10")
    XCTAssertEqual(result[2], "value=20")
    XCTAssertEqual(result.map(\.key), [1, 2])
  }

  func test_compactMapValues_omitsNilResults() {
    let dictionary: RedBlackTreeDictionary = [1: 10, 2: 20, 3: 30]

    let result = dictionary.compactMapValues { $0 >= 20 ? String($0) : nil }

    XCTAssertNil(result[1])
    XCTAssertEqual(result[2], "20")
    XCTAssertEqual(result[3], "30")
  }

  func test_filter_returnsDictionaryContainingMatchingEntries() {
    let dictionary: RedBlackTreeDictionary = [1: "a", 2: "b", 3: "c", 4: "d"]

    let result = dictionary.filter { $0.key.isMultiple(of: 2) }

    XCTAssertEqual(result.map(\.key), [2, 4])
    XCTAssertEqual(result[2], "b")
    XCTAssertEqual(result[4], "d")
  }

  func test_copyOnWrite_mutatingCopyPreservesOriginal() {
    let original: RedBlackTreeDictionary = [1: "a", 2: "b"]
    var copy = original

    copy[2] = "changed"
    copy[3] = "c"

    XCTAssertEqual(original[2], "b")
    XCTAssertNil(original[3])
    XCTAssertEqual(copy[2], "changed")
    XCTAssertEqual(copy[3], "c")
  }
  /// mapValues・compactMapValues・filterは、closureのエラーをそのまま投げ、投げた後はclosureを呼ばないこと。
  /// 元の辞書のkey/valueは変わらず、途中まで作られた結果が参照値を保持し続けないこと（RBT-044 D2）
  func test_transformations_rethrowClosureErrorWithoutKeepingPartialResults() {
    final class Box { let id: Int; init(_ id: Int) { self.id = id } }
    struct StopError: Error, Equatable {}
    final class WeakBox { weak var box: Box? }

    let source: RedBlackTreeDictionary<Int, Int> = [1: 10, 2: 20, 3: 30]
    var produced: [WeakBox] = []
    func track(_ box: Box) -> Box {
      let observer = WeakBox()
      observer.box = box
      produced.append(observer)
      return box
    }

    var visited: [Int] = []
    XCTAssertThrowsError(
      try source.mapValues { value -> Box in
        visited.append(value)
        if value == 20 { throw StopError() }
        return track(Box(value))
      }
    ) { error in
      XCTAssertEqual(error as? StopError, StopError())
    }
    XCTAssertEqual(visited, [10, 20])

    visited = []
    XCTAssertThrowsError(
      try source.compactMapValues { value -> Box? in
        visited.append(value)
        if value == 20 { throw StopError() }
        return track(Box(value))
      }
    ) { error in
      XCTAssertEqual(error as? StopError, StopError())
    }
    XCTAssertEqual(visited, [10, 20])

    XCTAssertEqual(produced.count, 2)
    XCTAssertTrue(produced.allSatisfy { $0.box == nil }, "途中まで作られた結果が変換後の値を保持していないこと")

    var observers: [WeakBox] = []
    do {
      let boxes: RedBlackTreeDictionary<Int, Box> = [1: Box(1), 2: Box(2), 3: Box(3)]
      observers = boxes.map { element in
        let observer = WeakBox()
        observer.box = element.value
        return observer
      }
      var filtered: [Int] = []
      XCTAssertThrowsError(
        try boxes.filter { element in
          filtered.append(element.key)
          if element.key == 2 { throw StopError() }
          return true
        }
      ) { error in
        XCTAssertEqual(error as? StopError, StopError())
      }
      XCTAssertEqual(filtered, [1, 2])
      XCTAssertEqual(boxes.map(\.key), [1, 2, 3])
      XCTAssertTrue(zip(boxes.map(\.value), observers).allSatisfy { $0 === $1.box })
    }
    XCTAssertTrue(observers.allSatisfy { $0.box == nil }, "元の辞書を破棄した後、filterの途中結果が参照値を保持していないこと")

    XCTAssertEqual(source.map(\.key), [1, 2, 3])
    XCTAssertEqual(source.map(\.value), [10, 20, 30])
  }
}
