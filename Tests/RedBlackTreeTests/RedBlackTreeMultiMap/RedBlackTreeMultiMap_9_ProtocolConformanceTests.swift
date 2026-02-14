import RedBlackTreeModule
import XCTest

final class RedBlackTreeMultiMapProtocolConformanceTests: RedBlackTreeTestCase {}

// MARK: - ExpressibleByDictionaryLiteral
extension RedBlackTreeMultiMapProtocolConformanceTests {

  func test_expressibleByDictionaryLiteral() {
    let map: RedBlackTreeMultiMap<Int, String> = [1: "a", 2: "b"]
    XCTAssertEqual(map.count, 2)
  }
}

// MARK: - ExpressibleByArrayLiteral
extension RedBlackTreeMultiMapProtocolConformanceTests {

  func test_expressibleByArrayLiteral() {
    let map: RedBlackTreeMultiMap<Int, String> = [(1, "a"), (1, "b"), (2, "c")]
    XCTAssertEqual(map.count, 3)
  }
}

// MARK: - CustomStringConvertible
extension RedBlackTreeMultiMapProtocolConformanceTests {

  func test_customStringConvertible_description() {
    let map: RedBlackTreeMultiMap<Int, String> = [(1, "a"), (2, "b")]
    let description = map.description
    XCTAssertTrue(description.contains("1") && description.contains("a"))
  }
}

// MARK: - CustomDebugStringConvertible
extension RedBlackTreeMultiMapProtocolConformanceTests {

  func test_customDebugStringConvertible_debugDescription() {
    let map: RedBlackTreeMultiMap<Int, String> = [(1, "a")]
    let debugDescription = map.debugDescription
    XCTAssertTrue(debugDescription.contains(map.description))
  }
}

// MARK: - CustomReflectable
extension RedBlackTreeMultiMapProtocolConformanceTests {

  func test_customReflectable_mirrorContainsElements() {
    let map: RedBlackTreeMultiMap<Int, String> = [(2, "b"), (1, "a")]
    let mirror = map.customMirror

    XCTAssertEqual(mirror.displayStyle, .dictionary)
    XCTAssertEqual(mirror.children.count, map.count)
  }
}

// MARK: - Is Trivially Identical
extension RedBlackTreeMultiMapProtocolConformanceTests {

  func test_isTriviallyIdentical_copyIsIdentical() {
    let a: RedBlackTreeMultiMap<Int, String> = [(1, "a"), (2, "b")]
    let b = a
    XCTAssertTrue(a.isTriviallyIdentical(to: b))
  }

  func test_isTriviallyIdentical_mutationBreaksIdentity() {
    let a: RedBlackTreeMultiMap<Int, String> = [(1, "a")]
    var b = a
    b.insert(key: 2, value: "b")
    XCTAssertFalse(a.isTriviallyIdentical(to: b))
  }
}

// MARK: - Equatable
extension RedBlackTreeMultiMapProtocolConformanceTests {

  func test_equatable_mapsAreEqual() {
    let a: RedBlackTreeMultiMap<Int, String> = [(1, "a"), (2, "b")]
    let b: RedBlackTreeMultiMap<Int, String> = [(2, "b"), (1, "a")]
    XCTAssertEqual(a, b)
  }

  func test_equatable_mapsAreNotEqual() {
    let a: RedBlackTreeMultiMap<Int, String> = [(1, "a")]
    let b: RedBlackTreeMultiMap<Int, String> = [(1, "b")]
    XCTAssertNotEqual(a, b)
  }
}

// MARK: - Comparable
extension RedBlackTreeMultiMapProtocolConformanceTests {

  func test_comparable_ordersByElements() {
    let a: RedBlackTreeMultiMap<Int, String> = [(1, "a")]
    let b: RedBlackTreeMultiMap<Int, String> = [(1, "b")]

    XCTAssertTrue(a < b)
    XCTAssertFalse(b < a)
  }
}

// MARK: - Hashable
extension RedBlackTreeMultiMapProtocolConformanceTests {

  func test_hashable_allowsSetOfMaps() {
    let a: RedBlackTreeMultiMap<Int, String> = [(1, "a")]
    let b: RedBlackTreeMultiMap<Int, String> = [(2, "b")]
    let c: RedBlackTreeMultiMap<Int, String> = [(1, "a")]

    let setOfMaps: Set<RedBlackTreeMultiMap<Int, String>> = [a, b]
    XCTAssertTrue(setOfMaps.contains(a))
    XCTAssertTrue(setOfMaps.contains(b))
    XCTAssertTrue(setOfMaps.contains(c))
    XCTAssertEqual(setOfMaps.count, 2)
  }
}

// MARK: - Sendable
#if swift(>=5.5)
extension RedBlackTreeMultiMapProtocolConformanceTests {

  func test_sendable_compiles() {
    func requiresSendable<T: Sendable>(_ value: T) {}
    let map: RedBlackTreeMultiMap<Int, String> = [(1, "a")]
    requiresSendable(map)
  }
}
#endif
