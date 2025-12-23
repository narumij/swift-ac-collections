import RedBlackTreeModule
import XCTest

final class MultisetCodableTests: CodableFixture {

  #if !COMPATIBLE_ATCODER_2025
    func testRoundTrip() throws {
      let u = RedBlackTreeMultiSet<Int>((0..<10).flatMap { repeatElement($0, count: 3) })
      let data = try encoder.encode(u)
      let v = try decoder.decode(RedBlackTreeMultiSet<Int>.self, from: data)
      XCTAssertEqual(v, u)
    }
  #endif
}
