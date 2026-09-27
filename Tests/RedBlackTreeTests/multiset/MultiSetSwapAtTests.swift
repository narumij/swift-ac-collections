import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

#if !COMPATIBLE_ATCODER_2025
  extension MultisetTests {

    func testSwapAtSwapsEqualMembers() {
      let firstMember = A(x: 1, label: "first")
      let lastMember = A(x: 1, label: "last")
      var set = RedBlackTreeMultiSet([firstMember, lastMember])
      let first = set.startIndex
      let last = set.index(after: first)

      XCTAssertTrue(set.swapAt(first, last))

      XCTAssertTrue(set[first] === lastMember)
      XCTAssertTrue(set[last] === firstMember)
    }

    func testSwapAtReturnsFalseForDifferentMembersWithoutChangingSet() {
      let firstMember = A(x: 1, label: "first")
      let lastMember = A(x: 2, label: "last")
      var set = RedBlackTreeMultiSet([firstMember, lastMember])
      let first = set.startIndex
      let last = set.index(after: first)

      XCTAssertFalse(set.swapAt(first, last))

      XCTAssertTrue(set[first] === firstMember)
      XCTAssertTrue(set[last] === lastMember)
    }

    func testSwapAtSameIndexSucceedsWithoutChangingSet() {
      let member = A(x: 1, label: "member")
      var set = RedBlackTreeMultiSet([member])
      let index = set.startIndex

      XCTAssertTrue(set.swapAt(index, index))

      XCTAssertTrue(set[index] === member)
    }

    func testSwapAtPreservesValueSemanticsAfterCopy() {
      let firstMember = A(x: 1, label: "first")
      let lastMember = A(x: 1, label: "last")
      var set = RedBlackTreeMultiSet([firstMember, lastMember])
      let first = set.startIndex
      let last = set.index(after: first)
      let copy = set

      XCTAssertTrue(set.swapAt(first, last))

      XCTAssertTrue(set[first] === lastMember)
      XCTAssertTrue(set[last] === firstMember)
      XCTAssertTrue(copy[copy.startIndex] === firstMember)
      XCTAssertTrue(copy[copy.index(after: copy.startIndex)] === lastMember)
    }
  }
#endif
