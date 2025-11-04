import XCTest
import RedBlackTreeModule

final class MultisetCodableTests: CodableFixture {

  func testRoundTrip() throws {
    let u = RedBlackTreeMultiSet<Int>((0..<10).flatMap { repeatElement($0, count: 3) })
    let data = try encoder.encode(u)
    let v = try decoder.decode(RedBlackTreeMultiSet<Int>.self, from: data)
    XCTAssertEqual(v, u)
  }
}
