import ElementBufferModule
import XCTest

/// Public conformance: the owned 1D through 4D types are `Sendable` when `Element: Sendable`.
final class BareArray_0_PublicSurfaceTests: XCTestCase {

  // MARK: - Sendable

  #if swift(>=5.5)
    func testOwnedArraysAreSendable_compiles() {
      func requiresSendable<T: Sendable & ~Copyable>(_ value: borrowing T) {}
      requiresSendable(ElementBuffer<Int>(repeating: 0, count: 1))
      requiresSendable(ElementBuffer2D<Int>(repeating: 0, width: 1, height: 1))
      requiresSendable(ElementBuffer3D<Int>(repeating: 0, width: 1, height: 1, depth: 1))
      requiresSendable(ElementBuffer4D<Int>(repeating: 0, size0: 1, size1: 1, size2: 1, size3: 1))
    }
  #endif
}
