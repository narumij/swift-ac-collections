import BareArrayModule
import XCTest

  final class BareArray_1_PublicContractTests: XCTestCase {

    // MARK: - BareArray

    func testBareArrayRepeating() {
      let array = BareArray<Int>(repeating: 42, count: 5)

      XCTAssertEqual(Array(array.indices), [0, 1, 2, 3, 4])

      for i in array.indices {
        XCTAssertEqual(array[i], 42)
      }
    }

    func testBareArrayInitializerClosure() {
      var value = 0

      let array = BareArray<Int>(count: 5) {
        defer { value += 1 }
        return value
      }

      XCTAssertEqual(array[0], 0)
      XCTAssertEqual(array[1], 1)
      XCTAssertEqual(array[2], 2)
      XCTAssertEqual(array[3], 3)
      XCTAssertEqual(array[4], 4)
    }

    func testBareArrayMutation() {
      var array = BareArray<Int>(repeating: 0, count: 3)

      array[0] = 10
      array[1] = 20
      array[2] = 30

      XCTAssertEqual(array[0], 10)
      XCTAssertEqual(array[1], 20)
      XCTAssertEqual(array[2], 30)
    }

    // MARK: - BareArray2D

    func testBareArray2DRepeating() {
      let array = BareArray2D<Int>(
        repeating: 7,
        width: 3,
        height: 2)

      for y in array.indices {
        for x in array[y].indices {
          XCTAssertEqual(array[y][x], 7)
        }
      }
    }

    func testBareArray2DMutation() {
      var array = BareArray2D<Int>(
        repeating: 0,
        width: 3,
        height: 2)

      array[0][0] = 1
      array[0][1] = 2
      array[1][2] = 3

      XCTAssertEqual(array[0][0], 1)
      XCTAssertEqual(array[0][1], 2)
      XCTAssertEqual(array[1][2], 3)
    }

    func testBareArray2DSliceReflectsOriginalStorage() {
      let array = BareArray2D<Int>(
        repeating: 0,
        width: 2,
        height: 2)

      var row = array[1]
      row[0] = 123

      // 標準ではこの挙動は許容できないのだとおもう。
      XCTAssertEqual(array[1][0], 123)
    }

    func testBareArray2DInitializerClosure() {
      var value = 0

      let array = BareArray2D<Int>(
        width: 2,
        height: 2
      ) {
        defer { value += 1 }
        return value
      }

      XCTAssertEqual(array[0][0], 0)
      XCTAssertEqual(array[0][1], 1)
      XCTAssertEqual(array[1][0], 2)
      XCTAssertEqual(array[1][1], 3)
    }

    // MARK: - BareArray3D

    func testBareArray3DMutation() {
      var array = BareArray3D<Int>(
        repeating: 0,
        width: 2,
        height: 2,
        depth: 2)

      array[0][0][0] = 10
      array[0][1][1] = 20
      array[1][0][1] = 30

      XCTAssertEqual(array[0][0][0], 10)
      XCTAssertEqual(array[0][1][1], 20)
      XCTAssertEqual(array[1][0][1], 30)
    }

    func testBareArray3DRepeating() {
      let array = BareArray3D<Int>(repeating: 7, width: 2, height: 3, depth: 4)

      for z in array.indices {
        for y in array[z].indices {
          for x in array[z][y].indices {
            XCTAssertEqual(array[z][y][x], 7)
          }
        }
      }
    }

    func testBareArray3DInitializerClosure() {
      var value = 0

      let array = BareArray3D<Int>(
        width: 2,
        height: 2,
        depth: 2
      ) {
        defer { value += 1 }
        return value
      }

      XCTAssertEqual(array[0][0][0], 0)
      XCTAssertEqual(array[0][0][1], 1)
      XCTAssertEqual(array[0][1][0], 2)
      XCTAssertEqual(array[0][1][1], 3)
      XCTAssertEqual(array[1][0][0], 4)
      XCTAssertEqual(array[1][0][1], 5)
      XCTAssertEqual(array[1][1][0], 6)
      XCTAssertEqual(array[1][1][1], 7)
    }

    func testBareArray3DSliceReflectsOriginalStorage() {
      let array = BareArray3D<Int>(
        repeating: 0,
        width: 2,
        height: 2,
        depth: 2)

      var plane = array[1]
      plane[0][1] = 999

      XCTAssertEqual(array[1][0][1], 999)
    }

    // MARK: - BareArray4D

    func testBareArray4DMutation() {
      var array = BareArray4D<Int>(
        repeating: 0,
        size0: 2,
        size1: 2,
        size2: 2,
        size3: 2)

      array[1][0][1][0] = 1234

      XCTAssertEqual(array[1][0][1][0], 1234)
    }

    func testBareArray4DRepeating() {
      let array = BareArray4D<Int>(repeating: 7, size0: 2, size1: 3, size2: 2, size3: 2)

      for w in array.indices {
        for z in array[w].indices {
          for y in array[w][z].indices {
            for x in array[w][z][y].indices {
              XCTAssertEqual(array[w][z][y][x], 7)
            }
          }
        }
      }
    }

    func testBareArray4DInitializerClosure() {
      var value = 0

      let array = BareArray4D<Int>(
        size0: 2,
        size1: 2,
        size2: 2,
        size3: 2
      ) {
        defer { value += 1 }
        return value
      }

      XCTAssertEqual(array[0][0][0][0], 0)
      XCTAssertEqual(array[0][0][0][1], 1)
      XCTAssertEqual(array[1][1][1][1], 15)
    }

    func testBareArray4DSliceReflectsOriginalStorage() {
      let array = BareArray4D<Int>(
        repeating: 0,
        size0: 2,
        size1: 2,
        size2: 2,
        size3: 2)

      var cube = array[1]
      cube[1][1][1] = 555

      XCTAssertEqual(array[1][1][1][1], 555)
    }

    // MARK: - Indices

    func testIndices() {
      XCTAssertEqual(
        Array(BareArray<Int>(repeating: 0, count: 3).indices),
        [0, 1, 2])

      XCTAssertEqual(
        Array(BareArray2D<Int>(repeating: 0, width: 2, height: 4).indices),
        [0, 1, 2, 3])

      XCTAssertEqual(
        Array(BareArray3D<Int>(repeating: 0, width: 2, height: 2, depth: 3).indices),
        [0, 1, 2])

      XCTAssertEqual(
        Array(
          BareArray4D<Int>(
            repeating: 0,
            size0: 2,
            size1: 2,
            size2: 2,
            size3: 4
          ).indices),
        [0, 1, 2, 3])
    }

    func testSliceIndices() {
      let array2d = BareArray2D<Int>(
        repeating: 0,
        width: 3,
        height: 2)

      XCTAssertEqual(
        Array(array2d[0].indices),
        [0, 1, 2])

      let array3d = BareArray3D<Int>(
        repeating: 0,
        width: 2,
        height: 3,
        depth: 4)

      XCTAssertEqual(
        Array(array3d[0].indices),
        [0, 1, 2])

      XCTAssertEqual(
        Array(array3d[0][0].indices),
        [0, 1])

      let array4d = BareArray4D<Int>(
        repeating: 0,
        size0: 2,
        size1: 3,
        size2: 4,
        size3: 5)

      XCTAssertEqual(
        Array(array4d[0].indices),
        [0, 1, 2, 3])

      XCTAssertEqual(
        Array(array4d[0][0].indices),
        [0, 1, 2])

      XCTAssertEqual(
        Array(array4d[0][0][0].indices),
        [0, 1])
    }

    // MARK: - Zero count

    func testBareArrayEmptyHasNoIndices() {
      let array = BareArray<Int>(repeating: 0, count: 0)
      XCTAssertEqual(Array(array.indices), [])
    }

    func testZeroDimensionsCreateEmptyStorageWithoutCallingInitializerClosure() {
      var calls = 0

      let one = BareArray<Int>(count: 0) {
        calls += 1
        return 0
      }
      let two = BareArray2D<Int>(width: 0, height: 3) {
        calls += 1
        return 0
      }
      let three = BareArray3D<Int>(width: .max, height: .max, depth: 0) {
        calls += 1
        return 0
      }
      let four = BareArray4D<Int>(size0: .max, size1: .max, size2: .max, size3: 0) {
        calls += 1
        return 0
      }

      XCTAssertTrue(one.indices.isEmpty)
      XCTAssertEqual(Array(two.indices), [0, 1, 2])
      XCTAssertTrue(two[0].indices.isEmpty)
      XCTAssertTrue(three.indices.isEmpty)
      XCTAssertTrue(four.indices.isEmpty)
      XCTAssertEqual(calls, 0)
    }

    // MARK: - Sendable

    #if swift(>=5.5)
      func testSendable_compiles() {
        func requiresSendable<T: Sendable & ~Copyable>(_ value: borrowing T) {}
        requiresSendable(BareArray<Int>(repeating: 0, count: 1))
        requiresSendable(BareArray2D<Int>(repeating: 0, width: 1, height: 1))
        requiresSendable(BareArray3D<Int>(repeating: 0, width: 1, height: 1, depth: 1))
        requiresSendable(BareArray4D<Int>(repeating: 0, size0: 1, size1: 1, size2: 1, size3: 1))
      }
    #endif

    // MARK: - Reference element lifetime

    func testBareArrayOverwriteDeinitializesPreviousReferenceElement() {
      final class Box {
        let onDeinit: () -> Void
        init(_ onDeinit: @escaping () -> Void) { self.onDeinit = onDeinit }
        deinit { onDeinit() }
      }

      var deinitCount = 0
      var array = BareArray<Box>(repeating: Box({ deinitCount += 1 }), count: 1)
      XCTAssertEqual(deinitCount, 0)

      array[0] = Box({ deinitCount += 1 })
      XCTAssertEqual(deinitCount, 1, "上書き時に古い要素がdeinitされること")

      array = BareArray<Box>(repeating: Box({ deinitCount += 1 }), count: 1)
      XCTAssertEqual(deinitCount, 2, "再代入直前に、直前のarrayのdeinitで要素も解放されること")
    }

    func testMultidimensionalArraysDeinitializeEveryReferenceElement() {
      final class Box {
        let onDeinit: () -> Void
        init(_ onDeinit: @escaping () -> Void) { self.onDeinit = onDeinit }
        deinit { onDeinit() }
      }

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
      final class Box {
        let onDeinit: () -> Void
        init(_ onDeinit: @escaping () -> Void) { self.onDeinit = onDeinit }
        deinit { onDeinit() }
      }

      var deinitCount = 0
      var array = BareArray4D<Box>(size0: 1, size1: 1, size2: 1, size3: 1) {
        Box { deinitCount += 1 }
      }

      array[0][0][0][0] = Box { deinitCount += 1 }

      XCTAssertEqual(deinitCount, 1)
      withExtendedLifetime(array) {}
    }

    // MARK: - Asymmetric dimensions (BARE-009)
    //
    // 正方形・立方体ではstrideの取り違えが隠れるため、各軸の長さを変えて全位置を確かめる。
    // 初期化closureの返り値はstorageへ順に格納されるので、各位置の値はそのまま線形位置になる。

    func testBareArray2DChainedSubscriptReachesEveryPositionWithAsymmetricDimensions() {
      let (width, height) = (3, 2)
      var next = 0
      let array = BareArray2D<Int>(width: width, height: height) {
        defer { next += 1 }
        return next
      }

      for y in 0..<height {
        for x in 0..<width {
          XCTAssertEqual(array[y][x], y * width + x, "[\(y)][\(x)]")
        }
      }
    }

    func testBareArray3DChainedSubscriptReachesEveryPositionWithAsymmetricDimensions() {
      let (width, height, depth) = (2, 3, 4)
      var next = 0
      let array = BareArray3D<Int>(width: width, height: height, depth: depth) {
        defer { next += 1 }
        return next
      }

      for z in 0..<depth {
        for y in 0..<height {
          for x in 0..<width {
            XCTAssertEqual(array[z][y][x], (z * height + y) * width + x, "[\(z)][\(y)][\(x)]")
          }
        }
      }
    }

    func testBareArray4DChainedSubscriptReachesEveryPositionWithAsymmetricDimensions() {
      let (size0, size1, size2, size3) = (2, 3, 4, 5)
      var next = 0
      let array = BareArray4D<Int>(size0: size0, size1: size1, size2: size2, size3: size3) {
        defer { next += 1 }
        return next
      }

      for w in 0..<size3 {
        for z in 0..<size2 {
          for y in 0..<size1 {
            for x in 0..<size0 {
              XCTAssertEqual(
                array[w][z][y][x], ((w * size2 + z) * size1 + y) * size0 + x,
                "[\(w)][\(z)][\(y)][\(x)]")
            }
          }
        }
      }
    }

    func testBareArray2DViewOffsetAndSharingWithAsymmetricDimensions() {
      let (width, height, depth) = (2, 3, 4)
      var next = 0
      let array = BareArray3D<Int>(width: width, height: height, depth: depth) {
        defer { next += 1 }
        return next
      }

      for z in 0..<depth {
        var plane = array[z]
        for y in 0..<height {
          for x in 0..<width {
            let linear = (z * height + y) * width + x
            XCTAssertEqual(plane[y][x], linear, "plane \(z) [\(y)][\(x)]")
            plane[y][x] = -linear - 1
          }
        }
      }

      // View経由の書き込みが、各面の外へはみ出さず元のstorageへ反映されていること
      for z in 0..<depth {
        for y in 0..<height {
          for x in 0..<width {
            XCTAssertEqual(array[z][y][x], -((z * height + y) * width + x) - 1, "[\(z)][\(y)][\(x)]")
          }
        }
      }
    }

    func testBareArray3DViewOffsetAndSharingWithAsymmetricDimensions() {
      let (size0, size1, size2, size3) = (2, 3, 4, 5)
      var next = 0
      let array = BareArray4D<Int>(size0: size0, size1: size1, size2: size2, size3: size3) {
        defer { next += 1 }
        return next
      }

      for w in 0..<size3 {
        var cube = array[w]
        for z in 0..<size2 {
          for y in 0..<size1 {
            for x in 0..<size0 {
              let linear = ((w * size2 + z) * size1 + y) * size0 + x
              XCTAssertEqual(cube[z][y][x], linear, "cube \(w) [\(z)][\(y)][\(x)]")
              cube[z][y][x] = -linear - 1
            }
          }
        }
      }

      for w in 0..<size3 {
        for z in 0..<size2 {
          for y in 0..<size1 {
            for x in 0..<size0 {
              XCTAssertEqual(
                array[w][z][y][x], -(((w * size2 + z) * size1 + y) * size0 + x) - 1,
                "[\(w)][\(z)][\(y)][\(x)]")
            }
          }
        }
      }
    }
  }
