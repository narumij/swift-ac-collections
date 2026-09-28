import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultiSetInsertionTests: RedBlackTreeTestCase {

  private final class Member: Comparable {
    let key: Int
    let label: String

    init(key: Int, label: String) {
      self.key = key
      self.label = label
    }

    static func == (lhs: Member, rhs: Member) -> Bool {
      lhs.key == rhs.key
    }

    static func < (lhs: Member, rhs: Member) -> Bool {
      lhs.key < rhs.key
    }
  }

  func test_insert_alwaysAddsDuplicateMembers() {
    var multiset = RedBlackTreeMultiSet([1, 2])

    let first = multiset.insert(2)
    let second = multiset.insert(2)

    XCTAssertTrue(first.inserted)
    XCTAssertTrue(second.inserted)
    XCTAssertEqual(first.memberAfterInsert, 2)
    XCTAssertEqual(Array(multiset), [1, 2, 2, 2])
    XCTAssertEqual(multiset.count(of: 2), 3)
  }

  func test_insert_preservesReferenceIdentityOfDuplicateMembers() {
    let first = Member(key: 3, label: "a")
    let second = Member(key: 3, label: "b")
    var multiset = RedBlackTreeMultiSet<Member>([])

    let firstResult = multiset.insert(first)
    let secondResult = multiset.insert(second)

    XCTAssertTrue(firstResult.inserted)
    XCTAssertTrue(firstResult.memberAfterInsert === first)
    XCTAssertTrue(secondResult.inserted)
    XCTAssertTrue(secondResult.memberAfterInsert === second)
  }

  func test_insertContentsOf_preservesMultiplicity() {
    var multiset = RedBlackTreeMultiSet([1, 2])

    multiset.insert(contentsOf: [2, 3, 3])

    XCTAssertEqual(Array(multiset), [1, 2, 2, 3, 3])
  }

  #if !COMPATIBLE_ATCODER_2025
    func test_insertWithHint_handlesDuplicateGoodAndBadHints() {
      var multiset = RedBlackTreeMultiSet([1, 1, 3])

      let duplicate = multiset.insert(1, hint: multiset.index(after: multiset.startIndex))
      XCTAssertEqual(multiset[duplicate], 1)

      let insertedWithGoodHint = multiset.insert(2, hint: multiset.firstIndex(of: 3)!)
      XCTAssertEqual(multiset[insertedWithGoodHint], 2)

      let insertedWithBadHint = multiset.insert(4, hint: multiset.startIndex)
      XCTAssertEqual(multiset[insertedWithBadHint], 4)
      XCTAssertEqual(Array(multiset), [1, 1, 1, 2, 3, 4])
    }

    func test_update_replacesOnlySpecifiedEquivalentMember() {
      let members = [
        Member(key: 1, label: "first"),
        Member(key: 1, label: "middle"),
        Member(key: 1, label: "last"),
      ]
      var multiset = RedBlackTreeMultiSet(members)
      let index = multiset.index(after: multiset.startIndex)
      let oldMember = multiset[index]
      let newMember = Member(key: 1, label: "new")

      let replacedMember = multiset.update(newMember, at: index)
      let result = Array(multiset)

      XCTAssertTrue(replacedMember === oldMember)
      XCTAssertTrue(result[0] === members[0])
      XCTAssertTrue(result[1] === newMember)
      XCTAssertTrue(result[2] === members[2])
    }

    func test_update_rejectsEndIndexAndNonEquivalentMember() {
      let member = Member(key: 1, label: "member")
      var multiset = RedBlackTreeMultiSet([member])

      XCTAssertNil(multiset.update(Member(key: 1, label: "new"), at: multiset.endIndex))
      XCTAssertNil(multiset.update(Member(key: 2, label: "different"), at: multiset.startIndex))
      XCTAssertTrue(multiset[multiset.startIndex] === member)
    }

    func test_update_preservesValueSemanticsAfterCopy() {
      let oldMember = Member(key: 1, label: "old")
      let newMember = Member(key: 1, label: "new")
      var multiset = RedBlackTreeMultiSet([oldMember])
      let copy = multiset

      let replacedMember = multiset.update(newMember, at: multiset.startIndex)

      XCTAssertTrue(replacedMember === oldMember)
      XCTAssertTrue(multiset[multiset.startIndex] === newMember)
      XCTAssertTrue(copy[copy.startIndex] === oldMember)
    }
  #endif
}
