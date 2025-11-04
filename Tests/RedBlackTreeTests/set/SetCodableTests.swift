import XCTest
import RedBlackTreeModule

class CodableFixture: XCTestCase {
  
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

final class SetCodableTests: CodableFixture {

  func testRoundTrip() throws {
    let u = RedBlackTreeSet<Int>(0..<10)
    let data = try encoder.encode(u)
    let v = try decoder.decode(RedBlackTreeSet<Int>.self, from: data)
    XCTAssertEqual(v, u)
  }
}
