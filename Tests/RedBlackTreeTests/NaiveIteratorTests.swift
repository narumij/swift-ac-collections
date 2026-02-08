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
      let it = UnsafeIterator._Obverse(
        _start: a.__tree_.__begin_node_,
        _end: a.__tree_.__end_node)
      XCTAssertEqual(it.map { a.__tree_[_unsafe_raw: $0] }, [Int](0..<5))
    }

    func testNaiveReverse() throws {
      let a = RedBlackTreeSet<Int>(0..<5)
      let it = UnsafeIterator._Reverse(
        _start: a.__tree_.__begin_node_,
        _end: a.__tree_.__end_node)
      XCTAssertEqual(it.map { a.__tree_[_unsafe_raw: $0] }, [Int](0..<5).reversed())
    }

    func testWrappedForward() throws {
      let a = RedBlackTreeSet<Int>(0..<5)
      let wrapped = UnsafeIterator._RemoveAware(
        source: UnsafeIterator._Obverse(
          _start: a.__tree_.__begin_node_,
          _end: a.__tree_.__end_node))
      XCTAssertEqual(wrapped.map { a.__tree_[_unsafe_raw: $0] }, [Int](0..<5))
    }

    func testWrappedReverse() throws {
      let a = RedBlackTreeSet<Int>(0..<5)
      let wrapped = UnsafeIterator._RemoveAware(
        source: UnsafeIterator._Reverse(
          _start: a.__tree_.__begin_node_,
          _end: a.__tree_.__end_node))
      XCTAssertEqual(wrapped.map { a.__tree_[_unsafe_raw: $0] }, [Int](0..<5).reversed())
    }

    func testValuesForward() throws {
      let a = RedBlackTreeSet<Int>(0..<5)
      let it = UnsafeIterator._Payload<RedBlackTreeSet<Int>, UnsafeIterator._Obverse>(
        source: .init(
          _start: a.__tree_.__begin_node_,
          _end: a.__tree_.__end_node))
      XCTAssertEqual(it.map { $0 }, [Int](0..<5))
    }

    func testValuesReverse() throws {
      let a = RedBlackTreeSet<Int>(0..<5)
      let it = UnsafeIterator._Payload<RedBlackTreeSet<Int>, UnsafeIterator._Reverse>(
        source: .init(
          _start: a.__tree_.__begin_node_,
          _end: a.__tree_.__end_node))
      XCTAssertEqual(it.map { $0 }, [Int](0..<5).reversed())
    }
  }
#endif
