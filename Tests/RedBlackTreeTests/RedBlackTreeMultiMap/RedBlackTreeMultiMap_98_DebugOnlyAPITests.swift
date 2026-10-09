//
//  RedBlackTreeMultiMap_98_DebugOnlyAPITests.swift
//  swift-ac-collections
//
//  Debug構成だけにあるAPI（Balanced群の`popFirst(_:)` / `popLast(_:)`）のテスト。
//  公開仕様の根拠にしないため、番号付きのTest as Specから移した（2026-10-07）。
//

#if DEBUG
  import RedBlackTreeCollections
  import XCTest

  final class RedBlackTreeMultiMapDebugOnlyAPITests: RedBlackTreeTestCase {

    func test_rangeViewPopFirstAndPopLast_removeAtMostTheRequestedCountInsideTheView() {
      var firstMap: RedBlackTreeMultiMap = [
        (0, "before"), (1, "a"), (1, "b"), (1, "c"), (2, "after"),
      ]
      XCTAssertEqual(firstMap[firstMap.equalRange(1)].popFirst(2), 2)
      XCTAssertEqual(firstMap.map(\.value), ["before", "c", "after"])

      var lastMap: RedBlackTreeMultiMap = [
        (0, "before"), (1, "a"), (1, "b"), (1, "c"), (2, "after"),
      ]
      XCTAssertEqual(lastMap[lastMap.equalRange(1)].popLast(10), 3)
      XCTAssertEqual(lastMap.map(\.value), ["before", "after"])
    }
  }
#endif
