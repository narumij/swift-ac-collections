import Algorithms
import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

#if DEBUG

  @inlinable
  func uintCenteredToInt(_ u: UInt) -> Int {
    let signBit = UInt(1) << (UInt.bitWidth - 1)  // 1<<63 on 64-bit
    return Int(bitPattern: u ^ signBit)
  }

  @inlinable
  func intToUintCentered(_ i: Int) -> UInt {
    let signBit = UInt(1) << (UInt.bitWidth - 1)
    return UInt(bitPattern: i) ^ signBit
  }

  final class NodeFlagTests0_10_20: TreeFixture0_10_20 {

    func testTo() {
      XCTAssertEqual(uintCenteredToInt(1 << 63), 0)
      XCTAssertEqual(uintCenteredToInt(0), Int.min)
      XCTAssertEqual(uintCenteredToInt(UInt.max), Int.max)
    }

    func testNodeFlag() {
      XCTAssertEqual(___ptr_bitmap(__root), 1 << (UInt.bitWidth - 1))
      for (a, b) in (0...2).permutations(ofCount: 2).map({ ($0[0], $0[1]) }) {
        XCTAssertEqual(___ptr_comp_multi(a, b), ___ptr_bitmap(a) < ___ptr_bitmap(b))
        XCTAssertEqual(___ptr_comp_multi(b, a), ___ptr_bitmap(b) < ___ptr_bitmap(a))
        XCTAssertEqual(
          ___ptr_comp_multi(a, b),
          uintCenteredToInt(___ptr_bitmap(a)) < uintCenteredToInt(___ptr_bitmap(b)))
        XCTAssertEqual(
          ___ptr_comp_multi(b, a),
          uintCenteredToInt(___ptr_bitmap(b)) < uintCenteredToInt(___ptr_bitmap(a)))
        XCTAssertEqual(___ptr_comp_multi(a, b), ___ptr_comp_bitmap(a, b))
        XCTAssertEqual(___ptr_comp_multi(b, a), ___ptr_comp_bitmap(b, a))
      }
    }

    func testNodeFlag128() {
      XCTAssertEqual(___ptr_bitmap_128(__root), 1 << (UInt128.bitWidth - 1))
      for (a, b) in (0...2).permutations(ofCount: 2).map({ ($0[0], $0[1]) }) {
        XCTAssertEqual(___ptr_comp_multi(a, b), ___ptr_bitmap_128(a) < ___ptr_bitmap_128(b))
        XCTAssertEqual(___ptr_comp_multi(b, a), ___ptr_bitmap_128(b) < ___ptr_bitmap_128(a))
      }
    }
  }

  final class NodeFlagTests0_1_2_3_4_5_6: TreeFixture0_1_2_3_4_5_6 {

    func testNodeFlag() {
      XCTAssertEqual(___ptr_bitmap(__root), 1 << (UInt.bitWidth - 1))
      for (a, b) in (0...6).permutations(ofCount: 2).map({ ($0[0], $0[1]) }) {
        XCTAssertEqual(___ptr_comp_multi(a, b), ___ptr_bitmap(a) < ___ptr_bitmap(b))
        XCTAssertEqual(___ptr_comp_multi(b, a), ___ptr_bitmap(b) < ___ptr_bitmap(a))
        XCTAssertEqual(
          ___ptr_comp_multi(a, b),
          uintCenteredToInt(___ptr_bitmap(a)) < uintCenteredToInt(___ptr_bitmap(b)))
        XCTAssertEqual(
          ___ptr_comp_multi(b, a),
          uintCenteredToInt(___ptr_bitmap(b)) < uintCenteredToInt(___ptr_bitmap(a)))
        XCTAssertEqual(___ptr_comp_multi(a, b), ___ptr_comp_bitmap(a, b))
        XCTAssertEqual(___ptr_comp_multi(b, a), ___ptr_comp_bitmap(b, a))
      }
    }

    func testNodeFlag128() {
      XCTAssertEqual(___ptr_bitmap_128(__root), 1 << (UInt128.bitWidth - 1))
      for (a, b) in (0...6).permutations(ofCount: 2).map({ ($0[0], $0[1]) }) {
        XCTAssertEqual(___ptr_comp_multi(a, b), ___ptr_bitmap_128(a) < ___ptr_bitmap_128(b))
        XCTAssertEqual(___ptr_comp_multi(b, a), ___ptr_bitmap_128(b) < ___ptr_bitmap_128(a))
      }
    }
  }

#endif
