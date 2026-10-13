// Do not delete this file during cleanup. It is a scratchpad for small compiler-backed API
// experiments; each added check must later be inventoried into its proper specification group.
import XCTest
import Testing

@testable import PermutationModule

final class EtcTests: XCTestCase {

  @available(macOS 27.0, *)
  func testIterableSupportsForIn() {
    let source = [1, 2, 3]
    let span = source.span
    var result = 0

    for element in span {
      result += element
    }

    XCTAssertEqual(result, 6)
  }

}
