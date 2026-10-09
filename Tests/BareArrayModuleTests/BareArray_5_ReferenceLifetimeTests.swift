import BareArrayModule
import XCTest

/// 要素の寿命: 所有型は要素を所有し、上書きで古い要素を、破棄で全要素をちょうど1回解放する。
/// View経由の上書きも、所有者のstorage上の古い要素を解放する。
final class BareArray_5_ReferenceLifetimeTests: XCTestCase {

  private final class Box {
    let onDeinit: () -> Void
    init(_ onDeinit: @escaping () -> Void) { self.onDeinit = onDeinit }
    deinit { onDeinit() }
  }

  func testBareArrayOverwriteDeinitializesPreviousReferenceElement() {
    var deinitCount = 0
    var array = BareArray<Box>(repeating: Box({ deinitCount += 1 }), count: 1)
    XCTAssertEqual(deinitCount, 0)

    array[0] = Box({ deinitCount += 1 })
    XCTAssertEqual(deinitCount, 1, "上書き時に古い要素がdeinitされること")

    array = BareArray<Box>(repeating: Box({ deinitCount += 1 }), count: 1)
    XCTAssertEqual(deinitCount, 2, "再代入直前に、直前のarrayのdeinitで要素も解放されること")
  }

  func testMultidimensionalArraysDeinitializeEveryReferenceElement() {
    var deinitCount = 0

    do {
      let array = BareArray2D<Box>(width: 2, height: 3) { Box { deinitCount += 1 } }
      withExtendedLifetime(array) {}
    }
    XCTAssertEqual(deinitCount, 6)

    do {
      let array = BareArray3D<Box>(width: 2, height: 2, depth: 2) { Box { deinitCount += 1 } }
      withExtendedLifetime(array) {}
    }
    XCTAssertEqual(deinitCount, 14)

    do {
      let array = BareArray4D<Box>(size0: 2, size1: 2, size2: 2, size3: 2) {
        Box { deinitCount += 1 }
      }
      withExtendedLifetime(array) {}
    }
    XCTAssertEqual(deinitCount, 30)
  }

  func testViewOverwriteDeinitializesPreviousReferenceElement() {
    var deinitCount = 0
    var array = BareArray4D<Box>(size0: 1, size1: 1, size2: 1, size3: 1) {
      Box { deinitCount += 1 }
    }

    array[0][0][0][0] = Box { deinitCount += 1 }

    XCTAssertEqual(deinitCount, 1)
    withExtendedLifetime(array) {}
  }
}
