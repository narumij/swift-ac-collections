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

  func test_insertContentsOf_emptyTreeIntoSharedMultiSetDoesNotCopy() {
    let original: RedBlackTreeMultiSet<Int> = [1, 2, 2, 3]

    var fromSet = original
    fromSet.insert(contentsOf: RedBlackTreeSet<Int>())
    XCTAssertEqual(Array(fromSet), [1, 2, 2, 3])
    XCTAssertTrue(fromSet.isTriviallyIdentical(to: original), "空のSetのinsert(contentsOf:)で木がコピーされた")

    var fromMultiSet = original
    fromMultiSet.insert(contentsOf: RedBlackTreeMultiSet<Int>())
    XCTAssertEqual(Array(fromMultiSet), [1, 2, 2, 3])
    XCTAssertTrue(fromMultiSet.isTriviallyIdentical(to: original), "空のMultiSetのinsert(contentsOf:)で木がコピーされた")
  }

  func test_insertContentsOf_emptySequenceIntoSharedMultiSetDoesNotCopy() {
    let original: RedBlackTreeMultiSet<Int> = [1, 2, 2, 3]
    var shared = original

    shared.insert(contentsOf: [Int]())

    XCTAssertEqual(Array(shared), [1, 2, 2, 3])
    XCTAssertTrue(shared.isTriviallyIdentical(to: original), "空のSequenceのinsert(contentsOf:)で木がコピーされた")
  }

  func test_insertContentsOf_singlePassSequenceConsumesEveryElementOnce() {
    let original: RedBlackTreeMultiSet<Int> = [1, 3]
    var multiset = original
    let source = SinglePassSequence([0, 3, 3, 5])

    multiset.insert(contentsOf: source)

    XCTAssertEqual(Array(multiset), [0, 1, 3, 3, 3, 5])
    XCTAssertEqual(Array(original), [1, 3])
    XCTAssertEqual(source.makeIteratorCount, 1)
    XCTAssertTrue(source.isExhausted)
  }

  func test_insertContentsOf_preservesMultiplicity() {
    var multiset = RedBlackTreeMultiSet([1, 2])

    multiset.insert(contentsOf: [2, 3, 3])

    XCTAssertEqual(Array(multiset), [1, 2, 2, 3, 3])
  }

  // MARK: - 同値要素の並び（RBT-074）

  private func members(_ pairs: [(Int, String)]) -> [Member] {
    pairs.map { Member(key: $0.0, label: $0.1) }
  }

  /// 通常挿入は、新しい要素を既存の同値要素の後ろに置くこと（RBT-074）
  func test_insert_appendsAfterExistingEquivalentMembers() {
    var multiset = RedBlackTreeMultiSet<Member>()

    for member in members([(1, "a1"), (2, "x"), (1, "a2"), (0, "y"), (1, "a3")]) {
      multiset.insert(member)
    }

    XCTAssertEqual(multiset.map(\.label), ["y", "a1", "a2", "a3", "x"])
  }

  /// 列からの初期化は、同値要素を入力の順に並べること（RBT-074）
  func test_initFromSequence_keepsInputOrderOfEquivalentMembers() {
    let input = members([(2, "b1"), (1, "a1"), (2, "b2"), (1, "a2"), (2, "b3")])
    let expected = ["a1", "a2", "b1", "b2", "b3"]

    XCTAssertEqual(RedBlackTreeMultiSet(input).map(\.label), expected)
    XCTAssertEqual(RedBlackTreeMultiSet(AnySequence(input)).map(\.label), expected)
  }

  /// insert(contentsOf:)・inserting(contentsOf:)は、既存の同値要素の後ろに、
  /// 入力側の同値要素を入力の順で置くこと（RBT-074）
  func test_insertContentsOf_appendsEquivalentMembersAfterExistingOnes() {
    let multiset = RedBlackTreeMultiSet(members([(1, "a0"), (5, "a1"), (5, "a2"), (9, "a9")]))
    let other = members([(5, "b1"), (5, "b2"), (5, "b3"), (7, "b7")])
    let expected = ["a0", "a1", "a2", "b1", "b2", "b3", "b7", "a9"]

    var fromMultiSet = multiset
    fromMultiSet.insert(contentsOf: RedBlackTreeMultiSet(other))
    XCTAssertEqual(fromMultiSet.map(\.label), expected)

    var fromSequence = multiset
    fromSequence.insert(contentsOf: other)
    XCTAssertEqual(fromSequence.map(\.label), expected)

    XCTAssertEqual(multiset.inserting(contentsOf: RedBlackTreeMultiSet(other)).map(\.label), expected)
    XCTAssertEqual(multiset.inserting(contentsOf: other).map(\.label), expected)

    var fromSet = multiset
    fromSet.insert(contentsOf: RedBlackTreeSet(members([(5, "s5"), (9, "s9")])))
    XCTAssertEqual(fromSet.map(\.label), ["a0", "a1", "a2", "s5", "a9", "s9"])
  }

  /// 固定シードの乱択入力でも、初期化とinsert(contentsOf:)の結果が、
  /// キーごとに「既存の並び→入力の並び」（安定なmerge）と一致すること（RBT-074）
  func test_insertContentsOf_matchesStableMergeForSeededInputs() {
    var random = InsertionOrderRandom(seed: 0x5EED_0074)

    for trial in 0..<200 {
      let lhs = members(
        (0..<Int.random(in: 0...40, using: &random)).map { (Int.random(in: 0...5, using: &random), "a\($0)") })
      let rhs = members(
        (0..<Int.random(in: 0...40, using: &random)).map { (Int.random(in: 0...5, using: &random), "b\($0)") })
      let expected = (lhs + rhs).enumerated()
        .sorted { ($0.element.key, $0.offset) < ($1.element.key, $1.offset) }
        .map(\.element.label)

      var fromMultiSet = RedBlackTreeMultiSet(lhs)
      fromMultiSet.insert(contentsOf: RedBlackTreeMultiSet(rhs))
      XCTAssertEqual(fromMultiSet.map(\.label), expected, "trial \(trial)")

      var fromSequence = RedBlackTreeMultiSet(lhs)
      fromSequence.insert(contentsOf: rhs)
      XCTAssertEqual(fromSequence.map(\.label), expected, "trial \(trial)")
    }
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

    #if false
    // RBT-048: Previous nil-returning contract; retained for API review.
    func test_update_rejectsEndIndexAndNonEquivalentMember() {
      let member = Member(key: 1, label: "member")
      var multiset = RedBlackTreeMultiSet([member])

      XCTAssertNil(multiset.update(Member(key: 1, label: "new"), at: multiset.endIndex))
      XCTAssertNil(multiset.update(Member(key: 2, label: "different"), at: multiset.startIndex))
      XCTAssertTrue(multiset[multiset.startIndex] === member)
    }
    #endif

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

    /// 削除済みのIndexへのupdateはnilを返し、残っている等価な要素とその個数を変えないこと（RBT-043 M1）
    #if false
    // RBT-048: Previous nil-returning contract; retained for API review.
    func test_update_atRemovedIndexReturnsNilAndKeepsSurvivors() {
      let members = [
        Member(key: 1, label: "first"),
        Member(key: 1, label: "middle"),
        Member(key: 1, label: "last"),
      ]
      var multiset = RedBlackTreeMultiSet(members)
      let removedIndex = multiset.index(after: multiset.startIndex)
      XCTAssertTrue(multiset.remove(at: removedIndex) === members[1])
      XCTAssertFalse(multiset.isElement(at: removedIndex), "削除した位置のIndexは無効になっていること")

      XCTAssertNil(multiset.update(Member(key: 1, label: "new"), at: removedIndex))

      let result = Array(multiset)
      XCTAssertEqual(result.count, 2)
      XCTAssertTrue(result[0] === members[0])
      XCTAssertTrue(result[1] === members[2])
    }
    #endif
  #endif

  #if !COMPATIBLE_ATCODER_2025 && ALLOW_CROSS_TREE_INDEX
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

      #if _TREE_COPY_COUNTER
        XCTAssertEqual(multiset._copyCount, 0)
      #endif
      XCTAssertNil(multiset.erase(exactly: multiset.startIndex))
      #if _TREE_COPY_COUNTER
        XCTAssertEqual(multiset._copyCount, 0, "空の削除はnilを返すだけで、バッファのコピーを発生させないはず")
      #endif
      XCTAssertNil(multiset.erase(exactly: multiset.endIndex))
    }

    /// 共有中の空でない木に`endIndex`で`erase(exactly:)`しても、`nil`を返し木をコピーしないこと（RBT-081）。
    func test_eraseExactly_endIndexKeepsSharedStorage() {
      let original: RedBlackTreeMultiSet<Int> = [1, 2, 2, 3]
      var shared = original

      XCTAssertNil(shared.erase(exactly: shared.endIndex))

      XCTAssertTrue(shared.isTriviallyIdentical(to: original), "endIndexのerase(exactly:)で木がコピーされた")
    }

    /// 共有中の空でない木に失効したIndexで`erase(exactly:)`しても、`nil`を返し木をコピーしないこと（RBT-081）。
    func test_eraseExactly_staleIndexKeepsSharedStorage() {
      var shared: RedBlackTreeMultiSet<Int> = [1, 2, 2, 3]
      let i = shared.startIndex
      XCTAssertNotNil(shared.erase(exactly: i))
      let original = shared

      XCTAssertNil(shared.erase(exactly: i))

      XCTAssertEqual(Array(shared), [2, 2, 3])
      XCTAssertTrue(shared.isTriviallyIdentical(to: original), "失効したIndexのerase(exactly:)で木がコピーされた")
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

/// SplitMix64. 並びのテストで、再現できる乱択入力を作る
private struct InsertionOrderRandom: RandomNumberGenerator {
  var state: UInt64
  init(seed: UInt64) { state = seed }
  mutating func next() -> UInt64 {
    state &+= 0x9E37_79B9_7F4A_7C15
    var z = state
    z = (z ^ (z &>> 30)) &* 0xBF58_476D_1CE4_E5B9
    z = (z ^ (z &>> 27)) &* 0x94D0_49BB_1331_11EB
    return z ^ (z &>> 31)
  }
}
