#if DEBUG
  @testable import ElementBufferModule
  import XCTest

  /// 実装test: `clone()`は公開宣言ではなく`internal`で、`@testable import`が使えるDEBUG構成だけで検証する。
  /// cloneは新しいstorageへ要素をcopy初期化し、元配列と独立に要素を保持する。
  final class BareArray_98_CloneTests: XCTestCase {

    func testBareArrayCloneCreatesIndependentStorage() {
      let array = ElementBuffer<Int>(repeating: 0, count: 3)
      array.setElement(123, at: 1)
      let clone = array.clone()
      clone.setElement(999, at: 1)

      XCTAssertEqual(array.element(at: 1), 123)
      XCTAssertEqual(clone.element(at: 1), 999)
    }

    func testBareArray2DCloneCreatesIndependentStorage() {
      let array = ElementBuffer2D<Int>(repeating: 0, width: 2, height: 2)
      array.setElement(123, at: 0, 1)
      let clone = array.clone()
      clone.setElement(999, at: 0, 1)

      XCTAssertEqual(array.element(at: 0, 1), 123)
      XCTAssertEqual(clone.element(at: 0, 1), 999)
    }

    func testBareArray3DCloneCreatesIndependentStorage() {
      let array = ElementBuffer3D<Int>(repeating: 0, width: 2, height: 2, depth: 2)
      array.setElement(123, at: 1, 0, 1)
      let clone = array.clone()
      clone.setElement(999, at: 1, 0, 1)

      XCTAssertEqual(array.element(at: 1, 0, 1), 123)
      XCTAssertEqual(clone.element(at: 1, 0, 1), 999)
    }

    func testBareArray4DCloneCreatesIndependentStorage() {
      let array = ElementBuffer4D<Int>(repeating: 0, size0: 2, size1: 2, size2: 2, size3: 2)
      array.setElement(123, at: 1, 1, 1, 1)
      let clone = array.clone()
      clone.setElement(999, at: 1, 1, 1, 1)

      XCTAssertEqual(array.element(at: 1, 1, 1, 1), 123)
      XCTAssertEqual(clone.element(at: 1, 1, 1, 1), 999)
    }

    func testBareArrayCloneWithString() {
      let array = ElementBuffer<String>(repeating: "", count: 2)
      array.setElement("abc", at: 0)
      let clone = array.clone()
      clone.setElement("xyz", at: 0)

      XCTAssertEqual(array.element(at: 0), "abc")
      XCTAssertEqual(clone.element(at: 0), "xyz")
    }

    func testBareArray3DCloneDeinitializesEveryReferenceElement() {
      final class Box {
        let onDeinit: () -> Void
        init(_ onDeinit: @escaping () -> Void) { self.onDeinit = onDeinit }
        deinit { onDeinit() }
      }

      var deinitCount = 0
      do {
        let array = ElementBuffer3D<Box>(width: 2, height: 2, depth: 2) {
          Box { deinitCount += 1 }
        }
        let clone = array.clone()
        withExtendedLifetime(array) {}
        withExtendedLifetime(clone) {}
      }

      XCTAssertEqual(deinitCount, 8)
    }

    /// `clone()`は次元ごとに別実装のため、3D以外の1D/2D/4Dでも、cloneが元配列と
    /// 独立に参照要素を保持し、両方の破棄で全要素がちょうど1回解放されることを検証する。
    func testBareArrayClonesOwnReferenceElementsIndependently() {
      final class Box {
        let onDeinit: () -> Void
        init(_ onDeinit: @escaping () -> Void) { self.onDeinit = onDeinit }
        deinit { onDeinit() }
      }

      var deinitCount = 0

      do {
        let clone: ElementBuffer<Box>
        do {
          let array = ElementBuffer<Box>(count: 3) { Box { deinitCount += 1 } }
          clone = array.clone()
          withExtendedLifetime(array) {}
        }
        XCTAssertEqual(deinitCount, 0, "元配列の破棄後もcloneが要素を保持すること")
        withExtendedLifetime(clone) {}
      }
      XCTAssertEqual(deinitCount, 3)

      do {
        let clone: ElementBuffer2D<Box>
        do {
          let array = ElementBuffer2D<Box>(width: 2, height: 3) { Box { deinitCount += 1 } }
          clone = array.clone()
          withExtendedLifetime(array) {}
        }
        XCTAssertEqual(deinitCount, 3, "元配列の破棄後もcloneが要素を保持すること")
        withExtendedLifetime(clone) {}
      }
      XCTAssertEqual(deinitCount, 9)

      do {
        let clone: ElementBuffer4D<Box>
        do {
          let array = ElementBuffer4D<Box>(size0: 2, size1: 2, size2: 2, size3: 2) {
            Box { deinitCount += 1 }
          }
          clone = array.clone()
          withExtendedLifetime(array) {}
        }
        XCTAssertEqual(deinitCount, 9, "元配列の破棄後もcloneが要素を保持すること")
        withExtendedLifetime(clone) {}
      }
      XCTAssertEqual(deinitCount, 25)
    }
  }
#endif
