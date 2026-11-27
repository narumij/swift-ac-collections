import RedBlackTreeCollections
import XCTest

final class RedBlackTreeDictionaryUpdateMemberTests: RedBlackTreeTestCase {

  func test_update_insertsMissingKeyAndReturnsNil() {
    var dictionary = RedBlackTreeDictionary<Int, String>()

    XCTAssertNil(dictionary.update((2, "two")))
    XCTAssertNil(dictionary.update((1, "one")))
    XCTAssertNil(dictionary.update((3, "three")))

    XCTAssertEqual(dictionary.count, 3)
    XCTAssertEqual(dictionary.map(\.key), [1, 2, 3])
    XCTAssertEqual(dictionary.map(\.value), ["one", "two", "three"])
  }

  func test_update_replacesExistingPairAndReturnsPreviousPair() {
    var dictionary: RedBlackTreeDictionary<Int, String> = [1: "one", 2: "two", 3: "three"]

    let first = dictionary.update((2, "updated"))
    XCTAssertEqual(first?.key, 2)
    XCTAssertEqual(first?.value, "two")
    let second = dictionary.update((2, "again"))
    XCTAssertEqual(second?.key, 2)
    XCTAssertEqual(second?.value, "updated")

    XCTAssertEqual(dictionary.count, 3)
    XCTAssertEqual(dictionary.map(\.key), [1, 2, 3])
    XCTAssertEqual(dictionary.map(\.value), ["one", "again", "three"])
  }

  private struct Key: Comparable {
    let order: Int
    let label: String

    static func == (lhs: Self, rhs: Self) -> Bool { lhs.order == rhs.order }
    static func < (lhs: Self, rhs: Self) -> Bool { lhs.order < rhs.order }
  }

  func test_update_replacesEquivalentKeyAsWellAsValue() {
    var dictionary = RedBlackTreeDictionary<Key, String>()
    dictionary.insert((Key(order: 1, label: "left"), "one"))
    dictionary.insert((Key(order: 2, label: "old"), "two"))
    dictionary.insert((Key(order: 3, label: "right"), "three"))
    let replacement = Key(order: 2, label: "new")

    let previous = dictionary.update((replacement, "updated"))
    XCTAssertEqual(previous?.key.order, 2)
    XCTAssertEqual(previous?.key.label, "old")
    XCTAssertEqual(previous?.value, "two")

    XCTAssertEqual(dictionary.count, 3)
    XCTAssertEqual(dictionary.map { $0.key.order }, [1, 2, 3])
    XCTAssertEqual(dictionary.map { $0.key.label }, ["left", "new", "right"])
    XCTAssertEqual(dictionary[Key(order: 2, label: "query")], "updated")
  }

  func test_update_preservesSharedOriginalWhenReplacingKeyAndInserting() {
    let key = Key(order: 2, label: "original")
    let original = RedBlackTreeDictionary<Key, String>(uniqueKeysWithValues: [(key, "two")])
    var copy = original

    let previous = copy.update((Key(order: 2, label: "replacement"), "updated"))
    XCTAssertEqual(previous?.key.order, 2)
    XCTAssertEqual(previous?.key.label, "original")
    XCTAssertEqual(previous?.value, "two")
    XCTAssertNil(copy.update((Key(order: 1, label: "inserted"), "one")))

    XCTAssertEqual(original.map { $0.key.label }, ["original"])
    XCTAssertEqual(original.map(\.value), ["two"])
    XCTAssertEqual(copy.map { $0.key.label }, ["inserted", "replacement"])
    XCTAssertEqual(copy.map(\.value), ["one", "updated"])
  }

  func test_update_insertingIntoSharedDictionaryPreservesOriginal() {
    let original: RedBlackTreeDictionary<Int, String> = [2: "two"]
    var copy = original

    XCTAssertNil(copy.update((1, "one")))

    XCTAssertEqual(original.map(\.key), [2])
    XCTAssertEqual(original.map(\.value), ["two"])
    XCTAssertEqual(copy.map(\.key), [1, 2])
    XCTAssertEqual(copy.map(\.value), ["one", "two"])
  }

  func test_update_optionalValueDistinguishesInsertionFromReplacingStoredNil() {
    var dictionary = RedBlackTreeDictionary<Int, Int?>()

    let inserted = dictionary.update((1, nil))
    guard case .none = inserted else { return XCTFail("Insertion must return nil") }
    XCTAssertEqual(dictionary.count, 1)

    let replacedNil = dictionary.update((1, 42))
    guard case .some((key: 1, value: .none)) = replacedNil else { return XCTFail("The previous stored value was nil") }

    let replacedValue = dictionary.update((1, nil))
    guard case .some((key: 1, value: .some(42))) = replacedValue else { return XCTFail("The previous stored value was 42") }
    guard case .some(.none) = dictionary[1] else { return XCTFail("Updating to nil must retain the key") }
    XCTAssertEqual(dictionary.count, 1)
  }

  func test_update_returnsOldReferenceWithoutRetainingItInDictionary() {
    final class Value {}
    var dictionary = RedBlackTreeDictionary<Int, Value>()
    var old: Value? = Value()
    weak var observedOld = old
    dictionary.update((1, old!))
    old = nil
    let replacement = Value()

    var returned = dictionary.update((1, replacement))

    XCTAssertNotNil(observedOld)
    XCTAssertEqual(returned?.key, 1)
    XCTAssertTrue(returned?.value === observedOld)
    XCTAssertTrue(dictionary[1] === replacement)
    returned = nil
    XCTAssertNil(observedOld)
  }
}
