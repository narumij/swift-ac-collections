import BareArrayModule
import XCTest

/// 公開適合: 所有型1D〜4Dは、`Element: Sendable`のとき`Sendable`である。
final class BareArray_0_PublicSurfaceTests: XCTestCase {

  // MARK: - Sendable

  #if swift(>=5.5)
    func testOwnedArraysAreSendable_compiles() {
      func requiresSendable<T: Sendable & ~Copyable>(_ value: borrowing T) {}
      requiresSendable(BareArray<Int>(repeating: 0, count: 1))
      requiresSendable(BareArray2D<Int>(repeating: 0, width: 1, height: 1))
      requiresSendable(BareArray3D<Int>(repeating: 0, width: 1, height: 1, depth: 1))
      requiresSendable(BareArray4D<Int>(repeating: 0, size0: 1, size1: 1, size2: 1, size3: 1))
    }
  #endif
}
