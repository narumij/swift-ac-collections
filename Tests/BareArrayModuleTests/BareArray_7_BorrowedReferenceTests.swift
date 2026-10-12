import BareArrayModule
import XCTest

/// Swift 6.4以降の借用参照はownerのstorageへ直接到達し、ownerの寿命へ依存する。
final class BareArray_7_BorrowedReferenceTests: XCTestCase {

  func testReferenceReadsAndWritesOwnerStorage() {
    let one = BareArray<Int>(repeating: 0, count: 3)
    let oneReference = one.reference(at: 1)
    oneReference.pointee = 11
    XCTAssertEqual(oneReference.pointee, 11)
    XCTAssertEqual(one.element(at: 1), 11)

    let two = BareArray2D<Int>(repeating: 0, width: 2, height: 3)
    let twoReference = two.reference(at: 1, 2)
    twoReference.pointee = 22
    XCTAssertEqual(twoReference.pointee, 22)
    XCTAssertEqual(two.element(at: 1, 2), 22)

    let three = BareArray3D<Int>(repeating: 0, width: 2, height: 3, depth: 4)
    let threeReference = three.reference(at: 1, 2, 3)
    threeReference.pointee = 33
    XCTAssertEqual(threeReference.pointee, 33)
    XCTAssertEqual(three.element(at: 1, 2, 3), 33)

    let four = BareArray4D<Int>(repeating: 0, size0: 2, size1: 3, size2: 4, size3: 5)
    let fourReference = four.reference(at: 1, 2, 3, 4)
    fourReference.pointee = 44
    XCTAssertEqual(fourReference.pointee, 44)
    XCTAssertEqual(four.element(at: 1, 2, 3, 4), 44)
  }

  func testReferenceDestroysReplacedReferenceExactlyOnce() {
    final class Box {
      let id: Int
      let onDeinit: (Int) -> Void

      init(id: Int, onDeinit: @escaping (Int) -> Void) {
        self.id = id
        self.onDeinit = onDeinit
      }

      deinit { onDeinit(id) }
    }

    var destroyed: [Int] = []
    do {
      let array = BareArray<Box>(count: 1) { Box(id: 0) { destroyed.append($0) } }
      let reference = array.reference(at: 0)
      reference.pointee = Box(id: 1) { destroyed.append($0) }

      XCTAssertEqual(destroyed, [0])
      XCTAssertEqual(reference.pointee.id, 1)
      XCTAssertEqual(array.element(at: 0).id, 1)
      withExtendedLifetime(array) {}
    }
    XCTAssertEqual(destroyed, [0, 1])
  }
}
