//
//  NaiveIteratorTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2026/01/15.
//

import XCTest

#if DEBUG
  @testable import RedBlackTreeModule

  final class NaiveIteratorTests: RedBlackTreeTestCase {

    func testNaiveForward() throws {
      let a = RedBlackTreeSet<Int>(0..<5)
      let it = UnsafeIterator.Obverse(
        __first: a.__tree_.__begin_node_,
        __last: a.__tree_.__end_node)
      XCTAssertEqual(it.map { a.__tree_[$0] }, [Int](0..<5))
    }

    func testNaiveReverse() throws {
      let a = RedBlackTreeSet<Int>(0..<5)
      let it = UnsafeIterator.Reverse(
        __first: a.__tree_.__begin_node_,
        __last: a.__tree_.__end_node)
      XCTAssertEqual(it.map { a.__tree_[$0] }, [Int](0..<5).reversed())
    }

    func testWrappedForward() throws {
      let a = RedBlackTreeSet<Int>(0..<5)
      let wrapped = UnsafeIterator.RemoveAware(
        iterator: UnsafeIterator.Obverse(
          __first: a.__tree_.__begin_node_,
          __last: a.__tree_.__end_node))
      XCTAssertEqual(wrapped.map { a.__tree_[$0] }, [Int](0..<5))
    }

    func testWrappedReverse() throws {
      let a = RedBlackTreeSet<Int>(0..<5)
      let wrapped = UnsafeIterator.RemoveAware(
        iterator: UnsafeIterator.Reverse(
          __first: a.__tree_.__begin_node_,
          __last: a.__tree_.__end_node))
      XCTAssertEqual(wrapped.map { a.__tree_[$0] }, [Int](0..<5).reversed())
    }

    func testValuesForward() throws {
      let a = RedBlackTreeSet<Int>(0..<5)
      let it = UnsafeIterator.Value<RedBlackTreeSet<Int>, UnsafeIterator.Obverse>(
        iterator: .init(
          __first: a.__tree_.__begin_node_,
          __last: a.__tree_.__end_node))
      XCTAssertEqual(it.map { $0 }, [Int](0..<5))
    }

    func testValuesReverse() throws {
      let a = RedBlackTreeSet<Int>(0..<5)
      let it = UnsafeIterator.Value<RedBlackTreeSet<Int>, UnsafeIterator.Reverse>(
        iterator: .init(
          __first: a.__tree_.__begin_node_,
          __last: a.__tree_.__end_node))
      XCTAssertEqual(it.map { $0 }, [Int](0..<5).reversed())
    }
  }
#endif
