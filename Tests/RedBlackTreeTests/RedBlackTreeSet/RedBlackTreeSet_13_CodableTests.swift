import Foundation
import RedBlackTreeCollections
import XCTest

#if !COMPATIBLE_ATCODER_2025
  final class RedBlackTreeSetCodableTests: RedBlackTreeTestCase {

    func test_codable_roundTripsElementsInOrder() throws {
      let original = RedBlackTreeSet(0..<10)
      let data = try JSONEncoder().encode(original)

      let decoded = try JSONDecoder().decode(RedBlackTreeSet<Int>.self, from: data)

      XCTAssertEqual(decoded, original)
      XCTAssertEqual(Array(decoded), Array(0..<10))
    }

  }
#endif
