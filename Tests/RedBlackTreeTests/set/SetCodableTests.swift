import RedBlackTreeModule
import XCTest

class CodableFixture: RedBlackTreeTestCase {

  let encoder: JSONEncoder = {
    let e = JSONEncoder()
    e.keyEncodingStrategy = .convertToSnakeCase
    e.dateEncodingStrategy = .iso8601
    return e
  }()

  let decoder: JSONDecoder = {
    let d = JSONDecoder()
    d.keyDecodingStrategy = .convertFromSnakeCase
    d.dateDecodingStrategy = .iso8601
    return d
  }()
}

#if !COMPATIBLE_ATCODER_2025
  final class SetCodableTests: CodableFixture {

    func testRoundTrip() throws {
      let u = RedBlackTreeSet<Int>(0..<10)
      let data = try encoder.encode(u)
      let v = try decoder.decode(RedBlackTreeSet<Int>.self, from: data)
      XCTAssertEqual(v, u)
    }
  }
#endif
