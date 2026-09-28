import XCTest

#if DEBUG
  @testable import RedBlackTreeCollections
#else
  import RedBlackTreeCollections
#endif

#if !COMPATIBLE_ATCODER_2025
  extension MultisetTests {

    func testInsertWithHint() {
      var set = RedBlackTreeMultiSet([1, 1, 3])

      let secondOne = set.index(after: set.startIndex)
      let duplicate = set.insert(1, hint: secondOne)
      XCTAssertEqual(set[duplicate], 1)
      XCTAssertEqual(Array(set), [1, 1, 1, 3])

      let goodHint = set.firstIndex(of: 3)!
      let insertedWithGoodHint = set.insert(2, hint: goodHint)
      XCTAssertEqual(set[insertedWithGoodHint], 2)

      let insertedWithBadHint = set.insert(4, hint: set.startIndex)
      XCTAssertEqual(set[insertedWithBadHint], 4)
      XCTAssertEqual(Array(set), [1, 1, 1, 2, 3, 4])
    }

    func testUpdateReplacesMemberAndReturnsOldMember() {
      let oldMember = A(x: 1, label: "old")
      let newMember = A(x: 1, label: "new")
      var set = RedBlackTreeMultiSet([oldMember])
      let index = set.startIndex

      let replacedMember = set.update(newMember, at: index)

      XCTAssertNotNil(replacedMember)
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

      XCTAssertNotNil(replacedMember)
      XCTAssertTrue(replacedMember === oldMember)
      XCTAssertTrue(after[0] === before[0])
      XCTAssertTrue(after[1] === newMember)
      XCTAssertTrue(after[2] === before[2])
    }

    func testUpdateAtEndIndexReturnsNilWithoutChangingSet() {
      let member = A(x: 1, label: "member")
      let newMember = A(x: 1, label: "new")
      var set = RedBlackTreeMultiSet([member])

      let replacedMember = set.update(newMember, at: set.endIndex)

      XCTAssertNil(replacedMember)
      XCTAssertTrue(set[set.startIndex] === member)
    }

    func testUpdateWithDifferentMemberReturnsNilWithoutChangingSet() {
      let member = A(x: 1, label: "member")
      let differentMember = A(x: 2, label: "different")
      var set = RedBlackTreeMultiSet([member])
      let index = set.startIndex

      let replacedMember = set.update(differentMember, at: index)

      XCTAssertNil(replacedMember)
      XCTAssertTrue(set[index] === member)
    }

    func testUpdatePreservesValueSemanticsAfterCopy() {
      let oldMember = A(x: 1, label: "old")
      let newMember = A(x: 1, label: "new")
      var set = RedBlackTreeMultiSet([oldMember])
      let index = set.startIndex
      let copy = set

      let replacedMember = set.update(newMember, at: index)

      XCTAssertNotNil(replacedMember)
      XCTAssertTrue(replacedMember === oldMember)
      XCTAssertTrue(set[index] === newMember)
      XCTAssertTrue(copy[copy.startIndex] === oldMember)
    }
  }
#endif
