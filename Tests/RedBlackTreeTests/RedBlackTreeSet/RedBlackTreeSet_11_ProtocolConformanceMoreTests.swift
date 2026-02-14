import RedBlackTreeModule
import XCTest

final class RedBlackTreeSetProtocolConformanceMoreTests: RedBlackTreeTestCase {}

// MARK: - CustomReflectable
extension RedBlackTreeSetProtocolConformanceMoreTests {

  func test_customReflectable_mirrorContainsElements() {
    let set: RedBlackTreeSet = [3, 1, 2]
    let mirror = set.customMirror

    XCTAssertEqual(mirror.displayStyle, .set)

    let elements = mirror.children.compactMap { $0.value as? Int }.sorted()
    XCTAssertEqual(elements, [1, 2, 3])
    XCTAssertEqual(elements.count, set.count)
  }
}

// MARK: - Is Trivially Identical
extension RedBlackTreeSetProtocolConformanceMoreTests {

  func test_isTriviallyIdentical_copyIsIdentical() {
    let a: RedBlackTreeSet = [1, 2, 3]
    let b = a

    XCTAssertTrue(a.isTriviallyIdentical(to: b))
  }

  func test_isTriviallyIdentical_mutationBreaksIdentity() {
    let a: RedBlackTreeSet = [1, 2, 3]
    var b = a
    b.insert(4)

    XCTAssertFalse(a.isTriviallyIdentical(to: b))
  }
}

// MARK: - Comparable
extension RedBlackTreeSetProtocolConformanceMoreTests {

  func test_comparable_ordersByElements() {
    let a: RedBlackTreeSet = [1, 2]
    let b: RedBlackTreeSet = [1, 3]

    XCTAssertTrue(a < b)
    XCTAssertFalse(b < a)
  }

  func test_comparable_equalIsNotLessThan() {
    let a: RedBlackTreeSet = [1, 2, 3]
    let b: RedBlackTreeSet = [3, 2, 1]

    XCTAssertFalse(a < b)
    XCTAssertFalse(b < a)
  }
}

// MARK: - Hashable
extension RedBlackTreeSetProtocolConformanceMoreTests {

  func test_hashable_allowsSetOfSets() {
    let a: RedBlackTreeSet = [1, 2]
    let b: RedBlackTreeSet = [2, 3]
    let c: RedBlackTreeSet = [1, 2]

    let setOfSets: Set<RedBlackTreeSet<Int>> = [a, b]
    XCTAssertTrue(setOfSets.contains(a))
    XCTAssertTrue(setOfSets.contains(b))
    XCTAssertTrue(setOfSets.contains(c))
    XCTAssertEqual(setOfSets.count, 2)
  }
}

// MARK: - Sendable
#if swift(>=5.5)
extension RedBlackTreeSetProtocolConformanceMoreTests {

  func test_sendable_compiles() {
    func requiresSendable<T: Sendable>(_ value: T) {}
    let set: RedBlackTreeSet = [1, 2, 3]
    requiresSendable(set)
  }
}
#endif
