//
//  PurifiedTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/05/26.
//

#if DEBUG && !COMPATIBLE_ATCODER_2025
  import XCTest
  @testable import RedBlackTreeModule

  extension Result where Success == _LazyTieWrap<_NodePtrSealing>, Failure == SealError {

    var __recycle_count: UnsafeNode.Seal? {
      try? map { $0.rawValue.pointer.pointee.___recycle_count }.get()
    }

    var seal: UnsafeNode.Seal? {
      try? map { $0.rawValue.seal }.get()
    }

    var ___tracking_tag: _TrackingTag? {
      try? map { $0.rawValue.pointer.pointee.___tracking_tag }.get()
    }
  }

  final class PurifiedTests: RedBlackTreeTestCase {

    func testExample0() throws {
      var a = RedBlackTreeSet<Int>(0..<10)
      let i0 = a.find(5)
      XCTAssertEqual(i0.__recycle_count, 0)
      XCTAssertEqual(i0.seal, 0)
      XCTAssertNil(a.__tree_.__purified_(i0).error)
      a.remove(5)
      XCTAssertEqual(i0.__recycle_count, 1)
      XCTAssertEqual(i0.seal, 0)
      a.insert(5)
      XCTAssertEqual(i0.__recycle_count, 1)
      XCTAssertEqual(i0.seal, 0)
      a.remove(5)
      XCTAssertEqual(i0.__recycle_count, 2)
      XCTAssertEqual(i0.seal, 0)
      XCTAssertEqual(a.__tree_.__purified_(i0).error, .unsealed)
      var b = a
      b.insert(5)
      let i1 = b.find(5)
      XCTAssertEqual(i0.___tracking_tag, i1.___tracking_tag)
      XCTAssertEqual(i0.__recycle_count, 2)
      XCTAssertEqual(i1.__recycle_count, 0, "CoW発生後、リサイクル数は0からリセットになる模様。把握してなかった")
      #if ALLOW_CROSS_TREE_INDEX
        XCTAssertEqual(b.__tree_.__purified_(i0).error, .unsealed)
      #else
        XCTAssertEqual(b.__tree_.__purified_(i0).error, .crossTree)
      #endif
    }

    func testExample1() throws {
      let a = RedBlackTreeSet<Int>(0..<10)

      let i0 = a.find(5)
      XCTAssertEqual(i0.__recycle_count, 0)
      XCTAssertNil(a.__tree_.__purified_(i0).error)

      var b = a
      b.remove(5)
      XCTAssertEqual(i0.__recycle_count, 0)
      #if ALLOW_CROSS_TREE_INDEX
        XCTAssertEqual(b.__tree_.__purified_(i0).error, .garbaged)  // TODO: この挙動について再検討
      #else
        XCTAssertEqual(b.__tree_.__purified_(i0).error, .crossTree)
      #endif
      b.insert(5)

      let i1 = b.find(5)
      XCTAssertEqual(i0.___tracking_tag, i1.___tracking_tag)
      XCTAssertEqual(i0.__recycle_count, 0)
      XCTAssertEqual(i1.__recycle_count, 1)
      #if ALLOW_CROSS_TREE_INDEX
        XCTAssertEqual(b.__tree_.__purified_(i0).error, .unsealed)
      #else
        XCTAssertEqual(b.__tree_.__purified_(i0).error, .crossTree)
      #endif
    }

    func testExample2() throws {
      let a = RedBlackTreeSet<Int>()
      XCTAssertEqual(a.__tree_.__purified_(a.startIndex).accessible.error, .garbaged)
      XCTAssertEqual(a.__tree_.__purified_(a.endIndex).accessible.error, .garbaged)
    }
  }
#endif
