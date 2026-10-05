import Foundation
import RedBlackTreeCollections
import XCTest

#if !COMPATIBLE_ATCODER_2025
  final class RedBlackTreeMultiSetCodableTests: RedBlackTreeTestCase {

    func test_codable_roundTripsElementsInOrder() throws {
      let original = RedBlackTreeMultiSet((0..<10).flatMap { repeatElement($0, count: 2) })
      let data = try JSONEncoder().encode(original)

      let decoded = try JSONDecoder().decode(RedBlackTreeMultiSet<Int>.self, from: data)

      XCTAssertEqual(decoded, original)
      XCTAssertEqual(Array(decoded), Array(original))
    }

    /// 非ソート・重複を含む入力をdecodeしても、昇順に並びつつ全要素が保持されること
    /// (2026-10-03発見・修正済みの回帰防止テスト)
    func test_codable_decodeFromUnsortedJSON_producesSortedMultiSetWithDuplicates() throws {
      let json = "[3,1,2,1]".data(using: .utf8)!
      let decoded = try JSONDecoder().decode(RedBlackTreeMultiSet<Int>.self, from: json)
      XCTAssertEqual(Array(decoded), [1, 1, 2, 3])
    }

    func test_codable_decodeEmptyArray_isEmpty() throws {
      let json = "[]".data(using: .utf8)!
      let decoded = try JSONDecoder().decode(RedBlackTreeMultiSet<Int>.self, from: json)
      XCTAssertTrue(decoded.isEmpty)
    }
  }
#endif
