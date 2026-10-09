import Foundation
import RedBlackTreeCollections
import XCTest

  final class RedBlackTreeSetCodableTests: RedBlackTreeTestCase {

    func test_codable_roundTripsElementsInOrder() throws {
      let original = RedBlackTreeSet(0..<10)
      let data = try JSONEncoder().encode(original)

      let decoded = try JSONDecoder().decode(RedBlackTreeSet<Int>.self, from: data)

      XCTAssertEqual(decoded, original)
      XCTAssertEqual(Array(decoded), Array(0..<10))
    }

    /// 非ソートな入力をdecodeしても、要素は昇順に並ぶこと(2026-10-03発見・修正済みの回帰防止テスト)
    func test_codable_decodeFromUnsortedJSON_producesSortedSet() throws {
      let json = "[3,1,2]".data(using: .utf8)!
      let decoded = try JSONDecoder().decode(RedBlackTreeSet<Int>.self, from: json)
      XCTAssertEqual(Array(decoded), [1, 2, 3])
    }

    /// 重複を含む入力をdecodeしても、一意性が保たれること
    func test_codable_decodeFromDuplicateJSON_discardsDuplicates() throws {
      let json = "[1,1,2]".data(using: .utf8)!
      let decoded = try JSONDecoder().decode(RedBlackTreeSet<Int>.self, from: json)
      XCTAssertEqual(Array(decoded), [1, 2])
      XCTAssertEqual(decoded.count, 2)
    }

    func test_codable_decodeEmptyArray_isEmpty() throws {
      let json = "[]".data(using: .utf8)!
      let decoded = try JSONDecoder().decode(RedBlackTreeSet<Int>.self, from: json)
      XCTAssertTrue(decoded.isEmpty)
    }

  }
