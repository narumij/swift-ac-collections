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

  func test_insertContentsOf_fromSetAndMultiSet_preservesEachSourcesMultiplicity() {
    var fromSet = RedBlackTreeMultiSet<Int>([1, 2, 3, 4, 5, 6])
    fromSet.insert(contentsOf: RedBlackTreeSet([4, 5, 6]))
    XCTAssertEqual(Array(fromSet), [1, 2, 3, 4, 4, 5, 5, 6, 6])

    var fromMultiSet = RedBlackTreeMultiSet<Int>([1, 2, 3])
    fromMultiSet.insert(contentsOf: RedBlackTreeMultiSet([2, 2, 3, 3]))
    XCTAssertEqual(Array(fromMultiSet), [1, 2, 2, 2, 3, 3, 3])
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

    /// `insert(_:hint:)`は、std::multisetと同様にhintが示す位置そのものへ挿入する。
    /// hintが同値要素群の途中を指す場合、新しい要素は末尾ではなくその途中へ入る
    /// (通常の`insert(_:)`が常に同値要素群の末尾へ追加するのとは異なる)。
    /// 2026-10-03にユーザー確認: C++の`std::multiset::insert(hint, value)`に倣う。
    func test_insertWithHint_placesNewMemberAtHintPositionWithinEquivalentGroup() {
      let a = Member(key: 1, label: "a")
      let b = Member(key: 1, label: "b")
      let c = Member(key: 1, label: "c")
      var multiset = RedBlackTreeMultiSet<Member>([a, b, c])
      let hint = multiset.index(after: multiset.startIndex)  // bを指す

      let x = Member(key: 1, label: "X")
      multiset.insert(x, hint: hint)

      XCTAssertEqual(multiset.map(\.label), ["a", "X", "b", "c"])
    }

    /// `startIndex`・`endIndex`(空の場合は両者が一致)はいずれも有効なhintで、
    /// std::multisetと同様にその位置へ挿入する。
    func test_insertWithHint_acceptsStartAndEndIndexBoundaries() {
      var empty = RedBlackTreeMultiSet<Int>()
      let intoEmpty = empty.insert(10, hint: empty.endIndex)
      XCTAssertEqual(empty[intoEmpty], 10)
      XCTAssertEqual(Array(empty), [10])

      var multiset = RedBlackTreeMultiSet([10, 20])
      let atEnd = multiset.insert(30, hint: multiset.endIndex)
      XCTAssertEqual(multiset[atEnd], 30)
      XCTAssertEqual(multiset.index(after: atEnd), multiset.endIndex)

      let newLeast = multiset.insert(5, hint: multiset.startIndex)
      XCTAssertEqual(newLeast, multiset.startIndex)
      XCTAssertEqual(Array(multiset), [5, 10, 20, 30])

      let first = Member(key: 1, label: "first")
      var members = RedBlackTreeMultiSet<Member>([first])
      let equivalent = Member(key: 1, label: "new")
      let atStart = members.insert(equivalent, hint: members.startIndex)
      XCTAssertEqual(atStart, members.startIndex)
      XCTAssertEqual(members.map(\.label), ["new", "first"])
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

  #if !COMPATIBLE_ATCODER_2025 && ALLOW_CROSS_TREE_INDEX && !USE_LAZY_DETACH
    /// MultiSetは同値要素を許容するため、`index(inserting:)`は常に新しいoccurrenceを
    /// 挿入し、`inserted`は`true`、`index`はその新しいoccurrenceを指すこと。
    func test_indexInserting_alwaysInsertsNewOccurrence() {
      let first = Member(key: 1, label: "first")
      let second = Member(key: 1, label: "second")
      var multiset = RedBlackTreeMultiSet<Member>()

      let firstResult = multiset.index(inserting: first)
      let secondResult = multiset.index(inserting: second)

      XCTAssertTrue(firstResult.inserted)
      XCTAssertTrue(secondResult.inserted, "MultiSetなので同値でも挿入されるはず")
      XCTAssertNotEqual(firstResult.index, secondResult.index)
      XCTAssertTrue(multiset[firstResult.index] === first)
      XCTAssertTrue(multiset[secondResult.index] === second)
      XCTAssertEqual(multiset.count, 2)
    }

    /// `erase(exactly:)`は、Indexが指すoccurrenceだけを削除し、後続のIndexを返すこと。
    /// 同値の別のoccurrenceは残ること。
    func test_eraseExactly_removesOnlyTheIndexedOccurrence() {
      let first = Member(key: 1, label: "first")
      let second = Member(key: 1, label: "second")
      var multiset = RedBlackTreeMultiSet<Member>()
      let firstIndex = multiset.index(inserting: first).index
      let secondIndex = multiset.index(inserting: second).index

      let successor = multiset.erase(exactly: firstIndex)

      XCTAssertEqual(successor, secondIndex)
      XCTAssertEqual(multiset.count, 1)
      XCTAssertTrue(multiset[multiset.startIndex] === second)
    }

    /// 削除済みのIndexや`endIndex`に対する`erase(exactly:)`は、何も削除せず`nil`を返すこと。
    func test_eraseExactly_returnsNilForStaleOrEndIndex() {
      var multiset: RedBlackTreeMultiSet = [1, 1, 2]
      let index = multiset.index(inserting: 1).index
      XCTAssertNotNil(multiset.erase(exactly: index))

      XCTAssertNil(multiset.erase(exactly: index))
      XCTAssertNil(multiset.erase(exactly: multiset.endIndex))
      XCTAssertEqual(Array(multiset), [1, 1, 2])
    }

    /// 空のMultiSetに対して`erase(exactly:)`を呼んでもトラップせず、`nil`を返すこと。
    /// トラップしない以上、無駄なCoW(共有される空シングルトンバッファからの退避)も
    /// 発生しないこと。
    func test_eraseExactly_onEmptyMultiSetReturnsNilWithoutCopy() {
      var multiset = RedBlackTreeMultiSet<Int>()

      #if AC_COLLECTIONS_INTERNAL_CHECKS
        XCTAssertEqual(multiset._copyCount, 0)
      #endif
      XCTAssertNil(multiset.erase(exactly: multiset.startIndex))
      #if AC_COLLECTIONS_INTERNAL_CHECKS
        XCTAssertEqual(multiset._copyCount, 0, "空の削除はnilを返すだけで、バッファのコピーを発生させないはず")
      #endif
      XCTAssertNil(multiset.erase(exactly: multiset.endIndex))
    }
  #endif
}

#if !COMPATIBLE_ATCODER_2025
  import RedBlackTreeCollections
  import XCTest

  final class RedBlackTreeMultiSetInsertingContentsOfTests: RedBlackTreeTestCase {

    /// `inserting(contentsOf:)`は、multisetでもsetでも全出現を加えた新しいmultisetを返し、入力を変えないこと。
    func testInsertingContentsOfMultiSetAndSet() {
      let m = RedBlackTreeMultiSet<Int>([1, 2])
      let other = RedBlackTreeMultiSet<Int>([2, 3])
      XCTAssertEqual(Array(m.inserting(contentsOf: other)), [1, 2, 2, 3])
      XCTAssertEqual(Array(m.inserting(contentsOf: RedBlackTreeSet<Int>([2, 4]))), [1, 2, 2, 4])
      XCTAssertEqual(Array(m), [1, 2])
      XCTAssertEqual(Array(other), [2, 3])
    }
  }
#endif
