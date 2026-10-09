  import Foundation
  import RedBlackTreeCollections
  import XCTest

  final class RedBlackTreeDictionaryCodableTests: RedBlackTreeTestCase {

    func test_codable_roundTripPreservesKeysAndValues() throws {
      let original = RedBlackTreeDictionary<Int, String>(
        uniqueKeysWithValues: (0..<10).map { ($0, "value=\($0 * 3)") }
      )

      let data = try JSONEncoder().encode(original)
      let decoded = try JSONDecoder().decode(RedBlackTreeDictionary<Int, String>.self, from: data)

      XCTAssertEqual(decoded, original)
      XCTAssertEqual(decoded.map(\.key), Array(0..<10))
    }

    /// 非ソートな入力をdecodeしても、キーは昇順に並ぶこと(2026-10-03発見・修正済みの回帰防止テスト)
    func test_codable_decodeFromUnsortedJSON_producesKeySortedDictionary() throws {
      let json = "[[2,\"b\"],[1,\"a\"]]".data(using: .utf8)!
      let decoded = try JSONDecoder().decode(RedBlackTreeDictionary<Int, String>.self, from: json)
      XCTAssertEqual(decoded.map(\.key), [1, 2])
    }

    /// 重複キーを含む入力をdecodeしても、キーごとに1件だけ残ること(先に出現した値を優先)
    func test_codable_decodeFromDuplicateKeyJSON_keepsFirstValuePerKey() throws {
      let json = "[[1,\"a\"],[1,\"b\"]]".data(using: .utf8)!
      let decoded = try JSONDecoder().decode(RedBlackTreeDictionary<Int, String>.self, from: json)
      XCTAssertEqual(decoded.count, 1)
      XCTAssertEqual(decoded[1], "a")
    }

    func test_codable_decodeEmptyArray_isEmpty() throws {
      let json = "[]".data(using: .utf8)!
      let decoded = try JSONDecoder().decode(RedBlackTreeDictionary<Int, String>.self, from: json)
      XCTAssertTrue(decoded.isEmpty)
    }
  }
