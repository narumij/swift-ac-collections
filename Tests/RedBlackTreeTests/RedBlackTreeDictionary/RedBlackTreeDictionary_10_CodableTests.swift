#if !COMPATIBLE_ATCODER_2025
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
  }
#endif
