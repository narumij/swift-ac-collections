import ElementBufferModule
import XCTest

/// On Swift 6.4 and later, a borrowed reference accesses the owner's storage directly and depends on the owner's lifetime.
@available(macOS 27.0, *)
final class BareArray_7_BorrowedReferenceTests: XCTestCase {

  func testReferenceReadsAndWritesOwnerStorage() {
    var one = ElementBuffer<Int>(repeating: 0, count: 3)
    var oneReference = one.reference(at: 1)
    oneReference.value = 11
    XCTAssertEqual(oneReference.value, 11)
    XCTAssertEqual(one.element(at: 1), 11)

    var two = ElementBuffer2D<Int>(repeating: 0, width: 2, height: 3)
    var twoReference = two.reference(at: 1, 2)
    twoReference.value = 22
    XCTAssertEqual(twoReference.value, 22)
    XCTAssertEqual(two.element(at: 1, 2), 22)

    var three = ElementBuffer3D<Int>(repeating: 0, width: 2, height: 3, depth: 4)
    var threeReference = three.reference(at: 1, 2, 3)
    threeReference.value = 33
    XCTAssertEqual(threeReference.value, 33)
    XCTAssertEqual(three.element(at: 1, 2, 3), 33)

    var four = ElementBuffer4D<Int>(repeating: 0, size0: 2, size1: 3, size2: 4, size3: 5)
    var fourReference = four.reference(at: 1, 2, 3, 4)
    fourReference.value = 44
    XCTAssertEqual(fourReference.value, 44)
    XCTAssertEqual(four.element(at: 1, 2, 3, 4), 44)
  }

  // BARE-046 B: every coordinate of an asymmetric shape, with a distinct initial value per element.
  // The reference reads the initial value computed independently from the storage order, and each
  // write is observed through `element(at:)`, a separate access path, without changing any other element.

  func testReference1DReachesEveryPositionAndUpdatesOnlyThatElement() {
    let count = 5
    var next = 0
    var array = ElementBuffer<Int>(count: count) {
      defer { next += 1 }
      return next
    }
    func initial(_ x: Int) -> Int { x }
    func written(_ x: Int) -> Int { -1 - initial(x) }

    for target in 0..<count {
      var reference = array.reference(at: target)
      XCTAssertEqual(reference.value, initial(target), "(\(target))")
      reference.value = written(target)
      for x in 0..<count {
        let expected = x <= target ? written(x) : initial(x)
        XCTAssertEqual(array.element(at: x), expected, "write (\(target)) read (\(x))")
      }
    }
  }

  func testReference2DReachesEveryPositionAndUpdatesOnlyThatElement() {
    let (width, height) = (2, 3)
    var next = 0
    var array = ElementBuffer2D<Int>(width: width, height: height) {
      defer { next += 1 }
      return next
    }
    func initial(_ x: Int, _ y: Int) -> Int { y * width + x }
    func written(_ x: Int, _ y: Int) -> Int { -1 - initial(x, y) }

    for ty in 0..<height {
      for tx in 0..<width {
        var reference = array.reference(at: tx, ty)
        XCTAssertEqual(reference.value, initial(tx, ty), "(\(tx), \(ty))")
        reference.value = written(tx, ty)
        let target = initial(tx, ty)
        for y in 0..<height {
          for x in 0..<width {
            let expected = initial(x, y) <= target ? written(x, y) : initial(x, y)
            XCTAssertEqual(array.element(at: x, y), expected, "write (\(tx), \(ty)) read (\(x), \(y))")
          }
        }
      }
    }
  }

  func testReference3DReachesEveryPositionAndUpdatesOnlyThatElement() {
    let (width, height, depth) = (2, 3, 4)
    var next = 0
    var array = ElementBuffer3D<Int>(width: width, height: height, depth: depth) {
      defer { next += 1 }
      return next
    }
    func initial(_ x: Int, _ y: Int, _ z: Int) -> Int { (z * height + y) * width + x }
    func written(_ x: Int, _ y: Int, _ z: Int) -> Int { -1 - initial(x, y, z) }

    for tz in 0..<depth {
      for ty in 0..<height {
        for tx in 0..<width {
          var reference = array.reference(at: tx, ty, tz)
          XCTAssertEqual(reference.value, initial(tx, ty, tz), "(\(tx), \(ty), \(tz))")
          reference.value = written(tx, ty, tz)
          let target = initial(tx, ty, tz)
          for z in 0..<depth {
            for y in 0..<height {
              for x in 0..<width {
                let expected = initial(x, y, z) <= target ? written(x, y, z) : initial(x, y, z)
                XCTAssertEqual(
                  array.element(at: x, y, z), expected,
                  "write (\(tx), \(ty), \(tz)) read (\(x), \(y), \(z))")
              }
            }
          }
        }
      }
    }
  }

  func testReference4DReachesEveryPositionAndUpdatesOnlyThatElement() {
    let (size0, size1, size2, size3) = (2, 3, 4, 5)
    var next = 0
    var array = ElementBuffer4D<Int>(size0: size0, size1: size1, size2: size2, size3: size3) {
      defer { next += 1 }
      return next
    }
    func initial(_ x: Int, _ y: Int, _ z: Int, _ w: Int) -> Int {
      ((w * size2 + z) * size1 + y) * size0 + x
    }
    func written(_ x: Int, _ y: Int, _ z: Int, _ w: Int) -> Int { -1 - initial(x, y, z, w) }

    for tw in 0..<size3 {
      for tz in 0..<size2 {
        for ty in 0..<size1 {
          for tx in 0..<size0 {
            var reference = array.reference(at: tx, ty, tz, tw)
            XCTAssertEqual(reference.value, initial(tx, ty, tz, tw), "(\(tx), \(ty), \(tz), \(tw))")
            reference.value = written(tx, ty, tz, tw)
            let target = initial(tx, ty, tz, tw)
            for w in 0..<size3 {
              for z in 0..<size2 {
                for y in 0..<size1 {
                  for x in 0..<size0 {
                    let value = initial(x, y, z, w)
                    let expected = value <= target ? written(x, y, z, w) : value
                    XCTAssertEqual(
                      array.element(at: x, y, z, w), expected,
                      "write (\(tx), \(ty), \(tz), \(tw)) read (\(x), \(y), \(z), \(w))")
                  }
                }
              }
            }
          }
        }
      }
    }
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
      var array = ElementBuffer<Box>(count: 1) { Box(id: 0) { destroyed.append($0) } }
      var reference = array.reference(at: 0)
      reference.value = Box(id: 1) { destroyed.append($0) }

      XCTAssertEqual(destroyed, [0])
      XCTAssertEqual(reference.value.id, 1)
      XCTAssertEqual(array.element(at: 0).id, 1)
      withExtendedLifetime(array) {}
    }
    XCTAssertEqual(destroyed, [0, 1])
  }
}
