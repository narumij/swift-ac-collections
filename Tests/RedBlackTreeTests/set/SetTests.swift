//
//  SortedSetTests.swift
//  swift-ac-collections
//
//  Created by narumij on 2024/09/16.
//

import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class SetTests: RedBlackTreeTestCase {

  func testInitEmtpy() throws {
    let set = RedBlackTreeSet<Int>()
    XCTAssertEqual(set.elements, [])
    XCTAssertEqual(set.count, 0)
    XCTAssertTrue(set.isEmpty)
    XCTAssertEqual(set.distance(from: set.startIndex, to: set.endIndex), 0)
    XCTAssertEqual(set.count(of: 0), 0)
  }

  func testRedBlackTreeCapacity() throws {
    var numbers: RedBlackTreeSet<Int> = .init(minimumCapacity: 3)
    XCTAssertGreaterThanOrEqual(numbers.capacity, 3)
    numbers.reserveCapacity(4)
    XCTAssertGreaterThanOrEqual(numbers.capacity, 4)
  }

  func testInitNaive0() throws {
    let set = RedBlackTreeSet<Int>(naive: 0..<0)
    XCTAssertEqual(set.elements, (0..<0) + [])
    XCTAssertEqual(set.count, 0)
    XCTAssertTrue(set.isEmpty)
    XCTAssertEqual(set.distance(from: set.startIndex, to: set.endIndex), 0)
  }

  func testInitRange() throws {
    let set = RedBlackTreeSet<Int>(0..<10000)
    XCTAssertEqual(set.elements, (0..<10000) + [])
    XCTAssertEqual(set.count, 10000)
    XCTAssertFalse(set.isEmpty)
    XCTAssertEqual(set.distance(from: set.startIndex, to: set.endIndex), 10000)
  }

  func testInitCollection1() throws {
    let set = RedBlackTreeSet<Int>(0..<10000)
    XCTAssertEqual(set.elements, (0..<10000) + [])
    XCTAssertEqual(set.count, 10000)
    XCTAssertFalse(set.isEmpty)
    XCTAssertEqual(set.distance(from: set.startIndex, to: set.endIndex), 10000)
  }

  func testInitCollection2() throws {
    let set = RedBlackTreeSet<Int>([2, 3, 3, 0, 0, 1, 1, 1])
    XCTAssertEqual(set.elements, [0, 1, 2, 3])
    XCTAssertEqual(set.count, 4)
    XCTAssertFalse(set.isEmpty)
    XCTAssertEqual(set.distance(from: set.startIndex, to: set.endIndex), set.count)
  }

  func testInitCollection3() throws {
    let set = RedBlackTreeSet<Int>(naive: [2, 3, 3, 0, 0, 1, 1, 1])
    XCTAssertEqual(set.elements, [0, 1, 2, 3])
    XCTAssertEqual(set.count, 4)
    XCTAssertFalse(set.isEmpty)
    XCTAssertEqual(set.distance(from: set.startIndex, to: set.endIndex), set.count)
  }

  func testExample3() throws {
    let b: RedBlackTreeSet<Int> = [1, 2, 3]
    XCTAssertEqual(b.distance(from: b.startIndex, to: b.endIndex), b.count)
  }

  #if DEBUG
    func testSubscript() throws {
      let b: RedBlackTreeSet<Int> = [1, 2, 3]
      XCTAssertEqual(b[b.startIndex], 1)
    }
  #endif

  func testSmoke() throws {
    let b: RedBlackTreeSet<Int> = [1, 2, 3]
    print(b)
    debugPrint(b)
  }

  func testInsert() throws {
    var set = RedBlackTreeSet<Int>([])
    XCTAssertEqual(set.insert(0).inserted, true)
    XCTAssertEqual(set.insert(1).inserted, true)
    XCTAssertEqual(set.insert(2).inserted, true)
    XCTAssertEqual(set.insert(3).inserted, true)
    XCTAssertEqual(set.insert(4).inserted, true)
    XCTAssertEqual(set.insert(0).inserted, false)
    XCTAssertEqual(set.insert(1).inserted, false)
    XCTAssertEqual(set.insert(2).inserted, false)
    XCTAssertEqual(set.insert(3).inserted, false)
    XCTAssertEqual(set.insert(4).inserted, false)
  }

  func testContains() throws {
    var set = RedBlackTreeSet<Int>([0, 1, 2, 3, 4])
    XCTAssertEqual(set.count, 5)
    XCTAssertEqual(set.contains(-1), false)
    XCTAssertEqual(set.contains(0), true)
    XCTAssertEqual(set.contains(1), true)
    XCTAssertEqual(set.contains(2), true)
    XCTAssertEqual(set.contains(3), true)
    XCTAssertEqual(set.contains(4), true)
    XCTAssertEqual(set.contains(5), false)
    XCTAssertEqual(set.remove(1), 1)
    XCTAssertEqual(set.remove(3), 3)
    XCTAssertEqual(set.remove(1), nil)
    XCTAssertEqual(set.remove(3), nil)
    XCTAssertEqual(set.elements, [0, 2, 4])
    XCTAssertEqual(set.contains(-1), false)
    XCTAssertEqual(set.contains(0), true)
    XCTAssertEqual(set.contains(1), false)
    XCTAssertEqual(set.contains(2), true)
    XCTAssertEqual(set.contains(3), false)
    XCTAssertEqual(set.contains(4), true)
    XCTAssertEqual(set.contains(5), false)
    XCTAssertEqual(set.remove(2), 2)
    XCTAssertEqual(set.remove(1), nil)
    XCTAssertEqual(set.remove(2), nil)
    XCTAssertEqual(set.remove(3), nil)
    XCTAssertEqual(set.elements, [0, 4])
    XCTAssertEqual(set.contains(-1), false)
    XCTAssertEqual(set.contains(0), true)
    XCTAssertEqual(set.contains(1), false)
    XCTAssertEqual(set.contains(2), false)
    XCTAssertEqual(set.contains(3), false)
    XCTAssertEqual(set.contains(4), true)
    XCTAssertEqual(set.contains(5), false)
    XCTAssertEqual(set.remove(0), 0)
    XCTAssertEqual(set.remove(1), nil)
    XCTAssertEqual(set.remove(2), nil)
    XCTAssertEqual(set.remove(3), nil)
    XCTAssertEqual(set.remove(4), 4)
    XCTAssertEqual(set.contains(-1), false)
    XCTAssertEqual(set.contains(0), false)
    XCTAssertEqual(set.contains(1), false)
    XCTAssertEqual(set.contains(2), false)
    XCTAssertEqual(set.contains(3), false)
    XCTAssertEqual(set.contains(4), false)
    XCTAssertEqual(set.contains(5), false)
    XCTAssertEqual(set.elements, [])
  }

  func testLeftRight() throws {
    var set = RedBlackTreeSet<Int>([0, 1, 2, 3, 4])
    XCTAssertEqual(set.count, 5)
    XCTAssertEqual(set.left(-1).index, 0)
    //        XCTAssertEqual(set.elements.count{ $0 < -1 }, 0)
    XCTAssertEqual(set.left(0).index, 0)
    //        XCTAssertEqual(set.elements.count{ $0 < 0 }, 0)
    XCTAssertEqual(set.left(1).index, 1)
    //        XCTAssertEqual(set.elements.count{ $0 < 1 }, 1)
    XCTAssertEqual(set.left(2).index, 2)
    XCTAssertEqual(set.left(3).index, 3)
    XCTAssertEqual(set.left(4).index, 4)
    XCTAssertEqual(set.left(5).index, 5)
    XCTAssertEqual(set.left(6).index, 5)
    XCTAssertEqual(set.right(-1).index, 0)
    //        XCTAssertEqual(set.elements.count{ $0 <= -1 }, 0)
    XCTAssertEqual(set.right(0).index, 1)
    //        XCTAssertEqual(set.elements.count{ $0 <= 0 }, 1)
    XCTAssertEqual(set.right(1).index, 2)
    //        XCTAssertEqual(set.elements.count{ $0 <= 1 }, 2)
    XCTAssertEqual(set.right(2).index, 3)
    XCTAssertEqual(set.right(3).index, 4)
    XCTAssertEqual(set.right(4).index, 5)
    XCTAssertEqual(set.right(5).index, 5)
    XCTAssertEqual(set.right(6).index, 5)
    XCTAssertEqual(set.remove(1), 1)
    XCTAssertEqual(set.remove(3), 3)
    XCTAssertEqual(set.remove(1), nil)
    XCTAssertEqual(set.remove(3), nil)
    XCTAssertEqual(set.elements, [0, 2, 4])
    XCTAssertEqual(set.left(-1).index, 0)
    XCTAssertEqual(set.left(0).index, 0)
    XCTAssertEqual(set.left(1).index, 1)
    XCTAssertEqual(set.left(2).index, 1)
    XCTAssertEqual(set.left(3).index, 2)
    XCTAssertEqual(set.left(4).index, 2)
    XCTAssertEqual(set.left(5).index, 3)
    XCTAssertEqual(set.right(-1).index, 0)
    XCTAssertEqual(set.right(0).index, 1)
    XCTAssertEqual(set.right(1).index, 1)
    XCTAssertEqual(set.right(2).index, 2)
    XCTAssertEqual(set.right(3).index, 2)
    XCTAssertEqual(set.right(4).index, 3)
    XCTAssertEqual(set.right(5).index, 3)
    XCTAssertEqual(set.remove(2), 2)
    XCTAssertEqual(set.remove(1), nil)
    XCTAssertEqual(set.remove(2), nil)
    XCTAssertEqual(set.remove(3), nil)
    XCTAssertEqual(set.elements, [0, 4])
    XCTAssertEqual(set.left(-1).index, 0)
    XCTAssertEqual(set.left(0).index, 0)
    XCTAssertEqual(set.left(1).index, 1)
    XCTAssertEqual(set.left(2).index, 1)
    XCTAssertEqual(set.left(3).index, 1)
    XCTAssertEqual(set.left(4).index, 1)
    XCTAssertEqual(set.left(5).index, 2)
    XCTAssertEqual(set.right(-1).index, 0)
    XCTAssertEqual(set.right(0).index, 1)
    XCTAssertEqual(set.right(1).index, 1)
    XCTAssertEqual(set.right(2).index, 1)
    XCTAssertEqual(set.right(3).index, 1)
    XCTAssertEqual(set.right(4).index, 2)
    XCTAssertEqual(set.right(5).index, 2)
    XCTAssertEqual(set.remove(0), 0)
    XCTAssertEqual(set.remove(1), nil)
    XCTAssertEqual(set.remove(2), nil)
    XCTAssertEqual(set.remove(3), nil)
    XCTAssertEqual(set.remove(4), 4)
    XCTAssertEqual(set.left(-1).index, 0)
    XCTAssertEqual(set.left(0).index, 0)
    XCTAssertEqual(set.left(1).index, 0)
    XCTAssertEqual(set.left(2).index, 0)
    XCTAssertEqual(set.left(3).index, 0)
    XCTAssertEqual(set.left(4).index, 0)
    XCTAssertEqual(set.left(5).index, 0)
    XCTAssertEqual(set.right(-1).index, 0)
    XCTAssertEqual(set.right(0).index, 0)
    XCTAssertEqual(set.right(1).index, 0)
    XCTAssertEqual(set.right(2).index, 0)
    XCTAssertEqual(set.right(3).index, 0)
    XCTAssertEqual(set.right(4).index, 0)
    XCTAssertEqual(set.right(5).index, 0)
    XCTAssertEqual(set.elements, [])
  }

  func testMinMax() throws {
    do {
      let set = RedBlackTreeSet<Int>([5, 2, 3, 1, 0])
      XCTAssertEqual(set.max(), 5)
      XCTAssertEqual(set.min(), 0)
    }
    do {
      let set = RedBlackTreeSet<Int>()
      XCTAssertEqual(set.max(), nil)
      XCTAssertEqual(set.min(), nil)
    }
  }

  func testSequence() throws {
    let set = RedBlackTreeSet<Int>([5, 2, 3, 1, 0])
    XCTAssertEqual(set + [], [0, 1, 2, 3, 5])
  }

  func testArrayAccess1() throws {
    let set = RedBlackTreeSet<Int>([0, 1, 2, 3, 4])
    XCTAssertEqual(set[set.index(set.startIndex, offsetBy: 0)], 0)
    XCTAssertEqual(set[set.index(set.startIndex, offsetBy: 1)], 1)
    XCTAssertEqual(set[set.index(set.startIndex, offsetBy: 2)], 2)
    XCTAssertEqual(set[set.index(set.startIndex, offsetBy: 3)], 3)
    XCTAssertEqual(set[set.index(set.startIndex, offsetBy: 4)], 4)
  }

  func testArrayAccess2() throws {
    let set = RedBlackTreeSet<Int>([0, 1, 2, 3, 4])
    XCTAssertEqual(set[set.index(set.endIndex, offsetBy: -5)], 0)
    XCTAssertEqual(set[set.index(set.endIndex, offsetBy: -4)], 1)
    XCTAssertEqual(set[set.index(set.endIndex, offsetBy: -3)], 2)
    XCTAssertEqual(set[set.index(set.endIndex, offsetBy: -2)], 3)
    XCTAssertEqual(set[set.index(set.endIndex, offsetBy: -1)], 4)
  }

  #if !COMPATIBLE_ATCODER_2025
    func testArrayAccess3() throws {
      let set = RedBlackTreeSet<Int>([0, 1, 2, 3, 4])
      XCTAssertEqual(set[unchecked: set.index(set.startIndex, offsetBy: 0)], 0)
      XCTAssertEqual(set[unchecked: set.index(set.startIndex, offsetBy: 1)], 1)
      XCTAssertEqual(set[unchecked: set.index(set.startIndex, offsetBy: 2)], 2)
      XCTAssertEqual(set[unchecked: set.index(set.startIndex, offsetBy: 3)], 3)
      XCTAssertEqual(set[unchecked: set.index(set.startIndex, offsetBy: 4)], 4)
    }

    func testArrayAccess4() throws {
      let set = RedBlackTreeSet<Int>([0, 1, 2, 3, 4])
      XCTAssertEqual(set[unchecked: set.index(set.endIndex, offsetBy: -5)], 0)
      XCTAssertEqual(set[unchecked: set.index(set.endIndex, offsetBy: -4)], 1)
      XCTAssertEqual(set[unchecked: set.index(set.endIndex, offsetBy: -3)], 2)
      XCTAssertEqual(set[unchecked: set.index(set.endIndex, offsetBy: -2)], 3)
      XCTAssertEqual(set[unchecked: set.index(set.endIndex, offsetBy: -1)], 4)
    }
  #endif

  func testIndexLimit1() throws {
    let set = Set<Int>([0, 1, 2, 3, 4])
    XCTAssertNotEqual(
      set.index(set.startIndex, offsetBy: 4, limitedBy: set.index(set.startIndex, offsetBy: 4)),
      nil)
    XCTAssertEqual(
      set.index(set.startIndex, offsetBy: 5, limitedBy: set.index(set.startIndex, offsetBy: 4)),
      nil)
    XCTAssertEqual(
      set.index(set.startIndex, offsetBy: 5, limitedBy: set.endIndex), set.endIndex)
    XCTAssertEqual(set.index(set.startIndex, offsetBy: 6, limitedBy: set.endIndex), nil)
    XCTAssertEqual(set.index(set.endIndex, offsetBy: 6, limitedBy: set.endIndex), nil)
    //      XCTAssertEqual(set.index(set.endIndex, offsetBy: -6, limitedBy: set.startIndex), nil)
  }

  func testIndexLimit2() throws {
    let set = RedBlackTreeSet<Int>([0, 1, 2, 3, 4])
    XCTAssertNotEqual(
      set.index(set.startIndex, offsetBy: 4, limitedBy: set.index(set.startIndex, offsetBy: 4)),
      nil)
    XCTAssertEqual(
      set.index(set.startIndex, offsetBy: 5, limitedBy: set.index(set.startIndex, offsetBy: 4)),
      nil)
    XCTAssertEqual(
      set.index(set.startIndex, offsetBy: 5, limitedBy: set.endIndex), set.endIndex)
    XCTAssertEqual(set.index(set.startIndex, offsetBy: 6, limitedBy: set.endIndex), nil)
    XCTAssertEqual(set.index(set.endIndex, offsetBy: 6, limitedBy: set.endIndex), nil)
  }

  #if DEBUG
    func testIndexLimit3() throws {
      let set = RedBlackTreeSet<Int>([0, 1, 2, 3, 4])
      XCTAssertEqual(set.startIndex._rawValue, .node(0))
      XCTAssertEqual(set.index(before: set.endIndex)._rawValue, .node(4))
      XCTAssertEqual(set.index(set.endIndex, offsetBy: -1)._rawValue, .node(4))
      XCTAssertEqual(
        set.index(set.endIndex, offsetBy: -1, limitedBy: set.startIndex)?._rawValue, .node(4))
      XCTAssertEqual(set.index(set.endIndex, offsetBy: -5)._rawValue, .node(0))
      XCTAssertEqual(set.index(set.endIndex, offsetBy: -5), set.startIndex)
      XCTAssertNotEqual(
        set.index(set.endIndex, offsetBy: -4, limitedBy: set.index(set.endIndex, offsetBy: -4)),
        nil)
      XCTAssertEqual(
        set.index(set.endIndex, offsetBy: -5, limitedBy: set.index(set.endIndex, offsetBy: -4)),
        nil)
      XCTAssertEqual(
        set.index(set.endIndex, offsetBy: -5, limitedBy: set.startIndex),
        set.startIndex)
      XCTAssertEqual(
        set.index(set.endIndex, offsetBy: -6, limitedBy: set.startIndex),
        nil)
      XCTAssertEqual(
        set.index(set.startIndex, offsetBy: -6, limitedBy: set.startIndex),
        nil)
    }
  #endif

  func testRandom() throws {
    var set = RedBlackTreeSet<Int>()
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.remove(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.remove(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in set {
      set.remove(i)
      XCTAssertTrue(set.___tree_invariant())
    }
  }

  func testRandom2() throws {
    var set = RedBlackTreeSet<Int>()
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.remove(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.remove(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in set[set.startIndex..<set.endIndex] {
      set.remove(i)
      XCTAssertTrue(set.___tree_invariant())
    }
  }

  func testRandom3() throws {
    var set = RedBlackTreeSet<Int>()
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.remove(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.remove(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert(i)
      XCTAssertTrue(set.___tree_invariant())
    }
  }

  func testRandom4() throws {
    var set = RedBlackTreeSet<Int>()
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.remove(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.remove(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert(i)
      XCTAssertTrue(set.___tree_invariant())
    }
  }

  func testLiteral() throws {
    let set: RedBlackTreeSet<Int> = [1, 1, 2, 2, 3, 3, 4, 4, 5, 5]
    XCTAssertEqual(set + [], [1, 2, 3, 4, 5])
    XCTAssertEqual(set.count(of: 0), 0)
    XCTAssertEqual(set.count(of: 1), 1)
    XCTAssertEqual(set.count(of: 2), 1)
    XCTAssertEqual(set.count(of: 3), 1)
    XCTAssertEqual(set.count(of: 4), 1)
    XCTAssertEqual(set.count(of: 5), 1)
  }

  class A: Hashable, Comparable {
    static func < (lhs: A, rhs: A) -> Bool {
      lhs.x < rhs.x
    }
    static func == (lhs: A, rhs: A) -> Bool {
      lhs.x == rhs.x
    }
    let x: Int
    let label: String
    init(x: Int, label: String) {
      self.x = x
      self.label = label
    }
    func hash(into hasher: inout Hasher) {
      hasher.combine(x)
    }
  }

  func testRedBlackTreeSetUpdate() throws {
    let a = A(x: 3, label: "a")
    let b = A(x: 3, label: "b")
    var s: RedBlackTreeSet<A> = [a]
    XCTAssertFalse(a === b)
    XCTAssertTrue(s.update(with: b) === a)
    XCTAssertTrue(s.update(with: a) === b)
    XCTAssertEqual(s.update(with: A(x: 10, label: "c")), nil)
  }

  func testRedBlackTreeSetInsert() throws {
    let a = A(x: 3, label: "a")
    let b = A(x: 3, label: "b")
    var s: RedBlackTreeSet<A> = []
    XCTAssertFalse(a === b)
    do {
      let r = s.insert(a)
      XCTAssertEqual(r.inserted, true)
      XCTAssertTrue(r.memberAfterInsert === a)
    }
    do {
      let r = s.insert(b)
      XCTAssertEqual(r.inserted, false)
      XCTAssertTrue(r.memberAfterInsert === a)
    }
  }

  #if DEBUG
    func testLowerBound() throws {
      let numbers: RedBlackTreeSet = [1, 3, 5]
      XCTAssertEqual(numbers.lowerBound(0)._rawValue, 0)
      XCTAssertEqual(numbers.lowerBound(1)._rawValue, 0)
      XCTAssertEqual(numbers.lowerBound(2)._rawValue, 1)
      XCTAssertEqual(numbers.lowerBound(3)._rawValue, 1)
      XCTAssertEqual(numbers.lowerBound(4)._rawValue, 2)
      XCTAssertEqual(numbers.lowerBound(5)._rawValue, 2)
      XCTAssertEqual(numbers.lowerBound(6)._rawValue, .end)
    }

    func testUpperBound() throws {
      let numbers: RedBlackTreeSet = [1, 3, 5]
      XCTAssertEqual(numbers.upperBound(0)._rawValue, 0)
      XCTAssertEqual(numbers.upperBound(1)._rawValue, 1)
      XCTAssertEqual(numbers.upperBound(2)._rawValue, 1)
      XCTAssertEqual(numbers.upperBound(3)._rawValue, 2)
      XCTAssertEqual(numbers.upperBound(4)._rawValue, 2)
      XCTAssertEqual(numbers.upperBound(5)._rawValue, .end)
      XCTAssertEqual(numbers.upperBound(6)._rawValue, .end)
    }

    func testFirstIndex() throws {
      var members: RedBlackTreeSet = [1, 3, 5, 7, 9]
      XCTAssertEqual(members.firstIndex(of: 3)?._rawValue, .init(1))
      XCTAssertEqual(members.firstIndex(of: 2), nil)
      XCTAssertEqual(members.firstIndex(where: { $0 > 3 })?._rawValue, .init(2))
      XCTAssertEqual(members.firstIndex(where: { $0 > 9 }), nil)
      XCTAssertEqual(members.sorted(), [1, 3, 5, 7, 9])
      XCTAssertEqual(members.removeFirst(), 1)
      XCTAssertEqual(members.removeFirst(), 3)
      XCTAssertEqual(members.removeFirst(), 5)
      XCTAssertEqual(members.removeFirst(), 7)
      XCTAssertEqual(members.removeFirst(), 9)
    }
  #endif

  func testContainsAllSatisfy() throws {
    let dict = [1, 2, 2, 2, 3, 3, 4, 5] as RedBlackTreeSet<Int>
    XCTAssertEqual(dict.first, 1)
    XCTAssertEqual(dict.last, 5)
    XCTAssertEqual(dict.first(where: { $0 > 4 }), 5)
    XCTAssertEqual(dict.firstIndex(where: { $0 > 4 }), dict.index(before: dict.endIndex))
    XCTAssertEqual(dict.first(where: { $0 > 5 }), nil)
    XCTAssertEqual(dict.firstIndex(where: { $0 > 5 }), nil)
    XCTAssertTrue(dict.contains(where: { $0 > 3 }))
    XCTAssertFalse(dict.contains(where: { $0 > 5 }))
    XCTAssertTrue(dict.allSatisfy({ $0 > 0 }))
    XCTAssertFalse(dict.allSatisfy({ $0 > 1 }))
  }

  func testEqualtable() throws {
    XCTAssertEqual(RedBlackTreeSet<Int>(), [])
    XCTAssertNotEqual(RedBlackTreeSet<Int>(), [1])
    XCTAssertEqual([1] as RedBlackTreeSet<Int>, [1])
    XCTAssertNotEqual([1, 2] as RedBlackTreeSet<Int>, [1])
    XCTAssertNotEqual([2] as RedBlackTreeSet<Int>, [1])
  }

  func testForEach() throws {
    let dict = [1, 2, 2, 3] as RedBlackTreeSet<Int>
    var d: [Int] = []
    dict.forEach { v in
      d.append(v)
    }
    XCTAssertEqual(d, [1, 2, 3])
  }

  func testIndexRange() throws {
    throw XCTSkip()
    //    let s: RedBlackTreeSet<Int> = [3, 1, 2]
    //    let target = 2
    //    func f(_ range: Range<RedBlackTreeSet<Int>.Index>) {
    //      XCTAssertEqual(range.lowerBound, s.lowerBound(target))
    //      XCTAssertEqual(range.upperBound, s.upperBound(target))
    //    }
    //    f(s.lowerBound(target)..<s.upperBound(target))
  }

  #if DEBUG
    func testIndexAfter() throws {
      do {
        let s: RedBlackTreeSet<Int> = []
        XCTAssertEqual(s.startIndex._rawValue, .end)
      }
      do {
        let s: RedBlackTreeSet<Int> = [1]
        XCTAssertEqual(s.startIndex._rawValue, .node(0))
        XCTAssertEqual(s.index(after: s.startIndex)._rawValue, .end)
      }
    }
  #endif

  func testSubsequence() throws {
    var set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5]
    XCTAssertEqual(set[set.startIndex..<set.endIndex].map { $0 }, [1, 2, 3, 4, 5])
    XCTAssertEqual(set[set.lowerBound(2)..<set.lowerBound(4)].map { $0 }, [2, 3])
    let sub = set[2..<4]
    XCTAssertEqual(sub[set.lowerBound(2)], 2)
    XCTAssertEqual(sub[set.lowerBound(3)], 3)
    XCTAssertEqual(set.upperBound(3), sub.endIndex)
    XCTAssertEqual(set.lowerBound(4), sub.endIndex)
    XCTAssertEqual(sub.count, 2)
    XCTAssertEqual(sub.map { $0 }, [2, 3])
    #if COMPATIBLE_ATCODER_2025
      set.remove(contentsOf: 2..<4)
      XCTAssertEqual(set.map { $0 }, [1, 4, 5])
    #endif
  }

  func testSubsequence2() throws {
    var set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5]
    let sub = set.elements(in: 2...4)
    XCTAssertEqual(sub[set.lowerBound(2)], 2)
    XCTAssertEqual(sub[set.lowerBound(4)], 4)
    XCTAssertEqual(set.upperBound(4), sub.endIndex)
    XCTAssertEqual(set.lowerBound(5), sub.endIndex)
    XCTAssertEqual(sub.count, 3)
    XCTAssertEqual(sub.map { $0 }, [2, 3, 4])
    #if COMPATIBLE_ATCODER_2025
      set.remove(contentsOf: 2...4)
      XCTAssertEqual(set.map { $0 }, [1, 5])
    #endif
  }

  func testSubsequence3() throws {
    let set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5]
    XCTAssertEqual(set[1...5] + [], [1, 2, 3, 4, 5])
  }

  func testSubsequence4() throws {
    //    let set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5]
    //    let sub = set.elements(in: 1 ..< 3)
    throw XCTSkip("Fatal error: RedBlackTree index is out of range.")
    //    XCTAssertNotEqual(sub[set.startIndex ..< set.endIndex].map{ $0 }, [1, 2, 3, 4, 5])
  }

  func testSubsequence5() throws {
    let set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5]
    let sub = set.elements(in: 1..<3)
    XCTAssertEqual(sub[set.lowerBound(1)..<set.lowerBound(3)].map { $0 }, [1, 2])
    XCTAssertEqual(sub[sub.startIndex..<sub.endIndex].map { $0 }, [1, 2])
    XCTAssertEqual(sub[sub.startIndex..<sub.index(before: sub.endIndex)].map { $0 }, [1])
    XCTAssertEqual(sub.map { $0 }, [1, 2])
    XCTAssertEqual(set.elements(in: 1..<3).map { $0 }, [1, 2])
  }

  func testIndex0() throws {
    let set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5]
    var i = set.startIndex
    for _ in 0..<set.count {
      XCTAssertEqual(set.distance(from: i, to: set.index(after: i)), 1)
      i = set.index(after: i)
    }
    XCTAssertEqual(i, set.endIndex)
    for _ in 0..<set.count {
      XCTAssertEqual(set.distance(from: i, to: set.index(before: i)), -1)
      i = set.index(before: i)
    }
    XCTAssertEqual(i, set.startIndex)
    for _ in 0..<set.count {
      XCTAssertEqual(set.distance(from: set.index(after: i), to: i), -1)
      i = set.index(after: i)
    }
    XCTAssertEqual(i, set.endIndex)
    for _ in 0..<set.count {
      XCTAssertEqual(set.distance(from: set.index(before: i), to: i), 1)
      i = set.index(before: i)
    }
  }

  func testIndex00() throws {
    let set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5]
    do {
      var i = set.startIndex
      for j in 0..<set.count {
        XCTAssertEqual(set.distance(from: set.startIndex, to: i), j)
        i = set.index(after: i)
      }
      XCTAssertEqual(i, set.endIndex)
      for j in 0..<set.count {
        XCTAssertEqual(set.distance(from: set.endIndex, to: i), -j)
        i = set.index(before: i)
      }
      XCTAssertEqual(i, set.startIndex)
      for j in 0..<set.count {
        XCTAssertEqual(set.distance(from: i, to: set.startIndex), -j)
        set.formIndex(after: &i)
      }
      XCTAssertEqual(i, set.endIndex)
      for j in 0..<set.count {
        XCTAssertEqual(set.distance(from: i, to: set.endIndex), j)
        set.formIndex(before: &i)
      }
      XCTAssertEqual(i, set.startIndex)
    }
    let sub = set.elements(in: 2..<5)
    do {
      var i = sub.startIndex
      for j in 0..<sub.count {
        XCTAssertEqual(sub.distance(from: sub.startIndex, to: i), j)
        i = sub.index(after: i)
      }
      XCTAssertEqual(i, sub.endIndex)
      for j in 0..<sub.count {
        XCTAssertEqual(sub.distance(from: sub.endIndex, to: i), -j)
        i = sub.index(before: i)
      }
      XCTAssertEqual(i, sub.startIndex)
      for j in 0..<sub.count {
        XCTAssertEqual(sub.distance(from: i, to: sub.startIndex), -j)
        sub.formIndex(after: &i)
      }
      XCTAssertEqual(i, sub.endIndex)
      for j in 0..<sub.count {
        XCTAssertEqual(sub.distance(from: i, to: sub.endIndex), j)
        sub.formIndex(before: &i)
      }
      XCTAssertEqual(i, sub.startIndex)
    }
  }

  func testIndex000() throws {
    let set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5]
    do {
      var i = set.startIndex
      for j in 0..<set.count {
        XCTAssertEqual(set.distance(from: set.startIndex, to: i), j)
        set.formIndex(after: &i)
      }
      XCTAssertEqual(i, set.endIndex)
      for j in 0..<set.count {
        XCTAssertEqual(set.distance(from: set.endIndex, to: i), -j)
        set.formIndex(before: &i)
      }
      XCTAssertEqual(i, set.startIndex)
      for j in 0..<set.count {
        XCTAssertEqual(set.distance(from: i, to: set.startIndex), -j)
        set.formIndex(after: &i)
      }
      XCTAssertEqual(i, set.endIndex)
      for j in 0..<set.count {
        XCTAssertEqual(set.distance(from: i, to: set.endIndex), j)
        set.formIndex(before: &i)
      }
      XCTAssertEqual(i, set.startIndex)
    }
    let sub = set.elements(in: 2..<5)
    do {
      var i = sub.startIndex
      for j in 0..<sub.count {
        XCTAssertEqual(sub.distance(from: sub.startIndex, to: i), j)
        sub.formIndex(after: &i)
      }
      XCTAssertEqual(i, sub.endIndex)
      for j in 0..<sub.count {
        XCTAssertEqual(set.distance(from: sub.endIndex, to: i), -j)
        set.formIndex(before: &i)
      }
      XCTAssertEqual(i, sub.startIndex)
      for j in 0..<sub.count {
        XCTAssertEqual(sub.distance(from: i, to: sub.startIndex), -j)
        set.formIndex(after: &i)
      }
      XCTAssertEqual(i, sub.endIndex)
      for j in 0..<sub.count {
        XCTAssertEqual(sub.distance(from: i, to: sub.endIndex), j)
        set.formIndex(before: &i)
      }
      XCTAssertEqual(i, sub.startIndex)
    }
  }

  func testIndex100() throws {
    let set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5, 6]
    XCTAssertEqual(set.index(set.startIndex, offsetBy: 6), set.endIndex)
    XCTAssertEqual(set.index(set.endIndex, offsetBy: -6), set.startIndex)
    let sub = set.elements(in: 2..<5)
    XCTAssertEqual(sub.map { $0 }, [2, 3, 4])
    XCTAssertEqual(sub.index(sub.startIndex, offsetBy: 3), sub.endIndex)
    XCTAssertEqual(sub.index(sub.endIndex, offsetBy: -3), sub.startIndex)
  }

  func testIndex10() throws {
    let set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5, 6]
    XCTAssertNotNil(set.index(set.startIndex, offsetBy: 6, limitedBy: set.endIndex))
    XCTAssertNil(set.index(set.startIndex, offsetBy: 7, limitedBy: set.endIndex))
    XCTAssertNotNil(set.index(set.endIndex, offsetBy: -6, limitedBy: set.startIndex))
    XCTAssertNil(set.index(set.endIndex, offsetBy: -7, limitedBy: set.startIndex))
    let sub = set.elements(in: 2..<5)
    XCTAssertEqual(sub.map { $0 }, [2, 3, 4])
    XCTAssertNotNil(sub.index(sub.startIndex, offsetBy: 3, limitedBy: sub.endIndex))
    XCTAssertNil(sub.index(sub.startIndex, offsetBy: 4, limitedBy: sub.endIndex))
    XCTAssertNotNil(sub.index(sub.endIndex, offsetBy: -3, limitedBy: sub.startIndex))
    XCTAssertNil(sub.index(sub.endIndex, offsetBy: -4, limitedBy: sub.startIndex))
  }

  func testIndex11() throws {
    let set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5, 6]
    var i = set.startIndex
    XCTAssertTrue(set.formIndex(&i, offsetBy: 6, limitedBy: set.endIndex))
    i = set.startIndex
    XCTAssertFalse(set.formIndex(&i, offsetBy: 7, limitedBy: set.endIndex))
    i = set.endIndex
    XCTAssertTrue(set.formIndex(&i, offsetBy: -6, limitedBy: set.startIndex))
    i = set.endIndex
    XCTAssertFalse(set.formIndex(&i, offsetBy: -7, limitedBy: set.startIndex))
    let sub = set.elements(in: 2..<5)
    XCTAssertEqual(sub.map { $0 }, [2, 3, 4])
    i = sub.startIndex
    XCTAssertTrue(sub.formIndex(&i, offsetBy: 3, limitedBy: sub.endIndex))
    i = sub.startIndex
    XCTAssertFalse(sub.formIndex(&i, offsetBy: 4, limitedBy: sub.endIndex))
    i = sub.endIndex
    XCTAssertTrue(sub.formIndex(&i, offsetBy: -3, limitedBy: sub.startIndex))
    i = sub.endIndex
    XCTAssertFalse(sub.formIndex(&i, offsetBy: -4, limitedBy: sub.startIndex))
  }

  func testIndex12() throws {
    let set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5, 6]
    var i = set.startIndex
    set.formIndex(&i, offsetBy: 6)
    XCTAssertEqual(i, set.endIndex)
    i = set.endIndex
    set.formIndex(&i, offsetBy: -6)
    XCTAssertEqual(i, set.startIndex)
    let sub = set.elements(in: 2..<5)
    XCTAssertEqual(sub.map { $0 }, [2, 3, 4])
    i = sub.startIndex
    sub.formIndex(&i, offsetBy: 3)
    XCTAssertEqual(i, sub.endIndex)
    i = sub.endIndex
    sub.formIndex(&i, offsetBy: -3)
    XCTAssertEqual(i, sub.startIndex)
  }

  func testIndex1() throws {
    let set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 6, 7]
    let l2 = set.lowerBound(2)
    let u2 = set.upperBound(4)
    XCTAssertEqual(set[l2..<u2].map { $0 }, [2, 3, 4])
    XCTAssertEqual(set[l2...].map { $0 }, [2, 3, 4, 6, 7])
    XCTAssertEqual(set[u2...].map { $0 }, [6, 7])
    XCTAssertEqual(set[..<u2].map { $0 }, [1, 2, 3, 4])
    XCTAssertEqual(set[...u2].map { $0 }, [1, 2, 3, 4, 6])
    XCTAssertEqual(set[..<set.endIndex].map { $0 }, [1, 2, 3, 4, 6, 7])
  }

  func testSorted() throws {
    let set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5]
    XCTAssertEqual(set.sorted(), [1, 2, 3, 4, 5])
  }

  #if DEBUG
    func testSubSeqSubscript() throws {
      let set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5]
      XCTAssertEqual(set.elements(in: 2..<4)[set.startIndex + 2], 3)
      var a = 0
      set.elements(in: 2...4).forEach {
        a += $0
      }
      XCTAssertEqual(a, 2 + 3 + 4)
    }
  #endif

  func testIndexValidation() throws {
    let set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5]
    XCTAssertTrue(set.isValid(index: set.startIndex))
    XCTAssertFalse(set.isValid(index: set.endIndex))  // 仕様変更。subscriptやremoveにつかえないので
    typealias Index = RedBlackTreeSet<Int>.Index
    #if DEBUG
      XCTAssertEqual(Index.unsafe(tree: set.__tree_, rawValue: -1)._rawValue, -1)
      // UnsafeTreeでは、範囲外のインデックスを作成できない
      XCTAssertEqual(Index.unsafe(tree: set.__tree_, rawValue: 5)._rawValue, -2)
      XCTAssertFalse(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: .nullptr)))
      XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: 0)))
      XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: 1)))
      XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: 2)))
      XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: 3)))
      XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: 4)))
      XCTAssertFalse(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: 5)))
    #endif
  }

  func testIndexValidation2() throws {
    let _set: RedBlackTreeSet<Int> = [1, 2, 3, 4, 5, 6, 7]
    let set = _set.elements(in: 2..<6)
    XCTAssertTrue(set.isValid(index: set.startIndex))
    XCTAssertTrue(set.isValid(index: set.endIndex))
    typealias Index = RedBlackTreeSet<Int>.Index
    #if DEBUG
      XCTAssertEqual(Index.unsafe(tree: set.__tree_, rawValue: -1)._rawValue, -1)
      XCTAssertEqual(Index.unsafe(tree: set.__tree_, rawValue: 5)._rawValue, 5)

      XCTAssertFalse(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: .nullptr)))
      XCTAssertFalse(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: 0)))
      XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: 1)))
      XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: 2)))
      XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: 3)))
      XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: 4)))
      XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: 5)))
      XCTAssertFalse(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: 6)))
      XCTAssertFalse(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: 7)))
    #endif
  }

  func testPopFirst() {
    do {
      var d = RedBlackTreeSet<Int>()
      XCTAssertNil(d.popFirst())
    }
    do {
      var d: RedBlackTreeSet<Int> = [1]
      XCTAssertEqual(d.popFirst(), 1)
    }
  }

  func testEqual1() throws {
    do {
      let a = RedBlackTreeSet<Int>()
      let b = RedBlackTreeSet<Int>()
      XCTAssertEqual(a, b)
      XCTAssertEqual(b, a)
    }
    do {
      let a = RedBlackTreeSet<Int>()
      let b = RedBlackTreeSet<Int>([0])
      XCTAssertNotEqual(a, b)
      XCTAssertNotEqual(b, a)
    }
    do {
      let a = RedBlackTreeSet<Int>([0])
      let b = RedBlackTreeSet<Int>([0])
      XCTAssertEqual(a, b)
      XCTAssertEqual(b, a)
    }
    do {
      let a = RedBlackTreeSet<Int>([0, 1])
      let b = RedBlackTreeSet<Int>([0])
      XCTAssertNotEqual(a, b)
      XCTAssertNotEqual(b, a)
    }
    do {
      let a = RedBlackTreeSet<Int>([0, 1])
      let b = RedBlackTreeSet<Int>([0, 1])
      XCTAssertEqual(a, b)
      XCTAssertEqual(b, a)
    }
  }

  func testEqual2() throws {
    let aa = RedBlackTreeSet<Int>([0, 1, 2, 3, 4, 5])
    let bb = RedBlackTreeSet<Int>([3, 4, 5, 6, 7, 8])
    do {
      let a = aa[0..<0]
      let b = bb[3..<3]
      XCTAssertEqual(a, b)
      XCTAssertEqual(b, a)
    }
    do {
      let a = aa[3..<6]
      let b = bb[3..<6]
      XCTAssertEqual(a, b)
      XCTAssertEqual(b, a)
    }
    do {
      let a = aa[2..<6]
      let b = bb[3..<6]
      XCTAssertNotEqual(a, b)
      XCTAssertNotEqual(b, a)
    }
    do {
      let a = aa[3..<6]
      let b = bb[3..<7]
      XCTAssertNotEqual(a, b)
      XCTAssertNotEqual(b, a)
    }
  }

  func testCompare1() throws {
    do {
      let a = RedBlackTreeSet<Int>()
      let b = RedBlackTreeSet<Int>()
      XCTAssertFalse(a < b)
      XCTAssertFalse(b < a)
    }
    do {
      let a = RedBlackTreeSet<Int>()
      let b = RedBlackTreeSet<Int>([0])
      XCTAssertTrue(a < b)
      XCTAssertFalse(b < a)
    }
    do {
      let a = RedBlackTreeSet<Int>([0])
      let b = RedBlackTreeSet<Int>([0])
      XCTAssertFalse(a < b)
      XCTAssertFalse(b < a)
    }
    do {
      let a = RedBlackTreeSet<Int>([0])
      let b = RedBlackTreeSet<Int>([1])
      XCTAssertTrue(a < b)
      XCTAssertFalse(b < a)
    }
    do {
      let a = RedBlackTreeSet<Int>([0, 1])
      let b = RedBlackTreeSet<Int>([0])
      XCTAssertFalse(a < b)
      XCTAssertTrue(b < a)
    }
    do {
      let a = RedBlackTreeSet<Int>([0, 1])
      let b = RedBlackTreeSet<Int>([0, 1])
      XCTAssertFalse(a < b)
      XCTAssertFalse(b < a)
    }
    do {
      let a = RedBlackTreeSet<Int>([0, 1, 2])
      let b = RedBlackTreeSet<Int>([0, 1, 3])
      XCTAssertTrue(a < b)
      XCTAssertFalse(b < a)
    }
  }

  func testCompare2() throws {
    let aa = RedBlackTreeSet<Int>([0, 1, 2, 3, 4, 5])
    let bb = RedBlackTreeSet<Int>([3, 4, 5, 6, 7, 8])
    do {
      let a = aa[0..<0]
      let b = bb[3..<3]
      XCTAssertFalse(a < b)
      XCTAssertFalse(b < a)
    }
    do {
      let a = aa[3..<6]
      let b = bb[3..<6]
      XCTAssertFalse(a < b)
      XCTAssertFalse(b < a)
    }
    do {
      let a = aa[2..<6]
      let b = bb[3..<6]
      XCTAssertTrue(a < b)
      XCTAssertFalse(b < a)
    }
    do {
      let a = aa[3..<6]
      let b = bb[3..<7]
      XCTAssertTrue(a < b)
      XCTAssertFalse(b < a)
    }
  }

  func testSwap() {

    var a = RedBlackTreeSet<Int>([0])
    var b = RedBlackTreeSet<Int>([0, 1])
    swap(&a, &b)
    XCTAssertEqual(a, [0, 1])
    XCTAssertEqual(b, [0])
  }

  func testLeftUnsafeSmoke() {
    typealias Set = RedBlackTreeSet<Int>
    #if DEBUG
      let repeatCount = 1
    #else
      let repeatCount = 100
    #endif
    for _ in 0..<repeatCount {
      let count = Int.random(in: 0..<1_000_000)
      let a = Set(0..<count)
      do {
        var p: Set.Index? = a.startIndex
        while p != a.endIndex {
          p = p?.next
        }
      }
      do {
        var p: Set.Index? = a.endIndex
        while p != a.startIndex {
          p = p?.previous
        }
      }
      do {
        _ = a.equalRange(Int.random(in: 0..<count))
      }
      do {
        _ = a.min()
      }
    }
  }

  func testIsValidRangeSmoke() throws {
    let a = RedBlackTreeSet<Int>(naive: [0, 1, 2, 3, 4, 5])
    XCTAssertTrue(a.isValid(a.lowerBound(2)..<a.upperBound(4)))
  }

  func testSortedReversed() throws {
    let source = [0, 1, 2, 3, 4, 5]
    let a = RedBlackTreeSet<Int>(naive: source)
    XCTAssertEqual(a.sorted() + [], source)
    XCTAssertEqual(a.reversed() + [], source.reversed())
  }

  func testForEach_enumeration() throws {
    let source = [0, 1, 2, 3, 4, 5]
    let a = RedBlackTreeSet<Int>(naive: source)
    var p: RedBlackTreeSet<Int>.Index? = a.startIndex
    a.forEach { i, v in
      XCTAssertEqual(i, p)
      XCTAssertEqual(a[p!], v)
      p = p?.next
    }
  }

  func testInitNaive_with_Sequence() throws {
    let source = [0, 1, 2, 3, 4, 5]
    let a = RedBlackTreeSet<Int>(naive: AnySequence(source))
    XCTAssertEqual(a.sorted() + [], source)
  }

  func testInsertEmpty() throws {
    var a = RedBlackTreeSet<Int>()
    let b = RedBlackTreeSet<Int>()
    a.merge(b)
    XCTAssertTrue(a.isEmpty)
  }

  //  #if DEBUG
  #if !USE_UNSAFE_TREE
    func testMemoryLayout() throws {
      XCTAssertEqual(MemoryLayout<RedBlackTreeSet<Int>.Tree.Node>.stride, 40)
      XCTAssertEqual(40 * UInt128(Int.max) / 1024 / 1024 / 1024 / 1024 / 1024, 327679)
    }
  #endif
  //  #endif

  #if !COMPATIBLE_ATCODER_2025
    func testFilter() throws {
      let s = RedBlackTreeSet<Int>(0..<5)
      XCTAssertEqual(s.filter { _ in true }, s)
    }
  #endif
}
