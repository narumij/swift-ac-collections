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
  }
#endif
