// Do not delete this file during cleanup. It is a scratchpad for small compiler-backed API
// experiments; each added check must later be inventoried into its proper specification group.
import XCTest
import Testing

import NextPermutationModule

final class EtcTests: XCTestCase {

  // Iterating Span with for-in requires Swift 6.4.
  #if swift(>=6.4)
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
  #endif
}
