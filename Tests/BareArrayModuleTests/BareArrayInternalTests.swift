#if DEBUG && os(macOS)
  @testable import BareArrayModule
  import XCTest

  final class BareArrayInternalTests: XCTestCase {

    func testBareArrayCloneCreatesIndependentStorage() {
      var array = BareArray<Int>(repeating: 0, count: 3)
      array[1] = 123
      var clone = array.clone()
      clone[1] = 999

      XCTAssertEqual(array[1], 123)
      XCTAssertEqual(clone[1], 999)
    }

    func testBareArray2DCloneCreatesIndependentStorage() {
      var array = BareArray2D<Int>(repeating: 0, width: 2, height: 2)
      array[1][0] = 123
      var clone = array.clone()
      clone[1][0] = 999

      XCTAssertEqual(array[1][0], 123)
      XCTAssertEqual(clone[1][0], 999)
    }

    func testBareArray3DCloneCreatesIndependentStorage() {
      var array = BareArray3D<Int>(repeating: 0, width: 2, height: 2, depth: 2)
      array[1][0][1] = 123
      var clone = array.clone()
      clone[1][0][1] = 999

      XCTAssertEqual(array[1][0][1], 123)
      XCTAssertEqual(clone[1][0][1], 999)
    }

    func testBareArray4DCloneCreatesIndependentStorage() {
      var array = BareArray4D<Int>(repeating: 0, size0: 2, size1: 2, size2: 2, size3: 2)
      array[1][1][1][1] = 123
      var clone = array.clone()
      clone[1][1][1][1] = 999

      XCTAssertEqual(array[1][1][1][1], 123)
      XCTAssertEqual(clone[1][1][1][1], 999)
    }

    func testBareArrayCloneWithString() {
      var array = BareArray<String>(repeating: "", count: 2)
      array[0] = "abc"
      var clone = array.clone()
      clone[0] = "xyz"

      XCTAssertEqual(array[0], "abc")
      XCTAssertEqual(clone[0], "xyz")
    }

    func testBareArray3DCloneDeinitializesEveryReferenceElement() {
      final class Box {
        let onDeinit: () -> Void
        init(_ onDeinit: @escaping () -> Void) { self.onDeinit = onDeinit }
        deinit { onDeinit() }
      }

      var deinitCount = 0
      do {
        let array = BareArray3D<Box>(width: 2, height: 2, depth: 2) {
          Box { deinitCount += 1 }
        }
        let clone = array.clone()
        withExtendedLifetime(array) {}
        withExtendedLifetime(clone) {}
      }

      XCTAssertEqual(deinitCount, 8)
    }
  }
#endif
