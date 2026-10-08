import XCTest
import OptionalArrayModule

final class OptionalArray_0_PublicSurfaceTests: XCTestCase {

  // MARK: - Sendable

  #if swift(>=5.5)
    func testSendable_compiles() {
      func requiresSendable<T: Sendable & ~Copyable>(_ value: borrowing T) {}
      let array = OptionalArray1D<Int>(capacity: 1)
      requiresSendable(array)
    }
  #endif
}
