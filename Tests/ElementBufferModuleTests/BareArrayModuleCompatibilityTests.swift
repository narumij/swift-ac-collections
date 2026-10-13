import BareArrayModule
import XCTest

final class BareArrayModuleCompatibilityTests: XCTestCase {
  func testLegacyModuleReexportsElementBuffer() {
    let buffer = ElementBuffer<Int>(repeating: 42, count: 1)

    XCTAssertEqual(buffer.element(at: 0), 42)
  }
}
