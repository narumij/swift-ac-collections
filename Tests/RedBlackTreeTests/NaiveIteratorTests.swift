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
      let it = ___UnsafeNaiveIterator(
        nullptr: a.__tree_.nullptr,
        __first: a.__tree_.__begin_node_,
        __last: a.__tree_.__end_node)
      XCTAssertEqual(it.map { a.__tree_[$0] }, [Int](0..<5))
    }

    func testNaiveReverse() throws {
      let a = RedBlackTreeSet<Int>(0..<5)
      let it = ___UnsafeNaiveRevIterator(
        nullptr: a.__tree_.nullptr,
        __first: a.__tree_.__begin_node_,
        __last: a.__tree_.__end_node)
      XCTAssertEqual(it.map { a.__tree_[$0] }, [Int](0..<5).reversed())
    }

    func testWrappedForward() throws {
      let a = RedBlackTreeSet<Int>(0..<5)
      let wrapped = ___UnsafeRemoveAwareWrapper(
        iterator: ___UnsafeNaiveIterator(
          nullptr: a.__tree_.nullptr,
          __first: a.__tree_.__begin_node_,
          __last: a.__tree_.__end_node))
      XCTAssertEqual(wrapped.map { a.__tree_[$0] }, [Int](0..<5))
    }

    func testWrappedReverse() throws {
      let a = RedBlackTreeSet<Int>(0..<5)
      let wrapped = ___UnsafeRemoveAwareWrapper(
        iterator: ___UnsafeNaiveRevIterator(
          nullptr: a.__tree_.nullptr,
          __first: a.__tree_.__begin_node_,
          __last: a.__tree_.__end_node))
      XCTAssertEqual(wrapped.map { a.__tree_[$0] }, [Int](0..<5).reversed())
    }

    func testValuesForward() throws {
      let a = RedBlackTreeSet<Int>(0..<5)
      let it = ___UnsafeValueWrapper<RedBlackTreeSet<Int>, ___UnsafeNaiveIterator>(
        iterator: ___UnsafeNaiveIterator(
          nullptr: a.__tree_.nullptr,
          __first: a.__tree_.__begin_node_,
          __last: a.__tree_.__end_node))
      XCTAssertEqual(it.map { $0 }, [Int](0..<5))
    }

    func testValuesReverse() throws {
      let a = RedBlackTreeSet<Int>(0..<5)
      let it = ___UnsafeValueWrapper<RedBlackTreeSet<Int>, ___UnsafeRemoveAwareWrapper>(
        iterator: ___UnsafeRemoveAwareWrapper(
          iterator:
            ___UnsafeNaiveRevIterator(
              nullptr: a.__tree_.nullptr,
              __first: a.__tree_.__begin_node_,
              __last: a.__tree_.__end_node)))
      XCTAssertEqual(it.map { $0 }, [Int](0..<5).reversed())
    }

    func testRemoveProof_initial() throws {
      var a = RedBlackTreeMultiSet<Int>((0..<5).flatMap { [$0, $0] })
      let it = ___UnsafeRemoveProofIterator_initial<RedBlackTreeMultiSet<Int>>(
        nullptr: a.__tree_.nullptr,
        __first: a.__tree_.__begin_node_,
        __last: a.__tree_.end,
        __end_node: a.__tree_.__end_node,
        __current: (a.startIndex.rawValue, 0))
      for i in it {
        print("a.removeAll", i.__value_().pointee as Int)
        a.removeAll(i.__value_().pointee)
        print("a", a + [])
      }
      XCTAssertTrue(a.isEmpty)
      XCTAssertEqual(a + [], [])
    }

    func testRemoveUnproof() throws {

      var a = RedBlackTreeMultiSet<Int>((0..<5).flatMap { [$0, $0] })

      let it = ___UnsafeRemoveProofWrapper_naive(
        sequence: ___UnsafeNaiveIterator(
          nullptr: a.__tree_.nullptr,
          __first: a.__tree_.__begin_node_,
          __last: a.__tree_.__end_node))

      for i in AnySequence(it + []) {
        print("a.removeAll", i.__value_().pointee as Int)
        a.removeAll(i.__value_().pointee)
        print("a", a + [])
      }

      XCTAssertTrue(a.isEmpty)
      XCTAssertEqual(a + [], [])
    }

  }
#endif
