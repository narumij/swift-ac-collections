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

    func testNaiveForward0() throws {
      let a = RedBlackTreeSet<Int>(0..<5)
      let it = UnsafeIterator._Obverse1(
        _start: a.__tree_.__begin_node_,
        _end: a.__tree_.__end_node)
      XCTAssertEqual(it.map { a.__tree_[_unsafe_raw: $0] }, [Int](0..<5))
    }

    func testNaiveReverse0() throws {
      let a = RedBlackTreeSet<Int>(0..<5)
      let it = UnsafeIterator._Reverse1(
        _start: a.__tree_.__begin_node_,
        _end: a.__tree_.__end_node)
      XCTAssertEqual(it.map { a.__tree_[_unsafe_raw: $0] }, [Int](0..<5).reversed())
    }
    
    func testNaiveForward1() throws {
      let a = RedBlackTreeSet<Int>(0..<5)
      let it = UnsafeIterator._Obverse1(
        _start: a.__tree_.__begin_node_,
        _end: a.__tree_.__end_node)
      XCTAssertEqual(it.map { a.__tree_[_unsafe_raw: $0] }, [Int](0..<5))
    }

    func testNaiveReverse1() throws {
      let a = RedBlackTreeSet<Int>(0..<5)
      let it = UnsafeIterator._Reverse1(
        _start: a.__tree_.__begin_node_,
        _end: a.__tree_.__end_node)
      XCTAssertEqual(it.map { a.__tree_[_unsafe_raw: $0] }, [Int](0..<5).reversed())
    }
    
    func testNaiveForward2() throws {
      let a = RedBlackTreeSet<Int>(0..<5)
      let it = UnsafeIterator._Obverse2(
        _start: a.__tree_.__begin_node_,
        _end: a.__tree_.__end_node)
      XCTAssertEqual(it.map { a.__tree_[_unsafe_raw: $0] }, [Int](0..<5))
    }

    func testNaiveReverse2() throws {
      let a = RedBlackTreeSet<Int>(0..<5)
      let it = UnsafeIterator._Reverse2(
        _start: a.__tree_.__begin_node_,
        _end: a.__tree_.__end_node)
      XCTAssertEqual(it.map { a.__tree_[_unsafe_raw: $0] }, [Int](0..<5).reversed())
    }
    
    func testNaiveForward3() throws {
      let a = RedBlackTreeSet<Int>(0..<5)
      let it = UnsafeIterator._Obverse3(
        _start: a.__tree_.__begin_node_,
        _end: a.__tree_.__end_node)
      XCTAssertEqual(it.map { a.__tree_[_unsafe_raw: $0] }, [Int](0..<5))
    }

    func testNaiveReverse3() throws {
      let a = RedBlackTreeSet<Int>(0..<5)
      let it = UnsafeIterator._Reverse3(
        _start: a.__tree_.__begin_node_,
        _end: a.__tree_.__end_node)
      XCTAssertEqual(it.map { a.__tree_[_unsafe_raw: $0] }, [Int](0..<5).reversed())
    }

    func testWrappedForward() throws {
      let a = RedBlackTreeSet<Int>(0..<5)
      let wrapped = UnsafeIterator._RemoveAware(
        source: UnsafeIterator._Obverse1(
          _start: a.__tree_.__begin_node_,
          _end: a.__tree_.__end_node))
      XCTAssertEqual(wrapped.map { a.__tree_[_unsafe_raw: $0] }, [Int](0..<5))
    }

    func testWrappedReverse() throws {
      let a = RedBlackTreeSet<Int>(0..<5)
      let wrapped = UnsafeIterator._RemoveAware(
        source: UnsafeIterator._Reverse1(
          _start: a.__tree_.__begin_node_,
          _end: a.__tree_.__end_node))
      XCTAssertEqual(wrapped.map { a.__tree_[_unsafe_raw: $0] }, [Int](0..<5).reversed())
    }

    func testValuesForward() throws {
      let a = RedBlackTreeSet<Int>(0..<5)
      let it = UnsafeIterator._Payload<RedBlackTreeSet<Int>.Base, UnsafeIterator._Obverse1>(
        source: .init(
          _start: a.__tree_.__begin_node_,
          _end: a.__tree_.__end_node))
      XCTAssertEqual(it.map { $0 }, [Int](0..<5))
    }

    func testValuesReverse() throws {
      let a = RedBlackTreeSet<Int>(0..<5)
      let it = UnsafeIterator._Payload<RedBlackTreeSet<Int>.Base, UnsafeIterator._Reverse1>(
        source: .init(
          _start: a.__tree_.__begin_node_,
          _end: a.__tree_.__end_node))
      XCTAssertEqual(it.map { $0 }, [Int](0..<5).reversed())
    }
  }
#endif
