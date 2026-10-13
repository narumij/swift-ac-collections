import OptionalArrayModule
import XCTest

final class OptionalArrayModuleCompatibilityTests: XCTestCase {
  func testLegacyModuleReexportsOptionalElementBuffer() {
    let buffer = OptionalElementBuffer<Int>(capacity: 1)

    XCTAssertNil(buffer.element(at: 0))
  }
}
