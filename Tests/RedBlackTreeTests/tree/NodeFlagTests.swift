import XCTest
import Algorithms

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

#if DEBUG

final class NodeFlagTests0_10_20: TreeFixture0_10_20 {

  func testNodeFlag() {
    XCTAssertEqual(___ptr_bitmap(__root()), 1 << (UInt.bitWidth - 1))
    for (a,b) in (0...2).permutations(ofCount: 2).map({ ($0[0],$0[1])}) {
      XCTAssertEqual(___ptr_comp_multi(a, b), ___ptr_bitmap(a) < ___ptr_bitmap(b))
      XCTAssertEqual(___ptr_comp_multi(b, a), ___ptr_bitmap(b) < ___ptr_bitmap(a))
      XCTAssertEqual(___ptr_comp_multi(a, b), ___ptr_comp_bitmap(a, b))
      XCTAssertEqual(___ptr_comp_multi(b, a), ___ptr_comp_bitmap(b, a))
    }
  }
}

final class NodeFlagTests0_1_2_3_4_5_6: TreeFixture0_1_2_3_4_5_6 {

  func testNodeFlag() {
    XCTAssertEqual(___ptr_bitmap(__root()), 1 << (UInt.bitWidth - 1))
    for (a,b) in (0...6).permutations(ofCount: 2).map({ ($0[0],$0[1])}) {
      XCTAssertEqual(___ptr_comp_multi(a, b), ___ptr_bitmap(a) < ___ptr_bitmap(b))
      XCTAssertEqual(___ptr_comp_multi(b, a), ___ptr_bitmap(b) < ___ptr_bitmap(a))
      XCTAssertEqual(___ptr_comp_multi(a, b), ___ptr_comp_bitmap(a, b))
      XCTAssertEqual(___ptr_comp_multi(b, a), ___ptr_comp_bitmap(b, a))
    }
  }
}

#endif
