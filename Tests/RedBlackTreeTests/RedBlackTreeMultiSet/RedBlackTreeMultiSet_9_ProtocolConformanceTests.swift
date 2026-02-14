import Foundation
import RedBlackTreeModule
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
}

// MARK: - Comparable
extension RedBlackTreeMultiSetProtocolConformanceTests {

  func test_comparable_ordersByElements() {
    let a: RedBlackTreeMultiSet = [1, 2]
    let b: RedBlackTreeMultiSet = [1, 3]

    XCTAssertTrue(a < b)
    XCTAssertFalse(b < a)
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
#if !COMPATIBLE_ATCODER_2025
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
#endif
