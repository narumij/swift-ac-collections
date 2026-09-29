import RedBlackTreeCollections
import XCTest

final class RedBlackTreeMultiSetIntegerElementTests: RedBlackTreeTestCase {

  func test_Int32_supportsFullWidthValuesAndCopyOnWrite() {
    let values: [Int32] = [.max, 1, 0, -1, .min, 0]
    var set = RedBlackTreeMultiSet<Int32>()

    for value in values {
      set.insert(value)
    }

    let original = set
    #if COMPATIBLE_ATCODER_2025
      XCTAssertEqual(set.removeAll(0), 0)
    #else
      XCTAssertEqual(set.eraseMulti(0), 2)
    #endif
    XCTAssertTrue(set.insert(42).inserted)
    XCTAssertEqual(Array(original), values.sorted())
    XCTAssertEqual(Array(set), [.min, -1, 1, 42, .max])
  }

  @available(macOS 15.0, *)
  func test_Int128_supportsValuesBeyondInt64AndCopyOnWrite() {
    let low = -(Int128(1) << 100)
    let middle = Int128(1) << 80
    let high = Int128(1) << 120
    let original: RedBlackTreeMultiSet<Int128> = [low, middle, high, middle]
    var copy = original

    #if COMPATIBLE_ATCODER_2025
      XCTAssertEqual(copy.removeAll(middle), middle)
    #else
      XCTAssertEqual(copy.eraseMulti(middle), 2)
    #endif
    copy.insert(.min)
    copy.insert(.max)

    XCTAssertEqual(Array(original), [low, middle, middle, high])
    XCTAssertEqual(Array(copy), [.min, low, high, .max])
  }
}
