import XCTest
import RedBlackTreeModule

#if !COMPATIBLE_ATCODER_2025
final class DictionaryCodableTests: CodableFixture {

  func testRoundTrip() throws {
    let u = RedBlackTreeDictionary<Int,String>(uniqueKeysWithValues: (0..<10).map { ($0, "\($0 * 3)") })
    let data = try encoder.encode(u)
    let v = try decoder.decode(RedBlackTreeDictionary<Int,String>.self, from: data)
    XCTAssertEqual(v, u)
  }
}
#endif
