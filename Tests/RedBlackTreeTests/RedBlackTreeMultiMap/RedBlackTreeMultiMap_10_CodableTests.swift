#if !COMPATIBLE_ATCODER_2025
  import Foundation
  import RedBlackTreeCollections
  import XCTest

  final class RedBlackTreeMultiMapCodableTests: RedBlackTreeTestCase {

    func test_codable_roundTripPreservesDuplicateKeysAndValues() throws {
      let original = RedBlackTreeMultiMap<Int, Int>(
        keysWithValues: (0..<10).flatMap { key in
          repeatElement((key, key * 3), count: 3)
        }
      )

      let data = try JSONEncoder().encode(original)
      let decoded = try JSONDecoder().decode(RedBlackTreeMultiMap<Int, Int>.self, from: data)

      XCTAssertEqual(decoded, original)
      XCTAssertEqual(decoded.count(forKey: 4), 3)
    }

    /// 非ソート・重複キーを含む入力をdecodeしても、キー順に並びつつ全pairが保持されること
    /// (2026-10-03発見・修正済みの回帰防止テスト)
    func test_codable_decodeFromUnsortedJSON_preservesAllPairsInKeyOrder() throws {
      let json = "[[2,\"b\"],[1,\"a\"],[1,\"c\"]]".data(using: .utf8)!
      let decoded = try JSONDecoder().decode(RedBlackTreeMultiMap<Int, String>.self, from: json)
      XCTAssertEqual(decoded.map(\.key), [1, 1, 2])
      XCTAssertEqual(decoded.count, 3)
    }

    func test_codable_decodeEmptyArray_isEmpty() throws {
      let json = "[]".data(using: .utf8)!
      let decoded = try JSONDecoder().decode(RedBlackTreeMultiMap<Int, String>.self, from: json)
      XCTAssertTrue(decoded.isEmpty)
    }
  }
#endif
