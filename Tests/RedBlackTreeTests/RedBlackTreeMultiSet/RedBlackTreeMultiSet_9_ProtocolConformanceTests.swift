import Foundation
import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultiSetProtocolConformanceTests: RedBlackTreeTestCase {}

// MARK: - ExpressibleByArrayLiteral
extension RedBlackTreeMultiSetProtocolConformanceTests {

  func test_expressibleByArrayLiteral_allowsDuplicates() {
    let set: RedBlackTreeMultiSet = [1, 2, 2, 3]
    XCTAssertEqual(set.count, 4)
    XCTAssertEqual(set.sorted(), [1, 2, 2, 3])
  }
}

// MARK: - elementsEqual / lexicographicallyPrecedes
extension RedBlackTreeMultiSetProtocolConformanceTests {

  func test_elementsEqual_trueForSameElementsInOrderIncludingDuplicates() {
    let multiset: RedBlackTreeMultiSet = [1, 1, 2]
    XCTAssertTrue(multiset.elementsEqual([1, 1, 2]))
  }

  func test_elementsEqual_falseWhenMultiplicityDiffers() {
    let multiset: RedBlackTreeMultiSet = [1, 1, 2]
    XCTAssertFalse(multiset.elementsEqual([1, 2, 2]))
  }

  func test_lexicographicallyPrecedes_trueWhenSmallerAtFirstDifference() {
    let multiset: RedBlackTreeMultiSet = [1, 1, 2]
    XCTAssertTrue(multiset.lexicographicallyPrecedes([1, 2, 2]))
  }

  func test_lexicographicallyPrecedes_comparesLengthAfterCommonPrefix() {
    let shorter: RedBlackTreeMultiSet = [1, 1]
    let longer: RedBlackTreeMultiSet = [1, 1, 2]
    XCTAssertTrue(shorter.lexicographicallyPrecedes(longer))
    XCTAssertFalse(longer.lexicographicallyPrecedes(shorter))
  }
}

// MARK: - CustomStringConvertible
extension RedBlackTreeMultiSetProtocolConformanceTests {

  func test_customStringConvertible_description() {
    let set: RedBlackTreeMultiSet = [1, 2, 2]
    let description = set.description
    XCTAssertTrue(description.contains("1") && description.contains("2"))
  }
}

// MARK: - CustomDebugStringConvertible
extension RedBlackTreeMultiSetProtocolConformanceTests {

  func test_customDebugStringConvertible_debugDescription() {
    let set: RedBlackTreeMultiSet = [1, 2]
    let debugDescription = set.debugDescription
    XCTAssertTrue(debugDescription.contains(set.description))
  }
}

// MARK: - CustomReflectable
extension RedBlackTreeMultiSetProtocolConformanceTests {

  func test_customReflectable_mirrorContainsElements() {
    let set: RedBlackTreeMultiSet = [3, 1, 2]
    let mirror = set.customMirror

    XCTAssertEqual(mirror.displayStyle, .set)

    let elements = mirror.children.compactMap { $0.value as? Int }.sorted()
    XCTAssertEqual(elements, [1, 2, 3])
    XCTAssertEqual(elements.count, set.count)
  }

  /// 重複する要素も、個別の子としてすべて反映されること
  func test_customReflectable_duplicateElementsAreEachRepresented() {
    let set: RedBlackTreeMultiSet = [1, 1, 2]
    let mirror = set.customMirror

    let elements = mirror.children.compactMap { $0.value as? Int }.sorted()
    XCTAssertEqual(elements, [1, 1, 2])
    XCTAssertEqual(mirror.children.count, set.count)
  }

  /// すべての子がラベル無し(unlabeled)であること
  func test_customReflectable_childrenAreUnlabeled() {
    let set: RedBlackTreeMultiSet = [1, 1, 2]
    let mirror = set.customMirror

    XCTAssertTrue(mirror.children.allSatisfy { $0.label == nil })
  }

  /// 空のMultiSetの子は0件であること
  func test_customReflectable_emptyMultiSetHasNoChildren() {
    let set = RedBlackTreeMultiSet<Int>()
    let mirror = set.customMirror

    XCTAssertEqual(mirror.children.count, 0)
  }
}

// MARK: - Is Trivially Identical
extension RedBlackTreeMultiSetProtocolConformanceTests {

  func test_isTriviallyIdentical_copyIsIdentical() {
    let a: RedBlackTreeMultiSet = [1, 2, 2]
    let b = a
    XCTAssertTrue(a.isTriviallyIdentical(to: b))
  }

  func test_isTriviallyIdentical_mutationBreaksIdentity() {
    let a: RedBlackTreeMultiSet = [1, 2, 2]
    var b = a
    b.insert(3)
    XCTAssertFalse(a.isTriviallyIdentical(to: b))
  }
}

// MARK: - Equatable
extension RedBlackTreeMultiSetProtocolConformanceTests {

  func test_equatable_setsAreEqual() {
    let a: RedBlackTreeMultiSet = [1, 2, 2]
    let b: RedBlackTreeMultiSet = [2, 1, 2]
    XCTAssertEqual(a, b)
  }

  func test_equatable_setsAreNotEqual() {
    let a: RedBlackTreeMultiSet = [1, 2, 2]
    let b: RedBlackTreeMultiSet = [1, 2, 3]
    XCTAssertNotEqual(a, b)
  }

  func test_equatable_rangeViewsFromDifferentTreesCompareByElements() {
    let aa = RedBlackTreeMultiSet<Int>([0, 1, 2, 3, 4, 5])
    let bb = RedBlackTreeMultiSet<Int>([3, 4, 5, 6, 7, 8])

    XCTAssertEqual(aa[aa.lowerBound(3)..<aa.lowerBound(6)], bb[bb.lowerBound(3)..<bb.lowerBound(6)])
    XCTAssertNotEqual(
      aa[aa.lowerBound(2)..<aa.lowerBound(6)], bb[bb.lowerBound(3)..<bb.lowerBound(6)])
  }
}

// MARK: - Comparable
extension RedBlackTreeMultiSetProtocolConformanceTests {

  func test_comparable_ordersByElements() {
    let a: RedBlackTreeMultiSet = [1, 2]
    let b: RedBlackTreeMultiSet = [1, 3]

    XCTAssertTrue(a < b)
    XCTAssertFalse(b < a)
  }

  func test_comparable_rangeViewsFromDifferentTreesOrderByElements() {
    let aa = RedBlackTreeMultiSet<Int>([0, 1, 2, 3, 4, 5])
    let bb = RedBlackTreeMultiSet<Int>([3, 4, 5, 6, 7, 8])

    XCTAssertTrue(aa[aa.lowerBound(2)..<aa.lowerBound(6)] < bb[bb.lowerBound(3)..<bb.lowerBound(6)])
    XCTAssertFalse(bb[bb.lowerBound(3)..<bb.lowerBound(6)] < aa[aa.lowerBound(2)..<aa.lowerBound(6)])
  }
}

// MARK: - Hashable
extension RedBlackTreeMultiSetProtocolConformanceTests {

  func test_hashable_allowsSetOfSets() {
    let a: RedBlackTreeMultiSet = [1, 2]
    let b: RedBlackTreeMultiSet = [2, 3]
    let c: RedBlackTreeMultiSet = [1, 2]

    let setOfSets: Set<RedBlackTreeMultiSet<Int>> = [a, b]
    XCTAssertTrue(setOfSets.contains(a))
    XCTAssertTrue(setOfSets.contains(b))
    XCTAssertTrue(setOfSets.contains(c))
    XCTAssertEqual(setOfSets.count, 2)
  }
}

// MARK: - Sendable
#if swift(>=5.5)
extension RedBlackTreeMultiSetProtocolConformanceTests {

  func test_sendable_compiles() {
    func requiresSendable<T: Sendable>(_ value: T) {}
    let set: RedBlackTreeMultiSet = [1, 2, 3]
    requiresSendable(set)
  }
}
#endif

// MARK: - Codable
extension RedBlackTreeMultiSetProtocolConformanceTests {

  func test_codable_roundTrip() throws {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    let original: RedBlackTreeMultiSet = [1, 2, 2, 3]
    let data = try encoder.encode(original)
    let decoded = try decoder.decode(RedBlackTreeMultiSet<Int>.self, from: data)

    XCTAssertEqual(decoded, original)
  }
}
