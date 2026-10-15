import ElementBufferModule
import XCTest

/// Element lifetime: an owned type owns its elements, releasing an old element on overwrite and every element exactly once on destruction.
/// Overwriting through coordinate access also releases the old element in the owner's storage.
final class BareArray_5_ReferenceLifetimeTests: XCTestCase {

  private final class Box {
    let onDeinit: () -> Void
    init(_ onDeinit: @escaping () -> Void) { self.onDeinit = onDeinit }
    deinit { onDeinit() }
  }

  func testBareArrayOverwriteDeinitializesPreviousReferenceElement() {
    var deinitCount = 0
    var array = ElementBuffer<Box>(repeating: Box({ deinitCount += 1 }), count: 1)
    XCTAssertEqual(deinitCount, 0)

    array.setElement(Box({ deinitCount += 1 }), at: 0)
    XCTAssertEqual(deinitCount, 1, "上書き時に古い要素がdeinitされること")

    array = ElementBuffer<Box>(repeating: Box({ deinitCount += 1 }), count: 1)
    XCTAssertEqual(deinitCount, 2, "再代入直前に、直前のarrayのdeinitで要素も解放されること")
  }

  func testMultidimensionalArraysDeinitializeEveryReferenceElement() {
    var deinitCount = 0

    do {
      let array = ElementBuffer2D<Box>(width: 2, height: 3) { Box { deinitCount += 1 } }
      withExtendedLifetime(array) {}
    }
    XCTAssertEqual(deinitCount, 6)

    do {
      let array = ElementBuffer3D<Box>(width: 2, height: 2, depth: 2) { Box { deinitCount += 1 } }
      withExtendedLifetime(array) {}
    }
    XCTAssertEqual(deinitCount, 14)

    do {
      let array = ElementBuffer4D<Box>(size0: 2, size1: 2, size2: 2, size3: 2) {
        Box { deinitCount += 1 }
      }
      withExtendedLifetime(array) {}
    }
    XCTAssertEqual(deinitCount, 30)
  }

  func testCoordinateOverwriteDeinitializesPreviousReferenceElement() {
    var deinitCount = 0
    let array = ElementBuffer4D<Box>(size0: 1, size1: 1, size2: 1, size3: 1) {
      Box { deinitCount += 1 }
    }

    array.setElement(Box { deinitCount += 1 }, at: 0, 0, 0, 0)

    XCTAssertEqual(deinitCount, 1)
    withExtendedLifetime(array) {}
  }
}
