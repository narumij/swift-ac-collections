import XCTest

#if DEBUG
  @testable import RedBlackTreeModule
#else
  import RedBlackTreeModule
#endif

final class MultisetTests: RedBlackTreeTestCase {

  func testInitEmtpy() throws {
    let set = RedBlackTreeMultiSet<Int>()
    XCTAssertEqual(set.sorted(), [])
    XCTAssertEqual(set.count, 0)
    XCTAssertTrue(set.isEmpty)
    XCTAssertEqual(set.distance(from: set.startIndex, to: set.endIndex), 0)
    XCTAssertEqual(set.count(of: 0), 0)
  }

  func testRedBlackTreeCapacity() throws {
    var numbers: RedBlackTreeMultiSet<Int> = .init(minimumCapacity: 3)
    XCTAssertGreaterThanOrEqual(numbers.capacity, 3)
    numbers.reserveCapacity(4)
    XCTAssertGreaterThanOrEqual(numbers.capacity, 4)
  }

  func testInitNaive0() throws {
    let set = RedBlackTreeMultiSet<Int>(naive: 0..<0)
    XCTAssertEqual(set.elements, (0..<0) + [])
    XCTAssertEqual(set.count, 0)
    XCTAssertTrue(set.isEmpty)
    XCTAssertEqual(set.distance(from: set.startIndex, to: set.endIndex), 0)
  }

  func testInitRange() throws {
    let set = RedBlackTreeMultiSet<Int>(0..<10000)
    XCTAssertEqual(set.sorted(), (0..<10000) + [])
    XCTAssertEqual(set.count, 10000)
    XCTAssertFalse(set.isEmpty)
    XCTAssertEqual(set.distance(from: set.startIndex, to: set.endIndex), 10000)
  }

  func testInitCollection1() throws {
    let set = RedBlackTreeMultiSet<Int>(0..<10000)
    XCTAssertEqual(set.sorted(), (0..<10000) + [])
    XCTAssertEqual(set.count, 10000)
    XCTAssertFalse(set.isEmpty)
    XCTAssertEqual(set.distance(from: set.startIndex, to: set.endIndex), 10000)
  }

  func testInitCollection2() throws {
    let set = RedBlackTreeMultiSet<Int>([2, 3, 3, 0, 0, 1, 1, 1])
    XCTAssertEqual(set.sorted(), [0, 0, 1, 1, 1, 2, 3, 3])
    XCTAssertEqual(set.count, 8)
    XCTAssertFalse(set.isEmpty)
    XCTAssertEqual(set.distance(from: set.startIndex, to: set.endIndex), set.count)
  }

  func testInitCollection3() throws {
    let set = RedBlackTreeMultiSet<Int>(AnySequence([2, 3, 3, 0, 0, 1, 1, 1]))
    XCTAssertEqual(set.sorted(), [0, 0, 1, 1, 1, 2, 3, 3])
    XCTAssertEqual(set.count, 8)
    XCTAssertFalse(set.isEmpty)
    XCTAssertEqual(set.distance(from: set.startIndex, to: set.endIndex), set.count)
  }

  func testInitCollection4() throws {
    let set = RedBlackTreeMultiSet<Int>(naive: [2, 3, 3, 0, 0, 1, 1, 1])
    XCTAssertEqual(set.sorted(), [0, 0, 1, 1, 1, 2, 3, 3])
    XCTAssertEqual(set.count, 8)
    XCTAssertFalse(set.isEmpty)
    XCTAssertEqual(set.distance(from: set.startIndex, to: set.endIndex), set.count)
  }

  func testExample3() throws {
    let b: RedBlackTreeMultiSet<Int> = [1, 2, 3]
    XCTAssertEqual(b.distance(from: b.startIndex, to: b.endIndex), b.count)
  }

  #if DEBUG
    func testSubscript() throws {
      let b: RedBlackTreeMultiSet<Int> = [1, 2, 3]
      XCTAssertEqual(b[b.startIndex], 1)
    }
  #endif

  func testSmoke() throws {
    let b: RedBlackTreeMultiSet<Int> = [1, 2, 3]
    print(b)
    debugPrint(b)
  }

  func testRemove() throws {
    var set = RedBlackTreeMultiSet<Int>([0, 1, 2, 3, 4])
    XCTAssertEqual(set.removeAll(0), 0)
    XCTAssertFalse(set.sorted().isEmpty)
    XCTAssertEqual(set.removeAll(1), 1)
    XCTAssertFalse(set.sorted().isEmpty)
    XCTAssertEqual(set.removeAll(2), 2)
    XCTAssertFalse(set.sorted().isEmpty)
    XCTAssertEqual(set.removeAll(3), 3)
    XCTAssertFalse(set.sorted().isEmpty)
    XCTAssertEqual(set.removeAll(4), 4)
    XCTAssertTrue(set.sorted().isEmpty)
    XCTAssertEqual(set.removeAll(0), nil)
    XCTAssertTrue(set.sorted().isEmpty)
    XCTAssertEqual(set.removeAll(1), nil)
    XCTAssertTrue(set.sorted().isEmpty)
    XCTAssertEqual(set.removeAll(2), nil)
    XCTAssertTrue(set.sorted().isEmpty)
    XCTAssertEqual(set.removeAll(3), nil)
    XCTAssertTrue(set.sorted().isEmpty)
    XCTAssertEqual(set.removeAll(4), nil)
    XCTAssertTrue(set.sorted().isEmpty)
  }

  #if DEBUG
    func testRemoveAt() throws {
      var set = RedBlackTreeMultiSet<Int>([0, 1, 2, 3, 4])
      XCTAssertEqual(set.___remove(at: set.__tree_.__begin_node_), 0)
      XCTAssertEqual(set.sorted(), [1, 2, 3, 4])
      XCTAssertEqual(set.___remove(at: set.__tree_.__begin_node_), 1)
      XCTAssertEqual(set.sorted(), [2, 3, 4])
      XCTAssertEqual(set.___remove(at: set.__tree_.__begin_node_), 2)
      XCTAssertEqual(set.sorted(), [3, 4])
      XCTAssertEqual(set.___remove(at: set.__tree_.__begin_node_), 3)
      XCTAssertEqual(set.sorted(), [4])
      XCTAssertEqual(set.___remove(at: set.__tree_.__begin_node_), 4)
      XCTAssertEqual(set.sorted(), [])
      XCTAssertEqual(set.___remove(at: set.__tree_.__begin_node_), nil)
    }
  #endif

  func testInsert() throws {
    var set = RedBlackTreeMultiSet<Int>([])
    XCTAssertEqual(set.insert(0).inserted, true)
    XCTAssertEqual(set.insert(1).inserted, true)
    XCTAssertEqual(set.insert(2).inserted, true)
    XCTAssertEqual(set.insert(3).inserted, true)
    XCTAssertEqual(set.insert(4).inserted, true)
    XCTAssertEqual(set.insert(0).inserted, true)
    XCTAssertEqual(set.insert(1).inserted, true)
    XCTAssertEqual(set.insert(2).inserted, true)
    XCTAssertEqual(set.insert(3).inserted, true)
    XCTAssertEqual(set.insert(4).inserted, true)
  }

  func testContains() throws {
    var set = RedBlackTreeMultiSet<Int>([0, 1, 2, 3, 4])
    XCTAssertEqual(set.count, 5)
    XCTAssertEqual(set.contains(-1), false)
    XCTAssertEqual(set.contains(0), true)
    XCTAssertEqual(set.contains(1), true)
    XCTAssertEqual(set.contains(2), true)
    XCTAssertEqual(set.contains(3), true)
    XCTAssertEqual(set.contains(4), true)
    XCTAssertEqual(set.contains(5), false)
    XCTAssertEqual(set.removeAll(1), 1)
    XCTAssertEqual(set.removeAll(3), 3)
    XCTAssertEqual(set.removeAll(1), nil)
    XCTAssertEqual(set.removeAll(3), nil)
    XCTAssertEqual(set.sorted(), [0, 2, 4])
    XCTAssertEqual(set.contains(-1), false)
    XCTAssertEqual(set.contains(0), true)
    XCTAssertEqual(set.contains(1), false)
    XCTAssertEqual(set.contains(2), true)
    XCTAssertEqual(set.contains(3), false)
    XCTAssertEqual(set.contains(4), true)
    XCTAssertEqual(set.contains(5), false)
    XCTAssertEqual(set.removeAll(2), 2)
    XCTAssertEqual(set.removeAll(1), nil)
    XCTAssertEqual(set.removeAll(2), nil)
    XCTAssertEqual(set.removeAll(3), nil)
    XCTAssertEqual(set.sorted(), [0, 4])
    XCTAssertEqual(set.contains(-1), false)
    XCTAssertEqual(set.contains(0), true)
    XCTAssertEqual(set.contains(1), false)
    XCTAssertEqual(set.contains(2), false)
    XCTAssertEqual(set.contains(3), false)
    XCTAssertEqual(set.contains(4), true)
    XCTAssertEqual(set.contains(5), false)
    XCTAssertEqual(set.removeAll(0), 0)
    XCTAssertEqual(set.removeAll(1), nil)
    XCTAssertEqual(set.removeAll(2), nil)
    XCTAssertEqual(set.removeAll(3), nil)
    XCTAssertEqual(set.removeAll(4), 4)
    XCTAssertEqual(set.contains(-1), false)
    XCTAssertEqual(set.contains(0), false)
    XCTAssertEqual(set.contains(1), false)
    XCTAssertEqual(set.contains(2), false)
    XCTAssertEqual(set.contains(3), false)
    XCTAssertEqual(set.contains(4), false)
    XCTAssertEqual(set.contains(5), false)
    XCTAssertEqual(set.sorted(), [])
  }

  func testLeftRight() throws {
    var set = RedBlackTreeMultiSet<Int>([0, 1, 2, 3, 4])
    XCTAssertEqual(set.count, 5)
    XCTAssertEqual(set.left(-1).index, 0)
    //      XCTAssertEqual(set.elements.count { $0 < -1 }, 0)
    XCTAssertEqual(set.left(0).index, 0)
    //      XCTAssertEqual(set.elements.count { $0 < 0 }, 0)
    XCTAssertEqual(set.left(1).index, 1)
    //      XCTAssertEqual(set.elements.count { $0 < 1 }, 1)
    XCTAssertEqual(set.left(2).index, 2)
    XCTAssertEqual(set.left(3).index, 3)
    XCTAssertEqual(set.left(4).index, 4)
    XCTAssertEqual(set.left(5).index, 5)
    XCTAssertEqual(set.left(6).index, 5)
    XCTAssertEqual(set.right(-1).index, 0)
    //      XCTAssertEqual(set.elements.count { $0 <= -1 }, 0)
    XCTAssertEqual(set.right(0).index, 1)
    //      XCTAssertEqual(set.elements.count { $0 <= 0 }, 1)
    XCTAssertEqual(set.right(1).index, 2)
    //      XCTAssertEqual(set.elements.count { $0 <= 1 }, 2)
    XCTAssertEqual(set.right(2).index, 3)
    XCTAssertEqual(set.right(3).index, 4)
    XCTAssertEqual(set.right(4).index, 5)
    XCTAssertEqual(set.right(5).index, 5)
    XCTAssertEqual(set.right(6).index, 5)
    XCTAssertEqual(set.removeAll(1), 1)
    XCTAssertEqual(set.removeAll(3), 3)
    XCTAssertEqual(set.removeAll(1), nil)
    XCTAssertEqual(set.removeAll(3), nil)
    XCTAssertEqual(set.sorted(), [0, 2, 4])
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
    XCTAssertEqual(set.removeAll(2), 2)
    XCTAssertEqual(set.removeAll(1), nil)
    XCTAssertEqual(set.removeAll(2), nil)
    XCTAssertEqual(set.removeAll(3), nil)
    XCTAssertEqual(set.sorted(), [0, 4])
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
    XCTAssertEqual(set.removeAll(0), 0)
    XCTAssertEqual(set.removeAll(1), nil)
    XCTAssertEqual(set.removeAll(2), nil)
    XCTAssertEqual(set.removeAll(3), nil)
    XCTAssertEqual(set.removeAll(4), 4)
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
    XCTAssertEqual(set.sorted(), [])
  }

  func testMinMax() throws {
    do {
      let set = RedBlackTreeMultiSet<Int>([5, 2, 3, 1, 0])
      XCTAssertEqual(set.max(), 5)
      XCTAssertEqual(set.min(), 0)
    }
    do {
      let set = RedBlackTreeMultiSet<Int>()
      XCTAssertEqual(set.max(), nil)
      XCTAssertEqual(set.min(), nil)
    }
  }

  func testSequence() throws {
    let set = RedBlackTreeMultiSet<Int>([5, 2, 3, 1, 0])
    XCTAssertEqual(set + [], [0, 1, 2, 3, 5])
  }

  func testArrayAccess1() throws {
    let set = RedBlackTreeMultiSet<Int>([0, 1, 2, 3, 4])
    XCTAssertEqual(set[set.index(set.startIndex, offsetBy: 0)], 0)
    XCTAssertEqual(set[set.index(set.startIndex, offsetBy: 1)], 1)
    XCTAssertEqual(set[set.index(set.startIndex, offsetBy: 2)], 2)
    XCTAssertEqual(set[set.index(set.startIndex, offsetBy: 3)], 3)
    XCTAssertEqual(set[set.index(set.startIndex, offsetBy: 4)], 4)
  }

  func testArrayAccess2() throws {
    let set = RedBlackTreeMultiSet<Int>([0, 1, 2, 3, 4])
    XCTAssertEqual(set[set.index(set.endIndex, offsetBy: -5)], 0)
    XCTAssertEqual(set[set.index(set.endIndex, offsetBy: -4)], 1)
    XCTAssertEqual(set[set.index(set.endIndex, offsetBy: -3)], 2)
    XCTAssertEqual(set[set.index(set.endIndex, offsetBy: -2)], 3)
    XCTAssertEqual(set[set.index(set.endIndex, offsetBy: -1)], 4)
  }

  #if !COMPATIBLE_ATCODER_2025
    func testArrayAccess3() throws {
      let set = RedBlackTreeMultiSet<Int>([0, 1, 2, 3, 4])
      XCTAssertEqual(set[unchecked: set.index(set.startIndex, offsetBy: 0)], 0)
      XCTAssertEqual(set[unchecked: set.index(set.startIndex, offsetBy: 1)], 1)
      XCTAssertEqual(set[unchecked: set.index(set.startIndex, offsetBy: 2)], 2)
      XCTAssertEqual(set[unchecked: set.index(set.startIndex, offsetBy: 3)], 3)
      XCTAssertEqual(set[unchecked: set.index(set.startIndex, offsetBy: 4)], 4)
    }

    func testArrayAccess4() throws {
      let set = RedBlackTreeMultiSet<Int>([0, 1, 2, 3, 4])
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
    XCTAssertEqual(set.index(set.startIndex, offsetBy: 5, limitedBy: set.endIndex), set.endIndex)
    XCTAssertEqual(set.index(set.startIndex, offsetBy: 6, limitedBy: set.endIndex), nil)
    XCTAssertEqual(set.index(set.endIndex, offsetBy: 6, limitedBy: set.endIndex), nil)
    //      XCTAssertEqual(set.index(set.endIndex, offsetBy: -6, limitedBy: set.startIndex), nil)
  }

  func testIndexLimit2() throws {
    let set = RedBlackTreeMultiSet<Int>([0, 1, 2, 3, 4])
    XCTAssertNotEqual(
      set.index(set.startIndex, offsetBy: 4, limitedBy: set.index(set.startIndex, offsetBy: 4)),
      nil)
    XCTAssertEqual(
      set.index(set.startIndex, offsetBy: 5, limitedBy: set.index(set.startIndex, offsetBy: 4)),
      nil)
    XCTAssertEqual(set.index(set.startIndex, offsetBy: 5, limitedBy: set.endIndex), set.endIndex)
    XCTAssertEqual(set.index(set.startIndex, offsetBy: 6, limitedBy: set.endIndex), nil)
    XCTAssertEqual(set.index(set.endIndex, offsetBy: 6, limitedBy: set.endIndex), nil)
  }

  #if DEBUG
    func testIndexLimit3() throws {
      let set = RedBlackTreeMultiSet<Int>([0, 1, 2, 3, 4])
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
    var set = RedBlackTreeMultiSet<Int>()
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.removeAll(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.removeAll(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in set {
      set.removeAll(i)
      XCTAssertTrue(set.___tree_invariant())
    }
  }

  func testRandom2() throws {
    var set = RedBlackTreeMultiSet<Int>()
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    XCTAssertEqual(set + [], set[set.startIndex..<set.endIndex] + [])
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.removeAll(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    XCTAssertEqual(set + [], set[set.startIndex..<set.endIndex] + [])
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    XCTAssertEqual(set + [], set[set.startIndex..<set.endIndex] + [])
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.removeAll(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    XCTAssertEqual(set + [], set[set.startIndex..<set.endIndex] + [])
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    XCTAssertEqual(set + [], set[set.startIndex..<set.endIndex] + [])
    print("set.count", set.count)
    #if AC_COLLECTIONS_INTERNAL_CHECKS
      print("set._copyCount", set._copyCount)
    #endif
    for i in set[set.startIndex..<set.endIndex] {
      // erase multiなので、CoWなしだと、ポインタが破壊される
      set.removeAll(i)
      XCTAssertTrue(set.___tree_invariant())
    }
  }

  func testRandom3() throws {
    var set = RedBlackTreeMultiSet<Int>()
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.removeAll(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.removeAll(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert(i)
      XCTAssertTrue(set.___tree_invariant())
    }
  }

  func testRandom4() throws {
    var set = RedBlackTreeMultiSet<Int>()
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.removeAll(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.removeAll(i)
      XCTAssertTrue(set.___tree_invariant())
    }
    for i in ((0..<1000).compactMap { _ in (0..<500).randomElement() }) {
      set.insert(i)
      XCTAssertTrue(set.___tree_invariant())
    }
  }

  func testLiteral() throws {
    let set: RedBlackTreeMultiSet<Int> = [1, 1, 2, 2, 3, 3, 4, 4, 5, 5]
    XCTAssertEqual(set + [], [1, 1, 2, 2, 3, 3, 4, 4, 5, 5])
    XCTAssertEqual(set.count(of: 0), 0)
    XCTAssertEqual(set.count(of: 1), 2)
    XCTAssertEqual(set.count(of: 2), 2)
    XCTAssertEqual(set.count(of: 3), 2)
    XCTAssertEqual(set.count(of: 4), 2)
    XCTAssertEqual(set.count(of: 5), 2)
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

  //    func testRedBlackTreeSetUpdate() throws {
  //      let a = A(x: 3, label: "a")
  //      let b = A(x: 3, label: "b")
  //      var s: RedBlackTreeMultiSet<A> = [a]
  //      XCTAssertFalse(a === b)
  //      XCTAssertTrue(s.update(with: b) === a)
  //      XCTAssertTrue(s.update(with: a) === b)
  //    }

  func testRedBlackTreeSetInsert() throws {
    let a = A(x: 3, label: "a")
    let b = A(x: 3, label: "b")
    var s: RedBlackTreeMultiSet<A> = []
    XCTAssertFalse(a === b)
    do {
      let r = s.insert(a)
      XCTAssertEqual(r.inserted, true)
      XCTAssertTrue(r.memberAfterInsert === a)
    }
    do {
      // 重複を受け付けるので、setと挙動が異なる
      let r = s.insert(b)
      XCTAssertEqual(r.inserted, true)
      XCTAssertTrue(r.memberAfterInsert === b)
    }
  }

  #if DEBUG
    func testRedBlackTreeSetLowerBound() throws {
      let numbers: RedBlackTreeMultiSet = [1, 3, 5, 7, 9]
      XCTAssertEqual(numbers.lowerBound(4)._rawValue, 2)
    }

    func testRedBlackTreeSetUpperBound() throws {
      let numbers: RedBlackTreeMultiSet = [1, 3, 5, 7, 9]
      XCTAssertEqual(numbers.upperBound(7)._rawValue, 4)
    }
  #endif

  func testRedBlackTreeConveniences() throws {
    let numbers: RedBlackTreeMultiSet = [1, 3, 5, 7, 9]

    XCTAssertEqual(numbers.lessThan(4), 3)
    XCTAssertEqual(numbers.lessThanOrEqual(4), 3)
    XCTAssertEqual(numbers.lessThan(5), 3)
    XCTAssertEqual(numbers.lessThanOrEqual(5), 5)

    XCTAssertEqual(numbers.greaterThan(6), 7)
    XCTAssertEqual(numbers.greaterThanOrEqual(6), 7)
    XCTAssertEqual(numbers.greaterThan(5), 7)
    XCTAssertEqual(numbers.greaterThanOrEqual(5), 5)
  }

  #if DEBUG
    func testRedBlackTreeSetFirstIndex() throws {
      var members: RedBlackTreeMultiSet = [1, 3, 5, 7, 9]
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

  func testEqualtable() throws {
    XCTAssertEqual(RedBlackTreeMultiSet<Int>(), [])
    XCTAssertNotEqual(RedBlackTreeMultiSet<Int>(), [1])
    XCTAssertEqual([1] as RedBlackTreeMultiSet<Int>, [1])
    XCTAssertNotEqual([1, 1] as RedBlackTreeMultiSet<Int>, [1])
    XCTAssertNotEqual([1, 2] as RedBlackTreeMultiSet<Int>, [1, 1])
  }

  func testContainsAllSatisfy() throws {
    let dict = [1, 2, 2, 2, 3, 3, 4, 5] as RedBlackTreeMultiSet<Int>
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

  func testContains2() throws {
    let multiset: RedBlackTreeMultiSet<Int> = [1, 1, 2, 2, 2, 3, 3]
    XCTAssertFalse(multiset.contains(0))
    XCTAssertTrue(multiset.contains(1))
    XCTAssertTrue(multiset.contains(2))
    XCTAssertTrue(multiset.contains(3))
    XCTAssertFalse(multiset.contains(4))
  }

  func testForEach() throws {
    let dict = [1, 2, 2, 3] as RedBlackTreeMultiSet<Int>
    var d: [Int] = []
    dict.forEach { v in
      d.append(v)
    }
    XCTAssertEqual(d, [1, 2, 2, 3])
  }

  func testCount() throws {
    let b: RedBlackTreeMultiSet<Int> = [1, 1, 2, 2, 2, 3]
    XCTAssertEqual(b.count, 6)
    XCTAssertEqual(b.count(of: 1), 2)
    XCTAssertEqual(b.count(of: 2), 3)
    XCTAssertEqual(b.count(of: 3), 1)
  }

  func testSubsequence() throws {
    var set: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4, 5]
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
    var set: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4, 5]
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
    let set: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4, 5]
    XCTAssertEqual(set[1...5] + [], [1, 2, 3, 4, 5])
  }

  func testSubsequence4() throws {
    //    let set: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4, 5]
    //    let sub = set[1 ..< 3]
    throw XCTSkip("Fatal error: RedBlackTree index is out of range.")
    //    XCTAssertNotEqual(sub[set.startIndex ..< set.endIndex].map{ $0 }, [1, 2, 3, 4, 5])
  }

  func testSubsequence5() throws {
    let set: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4, 5]
    let sub = set.elements(in: 1..<3)
    XCTAssertEqual(sub[set.lowerBound(1)..<set.lowerBound(3)].map { $0 }, [1, 2])
    XCTAssertEqual(sub[sub.startIndex..<sub.endIndex].map { $0 }, [1, 2])
    XCTAssertEqual(sub[sub.startIndex..<sub.index(before: sub.endIndex)].map { $0 }, [1])
    XCTAssertEqual(sub.map { $0 }, [1, 2])
    XCTAssertEqual(set.elements(in: 1..<3).map { $0 }, [1, 2])
  }

  func testSubsequence6() throws {
    let set: RedBlackTreeMultiSet<Int> = [1, 1, 2, 2, 2, 3, 4]
    let sub = set.elements(in: 2..<3)
    XCTAssertEqual(sub.map { $0 }, [2, 2, 2])
    XCTAssertEqual(sub[set.lowerBound(2)..<set.lowerBound(3)].map { $0 }, [2, 2, 2])
    XCTAssertEqual(sub[sub.startIndex..<sub.endIndex].map { $0 }, [2, 2, 2])
    XCTAssertEqual(sub[sub.startIndex..<sub.index(before: sub.endIndex)].map { $0 }, [2, 2])
    XCTAssertEqual(set.elements(in: 2..<3).map { $0 }, [2, 2, 2])
  }

  func testSubsequence7() throws {
    let set: RedBlackTreeMultiSet<Int> = [1, 1, 2, 2, 2, 3, 4]
    let sub = set.elements(in: 2...2)
    XCTAssertEqual(sub.map { $0 }, [2, 2, 2])
    XCTAssertEqual(sub[set.lowerBound(2)..<set.upperBound(2)].map { $0 }, [2, 2, 2])
    XCTAssertEqual(sub[sub.startIndex..<sub.endIndex].map { $0 }, [2, 2, 2])
    XCTAssertEqual(sub[sub.startIndex..<sub.index(before: sub.endIndex)].map { $0 }, [2, 2])
    XCTAssertEqual(set.elements(in: 2..<3).map { $0 }, [2, 2, 2])
  }

  #if !SKIP_MULTISET_INDEX_BUG
    func testIndex0() throws {
      let set: RedBlackTreeMultiSet<Int> = [1, 1, 2, 2, 2, 3, 4]
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
  #endif

  #if !SKIP_MULTISET_INDEX_BUG
    func testIndex00() throws {
      let set: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4, 5]
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
  #endif

  func testIndex000() throws {
    let set: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4, 5]
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

  func testIndex1() throws {
    let set: RedBlackTreeMultiSet<Int> = [1, 1, 2, 2, 2, 3, 4]
    let l2 = set.lowerBound(2)
    let u2 = set.upperBound(2)
    XCTAssertEqual(set[l2..<u2].map { $0 }, [2, 2, 2])
    XCTAssertEqual(set[l2...].map { $0 }, [2, 2, 2, 3, 4])
    XCTAssertEqual(set[u2...].map { $0 }, [3, 4])
    XCTAssertEqual(set[..<u2].map { $0 }, [1, 1, 2, 2, 2])
    XCTAssertEqual(set[...u2].map { $0 }, [1, 1, 2, 2, 2, 3])
    XCTAssertEqual(set[..<set.endIndex].map { $0 }, [1, 1, 2, 2, 2, 3, 4])
  }

  func testIndex2() throws {
    let set: RedBlackTreeMultiSet<Int> = [1, 1, 2, 2, 2, 3, 4]
    let sub = set[set.index(after: set.lowerBound(2))..<set.upperBound(2)]
    XCTAssertEqual(sub.map { $0 }, [2, 2])
    XCTAssertTrue(set.index(after: set.lowerBound(2)) < set.upperBound(2))
  }

  func testIndex3() throws {
    let set: RedBlackTreeMultiSet<Int> = [1, 1, 2, 2, 2, 3, 4]
    let sub = set[set.index(after: set.lowerBound(2))...set.index(before: set.upperBound(2))]
    XCTAssertEqual(sub.map { $0 }, [2, 2])
    XCTAssertTrue(set.index(after: set.lowerBound(2)) < set.index(before: set.upperBound(2)))
  }

  #if !COMPATIBLE_ATCODER_2025
    func testIndex4() throws {
      let set: RedBlackTreeMultiSet<Int> = [1, 1, 2, 2, 2, 3, 4]
      let l2 = set.lowerBound(2)
      let u2 = set.upperBound(2)
      XCTAssertEqual(set[unchecked: l2..<u2].map { $0 }, [2, 2, 2])
      XCTAssertEqual(set[unchecked: l2...].map { $0 }, [2, 2, 2, 3, 4])
      XCTAssertEqual(set[unchecked: u2...].map { $0 }, [3, 4])
      XCTAssertEqual(set[unchecked: ..<u2].map { $0 }, [1, 1, 2, 2, 2])
      XCTAssertEqual(set[unchecked: ...u2].map { $0 }, [1, 1, 2, 2, 2, 3])
      XCTAssertEqual(set[unchecked: ..<set.endIndex].map { $0 }, [1, 1, 2, 2, 2, 3, 4])
    }

    func testIndex5() throws {
      let set: RedBlackTreeMultiSet<Int> = [1, 1, 2, 2, 2, 3, 4]
      let sub = set[unchecked: set.index(after: set.lowerBound(2))..<set.upperBound(2)]
      XCTAssertEqual(sub.map { $0 }, [2, 2])
      XCTAssertTrue(set.index(after: set.lowerBound(2)) < set.upperBound(2))
    }

    func testIndex6() throws {
      let set: RedBlackTreeMultiSet<Int> = [1, 1, 2, 2, 2, 3, 4]
      let sub = set[
        unchecked: set.index(after: set.lowerBound(2))...set.index(before: set.upperBound(2))]
      XCTAssertEqual(sub.map { $0 }, [2, 2])
      XCTAssertTrue(set.index(after: set.lowerBound(2)) < set.index(before: set.upperBound(2)))
    }
  #endif

  func testIndex100() throws {
    let set: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4, 5, 6]
    XCTAssertEqual(set.index(set.startIndex, offsetBy: 6), set.endIndex)
    XCTAssertEqual(set.index(set.endIndex, offsetBy: -6), set.startIndex)
    let sub = set.elements(in: 2..<5)
    XCTAssertEqual(sub.map { $0 }, [2, 3, 4])
    XCTAssertEqual(sub.index(sub.startIndex, offsetBy: 3), sub.endIndex)
    XCTAssertEqual(sub.index(sub.endIndex, offsetBy: -3), sub.startIndex)
  }

  func testIndex10() throws {
    let set: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4, 5, 6]
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
    let set: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4, 5, 6]
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
    let set: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4, 5, 6]
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

  func testSorted() throws {
    let set: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4, 5]
    XCTAssertEqual(set.sorted(), [1, 2, 3, 4, 5])
  }

  #if DEBUG
    func testSubSeqSubscript() throws {
      let set: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4, 5]
      XCTAssertEqual(set.elements(in: 2..<4)[set.startIndex + 2], 3)
      var a = 0
      set.elements(in: 2...4).forEach {
        a += $0
      }
      XCTAssertEqual(a, 2 + 3 + 4)
    }
  #endif

  func testIndexValidation() throws {
    let set: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4, 5]
    XCTAssertTrue(set.isValid(index: set.startIndex))
    XCTAssertFalse(set.isValid(index: set.endIndex))  // 仕様変更。subscriptやremoveにつかえないので
    typealias Index = RedBlackTreeMultiSet<Int>.Index
    #if DEBUG
      XCTAssertEqual(Index.unsafe(tree: set.__tree_, rawValue: -1)._rawValue, -1)
#if USE_FRESH_POOL_V1
      // UnsafeTreeでは、範囲外のインデックスを作成できない
      XCTAssertEqual(Index.unsafe(tree: set.__tree_, rawValue: 5)._rawValue, -2)
#endif
      XCTAssertFalse(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: .nullptr)))
      XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: 0)))
      XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: 1)))
      XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: 2)))
      XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: 3)))
      XCTAssertTrue(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: 4)))
#if USE_FRESH_POOL_V1
      XCTAssertFalse(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: 5)))
#endif
    #endif
  }

  func testIndexValidation2() throws {
    let _set: RedBlackTreeMultiSet<Int> = [1, 2, 3, 4, 5, 6, 7]
    let set = _set.elements(in: 2..<6)
    XCTAssertTrue(set.isValid(index: set.startIndex))
    XCTAssertTrue(set.isValid(index: set.endIndex))
    typealias Index = RedBlackTreeMultiSet<Int>.Index
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
#if USE_FRESH_POOL_V1
      XCTAssertFalse(set.isValid(index: .unsafe(tree: set.__tree_, rawValue: 7)))
#endif
    #endif
  }

  func testPopFirst() {
    do {
      var d = RedBlackTreeMultiSet<Int>()
      XCTAssertNil(d.popFirst())
    }
    do {
      var d: RedBlackTreeMultiSet<Int> = [1]
      XCTAssertEqual(d.popFirst(), 1)
    }
  }

  func testEqual1() throws {
    do {
      let a = RedBlackTreeMultiSet<Int>()
      let b = RedBlackTreeMultiSet<Int>()
      XCTAssertEqual(a, b)
      XCTAssertEqual(b, a)
    }
    do {
      let a = RedBlackTreeMultiSet<Int>()
      let b = RedBlackTreeMultiSet<Int>([0])
      XCTAssertNotEqual(a, b)
      XCTAssertNotEqual(b, a)
    }
    do {
      let a = RedBlackTreeMultiSet<Int>([0])
      let b = RedBlackTreeMultiSet<Int>([0])
      XCTAssertEqual(a, b)
      XCTAssertEqual(b, a)
    }
    do {
      let a = RedBlackTreeMultiSet<Int>([0, 1])
      let b = RedBlackTreeMultiSet<Int>([0])
      XCTAssertNotEqual(a, b)
      XCTAssertNotEqual(b, a)
    }
    do {
      let a = RedBlackTreeMultiSet<Int>([0, 1])
      let b = RedBlackTreeMultiSet<Int>([0, 1])
      XCTAssertEqual(a, b)
      XCTAssertEqual(b, a)
    }
  }

  func testEqual2() throws {
    let aa = RedBlackTreeMultiSet<Int>([0, 1, 2, 3, 4, 5])
    let bb = RedBlackTreeMultiSet<Int>([3, 4, 5, 6, 7, 8])
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
      let a = RedBlackTreeMultiSet<Int>()
      let b = RedBlackTreeMultiSet<Int>()
      XCTAssertFalse(a < b)
      XCTAssertFalse(b < a)
    }
    do {
      let a = RedBlackTreeMultiSet<Int>()
      let b = RedBlackTreeMultiSet<Int>([0])
      XCTAssertTrue(a < b)
      XCTAssertFalse(b < a)
    }
    do {
      let a = RedBlackTreeMultiSet<Int>([0])
      let b = RedBlackTreeMultiSet<Int>([0])
      XCTAssertFalse(a < b)
      XCTAssertFalse(b < a)
    }
    do {
      let a = RedBlackTreeMultiSet<Int>([0])
      let b = RedBlackTreeMultiSet<Int>([1])
      XCTAssertTrue(a < b)
      XCTAssertFalse(b < a)
    }
    do {
      let a = RedBlackTreeMultiSet<Int>([0, 1])
      let b = RedBlackTreeMultiSet<Int>([0])
      XCTAssertFalse(a < b)
      XCTAssertTrue(b < a)
    }
    do {
      let a = RedBlackTreeMultiSet<Int>([0, 1])
      let b = RedBlackTreeMultiSet<Int>([0, 1])
      XCTAssertFalse(a < b)
      XCTAssertFalse(b < a)
    }
    do {
      let a = RedBlackTreeMultiSet<Int>([0, 1, 2])
      let b = RedBlackTreeMultiSet<Int>([0, 1, 3])
      XCTAssertTrue(a < b)
      XCTAssertFalse(b < a)
    }
  }

  func testCompare2() throws {
    let aa = RedBlackTreeMultiSet<Int>([0, 1, 2, 3, 4, 5])
    let bb = RedBlackTreeMultiSet<Int>([3, 4, 5, 6, 7, 8])
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

  func testMeld() throws {
    do {
      var a = RedBlackTreeMultiSet<Int>([0, 1])
      let b = RedBlackTreeMultiSet<Int>([0, 1])
      a.meld(b)
      XCTAssertEqual(a + [], [0, 0, 1, 1])
    }
    do {
      var a = RedBlackTreeMultiSet<Int>([0, 1])
      let b = RedBlackTreeMultiSet<Int>([1, 2])
      a.meld(b)
      XCTAssertEqual(a + [], [0, 1, 1, 2])
    }
    do {
      var a = RedBlackTreeMultiSet<Int>([0, 1])
      let b = RedBlackTreeMultiSet<Int>([2, 3])
      a.meld(b)
      XCTAssertEqual(a + [], [0, 1, 2, 3])
    }
    do {
      var a = RedBlackTreeMultiSet<Int>([0, 1])
      let b = RedBlackTreeMultiSet<Int>([0, 1])
      a.meld(b)
      XCTAssertEqual(a + [], [0, 0, 1, 1])
    }
    do {
      var a = RedBlackTreeMultiSet<Int>([1, 2])
      let b = RedBlackTreeMultiSet<Int>([0, 1])
      a.meld(b)
      XCTAssertEqual(a + [], [0, 1, 1, 2])
    }
    do {
      var a = RedBlackTreeMultiSet<Int>([2, 3])
      let b = RedBlackTreeMultiSet<Int>([0, 1])
      a.meld(b)
      XCTAssertEqual(a + [], [0, 1, 2, 3])
    }
  }

  func testMelding() throws {
    do {
      let a = RedBlackTreeMultiSet<Int>([0, 1])
      let b = RedBlackTreeMultiSet<Int>([0, 1])
      XCTAssertEqual(a.melding(b) + [], [0, 0, 1, 1])
    }
    do {
      let a = RedBlackTreeMultiSet<Int>([0, 1])
      let b = RedBlackTreeMultiSet<Int>([1, 2])
      XCTAssertEqual(a.melding(b) + [], [0, 1, 1, 2])
    }
    do {
      let a = RedBlackTreeMultiSet<Int>([0, 1])
      let b = RedBlackTreeMultiSet<Int>([2, 3])
      XCTAssertEqual(a.melding(b) + [], [0, 1, 2, 3])
    }
    do {
      let a = RedBlackTreeMultiSet<Int>([0, 1])
      let b = RedBlackTreeMultiSet<Int>([0, 1])
      XCTAssertEqual(a.melding(b) + [], [0, 0, 1, 1])
    }
    do {
      let a = RedBlackTreeMultiSet<Int>([1, 2])
      let b = RedBlackTreeMultiSet<Int>([0, 1])
      XCTAssertEqual(a.melding(b) + [], [0, 1, 1, 2])
    }
    do {
      let a = RedBlackTreeMultiSet<Int>([2, 3])
      let b = RedBlackTreeMultiSet<Int>([0, 1])
      XCTAssertEqual(a.melding(b) + [], [0, 1, 2, 3])
    }
  }

  func testAdd() throws {
    do {
      let a = RedBlackTreeMultiSet<Int>([0, 1])
      let b = RedBlackTreeMultiSet<Int>([0, 1])
      //      a.meld(b)
      XCTAssertEqual((a + b) + [], [0, 0, 1, 1])
    }
    do {
      let a = RedBlackTreeMultiSet<Int>([0, 1])
      let b = RedBlackTreeMultiSet<Int>([1, 2])
      //      a.meld(b)
      XCTAssertEqual((a + b) + [], [0, 1, 1, 2])
    }
    do {
      let a = RedBlackTreeMultiSet<Int>([0, 1])
      let b = RedBlackTreeMultiSet<Int>([2, 3])
      //      a.meld(b)
      XCTAssertEqual((a + b) + [], [0, 1, 2, 3])
    }
    do {
      let a = RedBlackTreeMultiSet<Int>([0, 1])
      let b = RedBlackTreeMultiSet<Int>([0, 1])
      //      a.meld(b)
      XCTAssertEqual((a + b) + [], [0, 0, 1, 1])
    }
    do {
      let a = RedBlackTreeMultiSet<Int>([1, 2])
      let b = RedBlackTreeMultiSet<Int>([0, 1])
      //      a.meld(b)
      XCTAssertEqual((a + b) + [], [0, 1, 1, 2])
    }
    do {
      let a = RedBlackTreeMultiSet<Int>([2, 3])
      let b = RedBlackTreeMultiSet<Int>([0, 1])
      //      a.meld(b)
      XCTAssertEqual((a + b) + [], [0, 1, 2, 3])
    }
  }

  func testAddEqual() throws {
    do {
      var a = RedBlackTreeMultiSet<Int>([0, 1])
      let b = RedBlackTreeMultiSet<Int>([0, 1])
      a += b
      XCTAssertEqual(a + [], [0, 0, 1, 1])
    }
    do {
      var a = RedBlackTreeMultiSet<Int>([0, 1])
      let b = RedBlackTreeMultiSet<Int>([1, 2])
      a += b
      XCTAssertEqual(a + [], [0, 1, 1, 2])
    }
    do {
      var a = RedBlackTreeMultiSet<Int>([0, 1])
      let b = RedBlackTreeMultiSet<Int>([2, 3])
      a += b
      XCTAssertEqual(a + [], [0, 1, 2, 3])
    }
    do {
      var a = RedBlackTreeMultiSet<Int>([0, 1])
      let b = RedBlackTreeMultiSet<Int>([0, 1])
      a += b
      XCTAssertEqual(a + [], [0, 0, 1, 1])
    }
    do {
      var a = RedBlackTreeMultiSet<Int>([1, 2])
      let b = RedBlackTreeMultiSet<Int>([0, 1])
      a += b
      XCTAssertEqual(a + [], [0, 1, 1, 2])
    }
    do {
      var a = RedBlackTreeMultiSet<Int>([2, 3])
      let b = RedBlackTreeMultiSet<Int>([0, 1])
      a += b
      XCTAssertEqual(a + [], [0, 1, 2, 3])
    }
  }

  func testLeftUnsafeSmoke() {
    typealias MultiSet = RedBlackTreeMultiSet<Int>
    #if DEBUG
      let repeatCount = 1
    #else
      let repeatCount = 100
    #endif
    for _ in 0..<repeatCount {
      let count = Int.random(in: 0..<1_000_000)
      let a = MultiSet(0..<count)
      do {
        var p: MultiSet.Index? = a.startIndex
        while p != a.endIndex {
          p = p?.next
        }
      }
      do {
        var p: MultiSet.Index? = a.endIndex
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
    let a = RedBlackTreeMultiSet<Int>(naive: [0, 1, 2, 3, 4, 5])
    XCTAssertTrue(a.isValid(a.lowerBound(2)..<a.upperBound(4)))
  }

  func testSortedReversed() throws {
    let source = [0, 1, 2, 3, 4, 5]
    let a = RedBlackTreeMultiSet<Int>(naive: source)
    XCTAssertEqual(a.sorted() + [], source)
    XCTAssertEqual(a.reversed() + [], source.reversed())
  }

  func testForEach_enumeration() throws {
    let source = [0, 1, 2, 3, 4, 5]
    let a = RedBlackTreeMultiSet<Int>(naive: source)
    var p: RedBlackTreeMultiSet<Int>.Index? = a.startIndex
    a.forEach { i, v in
      XCTAssertEqual(i, p)
      XCTAssertEqual(a[p!], v)
      p = p?.next
    }
  }

  func testInitNaive_with_Sequence() throws {
    let source = [0, 1, 2, 3, 4, 5]
    let a = RedBlackTreeMultiSet<Int>(naive: AnySequence(source))
    XCTAssertEqual(a.sorted() + [], source)
  }

  #if !COMPATIBLE_ATCODER_2025
    func testFilter() throws {
      let s = RedBlackTreeMultiSet<Int>(0..<5)
      XCTAssertEqual(s.filter { _ in true }, s)
    }
  #endif
}
