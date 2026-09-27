import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

#if !COMPATIBLE_ATCODER_2025
  extension MultisetTests {

    func testUpdateReplacesMemberAndReturnsOldMember() {
      let oldMember = A(x: 1, label: "old")
      let newMember = A(x: 1, label: "new")
      var set = RedBlackTreeMultiSet([oldMember])
      let index = set.startIndex

      let replacedMember = set.update(newMember, at: index)

      XCTAssertTrue(replacedMember === oldMember)
      XCTAssertTrue(set[index] === newMember)
    }

    func testUpdateReplacesOnlyMemberAtSpecifiedDuplicatePosition() {
      let members = [
        A(x: 1, label: "first"),
        A(x: 1, label: "middle"),
        A(x: 1, label: "last"),
      ]
      var set = RedBlackTreeMultiSet(members)
      let index = set.index(after: set.startIndex)
      let oldMember = set[index]
      let newMember = A(x: 1, label: "new")
      let before = Array(set)

      let replacedMember = set.update(newMember, at: index)
      let after = Array(set)

      XCTAssertTrue(replacedMember === oldMember)
      XCTAssertTrue(after[0] === before[0])
      XCTAssertTrue(after[1] === newMember)
      XCTAssertTrue(after[2] === before[2])
    }

    func testUpdatePreservesValueSemanticsAfterCopy() {
      let oldMember = A(x: 1, label: "old")
      let newMember = A(x: 1, label: "new")
      var set = RedBlackTreeMultiSet([oldMember])
      let index = set.startIndex
      let copy = set

      let replacedMember = set.update(newMember, at: index)

      XCTAssertTrue(replacedMember === oldMember)
      XCTAssertTrue(set[index] === newMember)
      XCTAssertTrue(copy[copy.startIndex] === oldMember)
    }
  }
#endif
