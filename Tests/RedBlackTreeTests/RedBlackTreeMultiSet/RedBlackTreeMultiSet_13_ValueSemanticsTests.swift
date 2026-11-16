import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultiSetValueSemanticsTests: RedBlackTreeTestCase {

  /// コピーを変更しても元の集合は変更されないこと
  func test_copyOnWrite_mutatingCopyPreservesOriginal() {
    let original: RedBlackTreeMultiSet = [1, 2, 2, 3]
    var copy = original

    copy.insert(99)
    #if COMPATIBLE_ATCODER_2025
      copy.removeAll(2)
    #else
      copy.eraseMulti(2)
    #endif

    XCTAssertEqual(Array(original), [1, 2, 2, 3])
    XCTAssertEqual(Array(copy), [1, 3, 99])
  }

  /// コピーした後、元の側とコピーの側をそれぞれクロージャの中で変更しても、互いに影響しないこと
  func test_copyOnWrite_mutatingInsideClosuresKeepsCopiesIndependent() {
    var original: RedBlackTreeMultiSet = [1, 2, 2, 3]
    original.insert(0)
    var copy = original

    // 変更はassertionの@autoclosureの中で行う。Swift 6.4の`-O`では、この形でCoWが壊れる型が
    // あった(`NextPermutationsSequence`、2026-10-07)。赤黒木では再現しなかった
    XCTAssertTrue(original.insert(99).inserted)
    XCTAssertTrue(copy.insert(99).inserted)

    XCTAssertEqual(Array(original), [0, 1, 2, 2, 3, 99])
    XCTAssertEqual(Array(copy), [0, 1, 2, 2, 3, 99])
  }
  /// 同じ参照を複数回格納したmultisetを共有コピーで分岐させても、残る出現と共有コピーが参照を保持し、
  /// 最後の保持がなくなったときにだけ解放されること（RBT-043 M5）
  func test_sameReferenceStoredMultipleTimesIsReleasedAfterTheLastOwner() {
    final class Member: Comparable {
      let key: Int
      init(_ key: Int) { self.key = key }
      static func == (lhs: Member, rhs: Member) -> Bool { lhs.key == rhs.key }
      static func < (lhs: Member, rhs: Member) -> Bool { lhs.key < rhs.key }
    }
    weak var weakMember: Member?
    var multiset: RedBlackTreeMultiSet<Member>
    var copy: RedBlackTreeMultiSet<Member>
    do {
      let member = Member(1)
      weakMember = member
      multiset = RedBlackTreeMultiSet([member, member, member, Member(2)])
      copy = multiset
    }
    XCTAssertNotNil(weakMember)

    _ = multiset.popFirst()
    XCTAssertNotNil(weakMember, "残る出現が参照を保持すること")
    _ = multiset.popFirst()
    _ = multiset.popFirst()
    XCTAssertEqual(multiset.map(\.key), [2])
    XCTAssertNotNil(weakMember, "変更側から全出現を除いても、共有コピーが参照を保持すること")
    do {
      let shared = Array(copy)
      XCTAssertEqual(shared.map(\.key), [1, 1, 1, 2])
      XCTAssertTrue(shared.prefix(3).allSatisfy { $0 === weakMember })
    }

    copy.removeAll()
    XCTAssertNil(weakMember, "最後の保持がなくなったときに解放されること")
  }
}
