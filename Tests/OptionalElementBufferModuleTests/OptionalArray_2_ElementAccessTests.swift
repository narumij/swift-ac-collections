import XCTest
import OptionalElementBufferModule

final class OptionalArray_2_ElementAccessTests: XCTestCase {

  // MARK: - OptionalElementBuffer

  func testOptionalArray1DSetAndGet() {
    let array = OptionalElementBuffer<Int>(capacity: 3)

    array.setElement(10, at: 0)
    array.setElement(30, at: 2)

    XCTAssertEqual(array.element(at: 0), 10)
    XCTAssertNil(array.element(at: 1))
    XCTAssertEqual(array.element(at: 2), 30)
  }

  func testOptionalArray1DAssignNil() {
    let array = OptionalElementBuffer<Int>(capacity: 3)

    array.setElement(123, at: 1)
    XCTAssertEqual(array.element(at: 1), 123)

    array.setElement(nil, at: 1)
    XCTAssertNil(array.element(at: 1))
  }

  func testOptionalArray1DDirectMethods() {
    let array = OptionalElementBuffer<Int>(capacity: 2)
    XCTAssertNil(array.element(at: 1))
    array.setElement(10, at: 1)
    XCTAssertEqual(array.element(at: 1), 10)
    array.setElement(nil, at: 1)
    XCTAssertNil(array.element(at: 1))
  }

  // MARK: - OptionalElementBuffer2D

  func testOptionalArray2DSetAndGet() {
    let array = OptionalElementBuffer2D<Int>(
      width: 2,
      height: 2)

    array.setElement(10, at: 0, 0)
    array.setElement(20, at: 1, 1)

    XCTAssertEqual(array.element(at: 0, 0), 10)
    XCTAssertEqual(array.element(at: 1, 1), 20)
    XCTAssertNil(array.element(at: 1, 0))
  }

  func testOptionalArray2DDirectMethods() {
    let array = OptionalElementBuffer2D<Int>(width: 2, height: 3)
    XCTAssertNil(array.element(at: 1, 2))
    array.setElement(20, at: 1, 2)
    XCTAssertEqual(array.element(at: 1, 2), 20)
    XCTAssertNil(array.element(at: 0, 2))
    array.setElement(nil, at: 1, 2)
    XCTAssertNil(array.element(at: 1, 2))
  }

  // MARK: - OptionalElementBuffer3D

  func testOptionalArray3DSetAndGet() {
    let array = OptionalElementBuffer3D<Int>(
      width: 2,
      height: 2,
      depth: 2)

    array.setElement(999, at: 1, 0, 1)

    XCTAssertEqual(array.element(at: 1, 0, 1), 999)
    XCTAssertNil(array.element(at: 0, 0, 0))
  }

  func testOptionalArray3DDirectMethods() {
    let array = OptionalElementBuffer3D<Int>(width: 2, height: 3, depth: 4)
    XCTAssertNil(array.element(at: 1, 2, 3))
    array.setElement(30, at: 1, 2, 3)
    XCTAssertEqual(array.element(at: 1, 2, 3), 30)
    XCTAssertNil(array.element(at: 0, 2, 3))
    array.setElement(nil, at: 1, 2, 3)
    XCTAssertNil(array.element(at: 1, 2, 3))
  }

  // MARK: - OptionalElementBuffer4D

  func testOptionalArray4DSetAndGet() {
    let array = OptionalElementBuffer4D<Int>(
      size0: 2,
      size1: 2,
      size2: 2,
      size3: 2)

    array.setElement(1234, at: 0, 1, 0, 1)

    XCTAssertEqual(array.element(at: 0, 1, 0, 1), 1234)
    XCTAssertNil(array.element(at: 0, 0, 0, 0))
  }

  func testOptionalArray4DDirectMethods() {
    let array = OptionalElementBuffer4D<Int>(size0: 2, size1: 3, size2: 4, size3: 5)
    XCTAssertNil(array.element(at: 1, 2, 3, 4))
    array.setElement(40, at: 1, 2, 3, 4)
    XCTAssertEqual(array.element(at: 1, 2, 3, 4), 40)
    XCTAssertNil(array.element(at: 0, 2, 3, 4))
    array.setElement(nil, at: 1, 2, 3, 4)
    XCTAssertNil(array.element(at: 1, 2, 3, 4))
  }

  // MARK: - Unset slot versus a stored `Optional.none` (OPT-074 A)

  // With `Element == Int?`, `element(at:)` returns `Int??`. An unset slot is `.none`; a slot that
  // stores `nil` is `.some(.none)`. Passing the outer `nil` unsets a slot; passing `.some(nil)`
  // stores `nil`. Each state is classified by pattern matching so that the two nils never merge.

  private enum NestedSlot: Equatable {
    case unset
    case storedNil
    case stored(Int)
  }

  private static func classify(_ value: Int??) -> NestedSlot {
    switch value {
    case .none: return .unset
    case .some(.none): return .storedNil
    case .some(.some(let value)): return .stored(value)
    }
  }

  private func checkNestedOptionalStates<B: OptionalBufferProbe<Int?> & ~Copyable>(
    _ array: borrowing B, shape: [Int], file: StaticString = #filePath, line: UInt = #line
  ) {
    let positions = allCoordinates(shape)
    let first = 0
    let last = positions.count - 1
    var expected = Array(repeating: NestedSlot.unset, count: positions.count)

    func verify(_ stage: String) {
      for (i, position) in positions.enumerated() {
        XCTAssertEqual(
          Self.classify(array.probeElement(at: position)), expected[i],
          "\(stage) at \(position)", file: file, line: line)
      }
    }

    verify("initial")

    array.probeSetElement(Int??.some(nil), at: positions[first])
    expected[first] = .storedNil
    array.probeSetElement(Int??.some(5), at: positions[last])
    expected[last] = .stored(5)
    verify("store nil and a value")

    array.probeSetElement(Int??.some(7), at: positions[first])
    expected[first] = .stored(7)
    array.probeSetElement(Int??.some(nil), at: positions[last])
    expected[last] = .storedNil
    verify("overwrite stored nil with a value and a value with stored nil")

    array.probeSetElement(Int??.none, at: positions[first])
    expected[first] = .unset
    array.probeSetElement(Int??.none, at: positions[last])
    expected[last] = .unset
    verify("unset with the outer nil")

    array.probeSetElement(Int??.some(nil), at: positions[first])
    expected[first] = .storedNil
    array.probeSetElement(Int??.some(9), at: positions[last])
    expected[last] = .stored(9)
    verify("set again after unsetting")

    array.removeAll()
    expected = Array(repeating: .unset, count: positions.count)
    verify("removeAll")

    array.probeSetElement(Int??.some(nil), at: positions[last])
    expected[last] = .storedNil
    verify("store nil after removeAll")
  }

  func testUnsetSlotAndStoredNilAreDistinct1D() {
    let array = OptionalElementBuffer<Int?>(capacity: 3)
    checkNestedOptionalStates(array, shape: [3])
  }

  func testUnsetSlotAndStoredNilAreDistinct2D() {
    let array = OptionalElementBuffer2D<Int?>(width: 2, height: 3)
    checkNestedOptionalStates(array, shape: [2, 3])
  }

  func testUnsetSlotAndStoredNilAreDistinct3D() {
    let array = OptionalElementBuffer3D<Int?>(width: 2, height: 3, depth: 2)
    checkNestedOptionalStates(array, shape: [2, 3, 2])
  }

  func testUnsetSlotAndStoredNilAreDistinct4D() {
    let array = OptionalElementBuffer4D<Int?>(size0: 2, size1: 1, size2: 3, size3: 2)
    checkNestedOptionalStates(array, shape: [2, 1, 3, 2])
  }
}
