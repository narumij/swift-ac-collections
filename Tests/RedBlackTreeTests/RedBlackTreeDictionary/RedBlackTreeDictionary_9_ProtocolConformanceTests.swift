import RedBlackTreeModule
import XCTest

final class RedBlackTreeDictionaryProtocolConformanceTests: RedBlackTreeTestCase {}

// MARK: - ExpressibleByDictionaryLiteral
extension RedBlackTreeDictionaryProtocolConformanceTests {

  func test_expressibleByDictionaryLiteral() {
    let dict: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b"]
    XCTAssertEqual(dict.count, 2)
    XCTAssertEqual(dict[1], "a")
  }
}

// MARK: - ExpressibleByArrayLiteral
extension RedBlackTreeDictionaryProtocolConformanceTests {

  func test_expressibleByArrayLiteral() {
    let dict: RedBlackTreeDictionary<Int, String> = [(1, "a"), (2, "b")]
    XCTAssertEqual(dict.count, 2)
    XCTAssertEqual(dict[2], "b")
  }
}

// MARK: - CustomStringConvertible
extension RedBlackTreeDictionaryProtocolConformanceTests {

  func test_customStringConvertible_description() {
    let dict: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b"]
    let description = dict.description
    XCTAssertTrue(description.contains("1") && description.contains("a"))
  }
}

// MARK: - CustomDebugStringConvertible
extension RedBlackTreeDictionaryProtocolConformanceTests {

  func test_customDebugStringConvertible_debugDescription() {
    let dict: RedBlackTreeDictionary<Int, String> = [1: "a"]
    let debugDescription = dict.debugDescription
    XCTAssertTrue(debugDescription.contains(dict.description))
  }
}

// MARK: - CustomReflectable
extension RedBlackTreeDictionaryProtocolConformanceTests {

  func test_customReflectable_mirrorContainsElements() {
    let dict: RedBlackTreeDictionary<Int, String> = [2: "b", 1: "a"]
    let mirror = dict.customMirror

    XCTAssertEqual(mirror.displayStyle, .dictionary)
    XCTAssertEqual(mirror.children.count, dict.count)
  }
}

// MARK: - Is Trivially Identical
extension RedBlackTreeDictionaryProtocolConformanceTests {

  func test_isTriviallyIdentical_copyIsIdentical() {
    let a: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b"]
    let b = a
    XCTAssertTrue(a.isTriviallyIdentical(to: b))
  }

  func test_isTriviallyIdentical_mutationBreaksIdentity() {
    let a: RedBlackTreeDictionary<Int, String> = [1: "a"]
    var b = a
    b[2] = "b"
    XCTAssertFalse(a.isTriviallyIdentical(to: b))
  }
}

// MARK: - Equatable
extension RedBlackTreeDictionaryProtocolConformanceTests {

  func test_equatable_dictsAreEqual() {
    let a: RedBlackTreeDictionary<Int, String> = [1: "a", 2: "b"]
    let b: RedBlackTreeDictionary<Int, String> = [2: "b", 1: "a"]
    XCTAssertEqual(a, b)
  }

  func test_equatable_dictsAreNotEqual() {
    let a: RedBlackTreeDictionary<Int, String> = [1: "a"]
    let b: RedBlackTreeDictionary<Int, String> = [1: "b"]
    XCTAssertNotEqual(a, b)
  }
}

// MARK: - Comparable
extension RedBlackTreeDictionaryProtocolConformanceTests {

  func test_comparable_ordersByElements() {
    let a: RedBlackTreeDictionary<Int, String> = [1: "a"]
    let b: RedBlackTreeDictionary<Int, String> = [1: "b"]

    XCTAssertTrue(a < b)
    XCTAssertFalse(b < a)
  }
}

// MARK: - Hashable
extension RedBlackTreeDictionaryProtocolConformanceTests {

  func test_hashable_allowsSetOfDictionaries() {
    let a: RedBlackTreeDictionary<Int, String> = [1: "a"]
    let b: RedBlackTreeDictionary<Int, String> = [2: "b"]
    let c: RedBlackTreeDictionary<Int, String> = [1: "a"]

    let setOfDicts: Set<RedBlackTreeDictionary<Int, String>> = [a, b]
    XCTAssertTrue(setOfDicts.contains(a))
    XCTAssertTrue(setOfDicts.contains(b))
    XCTAssertTrue(setOfDicts.contains(c))
    XCTAssertEqual(setOfDicts.count, 2)
  }
}

// MARK: - Sendable
#if swift(>=5.5)
extension RedBlackTreeDictionaryProtocolConformanceTests {

  func test_sendable_compiles() {
    func requiresSendable<T: Sendable>(_ value: T) {}
    let dict: RedBlackTreeDictionary<Int, String> = [1: "a"]
    requiresSendable(dict)
  }
}
#endif
