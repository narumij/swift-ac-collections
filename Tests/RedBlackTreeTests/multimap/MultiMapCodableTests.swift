import RedBlackTreeModule
import XCTest

#if !COMPATIBLE_ATCODER_2025
  final class MultiMapCodableTests: CodableFixture {

    func testRoundTrip() throws {
      let u = RedBlackTreeMultiMap<Int, Int>(
        multiKeysWithValues: (0..<10).flatMap { repeatElement($0, count: 3).map { ($0, $0 * 3) } })
      let data = try encoder.encode(u)
      let v = try decoder.decode(RedBlackTreeMultiMap<Int, Int>.self, from: data)
      XCTAssertEqual(v, u)
    }
  }
#endif
