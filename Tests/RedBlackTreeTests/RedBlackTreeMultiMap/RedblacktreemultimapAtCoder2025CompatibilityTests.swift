import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

#if COMPATIBLE_ATCODER_2025
  extension RedBlackTreeMultiMapInitializationTests {
    /// シーケンス初期化テスト（AnySequence使用）
    func testSequenceInitializationWithNaive() {
      let multiMap = RedBlackTreeMultiMap<String, Int>(
        naive: AnySequence(elements.map { keyValue($0.0, $0.1) }))

      let expected = [
        ("apple", 1),
        ("apple", 3),
        ("banana", 2),
        ("cherry", 4),
      ]

      XCTAssertFalse(multiMap.isEmpty, "空ではないこと")
      XCTAssertEqual(multiMap.count, expected.count, "要素数が期待通りであること")
    }
  }
#endif
