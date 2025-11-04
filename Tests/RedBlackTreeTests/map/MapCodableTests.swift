import XCTest
import RedBlackTreeModule

final class MapCodableTests: CodableFixture {

  func testRoundTrip() throws {
    let u = RedBlackTreeMap<Int,Int>(uniqueKeysWithValues: (0..<10).map { ($0, $0 * 3) })
    let data = try encoder.encode(u)
    let v = try decoder.decode(RedBlackTreeMap<Int,Int>.self, from: data)
    XCTAssertEqual(v, u)
  }
}
