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

  // BARE-046 E: the buffer owns one strong reference per slot, not the objects themselves.
  // `withExtendedLifetime` fixes the observation points, so releasing a slot and an object's
  // deinitialization are observed separately.

  func testElementReadKeepsObjectAliveAfterBufferIsDestroyed() {
    var deinitCount = 0
    var kept: Box?
    do {
      let array = ElementBuffer<Box>(count: 2) { Box { deinitCount += 1 } }
      kept = array.element(at: 1)
      withExtendedLifetime(array) {}
    }
    XCTAssertEqual(deinitCount, 1, "only the element that was not read is released with the buffer")
    XCTAssertNotNil(kept)
    kept = nil
    XCTAssertEqual(deinitCount, 2, "the read element is released when its last reference goes away")
  }

  func testOverwriteDoesNotDestroyObjectReferencedElsewhere() {
    var deinitCount = 0
    let shared = Box { deinitCount += 1 }
    let array = ElementBuffer2D<Box>(repeating: shared, width: 1, height: 1)

    array.setElement(Box { deinitCount += 1 }, at: 0, 0)
    XCTAssertEqual(deinitCount, 0, "overwriting a slot releases only the slot's reference")
    XCTAssertFalse(array.element(at: 0, 0) === shared)
    withExtendedLifetime(array) {}
    withExtendedLifetime(shared) {}
  }

  func testRepeatingInitializerSharesOneObjectAcrossSlotsAndDestroysItOnce() {
    var deinitCount = 0
    var source: Box? = Box { deinitCount += 1 }
    do {
      let array = ElementBuffer3D<Box>(repeating: source!, width: 2, height: 1, depth: 2)
      for z in 0..<2 {
        for x in 0..<2 {
          XCTAssertTrue(array.element(at: x, 0, z) === source, "(\(x), 0, \(z))")
        }
      }
      source = nil
      XCTAssertEqual(deinitCount, 0, "the buffer slots still hold the shared object")
      withExtendedLifetime(array) {}
    }
    XCTAssertEqual(deinitCount, 1, "the shared object is destroyed exactly once with the last slot")
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
