import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultiMapTransformingAndCombiningTests: RedBlackTreeTestCase {

  func test_mapValues_transformsEveryValueAndPreservesDuplicateKeys() {
    let map: RedBlackTreeMultiMap = [(1, 10), (1, 20), (2, 30)]

    let result = map.mapValues { "value=\($0)" }

    XCTAssertEqual(result.map(\.key), [1, 1, 2])
    XCTAssertEqual(result.map(\.value), ["value=10", "value=20", "value=30"])
  }

  func test_compactMapValues_omitsNilResultsWithoutCollapsingKeys() {
    let map: RedBlackTreeMultiMap = [(1, 10), (1, 20), (2, 30), (2, 40)]

    let result = map.compactMapValues { $0 >= 30 ? String($0) : nil }

    XCTAssertEqual(result.map(\.key), [2, 2])
    XCTAssertEqual(result.map(\.value), ["30", "40"])
  }

  func test_insertingContentsOf_returnsChangedCopyAndPreservesOriginal() {
    let original: RedBlackTreeMultiMap = [(1, "a"), (1, "b")]

    let result = original.inserting(contentsOf: [(1, "c"), (2, "d")])

    XCTAssertEqual(original.map(\.value), ["a", "b"])
    XCTAssertEqual(result.map(\.value), ["a", "b", "c", "d"])
  }

  func test_meld_combinesEveryEntryInPlace() {
    var lhs: RedBlackTreeMultiMap = [(1, "a"), (2, "c")]
    let rhs: RedBlackTreeMultiMap = [(1, "b"), (2, "d")]

    lhs.meld(rhs)

    XCTAssertEqual(lhs.map(\.key), [1, 1, 2, 2])
    XCTAssertEqual(lhs.map(\.value), ["a", "b", "c", "d"])
  }

  func test_melding_returnsCombinedCopyAndPreservesOperands() {
    let lhs: RedBlackTreeMultiMap = [(1, "a"), (2, "c")]
    let rhs: RedBlackTreeMultiMap = [(1, "b"), (2, "d")]

    let result = lhs.melding(rhs)

    XCTAssertEqual(result.map(\.value), ["a", "b", "c", "d"])
    XCTAssertEqual(lhs.map(\.value), ["a", "c"])
    XCTAssertEqual(rhs.map(\.value), ["b", "d"])
  }
  /// mapValues・compactMapValues・filterは、重複keyの値を区別した入力でもclosureのエラーをそのまま投げ、
  /// 投げた後はclosureを呼ばないこと。元のkey/valueは変わらず、途中まで作られた結果が参照値を
  /// 保持し続けないこと（RBT-045 MM2）
  func test_transformations_rethrowClosureErrorWithoutKeepingPartialResults() {
    final class Box { let id: Int; init(_ id: Int) { self.id = id } }
    struct StopError: Error, Equatable {}
    final class WeakBox { weak var box: Box? }

    let source: RedBlackTreeMultiMap<Int, Int> = [(1, 10), (1, 11), (1, 12), (2, 20)]
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
        if value == 11 { throw StopError() }
        return track(Box(value))
      }
    ) { error in
      XCTAssertEqual(error as? StopError, StopError())
    }
    XCTAssertEqual(visited, [10, 11], "同じkeyの後続の値へclosureを呼ばないこと")

    visited = []
    XCTAssertThrowsError(
      try source.compactMapValues { value -> Box? in
        visited.append(value)
        if value == 12 { throw StopError() }
        return track(Box(value))
      }
    ) { error in
      XCTAssertEqual(error as? StopError, StopError())
    }
    XCTAssertEqual(visited, [10, 11, 12])

    XCTAssertEqual(produced.count, 3)
    XCTAssertTrue(produced.allSatisfy { $0.box == nil }, "途中まで作られた結果が変換後の値を保持していないこと")

    var observers: [WeakBox] = []
    do {
      let boxes: RedBlackTreeMultiMap<Int, Box> = [(1, Box(0)), (1, Box(1)), (1, Box(2)), (2, Box(3))]
      observers = boxes.map { element in
        let observer = WeakBox()
        observer.box = element.value
        return observer
      }
      var filtered: [Int] = []
      XCTAssertThrowsError(
        try boxes.filter { element in
          filtered.append(element.value.id)
          if element.value.id == 1 { throw StopError() }
          return true
        }
      ) { error in
        XCTAssertEqual(error as? StopError, StopError())
      }
      XCTAssertEqual(filtered, [0, 1])
      XCTAssertEqual(boxes.map(\.key), [1, 1, 1, 2])
      XCTAssertTrue(zip(boxes.map(\.value), observers).allSatisfy { $0 === $1.box })
    }
    XCTAssertTrue(observers.allSatisfy { $0.box == nil }, "元のmultimapを破棄した後、filterの途中結果が参照値を保持していないこと")

    XCTAssertEqual(source.map(\.key), [1, 1, 1, 2])
    XCTAssertEqual(source.map(\.value), [10, 11, 12, 20])
  }
}
