import RedBlackTreeCollections
import XCTest

final class RedBlackTreeSetIntegerElementTests: RedBlackTreeTestCase {

  func test_Int32_supportsFullWidthValuesAndCopyOnWrite() {
    let values: [Int32] = [.max, 1, 0, -1, .min]
    var set = RedBlackTreeSet<Int32>()

    for value in values {
      let result = set.insert(value)
      XCTAssertTrue(result.inserted)
      XCTAssertEqual(result.memberAfterInsert, value)
    }

    let original = set
    XCTAssertEqual(set.remove(0), 0)
    XCTAssertTrue(set.insert(42).inserted)
    XCTAssertEqual(Array(original), values.sorted())
    XCTAssertEqual(Array(set), [.min, -1, 1, 42, .max])
  }

  @available(macOS 15.0, *)
  func test_Int128_supportsValuesBeyondInt64AndCopyOnWrite() {
    let low = -(Int128(1) << 100)
    let middle = Int128(1) << 80
    let high = Int128(1) << 120
    let original: RedBlackTreeSet<Int128> = [low, middle, high]
    var copy = original

    XCTAssertEqual(copy.remove(middle), middle)
    XCTAssertTrue(copy.insert(.min).inserted)
    XCTAssertTrue(copy.insert(.max).inserted)

    XCTAssertEqual(Array(original), [low, middle, high])
    XCTAssertEqual(Array(copy), [.min, low, high, .max])
  }
}
