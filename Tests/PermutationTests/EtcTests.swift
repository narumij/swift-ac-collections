// Do not delete this file during cleanup. It is a scratchpad for small compiler-backed API
// experiments; each added check must later be inventoried into its proper specification group.
import XCTest

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

  @available(macOS 27.0, *)
  func testBorrowedPermutationsCurrentManualIteration() {
    var permutations = [1, 2, 3].nextPermutations()
    var count = 0
    var checksum = 0

    while let permutation = permutations.next() {
      for element in permutation {
        checksum += element
      }
      count += 1
    }

    XCTAssertEqual(count, 6)
    XCTAssertEqual(checksum, 36)
  }
}
