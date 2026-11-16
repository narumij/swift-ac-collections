import XCTest
import OptionalElementBufferModule

final class OptionalArray_5_RemoveAllTests: XCTestCase {

  // MARK: - OptionalElementBuffer

  func testOptionalArray1DRemoveAll() {
    let array = OptionalElementBuffer<Int>(capacity: 3)

    array.setElement(1, at: 0)
    array.setElement(2, at: 1)
    array.setElement(3, at: 2)

    array.removeAll()

    XCTAssertNil(array.element(at: 0))
    XCTAssertNil(array.element(at: 1))
    XCTAssertNil(array.element(at: 2))
  }

  // MARK: - OptionalElementBuffer2D

  func testOptionalArray2DRemoveAll() {
    let array = OptionalElementBuffer2D<Int>(
      width: 2,
      height: 2)

    array.setElement(1, at: 0, 0)
    array.setElement(2, at: 1, 1)

    array.removeAll()

    XCTAssertNil(array.element(at: 0, 0))
    XCTAssertNil(array.element(at: 1, 1))
  }

  // MARK: - OptionalElementBuffer3D

  func testOptionalArray3DRemoveAll() {
    let array = OptionalElementBuffer3D<Int>(
      width: 2,
      height: 2,
      depth: 2)

    array.setElement(999, at: 1, 0, 1)

    array.removeAll()

    XCTAssertNil(array.element(at: 1, 0, 1))
  }

  // MARK: - OptionalElementBuffer4D

  func testOptionalArray4DRemoveAll() {
    let array = OptionalElementBuffer4D<Int>(
      size0: 2,
      size1: 2,
      size2: 2,
      size3: 2)

    array.setElement(1234, at: 0, 1, 0, 1)

    array.removeAll()

    XCTAssertNil(array.element(at: 0, 1, 0, 1))
  }

  // MARK: - Repeated removeAll and reuse of every position (OPT-074 C)

  // Small asymmetric shapes go through: removeAll on the initial empty state, a sparse fill,
  // removeAll, removeAll again, a fill of every position, and destruction. Every stage checks every
  // coordinate and `indices`. Destroyed identifiers are recorded, so a double release or a leak
  // shows up as a wrong identifier list rather than only a wrong count.

  private func assertAllUnset<B: OptionalBufferProbe & ~Copyable>(
    _ array: borrowing B, _ positions: [[Int]], indices: Range<Int>, _ stage: String,
    file: StaticString = #filePath, line: UInt = #line
  ) {
    for position in positions {
      XCTAssertNil(array.probeElement(at: position), "\(stage) at \(position)", file: file, line: line)
    }
    XCTAssertEqual(array.indices, indices, stage, file: file, line: line)
  }

  private func checkRepeatedRemoveAllAndFullReuse<B: OptionalBufferProbe<TrackedBox> & ~Copyable>(
    _ makeBuffer: () -> B, shape: [Int], indices: Range<Int>,
    file: StaticString = #filePath, line: UInt = #line
  ) {
    let positions = allCoordinates(shape)
    let sparse = Array(stride(from: 0, to: positions.count, by: 2))
    var destroyed: [Int] = []
    let array = makeBuffer()

    array.removeAll()
    assertAllUnset(array, positions, indices: indices, "removeAll on the initial state", file: file, line: line)
    XCTAssertEqual(destroyed, [], file: file, line: line)

    for i in sparse {
      array.probeSetElement(TrackedBox(100 + i) { destroyed.append($0) }, at: positions[i])
    }
    for (i, position) in positions.enumerated() {
      XCTAssertEqual(
        array.probeElement(at: position)?.id, sparse.contains(i) ? 100 + i : nil,
        "sparse fill at \(position)", file: file, line: line)
    }

    array.removeAll()
    assertAllUnset(array, positions, indices: indices, "removeAll after the sparse fill", file: file, line: line)
    XCTAssertEqual(destroyed.sorted(), sparse.map { 100 + $0 }, file: file, line: line)

    array.removeAll()
    assertAllUnset(array, positions, indices: indices, "removeAll again", file: file, line: line)
    XCTAssertEqual(destroyed.count, sparse.count, "a second removeAll releases nothing", file: file, line: line)

    for (i, position) in positions.enumerated() {
      array.probeSetElement(TrackedBox(200 + i) { destroyed.append($0) }, at: position)
    }
    for (i, position) in positions.enumerated() {
      XCTAssertEqual(array.probeElement(at: position)?.id, 200 + i, "full reuse at \(position)", file: file, line: line)
    }
    XCTAssertEqual(array.indices, indices, file: file, line: line)
    XCTAssertEqual(destroyed.count, sparse.count, file: file, line: line)

    _ = consume array
    XCTAssertEqual(
      destroyed.sorted(), sparse.map { 100 + $0 } + positions.indices.map { 200 + $0 },
      "every element is released exactly once", file: file, line: line)
  }

  func testRepeatedRemoveAllAndFullReuse1D() {
    checkRepeatedRemoveAllAndFullReuse(
      { OptionalElementBuffer<TrackedBox>(capacity: 5) }, shape: [5], indices: 0..<5)
  }

  func testRepeatedRemoveAllAndFullReuse2D() {
    checkRepeatedRemoveAllAndFullReuse(
      { OptionalElementBuffer2D<TrackedBox>(width: 2, height: 3) }, shape: [2, 3], indices: 0..<3)
  }

  func testRepeatedRemoveAllAndFullReuse3D() {
    checkRepeatedRemoveAllAndFullReuse(
      { OptionalElementBuffer3D<TrackedBox>(width: 2, height: 3, depth: 2) }, shape: [2, 3, 2],
      indices: 0..<2)
  }

  func testRepeatedRemoveAllAndFullReuse4D() {
    checkRepeatedRemoveAllAndFullReuse(
      { OptionalElementBuffer4D<TrackedBox>(size0: 2, size1: 1, size2: 3, size3: 2) },
      shape: [2, 1, 3, 2], indices: 0..<2)
  }

  // MARK: - Buffers with no elements (OPT-074 D)

  // A buffer with a zero dimension has no slots. Repeated removeAll must be safe and must keep
  // `indices`, which still reports the outermost axis when only an inner axis is zero.
  // Access to coordinate zero in these shapes is rejected in `OptionalArray_97`.

  private func checkRepeatedRemoveAllOnEmpty<B: OptionalBufferProbe & ~Copyable>(
    _ array: borrowing B, indices: Range<Int>, file: StaticString = #filePath, line: UInt = #line
  ) {
    array.removeAll()
    array.removeAll()
    XCTAssertEqual(array.indices, indices, file: file, line: line)
  }

  func testRepeatedRemoveAllOnBuffersWithNoElements() {
    checkRepeatedRemoveAllOnEmpty(OptionalElementBuffer<Int>(capacity: 0), indices: 0..<0)

    checkRepeatedRemoveAllOnEmpty(OptionalElementBuffer2D<Int>(width: 0, height: 3), indices: 0..<3)
    checkRepeatedRemoveAllOnEmpty(OptionalElementBuffer2D<Int>(width: 2, height: 0), indices: 0..<0)

    checkRepeatedRemoveAllOnEmpty(OptionalElementBuffer3D<Int>(width: 0, height: 2, depth: 3), indices: 0..<3)
    checkRepeatedRemoveAllOnEmpty(OptionalElementBuffer3D<Int>(width: 2, height: 0, depth: 3), indices: 0..<3)
    checkRepeatedRemoveAllOnEmpty(OptionalElementBuffer3D<Int>(width: 2, height: 2, depth: 0), indices: 0..<0)

    checkRepeatedRemoveAllOnEmpty(
      OptionalElementBuffer4D<Int>(size0: 0, size1: 2, size2: 2, size3: 3), indices: 0..<3)
    checkRepeatedRemoveAllOnEmpty(
      OptionalElementBuffer4D<Int>(size0: 2, size1: 0, size2: 2, size3: 3), indices: 0..<3)
    checkRepeatedRemoveAllOnEmpty(
      OptionalElementBuffer4D<Int>(size0: 2, size1: 2, size2: 0, size3: 3), indices: 0..<3)
    checkRepeatedRemoveAllOnEmpty(
      OptionalElementBuffer4D<Int>(size0: 2, size1: 2, size2: 2, size3: 0), indices: 0..<0)
  }
}
